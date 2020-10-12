import hts

type
  FlankSeq* = object
    left*, right*: string

proc retrieve_flanking_sequences_from_fai*(fastaIdx: Fai, chrom: string,
        start_pos : int, end_pos : int, flank: int): FlankSeq =
  ## this function lacks a return
  result.left = fastaIdx.get(chrom, max(0, start_pos - flank), start_pos)
  result.right = fastaIdx.get(chrom, end_pos, end_pos + flank)



proc compose_variants*(variant_file: string, reference_file: string) =
  ## function to compose

  ## Open FASTA index
  var fai: Fai
  if not fai.open(reference_file):
    quit ("Failed to open FASTA file: " & reference_file)

  var variants: VCF
  doAssert(open(variants, variant_file))

  var sv_type: string
  for v in variants:
    var info_fields = v.info
    ## Extract SV type / SV END / start position
    doAssert info_fields.get("SVTYPE", svtype) == Status.OK
    let sv_chrom = $v.CHROM
    ## Retrieve flanks, either from FAI or string cache
    let flanks = retrieve_flanking_sequences_from_fai(fai, sv_chrom, int(v.start), int(v.stop), 100)
    ## Generate a single sequence from variant seq + flank,
    ## taking into account the variant type.


when isMainModule:
  import cligen
  dispatch(compose_variants)
