#!/usr/bin/env python3
"""Build the EDOPro SQLite card database from database/cards.json."""
from __future__ import annotations
import json
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "database" / "cards.json"
OUTPUT = ROOT / "Ourogear.cdb"
SETCODE = 0x1F99
OT_CUSTOM = 4


def main() -> None:
    cards = json.loads(SOURCE.read_text(encoding="utf-8"))
    if OUTPUT.exists():
        OUTPUT.unlink()
    con = sqlite3.connect(OUTPUT)
    try:
        con.execute(
            """CREATE TABLE datas (
            id INTEGER PRIMARY KEY, ot INTEGER, alias INTEGER, setcode INTEGER,
            type INTEGER, atk INTEGER, def INTEGER, level INTEGER,
            race INTEGER, attribute INTEGER, category INTEGER
            )"""
        )
        con.execute(
            """CREATE TABLE texts (
            id INTEGER PRIMARY KEY, name TEXT, desc TEXT,
            str1 TEXT, str2 TEXT, str3 TEXT, str4 TEXT,
            str5 TEXT, str6 TEXT, str7 TEXT, str8 TEXT,
            str9 TEXT, str10 TEXT, str11 TEXT, str12 TEXT,
            str13 TEXT, str14 TEXT, str15 TEXT, str16 TEXT
            )"""
        )
        for card in cards:
            cid = int(card["id"])
            strings = list(card.get("strings", []))[:16]
            strings += [""] * (16 - len(strings))
            con.execute(
                "INSERT INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)",
                (
                    cid, OT_CUSTOM, 0, SETCODE, int(card["type"]), int(card.get("atk", 0)),
                    int(card.get("def", 0)), int(card.get("level", 0)), int(card.get("race", 0)),
                    int(card.get("attribute", 0)), int(card.get("category", 0)),
                ),
            )
            con.execute(
                "INSERT INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                (cid, card["name"], card["desc"], *strings),
            )
        con.commit()
    finally:
        con.close()
    print(f"Built {OUTPUT} with {len(cards)} cards.")


if __name__ == "__main__":
    main()
