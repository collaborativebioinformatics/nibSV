import hts
import ./kmers
import ./compose
import tables
import msgpack4nim, streams
import ./svidx

proc lookupKmer*(idx : svIdx, kmer : seed_t): seq[uint32] =
  return idx[kmer.kmer].svs

proc buildSVIdx*(reference_path:string, vcf_path: string, flank:int=100, k:int=25): svIdx =

 ## Open FASTA index
 result = newTable[uint64, tuple[refCount: uint32, altCount:uint32, svs:seq[uint32]]]()
 var fai: Fai
 doAssert fai.open(reference_path), "Failed to open FASTA file: " & reference_path

 var variants: VCF
 doAssert(open(variants, vcf_path))

 var sv_type: string
 var sv_idx = 0
 for v in variants:
   doAssert v.info.get("SVTYPE", svtype) == Status.OK
   let sv_chrom = $v.CHROM

   let flanks = fai.retrieve_flanking_sequences_from_fai($v.CHROM, v.start.int, v.stop.int, flank)
   for s in [flanks.left, flanks.right]:
     result.insert(s, k, sv_idx)

   sv_idx.inc
