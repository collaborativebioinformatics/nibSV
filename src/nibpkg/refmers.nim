import hts

proc countRefKmers*(input_fn: string) =
    ##Walk over reference sequences and count kmers
    var fai: Fai
    if not fai.open(input_fn):
        quit "couldn't open fasta"

    for i in 0..<fai.len:
        let chrom_name = fai[i]
        let chrom_len = fai.chrom_len(chrom_name)
        var full_sequence = fai.get(chrom_name)

when isMainModule:
    import cligen
    dispatch(coutRefKmers)
    