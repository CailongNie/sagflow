# Architecture

## Separation of concerns

SAGFlow separates three layers:

1. **Workflow layer** — Nextflow channels, retries, resources, provenance,
   containers/Conda, and publication of declared outputs.
2. **Tool layer** — one DSL2 process per external bioinformatics tool.
3. **Scientific logic layer** — versioned custom programs under `bin/`, with
   explicit inputs, outputs, thresholds, and tests.

Long custom scripts are not embedded inside Nextflow process bodies. This
follows the nf-core recommendation to keep substantial custom logic in module
templates or standalone versioned tools.

## Stable channel contracts

Paired reads:

```groovy
tuple val(meta), path(reads)
```

Assemblies:

```groovy
tuple val(meta), path(assembly)
```

`meta` always contains `id`, `dataset`, `barcode`, `group`, and
`expected_target`. Downstream modules must preserve it.

## Planned extension points

- `BARCODE_EXTRACT`: migrate validated CB parsing and paired-read extraction.
- `ASSIGNMENT_SUMMARY`: consolidate Bowtie2/minimap2 bin-level metrics.
- `SAG_CLUSTER`: sourmash screening followed by ANI confirmation.
- `COSAG`: cluster-gated co-assembly and iterative contamination optimisation.
- `CALLABILITY`: explicit SAG×position/block callable masks.
- `MICRODIVERSITY`: pooled inStrain profiles using one fixed reference.
- `BLOCK_NETWORK`: callability-aware association tests with FDR/maxT.
- `HGT_SCREEN`: composition/reference/viral/taxonomic evidence integration.

Each extension must include a test dataset and a machine-readable result
schema before it is connected to the release workflow.
