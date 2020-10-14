import compose
import refmers
import svidx
import strformat
import mainLookup
import classify
import reporter

proc main_runner*(variants_fn, refSeq_fn, prefix, reads_fn: string, kmerSize: int = 21, spacedSeeds : bool = false, space: int = 50, preIndex : bool = false, flank: int = 100, maxRefKmerCount: uint32 = 2 ) =
    ## Main program to type SVs
    var dumpedIdx = "{prefix}.sv_kmers.msgpck".fmt

    if(not preIndex):
        echo "building an SV kmer DB."
        var svs = buildSVIdx(refSeq_fn, variants_fn, flank, kmerSize)
        echo "updating reference kmer counts."

        updateSvIdx(refSeq_fn, svs, kmerSize, 1000000, space)
        dumpIdxToFile(svs, dumpedIdx)
    else:
        dumpedIdx = variants_fn

    echo "loading final index."
    let finalIdx  = loadIdxFromFile(dumpedIdx)
    #echo "idx contains: {finalIdx.keys.len} forward and reverse SV kmers before filter.".fmt
    filterRefKmers(finalIdx, maxRefKmerCount)
    #echo "filtered idx contains: {finalIdx.keys.len} forward and reverse SV kmers.".fmt

    let classifyCount = classify_file(reads_fn, finalIdx, kmerSize, spacedSeeds, space)

    echo "reporting variants."

    report(variants_fn, classifyCount, finalIdx, prefix)

    echo "nibbleSV finished without problems, goodbye!"




when isMainModule:
  import cligen
  dispatch(main_runner)
