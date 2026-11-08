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

## Layout
- `sql/01_create/<name>.sql` – CREATE TABLE
- `sql/02_seed/<name>.sql` – INSERT data
- `sql/03_queries/<name>.sql` – queries the app uses
- `sql/04_advanced/harsh.sql` – triggers / functions / procedures

## Workflow
```bash
git pull
# edit only your own files
git add sql/ && git commit -m "your message" && git push
```
All SQL must be written by us (no AI-generated SQL, per the brief).
