# Ourogear EDOPro runtime test checklist

Static validation catches database, syntax, ID, and deck-construction errors. These checks must be run inside EDOPro because they depend on the duel engine.

## Core loading

- EDOPro starts without a Lua error.
- All 21 cards and the Ourogear Token appear with the correct names, stats, types, Levels/Ranks, Attribute, and Race.
- `Ourogear-Test.ydk` opens as 40 Main / 15 Extra.

## Level 4 Effect Monsters

- Each can Special Summon itself from hand while you control a WIND Machine or Token.
- Windscale searches an Ourogear monster other than itself.
- Coilwright searches an Ourogear Spell/Trap.
- Driftseer draws 2 and places 1 hand card on the bottom of the Deck.
- Each random-reveal effect lets the opponent randomly select a hand card, reveals it, and creates exactly 1 Token.
- The Token cannot be used as Fusion, Synchro, or Link Material.

## Level 4 Ritual engine

- Each Level 4 Ritual can discard itself to Ritual Summon any Reptile Ritual Monster from the Deck using only monsters you control.
- Materials are actually Tributed and trigger appropriate Tribute/Ritual-material effects, including Mitsurugi cards.
- Ritefang/Riteveil/Ritebind field Quick Effects resolve correctly.
- Their GY effects shuffle themselves into the Deck as cost and resolve correctly.

## Rite Circuit

- Can Ritual Summon an Ourogear Ritual from hand or GY using only Level 4 Reptiles from the Deck.
- Deck materials are treated as Tributed Ritual Material and trigger appropriate Tribute effects.
- A Ritual Monster sent from the field to the GY this turn cannot be immediately Ritual Summoned back from the GY with Rite Circuit.
- A Ritual Monster sent there on a previous turn can be Ritual Summoned from the GY.
- Ourogear monsters used for a Reptile Ritual Summon can contribute Level 4 or Level 8 as appropriate.

## Custom Xyz procedure

Test all of these separately:

- Rank 4 with ordinary listed Level 4 materials.
- Rank 4 using 1 Token as a substitute.
- Rank 4 using only valid substitutes where permitted.
- Rank 8 using three Tokens.
- Rank 8 using actual Rank 4 Ourogear Xyz Monsters.
- Rank 8 using a mixture of Tokens and WIND Machine Xyz Monsters.
- A Token used for the Summon disappears and exactly 1 top-Deck card is attached for each Token used.
- An Xyz Monster used as material carries all of its existing materials upward.
- Vector/Relay/Breach inherited effects remain active on the new WIND Machine Xyz.
- DoomZ can still cheat out the matching-Rank Ourogear WIND Machine Xyz Monsters.

## Rank 4 inherited effects

- Vector grants +500 ATK/DEF while it is material of a WIND Machine Xyz.
- Relay lets the host attach 1 eligible monster from an opponent Special Summon event once per turn.
- Breach gives the host its once-per-turn targeted destruction effect.

## Rank 8 monsters

- Siege Leviathan can attack every opponent monster once each.
- A monster it destroys by battle can be attached as material.
- Its ATK/DEF changes by 300 for every attached material.
- Its board wipe cannot be activated below 10 materials and correctly detaches 10 when activated.
- Material Loom supplies the top card immediately before the first detach by each WIND Machine Xyz that turn.
- Dominion Ark temporarily banishes a field card and returns it in the End Phase.
- Dominion Ark applies its Extra Deck Summon tax only in legal summon-negation windows and only for the first 2 applicable Summons each turn.

## Level 12 Sovereign

- Each opponent monster loses 600 ATK/DEF for every other monster they control.
- Once per Chain, the opponent chooses between negating their activated effect and temporarily losing a random Extra Deck card face-down.
- The random Extra Deck card returns at the End Phase of that opponent's next turn, not the current turn when activated during their turn.
- Activated effects of face-up Ourogear monsters you control cannot be negated by the opponent.

## Spell/Trap package

- Launch Harness Special Summons from Deck, can equip itself, searches while equipped, and creates a Token when its equipped monster becomes Ritual/Xyz Material.
- Skyforge Nexus searches, protects only the first qualifying Ourogear Spell/Trap destruction each turn, and places up to 2 Continuous Ourogear S/T from GY face-up.
- Recovery Array applies its behind-on-cards bonuses and only searches Continuous Ourogear S/T.
- Material Loom performs its random 1-of-3 recovery correctly and shuffles the other 2.
- Grave Harvester responds to opponent GY activations and opponent-caused cards leaving their GY, attaching the correct card to a WIND Machine Xyz.
- Suppression Grid changes newly Special Summoned Attack Position monsters to Defense Position, locks only monsters it changed, and the lock ends permanently if that exact copy of Suppression Grid leaves the field.
- Suppression Grid prevents Defense Position monster-effect activations only while the opponent controls 4 or more Defense Position monsters.

## Cross-archetype regression

- Mitsurugi Ritual can Ritual Summon Ourogear Reptile Ritual Monsters as intended.
- Ourogear Ritual effects can Tribute Mitsurugi monsters and those Tribute effects trigger.
- DoomZ same-Rank WIND Machine Xyz effects can Special Summon Ourogear Xyz Monsters and attach their normal DoomZ materials.
- No Ourogear restriction unintentionally prevents these intended bridges.
