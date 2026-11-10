# Milestone 3 review

Reviewed against `Milestone 3_DB setup and SQL.docx-4.pdf`, pages 1-5.
This is an estimate of technical readiness, not a grade from course staff or a
verification of the student's final report/Gradescope submission.

| Rubric item | Points | Evidence / remaining condition |
|---|---:|---|
| Database server setup | 3/3 | MySQL 8.4.9 running locally on 127.0.0.1:33307; clean builds and imports pass. Report must state the host. |
| All Milestone 1 tables | 3/3 | All ten original relations remain; three UI-support relations added. Final ERD/schema supplied. |
| Populated, practical, sufficient data | 3/3 | Every table has 10+ rows; multiple offerings, drafts, approval outcomes, corrections and selective disclosure demonstrated. Actual counts supplied. |
| Non-advanced application SQL | 5-6/6 | All four role files populated and executed successfully; query coverage maps to screens below. Application-layer authentication/crypto/files/email are documented separately. |
| Advanced commands: technical portion | 3/3 | Triggers, functions, CHECK constraints and stored procedures exceed the two-different-types minimum. Regression checks pass. |
| Individual peer evaluation | ?/2 | Cannot verify submission. These two points are part of the advanced-command category's five points, not extra points. |

Estimated technical readiness: **17-18 of the 18 non-peer-evaluation points**,
conditional on the report presenting the required evidence clearly. The full
score is conditional on the report and individual peer evaluation. A correct
repository alone does not establish a complete Milestone 3 submission.

## Problems found and addressed

- COURSE duplicated university_id even though instructor_id determines the
  university. Removed the stored column and derived it through INSTRUCTOR.
- Student, instructor and registrar query files were empty. Added transcript,
  GPA, history, proof creation, rosters, drafts, requests, dashboard, publication
  batch, search, registry and audit queries; all execute successfully.
- The model could not represent enrolled students before grading, saved drafts,
  pending corrections, rejected decisions or supporting attachment references.
  Added ENROLLMENT, GRADE_DRAFT and CORRECTION_REQUEST with realistic seed rows.
- Roster submission could otherwise partly commit. Added an atomic JSON-batch
  procedure and verified rollback when a batch is invalid or contains collisions.
- Missing constraints and publication checks were added: original-grade
  uniqueness, checkpoint version/index uniqueness, positive credits, mandatory
  instructors, expiration order, matching publication university/term/index,
  correction ownership and reasons, and irreversible revocation.
- Seed roots hashed course data instead of grade leaves, counts were wrong,
  and leaf numbering conflicted with the procedure. Corrected and independently
  recomputed every seed root/hash/count/index.
- An unconditional ban on all GRADE updates conflicted with later publication.
  Documented and constrained the one-time metadata-assignment exception.
- No standalone submission SQL file, final schema statements or final ERD
  package existed. Added a real MySQL export plus application queries and the
  revised design artifacts. The export imports without repository dependencies.
- SQL execution had not been demonstrated. Ran both test suites, all four query
  files and the standalone SQL import against an actual MySQL server.
- Windows exports lower-case table names. Normalized exported table/view
  identifiers to the project's upper-case convention for Linux portability.

## Query-to-screen coverage

| Screens | SQL / behavior |
|---|---|
| 1: sign-in | Authentication is external; institution/key reads appear in the registry query. |
| 2-3: transcript/history | khalid.sql: current grades, weighted GPA, credits, enrollment, version history. |
| 4-5: proof creation/management | khalid.sql: picker, verifier lookup/create, proof/disclosure INSERT, listing, revocation, profile phones. |
| 6-8: instructor | pratyush.sql: offerings, progress, deadlines, roster identifiers, draft CRUD, request creation/history; submission procedures. |
| 9-10: registrar dashboard/approval | mohammad.sql: KPIs, course progress, pending queue, decision routine and activity feed. |
| 11-12: publication/audit | mohammad.sql: next version, exact leaf batch, full historical ledger, text/term filtering; publish_checkpoint. |
| 13-16: verifier/mobile | harsh.sql: token lookup, failure status, current disclosed grades, ordered leaves, registry root-prefix filtering, sharing/revocation. |

## Still required before submission

1. Finish REPORT.pdf with all team names/NetIDs and database-host details.
2. Include actual schema screenshots, row-count screenshots, and readable sample
   data showing at least ten records for each of the **13** tables.
3. Include the final ERD and relational schema statements, explaining both the
   normalization change and the new UI-support relations.
4. List basic SQL and advanced commands and include evidence of successful tests.
5. Upload REPORT.pdf and COMMANDS.sql to Gradescope, verify they open, and attach
   all group members. A GitHub push does not submit to Gradescope.
6. Submit the individual peer evaluation by the assignment deadline.

The rubric explicitly deducts five points for not submitting a .sql file and
two points for a Word/handwritten report. Those penalties should not be added
to speculative deductions for a report that has not yet been reviewed.

## Practical limits, separate from SQL milestone completion

The web application, university SSO, signature generation/verification, trusted-key
distribution, Merkle-path export, QR/file/CSV interfaces and email delivery are
not implemented here. Seed signatures and keys are labeled fixtures. SQL proof
validity checks current database state, not cryptography. Offline inclusion
proofs cannot establish live revocation or currentness without fresh trusted
state. Production additionally needs restricted accounts, authenticated actor
IDs, collision-safe ID allocation, and controlled concurrent publication and
course/instructor reassignment. Do not present these as already implemented in
REPORT.pdf. MySQL is temporary local hosting; no Windows service/cloud instance
has been configured by this work.
