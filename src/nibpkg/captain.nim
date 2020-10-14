# vim: sw=4 ts=4 sts=4 tw=0 et:
import compose
import refmers
import svidx
import strformat
import mainLookup
import classify
import reporter
from os import nil
from tables import len

proc main_runner*(variants_fn, refSeq_fn, reads_fn: string, prefix = "test", kmer_size: int = 25, spaced_seeds : bool = false, space: int = 50, flank: int = 100, maxRefKmerCount : uint32 = 0 ) =
    ## Generate a SV kmer database, and genotype new samples.
    ## If a file called "{prefix}.sv_kmers.msgpack" exists, use it.
    ## Otherwise, generate it.
    var index_fn = "{prefix}.sv_kmers.msgpck".fmt
    var idx: svIdx

    if not os.existsFile(index_fn):
        echo "building an SV kmer DB."
        idx = buildSVIdx(refSeq_fn, variants_fn, flank, kmer_size)
        let sp = if spaced_seeds:
          space
        else:
          0
        echo "updating reference kmer counts."
        updateSvIdx(refSeq_fn, idx, kmer_size, 1000000, sp)
        echo "dumpIdxToFile:'", index_fn, "'"
        dumpIdxToFile(idx, index_fn)
    else:
        echo "loadIdxFromFile:'", index_fn, "'"
        idx = loadIdxFromFile(index_fn)

    echo "final idx contains: {idx.len} forward and reverse SV kmers.".fmt

    filterRefKmers(idx, maxRefKmerCount)

    let classifyCount = classify_file(reads_fn, idx, kmer_size, spaced_seeds, space)

    echo "reporting variants."

    report(variants_fn, classifyCount, idx, prefix)

    echo "nibbleSV finished without problems, goodbye!"


when isMainModule:
  import cligen
  dispatch(main_runner)
