# Ourogear EDOPro Expansion

A custom Yu-Gi-Oh! archetype for Project Ignis / EDOPro.

## What is included

- **21 playable custom cards** plus **1 Ourogear Token** database entry.
- Generated `Ourogear.cdb` with names, stats, card text, archetype setcode, and effect prompt strings.
- `script/` with all card Lua scripts plus the shared `ourogear.lua` helper.
- `strings.conf` registering the **Ourogear** archetype name (`0x1f99`).
- `deck/Ourogear-Test.ydk` — a 40-card pure Ourogear test deck with a 15-card Extra Deck.
- A generated `Ourogear.zip` single-file EDOPro expansion package (also uploaded by GitHub Actions as the `Ourogear-EDOPro` build artifact).
- Source data and build/validation tools so the database cannot silently drift away from the scripts.

## Install in EDOPro

### Easiest method

1. Close EDOPro.
2. Build/download `Ourogear.zip`, then copy it into your EDOPro `expansions` folder.
3. Start EDOPro again.
4. Search for `@Ourogear` or `Ourogear` in the deck editor.
5. Copy `deck/Ourogear-Test.ydk` into your normal EDOPro deck folder if you want the supplied test deck.

EDOPro officially reads `.zip` card expansions from the `expansions` folder.

### Unpacked method

Copy these files/folders into EDOPro's `expansions` folder:

```text
Ourogear.cdb
strings.conf
script/
pics/
```

If you already maintain a custom `strings.conf`, merge this line into it instead of overwriting it:

```text
!setname 0x1f99 Ourogear
```

## Build / validation

```bash
python tools/build_cdb.py
python tools/validate.py
python tools/build_package.py
```

GitHub Actions also rebuilds the database, validates all IDs/references, installs Lua 5.3, runs `luac5.3 -p` against every Lua file, then loads the custom scripts through Project Ignis' ocgcore-backed ScriptChecker before building and uploading `Ourogear.zip`. It also runs 41 focused callback regressions and 16 real-engine scenarios covering Ritual support, negation, Xyz material transfer, Token substitutions, Material Loom costs, banishment returns, and Launch Harness triggers. These tests check specific rules and do not replace a complete duel test.

## Important custom mechanics

The shared `script/ourogear.lua` implements the archetype-specific rules that normal EDOPro Xyz procedures do not provide:

- WIND Machine Tokens and WIND Machine Xyz Monsters can substitute for any required material of an Ourogear Xyz Summon.
- Existing materials of a WIND Machine Xyz used this way transfer to the newly Summoned Ourogear Xyz Monster.
- A Token used as substitute material is consumed, then the top card of the Deck is attached after the successful Xyz Summon for each Token used.
- Ourogear Xyz Monsters can use their Rank as their Level when used as material for a Reptile Ritual Summon.
- Ourogear Tokens cannot be used as Fusion, Synchro, or Link Material.

## Runtime testing note

The repository performs database integrity checks, Lua syntax compilation, and Project Ignis ocgcore script loading automatically. EDOPro itself is still the final authority for duel-state timing and the custom summon procedure. Use [`docs/runtime-test-matrix.md`](docs/runtime-test-matrix.md) for the one-time in-client validation pass covering the custom Xyz procedure, Ritual-from-Deck effects, inherited Xyz-material effects, DoomZ/Mitsurugi compatibility, and Continuous Spell/Trap interactions.


## Ritual Levels and Tokens

- Rite Circuit's Level 4/8 substitution is automatic while it is face-up and active. It applies to your Ourogear monsters used for a Reptile Ritual Summon; the displayed Level remains unchanged.
- Ordinary Ourogear Tokens can be Tributed by Ritefang/Riteveil/Ritebind's field-material Ritual effects. With Rite Circuit active, one ordinary Token can provide Level 8.
- Tokens created by Relay Frame can be Tributed immediately; Relay no longer adds a same-turn Tribute restriction.
- Rite Circuit's own Quick Ritual effect uses Level 4 Reptiles from your Deck, so field Tokens are not eligible for that effect.
- Mitsurugi Ritual requires Reptile materials. Ourogear Tokens are Machines; changing their Ritual Level does not change their Type.
- Token-creating effects now offer either face-up Attack or Defense Position unless a game effect restricts the available positions.


## Shorter card text and search limits

The Xyz cards keep their listed materials, WIND Machine Xyz substitution/material transfer, and Rank-as-Level use for Reptile Rituals. The shared Token-substitution explanation is printed on Ourogear Token, with a short pointer on each Xyz. This is a display change to the custom procedure; the Xyz scripts still enforce all Token substitutions even though the Token has no separate card script.

Level 4 Rituals and Rite Circuit have numbered effects and one final named once-per-turn clause instead of repeating that limit. Their Ritual material requirements are unchanged.

Windscale, Ritefang, Vector Frame, and Skyforge Nexus exclude same-name cards from their searches. Their existing Ourogear/archetype and Level restrictions remain. Launch Harness already searches Level 4 Ourogear Reptile Ritual Monsters. Ritebind intentionally keeps its broader recursion: it may Special Summon any legal Level 4 Reptile from the hand or banishment, including non-Ourogear and non-WIND monsters. Rite Circuit still uses Level 4 Reptiles from the Deck.
