/*
 * pipeline input parameters
 */
params.reads = "$baseDir/data"
params.multiqc = "$baseDir/Multi_QC"
params.outdir = "$baseDir/results_qc"

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

process trimming_pe {
                 publishDir params.outdir, mode: 'copy'

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
process fastqc {
                 input:
                     file reads from trimmed_reads_pe.collect()

                 output:
                     file "*_fastqc.{zip,html}" into fastqc_results

                 script:
                     """
                     fastqc -t 10 $reads
                     """
             }

process multiqc {
                 publishDir 'results', mode: 'copy'

                 input:
                     file 'fastqc/*' from fastqc_results.collect()

                 output:
                     file 'multiqc_report.html'

                 script:
                     """
                     multiqc .
                     """
             }
trimmed_reads_pe = Channel
    .fromFilePairs(params.outdir + '*_{R1,R2}.fastq.gz')

process assembly {
                  container 'ewels/multiqc'
                  publishDir 'results', mode: 'copy'

                  input:
                      set val(id), file(read1), file(read2) from trimmed_reads_pe
                  output:
                      set val(id), file("${id}_.fasta") into assembly_result
                  script:
                      """
                      echo $read1 $read2
                      """
}
