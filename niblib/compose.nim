import hts

proc retrieve_flanking_sequences_from_fai(fastaIdx: Fai, chrom: string,
        start_pos, end_pos, flank: int) =
    ## this function lacks a return
    var five_prime_seq = fastaIdx.get(chrom, start_pos - flank, start_pos)
    var three_prime_seq = fastaIdx.get(chrom, end_pos, end_pos + flank)


proc compose_variants(variant_file: string, reference_file: string) =
    ## function to compose
    var variants: VCF
    doAssert(open(variants, variant_file))

    var sv_type = new_string_of_cap(20)
    var sv_len = int32
    var sv_end = int32
    for v in variants:

        infoF = v.info
        do infoF.get("SVEND")
        ## Extract SV type / SV END / start position


        ## Extract SV type / SV END / start position

        ## Retrieve flanks, either from FAI or string cache

        ## Generate a single sequence from variant seq + flank,
        ## taking into account the variant type.


when isMainModule:
    import cligen
    dispatch(compose_variants)
