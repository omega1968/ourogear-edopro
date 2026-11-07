-- Ourogear Intercept Frame
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    Ourogear.AddXyzProcedure(c,4,4,2)
    -- During the opponent's turn, negate an on-field monster effect and return that monster to the hand
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.negcon)
    e1:SetCost(Cost.DetachFromSelf(1))
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
end
s.listed_series={Ourogear.SET}
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=re:GetHandler()
    return Duel.GetTurnPlayer()~=c:GetControler() and rp~=c:GetControler()
        and re:IsMonsterEffect() and tc and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup()
        and Duel.IsChainNegatable(ev)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CARD)
    if Duel.NegateEffect(ev) and tc and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end
