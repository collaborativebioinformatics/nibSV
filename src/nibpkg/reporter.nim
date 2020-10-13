import tables
import hts

proc report(vcf_name : string, sv_read_supports : CountTable[uint32], sample_name : string="SAMPLE") =
    ## Query SV supports for each SV in a VCF, appending the sample name to a field in the INFO fileds if
    ## the SV is present in the sample (i.e., SV support count > 1)
    var variants:VCF
    doAssert open(variants, vcf_name)

    var outputVCF:VCF
    doAssert open(outputVCF, "output.vcf", "w")
    ## Note: this will overwrite the existing entry if any exist in the VCF
    discard variants.header.add_info("SAMPLES_WITH_SV", ".", "String", "Sample name is present if SV is present in sample.")
    outputVCF.copy_header(variants.header)
    discard outputVCF.write_header()

    var sample_name = sample_name
    var sv_id :uint32= 0
    for v in variants:
        var sv_support_count = sv_read_supports.getOrDefault(sv_id)
        if sv_support_count > 0:
            doAssert v.info.set("SAMPLES_WITH_SV", sample_name) == Status.OK

        doAssert outputVCF.write_variant(v)

        sv_id.inc
    
    close(outputVCF)
    close(variants)
