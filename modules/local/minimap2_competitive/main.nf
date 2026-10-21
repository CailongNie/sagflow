process MINIMAP2_COMPETITIVE {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::minimap2=2.28'
    container 'quay.io/biocontainers/minimap2:2.28--he4a0461_3'

    input:
    tuple val(meta), path(reads)
    path reference

    output:
    tuple val(meta), path("${meta.id}.sam"), emit: sam
    path "${meta.id}.minimap2.log", emit: logs
    path 'versions.yml', emit: versions

    script:
    """
    minimap2 \
        -ax sr \
        --secondary=no \
        -t ${task.cpus} \
        ${reference} \
        ${reads[0]} ${reads[1]} \
        > ${meta.id}.sam \
        2> ${meta.id}.minimap2.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        minimap2: \$(minimap2 --version)
    END_VERSIONS
    """

    stub:
    """
    touch ${meta.id}.sam ${meta.id}.minimap2.log
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        minimap2: stub
    END_VERSIONS
    """
}
