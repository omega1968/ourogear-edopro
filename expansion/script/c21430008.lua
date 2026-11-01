if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Ourogear.MarkRitualLeftField(c)
	--Negate a face-up opponent's card; monsters also cannot attack or be used as Extra Deck material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--While you control a WIND Machine monster, each "Ourogear" monster can make a second attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(function(e,tc) return tc:IsSetCard(Ourogear.SET) end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.listed_series={Ourogear.SET}
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	tc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END,true)
	if not tc:IsMonster() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e2:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	tc:RegisterEffect(e2)
end
function s.atkcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(function(c)
		return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_MACHINE)
	end,tp,LOCATION_MZONE,0,1,nil)
end
