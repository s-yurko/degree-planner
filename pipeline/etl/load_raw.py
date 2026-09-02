"""
Load the source Excel exports into the Postgres `raw` schema

Append-only landing: one table per file, headers snake_cased, everything stored as
text. The loader only refuses or replaces whole files by name, it doesn't validate
row content. Cleaning, typing, and cross-year checks happen downstream in dbt
"""

import argparse
import os
import re
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd
import yaml
from sqlalchemy import create_engine, text

REPO_ROOT = Path(__file__).resolve().parents[2]
DATA_RAW_DIR = REPO_ROOT / "data" / "raw"
SOURCES_FILE = Path(__file__).parent / "sources.yml"
SCHEMA = "raw"


def snake_case(name):
    return re.sub(r"[^0-9a-zA-Z]+", "_", str(name).strip().lower()).strip("_")


def make_engine():
    user = os.getenv("POSTGRES_USER", "dplanner")
    password = os.getenv("POSTGRES_PASSWORD", "dplanner")
    host = os.getenv("POSTGRES_HOST", "localhost")
    port = os.getenv("POSTGRES_PORT", "5432")
    db = os.getenv("POSTGRES_DB", "dplanner")
    return create_engine(f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}")


def load_one(engine, src, replace_batch):
    table, fname = src["table"], src["file"]
    path = DATA_RAW_DIR / fname
    if not path.exists():
        raise FileNotFoundError(f"source file not found: {path}")

    # append-only: refuses a re-load unless we're explicitly replacing this file's rows
    with engine.begin() as conn:
        conn.execute(text(f"create schema if not exists {SCHEMA}"))
        exists = conn.execute(text(f"select to_regclass('{SCHEMA}.\"{table}\"')")).scalar()
        loaded = exists and conn.execute(
            text(f'select 1 from {SCHEMA}."{table}" where _source_file = :f limit 1'),
            {"f": fname},
        ).scalar()
        if loaded and not replace_batch:
            raise SystemExit(f"raw.{table} already has rows from {fname}; pass --replace-batch to replace them")
        if loaded:
            conn.execute(text(f'delete from {SCHEMA}."{table}" where _source_file = :f'), {"f": fname})

    df = pd.read_excel(path, sheet_name=src.get("sheet", 0), dtype=str)
    df.columns = [snake_case(c) for c in df.columns]
    df.insert(0, "_source_row", range(2, len(df) + 2))  # excel row, header is row 1
    df["_source_file"] = fname
    df["_ingested_at"] = datetime.now(timezone.utc).isoformat()
    df.to_sql(table, engine, schema=SCHEMA, if_exists="append", index=False)
    return len(df)


def main():
    ap = argparse.ArgumentParser(description="load source Excel files into the raw schema")
    ap.add_argument("--only", nargs="*", help="only these tables (default: all)")
    ap.add_argument("--replace-batch", action="store_true", help="replace an already-loaded file's rows")
    args = ap.parse_args()

    sources = yaml.safe_load(SOURCES_FILE.read_text())["sources"]
    if args.only:
        sources = [s for s in sources if s["table"] in set(args.only)]

    engine = make_engine()
    for src in sources:
        n = load_one(engine, src, args.replace_batch)
        print(f"  loaded {n:5d} rows -> {SCHEMA}.{src['table']}")


if __name__ == "__main__":
    main()
