import hts
import kmers
import tables
import svidx

type
    Chunk* = object
        chrom_name: string
        chrom_start: int
        chrom_end: int
    
proc addRefCount*(refKmers: CountTableRef[uint64], svKmers: svIdx) =
    for k, v in pairs(refKmers): 
        if svKmers.hasKey(k):
            svKmers[k].refCount += uint32(v)

proc createChunk*(fai: Fai, chunk_size: int): seq[Chunk] =
    var chunkSeq = newSeq[Chunk]()
    for i in 0..<fai.len:
        let chrom_name = fai[i]
        let chrom_len = fai.chrom_len(chrom_name)
        for j in countup(0, chrom_len, chunk_size):
            var chunk: Chunk
            chunk.chrom_name = chrom_name
            chunk.chrom_start = j
            chunk.chrom_end = j + chunk_size
            chunkSeq.add(chunk)
    return chunkSeq

proc buildKmerCountTable*(full_sequence: string, kmer_size: int=21):CountTableRef[uint64] =
    let convertedKmers: pot_t = dna_to_kmers(full_sequence, kmer_size)
    result = newCountTable[uint64]()
    for k in convertedKmers.seeds:
        result.inc(uint64(k.kmer))

proc countByChunk*(fai: Fai, chunk: Chunk, kmer_size: int=21):CountTableRef[uint64] =
    new (result)
    var sub_seq = fai.get(chunk.chrom_name, chunk.chrom_start, chunk.chrom_end)
    result = buildKmerCountTable(sub_seq, kmer_size)

proc countRefKmers*(input_fn: string, kmer_size: int=21, chunk_size: int=1000000) =
    ##Walk over reference sequences and count kmers
    var fai: Fai
    if not fai.open(input_fn):
        quit "couldn't open fasta"
    
    let chunks = createChunk(fai, chunk_size)
    for i in chunks:
        let chunkCount = countByChunk(fai, i, kmer_size)
        echo(chunkCount)

proc mainRefCounter*(input_fn: string, svKmers: svIdx, kmer_size: int=21, chunk_size: int=1000000) =
    ##Walk over reference sequences and count kmers
    var fai: Fai
    if not fai.open(input_fn):
        quit "couldn't open fasta"
    
    let chunks = createChunk(fai, chunk_size)
    for i in chunks:
        let chunkCount = countByChunk(fai, i, kmer_size)
        addRefCount(chunkCount, svKmers)

when isMainModule:
    import cligen
    dispatch(countRefKmers)
    