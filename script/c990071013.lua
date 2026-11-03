-- Ourogear Siege Leviathan
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    Ourogear.AddXyzProcedure(c,4,4,3)
    -- Can attack each opponent's monster once, plus one bonus repeat while extra attacks apply.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ATTACK_ALL)
    e1:SetValue(s.atkallval)
    c:RegisterEffect(e1)
    -- Can attack directly once the opponent controls no monsters.
    local e1b=Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_SINGLE)
    e1b:SetCode(EFFECT_DIRECT_ATTACK)
    e1b:SetCondition(s.directcon)
    c:RegisterEffect(e1b)
    -- Attach a monster destroyed by battle
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCondition(aux.bdocon)
    e2:SetTarget(s.atttg)
    e2:SetOperation(s.attop)
    c:RegisterEffect(e2)
    -- Gains 300 ATK/DEF for each material
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetValue(function(e) return e:GetHandler():GetOverlayCount()*300 end)
    c:RegisterEffect(e3)
    local e3b=e3:Clone(); e3b:SetCode(EFFECT_UPDATE_DEFENSE); c:RegisterEffect(e3b)
    -- Once per turn, banish all opponent cards from the field, hand, and GY.
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
    e4:SetTarget(s.rmtg)
    e4:SetOperation(s.rmop)
    c:RegisterEffect(e4)
end
s.listed_series={Ourogear.SET}
function s.atkallval(e,tc)
    local c=e:GetHandler()
    local extra=0
    for _,te in ipairs({c:IsHasEffect(EFFECT_EXTRA_ATTACK)}) do
        local val=te:GetValue()
        if type(val)=="function" then val=val(te,c) end
        if val and val>extra then extra=val end
    end
    if extra<=0 then return 1 end
    -- The core otherwise keeps the attack-all "once each" restriction active
    -- through the bonus attacks. Permit only the bonus number of repeat attacks.
    local repeats=c:GetAttackAnnouncedCount()-c:GetAttackedGroupCount()
    return repeats<extra and 2 or 1
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler(); local bc=c:GetBattleTarget()
    if chk==0 then return c:IsType(TYPE_XYZ) and bc and bc:IsMonster() and bc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT) end
    Duel.SetTargetCard(bc)
    if bc:IsLocation(LOCATION_GRAVE) then Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,bc,1,1-tp,0) end
end
function s.attop(e,tp)
    local c=e:GetHandler(); local bc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and c:IsType(TYPE_XYZ) and bc and bc:IsRelateToEffect(e) then Duel.Overlay(c,bc,true) end
end
function s.directcon(e)
    local c=e:GetHandler()
    return c:GetAttackAnnouncedCount()>0 and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)==0
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local loc=LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE
    local g=Duel.GetFieldGroup(tp,0,loc)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,1-tp,loc)
end
function s.rmop(e,tp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE)
    if #g>0 then Duel.Remove(g,POS_FACEUP,REASON_EFFECT) end
end
