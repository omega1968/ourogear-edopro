# Ourogear EDOPro Expansion

Custom Yu-Gi-Oh! archetype for Project Ignis / EDOPro.

## Build target

- Project Ignis CardScripts reference: commit `9c1e64ed879055cb05bd883060d191c26e3d2d0c` (2026-10-31 baseline)
- Custom card IDs: `21430001`-`21430021`
- Token ID: `21430099`
- Setcode: `0x7f0` (`Ourogear`)
- Database `ot`: `4`, matching the owner's existing custom-card CDB

## Install the validated build

Every push/PR runs GitHub Actions to:

1. build `ourogear.cdb` from `database/build_database.py`;
2. compile-check all Lua files;
3. validate the database IDs/schema and the test deck; and
4. upload an installable artifact named **ourogear-edopro-expansion**.

Download that artifact and copy its **contents** into your EDOPro `expansions/` folder:

```text
expansions/
├── ourogear.cdb
├── strings.conf
└── script/
    ├── ourogear.lua
    ├── c21430001.lua
    ├── ...
    └── c21430021.lua
```

The generated SQLite database and generated SQL dump are intentionally not committed; the generator is the authoritative source so they cannot silently drift out of sync.

Card pictures, once added, belong in `expansions/pics/` using the card ID as the filename, e.g. `21430001.jpg`.

The pure-archetype test deck is in `deck/Ourogear-Test.ydk`.

## Important custom mechanics

Ourogear intentionally uses custom Xyz procedures:

- WIND Machine Tokens and WIND Machine Xyz Monsters can fully substitute for the listed Xyz materials.
- Existing materials of a WIND Machine Xyz used as material carry upward.
- A Token used by the custom procedure disappears and is replaced by the top card of the Deck as material after the Xyz Summon.
- Ourogear Xyz Monsters can be Ritual Material for Reptile Ritual Monsters and use their Rank as their Ritual Level.
- Ourogear Tokens cannot be used as Fusion, Synchro, or Link Material.

The archetype intentionally remains compatible with generic Reptile Ritual support (including Mitsurugi) and WIND Machine Xyz support (including DoomZ).

## Build locally

From the repository root:

```bash
python3 database/build_database.py
python3 tools/validate.py
```

This generates `expansion/ourogear.cdb` and `database/cards.sql` locally.

## Runtime testing

Static validation catches database, syntax, ID, and deck-construction errors, but a custom summon procedure can only be fully verified by the EDOPro duel engine. Before merging a release, run the focused checklist in [`docs/runtime-test-checklist.md`](docs/runtime-test-checklist.md).

If EDOPro reports a script error, preserve the exact error text and card ID so it can be fixed against the precise failing code path rather than guessed at.
