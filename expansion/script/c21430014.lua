if not Ourogear then Duel.LoadScript("ourogear.lua") end
-- Ourogear Dominion Ark
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Ourogear.AddXyzProcedure(c,3,Ourogear.Rank4GenericXyzMaterial,Ourogear.Rank4ArchetypeXyzMaterial)
	Ourogear.AddRitualRankLevel(c)
	--Detach 1 material; temporarily banish 1 card on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--First 2 times each turn opponent would Special Summon from Extra Deck: destroy 1 card they control, or negate that Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.sumcon)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
end
s.listed_series={Ourogear.SET}
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		aux.RemoveUntil(tc,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp)
	end
end
function s.extrafilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:GetSummonLocation()==LOCATION_EXTRA
end
function s.sumcon(e,tp,eg)
	return Duel.GetCurrentChain()==0 and e:GetHandler():GetFlagEffect(id)<2 and eg:IsExists(s.extrafilter,1,nil,tp)
end
function s.desfilter(c)
	return c:IsOnField() and c:IsDestructable()
end
function s.sumop(e,tp,eg)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
	local opp=1-tp
	local dg=Duel.GetMatchingGroup(s.desfilter,opp,LOCATION_ONFIELD,0,nil)
	local paid=false
	if #dg>0 and Duel.SelectYesNo(opp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,opp,HINTMSG_DESTROY)
		local tc=dg:Select(opp,1,1,nil):GetFirst()
		paid=tc and Duel.Destroy(tc,REASON_EFFECT)>0
	end
	if not paid then Duel.NegateSummon(eg) end
end
