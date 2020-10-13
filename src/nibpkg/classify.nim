import strutils
import tables
import hts
import ./mainLookup
import ./read
import ./svidx

proc classify_bam(filename : string, idx : svIdx, k:int=25): CountTableRef[uint32] =
    new(result)

    var bamfile:Bam
    open(bamfile, filename, index=false)
    var sequence: string

    for record in bamfile:
        record.sequence(sequence)

        var read_classification = process_read(sequence, idx, k)
        filter_read_matches(read_classification)
        for key, val in read_classification.compatible_SVs:
            result.inc(key, val)


proc classify_file(filename : string, idx : svIdx, k:int=25): CountTableRef[uint32] =

    if endsWith(filename, ".bam"):
        return classify_bam(filename, idx, k)
    else:
        quit("Error: only BAM input currently supported.")

proc main_classify*(read_file : string, vcf_file : string, ref_file : string, k:int=25, flank:int=100) =

    var idx : svIdx = buildSVIdx(ref_file, vcf_file, flank, k)
    var svCounts: CountTableRef[uint32] = classify_file(read_file, idx, k)
