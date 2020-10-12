import hts
import kmers
import tables
import svidx

# proc addByChunk*(fai: Fai, chrom_name: string, chrom_start: int, chrom_end: int) =

proc addRefCount*(refKmers: CountTableRef[uint64], svKmers: svIdx) =
    for k, v in pairs(refKmers): 
        if svKmers.hasKey(k):
            svKmers[k].refCount += uint32(v)

proc buildKmerCountTable*(full_sequence: string):CountTableRef[uint64] =
    let convertedKmers: pot_t = dna_to_kmers(full_sequence, 21)
    result = newCountTable[uint64]()
    for k in convertedKmers.seeds:
        result.inc(uint64(k.kmer))

proc countRefKmers*(input_fn: string) =
    ##Walk over reference sequences and count kmers
    var fai: Fai
    if not fai.open(input_fn):
        quit "couldn't open fasta"

    for i in 0..<fai.len:
        let chrom_name = fai[i]
        let chrom_len = fai.chrom_len(chrom_name)
        var full_sequence = fai.get(chrom_name)
        let count = buildKmerCountTable(full_sequence)
    
when isMainModule:
    import cligen
    dispatch(countRefKmers)
    