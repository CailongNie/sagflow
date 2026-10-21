# Output

```text
OUTDIR/
├── 01_qc/
│   ├── fastqc/
│   └── fastp/
├── 02_competitive_mapping/
├── 03_assembly/
├── 04_assembly_qc/
│   ├── quast/
│   ├── checkm2/
│   └── gunc/
├── 05_taxonomy/
│   └── gtdbtk/
├── 06_report/
│   ├── multiqc_report.html
│   └── multiqc_data/
└── pipeline_info/
    ├── execution_report.html
    ├── execution_timeline.html
    ├── execution_trace.txt
    └── pipeline_dag.html
```

Important interpretation boundaries:

- `02_competitive_mapping` describes assignment to the supplied reference
  panel, not absolute organism abundance.
- `03_assembly` contains individual SAG assemblies produced with SPAdes
  single-cell mode.
- CheckM2 and GUNC estimates are complementary; neither alone identifies the
  correct biological host of every contaminated SAG.
- GTDB-Tk classification is conditional on the recorded GTDB release.
- A co-assembly or subMAG claim is outside the core workflow until the planned
  evidence-gated subworkflow is implemented and independently validated.
