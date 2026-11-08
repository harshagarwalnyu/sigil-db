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

All SQL must be written by us (no AI-generated SQL, per the brief).
