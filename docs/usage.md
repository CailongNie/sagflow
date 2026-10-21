# Usage

## Input contract

The samplesheet is the stable interface between laboratory/sample metadata and
the workflow.

| Column | Required | Meaning |
|---|---:|---|
| `sample_id` | yes | Globally unique SAG identifier |
| `dataset` | yes | Sequencing batch or biological dataset |
| `barcode` | yes | Cell barcode within `dataset` |
| `r1` | yes | Read 1 FASTQ, absolute or launch-directory-relative path |
| `r2` | yes | Read 2 FASTQ |
| `ont` | no | Barcode-associated ONT FASTQ for future phasing modules |
| `group` | no | Predefined technical/biological group |
| `expected_target` | no | Expected MAG/bin; never treated as observed evidence |

Validate before running:

```bash
python3 bin/validate_samplesheet.py --input samplesheet.csv
```

## Core run

```bash
nextflow run . \
  -profile conda \
  -params-file params.yaml
```

For Singularity or Docker, use the matching profile after validating all
selected module images on the target machine. Database-heavy modules are
initially distributed with Conda definitions and are skipped by default.

## Mandatory new-output rule

`--outdir` must be new or empty before Nextflow initialises it. SAGFlow creates
an exclusive `.sagflow_run_started` marker and will not reuse a claimed run
tree. It does not provide an overwrite or cleanup switch. Nextflow's `work/`
directory is also retained by default.

To restart a failed scientific run, use a new output directory. `-resume` may
reuse Nextflow's content-addressed task cache, but must not publish over a
previous result tree.

## Competitive mapping

Provide a contig-prefixed combined reference FASTA:

```text
>bin.145|contig_1
...
>bin.515|contig_1
...
```

The core mapper uses minimap2 short-read mode with secondary alignments
disabled. Read assignment must later be summarised jointly with coverage
breadth; a high read count over a narrow conserved region is not evidence for
the full genome.

## Genome QC databases

CheckM2, GUNC, and GTDB-Tk are opt-in because their databases are large and
version-coupled. Record both tool and database versions in every release run.
GTDB-Tk software and reference-data releases must be compatible.

## Resource configuration

The default configuration is conservative and local. For HPC use, copy
`conf/slurm.config.example` to a new site-specific configuration and pass it
with `-c`. Keep scientific parameters in the params YAML; use config files for
resources and infrastructure only.
