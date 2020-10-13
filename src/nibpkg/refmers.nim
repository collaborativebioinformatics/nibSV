import hts
import kmers
import tables
import svidx

type
    Chunk = object
        chrom_name: string
        chrom_start: int
        chrom_end: int

proc addRefCount(refKmers: CountTableRef[uint64], svKmers: svIdx) =
    for k, v in pairs(refKmers):
        if svKmers.hasKey(k):
            svKmers[k].refCount += uint32(v)

iterator createdChunks(fai: Fai, chunk_size: int): Chunk =
    for i in 0..<fai.len:
        let chrom_name = fai[i]
        let chrom_len = fai.chrom_len(chrom_name)
        for j in countup(0, chrom_len, chunk_size):
            yield Chunk(chrom_name:chrom_name, chrom_start:j, chrom_end: j + chunk_size)

proc buildKmerCountTable(full_sequence: string, kmer_size: int=21, spacedSeeds : bool = false, space : int = 50):CountTableRef[uint64] =
    var convertedKmers: pot_t = dna_to_kmers(full_sequence, kmer_size)
    if(spacedSeeds):
        convertedKmers = spacing_kmer(convertedKmers, space)
    result = newCountTable[uint64]()
    for k in convertedKmers.seeds:
        result.inc(uint64(k.kmer))

proc countByChunk(fai: Fai, chunk: Chunk, kmer_size: int=21, spacedSeeds: bool = false, space : int = 50):CountTableRef[uint64] =
    new (result)
    var sub_seq = fai.get(chunk.chrom_name, chunk.chrom_start, chunk.chrom_end)
    result = buildKmerCountTable(sub_seq, kmer_size, spacedSeeds, space )

proc showCounts*(input_fn: string, kmer_size: int=21, chunk_size: int=1000000, spacedSeeds: bool = false, space : int = 50) =
    ##Walk over reference sequences and count kmers.
    var fai: Fai
    if not fai.open(input_fn):
        quit "couldn't open fasta"

    for i in createdChunks(fai, chunk_size):
        let chunkCount = countByChunk(fai, i, kmer_size, spacedSeeds, space)
        echo(chunkCount)

proc updateSvIdx*(input_ref_fn: string, svKmers: svIdx, kmer_size: int=21, chunk_size: int=1000000, spacedSeeds: bool = false, space : int = 50) =
    ##Walk over reference sequences and count kmers.
    ##Update any existing svIdx entries with these counts.
    var fai: Fai
    if not fai.open(input_ref_fn):
        quit "couldn't open fasta"

    for i in createdChunks(fai, chunk_size):
        let chunkCount = countByChunk(fai, i, kmer_size, spacedSeeds, space)
        addRefCount(chunkCount, svKmers)
