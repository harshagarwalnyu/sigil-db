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

## Names Harsh's advanced commands rely on (keep these in your CREATE TABLEs)
- Tables: `Grade`, `Course`, `MerkleCheckpoint`, `DisclosureProof`, `DisclosedGrade` (exact Milestone 1 names)
- `Grade`: grade_id, student_id, course_id, checkpoint_id (**nullable**, NULL until published), supersedes_grade_id (nullable), letter_grade, salt, leaf_hash, leaf_index (nullable), change_reason, recorded_at
- `MerkleCheckpoint.checkpoint_id` must be `AUTO_INCREMENT`
- `DisclosureProof.status` uses `'active'` / `'revoked'`
- No `ON DELETE CASCADE` on foreign keys pointing into Grade (cascades skip triggers)
- Test them: `mysql -u <user> -p --force sigil < sql/tests/harsh_tests.sql`, then rerun build.sql

