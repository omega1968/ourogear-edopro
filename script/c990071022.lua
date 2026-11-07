-- Ourogear Intercept Colossus
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    Ourogear.AddXyzProcedure(c,4,4,3)
    -- Negate an opponent's on-field card/effect activation and attach that card
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.negcon)
    e1:SetCost(Cost.DetachFromSelf(1))
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
    -- Attach 1 monster your opponent Special Summoned
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.attcon)
    e2:SetCost(Cost.DetachFromSelf(1))
    e2:SetTarget(s.atttg)
    e2:SetOperation(s.attop)
    c:RegisterEffect(e2)
end
s.listed_series={Ourogear.SET}
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=re:GetHandler()
    return rp~=c:GetControler() and tc and tc:IsOnField() and Duel.IsChainNegatable(ev)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CARD)
    if Duel.NegateEffect(ev) and tc and tc:IsOnField() and tc:IsRelateToEffect(e) then
        Duel.Overlay(c,tc,true)
    end
end
function s.attfilter(c,e,tp)
    return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsMonster() and not c:IsImmuneToEffect(e)
end
function s.attcon(e,tp,eg)
    return eg:IsExists(s.attfilter,1,nil,e,tp)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return eg:IsContains(chkc) and s.attfilter(chkc,e,tp) end
    if chk==0 then return eg:IsExists(s.attfilter,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
    local g=eg:FilterSelect(tp,s.attfilter,1,1,nil,e,tp)
    Duel.SetTargetCard(g)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
    local xc=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if xc:IsFaceup() and xc:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
        Duel.Overlay(xc,tc,true)
    end
end
