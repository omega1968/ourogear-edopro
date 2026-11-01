if not Ourogear then Duel.LoadScript("ourogear.lua") end
-- Ourogear Grave Harvester
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--If opponent activates a card/effect in GY: attach 1 card from their GY to a WIND Machine Xyz
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.chcon)
	e1:SetTarget(s.atttg)
	e1:SetOperation(s.attop)
	c:RegisterEffect(e1)
	--If a card leaves opponent's GY because of their card/effect: attach 1 other card from their GY
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.lvcon)
	c:RegisterEffect(e2)
end
s.listed_series={Ourogear.SET}
function s.xyzfilter(c)
	return Ourogear.IsWindMachineXyz(c)
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Chain.IsTriggeringLocation(ev,LOCATION_GRAVE)
end
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and (r&(REASON_EFFECT|REASON_COST))~=0 and eg:IsExists(function(c) return c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_GRAVE) end,1,nil)
end
function s.gyfilter(c)
	return true
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and s.gyfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(s.gyfilter,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectTarget(tp,s.gyfilter,tp,0,LOCATION_GRAVE,1,1,nil)
end
function s.attop(e,tp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsLocation(LOCATION_GRAVE) then return end
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local xc=g:Select(tp,1,1,nil):GetFirst()
	if xc then Duel.Overlay(xc,tc,true) end
end
