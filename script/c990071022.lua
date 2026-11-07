-- Ourogear Signalbreaker Hydra
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    Ourogear.AddXyzProcedure(c,4,4,3)
    -- Negate an effect activated from the opponent's hand or GY and shuffle its card into the Deck
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.handnegcon)
    e1:SetCost(Cost.DetachFromSelf(1))
    e1:SetOperation(s.handnegop)
    c:RegisterEffect(e1)
    -- Punish the opponent for adding cards from the Deck to the hand
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_HAND)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.searchcon)
    e2:SetCost(Cost.DetachFromSelf(1))
    e2:SetTarget(s.searchtg)
    e2:SetOperation(s.searchop)
    c:RegisterEffect(e2)
end
s.listed_series={Ourogear.SET}
function s.handnegcon(e,tp,eg,ep,ev,re,r,rp)
    local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION) or 0
    return rp==1-tp and (loc&(LOCATION_HAND|LOCATION_GRAVE))~=0 and Duel.IsChainNegatable(ev)
end
function s.handnegop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CARD)
    if Duel.NegateEffect(ev) and tc then
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
function s.searchfilter(c)
    return c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
end
function s.searchcon(e,tp,eg,ep,ev,re,r,rp)
    return ep==1-tp and eg:IsExists(s.searchfilter,1,nil)
        and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
end
function s.searchtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
end
function s.searchop(e,tp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)
        local sg=g:Select(1-tp,1,1,nil)
        Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
