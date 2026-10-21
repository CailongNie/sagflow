#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SAGFLOW } from './workflows/sagflow'

def requiredColumns = ['sample_id', 'dataset', 'barcode', 'r1', 'r2']

workflow {
    if (!params.input) {
        error "Missing required parameter: --input"
    }
    if (!params.outdir) {
        error "Missing required parameter: --outdir"
    }
    // Nextflow creates pipeline_info before the workflow body when trace/report
    // outputs are enabled. An exclusive marker therefore guards the run tree
    // more reliably than testing the directory itself.
    def outdirFile = new File(params.outdir.toString())
    outdirFile.mkdirs()
    def runMarker = new File(outdirFile, '.sagflow_run_started')
    if (!runMarker.createNewFile()) {
        error "Output directory has already been claimed by SAGFlow; choose a new path: ${params.outdir}"
    }
    runMarker.text = "SAGFlow run claimed ${java.time.Instant.now()}\n"

    samplesheet = file(params.input, checkIfExists: true)

    ch_samples = Channel
        .fromPath(samplesheet, checkIfExists: true)
        .splitCsv(header: true, sep: ',')
        .collect()
        .flatMap { rows ->
            if (!rows) {
                error "Samplesheet contains no data rows: ${samplesheet}"
            }
            requiredColumns.each { column ->
                if (!rows[0].containsKey(column)) {
                    error "Samplesheet is missing required column: ${column}"
                }
            }
            def ids = rows.collect { it.sample_id?.toString()?.trim() }
            def duplicates = ids.countBy { it }.findAll { key, value -> key && value > 1 }.keySet()
            if (duplicates) {
                error "sample_id must be globally unique; duplicates: ${duplicates.sort().join(', ')}"
            }
            rows.collect { row ->
                requiredColumns.each { column ->
                    if (!row[column]?.toString()?.trim()) {
                        error "Empty ${column} value in sample ${row.sample_id ?: '<unknown>'}"
                    }
                }
                def meta = [
                    id              : row.sample_id.toString().trim(),
                    dataset         : row.dataset.toString().trim(),
                    barcode         : row.barcode.toString().trim(),
                    group           : row.group?.toString()?.trim() ?: '',
                    expected_target : row.expected_target?.toString()?.trim() ?: ''
                ]
                def reads = [
                    file(row.r1.toString().trim(), checkIfExists: true),
                    file(row.r2.toString().trim(), checkIfExists: true)
                ]
                tuple(meta, reads)
            }
        }

    ch_reference = params.reference_panel \
        ? Channel.value(file(params.reference_panel, checkIfExists: true)) \
        : Channel.empty()

    SAGFLOW(ch_samples, ch_reference)
}
