process SPADES_SC {
    tag "${meta.id}"
    label 'process_high'

    conda 'bioconda::spades=3.15.5'
    container 'quay.io/biocontainers/spades:3.15.5--h95f258a_1'

    publishDir "${params.outdir}/03_assembly", mode: 'copy', overwrite: false,
        saveAs: { filename -> filename == 'versions.yml' ? null : filename }

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${meta.id}.contigs.fa"), emit: assembly
    path 'versions.yml', emit: versions

    script:
    """
    spades.py \
        --sc \
        -1 ${reads[0]} \
        -2 ${reads[1]} \
        -t ${task.cpus} \
        -m ${task.memory.toGiga()} \
        -o spades_${meta.id}
    cp spades_${meta.id}/contigs.fasta ${meta.id}.contigs.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        spades: \$(spades.py --version | sed 's/SPAdes genome assembler v//')
    END_VERSIONS
    """

    stub:
    """
    cat <<-END_FASTA > ${meta.id}.contigs.fa
    >${meta.id}_contig_1
    ACGTACGTACGTACGTACGTACGTACGTACGT
    END_FASTA
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        spades: stub
    END_VERSIONS
    """
}
