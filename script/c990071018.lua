-- Ourogear Recovery Array
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c); e0:SetType(EFFECT_TYPE_ACTIVATE); e0:SetCode(EVENT_FREE_CHAIN); c:RegisterEffect(e0)
    -- Requires both a WIND Machine Xyz Monster and a Reptile Ritual Monster
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD); e1:SetCode(EFFECT_UPDATE_ATTACK); e1:SetRange(LOCATION_SZONE); e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetCondition(s.comeback); e1:SetTarget(function(e,c) return c:IsSetCard(Ourogear.SET) end); e1:SetValue(500); c:RegisterEffect(e1)
    local e1b=e1:Clone(); e1b:SetCode(EFFECT_UPDATE_DEFENSE); c:RegisterEffect(e1b)
    -- Cannot be targeted by opponent's monster effects while both required monsters remain
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD); e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET); e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE); e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,0); e2:SetCondition(s.comeback); e2:SetTarget(function(e,c) return c:IsSetCard(Ourogear.SET) end)
    e2:SetValue(function(e,re,rp) return rp==1-e:GetHandlerPlayer() and re:IsMonsterEffect() end); c:RegisterEffect(e2)
    -- Search an Ourogear Continuous Spell/Trap
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0)); e3:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH); e3:SetType(EFFECT_TYPE_IGNITION); e3:SetRange(LOCATION_SZONE); e3:SetCountLimit(1,{id,0})
    e3:SetTarget(s.thtg); e3:SetOperation(s.thop); c:RegisterEffect(e3)
    -- Send this card to GY; create a Token
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1)); e4:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE); e4:SetType(EFFECT_TYPE_IGNITION); e4:SetRange(LOCATION_SZONE); e4:SetCountLimit(1,{id,1})
    e4:SetCost(s.tkcost); e4:SetTarget(s.tktg); e4:SetOperation(s.tkop); c:RegisterEffect(e4)
end
s.listed_series={Ourogear.SET}
s.listed_names={Ourogear.TOKEN}
function s.comeback(e,tp)
    -- Some EDOPro callback paths omit tp for field-effect conditions.
    -- Derive it from the effect handler so the player argument is always an integer.
    local c=e:GetHandler()
    if not c then return false end
    tp=c:GetControler()
    return Duel.IsExistingMatchingCard(function(tc) return tc:IsFaceup() and Ourogear.IsWindMachineXyz(tc) end,
        tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(function(tc) return tc:IsFaceup() and tc:IsType(TYPE_RITUAL) and tc:IsRace(RACE_REPTILE) end,
            tp,LOCATION_MZONE,0,1,nil)
end
function s.thfilter(c) return Ourogear.IsOurogearContinuousST(c) and not c:IsCode(id) and c:IsAbleToHand() end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK) end
function s.thop(e,tp) Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND); local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil); if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT); Duel.ConfirmCards(1-tp,g) end end
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler(); if chk==0 then return c:IsAbleToGraveAsCost() end Duel.SendtoGrave(c,REASON_COST) end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0) end
function s.tkop(e,tp) Ourogear.CreateToken(tp,e:GetHandler()) end
