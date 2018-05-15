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
             .fromFilePairs(params.reads + '*_{R1,R2}.fastq.gz', size: 2, flat: true)
             .println()

process trimming_pe {
                 publishDir params.outdir, mode: 'copy'

                 input:
                     set val(id), file(read1), file(read2) from reads_atropos_pe

                 output:
                     set val(id), file("${id}_R1.fastq.gz"), file("${id}_R2.fastq.gz") into trimmed_reads_pe

                 script:
                     """
                     mkdir trimmed
                     atropos -a TGGAATTCTCGGGTGCCAAGG -B AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT \
                         -T 4 -m 50 --max-n 0 -q 20,20 -pe1 $read1 -pe2 $read2 \
                         -o ${id}_R1.fastq.gz -p ${id}_R2.fastq.gz
                     """
             }
