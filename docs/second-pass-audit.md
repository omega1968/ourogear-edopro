# Second-pass script audit

Base reviewed: `4ce86d9bc797852ac6184498d21da2a1017d950c`.
All 21 card scripts, the shared helper, database text, and validation workflow were reviewed against Project Ignis CardScripts and ocgcore API 11 source.

## Corrected behavior

- Windscale, Coilwright, and Driftseer reveal the random hand card as an activation cost, as their semicolon requires. Revealing is followed by shuffling the hand. Resolution only creates the Token.
- Every Token-producing effect checks that the player is actually permitted to summon the specified Token, as well as checking zone space.
- Naga, Recovery Array, and Suppression Grid obtain their controller from the effect in passive conditions. Passive field-condition callbacks receive only the effect argument.
- Aegis Basilisk treats `Duel.NegateActivation` as a boolean. A failed negation no longer proceeds to banish the activating monster.
- Ourogear Xyz Ritual material support now reaches the engine: the engine's native material pool and Ritual Level getter reject Level-less Xyz before consulting EFFECT_RITUAL_LEVEL. Narrow Lua compatibility extensions add releasable Ourogear Xyz to the normal Ritual pool and provide Rank for Reptile Rituals, without giving Xyz ordinary Levels. Non-Ourogear cards retain the original API behavior. The normal Ritual helper still checks material legality.
- Rite Circuit's Level substitution applies only to Reptile Rituals, and also works on Ourogear Xyz through that compatibility layer.
- Token Xyz substitutes preserve Forbidden status and explicit material restrictions instead of bypassing them.
- A supplied Xyz material group is checked against all required material filters, not merely its size and archetype slot.
- Relay Frame's inherited attachment chooses a monster at resolution without targeting, matching its text. Tokens and monsters that cannot be attached by effect are excluded.
- Siege Leviathan's battle-attachment trigger and Launch Harness's material-Token trigger are mandatory, matching text without "you can".
- Ritebind excludes face-down banished monsters from its summon selection.
- Material Loom uses the engine's existing replacement-choice prompt and attaches before paying the full detach cost. Its replacement operation returns integer zero, and does not misread the packed min/max event value as a plain material count. A global move tracker also consumes the first-detach opportunity when the player declines Loom or no top card is available.
- Suppression Grid blocks both manual and effect-driven position changes for affected monsters while the same face-up Grid remains.

## Verification

- Database rebuild, ID/string/reference checks, ZIP build.
- Project Ignis ocgcore-backed ScriptChecker loads all custom scripts.
- `tests/regression.lua`: 28 focused callback regressions with controlled API doubles. The reviewed base fails 21 of these cases; the fixes pass all 28.
- `tools/engine_regression.py`: two actual ocgcore boards, with and without Rite Circuit. These verify the Ritual material pool, Xyz Ritual Level lookup, unchanged ordinary Xyz Levels, non-Reptile exclusion, and passive field callbacks.
- CI now runs both new suites along with Lua 5.3 compilation and the existing checks.

## Still requires complete duel testing

These checks do not prove all turn-by-turn interactions. The runtime matrix still needs an actual EDOPro pass, especially custom Xyz selection/negated Summons, material transfer, delayed return timing, DoomZ/Mitsurugi chains, Material Loom's cost-selection UI, and all Continuous-card interactions.

Dominion Ark retains the documented rules limitation: a Summon occurring while a Chain resolves has no ordinary Summon-negation window. Artwork remains outside this code audit.
