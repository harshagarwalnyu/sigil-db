# Sigil: Milestone 3 (DB setup and SQL)

Due **Mon Nov 9, 11:59pm**. Submit `REPORT.pdf` + `COMMANDS.sql` on Gradescope.

## Who does what
| Person | Tables (CREATE + 10+ rows) |
|---|---|
| Khalid | University, Instructor, MerkleCheckpoint, Course |
| Mohammad | Student, DisclosureProof, Verifier, Student_Phone |
| Pratyush | DisclosedGrade, Grade |
| Harsh | 2+ advanced commands (different types), GitHub |

**Rule:** do NOT populate any table until everyone has created theirs.

## Layout (files run in this order)
- `sql/01_create/<n>_<name>.sql` – CREATE TABLE (Khalid → Mohammad → Pratyush)
- `sql/02_advanced/harsh.sql` – triggers / functions / procedures
- `sql/03_seed/<n>_<name>.sql` – INSERT data
- `sql/04_queries/<name>.sql` – queries the app uses (not run by build)

## Keeping everyone's database the same
GitHub is the master copy. Never change the database by hand; change your file, push, and rebuild.
```bash
git pull
mysql -u <user> -p < build.sql   # drops and rebuilds `sigil` from every file in order
```
Edit only your own files, then `git add sql/ && git commit -m "msg" && git push`.
In DataGrip: open a terminal in the repo and run the mysql command above (DataGrip's editor doesn't support `SOURCE`).

## Table names (team decision: ERD style, UPPER_SNAKE_CASE)
`UNIVERSITY`, `STUDENT`, `STUDENT_PHONE`, `INSTRUCTOR`, `COURSE`, `MERKLE_CHECKPOINT`, `GRADE`, `VERIFIER`, `DISCLOSURE_PROOF`, `DISCLOSED_GRADE`
Use these exact names in CREATE TABLE and in every FOREIGN KEY ... REFERENCES.

## Columns Harsh's advanced commands rely on
- `GRADE`: grade_id, student_id, course_id, checkpoint_id (**nullable**, NULL until published), supersedes_grade_id (nullable), letter_grade, salt, leaf_hash, leaf_index (nullable), change_reason, recorded_at
- `MERKLE_CHECKPOINT.checkpoint_id` must be `AUTO_INCREMENT`
- `DISCLOSURE_PROOF.status` uses `'active'` / `'revoked'`
- No `ON DELETE CASCADE` on foreign keys pointing into GRADE (cascades skip triggers)
- Test them: `mysql -u <user> -p --force sigil < sql/tests/harsh_tests.sql`, then rerun build.sql

## Current implementation and validation

The implementation targets **MySQL 8.4 LTS**. Milestone 2's PostgreSQL selection
is historical; this milestone uses MySQL syntax and tooling.

Harsh's application queries are in `sql/04_queries/harsh.sql`: proof lookup,
disclosed grade evidence, the public checkpoint registry, backend tree leaves,
and mobile proof creation/selection/revocation. The write examples roll back.
The other three query files remain assigned to their respective owners.

On Windows, run `./scripts/install-windows.ps1` from your own PowerShell to install
MySQL and DataGrip with WinGet. Then use **MySQL Configurator** to initialize the
server and set your own root password. In DataGrip, add a MySQL data source at
`localhost:3306`, download its JDBC driver if prompted, and test the connection.
For local development, if function creation reports error 1418, an administrator
can enable `SET GLOBAL log_bin_trust_function_creators = 1;` on that local server.

Run the fail-fast build and regression checks on a disposable `sigil` database:

```powershell
python scripts/validate.py --mysql "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" --ask-password --rebuild
```

`--rebuild` drops and recreates `sigil`, then restores the seed data after a
successful test run. Without it, validation requires a fresh existing seed
database and leaves the publication test committed; rebuild before repeating.
No third-party Python packages are needed. The runner expands
`SOURCE` statements and stops on any unexpected SQL error. GitHub Actions runs
the same checks against a fresh MySQL 8.4 container.

`python scripts/check_seed.py` checks the actual seed INSERTs, leaf hashes,
Merkle roots, counts and indexes without MySQL. This does not validate MySQL
constraints or stored routines.

See [implementation notes](docs/implementation-notes.md) for the publication
exception to append-only grades, fixture cryptography, and verification limits.

