process FASTQC {
    tag "${meta.id}"
    label 'process_low'

    conda 'bioconda::fastqc=0.12.1'
    container 'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0'

    publishDir "${params.outdir}/01_qc/fastqc", mode: 'copy', overwrite: false,
        saveAs: { filename -> filename == 'versions.yml' ? null : filename }

    input:
    tuple val(meta), path(reads)

    output:
    path '*_fastqc.zip', emit: reports
    path 'versions.yml', emit: versions

    script:
    def r1 = "${meta.id}_R1${reads[0].name.endsWith('.gz') ? '.fastq.gz' : '.fastq'}"
    def r2 = "${meta.id}_R2${reads[1].name.endsWith('.gz') ? '.fastq.gz' : '.fastq'}"
    """
    ln -s ${reads[0]} ${r1}
    ln -s ${reads[1]} ${r2}
    fastqc --threads ${task.cpus} --quiet ${r1} ${r2}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastqc: \$(fastqc --version | sed 's/FastQC v//')
    END_VERSIONS
    """

    stub:
    """
    touch ${meta.id}_R1_fastqc.zip ${meta.id}_R2_fastqc.zip
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastqc: stub
    END_VERSIONS
    """
}
