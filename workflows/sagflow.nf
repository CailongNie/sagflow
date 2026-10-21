include { FASTQC }               from '../modules/local/fastqc/main'
include { FASTP }                from '../modules/local/fastp/main'
include { MINIMAP2_COMPETITIVE } from '../modules/local/minimap2_competitive/main'
include { SAMTOOLS_METRICS }     from '../modules/local/samtools_metrics/main'
include { SPADES_SC }            from '../modules/local/spades_sc/main'
include { QUAST }                from '../modules/local/quast/main'
include { CHECKM2 }              from '../modules/local/checkm2/main'
include { GUNC }                 from '../modules/local/gunc/main'
include { GTDBTK }               from '../modules/local/gtdbtk/main'
include { MULTIQC }              from '../modules/local/multiqc/main'
include { COLLECT_VERSIONS }     from '../modules/local/collect_versions/main'

workflow SAGFLOW {
    take:
    reads
    reference

    main:
    report_channels = []
    version_channels = []

    if (!params.skip_fastqc) {
        FASTQC(reads)
        report_channels << FASTQC.out.reports
        version_channels << FASTQC.out.versions
    }

    FASTP(reads)
    clean_reads = FASTP.out.reads
    report_channels << FASTP.out.reports
    version_channels << FASTP.out.versions

    if (!params.skip_competitive_mapping && params.reference_panel) {
        MINIMAP2_COMPETITIVE(clean_reads, reference)
        SAMTOOLS_METRICS(MINIMAP2_COMPETITIVE.out.sam)
        report_channels << MINIMAP2_COMPETITIVE.out.logs
        report_channels << SAMTOOLS_METRICS.out.reports
        version_channels << MINIMAP2_COMPETITIVE.out.versions
        version_channels << SAMTOOLS_METRICS.out.versions
    }

    if (!params.skip_assembly) {
        SPADES_SC(clean_reads)
        assemblies = SPADES_SC.out.assembly
        version_channels << SPADES_SC.out.versions

        QUAST(assemblies)
        report_channels << QUAST.out.reports
        version_channels << QUAST.out.versions

        if (!params.skip_checkm2) {
            if (!params.checkm2_db) error "--checkm2_db is required when CheckM2 is enabled"
            CHECKM2(assemblies)
            report_channels << CHECKM2.out.reports
            version_channels << CHECKM2.out.versions
        }
        if (!params.skip_gunc) {
            if (!params.gunc_db) error "--gunc_db is required when GUNC is enabled"
            GUNC(assemblies)
            report_channels << GUNC.out.reports
            version_channels << GUNC.out.versions
        }
        if (!params.skip_gtdbtk) {
            if (!params.gtdbtk_data_path) error "--gtdbtk_data_path is required when GTDB-Tk is enabled"
            GTDBTK(assemblies)
            report_channels << GTDBTK.out.reports
            version_channels << GTDBTK.out.versions
        }
    }

    if (!params.skip_multiqc) {
        all_reports = report_channels.size() > 1 \
            ? report_channels[0].mix(*report_channels[1..-1]) \
            : report_channels[0]
        MULTIQC(all_reports.collect())
        version_channels << MULTIQC.out.versions
    }

    all_versions = version_channels.size() > 1 \
        ? version_channels[0].mix(*version_channels[1..-1]) \
        : version_channels[0]
    COLLECT_VERSIONS(all_versions.collect())

    emit:
    clean_reads
}
