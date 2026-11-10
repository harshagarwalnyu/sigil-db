"""Run MySQL build, fail-fast integrity tests, and Harsh's query examples.

Requires a MySQL 8.4 client/server, or an already-running MySQL Docker container.
Uses MYSQL_PWD/login-path defaults for credentials; never stores a password.
"""
import argparse
import getpass
import os
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def expand_sql(path: Path) -> str:
    """Expand client-side SOURCE commands so errors abort the entire build."""
    return re.sub(
        r"(?im)^SOURCE\s+([^;\r\n]+);\s*$",
        lambda match: expand_sql(ROOT / match[1]),
        path.read_text(encoding="utf-8"),
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mysql", default="mysql", help="Path to mysql.exe")
    parser.add_argument("--container", help="Use docker exec instead of a local client")
    parser.add_argument("--user", default="root")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=3306)
    parser.add_argument("--ask-password", action="store_true", help="Prompt without echoing or storing the password")
    parser.add_argument("--rebuild", action="store_true", help="DROP and rebuild the disposable sigil database")
    args = parser.parse_args()
    if args.ask_password:
        os.environ["MYSQL_PWD"] = getpass.getpass("MySQL password: ")
    command = (
        ["docker", "exec", "-i", "-e", "MYSQL_PWD", args.container, "mysql"]
        if args.container else [args.mysql]
    )
    command += ["--batch", "--raw", "--user=" + args.user]
    if not args.container:
        command += ["--host=" + args.host, "--port=" + str(args.port)]
    paths = (["build.sql"] if args.rebuild else []) + [
        "sql/tests/integrity_tests.sql", "sql/tests/workflow_tests.sql",
        "sql/04_queries/khalid.sql", "sql/04_queries/pratyush.sql",
        "sql/04_queries/mohammad.sql", "sql/04_queries/harsh.sql"
    ]
    if args.rebuild:
        paths.append("build.sql")  # Restore seeds after the publication regression.
    for path in paths:
        print(f"Checking {path}", flush=True)
        subprocess.run(command, input=expand_sql(ROOT / path), text=True,
                       encoding="utf-8", check=True)
    print("PASS: MySQL validation completed")


if __name__ == "__main__":
    main()
