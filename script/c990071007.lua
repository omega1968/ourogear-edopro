-- Ourogear Aegis Basilisk
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Ourogear.RegisterRitualLeftFieldTracker(c)
    -- Negate an opponent's card/effect activation and banish that card
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
    -- Each opponent's card effect can affect at most 1 Ourogear card you control
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.protcon)
    e2:SetOperation(s.protop)
    c:RegisterEffect(e2)
    -- If the opponent controls 2 or more monsters, Ourogear monsters inflict piercing damage
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_PIERCE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetCondition(s.piercecon)
    e3:SetTarget(function(e,tc) return tc:IsSetCard(Ourogear.SET) end)
    c:RegisterEffect(e3)
end
s.listed_series={Ourogear.SET}
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and Duel.IsChainNegatable(ev)
        and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    local rc=re:GetHandler()
    if rc and rc:IsAbleToRemove() then Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,0,0) end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev)==0 then return end
    local rc=re:GetHandler()
    if rc and rc:IsRelateToEffect(re) then Duel.Remove(rc,POS_FACEUP,REASON_EFFECT) end
end
function s.protcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp
end
function s.protop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_ONFIELD,0,nil,Ourogear.SET)
    if #g<=1 then return end
    -- Leave one card able to be affected; the opponent's effect is blocked on the rest.
    local allowed=g:GetFirst()
    g:Remove(allowed)
    for tc in g:Iter() do
        local te=re
        local imm=Effect.CreateEffect(e:GetHandler())
        imm:SetType(EFFECT_TYPE_SINGLE)
        imm:SetCode(EFFECT_IMMUNE_EFFECT)
        imm:SetValue(function(ie,ce) return ce==te end)
        imm:SetReset(RESET_CHAIN)
        tc:RegisterEffect(imm,true)
    end
end
function s.piercecon(e,tp)
    return Duel.GetMatchingGroupCount(Card.IsMonster,tp,0,LOCATION_MZONE,nil)>=2
end
