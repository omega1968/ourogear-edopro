-- Ourogear Siege Leviathan
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    Ourogear.AddXyzProcedure(c,8,4,3)
    -- Can attack all monsters your opponent controls, once each
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ATTACK_ALL)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    -- Attach a monster destroyed by battle
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
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
    -- Detach 10; banish your opponent's field, hand, and GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
    e4:SetCost(Cost.DetachFromSelf(10))
    e4:SetTarget(s.rmtg)
    e4:SetOperation(s.rmop)
    c:RegisterEffect(e4)
end
s.listed_series={Ourogear.SET}
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
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local loc=LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE
    local g=Duel.GetFieldGroup(tp,0,loc)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,1-tp,loc)
end
function s.rmop(e,tp)
    local loc=LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE
    local g=Duel.GetFieldGroup(tp,0,loc)
    if #g>0 then Duel.Remove(g,POS_FACEUP,REASON_EFFECT) end
end
