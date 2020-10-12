import strutils
import tables
import hts
import ./mainLookup
import ./read

proc classify_bam(filename : string, idx : svIdx, k:int=25): CountTableRef =
    result = newCountTable[uint32, uint32]()

    var bamfile:Bam
    open(bamfile, filename, index=false)

    for record in bamfile:
        var read_classification = process_read(record.sequence, idx, k)
        var filtered_classification = filter_read_matches(read_classification)
        for key, val in filtered_classification.compatible_SVs:
            result.mgetOrPut(key, val)


proc classify_file(filename : string, idx : svIdx): CountTableRef =
    
    if endsWith(filename, ".bam"):
        return classify_bam
    else:
        quit("Error: only BAM input currently supported.")

proc main_classify(read_file : string, vcf_file : string, ref_file : string, k:int=25) =
    