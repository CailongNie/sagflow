process GUNC {
    tag "${meta.id}"
    label 'process_high'

    conda 'bioconda::gunc=1.0.6'

    publishDir "${params.outdir}/04_assembly_qc/gunc", mode: 'copy', overwrite: false,
        saveAs: { filename -> filename == 'versions.yml' ? null : filename }

    input:
    tuple val(meta), path(assembly)

    output:
    path "${meta.id}.gunc", emit: reports
    path 'versions.yml', emit: versions

    script:
    """
    mkdir ${meta.id}.input
    cp ${assembly} ${meta.id}.input/${meta.id}.fa
    gunc run \
        --input_dir ${meta.id}.input \
        --file_suffix .fa \
        --db_file ${params.gunc_db} \
        --out_dir ${meta.id}.gunc \
        --threads ${task.cpus}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gunc: \$(gunc --version 2>&1 | head -n 1)
    END_VERSIONS
    """

    stub:
    """
    mkdir ${meta.id}.gunc
    printf 'genome\tpass.GUNC\n${meta.id}\tn.a.\n' > ${meta.id}.gunc/GUNC.progenomes_2.1.maxCSS_level.tsv
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gunc: stub
    END_VERSIONS
    """
}
