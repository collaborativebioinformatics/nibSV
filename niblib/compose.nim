import hts





## Takes in a FAI object and returns a pair of strings, covering the flanks of chrom[start_pos - flank, start_pos]
## to chrom[end_pos, end_pos + flank]
proc retrieve_flanking_sequences_from_fai(fai : Fai, chrom : string, start_pos : int, end_pos : int, flank : int):
    var five_prime_seq = fai.get(chrom, start_pos - flank, start_pos)
    var three_prime_seq = fai.get(chrom, end_pos, end_pos + flank)

    return five_prime_seq, three_prime_seq


proc compose_variants(variant_file : string, reference_file : string):

    var variants:VCF
    doAssert(open(variants, variant_file))

    for v in variants:
        info = v.info
        ## Extract SV type / SV END / start position
        
        ## Retrieve flanks, either from FAI or string cache
        
        ## Generate a single sequence from variant seq + flank,
        ## taking into account the variant type.
