# Migration from the DP_SAG workspace

Historical inputs and scripts remain read-only. Migration is by reimplementation
and regression testing in this new repository, not by moving or rewriting old
files.

| Historical area | SAGFlow destination | Status |
|---|---|---|
| `MAG_SAG_split_20260727` | input/barcode/target-routing modules | interface defined; barcode module planned |
| `ANA-CP3-CC...drep128...` | competitive assignment and reports | core mapper implemented; full summary planned |
| `260930-OP3-CP3...drep128...` | scalable assignment execution | core mapper implemented; sharding delegated to Nextflow |
| `bin515-subMAGs` 00–13 | individual assembly and projection | assembly core implemented |
| `bin515-subMAGs` 14–27 | callability/network/co-assembly | planned opt-in research subworkflow |
| `bin515-L2-SNP` | microdiversity and functional selection | planned opt-in research subworkflow |
| CP3-0901 snapshots | regression fixtures | historical results retained externally |
| root `bin145_*HGT*` | HGT screening | planned opt-in research subworkflow |

## Acceptance rule for migrated modules

A migrated module is accepted only when:

1. its input/output schema is documented;
2. its parameters and versions are recorded;
3. a minimal test passes;
4. representative historical outputs have been compared without rewriting
   them;
5. differences are explained scientifically;
6. the module writes only declared outputs to a new run directory.
