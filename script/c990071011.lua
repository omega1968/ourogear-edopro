-- Ourogear Relay Frame
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    Ourogear.AddXyzProcedure(c,4,4,2)
    -- Detach 1; Special Summon an Ourogear Token
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(Cost.DetachFromSelf(1))
    e1:SetTarget(s.tktg)
    e1:SetOperation(s.tkop)
    c:RegisterEffect(e1)
    -- Granted effect: attach 1 monster your opponent just Special Summoned
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_XMATERIAL|EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1)
    e2:SetCondition(s.attcon)
    e2:SetTarget(s.atttg)
    e2:SetOperation(s.attop)
    c:RegisterEffect(e2)
end
s.listed_series={Ourogear.SET}
s.listed_names={Ourogear.TOKEN}
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp)
    Ourogear.CreateToken(tp,e:GetHandler())
end
function s.attfilter(c,e,tp)
    return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsMonster() and not c:IsImmuneToEffect(e)
end
function s.attcon(e,tp,eg)
    return Ourogear.IsWindMachineXyz(e:GetHandler()) and eg:IsExists(s.attfilter,1,nil,e,tp)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return eg:IsContains(chkc) and s.attfilter(chkc,e,tp) end
    if chk==0 then return eg:IsExists(s.attfilter,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
    local g=eg:FilterSelect(tp,s.attfilter,1,1,nil,e,tp)
    Duel.SetTargetCard(g)
end
function s.attop(e,tp)
    local xc=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if xc:IsFaceup() and xc:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
        Duel.Overlay(xc,tc,true)
    end
end
