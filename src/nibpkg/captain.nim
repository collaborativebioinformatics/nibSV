# vim: sw=4 ts=4 sts=4 tw=0 et:
import compose
import refmers
import svidx
import strformat
import mainLookup
import classify
import reporter

proc main_runner*(variants_fn, refSeq_fn, reads_fn, prefix: string, index_fn = "", kmerSize: int = 21, spacedSeeds : bool = false, space: int = 50, flank: int = 100) =
    ## Main program to type SVs
    var actual_index_fn = "{prefix}.sv_kmers.msgpck".fmt
    var idx: svIdx

    # Make preindex an option to take the msgpack, precomputed.
    # In that case, skip this block.
    if "" == index_fn:
        echo "building an SV kmer DB."
        idx = buildSVIdx(refSeq_fn, variants_fn, flank, kmerSize)
        echo "updating reference kmer counts."
        updateSvIdx(refSeq_fn, idx, kmerSize, 1000000, spacedSeeds, space)
        echo "dumpIdxToFile:'", actual_index_fn, "'"
        dumpIdxToFile(idx, actual_index_fn)
    else:
        actual_index_fn = index_fn
        echo "loadIdxFromFile:'", actual_index_fn, "'"
        idx = loadIdxFromFile(actual_index_fn)

    echo "final idx contains: {idx.len} forward and reverse SV kmers.".fmt

    let classifyCount = classify_file(reads_fn, idx, kmerSize, spacedSeeds, space)

    echo "reporting variants."

    report(variants_fn, classifyCount, prefix)

    echo "nibbleSV finished without problems, goodbye!"




when isMainModule:
  import cligen
  dispatch(main_runner)
