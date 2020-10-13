# vim: sw=4 ts=4 sts=4 tw=0 et:
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
            yield Chunk(chrom_name: chrom_name, chrom_start: j, chrom_end: j + chunk_size)

proc addRefCount(svKmers: svIdx, full_sequence: string, kmer_size: int = 21, spacedSeeds: bool = false, space: int = 50) =
    var convertedKmers: pot_t = dna_to_kmers(full_sequence, kmer_size)
    if(spacedSeeds):
        convertedKmers = spacing_kmer(convertedKmers, space)

    for km in convertedKmers.seeds:
      if km.kmer in svKmers:
        svKmers[km.kmer].refCount.inc

proc updateChunk(svKmers: svIdx, fai: Fai, chunk: Chunk, kmer_size: int = 21, spacedSeeds: bool = false, space: int = 50) =
    var sub_seq = fai.get(chunk.chrom_name, chunk.chrom_start, chunk.chrom_end)
    addRefCount(svKmers, sub_seq, kmer_size, spacedSeeds, space)

proc updateSvIdx*(input_ref_fn: string, svKmers: svIdx, kmer_size: int = 21, chunk_size: int = 1000000, spacedSeeds: bool = false, space: int = 50) =
    ##Walk over reference sequences and count kmers.
    ##Update any existing svIdx entries with these counts.
    var fai: Fai
    if not fai.open(input_ref_fn):
        quit "couldn't open fasta"

    for i in createdChunks(fai, chunk_size):
        echo "i:", i
        updateChunk(svKmers, fai, i, kmer_size, spacedSeeds, space)

when isMainModule:
  import hts
  var fai:Fai
  import times

  if not fai.open("/data/human/g1k_v37_decoy.fa"):
    quit "bad"

  var s = fai.get("22")
  var svkmers:svIdx
  new(svkmers)
  echo "starting"
  for i in countup(0, 100_000_000, 10):
    svkmers[i.uint64] = (0'u32, 0'u32, newSeq[uint32]())

  var t0 = cpuTime()
  svKmers.addRefCount(s)
  echo "time:", cpuTime() - t0
