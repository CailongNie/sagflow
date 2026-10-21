process GTDBTK {
    tag "${meta.id}"
    label 'process_high'

    conda 'bioconda::gtdbtk=2.4.0'

    publishDir "${params.outdir}/05_taxonomy/gtdbtk", mode: 'copy', overwrite: false,
        saveAs: { filename -> filename == 'versions.yml' ? null : filename }

    input:
    tuple val(meta), path(assembly)

    output:
    path "${meta.id}.gtdbtk", emit: reports
    path 'versions.yml', emit: versions

    script:
    """
    mkdir ${meta.id}.input
    cp ${assembly} ${meta.id}.input/${meta.id}.fa
    export GTDBTK_DATA_PATH=${params.gtdbtk_data_path}
    gtdbtk classify_wf \
        --genome_dir ${meta.id}.input \
        --out_dir ${meta.id}.gtdbtk \
        --extension fa \
        --cpus ${task.cpus}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gtdbtk: \$(gtdbtk --version | awk '{print \$2}')
        database: \$(basename ${params.gtdbtk_data_path})
    END_VERSIONS
    """

    stub:
    """
    mkdir ${meta.id}.gtdbtk
    printf 'user_genome\tclassification\n${meta.id}\tunclassified\n' > ${meta.id}.gtdbtk/gtdbtk.bac120.summary.tsv
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gtdbtk: stub
        database: stub
    END_VERSIONS
    """
}
