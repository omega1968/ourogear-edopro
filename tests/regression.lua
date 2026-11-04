-- Focused callback regressions. These use controlled API doubles, not a simulated duel.
-- Usage: lua5.3 tests/regression.lua <ProjectIgnis/CardScripts directory> [script directory]
local upstream=arg[1] or 'upstream-cardscripts'
local scripts=arg[2] or 'script'
Duel={LoadScript=function() end}
dofile(upstream..'/constant.lua')
local failures,total=0,0
local select_index=1
local function test(name,fn)
    total=total+1
    local ok,err=pcall(fn)
    if not ok then failures=failures+1 end
    print((ok and 'PASS ' or 'FAIL ')..name..(ok and '' or ': '..tostring(err)))
end
local function eq(a,b) assert(a==b,tostring(a)..' ~= '..tostring(b)) end
local function group(items)
    local g=items or {}
    function g:Iter() local i=0; return function() i=i+1; return self[i] end end
    function g:Filter(fn,excluded,...)
        local out=group(); for _,c in ipairs(self) do if c~=excluded and fn(c,...) then out[#out+1]=c end end; return out
    end
    function g:FilterCount(fn,excluded,...) return #self:Filter(fn,excluded,...) end
    function g:Merge(other) for _,c in ipairs(other) do local found=false; for _,v in ipairs(self) do if v==c then found=true end end; if not found then self[#self+1]=c end end end
    function g:RandomSelect() return group({self[1]}) end
    function g:Select() return group({self[select_index]}) end
    function g:GetFirst() return self[1] end
    function g:Includes(c) for _,v in ipairs(self) do if v==c then return true end end; return false end
    function g:IsContains(c) return self:Includes(c) end
    function g:IsExists(fn,n,excluded,...) return self:FilterCount(fn,excluded,...)>=n end
    return g
end
Card={}
function Card.GetRitualLevel(c) return c.normal_level or 0 end
function Card:IsSetCard(set) return self.ourogear==true end
function Card:IsType(t) return ((self.type or 0)&t)~=0 end
function Card:IsRace(r) return ((self.race or 0)&r)~=0 end
function Card:IsAttribute(a) return ((self.attribute or 0)&a)~=0 end
function Card:IsControler(tp) return self.player==tp end
function Card:GetControler() return self.player end
function Card:GetEquipTarget() return self.equip_target end
function Card:GetPreviousEquipTarget() return self.previous_equip_target end
function Card:IsLocation(loc) return ((self.location or 0)&loc)~=0 end
function Card:IsFaceup() return self.faceup~=false end
function Card:GetRank() return self.rank or 0 end
function Card:IsCode(id) return self.id==id end
function Card:IsHasEffect(code) return table.unpack((self.applied or {})[code] or {}) end
function Card:IsStatus() return self.forbidden or false end
function Card:IsForbidden() return self.forbidden or false end
function Card:CheckUniqueOnField() return not self.unique_blocked end
function Card:IsAbleToHand() return true end
function Card:IsAbleToDeckAsCost() return true end
function Card:IsSpell() return self:IsType(TYPE_SPELL) end
function Card:IsTrap() return self:IsType(TYPE_TRAP) end
function Card:IsSpellTrap() return self:IsType(TYPE_SPELL|TYPE_TRAP) end
function Card:IsMonster() return self:IsType(TYPE_MONSTER) or self:IsType(TYPE_TOKEN) end
function Card:IsLevel(lv) return self.normal_level==lv end
function Card:IsRank(rank) return self.rank==rank end
function Card:IsCanBeSpecialSummoned() return not self.block_summon end
function Card:IsCanBeXyzMaterial() return not self:IsType(TYPE_TOKEN) and not self.block_material end
function Card:IsImmuneToEffect() return false end
function Card:IsRelateToEffect() return true end
function Card:GetOverlayCount() return self.overlays or 0 end
function Card:GetAttackAnnouncedCount() return self.attack_announced or 0 end
function Card:GetAttackedGroupCount() return self.attacked_group_count or 0 end
function Card:GetFlagEffect(code) return (self.flags or {})[code] or 0 end
function Card:RegisterFlagEffect(code) self.flags=self.flags or {}; self.flags[code]=1 end
function Card:RegisterEffect(e) self.effects=self.effects or {}; table.insert(self.effects,e) end
function Card:EnableReviveLimit() end
function Card:IsPreviousLocation(loc) return self.previous==loc end
function Card:IsReason(r) return ((self.reason or 0)&r)~=0 end
function Card:GetReasonEffect() return self.reason_effect end
local function card(values) return setmetatable(values or {},{__index=Card}) end
local effects={}
Effect={CreateEffect=function(c)
    local e={handler=c}
    return setmetatable(e,{__index=function(_,key)
        if key=='Clone' then return function(self) local out=Effect.CreateEffect(self.handler); for k,v in pairs(self) do out[k]=v end; return out end end
        if key=='GetHandler' then return function(self) return self.handler end end
        if key=='GetHandlerPlayer' then return function(self) return self.handler.player or 0 end end
        if key:sub(1,3)=='Set' then return function(self,v) self[key:sub(4)]=v end end
        if key:sub(1,3)=='Get' then return function(self) return self[key:sub(4)] end end
    end})
end}
aux={Stringid=function(id,n) return n end, GlobalCheck=function(s,fn) if not s.global then s.global=true;fn() end end}
-- Varargs cannot be captured directly in a nested function on Lua 5.3.
aux.FilterBoolFunction=function(fn,...) local args={...}; return function(c) return fn(c,table.unpack(args)) end end
Cost={DetachFromSelf=function() return function() end end}
Ritual={Target=function() return function() end end,Operation=function() return function() end end}
Auxiliary=aux
local registered={}
local material_calls={}
Duel={GetRitualMaterial=function(tp,check_level)
    material_calls[#material_calls+1]=check_level
    return check_level==false and group({material_xyz,material_link}) or group({material_normal})
end,RegisterEffect=function(e) registered[#registered+1]=e end}
dofile(scripts..'/ourogear.lua')
local functions,cards={},{}
for i=1,21 do
    local id=990071000+i
    local s={}; GetID=function() return s,id end
    dofile(scripts..'/c'..id..'.lua')
    local c=card({id=id,player=0}); s.initial_effect(c)
    functions[i],cards[i]=s,c
end
local function effect_for(i,code)
    for _,e in ipairs(cards[i].effects) do if e.Code==code then return e end end
end
local e=Effect.CreateEffect(card({player=0}))
Duel.GetFieldGroupCount=function(tp,selfloc,opploc) assert(tp~=nil,'missing player'); return opploc==LOCATION_ONFIELD and 3 or 1 end
Duel.GetMatchingGroupCount=function(fn,tp) assert(tp~=nil,'missing player'); return 4 end
Duel.IsExistingMatchingCard=function(fn,tp) assert(tp~=nil,'missing player'); return true end
test('Naga field condition gets controller from effect',function() eq(functions[8].atkcon(e),true) end)
test('Recovery Array aura requires both a WIND Machine Xyz and a Reptile Ritual',function()
    local boost=effect_for(18,EFFECT_UPDATE_ATTACK)
    assert(boost and boost.Condition==functions[18].supportcon)
    local saved=Duel.IsExistingMatchingCard
    local wind_xyz=card({type=TYPE_XYZ,attribute=ATTRIBUTE_WIND,race=RACE_MACHINE,faceup=true})
    local reptile_ritual=card({type=TYPE_RITUAL,race=RACE_REPTILE,faceup=true})
    local field=group({wind_xyz,reptile_ritual})
    Duel.IsExistingMatchingCard=function(fn,tp,loc,opp,n,ex)
        return field:IsExists(fn,n,ex)
    end
    eq(functions[18].supportcon(e),true)
    field=group({wind_xyz})
    eq(functions[18].supportcon(e),false)
    field=group({reptile_ritual})
    eq(functions[18].supportcon(e),false)
    Duel.IsExistingMatchingCard=saved
end)
test('Skyforge protection excludes Skyforge itself',function()
    local protection=effect_for(16,EFFECT_INDESTRUCTABLE_COUNT)
    eq(functions[16].indtg(protection,protection:GetHandler()),false)
    eq(functions[16].indtg(protection,card({ourogear=true,type=TYPE_SPELL|TYPE_CONTINUOUS})),true)
end)
test('Suppression Grid field condition gets controller from effect',function() eq(functions[21].lockcon(e),true) end)
local banished=0
Duel.NegateActivation=function() return false end
Duel.Remove=function() banished=banished+1; return 1 end
local re={GetHandler=function() return card() end}
test('Aegis does not banish after unsuccessful negation',function() banished=0; functions[7].negop(e,0,nil,0,1,re); eq(banished,0) end)
Duel.NegateActivation=function() return true end
test('Aegis banishes after successful negation',function() banished=0; functions[7].negop(e,0,nil,0,1,re); eq(banished,1) end)
test('Aegis protection stays stable for repeated checks of one card',function()
    local immunity=Effect.CreateEffect(card({player=0}))
    local opponent_effect={GetHandlerPlayer=function() return 1 end,IsActivated=function() return true end}
    local allowed,blocked=card({ourogear=true}),card({ourogear=true})
    Ourogear.AegisAffectedEffects={}
    eq(functions[7].immune(immunity,opponent_effect,allowed),false)
    eq(functions[7].immune(immunity,opponent_effect,allowed),false)
    eq(functions[7].immune(immunity,opponent_effect,blocked),true)
end)
test('Aegis protection resets for each activated effect and Chain',function()
    local immunity=Effect.CreateEffect(card({player=0}))
    local opponent_effect={GetHandlerPlayer=function() return 1 end,IsActivated=function() return true end}
    local allowed,blocked=card({ourogear=true}),card({ourogear=true})
    Ourogear.AegisAffectedEffects={}
    eq(functions[7].immune(immunity,opponent_effect,allowed),false)
    functions[7].resetprotection(immunity,0,nil,0,2,opponent_effect,0,1)
    eq(functions[7].immune(immunity,opponent_effect,blocked),false)
    functions[7].endprotection(immunity,0,nil,0,0,nil,0,0)
    eq(functions[7].immune(immunity,opponent_effect,allowed),false)
end)
local hand=group({card()}); local reveals=0
Duel.GetFieldGroup=function() return hand end
Duel.ConfirmCards=function() reveals=reveals+1 end
Duel.ShuffleHand=function() end
Duel.GetLocationCount=function() return 1 end
Duel.GetLocationCountFromEx=function() return 1 end
local token_allowed=true
Duel.IsPlayerCanSpecialSummonMonster=function() return token_allowed end
for i=1,3 do
    test('starter '..i..' reveals as activation cost',function()
        local te=cards[i].effects[#cards[i].effects]; assert(te.Cost,'no reveal cost'); reveals=0
        eq(te.Cost(e,0,nil,0,0,nil,0,0,0),true); eq(reveals,0)
        te.Cost(e,0,nil,0,0,nil,0,0,1); eq(reveals,1)
    end)
end
test('Token activation prohibited under summon lock',function() token_allowed=false; eq(functions[1].tktg(e,0,nil,0,0,nil,0,0,0),false); token_allowed=true end)
test('Token activation legal with space and permission',function() eq(functions[1].tktg(e,0,nil,0,0,nil,0,0,0),true) end)
local vector_normal=card({normal_level=4,player=0,location=LOCATION_MZONE})
local vector_ourogear=card({normal_level=4,ourogear=true,player=0,location=LOCATION_MZONE})
local vector_generic=card({normal_level=4,player=0,location=LOCATION_MZONE})
test('Vector Frame accepts two Level 4s with an Ourogear and rejects two generic monsters',function()
    eq(Ourogear.ValidXyzGroup(group({vector_normal,vector_ourogear}),cards[10],0,4,4,2),true)
    eq(Ourogear.ValidXyzGroup(group({vector_normal,vector_generic}),cards[10],0,4,4,2),false)
    eq(Ourogear.ValidXyzGroup(group({vector_ourogear}),cards[10],0,4,4,2),false)
end)
test('Siege attacks every monster twice while Naga grants an extra attack',function()
    local leviathan=cards[13]
    local attack_all=Effect.CreateEffect(leviathan)
    local naga_bonus=Effect.CreateEffect(cards[8])
    naga_bonus:SetValue(1)
    leviathan.applied={[EFFECT_EXTRA_ATTACK]={naga_bonus}}
    for _,counts in ipairs({{0,0},{3,3},{6,3},{9,6}}) do
        leviathan.attack_announced=counts[1]
        leviathan.attacked_group_count=counts[2]
        eq(functions[13].atkallval(attack_all,card()),2)
    end
    leviathan.applied={}
    eq(functions[13].atkallval(attack_all,card()),1)
end)
local siege_old_count,siege_old_group,siege_old_info,siege_old_remove=Duel.GetFieldGroupCount,Duel.GetFieldGroup,Duel.SetOperationInfo,Duel.Remove
test('Siege full banish requires its detach-10 cost',function()
    local full_banish=effect_for(13,EVENT_FREE_CHAIN)
    assert(full_banish and full_banish.Cost)
end)
test('Siege can attack directly whenever the opponent has no monsters',function()
    local monsters=0
    Duel.GetFieldGroupCount=function() return monsters end
    local direct=Effect.CreateEffect(cards[13])
    cards[13].attack_announced=0
    eq(functions[13].directcon(direct),true)
    cards[13].attack_announced=1
    eq(functions[13].directcon(direct),true)
    monsters=1
    eq(functions[13].directcon(direct),false)
    local loc=LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE
    local victims=group({card(),card(),card()})
    Duel.GetFieldGroup=function(tp,own,opp) eq(own,0); eq(opp,loc); return victims end
    local info
    Duel.SetOperationInfo=function(...) info={...} end
    local removed=0
    Duel.Remove=function(g,pos,reason) removed=#g; eq(pos,POS_FACEUP); eq(reason,REASON_EFFECT); return removed end
    eq(functions[13].rmtg(e,0,nil,0,0,nil,0,0,0),true)
    functions[13].rmtg(e,0,nil,0,0,nil,0,0,1)
    eq(info[2],CATEGORY_REMOVE)
    eq(info[6],loc)
    functions[13].rmop(e,0)
    eq(removed,#victims)
end)
Duel.GetFieldGroupCount,Duel.GetFieldGroup,Duel.SetOperationInfo,Duel.Remove=siege_old_count,siege_old_group,siege_old_info,siege_old_remove
material_normal=card({normal_level=4}); material_xyz=card({type=TYPE_XYZ,ourogear=true,player=0,location=LOCATION_MZONE,rank=8}); material_link=card({type=TYPE_LINK,player=0,location=LOCATION_MZONE})
local base_ritual_effect=Effect.CreateEffect(material_xyz)
base_ritual_effect:SetValue(function() return 8 end)
local base_ritual_effects={[EFFECT_RITUAL_LEVEL]={base_ritual_effect}}
material_xyz.applied=base_ritual_effects
test('Ritual pool includes Ourogear Xyz but excludes ordinary Links',function() local g=Duel.GetRitualMaterial(0); eq(#g,2); eq(g[2],material_xyz) end)
local reptile=card({race=RACE_REPTILE}); local warrior=card({race=RACE_WARRIOR})
test('Ourogear Xyz provides Rank for Reptile Ritual',function() eq(material_xyz:GetRitualLevel(reptile),8) end)
test('Ourogear Xyz does not provide Level for other Ritual races',function() eq(material_xyz:GetRitualLevel(warrior),0) end)
test('Normal Ritual Levels remain unchanged',function() eq(material_normal:GetRitualLevel(reptile),4) end)
local circuit=effect_for(17,EFFECT_RITUAL_LEVEL)
test('Rite Circuit only changes Levels for Reptile Rituals',function() eq(circuit.Value(circuit,warrior),0); eq(circuit.Value(circuit,reptile),(4<<16)|8) end)
test('Rite Circuit overrides Xyz Rank in Ritual lookup',function() material_xyz.applied={[EFFECT_RITUAL_LEVEL]={circuit}}; eq(material_xyz:GetRitualLevel(reptile),(4<<16)|8); material_xyz.applied=base_ritual_effects end)
local token=card({type=TYPE_TOKEN,attribute=ATTRIBUTE_WIND,race=RACE_MACHINE})
test('WIND Machine Token substitute is allowed normally',function() eq(Ourogear.CanUseAsXyzMaterial(token,material_xyz,0),true) end)
test('Token substitution respects material locks',function()
    local lock=Effect.CreateEffect(token); lock:SetValue(function(_,xyz,sumtype,tp) eq(sumtype,SUMMON_TYPE_XYZ);eq(tp,0);return true end)
    token.applied={[EFFECT_CANNOT_BE_MATERIAL]={lock}}; eq(Ourogear.CanUseAsXyzMaterial(token,material_xyz,0),false); token.applied=nil
end)
test('Token substitution respects Forbidden status',function() token.forbidden=true; eq(Ourogear.CanUseAsXyzMaterial(token,material_xyz,0),false);token.forbidden=false end)
test('Xyz supplied group cannot bypass material requirements',function()
    local invalid=group({card({type=TYPE_MONSTER,normal_level=7}),card({type=TYPE_MONSTER,normal_level=4,ourogear=true})})
    eq(Ourogear.ValidXyzGroup(invalid,material_xyz,0,4,4,2),false)
end)
local xc=card({type=TYPE_XYZ,attribute=ATTRIBUTE_WIND,race=RACE_MACHINE,overlays=9})
local loomre={GetHandler=function() return xc end,IsActivated=function() return true end}
local attached=0
Duel.GetDecktopGroup=function() return group({card()}) end
Duel.DisableShuffleCheck=function() end
Duel.Overlay=function() attached=attached+1 end
Duel.SelectYesNo=function() error('duplicate replacement prompt') end
test('Loom supports one-short detach-10 cost',function() eq(functions[19].repcon(e,0,nil,0,10,loomre,REASON_COST,0),true) end)
test('Loom replacement handles packed min/max and adds before full detach',function() attached=0; eq(functions[19].repop(e,0,nil,0,10|(10<<16),loomre,REASON_COST,0),0); eq(attached,1) end)
test('Loom cannot apply twice to same Xyz this turn',function() eq(functions[19].repcon(e,0,nil,0,1,loomre,REASON_COST,0),false) end)
test('Declining Loom still consumes first detach opportunity',function()
    xc.flags={}; local detached=card({previous=LOCATION_OVERLAY,reason=REASON_COST,reason_effect=loomre})
    functions[19].trackdetach(e,0,group({detached}));eq(xc:GetFlagEffect(Ourogear.FLAG_LOOM_USED),1)
end)
test('Relay inherited attach does not target',function() local te; for _,v in ipairs(cards[11].effects) do if (v.Type&EFFECT_TYPE_XMATERIAL)~=0 then te=v end end; assert(te); eq(te.Property&EFFECT_FLAG_CARD_TARGET,0) end)
test('Relay cannot attach Tokens',function() token.player=1;token.location=LOCATION_MZONE;eq(functions[11].attfilter(token,e,0),false) end)
test('Siege battle attach is mandatory',function() eq(effect_for(13,EVENT_BATTLE_DESTROYING).Type&EFFECT_TYPE_TRIGGER_F,EFFECT_TYPE_TRIGGER_F) end)
test('Harness material Token trigger is mandatory',function() eq(effect_for(15,EVENT_TO_GRAVE).Type&EFFECT_TYPE_TRIGGER_F,EFFECT_TYPE_TRIGGER_F) end)
test('Harness trigger activates when another effect equips it',function()
    local harness=cards[15]
    harness.equip_target=card({id=777,player=0})
    eq(functions[15].eqspcon(Effect.CreateEffect(harness),0,nil),true)
    harness.equip_target=nil
end)
test('Harness watcher creates a Token when Drastea overlays it with its Xyz material',function()
    local harness=card({id=990071015,player=0,location=LOCATION_OVERLAY,previous=LOCATION_SZONE,reason=REASON_XYZ})
    local target=card({id=92472273,player=0,location=LOCATION_OVERLAY,reason=REASON_XYZ})
    harness.previous_equip_target=target
    local created=0
    local saved=Ourogear.CreateLaunchHarnessToken
    Ourogear.CreateLaunchHarnessToken=function(tp,source)
        eq(tp,0); eq(source,harness); created=created+1
    end
    functions[15].ovop(e,0,group({harness}),0,0,nil,0,0)
    eq(created,1)
    Ourogear.CreateLaunchHarnessToken=saved
end)
test('Harness accepts effect-based Xyz material reason without REASON_MATERIAL',function()
    local harness=cards[15]
    local target=card({reason=REASON_XYZ,previous=LOCATION_MZONE})
    harness.GetPreviousEquipTarget=function() return target end
    harness.previous=LOCATION_SZONE
    harness.reason=0
    eq(functions[15].tkcon(Effect.CreateEffect(harness),0),true)
    harness.GetPreviousEquipTarget=nil
    harness.previous=nil
    harness.reason=nil
end)
test('Ritual pool forwards a real true default to native API',function()
    material_calls={}; Duel.GetRitualMaterial(0); eq(material_calls[1],true)
end)
test('Negated Xyz cannot use its own Ritual Level effect',function()
    material_xyz.applied=nil; eq(material_xyz:GetRitualLevel(reptile),0)
    material_xyz.applied=base_ritual_effects
end)
test('Ritefang cannot search itself after its shuffle cost',function()
    local fang=card({id=990071004,type=TYPE_MONSTER|TYPE_RITUAL,ourogear=true,race=RACE_REPTILE,normal_level=4,location=LOCATION_GRAVE})
    local fe=Effect.CreateEffect(fang)
    local saved=Duel.IsExistingMatchingCard
    Duel.IsExistingMatchingCard=function() return false end
    eq(functions[4].thtg(fe,0,nil,0,0,nil,0,0,0),false)
    Duel.IsExistingMatchingCard=saved
end)
test('Skyforge lets controller choose when only one restoration fits',function()
    local first=card({type=TYPE_SPELL|TYPE_CONTINUOUS,ourogear=true})
    local second=card({type=TYPE_TRAP|TYPE_CONTINUOUS,ourogear=true})
    local saved_count=Duel.GetLocationCount
    local space,placed=1,nil
    Duel.GetLocationCount=function() return space end
    Duel.Hint=function() end
    Duel.GetTargetCards=function() return group({first,second}) end
    Duel.MoveToField=function(c) placed=c; space=space-1; return true end
    select_index=2
    functions[16].recop(e,0)
    eq(placed,second)
    select_index=1; Duel.GetLocationCount=saved_count
end)
test('Skyforge excludes Forbidden and uniqueness-blocked cards',function()
    local c=card({type=TYPE_SPELL|TYPE_CONTINUOUS,ourogear=true,forbidden=true})
    eq(functions[16].recfilter(c,0),false)
    c.forbidden=false; c.unique_blocked=true
    eq(functions[16].recfilter(c,0),false)
end)
test('Searches reject same-name copies and generic monsters',function()
    for _,i in ipairs({1,4,10,16}) do
        local same=card({id=990071000+i,ourogear=true,type=TYPE_MONSTER,race=RACE_REPTILE,normal_level=4})
        eq(functions[i].thfilter(same),false)
        same.id=123; same.ourogear=false
        eq(functions[i].thfilter(same),false)
        same.ourogear=true
        eq(functions[i].thfilter(same),true)
    end
end)
test('Ritebind still summons an unrelated non-WIND Level 4 Reptile',function()
    local external=card({id=123,type=TYPE_MONSTER,race=RACE_REPTILE,attribute=ATTRIBUTE_EARTH,normal_level=4,location=LOCATION_HAND})
    eq(functions[6].spfilter(external,e,0),true)
    external.normal_level=8
    eq(functions[6].spfilter(external,e,0),false)
end)
test('Relay Token has no extra Tribute restriction',function()
    local create=Ourogear.CreateToken
    local made=card({type=TYPE_TOKEN})
    Ourogear.CreateToken=function() return made end
    functions[11].tkop(e,0)
    Ourogear.CreateToken=create
    for _,te in ipairs(made.effects or {}) do
        assert(te.Code~=EFFECT_UNRELEASABLE_SUM and te.Code~=EFFECT_UNRELEASABLE_NONSUM)
    end
end)
print(string.format('%d/%d callback regressions passed',total-failures,total))
if failures>0 then os.exit(1) end
