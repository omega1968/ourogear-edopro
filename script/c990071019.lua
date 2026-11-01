-- Ourogear Material Loom
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c); e0:SetType(EFFECT_TYPE_ACTIVATE); e0:SetCode(EVENT_FREE_CHAIN); c:RegisterEffect(e0)
    -- Before the first detach by each WIND Machine Xyz each turn, attach the top card of the Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0)); e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS); e1:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE); e1:SetRange(LOCATION_SZONE)
    e1:SetCondition(s.repcon); e1:SetOperation(s.repop); c:RegisterEffect(e1)
    -- Recover 1 of 3 differently named Ourogear cards at random
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1)); e2:SetCategory(CATEGORY_TOHAND|CATEGORY_TODECK); e2:SetType(EFFECT_TYPE_IGNITION); e2:SetProperty(EFFECT_FLAG_CARD_TARGET); e2:SetRange(LOCATION_SZONE); e2:SetCountLimit(1,{id,0})
    e2:SetTarget(s.rectg); e2:SetOperation(s.recop); c:RegisterEffect(e2)
    -- Send this card to GY; create a Token
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2)); e3:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE); e3:SetType(EFFECT_TYPE_IGNITION); e3:SetRange(LOCATION_SZONE); e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.tkcost); e3:SetTarget(s.tktg); e3:SetOperation(s.tkop); c:RegisterEffect(e3)
end
s.listed_series={Ourogear.SET}
s.listed_names={Ourogear.TOKEN}
function s.repcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return (r&REASON_COST)~=0 and ep==tp and rc:IsFaceup() and Ourogear.IsWindMachineXyz(rc)
        and rc:GetFlagEffect(Ourogear.FLAG_LOOM_USED)==0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and rc:GetOverlayCount()>=ev-1
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    rc:RegisterFlagEffect(Ourogear.FLAG_LOOM_USED,RESET_PHASE|PHASE_END,0,1)
    local use=rc:GetOverlayCount()<ev or Duel.SelectYesNo(tp,aux.Stringid(id,0))
    if use then
        local g=Duel.GetDecktopGroup(tp,1)
        if #g>0 then Duel.DisableShuffleCheck(); Duel.Overlay(rc,g) end
    end
    -- Returning false means the original detach cost is still paid normally.
    return false
end
function s.recfilter(c)
    return c:IsSetCard(Ourogear.SET) and c:IsAbleToHand()
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.recfilter(chkc)
    end
    local g=Duel.GetMatchingGroup(s.recfilter,tp,LOCATION_GRAVE,0,nil)
    if chk==0 then return g:GetClassCount(Card.GetCode)>=3 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_TARGET)
    Duel.SetTargetCard(sg)
end
function s.recop(e,tp)
    local g=Duel.GetTargetCards(e):Filter(s.recfilter,nil)
    if #g==0 then return end
    local chosen=g:RandomSelect(1-tp,1)
    local rest=g:Clone()
    rest:Sub(chosen)
    if Duel.SendtoHand(chosen,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,chosen)
    end
    if #rest>0 then
        Duel.SendtoDeck(rest,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler(); if chk==0 then return c:IsAbleToGraveAsCost() end Duel.SendtoGrave(c,REASON_COST) end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0) end
function s.tkop(e,tp) Ourogear.CreateToken(tp,e:GetHandler()) end
