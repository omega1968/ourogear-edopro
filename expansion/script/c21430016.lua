if not Ourogear then Duel.LoadScript("ourogear.lua") end
-- Ourogear Skyforge Nexus
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Once per turn: add 1 Ourogear card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--The first time each turn an Ourogear Spell/Trap would be destroyed by an opponent's card effect, it is not destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetCountLimit(1)
	e2:SetTarget(function(e,tc) return tc:IsSetCard(Ourogear.SET) and tc:IsSpellTrap() end)
	e2:SetValue(function(e,re,r,rp) return (r&REASON_EFFECT)>0 and rp==1-e:GetHandlerPlayer() end)
	c:RegisterEffect(e2)
	--Place up to 2 Ourogear Continuous Spells/Traps from GY face-up
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.pltg)
	e3:SetOperation(s.plop)
	c:RegisterEffect(e3)
end
s.listed_series={Ourogear.SET}
function s.thfilter(c)
	return c:IsSetCard(Ourogear.SET) and c:IsAbleToHand()
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
function s.plfilter(c)
	return Ourogear.IsOurogearContinuousST(c) and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.plfilter(chkc) end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if chk==0 then return ft>0 and Duel.IsExistingTarget(s.plfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local max=math.min(2,ft)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectTarget(tp,s.plfilter,tp,LOCATION_GRAVE,0,1,max,nil)
end
function s.plop(e,tp)
	local g=Duel.GetTargetCards(e):Filter(function(c) return c:IsRelateToEffect(e) and not c:IsForbidden() end,nil)
	for tc in g:Iter() do
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then break end
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
