import math
import hts

type
  FlankSeq = object
    left, right: string

proc retrieve_flanking_sequences_from_fai(fastaIdx: Fai, chrom: string,
        start_pos: int, end_pos: int, flank: int): FlankSeq =
  ## this function lacks a return
  result.left = fastaIdx.get(chrom, max(0, start_pos - flank), start_pos)
  result.right = fastaIdx.get(chrom, end_pos, end_pos + flank)

proc compose(variant: Variant, right_flank: string,
    left_flank: string): string =

  var inner_seq: string
  var variant_type: string
  doAssert variant.info.get("SVTYPE", variant_type) == Status.OK
  if variant_type == "DEL":
    inner_seq = ""
  elif variant_type == "INS":
    inner_seq = variant.ALT[0]
  elif variant_type == "INV":
    raise newException(ValueError,
    "Error: Inversion processing not implemented.")
  var combined_sequence = right_flank & inner_seq & left_flank

  return combined_sequence


proc compose_variants*(variant_file: string, reference_file: string): seq[string] =
  ## function to compose variants from their sequence / FASTA flanking regions
  ## Returns a Sequence of strings representing the DNA sequence of the flanking
  ## regions and variant sequence.

  var composed_seqs = newSeq[string]()

  ## Open FASTA index
  var fai: Fai
  if not fai.open(reference_file):
    quit ("Failed to open FASTA file: " & reference_file)

  var variants: VCF
  doAssert(open(variants, variant_file))


  for v in variants:
    let sv_chrom = $v.CHROM
    ## Retrieve flanks, either from FAI or string cache
    let flanks = retrieve_flanking_sequences_from_fai(fai, sv_chrom, int(
        v.start), int(v.stop), 100)
    ## Generate a single sequence from variant seq + flank,
    ## taking into account the variant type.
    var variant_seq = compose(v, flanks.right, flanks.left)
    composed_seqs.add(variant_seq)

  return composed_seqs

when isMainModule:
  import cligen
  dispatch(compose_variants)
