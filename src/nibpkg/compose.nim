import hts
import kmers

type
  FlankSeq* = object
    left*, right*: string

type
  PositionedSequence* = object
    sequences*: tuple[ref_seq : string, alt_seq : string]
    kmers : tuple[ref_kmers : seq[seed_t], alt_kmers : seq[seed_t]]
    chrom: string
    position: int32

proc retrieve_flanking_sequences_from_fai*(fastaIdx: Fai, chrom: string,
        start_pos: int, end_pos: int, flank: int): FlankSeq =
  ## this function lacks a return
  result.left = fastaIdx.get(chrom, max(0, start_pos - flank), start_pos)
  result.right = fastaIdx.get(chrom, end_pos, end_pos + flank)

proc kmerize(s : string, k:int=25): seq[seed_t] =
  return Dna(s).dna_to_kmers(k).seeds

proc compose*(variant: Variant, right_flank: string,
    left_flank: string, k:int=25): PositionedSequence =
  ## Takes in a VCF variant, the 5' and 3' reference flanking sequences,
  ## and a kmer size. Produces a PositionedSequence, which holds the ref/alt
  ## sequences as well as the kmers of those sequences (in addition to
  ## minimal position information)
  var variant_type: string
  doAssert variant.info.get("SVTYPE", variant_type) == Status.OK
  if variant_type == "DEL":
    var deleted_bases : string = $variant.REF ## Chop the reference base prefix in the REF allele.
    result.sequences.ref_seq = left_flank & deleted_bases & right_flank
    result.sequences.alt_seq = left_flank & right_flank
    result.kmers.ref_kmers = kmerize(result.sequences.ref_seq, k)
    result.kmers.alt_kmers = kmerize(result.sequences.alt_seq, k)
  elif variant_type == "INS":
    var inserted_seq : string = variant.ALT[0][1 .. ^0] ## Chop the reference base prefix in the ALT allele.
    result.sequences.ref_seq = left_flank & right_flank
    result.sequences.alt_seq = left_flank & inserted_seq & right_flank
    result.kmers.ref_kmers = kmerize(result.sequences.ref_seq, k)
    result.kmers.alt_kmers = kmerize(result.sequences.alt_seq, k)
  elif variant_type == "INV":
    return
    #raise newException(ValueError,
    #"Error: Inversion processing not implemented.")

  result.position = int32(variant.start) - int32(len(right_flank))
  result.chrom = $variant.CHROM


proc compose_variants*(variant_file: string, reference_file: string): seq[
    PositionedSequence] =
  ## function to compose variants from their sequence / FASTA flanking regions
  ## Returns a Sequence of strings representing the DNA sequence of the flanking
  ## regions and variant sequence.

  var composed_seqs = newSeq[PositionedSequence]()

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
