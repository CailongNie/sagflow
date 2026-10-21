process CHECKM2 {
    tag "${meta.id}"
    label 'process_high'

    conda 'bioconda::checkm2=1.1.0'

    publishDir "${params.outdir}/04_assembly_qc/checkm2", mode: 'copy', overwrite: false,
        saveAs: { filename -> filename == 'versions.yml' ? null : filename }

    input:
    tuple val(meta), path(assembly)

    output:
    path "${meta.id}.checkm2", emit: reports
    path 'versions.yml', emit: versions

    script:
    """
    checkm2 predict \
        --threads ${task.cpus} \
        --input ${assembly} \
        --output-directory ${meta.id}.checkm2 \
        --database_path ${params.checkm2_db}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        checkm2: \$(checkm2 --version 2>&1 | head -n 1)
    END_VERSIONS
    """

    stub:
    """
    mkdir ${meta.id}.checkm2
    printf 'Name\tCompleteness\tContamination\n${meta.id}\t0\t0\n' > ${meta.id}.checkm2/quality_report.tsv
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        checkm2: stub
    END_VERSIONS
    """
}
