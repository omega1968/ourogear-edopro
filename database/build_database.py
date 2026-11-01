import sqlite3, os, textwrap
OUT=os.path.join(os.path.dirname(__file__),'..','expansion','ourogear.cdb')
OUT=os.path.abspath(OUT)
SET=0x7f0
OT=4
WIND=0x8
REPTILE=0x80000
MACHINE=0x20
TYPE_EFFECT=0x21
TYPE_RITUAL_EFFECT=0xA1
TYPE_XYZ_EFFECT=0x800021
TYPE_EQUIP_SPELL=0x40002
TYPE_FIELD_SPELL=0x80002
TYPE_CONT_SPELL=0x20002
TYPE_CONT_TRAP=0x20004
TYPE_TOKEN=0x4011
cards=[]
def add(cid,name,desc,typ,atk=0,def_=0,level=0,race=0,attr=0,strings=None):
    cards.append(dict(id=cid,name=name,desc=' '.join(desc.split()),type=typ,atk=atk,def_=def_,level=level,race=race,attr=attr,strings=strings or []))

add(21430001,'Ourogear Windscale','''
If you control a WIND Machine monster or a Token, you can Special Summon this card (from your hand). If this card is Normal or Special Summoned: You can add 1 "Ourogear" monster from your Deck to your hand, except "Ourogear Windscale". You can have your opponent randomly choose 1 card in your hand and reveal it; Special Summon 1 "Ourogear Token" (Machine/WIND/Level 4/ATK 0/DEF 0). You can only use each effect of "Ourogear Windscale" once per turn.
''',TYPE_EFFECT,1700,800,4,REPTILE,WIND,[
'Special Summon this card from your hand','Add 1 "Ourogear" monster from your Deck to your hand','Reveal 1 random card from your hand; Special Summon 1 "Ourogear Token"'])
add(21430002,'Ourogear Coilwright','''
If you control a WIND Machine monster or a Token, you can Special Summon this card (from your hand). If this card is Normal or Special Summoned: You can add 1 "Ourogear" Spell/Trap from your Deck to your hand. You can have your opponent randomly choose 1 card in your hand and reveal it; Special Summon 1 "Ourogear Token" (Machine/WIND/Level 4/ATK 0/DEF 0). You can only use each effect of "Ourogear Coilwright" once per turn.
''',TYPE_EFFECT,1500,1200,4,REPTILE,WIND,[
'Special Summon this card from your hand','Add 1 "Ourogear" Spell/Trap from your Deck to your hand','Reveal 1 random card from your hand; Special Summon 1 "Ourogear Token"'])
add(21430003,'Ourogear Driftseer','''
If you control a WIND Machine monster or a Token, you can Special Summon this card (from your hand). If this card is Normal or Special Summoned: You can draw 2 cards, then place 1 card from your hand on the bottom of the Deck. You can have your opponent randomly choose 1 card in your hand and reveal it; Special Summon 1 "Ourogear Token" (Machine/WIND/Level 4/ATK 0/DEF 0). You can only use each effect of "Ourogear Driftseer" once per turn.
''',TYPE_EFFECT,1400,1600,4,REPTILE,WIND,[
'Special Summon this card from your hand','Draw 2 cards, then place 1 card from your hand on the bottom of the Deck','Reveal 1 random card from your hand; Special Summon 1 "Ourogear Token"'])

add(21430004,'Ourogear Ritefang','''
You can Ritual Summon this card with a card effect that Ritual Summons a Reptile Ritual Monster. You can discard this card; Ritual Summon 1 Reptile Ritual Monster from your Deck, by Tributing monsters you control whose total Levels equal or exceed its Level. Once per turn (Quick Effect): You can target 1 face-up monster on the field; negate its effects until the end of this turn. You can shuffle this card from your GY into the Deck; add 1 Level 4 "Ourogear" Reptile monster from your Deck to your hand. You can only use each effect of "Ourogear Ritefang" once per turn.
''',TYPE_RITUAL_EFFECT,2000,1000,4,REPTILE,WIND,[
'Discard this card; Ritual Summon 1 Reptile Ritual Monster from your Deck','Negate 1 face-up monster until the end of this turn','Shuffle this card into the Deck; add 1 Level 4 "Ourogear" Reptile monster'])
add(21430005,'Ourogear Riteveil','''
You can Ritual Summon this card with a card effect that Ritual Summons a Reptile Ritual Monster. You can discard this card; Ritual Summon 1 Reptile Ritual Monster from your Deck, by Tributing monsters you control whose total Levels equal or exceed its Level. Once per turn (Quick Effect): You can target 1 face-up monster your opponent controls; change it to face-down Defense Position. You can shuffle this card from your GY into the Deck; add 1 "Ourogear" Spell/Trap from your Deck to your hand. You can only use each effect of "Ourogear Riteveil" once per turn.
''',TYPE_RITUAL_EFFECT,1800,1700,4,REPTILE,WIND,[
'Discard this card; Ritual Summon 1 Reptile Ritual Monster from your Deck','Change 1 opponent monster to face-down Defense Position','Shuffle this card into the Deck; add 1 "Ourogear" Spell/Trap'])
add(21430006,'Ourogear Ritebind','''
You can Ritual Summon this card with a card effect that Ritual Summons a Reptile Ritual Monster. You can discard this card; Ritual Summon 1 Reptile Ritual Monster from your Deck, by Tributing monsters you control whose total Levels equal or exceed its Level. Once per turn (Quick Effect): You can target 1 face-up monster your opponent controls; until the end of this turn, it cannot attack or be used as material for a Fusion, Synchro, Xyz, or Link Summon. You can shuffle this card from your GY into the Deck; Special Summon 1 Level 4 Reptile monster from your hand or banishment. You can only use each effect of "Ourogear Ritebind" once per turn.
''',TYPE_RITUAL_EFFECT,1900,1400,4,REPTILE,WIND,[
'Discard this card; Ritual Summon 1 Reptile Ritual Monster from your Deck','Prevent 1 opponent monster from attacking or being used as Extra Deck material','Shuffle this card into the Deck; Special Summon 1 Level 4 Reptile','This monster cannot attack or be used as Fusion, Synchro, Xyz, or Link Material'])

add(21430007,'Ourogear Aegis Basilisk','''
You can Ritual Summon this card with a card effect that Ritual Summons a Reptile Ritual Monster. Once per turn, when your opponent activates a monster effect (Quick Effect): You can negate the activation, and if you do, banish that monster. "Ourogear" monsters you control cannot be destroyed by battle.
''',TYPE_RITUAL_EFFECT,2900,2400,8,REPTILE,WIND,['Negate an opponent monster effect and banish that monster'])
add(21430008,'Ourogear Twin-Gale Naga','''
You can Ritual Summon this card with a card effect that Ritual Summons a Reptile Ritual Monster. Once per turn (Quick Effect): You can target 1 face-up card your opponent controls; negate its effects until the end of this turn, and if it is a monster, it cannot attack or be used as material for a Fusion, Synchro, Xyz, or Link Summon this turn. While you control a WIND Machine monster, each "Ourogear" monster you control can make a second attack during each Battle Phase.
''',TYPE_RITUAL_EFFECT,3000,2000,8,REPTILE,WIND,['Negate 1 face-up opponent card; if it is a monster, restrict its attacks and material use'])
add(21430009,'Ourogear Sovereign, Crown of the Endless Gale','''
You can Ritual Summon this card with a card effect that Ritual Summons a Reptile Ritual Monster. Monsters your opponent controls lose 600 ATK/DEF for each other monster they control. Once per Chain, when your opponent activates a card or effect: Your opponent must choose 1 of these effects. ● Negate that activated effect. ● Banish 1 random card from their Extra Deck face-down until the End Phase of their next turn. The activated effects of "Ourogear" monsters you control cannot be negated by your opponent.
''',TYPE_RITUAL_EFFECT,3800,3600,12,REPTILE,WIND,[
'Force your opponent to choose: negate their effect, or temporarily banish a random Extra Deck card','Negate the activated effect','Banish 1 random Extra Deck card face-down until the End Phase of their next turn','Return the temporarily banished Extra Deck card'])

xyz_shared='For this card\'s Xyz Summon, you can treat WIND Machine Tokens and WIND Machine Xyz Monsters you control as any required material. If a WIND Machine Xyz Monster is used as material, transfer its materials to this card. If a Token is used, after the Xyz Summon, attach the top card of your Deck to this card as material for each Token used. This card can be used as material for the Ritual Summon of a Reptile Ritual Monster, and if it is, treat its Rank as its Level.'
add(21430010,'Ourogear Vector Frame',f'''
2 Level 4 monsters + 1 Level 4 "Ourogear" monster. {xyz_shared} Once per turn: You can detach 2 materials from this card; add 2 "Ourogear" cards with different names from your Deck to your hand. A WIND Machine Xyz Monster that has this card as material gains 500 ATK/DEF.
''',TYPE_XYZ_EFFECT,2200,1800,4,MACHINE,WIND,['Detach 2 materials; add 2 different-named "Ourogear" cards'])
add(21430011,'Ourogear Relay Frame',f'''
1 Level 4 monster + 1 Level 4 "Ourogear" monster. {xyz_shared} Once per turn: You can detach 1 material from this card; Special Summon 1 "Ourogear Token" (Machine/WIND/Level 4/ATK 0/DEF 0), but it cannot be Tributed this turn. A WIND Machine Xyz Monster that has this card as material gains this effect. ● Once per turn, if your opponent Special Summons a monster(s): You can target 1 of those monsters; attach it to this card as material.
''',TYPE_XYZ_EFFECT,2400,2000,4,MACHINE,WIND,['Detach 1 material; Special Summon an "Ourogear Token" that cannot be Tributed this turn','Attach 1 monster your opponent just Special Summoned as material'])
add(21430012,'Ourogear Breach Frame',f'''
1 Level 4 monster + 1 Level 4 "Ourogear" monster. {xyz_shared} Once per turn: You can detach 1 material from this card, then target up to 2 cards your opponent controls; destroy them. A WIND Machine Xyz Monster that has this card as material gains this effect. ● Once per turn: You can target 1 card your opponent controls; destroy it.
''',TYPE_XYZ_EFFECT,2500,1900,4,MACHINE,WIND,['Detach 1 material; destroy up to 2 opponent cards','Destroy 1 opponent card'])
add(21430013,'Ourogear Siege Leviathan',f'''
2 Rank 4 Xyz Monsters + 1 Rank 4 "Ourogear" Xyz Monster. {xyz_shared} This card can attack all monsters your opponent controls, once each. If this card destroys an opponent's monster by battle: Attach that destroyed monster to this card as material. This card gains 300 ATK/DEF for each material attached to it. Once per turn (Quick Effect): You can detach 10 materials from this card; banish all cards your opponent controls.
''',TYPE_XYZ_EFFECT,3000,3000,8,MACHINE,WIND,['Attach the opponent monster destroyed by battle as material','Detach 10 materials; banish all cards your opponent controls'])
add(21430014,'Ourogear Dominion Ark',f'''
2 Rank 4 Xyz Monsters + 1 Rank 4 "Ourogear" Xyz Monster. {xyz_shared} Once per turn (Quick Effect): You can detach 1 material from this card, then target 1 card on the field; banish it until the End Phase. The first 2 times each turn your opponent would Special Summon a monster(s) from the Extra Deck, they must destroy 1 card they control, or that Summon is negated.
''',TYPE_XYZ_EFFECT,3200,2800,8,MACHINE,WIND,['Detach 1 material; temporarily banish 1 card on the field','Apply the Extra Deck Summon destruction tax','Destroy 1 card you control instead of having the Summon negated'])

add(21430015,'Ourogear Launch Harness','''
When this card is activated: Special Summon 1 Level 4 "Ourogear" Reptile monster from your Deck, and if you do, you can equip this card to that monster. Once per turn, while this card is equipped to a monster: You can add 1 Level 4 "Ourogear" Reptile Ritual Monster from your Deck to your hand. If the equipped monster is used as material for a Ritual or Xyz Summon: You can Special Summon 1 "Ourogear Token" (Machine/WIND/Level 4/ATK 0/DEF 0). You can only use each effect of "Ourogear Launch Harness" once per turn.
''',TYPE_EQUIP_SPELL,strings=['Special Summon 1 Level 4 "Ourogear" Reptile from your Deck','Add 1 Level 4 "Ourogear" Reptile Ritual Monster','Special Summon an "Ourogear Token" after the equipped monster is used as material','Equip this card to the Summoned monster'])
add(21430016,'Ourogear Skyforge Nexus','''
Once per turn: You can add 1 "Ourogear" card from your Deck to your hand. The first time each turn an "Ourogear" Spell/Trap you control would be destroyed by an opponent's card effect, it is not destroyed. Once per turn: You can target up to 2 "Ourogear" Continuous Spells/Traps in your GY; place them face-up in your Spell & Trap Zones. You can only use each activated effect of "Ourogear Skyforge Nexus" once per turn.
''',TYPE_FIELD_SPELL,strings=['Add 1 "Ourogear" card from your Deck to your hand','Place up to 2 "Ourogear" Continuous Spells/Traps from your GY face-up'])
add(21430017,'Ourogear Rite Circuit','''
"Ourogear" monsters you control can be treated as Level 4 or Level 8 when used for the Ritual Summon of a Reptile Ritual Monster. Once per turn (Quick Effect): You can Ritual Summon 1 "Ourogear" Ritual Monster from your hand or GY by Tributing Level 4 Reptile monsters from your Deck whose total Levels equal or exceed its Level, but you cannot Ritual Summon a monster from your GY with this effect during the turn it was sent there from the field. You can send this face-up card to the GY; Special Summon 1 "Ourogear Token" (Machine/WIND/Level 4/ATK 0/DEF 0). You can only use each activated effect of "Ourogear Rite Circuit" once per turn.
''',TYPE_CONT_SPELL,strings=['Ritual Summon an "Ourogear" Ritual Monster from your hand or GY using Deck materials','Send this card to the GY; Special Summon an "Ourogear Token"'])
add(21430018,'Ourogear Recovery Array','''
While your opponent controls more cards than you do, "Ourogear" monsters you control gain 500 ATK/DEF and cannot be targeted by your opponent's monster effects. Once per turn: You can add 1 "Ourogear" Continuous Spell/Trap from your Deck to your hand, except "Ourogear Recovery Array". You can send this face-up card to the GY; Special Summon 1 "Ourogear Token" (Machine/WIND/Level 4/ATK 0/DEF 0). You can only use each activated effect of "Ourogear Recovery Array" once per turn.
''',TYPE_CONT_SPELL,strings=['Add 1 other "Ourogear" Continuous Spell/Trap','Send this card to the GY; Special Summon an "Ourogear Token"'])
add(21430019,'Ourogear Material Loom','''
The first time each WIND Machine Xyz Monster you control would detach material to activate its effect each turn, attach the top card of your Deck to that monster as material immediately before detaching. Once per turn: You can target 3 "Ourogear" cards with different names in your GY; your opponent randomly chooses 1 of them for you to add to your hand, then shuffle the remaining 2 into the Deck. You can send this face-up card to the GY; Special Summon 1 "Ourogear Token" (Machine/WIND/Level 4/ATK 0/DEF 0). You can only use each activated effect of "Ourogear Material Loom" once per turn.
''',TYPE_CONT_SPELL,strings=['Attach the top card of the Deck before this WIND Machine Xyz detaches','Recover 1 random card from 3 different-named "Ourogear" cards','Send this card to the GY; Special Summon an "Ourogear Token"'])
add(21430020,'Ourogear Grave Harvester','''
Once per turn, if your opponent activates a card or effect in their GY: You can target 1 card in their GY; attach it to a WIND Machine Xyz Monster you control as material. Once per turn, if a card(s) leaves your opponent's GY because of their card or effect: You can target 1 other card in their GY; attach it to a WIND Machine Xyz Monster you control as material.
''',TYPE_CONT_TRAP,strings=['Attach 1 card from your opponent\'s GY after they activate an effect there','Attach 1 other card from your opponent\'s GY after a card leaves it'])
add(21430021,'Ourogear Suppression Grid','''
If your opponent Special Summons a monster(s) in Attack Position: Change those monsters to Defense Position. Monsters changed to Defense Position by this effect cannot change their battle positions while this card remains face-up on the field. While your opponent controls 4 or more Defense Position monsters, they cannot activate the effects of Defense Position monsters.
''',TYPE_CONT_TRAP)
add(21430099,'Ourogear Token','''
Special Summoned with the effect of an "Ourogear" card. This Token cannot be used as Fusion, Synchro, or Link Material.
''',TYPE_TOKEN,0,0,4,MACHINE,WIND)

os.makedirs(os.path.dirname(OUT),exist_ok=True)
if os.path.exists(OUT): os.remove(OUT)
con=sqlite3.connect(OUT)
cur=con.cursor()
cur.execute('CREATE TABLE datas (id integer primary key, ot integer, alias integer, setcode integer, type integer, atk integer, def integer, level integer, race integer, attribute integer, category integer)')
cols=', '.join(f'str{i} text' for i in range(1,17))
cur.execute(f'CREATE TABLE texts (id integer primary key, name text, desc text, {cols})')
for c in cards:
    cur.execute('INSERT INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)',(c['id'],OT,0,SET,c['type'],c['atk'],c['def_'],c['level'],c['race'],c['attr'],0))
    strings=(c['strings']+['']*16)[:16]
    cur.execute('INSERT INTO texts VALUES ('+','.join(['?']*19)+')',(c['id'],c['name'],c['desc'],*strings))
con.commit(); con.close()

# also emit deterministic SQL source
sql_path=os.path.join(os.path.dirname(__file__),'cards.sql')
def q(s): return "'"+s.replace("'","''")+"'"
with open(sql_path,'w',encoding='utf-8') as f:
    f.write('-- Generated source for ourogear.cdb\nBEGIN TRANSACTION;\n')
    for c in cards:
        f.write(f"INSERT INTO datas VALUES ({c['id']},{OT},0,{SET},{c['type']},{c['atk']},{c['def_']},{c['level']},{c['race']},{c['attr']},0);\n")
        strings=(c['strings']+['']*16)[:16]
        vals=[str(c['id']),q(c['name']),q(c['desc'])]+[q(x) for x in strings]
        f.write('INSERT INTO texts VALUES ('+','.join(vals)+');\n')
    f.write('COMMIT;\n')
print(OUT)
print('cards',len(cards))
