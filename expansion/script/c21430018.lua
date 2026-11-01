if not Ourogear then Duel.LoadScript("ourogear.lua") end
-- Ourogear Recovery Array
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--While opponent controls more cards, Ourogear monsters gain 500 ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.advcon)
	e1:SetTarget(s.ogmon)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--...and cannot be targeted by opponent's monster effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.advcon)
	e3:SetTarget(s.ogmon)
	e3:SetValue(function(e,re,rp) return rp==1-e:GetHandlerPlayer() and re:IsMonsterEffect() end)
	c:RegisterEffect(e3)
	--Add 1 Ourogear Continuous Spell/Trap, except itself
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,0})
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	--Send this face-up card to GY; Special Summon an Ourogear Token
	Ourogear.AddSelfSendTokenEffect(c,id,1,1)
end
s.listed_series={Ourogear.SET}
function s.advcon(e,tp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.ogmon(e,c)
	return c:IsSetCard(Ourogear.SET) and c:IsMonster()
end
function s.thfilter(c)
	return c:IsSetCard(Ourogear.SET) and c:IsSpellTrap() and c:IsType(TYPE_CONTINUOUS)
		and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then Duel.ConfirmCards(1-tp,g) end
end
