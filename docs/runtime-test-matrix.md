# Ourogear Runtime Test Matrix

This checklist is for one deliberate EDOPro test pass after the automated checks are green. The repository already validates the database, compiles every Lua file, and loads every card's `initial_effect` through Project Ignis' ocgcore-backed ScriptChecker. These tests cover interactions that require an actual duel state.

## Core loading

- [ ] EDOPro starts with the expansion installed and reports no Lua/database errors.
- [ ] Searching `@Ourogear` shows all 21 playable cards and the Token is created by effects correctly.
- [ ] `Ourogear-Test.ydk` loads without missing-card warnings.

## Level 4 Effect Monsters

For Windscale, Coilwright, and Driftseer:

- [ ] The hand Special Summon is available while you control a face-up WIND Machine monster.
- [ ] The hand Special Summon is also available while you control any Token.
- [ ] The hand Special Summon is not available with neither condition.
- [ ] Each on-summon effect works on both Normal and Special Summon.
- [ ] The random hand reveal is chosen by the opponent and creates exactly 1 Ourogear Token; choose Attack or Defense Position.
- [ ] Each named effect respects its hard once-per-turn limit.

Specific effects:

- [ ] Windscale searches an Ourogear monster other than itself.
- [ ] Coilwright searches an Ourogear Spell/Trap.
- [ ] Driftseer draws 2, then places exactly 1 card from hand on the bottom of the Deck.

## Level 4 Ritual Monsters

For Ritefang, Riteveil, and Ritebind:

- [ ] Discarding the Ritual can Ritual Summon a Reptile Ritual Monster directly from the Deck.
- [ ] Only monsters you control on your field can be Tributed by this hand effect.
- [ ] Total Levels may equal or exceed the summoned Ritual's Level.
- [ ] Mitsurugi monsters Tributed this way receive their normal Tribute triggers.
- [ ] A non-Ourogear Reptile Ritual can be summoned if otherwise legal.

Specific field/GY effects:

- [ ] Ritefang negates a face-up monster until the End Phase and its GY effect shuffles itself, then searches a Level 4 Ourogear Reptile.
- [ ] Riteveil flips a face-up opponent monster face-down and its GY effect shuffles itself, then searches an Ourogear Spell/Trap.
- [ ] Ritebind prevents attacking and Fusion/Synchro/Xyz/Link material use for the turn and its GY effect shuffles itself, then Special Summons a Level 4 Reptile from hand or banishment.
- [ ] GY effects are ignition effects and cannot be used during the opponent's turn.

## Level 8 / Level 12 Ritual Monsters

- [ ] Aegis Basilisk negates an opponent's card/effect activation and banishes that card if the negation succeeds.
- [ ] Each time your opponent activates a card or effect, it can affect at most 1 Ourogear card you control.
- [ ] If the opponent controls 2 or more monsters, your Ourogear monsters inflict piercing battle damage.
- [ ] Twin-Gale Naga can target either a face-up monster or face-up Spell/Trap.
- [ ] Naga negates the targeted card until the End Phase; a targeted monster also cannot attack or be Fusion/Synchro/Xyz/Link Material that turn.
- [ ] Naga grants a second attack to each Ourogear monster while you control a WIND Machine.

For Ourogear Sovereign:

- [ ] Each opponent monster loses 600 ATK/DEF for each other monster that opponent controls.
- [ ] The once-per-Chain choice appears only for an opponent activation.
- [ ] The opponent can choose to negate their own activated effect.
- [ ] The opponent can instead have exactly 1 random Extra Deck card banished face-down.
- [ ] If Sovereign is used on your turn, that Extra Deck card returns at the End Phase of the opponent's next turn.
- [ ] If Sovereign is used on the opponent's turn, the card does **not** return that same End Phase; it returns at the End Phase of their following turn.
- [ ] Activated Ourogear monster effects from your Monster Zone cannot be negated by the opponent.
- [ ] Ourogear monster effects activated from hand/GY/banishment are not incorrectly protected by that field aura.

## Custom Xyz procedure

Test Rank 4 and Rank 8 separately. Rank 8 monsters require 3 Level 4 monsters total, including at least 1 Level 4 Ourogear monster.

- [ ] Normal listed materials work.
- [ ] A WIND Machine Token can substitute for any required slot.
- [ ] Multiple Tokens can substitute in the same Xyz Summon.
- [ ] A WIND Machine Xyz Monster can substitute for any required slot.
- [ ] Full substitution works when every required material is a legal substitute.
- [ ] A non-substitute material still has to meet the printed Level/Rank requirement.
- [ ] At least one normal Ourogear-required slot is satisfied, or a valid WIND Machine Token/Xyz substitutes for it.
- [ ] Tokens used for the Xyz Summon are consumed rather than remaining as Xyz Material.
- [ ] After a successful Xyz Summon, exactly 1 top card of your Deck is attached for each Token used.
- [ ] If a WIND Machine Xyz is used, all materials already attached to it carry over to the new Ourogear Xyz.
- [ ] The used WIND Machine Xyz itself also becomes material.
- [ ] The resulting material count is correct when Tokens and preloaded Xyz monsters are mixed.
- [ ] Ourogear Tokens cannot be used as Fusion, Synchro, or Link Material.
- [ ] Ourogear Xyz Monsters can be used for a Reptile Ritual Summon with Rank treated as Level.

## Rank 4 effects / inherited effects

- [ ] Vector Frame detaches 2 and searches exactly 2 differently named Ourogear cards.
- [ ] A WIND Machine Xyz with Vector Frame as material gains 500 ATK/DEF.
- [ ] Relay Frame detaches 1 to create a Token that cannot be Tributed that turn.
- [ ] A WIND Machine Xyz with Relay Frame as material can attach 1 monster from an opponent's successful Special Summon.
- [ ] If that attached monster is itself an Xyz Monster, its former materials do not improperly carry over.
- [ ] Breach Frame detaches 1 and can destroy 1 or 2 opponent cards.
- [ ] A WIND Machine Xyz with Breach Frame as material gains the once-per-turn single-card destruction effect.

## Rank 8 effects

For Siege Leviathan:

- [ ] Xyz Summon using 3 Level 4 monsters, including at least 1 Level 4 Ourogear monster.

- [ ] It can attack every opponent monster once each.
- [ ] A monster it destroys by battle is attached as material.
- [ ] ATK/DEF updates by 300 for every currently attached material.
- [ ] The detach-10 Quick Effect is unavailable below 10 materials.
- [ ] With 9 materials and an unused Material Loom replacement, the detach-10 effect can be paid by first attaching the top card.
- [ ] The detach-10 effect banishes the opponent's field, hand, and GY.

For Dominion Ark:

- [ ] Xyz Summon using 3 Level 4 monsters, including at least 1 Level 4 Ourogear monster.

- [ ] Its Quick Effect detaches 1 and banishes a field card until your next End Phase.
- [ ] The first two legal Extra Deck Special Summon attempts each turn prompt the opponent to destroy 1 card they control.
- [ ] If they successfully destroy a card, the Summon proceeds.
- [ ] If they decline/cannot successfully destroy a card, the Summon attempt is negated.
- [ ] A third eligible Extra Deck Summon that turn is not taxed.

### Rules note for Dominion Ark

EDOPro follows normal Yu-Gi-Oh! summon-negation timing. A Special Summon that occurs **while a Chain is resolving** does not create a window in which `Duel.NegateSummon` can negate that Summon. The current script therefore applies Dominion Ark's printed “or that Summon is negated” clause only to Extra Deck Summon attempts that can legally be negated under normal game rules. This should be verified with ordinary Synchro/Xyz/Link procedures and separately with effect-based Fusion/Special Summons so the behavior is understood rather than mistaken for a script error.

## Spells / Traps

### Launch Harness

- [ ] Activation Special Summons a Level 4 Ourogear Reptile from Deck.
- [ ] You may choose whether to equip Launch Harness to that summoned monster.
- [ ] While equipped, it searches a Level 4 Ourogear Reptile Ritual Monster once per turn.
- [ ] If the equipped monster becomes Ritual Material, Launch Harness reaches the GY as expected and creates a Token.
- [ ] If the equipped monster becomes Xyz Material, Launch Harness reaches the GY as expected and creates a Token.
- [ ] The Token effect does not falsely trigger when the equipped monster leaves for another reason.

### Skyforge Nexus

- [ ] Searches any Ourogear card once per turn.
- [ ] Prevents only the first destruction of your Ourogear Spell/Trap by an opponent's card effect each turn.
- [ ] Places 1 or 2 Ourogear Continuous Spells/Traps from GY face-up without treating that placement as activation.
- [ ] Re-placing Skyforge after it leaves the field gives a fresh soft once-per-turn search/placement, matching the printed text.

### Rite Circuit

- [ ] Ourogear monsters can provide Ritual Level 4 or 8 as appropriate.
- [ ] Quick Ritual Summon can summon an Ourogear Ritual from hand using only Level 4 Reptiles from the Deck.
- [ ] It can also summon from GY using only those Deck materials.
- [ ] A Ritual sent from the field to the GY that same turn cannot be re-Ritual-Summoned from the GY by Rite Circuit.
- [ ] A Ritual already in the GY from an earlier turn can be summoned.
- [ ] Sending Rite Circuit itself to the GY creates a Token once per turn.

### Recovery Array

- [ ] The +500/+500 and monster-effect targeting protection turn on only while the opponent controls more cards than you.
- [ ] It searches only an Ourogear Continuous Spell/Trap other than itself.
- [ ] Sending itself to the GY creates a Token once per turn.

### Material Loom

- [ ] The first detach cost of each individual WIND Machine Xyz each turn gets its own opportunity to attach the top card first.
- [ ] Choosing not to use Loom still consumes that Xyz monster's “first detach” opportunity for that turn, matching the wording.
- [ ] If the Xyz is exactly one material short of paying the detach cost, the top-card attachment is used automatically so the cost can be paid.
- [ ] The GY recovery effect targets exactly 3 differently named Ourogear cards at activation.
- [ ] The opponent randomly chooses which surviving target goes to your hand.
- [ ] The remaining surviving targets are shuffled into the Deck only after the chosen card is successfully added.

### Grave Harvester

- [ ] An opponent effect activated in their GY can trigger the first attach effect.
- [ ] A card leaving their GY because of their resolving card/effect can trigger the second effect.
- [ ] A card leaving their GY only as an activation **cost** does not incorrectly satisfy the second effect.
- [ ] Each effect is independently once per turn.

### Suppression Grid

- [ ] Newly Special Summoned opponent monsters in Attack Position are changed to Defense Position.
- [ ] Link Monsters are unaffected by the position-changing portion.
- [ ] Monsters changed by Grid cannot manually/effectively change battle position while that same Grid remains face-up.
- [ ] The lock disappears when that copy of Grid leaves the field.
- [ ] Both face-up and face-down Defense Position monsters count toward the 4-monster threshold.
- [ ] At 4+ Defense Position monsters, effects of face-up Defense Position monsters cannot be activated.

## Cross-archetype compatibility

### Mitsurugi

- [ ] Mitsurugi Ritual can Ritual Summon an Ourogear Reptile Ritual Monster when its own effect permits.
- [ ] Ourogear Level 4 Ritual hand effects can Ritual Summon a Mitsurugi Reptile Ritual Monster from the Deck.
- [ ] Mitsurugi monsters Tributed by the Ourogear Ritual effect receive their intended Tribute triggers.
- [ ] The resulting Ourogear engine remains usable afterward.

### DoomZ

Using official DoomZ effects that Special Summon a same-Rank WIND Machine Xyz:

- [ ] DoomZ V Five - Amalthe can Special Summon a legal Rank 4 Ourogear WIND Machine Xyz.
- [ ] DoomZ VII Seven - Elara can Special Summon a legal same-Rank Ourogear WIND Machine Xyz when Rank/Level permits.
- [ ] DoomZ XII Zero - Drastea can Special Summon a legal Rank 8 Ourogear WIND Machine Xyz.
- [ ] DoomZ attaches itself and its Equip Cards as material exactly as its official script specifies.
- [ ] A directly Special Summoned Ourogear Xyz from DoomZ does not accidentally run the Ourogear custom Xyz material-substitution procedure.
- [ ] Its normal card effects and inherited material effects work based on the materials it actually has.

## Pass criteria

The expansion is ready for ordinary play when:

1. GitHub Actions is green.
2. EDOPro starts with no script/database errors.
3. Every checkbox above that applies to the current build passes once.
4. No card performs an action that contradicts its database text.

If any runtime test fails, record the exact card, board state, action sequence, and EDOPro error text (if any). That makes the fix deterministic instead of speculative.
