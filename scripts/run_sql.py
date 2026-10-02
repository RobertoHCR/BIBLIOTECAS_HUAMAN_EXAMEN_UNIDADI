"""Ejecuta ambos scripts y comprueba el total cargado, sin imprimir credenciales."""
import csv
import os
import re
from pathlib import Path
import pyodbc

ROOT = Path(__file__).resolve().parents[1]

def quoted(value):
    return "{" + value.replace("}", "}}") + "}"

def main():
    keys = ("SQL_SERVER", "SQL_DATABASE", "SQL_ADMIN", "SQL_PASSWORD")
    values = {key: os.environ[key] for key in keys}
    connection_string = (
        "DRIVER={ODBC Driver 18 for SQL Server};"
        f"SERVER=tcp:{values['SQL_SERVER']},1433;"
        f"DATABASE={quoted(values['SQL_DATABASE'])};"
        f"UID={quoted(values['SQL_ADMIN'])};PWD={quoted(values['SQL_PASSWORD'])};"
        "Encrypt=yes;TrustServerCertificate=no;Connection Timeout=60;"
    )
    with (ROOT / 'data/bibliotecas.csv').open(encoding='utf-8-sig', newline='') as f:
        expected = sum(1 for _ in csv.DictReader(f))
    if expected == 0:
        raise RuntimeError('El dataset no contiene registros.')
    conn = pyodbc.connect(connection_string, autocommit=True)
    try:
        cur = conn.cursor()
        for filename in ('01_create_tables.sql', '02_load_data.sql'):
            sql = (ROOT / 'sql' / filename).read_text(encoding='utf-8')
            batches = re.split(r'^\s*GO\s*$', sql, flags=re.M | re.I) if filename == '01_create_tables.sql' else [sql]
            for batch in batches:
                if batch.strip():
                    cur.execute(batch)
                    while cur.nextset():
                        pass
        actual = cur.execute('SELECT COUNT(*) FROM dbo.vw_bibliotecas').fetchone()[0]
        if actual != expected:
            raise RuntimeError(f'Conteo incorrecto: esperado {expected}, obtenido {actual}.')
        print(f'Carga verificada: {actual} registros.')
    finally:
        conn.close()

if __name__ == '__main__':
    main()
