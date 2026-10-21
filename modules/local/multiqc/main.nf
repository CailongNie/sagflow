process MULTIQC {
    tag 'aggregate report'
    label 'process_low'

    conda 'bioconda::multiqc=1.25.1'
    container 'quay.io/biocontainers/multiqc:1.25.1--pyhdfd78af_0'

    publishDir "${params.outdir}/06_report", mode: 'copy', overwrite: false,
        saveAs: { filename -> filename == 'versions.yml' ? null : filename }

    input:
    path reports

    output:
    path 'multiqc_report.html', emit: report
    path 'multiqc_data', emit: data
    path 'versions.yml', emit: versions

    script:
    """
    multiqc \
        --force \
        --config ${projectDir}/assets/multiqc_config.yaml \
        --filename multiqc_report.html \
        .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$(multiqc --version | awk '{print \$3}')
    END_VERSIONS
    """

    stub:
    """
    mkdir multiqc_data
    echo '<html><body>SAGFlow stub report</body></html>' > multiqc_report.html
    echo -e 'Sample\tStatus\nstub\tPASS' > multiqc_data/multiqc_general_stats.txt
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: stub
    END_VERSIONS
    """
}
