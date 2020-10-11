import hts



proc retrieve_flanking_sequences_from_fai(fastaIdx: Fai, chrom: string,
        start_pos, end_pos, flank: int): tuple =
    ## this function lacks a return
    var five_prime_seq = fastaIdx.get(chrom, start_pos - flank, start_pos)
    var three_prime_seq = fastaIdx.get(chrom, end_pos, end_pos + flank)

    var flanks : tuple[five_prime : string, three_prime : string]

    return flanks



proc compose_variants(variant_file: string, reference_file: string) =
    ## function to compose
    
    ## Open FASTA index
    var fai:Fai
    if not fai.open(reference_file):
        quit ("Failed to open FASTA file: " & reference_file)
    
    var variants: VCF
    doAssert(open(variants, variant_file))

    for v in variants:
        var info_fields = v.info
        ## Extract SV type / SV END / start position

        ## Retrieve flanks, either from FAI or string cache

        ## Generate a single sequence from variant seq + flank,
        ## taking into account the variant type.


when isMainModule:
    import cligen
    dispatch(compose_variants)
