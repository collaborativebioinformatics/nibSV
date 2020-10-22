import hts
import ./kmers
import ./compose
import tables
import msgpack4nim, streams
import ./svidx




#TODO can we move all this code into svidx, does that make sense?

proc buildSvIndex*(reference_path: string, vcf_path: string, flank: int = 100, k: int = 25): SvIndex =
  ## Open FASTA index
  var fai: Fai
  doAssert fai.open(reference_path), "Failed to open FASTA file: " & reference_path

  var variants: VCF
  doAssert(open(variants, vcf_path))

  result.kmerSize = k.uint8

  var sv_idx = 0
  echo "flank:", flank
  for v in variants:
    let sv_chrom = $v.CHROM

    let flanks = fai.retrieve_flanking_sequences_from_fai($v.CHROM, v.start.int, v.stop.int, flank)
    var p = v.compose(flanks.left, flanks.right, k)

    result.insert(p.sequences.alt_seq, k, sv_idx)
    # The insert function allows us to add to the ref count, but refmer also
    #  adds the same counts, so for now i'm commenting this out to minimize the
    #  lines of code we are debugging. --Zev
    # result.insert(p.sequences.ref_seq, k, -1)

    sv_idx.inc
