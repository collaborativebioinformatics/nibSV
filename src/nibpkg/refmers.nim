import hts
import kmers
import tables

proc countRefKmers*(input_fn: string):CountTable[Bin] =
    ##Walk over reference sequences and count kmers
    var fai: Fai
    if not fai.open(input_fn):
        quit "couldn't open fasta"

    for i in 0..<fai.len:
        let chrom_name = fai[i]
        let chrom_len = fai.chrom_len(chrom_name)
        var full_sequence = fai.get(chrom_name)
        let convertedKmers: pot_t = dna_to_kmers(full_sequence, 21)

        var kmerCountTable = initCountTable[Bin]()
        for k in convertedKmers.seeds:
            kmerCountTable.inc(k.kmer)
        return kmerCountTable

        # put kmer in count table, then return the tables
        # 
when isMainModule:
    import cligen
    dispatch(countRefKmers)
    