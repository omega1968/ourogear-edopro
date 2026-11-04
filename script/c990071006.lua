-- Ourogear Ritebind
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.fieldmatfilter(c,e,tp)
    return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
s.ritparams={lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),location=LOCATION_DECK,matfilter=s.fieldmatfilter}
function s.initial_effect(c)
    c:EnableReviveLimit()
    Ourogear.RegisterRitualLeftFieldTracker(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0)); e1:SetCategory(CATEGORY_RELEASE|CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION); e1:SetRange(LOCATION_HAND); e1:SetCountLimit(1,{id,0})
    e1:SetCost(s.ritcost); e1:SetTarget(Ritual.Target(s.ritparams)); e1:SetOperation(Ritual.Operation(s.ritparams)); c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1)); e2:SetType(EFFECT_TYPE_QUICK_O); e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET); e2:SetRange(LOCATION_MZONE); e2:SetCountLimit(1,{id,1})
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END); e2:SetTarget(s.locktg); e2:SetOperation(s.lockop); c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2)); e3:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_IGNITION); e3:SetRange(LOCATION_GRAVE); e3:SetCountLimit(1,{id,2})
    e3:SetCost(s.gycost); e3:SetTarget(s.sptg); e3:SetOperation(s.spop); c:RegisterEffect(e3)
end
s.listed_series={Ourogear.SET}
function s.ritcost(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return e:GetHandler():IsDiscardable() end Duel.SendtoGrave(e:GetHandler(),REASON_COST|REASON_DISCARD) end
function s.locktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP); Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.lockop(e,tp)
    local tc=Duel.GetFirstTarget(); if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
    local e1=Effect.CreateEffect(e:GetHandler()); e1:SetType(EFFECT_TYPE_SINGLE); e1:SetCode(EFFECT_CANNOT_ATTACK); e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END); tc:RegisterEffect(e1)
    local e2=Effect.CreateEffect(e:GetHandler()); e2:SetType(EFFECT_TYPE_SINGLE); e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e2:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK)); e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END); tc:RegisterEffect(e2)
end
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler(); if chk==0 then return c:IsAbleToDeckAsCost() end Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST) end
function s.spfilter(c,e,tp) return (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup()) and c:IsRace(RACE_REPTILE) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_REMOVED)
end
function s.spop(e,tp) if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON); local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,1,nil,e,tp); if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end end
