-- Ourogear Rite Circuit
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    -- "Ourogear" monsters can count as Level 4 or Level 8 for a Reptile Ritual Summon.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_RITUAL_LEVEL)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(function(_,tc) return tc:IsSetCard(Ourogear.SET) end)
    e1:SetValue(function() return (4<<16)|8 end)
    c:RegisterEffect(e1)
    -- Quick Ritual Summon an "Ourogear" Ritual Monster from the hand/GY using Level 4 Reptiles from the Deck.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_RELEASE|CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,0})
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
    e2:SetTarget(s.rittg)
    e2:SetOperation(s.ritop)
    c:RegisterEffect(e2)
    -- Send this face-up card to the GY; Special Summon an "Ourogear Token".
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.tkcost)
    e3:SetTarget(s.tktg)
    e3:SetOperation(s.tkop)
    c:RegisterEffect(e3)
end
s.listed_series={Ourogear.SET}
s.listed_names={Ourogear.TOKEN}
function s.ritfilter(c)
    return c:IsSetCard(Ourogear.SET) and c:IsRitualMonster()
        and not (c:IsLocation(LOCATION_GRAVE) and c:GetFlagEffect(Ourogear.FLAG_RITUAL_LEFT_FIELD)>0)
end
function s.deckmatfilter(c)
    return c:IsLocation(LOCATION_DECK) and c:IsRace(RACE_REPTILE) and c:IsLevel(4) and c:IsReleasableByEffect()
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
    return Duel.GetMatchingGroup(function(c)
        return c:IsRace(RACE_REPTILE) and c:IsLevel(4) and c:IsReleasableByEffect()
    end,tp,LOCATION_DECK,0,nil)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,rc)
    Duel.ReleaseRitualMaterial(mat,true)
end
local ritual_params={
    lvtype=RITPROC_GREATER,
    filter=s.ritfilter,
    location=LOCATION_HAND|LOCATION_GRAVE,
    extrafil=s.extragroup,
    extraop=s.extraop,
    matfilter=s.deckmatfilter
}
function s.rittg(e,tp,eg,ep,ev,re,r,rp,chk)
    local rt=Ritual.Target(ritual_params)
    if chk==0 then return rt(e,tp,eg,ep,ev,re,r,rp,0) end
    rt(e,tp,eg,ep,ev,re,r,rp,1)
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_DECK)
end
function s.ritop(e,tp,eg,ep,ev,re,r,rp)
    Ritual.Operation(ritual_params)(e,tp,eg,ep,ev,re,r,rp)
end
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c,REASON_COST)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp)
    Ourogear.CreateToken(tp,e:GetHandler())
end
