process SAMTOOLS_METRICS {
    tag "${meta.id}"
    label 'process_medium'

    conda 'bioconda::samtools=1.21'
    container 'quay.io/biocontainers/samtools:1.21--h50ea8bc_0'

    publishDir "${params.outdir}/02_competitive_mapping", mode: 'copy', overwrite: false,
        saveAs: { filename -> filename == 'versions.yml' ? null : filename }

    input:
    tuple val(meta), path(sam)

    output:
    tuple val(meta), path("${meta.id}.sorted.bam"), path("${meta.id}.sorted.bam.bai"), emit: bam
    path "${meta.id}.*.txt", emit: reports
    path 'versions.yml', emit: versions

    script:
    """
    samtools view -@ ${task.cpus} -b ${sam} \
        | samtools sort -@ ${task.cpus} -o ${meta.id}.sorted.bam -
    samtools index -@ ${task.cpus} ${meta.id}.sorted.bam
    samtools flagstat -@ ${task.cpus} ${meta.id}.sorted.bam > ${meta.id}.flagstat.txt
    samtools idxstats ${meta.id}.sorted.bam > ${meta.id}.idxstats.txt
    samtools stats -@ ${task.cpus} ${meta.id}.sorted.bam > ${meta.id}.stats.txt
    samtools view -@ ${task.cpus} -b \
        -q ${params.min_mapq} -f 2 -F 2304 \
        ${meta.id}.sorted.bam \
        | samtools flagstat -@ ${task.cpus} - \
        > ${meta.id}.mapq${params.min_mapq}.proper_primary.flagstat.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(samtools --version | head -n 1 | sed 's/samtools //')
    END_VERSIONS
    """

    stub:
    """
    touch ${meta.id}.sorted.bam ${meta.id}.sorted.bam.bai
    touch ${meta.id}.flagstat.txt ${meta.id}.idxstats.txt ${meta.id}.stats.txt
    touch ${meta.id}.mapq${params.min_mapq}.proper_primary.flagstat.txt
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: stub
    END_VERSIONS
    """
}
