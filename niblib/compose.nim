import hts

type
  FlankSeq = object
    left, right: string

proc retrieve_flanking_sequences_from_fai(fastaIdx: Fai, chrom: string,
        start_pos, end_pos, flank: int): FlankSeq =
  ## this function lacks a return
  result.left = fastaIdx.get(chrom, start_pos - flank, start_pos)
  result.right = fastaIdx.get(chrom, end_pos, end_pos + flank)



proc compose_variants(variant_file: string, reference_file: string) =
  ## function to compose

  ## Open FASTA index
  var fai: Fai
  if not fai.open(reference_file):
    quit ("Failed to open FASTA file: " & reference_file)

  var variants: VCF
  doAssert(open(variants, variant_file))

  var sv_end = new_seq[int32](2)
  var sv_start: int32
  var sv_type: string
  for v in variants:
    var info_fields = v.info
    ## Extract SV type / SV END / start position
    doAssert info_fields.get("SVTYPE", sv_type) == Status.OK
    doAssert info_fields.get("END", sv_end) == Status.OK
    let sv_start = v.POS
    ## Retrieve flanks, either from FAI or string cache
    let flanks = retrieve_flanking_sequences_from_fai(fai, v.CHROM, v.POS, sv_end)
    ## Generate a single sequence from variant seq + flank,
    ## taking into account the variant type.


when isMainModule:
  import cligen
  dispatch(compose_variants)
