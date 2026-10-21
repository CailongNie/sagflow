# Release checklist

Before the first public GitHub release:

- [ ] Set the final GitHub organisation/user and repository URL in repository
      metadata after the remote exists.
- [ ] Replace the generic contributor entry in `CITATION.cff` with named
      authors and ORCIDs where appropriate.
- [ ] Confirm the license choice with all code contributors.
- [ ] Run core processes with real small FASTQ data under the supported Conda
      profile; stub tests alone do not validate tool commands.
- [ ] Validate all declared container tags before advertising Docker or
      Singularity as release-supported.
- [ ] Run CheckM2, GUNC, and GTDB-Tk against versioned test databases.
- [ ] Record GTDB-Tk and database-release compatibility.
- [ ] Add nf-test snapshot tests once `nf-test` is installed.
- [ ] Run `nf-core pipelines lint` and document intentional deviations.
- [ ] Review the samplesheet and reports for private identifiers or local
      absolute paths.
- [ ] Create a signed or annotated semantic-version tag.
- [ ] Archive the release in Zenodo or another software repository if a DOI is
      required.
