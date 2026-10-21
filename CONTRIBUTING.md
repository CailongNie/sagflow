# Contributing

1. Open an issue describing the scientific or engineering change.
2. Create a focused branch from `main`.
3. Do not alter test expectations merely to hide a regression.
4. Add or update tests and documentation.
5. Run:

   ```bash
   nextflow config -profile test
   nextflow run . -profile test -stub-run
   python3 -m unittest discover -s tests/unit -p 'test_*.py'
   ```

6. Submit a pull request with the scientific rationale, parameter changes,
   expected output changes, and compatibility notes.

Custom scripts should expose a command-line interface, return non-zero on
failure, write only declared outputs, and never delete or overwrite inputs.
