# Third-pass script audit

Reviewed the updated PR #4 implementation at `c5d91113557f1e3fe1784361ab25684d5ed2362f`, all card scripts, and custom helper behavior against Project Ignis ocgcore API 11. No card names, stats, or intended effects were redesigned.

## Further fixes

1. **Native Ritual material default:** an omitted Lua argument had been forwarded as explicit nil. The native boolean conversion treated that as false, bypassing its Level filter. The wrapper now supplies true by default, so Level-less non-Xyz cards are not accidentally admitted.
2. **Negated Xyz Ritual support:** the compatibility layer now evaluates active Ritual Level effects instead of supplying Rank unconditionally. A negated Xyz loses its own ability; an independently active Rite Circuit can still supply Level 4/8. Both states are tested with real engine cards.
3. **Ritefang's shuffle cost:** its activation check accounts for Ritefang itself becoming a legal search candidate when it pays its cost by shuffling into the Deck. This works even when the Deck has no other eligible Level 4 Ourogear Reptile.
4. **Skyforge Nexus restoration:** if fewer Spell/Trap Zones remain at resolution, the controller selects which eligible targets to place. Forbidden cards and cards that fail uniqueness checks are excluded.

## Expanded verification

There are now **33 controlled callback regressions** and **12 actual-engine scenarios** (two variants of six fixtures):

| Fixture | Verified |
| --- | --- |
| `engine_regression.lua` | Normal and negated Xyz Ritual Levels/pools, with and without Rite Circuit; ordinary Levels remain unchanged; Link exclusion; Ritual Level sums; Ritual-from-Deck activation check; passive callbacks; Ritefang self-search eligibility. |
| `engine_actions.lua` | Native Xyz Summon of Relay/Breach using a loaded Vector Frame plus a Token; carried-over materials; top-deck attachment; inherited stats. |
| `engine_token_summon.lua` | Native Rank 8 Summon using three Tokens; exactly three replacement materials; Siege stats; negated-Summon cleanup and no top-deck attachment after negation. |
| `engine_loom.lua` | Paying detach 10 with nine materials plus the top Deck card; alternatively declining Loom on an ordinary detach and correctly losing the first-use opportunity. |
| `engine_returns.lua` | Ark's real banish/return callback; Sovereign's face-down Extra Deck banish and return; next-opponent-turn predicate for activation on either player's turn. Turn predicates are controlled and return callbacks are invoked directly; this does not simulate two full turns. |
| `engine_harness.lua` | Actual Harness trigger and exactly one Token after the equipped monster is used for Ritual/Xyz material. |

The action-test driver only makes explicit fixture choices: legal zones/position, activating the uniquely labeled test effect, declining optional responses, and deterministic material selections. It fails on unrecognized prompts or unmet assertions. GitHub Actions runs all six fixtures plus the callback suite, syntax compilation, Project Ignis ScriptChecker, database validation, and package build.

## Remaining limits

This is substantially stronger than loading scripts, but not a complete match against a human opponent. The client runtime matrix is still needed for DoomZ/Mitsurugi chains, unusual interruption/replacement effects, cost-selection UI, complete phase progression, and multiplayer agreement on the custom rules. Dominion Ark's documented lack of a summon-negation window during a resolving Chain is unchanged. Card art is still absent.
