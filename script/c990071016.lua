-- Ourogear Skyforge Nexus
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE); e0:SetCode(EVENT_FREE_CHAIN); c:RegisterEffect(e0)
    -- Search any Ourogear card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0)); e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION); e1:SetRange(LOCATION_FZONE); e1:SetCountLimit(1)
    e1:SetTarget(s.thtg); e1:SetOperation(s.thop); c:RegisterEffect(e1)
    -- The first Ourogear Spell/Trap that would be destroyed by an opponent's effect each turn is not destroyed
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD); e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT); e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_ONFIELD,0); e2:SetTarget(s.indtg); e2:SetCountLimit(1); e2:SetValue(s.indval); c:RegisterEffect(e2)
    -- Place up to 2 Ourogear Continuous Spells/Traps from GY face-up
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1)); e3:SetCategory(CATEGORY_LEAVE_GRAVE)
    e3:SetType(EFFECT_TYPE_IGNITION); e3:SetProperty(EFFECT_FLAG_CARD_TARGET); e3:SetRange(LOCATION_FZONE); e3:SetCountLimit(1)
    e3:SetTarget(s.rectg); e3:SetOperation(s.recop); c:RegisterEffect(e3)
end
s.listed_series={Ourogear.SET}
function s.thfilter(c) return c:IsSetCard(Ourogear.SET) and c:IsAbleToHand() end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK) end
function s.thop(e,tp) Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND); local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil); if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT); Duel.ConfirmCards(1-tp,g) end end
function s.indtg(e,c) return c:IsSpellTrap() and c:IsSetCard(Ourogear.SET) end
function s.indval(e,re,r,rp) return (r&REASON_EFFECT)~=0 and rp==1-e:GetHandlerPlayer() end
function s.recfilter(c) return Ourogear.IsOurogearContinuousST(c) end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.recfilter(chkc) end
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if chk==0 then return ft>0 and Duel.IsExistingTarget(s.recfilter,tp,LOCATION_GRAVE,0,1,nil) end
    local ct=math.min(2,ft)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectTarget(tp,s.recfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,tp,LOCATION_GRAVE)
end
function s.recop(e,tp)
    local g=Duel.GetTargetCards(e)
    for tc in g:Iter() do
        if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then break end
        if tc:IsRelateToEffect(e) and tc:IsSpellTrap() then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
    end
end
