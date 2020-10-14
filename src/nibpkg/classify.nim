import strutils
import tables
import hts
import ./mainLookup
import ./read
import ./svidx

proc classify_bam(filename: string, idx: SvIndex, k: int = 25, spacedSeeds: bool = false, space: int = 50, threads: int = 2): CountTableRef[uint32] =
    new(result)

    var bamfile: Bam
    open(bamfile, filename, index = false, threads=threads)
    var sequence: string

    for record in bamfile:
        # NOTE: we may also want to filter record.flag.dup in the future, but
        # that will make results differ between bam and fastq
        if record.flag.secondary or record.flag.supplementary: continue
        record.sequence(sequence)

        var read_classification = process_read(sequence, idx, k, spacedSeeds, space)
        filter_read_matches(read_classification, winner_takes_all=false)
        for key, val in read_classification.compatible_SVs:
            result.inc(key)


proc classify_file*(filename: string, idx: SvIndex, k: int = 25, spacedSeeds: bool = false, space: int = 50): CountTableRef[uint32] =
    if endsWith(filename, ".bam"):
        return classify_bam(filename, idx, k, spacedSeeds, space)
    else:
        quit("Error: only BAM input currently supported.")

proc main_classify*(read_file: string, vcf_file: string, ref_file: string, k: int = 25, flank: int = 100) =
    var idx: SvIndex = buildSvIndex(ref_file, vcf_file, flank, k)
    var svCounts: CountTableRef[uint32] = classify_file(read_file, idx, k)
