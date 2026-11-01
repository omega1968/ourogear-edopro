-- Ourogear Launch Harness
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    -- Activate: Special Summon a Level 4 Ourogear Reptile, then optionally equip this card to it
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_EQUIP)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,{id,0})
    e0:SetTarget(s.acttg)
    e0:SetOperation(s.actop)
    c:RegisterEffect(e0)
    -- While equipped: search a Level 4 Ourogear Reptile Ritual Monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(function(e) return e:GetHandler():GetEquipTarget()~=nil end)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    -- If the equipped monster is used as Ritual/Xyz material: create a Token
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,{id,2})
    e2:SetCondition(s.tkcon)
    e2:SetTarget(s.tktg)
    e2:SetOperation(s.tkop)
    c:RegisterEffect(e2)
end
s.listed_series={Ourogear.SET}
s.listed_names={Ourogear.TOKEN}
function s.spfilter(c,e,tp)
    return c:IsSetCard(Ourogear.SET) and c:IsRace(RACE_REPTILE) and c:IsLevel(4)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.actop(e,tp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_SZONE) and not c:IsStatus(STATUS_LEAVE_CONFIRMED)
        and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        if Duel.Equip(tp,c,tc) then
            local el=Effect.CreateEffect(c)
            el:SetType(EFFECT_TYPE_SINGLE)
            el:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            el:SetCode(EFFECT_EQUIP_LIMIT)
            el:SetReset(RESET_EVENT|RESETS_STANDARD)
            el:SetValue(s.eqlimit)
            el:SetLabelObject(tc)
            c:RegisterEffect(el)
        end
    end
end
function s.eqlimit(e,c) return e:GetLabelObject()==c end
function s.thfilter(c)
    return c:IsSetCard(Ourogear.SET) and c:IsRace(RACE_REPTILE) and c:IsLevel(4) and c:IsRitualMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT); Duel.ConfirmCards(1-tp,g) end
end
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler(); local ec=c:GetPreviousEquipTarget()
    return c:IsPreviousLocation(LOCATION_SZONE) and c:IsReason(REASON_LOST_TARGET) and ec
        and ec:IsReason(REASON_MATERIAL) and (ec:IsReason(REASON_RITUAL) or ec:IsReason(REASON_XYZ))
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Ourogear.CanCreateToken(e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp) Ourogear.CreateToken(tp,e:GetHandler()) end
