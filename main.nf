#!/usr/bin/env nextflow
/*
 * pipeline input parameters
 */
params.reads = ""
params.outdir = ""

// requires --reads for qc
if (params.reads == '') {
    exit 1, '--reads is a required paramater for qc pipeline'
}

// requires --outdir for qc
if (params.outdir == '') {
    exit 1, '--outdir is a required paramater for qc pipeline'
}
println """\
         Hybrid Assembly- N F   P I P E L I N E
         ===================================
         reads        : ${params.reads}
         outdir       : ${params.outdir}
         """
         .stripIndent()
reads_atropos_pe = Channel
             .fromFilePairs(params.reads + '*_{R1,R2}.fastq.gz', size: 2, flat: true)

process trimming_pe {
                 publishDir path: "${params.outdir}/trimmed", mode: 'copy'

                 input:
                     set val(id), file(read1), file(read2) from reads_atropos_pe

                 output:
                     set val(id), file("${id}_R1.fastq"), file("${id}_R2.fastq") into trimmed_reads_pe

                 script:
                     """
                     mkdir trimmed
                     atropos -a TGGAATTCTCGGGTGCCAAGG -B AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT \
                         -T 10 -m 50 --max-n 0 -q 20,20 -pe1 $read1 -pe2 $read2 \
                         -o ${id}_R1.fastq -p ${id}_R2.fastq
                     """
             }
trimmed_reads_pe.into {reads_for_fastq; reads_for_assembly}
process fastqc {
                 publishDir path: "${params.outdir}/fastqc", mode: 'copy'

                 input:
                     file reads from reads_for_fastq.collect()

                 output:
                     file "*_fastqc.{zip,html}" into fastqc_results

                 script:
                     """
                     fastqc -t 10 $reads
                     """
             }

process multiqc {
                 publishDir path: "${params.outdir}/multiqc", mode: 'copy'

                 input:
                     file 'fastqc/*' from fastqc_results.collect()

                 output:
                     file 'multiqc_report.html'

                 script:
                     """
                     multiqc .
                     """
             }
process assembly {
                  publishDir path: "${params.outdir}/assembly", mode: 'copy'

                  input:
                      set val(id), file(read1), file(read2) from reads_for_assembly.collect()

                  output:
                      file'assembly.fasta' into assembly_result

                  script:
                      """
                      unicycler -1 $read1 -2 $read2 -o ${params.outdir}/assembly -t 10
                      """
}
