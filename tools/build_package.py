#!/usr/bin/env python3
"""Create a single ZIP that EDOPro can read from its expansions folder."""
from __future__ import annotations
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "Ourogear.zip"


def main() -> None:
    if OUT.exists():
        OUT.unlink()
    with ZipFile(OUT, "w", ZIP_DEFLATED) as z:
        z.write(ROOT / "Ourogear.cdb", "Ourogear.cdb")
        z.write(ROOT / "strings.conf", "strings.conf")
        for path in sorted((ROOT / "script").glob("*.lua")):
            z.write(path, f"script/{path.name}")
        for path in sorted((ROOT / "pics").glob("*")):
            if path.is_file() and path.name != ".gitkeep":
                z.write(path, f"pics/{path.name}")
    print(f"Built {OUT}")


if __name__ == "__main__":
    main()
