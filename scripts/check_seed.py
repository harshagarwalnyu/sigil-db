"""Check the actual seed SQL's hashes/counts without installing third-party packages.

SQLite evaluates seed INSERTs against column lists extracted from CREATE files.
This checks fixtures only; MySQL syntax, constraints, and routines require validate.py.
"""
import hashlib
from pathlib import Path
import re
import sqlite3

ROOT = Path(__file__).resolve().parents[1]


def sha256(value):
    return hashlib.sha256(value if isinstance(value, bytes) else str(value).encode()).hexdigest()


def concat(*values):
    if any(isinstance(value, bytes) for value in values):
        return b"".join(value if isinstance(value, bytes) else str(value).encode() for value in values)
    return "".join(map(str, values))


def main():
    db = sqlite3.connect(":memory:")
    db.row_factory = sqlite3.Row
    db.create_function("SHA2", 2, lambda value, bits: sha256(value) if bits == 256 else None)
    db.create_function("CONCAT", -1, concat)
    db.create_function("CONCAT_WS", -1, lambda sep, *values: sep.join(str(v) for v in values if v is not None))
    db.create_function("UNHEX", 1, bytes.fromhex)
    tables = []
    for path in sorted((ROOT / "sql/01_create").glob("*.sql")):
        for table, body in re.findall(r"CREATE\s+TABLE\s+(\w+)\s*\((.*?)\n\);", path.read_text(), re.I | re.S):
            columns = re.findall(r"^\s+(\w+)\s+(?:INT|VARCHAR|CHAR|DATE|DATETIME|TEXT)\b", body, re.M | re.I)
            db.execute(f"CREATE TABLE {table} ({', '.join(columns)})")
            tables.append(table)
    assert len(tables) == 10, f"Expected 10 tables, found {tables}"
    for path in sorted((ROOT / "sql/03_seed").glob("*.sql")):
        db.executescript(path.read_text())
    for table in tables:
        count = db.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        assert count >= 10, f"{table} has only {count} seed rows"
    grades = db.execute("SELECT * FROM GRADE").fetchall()
    for grade in grades:
        payload = "|".join(str(grade[key]) for key in (
            "grade_id", "student_id", "course_id", "letter_grade", "salt"))
        assert grade["leaf_hash"] == sha256(payload), f"Grade {grade['grade_id']} hash mismatch"
        assert (grade["checkpoint_id"] is None) == (grade["leaf_index"] is None)
    checkpoints = db.execute("SELECT * FROM MERKLE_CHECKPOINT").fetchall()
    for checkpoint in checkpoints:
        leaves = db.execute("SELECT * FROM GRADE WHERE checkpoint_id=? ORDER BY leaf_index",
                            (checkpoint["checkpoint_id"],)).fetchall()
        assert len(leaves) == checkpoint["leaf_count"], "Checkpoint count mismatch"
        assert [row["leaf_index"] for row in leaves] == list(range(len(leaves))), "Leaf index mismatch"
        level = [bytes.fromhex(row["leaf_hash"]) for row in leaves]
        while len(level) > 1:
            if len(level) % 2:
                level.append(level[-1])
            level = [hashlib.sha256(level[i] + level[i + 1]).digest() for i in range(0, len(level), 2)]
        assert level[0].hex() == checkpoint["root_hash"], f"Checkpoint {checkpoint['checkpoint_id']} root mismatch"
    print(f"PASS: {len(tables)} tables, {len(grades)} grade hashes, {len(checkpoints)} Merkle roots; counts/indexes consistent")
    print("MySQL constraint and routine execution still requires scripts/validate.py.")


if __name__ == "__main__":
    main()
