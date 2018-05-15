/*
 * pipeline input parameters
 */
params.reads = "/data"
params.multiqc = "/Multi_QC"
params.outdir = "/results_qc"

// requires --reads for qc
if (params.reads == '') {
    exit 1, '--reads is a required paramater for qc pipeline'
}

// requires --multiqc for qc
if (params.multiqc == '') {
    exit 1, '--multiqc is a required paramater for qc pipeline'
}

// requires --outdir for qc
if (params.outdir == '') {
    exit 1, '--outdir is a required paramater for qc pipeline'
}
println """\
         R N A S E Q - N F   P I P E L I N E
         ===================================
         reads        : ${params.reads}
         multiqc      : ${params.multiqc}
         outdir       : ${params.outdir}
         """
         .stripIndent()

         reads_atropos_pe = Channel
             .fromFilePairs(params.input + '*_{1,2,3}.fastq.gz', size: 2, flat: true)
             .println()
             
