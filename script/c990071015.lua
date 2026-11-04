-- Ourogear Launch Harness
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    -- Declare this as a valid generic Equip Spell target for effects that equip directly from the Deck (e.g. Drastea).
    local el=Effect.CreateEffect(c)
    el:SetType(EFFECT_TYPE_SINGLE)
    el:SetCode(EFFECT_EQUIP_LIMIT)
    el:SetValue(1)
    c:RegisterEffect(el)
    -- Activate: Special Summon a Level 4 Ourogear Reptile, then optionally equip to any face-up monster you control
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
    e2:SetCondition(s.tkcon)
    e2:SetTarget(s.tktg)
    e2:SetOperation(s.tkop)
    c:RegisterEffect(e2)
    -- If another card effect equips this card: resolve the shared activation/equip summon effect.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,4))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_EQUIP)
    e3:SetCountLimit(1,{id,0})
    e3:SetCondition(s.eqspcon)
    e3:SetTarget(s.eqsp_tg)
    e3:SetOperation(s.eqsp_op)
    c:RegisterEffect(e3)
    -- Watch effect-based Xyz conversions that attach this Equip Spell directly as material.
    aux.GlobalCheck(s,function()
        local ge=Effect.CreateEffect(c)
        ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
        ge:SetCode(EVENT_MOVE)
        ge:SetOperation(s.ovop)
        Duel.RegisterEffect(ge,0)
    end)
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
        and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local tg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
        local target=tg:GetFirst()
        if target and c:IsRelateToEffect(e) and c:IsLocation(LOCATION_SZONE) then
            -- Mark our own optional equip so it does not also trigger this effect.
            c:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD,0,1)
            Duel.Equip(tp,c,target)
        end
    end
end
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
    if not c:IsPreviousLocation(LOCATION_SZONE) or not ec then return false end
    -- Standard Ritual materials carry REASON_MATERIAL|REASON_RITUAL. DoomZ's effect-based
    -- Xyz line may mark the equipped monster with REASON_XYZ without REASON_MATERIAL.
    local ritual_material=ec:IsReason(REASON_MATERIAL) and ec:IsReason(REASON_RITUAL)
    local xyz_material=ec:IsReason(REASON_XYZ)
    return ritual_material or xyz_material
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Ourogear.CanCreateLaunchHarnessToken(tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp) Ourogear.CreateLaunchHarnessToken(tp,e:GetHandler()) end

function s.eqspcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Suppress the trigger from this card's own activation effect.
    if c:GetFlagEffect(id+100)>0 then
        c:ResetFlagEffect(id+100)
        return false
    end
    return true
end
function s.eqsp_tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.eqsp_op(e,tp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end

function s.ovop(e,tp,eg,ep,ev,re,r,rp)
    if not eg then return end
    for tc in eg:Iter() do
        if tc:IsCode(id) and tc:IsPreviousLocation(LOCATION_SZONE) and tc:IsLocation(LOCATION_OVERLAY) then
            local ec=tc:GetPreviousEquipTarget()
            if ec and eg:IsContains(ec) and ec:IsLocation(LOCATION_OVERLAY) and ec:IsReason(REASON_XYZ) then
                Ourogear.CreateLaunchHarnessToken(tc:GetControler(),tc)
            end
        end
    end
end
