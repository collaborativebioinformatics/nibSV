import compose
import refmers
import svidx
import strformat
import mainLookup
import classify
import reporter

proc main_runner*(variants_fn, refSeq_fn, prefix, reads_fn: string, kmerSize: int = 21, spacedSeeds: bool = false, space: int = 50, preIndex: bool = false, flank: int = 100) =
    ## Main program to type SVs
    var dumpedIdx = "{prefix}.sv_kmers.msgpck".fmt

    if(not preIndex):
        var svs = buildSVIdx(refSeq_fn, variants_fn, flank, kmerSize)
        updateSvIdx(refSeq_fn, svs, kmerSize, 1000000, spacedSeeds, space)
        dumpIdxToFile(svs, dumpedIdx)
    else:
        dumpedIdx = variants_fn

    let finalIdx = loadIdxFromFile(dumpedIdx)

    let classifyCount = classify_file(reads_fn, finalIdx, kmerSize, spacedSeeds, space)

    report(variants_fn, classifyCount, "SAMPLE")



when isMainModule:
    import cligen
    dispatch(main_runner)