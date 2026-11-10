# Evidence for REPORT.pdf

These files contain genuine MySQL 8.4.9 query outputs, not screenshots.
Use them to verify your report and capture the actual result grids in DataGrip
or the MySQL client. Do not label these text files as GUI screenshots.

The validation database is hosted locally on Windows, TCP 127.0.0.1:33307,
database `sigil`. Its data directory is `.local/mysql`; local connection details
are in the ignored `.local/session.json`. Never put the password in your report
or commit that file. This is a running local validation instance, not an installed
Windows service or remote/cloud server.

For each of the 13 tables:

1. Capture `DESCRIBE TABLE_NAME;` (see `*-schema.txt`).
2. Capture `SELECT COUNT(*) FROM TABLE_NAME;` or the combined `row-counts.txt` query results.
3. Show at least 10 records from that table (see `*-data.txt`). Include readable
   columns and continuation images for wide tables rather than shrinking text.

Include `docs/final-erd.pdf` (or render `final-erd.mmd`) and the schema statements
in `docs/final-schema.md`. Explain that the instructor-university redundancy was
removed from COURSE in response to Milestone 1 feedback. Three new UI-support
relations were added; the final report must describe all 13 tables.

Document successful tests from `test-results.txt` and `bundle-import.txt`.
Tests cover forbidden grade edits/deletion, invalid publication, duplicate
original grades, corrections, ownership, expiration, revocation, normalized
course context, atomic grade batches and correction decisions.

List every application-query file and all advanced commands in the report.
The running implementation uses synthetic keys/signatures: describe it as a
database milestone demonstration, not completed cryptographic verification.

Include all team names/NetIDs, submit REPORT.pdf and COMMANDS.sql to Gradescope,
add all group members, and submit the peer evaluation individually. Screenshots,
report completion, group membership and peer evaluation remain human tasks.
