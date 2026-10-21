process COLLECT_VERSIONS {
    tag 'software provenance'
    label 'process_low'

    publishDir "${params.outdir}/pipeline_info", mode: 'copy', overwrite: false

    input:
    path version_files, stageAs: 'versions/versions??.yml'

    output:
    path 'software_versions.yml', emit: versions

    script:
    """
    cat versions/*.yml > software_versions.yml
    """

    stub:
    """
    cat versions/*.yml > software_versions.yml
    """
}
