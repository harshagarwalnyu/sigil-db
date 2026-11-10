"""Export COMMANDS.sql, final schema/ERD and genuine MySQL results for the report.

Requires a populated MySQL 8.4 sigil database; password comes from MYSQL_PWD
or the interactive --ask-password prompt. Does not generate REPORT.pdf.
"""
import argparse
import getpass
import json
import os
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mysql', default='mysql')
    parser.add_argument('--host', default='127.0.0.1')
    parser.add_argument('--port', type=int, default=3306)
    parser.add_argument('--user', default='root')
    parser.add_argument('--ask-password', action='store_true')
    args = parser.parse_args()
    if args.ask_password:
        os.environ['MYSQL_PWD'] = getpass.getpass('MySQL password: ')
    connection = [f'--host={args.host}', f'--port={args.port}', f'--user={args.user}']
    client = [args.mysql, *connection]

    def query(sql, table=False):
        result = subprocess.run(client + (['--table'] if table else ['--batch','--raw','--skip-column-names'])
                                + ['sigil','--execute',sql], check=True, capture_output=True, text=True, encoding='utf-8')
        return result.stdout

    evidence = ROOT / 'report-evidence'
    evidence.mkdir(exist_ok=True)
    tables = [name.upper() for name in query("SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA='sigil' AND TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME").splitlines()]
    metadata = {}
    for table in tables:
        columns = [line.split('\t') for line in query(
            f"SELECT COLUMN_NAME,DATA_TYPE,COLUMN_KEY,IS_NULLABLE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='sigil' AND TABLE_NAME='{table}' ORDER BY ORDINAL_POSITION").splitlines()]
        foreign_keys = [line.split('\t') for line in query(
            f"SELECT COLUMN_NAME,REFERENCED_TABLE_NAME,REFERENCED_COLUMN_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA='sigil' AND TABLE_NAME='{table}' AND REFERENCED_TABLE_NAME IS NOT NULL ORDER BY ORDINAL_POSITION").splitlines()]
        foreign_keys = [[column,target.upper(),key] for column,target,key in foreign_keys]
        metadata[table] = {'columns':columns,'foreign_keys':foreign_keys}
        (evidence / f'{table.lower()}-schema.txt').write_text(f'DESCRIBE {table};\n' + query(f'DESCRIBE `{table}`',True),encoding='utf-8')
        (evidence / f'{table.lower()}-data.txt').write_text(f'SELECT * FROM {table};\n' + query(f'SELECT * FROM `{table}`',True),encoding='utf-8')
    count_query = ' UNION ALL '.join(f"SELECT '{t}' AS table_name,COUNT(*) AS row_count FROM `{t}`" for t in tables)
    (evidence / 'row-counts.txt').write_text(query(count_query,True),encoding='utf-8')
    (evidence / 'server.txt').write_text(query('SELECT VERSION() AS mysql_version,DATABASE() AS database_name,NOW() AS captured_at',True),encoding='utf-8')
    (evidence / 'schema-metadata.json').write_text(json.dumps(metadata,indent=2),encoding='utf-8')

    docs = ROOT / 'docs'
    docs.mkdir(exist_ok=True)
    schema = ['# Final relational schema','',
        'PK marks primary-key attributes; FK names the referenced relation. Nullable attributes are suffixed with ?. The SQL export contains all CHECK and UNIQUE constraints.','',
        'COURSE has no university_id: COURSE.instructor_id → INSTRUCTOR.instructor_id → INSTRUCTOR.university_id. COURSE_CONTEXT is a derived view, not an additional stored relation.','']
    mermaid = ['erDiagram',
        '    UNIVERSITY ||--o{ INSTRUCTOR : employs',
        '    UNIVERSITY ||--o{ STUDENT : admits',
        '    UNIVERSITY ||--o{ MERKLE_CHECKPOINT : publishes',
        '    INSTRUCTOR ||--o{ COURSE : teaches',
        '    STUDENT ||--o{ STUDENT_PHONE : has',
        '    STUDENT ||--o{ ENROLLMENT : joins',
        '    COURSE ||--o{ ENROLLMENT : includes',
        '    ENROLLMENT ||--o| GRADE_DRAFT : saves',
        '    STUDENT ||--o{ GRADE : receives',
        '    COURSE ||--o{ GRADE : awards',
        '    GRADE |o--o| GRADE : supersedes',
        '    MERKLE_CHECKPOINT |o--|{ GRADE : seals',
        '    STUDENT ||--o{ DISCLOSURE_PROOF : creates',
        '    VERIFIER ||--o{ DISCLOSURE_PROOF : receives',
        '    DISCLOSURE_PROOF ||--|{ DISCLOSED_GRADE : reveals',
        '    GRADE ||--o{ DISCLOSED_GRADE : disclosed_as',
        '    GRADE ||--o{ CORRECTION_REQUEST : reviewed_in',
        '    INSTRUCTOR ||--o{ CORRECTION_REQUEST : requests',
        '    GRADE |o--o| CORRECTION_REQUEST : produced_by']
    for table in tables:
        item = metadata[table]
        fk = {row[0]:f'{row[1]}.{row[2]}' for row in item['foreign_keys']}
        attrs = []
        mermaid.append(f'    {table} {{')
        for name,kind,key,nullable in item['columns']:
            tags = (['PK'] if key=='PRI' else []) + (['FK'] if name in fk else [])
            if key=='UNI': tags.append('UK')
            attrs.append(name + ('?' if nullable=='YES' else '') + (' ['+', '.join(tags)+']' if tags else '')
                         + (' → '+fk[name] if name in fk else ''))
            mermaid.append(f'        {kind} {name}' + (' '+', '.join(tags) if tags else ''))
        mermaid.append('    }')
        schema += [f'**{table}**('+', '.join(attrs)+')','']
    schema += ['The checkpoint and proof minimum-one-child relationships express valid published business objects. A proof may temporarily have zero selected grades during a transaction; is_proof_valid rejects an empty proof.','',
        'Normalization: ENROLLMENT and GRADE_DRAFT depend on their complete (student_id, course_id) key; phone numbers and disclosed grades use separate relations. University membership is derived through INSTRUCTOR rather than duplicated on COURSE. GPA and current-grade status remain derived.','']
    (docs / 'final-schema.md').write_text('\n'.join(schema),encoding='utf-8')
    (docs / 'final-erd.mmd').write_text('\n'.join(mermaid)+'\n',encoding='utf-8')

    # This is a real server export, including data, routines and triggers.
    mysql_path = Path(args.mysql)
    dump = str(mysql_path.with_name('mysqldump.exe' if mysql_path.suffix.lower()=='.exe' else 'mysqldump')) if mysql_path.parent != Path('.') else 'mysqldump'
    result = subprocess.run([dump,*connection,'--routines','--triggers','--no-tablespaces',
        '--set-gtid-purged=OFF','--add-drop-database','--databases','sigil'],check=True,capture_output=True,text=True,encoding='utf-8')
    exported = re.sub(r'/\*!\d+ DEFINER=`[^`]+`@`[^`]+`\*/', '', result.stdout)
    exported = re.sub(r'DEFINER=`[^`]+`@`[^`]+`\s*', '', exported)
    # Windows folds table names to lower case. Preserve the team's upper-case
    # identifiers so this export also imports on case-sensitive Linux MySQL.
    names = {name.lower():name for name in tables + ['COURSE_CONTEXT']}
    exported = re.sub(r'`([^`]+)`', lambda m:'`'+names.get(m[1].lower(),m[1])+'`',exported)
    bundle = ['-- Sigil Milestone 3: actual MySQL export plus tested application queries.',
              '-- WARNING: importing recreates the disposable sigil database.', exported]
    for path in sorted((ROOT / 'sql/04_queries').glob('*.sql')):
        bundle += [f'\n-- Application queries: {path.name}\n',path.read_text(encoding='utf-8')]
    (ROOT / 'COMMANDS.sql').write_text('\n'.join(bundle),encoding='utf-8')
    print(f'Exported COMMANDS.sql, {len(tables)} schema/data captures, final-schema.md and final-erd.mmd')


if __name__=='__main__':
    main()
