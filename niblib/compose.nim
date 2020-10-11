import hts



type
    Flanks = tuple[five_prime: string, three_prime : string]



## Takes in a FAI object and returns a pair of strings, covering the flanks of chrom[start_pos - flank, start_pos]
## to chrom[end_pos, end_pos + flank]
proc retrieve_flanking_sequences_from_fai(fai: Fai, chrom: string,
        start_pos: int, end_pos: int, flank: int): Flanks =
    var five_prime_seq = fai.get(chrom, start_pos - flank, start_pos)
    var three_prime_seq = fai.get(chrom, end_pos, end_pos + flank)

    var flanks = Flanks(five_prime: five_prime_seq,
            three_prime: three_prime_seq)
    return flanks



proc compose_variants(variant_file: string, reference_file: string): @string =
    var variants: VCF
    doAssert(open(variants, variant_file))

    var sv_type = new_string_of_cap(20)
    var sv_len = int32
    var sv_end = int32
    for v in variants:
        info = v.info
        do info.get("SVEND")
        ## Extract SV type / SV END / start position


        ## Retrieve flanks, either from FAI or string cache

        ## Generate a single sequence from variant seq + flank,
        ## taking into account the variant type.
