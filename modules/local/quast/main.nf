process QUAST {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::quast=5.2.0'
    container 'quay.io/biocontainers/quast:5.2.0--py39pl5321h4e691d4_3'

    publishDir "${params.outdir}/04_assembly_qc/quast", mode: 'copy', overwrite: false,
        saveAs: { filename -> filename == 'versions.yml' ? null : filename }

    input:
    tuple val(meta), path(assembly)

    output:
    path "${meta.id}.quast", emit: reports
    path 'versions.yml', emit: versions

    script:
    """
    quast.py \
        --threads ${task.cpus} \
        --output-dir ${meta.id}.quast \
        ${assembly}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quast: \$(quast.py --version | sed 's/QUAST v//')
    END_VERSIONS
    """

    stub:
    """
    mkdir ${meta.id}.quast
    printf 'Assembly\t# contigs\tTotal length\n${meta.id}\t1\t32\n' > ${meta.id}.quast/report.tsv
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quast: stub
    END_VERSIONS
    """
}
