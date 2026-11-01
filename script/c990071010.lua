-- Ourogear Vector Frame
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    Ourogear.AddXyzProcedure(c,4,4,3)
    -- Detach 2; add 2 differently named Ourogear cards
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(Cost.DetachFromSelf(2))
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    -- A WIND Machine Xyz Monster with this card as material gains 500 ATK/DEF
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_XMATERIAL)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(function(e) return Ourogear.IsWindMachineXyz(e:GetHandler()) end)
    e2:SetValue(500)
    c:RegisterEffect(e2)
    local e2b=e2:Clone(); e2b:SetCode(EFFECT_UPDATE_DEFENSE); c:RegisterEffect(e2b)
end
s.listed_series={Ourogear.SET}
function s.thfilter(c) return c:IsSetCard(Ourogear.SET) and not c:IsCode(id) and c:IsAbleToHand() end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    if chk==0 then return g:GetClassCount(Card.GetCode)>=2 end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp)
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    if g:GetClassCount(Card.GetCode)<2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
    if #sg==2 then Duel.SendtoHand(sg,nil,REASON_EFFECT); Duel.ConfirmCards(1-tp,sg) end
end
