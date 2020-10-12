import hts
import kmers
import compose
import bitvector
import tables

type
 svIdx* = object
     idx : Table[uint64, BitVector]


proc buildSVIdx(referenceFasta, vcf : string) =
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
