process FASTP {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::fastp=0.23.4'
    container 'quay.io/biocontainers/fastp:0.23.4--h5f740d0_0'

    publishDir "${params.outdir}/01_qc/fastp", mode: 'copy', overwrite: false,
        saveAs: { filename -> filename == 'versions.yml' ? null : filename }

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${meta.id}_R{1,2}.fastq.gz"), emit: reads
    path "${meta.id}.fastp.{json,html}", emit: reports
    path 'versions.yml', emit: versions

    script:
    """
    fastp \
        --in1 ${reads[0]} \
        --in2 ${reads[1]} \
        --out1 ${meta.id}_R1.fastq.gz \
        --out2 ${meta.id}_R2.fastq.gz \
        --json ${meta.id}.fastp.json \
        --html ${meta.id}.fastp.html \
        --thread ${task.cpus} \
        --detect_adapter_for_pe

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastp: \$(fastp --version 2>&1 | sed -n 's/.*fastp //p')
    END_VERSIONS
    """

    stub:
    """
    touch ${meta.id}_R1.fastq.gz ${meta.id}_R2.fastq.gz
    echo '{}' > ${meta.id}.fastp.json
    echo '<html><body>stub</body></html>' > ${meta.id}.fastp.html
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastp: stub
    END_VERSIONS
    """
}
