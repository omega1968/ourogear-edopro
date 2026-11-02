-- Ourogear Aegis Basilisk
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Ourogear.RegisterRitualLeftFieldTracker(c)
    -- Negate an opponent's card or effect activation and banish that card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE|CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
    -- Each opponent's activated effect can affect at most 1 Ourogear card you control.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_ONFIELD,0)
    e2:SetTarget(s.protected)
    e2:SetValue(s.immune)
    c:RegisterEffect(e2)
    -- Reset the per-effect limiter when a new Chain begins.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(s.resetprotection)
    c:RegisterEffect(e3)
    -- Ourogear monsters inflict piercing battle damage while the opponent controls 2+ monsters.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_PIERCE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(s.piercetg)
    c:RegisterEffect(e4)
end
s.listed_series={Ourogear.SET}
Ourogear.AegisAffectedEffects=Ourogear.AegisAffectedEffects or {}
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and Duel.IsChainNegatable(ev)
        and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.protected(e,c)
    return c:IsSetCard(Ourogear.SET)
end
function s.immune(e,re)
    local tp=e:GetHandlerPlayer()
    if re:GetHandlerPlayer()==tp or not re:IsActivated() then return false end
    local affected=Ourogear.AegisAffectedEffects
    if affected[re] then return true end
    affected[re]=true
    return false
end
function s.resetprotection(e,tp,eg,ep,ev,re,r,rp)
    if ev==1 then Ourogear.AegisAffectedEffects={} end
end
function s.piercetg(e,c)
    return c:IsSetCard(Ourogear.SET)
        and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)>=2
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    local rc=re:GetHandler()
    if rc and rc:IsAbleToRemove() then Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,0,0) end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.NegateActivation(ev) then return end
    local rc=re:GetHandler()
    if rc and rc:IsRelateToEffect(re) then Duel.Remove(rc,POS_FACEUP,REASON_EFFECT) end
end
function s.damtg(e,c)
    return c:IsSetCard(Ourogear.SET) and c:GetBattleTarget()~=nil
end
