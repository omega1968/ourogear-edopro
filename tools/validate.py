#!/usr/bin/env python3
"""Static integrity checks for the Ourogear EDOPro expansion."""
from __future__ import annotations
import json
import re
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CARDS_JSON = ROOT / "database" / "cards.json"
CDB = ROOT / "Ourogear.cdb"
SCRIPT_DIR = ROOT / "script"
EXPECTED_CARD_IDS = set(range(990071001, 990071023))
TOKEN_ID = 990071099
SETCODE = 0x1F99


def fail(msg: str) -> None:
    print(f"ERROR: {msg}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    cards = json.loads(CARDS_JSON.read_text(encoding="utf-8"))
    ids = [int(c["id"]) for c in cards]
    if len(ids) != len(set(ids)):
        fail("duplicate card IDs in cards.json")
    if set(ids) != EXPECTED_CARD_IDS | {TOKEN_ID}:
        fail(f"unexpected card ID set: {sorted(set(ids) ^ (EXPECTED_CARD_IDS | {TOKEN_ID}))}")
    if len(cards) != 23:
        fail(f"expected 23 database rows (22 cards + Token), got {len(cards)}")

    # Every non-Token card has exactly one Lua file named for its ID.
    script_ids = set()
    for path in SCRIPT_DIR.glob("c*.lua"):
        m = re.fullmatch(r"c(\d+)\.lua", path.name)
        if m:
            script_ids.add(int(m.group(1)))
    if script_ids != EXPECTED_CARD_IDS:
        fail(f"script ID mismatch; missing={sorted(EXPECTED_CARD_IDS-script_ids)}, extra={sorted(script_ids-EXPECTED_CARD_IDS)}")
    if not (SCRIPT_DIR / "ourogear.lua").exists():
        fail("missing shared script/ourogear.lua")

    # Every aux.Stringid(id,n) reference must have a corresponding CDB str(n+1).
    by_id = {int(c["id"]): c for c in cards}
    for cid in sorted(EXPECTED_CARD_IDS):
        text = (SCRIPT_DIR / f"c{cid}.lua").read_text(encoding="utf-8")
        indexes = [int(x) for x in re.findall(r"aux\.Stringid\(id,(\d+)\)", text)]
        string_count = len(by_id[cid].get("strings", []))
        for idx in indexes:
            if idx >= string_count:
                fail(f"c{cid}.lua references aux.Stringid(id,{idx}) but cards.json has only {string_count} strings")

        # Catch unresolved local s.* references (simple but useful static guard).
        defs = set(re.findall(r"function\s+s\.([A-Za-z_][A-Za-z0-9_]*)", text))
        defs |= set(re.findall(r"s\.([A-Za-z_][A-Za-z0-9_]*)\s*=\s*function", text))
        refs = set(re.findall(r"s\.([A-Za-z_][A-Za-z0-9_]*)", text))
        fields = {"listed_series", "listed_names", "ritparams", "counter_place_list"}
        missing = refs - defs - fields
        if missing:
            fail(f"c{cid}.lua has unresolved local script references: {sorted(missing)}")

    # Database checks.
    if not CDB.exists():
        fail("Ourogear.cdb is missing; run tools/build_cdb.py")
    con = sqlite3.connect(CDB)
    try:
        datas = con.execute("SELECT id,ot,setcode,type,atk,def,level,race,attribute FROM datas ORDER BY id").fetchall()
        texts = con.execute("SELECT id,name,desc FROM texts ORDER BY id").fetchall()
        if len(datas) != 23 or len(texts) != 23:
            fail(f"database row count mismatch: datas={len(datas)} texts={len(texts)}")
        db_ids = {row[0] for row in datas}
        if db_ids != set(ids):
            fail("database IDs do not match cards.json")
        text_ids = {row[0] for row in texts}
        if text_ids != set(ids):
            fail("texts IDs do not match cards.json")
        for row in datas:
            if row[1] != 4:
                fail(f"card {row[0]} has unexpected OT {row[1]}")
            if row[2] != SETCODE:
                fail(f"card {row[0]} has unexpected setcode {row[2]:#x}")
        db_names = {row[0]: row[1] for row in texts}
        for card in cards:
            if db_names[int(card["id"])] != card["name"]:
                fail(f"database name mismatch for {card['id']}")
    finally:
        con.close()

    # Verify the test deck only references known custom IDs and obeys 3-copy limit.
    deck = ROOT / "deck" / "Ourogear-Test.ydk"
    if deck.exists():
        counts = {}
        mode = None
        for raw in deck.read_text(encoding="utf-8").splitlines():
            line = raw.strip()
            if line == "#main": mode = "main"; continue
            if line == "#extra": mode = "extra"; continue
            if line == "!side": mode = "side"; continue
            if not line or line.startswith("#"): continue
            cid = int(line)
            if cid not in set(ids):
                fail(f"test deck references unknown custom ID {cid}")
            counts[(mode,cid)] = counts.get((mode,cid),0)+1
            if counts[(mode,cid)] > 3:
                fail(f"test deck has more than 3 copies of {cid} in {mode}")

    print("Ourogear validation passed: 21 scripted cards + 1 Token, database and string references are consistent.")


if __name__ == "__main__":
    main()
