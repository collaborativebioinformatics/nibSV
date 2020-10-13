import tables
import hts
import svidx


## N.B.: Add a function that takes a BAM path and returns the sample name
## 
## TODO: Add a function that handles genotypes using the svIdx's ref/alt count fields.
proc report*(vcf_name : string, sv_read_supports : CountTableRef[uint32], sv_idex : svIdx, sample_name : string="SAMPLE") =
    ## Query SV supports for each SV in a VCF, appending the sample name to a field in the INFO fileds if
    ## the SV is present in the sample (i.e., SV support count > 1)
    var variants:VCF
    doAssert open(variants, vcf_name)

    var outputVCF:VCF
    doAssert open(outputVCF, "output.vcf", "w")
    ## Note: this will overwrite the existing entry if any exist in the VCF
    discard variants.header.add_info("NIB_SAMPLES_WITH_SV", ".", "String", "Sample name is present if SV is present in sample.")
    discard variants.header.add_info("NIB_READ_SUPPORTS", ".", "Integer", "The number of reads supporting a given SV.")
    #discard variants.header.add_info("NIB_ALT_SUPPORTS", ".", "Integer", "The number of reads supporting a given SV alt.")
    outputVCF.copy_header(variants.header)
    discard outputVCF.write_header()

    var sample_name = sample_name
    var sv_id :uint32= 0
    for v in variants:
        var sv_support_count = sv_read_supports.getOrDefault(sv_id, -1)
        if sv_support_count > 0:
            doAssert v.info.set("NIB_SAMPLES_WITH_SV", sample_name) == Status.OK
            doAssert v.info.set("NIB_READ_SUPPORTS", sv_support_count) == Status.OK

        doAssert outputVCF.write_variant(v)

        sv_id.inc
    
    close(outputVCF)
    close(variants)
