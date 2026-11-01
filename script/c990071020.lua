-- Ourogear Grave Harvester
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c); e0:SetType(EFFECT_TYPE_ACTIVATE); e0:SetCode(EVENT_FREE_CHAIN); c:RegisterEffect(e0)
    -- If opponent activates a card/effect in their GY, attach a card from their GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0)); e1:SetType(EFFECT_TYPE_QUICK_O); e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_CHAINING); e1:SetRange(LOCATION_SZONE); e1:SetCountLimit(1); e1:SetCondition(s.chaincon); e1:SetTarget(s.atttg); e1:SetOperation(s.attop); c:RegisterEffect(e1)
    -- If a card leaves opponent's GY because of their card/effect, attach another card from their GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1)); e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O); e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_LEAVE_GRAVE); e2:SetRange(LOCATION_SZONE); e2:SetCountLimit(1); e2:SetCondition(s.leavecon); e2:SetTarget(s.atttg); e2:SetOperation(s.attop); c:RegisterEffect(e2)
end
function s.xyzfilter(c) return c:IsFaceup() and Ourogear.IsWindMachineXyz(c) end
function s.chaincon(e,tp,eg,ep,ev,re,r,rp)
    local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
    return rp==1-tp and (loc&LOCATION_GRAVE)~=0
end
function s.leavecon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c)
        return c:IsPreviousControler(1-tp) and c:IsReason(REASON_EFFECT)
            and c:GetReasonPlayer()==1-tp and c:GetReasonEffect()~=nil
    end,1,nil)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_GRAVE,1,nil)
        and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
    local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_GRAVE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,1-tp,LOCATION_GRAVE)
end
function s.attop(e,tp)
    local tc=Duel.GetFirstTarget(); if not tc or not tc:IsRelateToEffect(e) then return end
    local xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
    if #xg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
    local xc=xg:Select(tp,1,1,nil):GetFirst()
    if xc then Duel.Overlay(xc,tc,true) end
end
