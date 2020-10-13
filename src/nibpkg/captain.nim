# vim: sw=4 ts=4 sts=4 tw=0 et:
import compose
import refmers
import svidx
import strformat
import mainLookup
import classify
import reporter

proc main_runner*(variants_fn, refSeq_fn, prefix, reads_fn: string, kmerSize: int = 21, spacedSeeds : bool = false, space: int = 50, preIndex : bool = false, flank: int = 100) =
    ## Main program to type SVs
    var dumpedIdx = "{prefix}.sv_kmers.msgpck".fmt

    # Make preindex an option to take the msgpack, precomputed.
    # In that case, skip this block.
    if(not preIndex):
        echo "building an SV kmer DB."
        var svs = buildSVIdx(refSeq_fn, variants_fn, flank, kmerSize)
        echo "updating reference kmer counts."
        updateSvIdx(refSeq_fn, svs, kmerSize, 1000000, spacedSeeds, space)
        dumpIdxToFile(svs, dumpedIdx)
    else:
        dumpedIdx = variants_fn

    let finalIdx = loadIdxFromFile(dumpedIdx)
    echo "final idx contains: {finalIdx.len} forward and reverse SV kmers.".fmt

    let classifyCount = classify_file(reads_fn, finalIdx, kmerSize, spacedSeeds, space)

    echo "reporting variants."

    report(variants_fn, classifyCount, prefix)

    echo "nibbleSV finished without problems, goodbye!"




when isMainModule:
  import cligen
  dispatch(main_runner)
