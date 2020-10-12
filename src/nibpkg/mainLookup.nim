import hts
import ./kmers
import ./compose
import tables
import msgpack4nim, streams

type svIdx* = TableRef[uint64, tuple[refCount: uint32, altCount:uint32, svs:seq[uint32]]]

proc dumpIdxToFile*(idx : svIdx, fn : string) =
    let strm = openFileStream(fn, fmWrite)
    strm.pack(idx)
    strm.close()

proc loadIdxFromFile*(fn : string) : svIdx =
    new(result) # = newTable[uint64, tuple[refCount:uint32, altCount:uint32, svs:seq[uint32]]]()
    let strm = openFileStream(fn, fmRead)
    strm.unpack(result)
    strm.close()


proc buildSVIdx*(reference_path:string, vcf_path: string, flank:int=100, k:int=25): svIdx =

 ## Open FASTA index
 result = newTable[uint64, tuple[refCount: uint32, altCount:uint32, svs:seq[uint32]]]()
 var fai: Fai
 doAssert fai.open(reference_path), "Failed to open FASTA file: " & reference_path

 var variants: VCF
 doAssert(open(variants, vcf_path))

 var sv_type: string
 var sv_idx = 0'u32
 for v in variants:
   doAssert v.info.get("SVTYPE", svtype) == Status.OK
   let sv_chrom = $v.CHROM

   let flanks = fai.retrieve_flanking_sequences_from_fai($v.CHROM, v.start.int, v.stop.int, flank)

   for s in [flanks.left, flanks.right]:
     var l = Dna(s).dna_to_kmers(k)
     for kmer in l.seeds:

       var kc = result.mgetOrPut(kmer.kmer, (0'u32, 0'u32, newSeq[uint32]()))
       kc.altCount.inc
       kc.svs.add(sv_idx)

   sv_idx.inc
