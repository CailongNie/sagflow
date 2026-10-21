# SAGFlow

[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A525.04.0-23aa62.svg)](https://www.nextflow.io/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

SAGFlow is a Nextflow DSL2 workflow for bacterial and archaeal
single-amplified genome (SAG) analysis. It standardises read validation,
quality control, competitive reference assignment, single-cell assembly,
assembly QC, contamination screening, taxonomy, and aggregate reporting.

The repository follows nf-core-inspired conventions, but is not currently an
official nf-core pipeline.

## Core workflow

```text
samplesheet
  -> input validation
  -> FastQC + fastp
  -> optional minimap2 competitive mapping + samtools metrics
  -> SPAdes --sc
  -> QUAST
  -> optional CheckM2 / GUNC / GTDB-Tk
  -> MultiQC
```

Research analyses such as SAG co-assembly, block co-occurrence networks,
microdiversity, pN/pS, and HGT screening are deliberately separated from the
core QC workflow. They are planned as opt-in subworkflows with explicit
evidence gates.

## Quick start

Requirements:

- Nextflow `>=25.04.0`
- Java `>=17`
- one software backend: Conda, Docker, or Singularity

Run the lightweight structural test without bioinformatics software:

```bash
nextflow run . -profile test -stub-run
```

Run real data with Conda:

```bash
nextflow run . \
  --input samplesheet.csv \
  --outdir results/run_001 \
  --reference_panel references/drep128.fa \
  -profile conda
```

Each real run must use a new output directory. SAGFlow creates an exclusive
`.sagflow_run_started` marker and refuses to reuse a claimed run tree; process
publication also disables overwriting.

## Samplesheet

```csv
sample_id,dataset,barcode,r1,r2,ont,group,expected_target
ANA2_CB001,ANA-2,CB001,/data/CB001_R1.fastq.gz,/data/CB001_R2.fastq.gz,,batch1,bin.515
```

Required columns are `sample_id`, `dataset`, `barcode`, `r1`, and `r2`.
`sample_id` must be globally unique. A barcode is interpreted only together
with its dataset.

See [docs/usage.md](docs/usage.md) and
[docs/output.md](docs/output.md) for details.

## Design principles

- Original reads, references, scripts, and historical results are read-only.
- Results are written only to a new run directory.
- Every process emits `versions.yml` provenance.
- Scientific tools are isolated in DSL2 modules.
- Custom SAG logic lives in versioned scripts under `bin/`.
- Missing coverage is never converted into a reference call.
- A mapping assignment, block cluster, or co-assembly candidate is not called
  a validated strain genome without independent evidence.

## Repository status

This is the initial integration scaffold. Core interfaces and test execution
are implemented. Optional database-heavy modules require local databases and
should be validated on the target HPC before a first tagged release.

## Citation

See [CITATION.cff](CITATION.cff). Tool-specific citations are listed in
[docs/citations.md](docs/citations.md).

## License

MIT. Third-party tools retain their own licenses.
