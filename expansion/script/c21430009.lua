if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Ourogear.MarkRitualLeftField(c)
	--Opponent's monsters lose 600 ATK/DEF for each other monster they control
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.statval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Once per Chain, when the opponent activates a card/effect, they choose to negate it or temporarily banish a random Extra Deck card face-down
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(s.choicecon)
	e3:SetTarget(s.choicetg)
	e3:SetOperation(s.choiceop)
	c:RegisterEffect(e3)
	--Activated effects of "Ourogear" monsters you control cannot be negated by the opponent
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DISEFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.protectval)
	c:RegisterEffect(e4)
end
s.listed_series={Ourogear.SET}
function s.statval(e,c)
	local tp=e:GetHandlerPlayer()
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-1
	return -600*math.max(ct,0)
end
function s.canbanish(tp)
	return Duel.IsPlayerCanRemove(tp)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil)
end
function s.choicecon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and (Duel.IsChainDisablable(ev) or s.canbanish(tp))
end
function s.choicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsChainDisablable(ev)
	local b2=s.canbanish(tp)
	if chk==0 then return b1 or b2 end
	local op
	if b1 and b2 then
		op=Duel.SelectEffect(1-tp,{true,aux.Stringid(id,1)},{true,aux.Stringid(id,2)})
	elseif b1 then
		op=1
	else
		op=2
	end
	e:SetLabel(op)
	if op==1 then
		Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
	end
end
function s.choiceop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		Duel.NegateEffect(ev)
		return
	end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)
	if #g==0 or not Duel.IsPlayerCanRemove(tp) then return end
	local rc=g:RandomSelect(1-tp,1):GetFirst()
	if not rc then return end
	local current_turn=Duel.GetTurnCount()
	local activated_during_opponent_turn=Duel.IsTurnPlayer(1-tp)
	local target_turn=current_turn+(activated_during_opponent_turn and 2 or 1)
	local reset_count=activated_during_opponent_turn and 3 or 2
	aux.RemoveUntil(rc,POS_FACEDOWN,REASON_EFFECT|REASON_TEMPORARY,PHASE_END,id,e,tp,s.retop,
		function() return Duel.GetTurnCount()==target_turn and Duel.IsTurnPlayer(1-tp) end,
		RESET_PHASE|PHASE_END,reset_count,aux.Stringid(id,3))
end
function s.retop(rg)
	local facedown_g,faceup_g=rg:Split(Card.IsPreviousPosition,nil,POS_FACEDOWN)
	if #facedown_g>0 then
		Duel.SendtoDeck(facedown_g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.ShuffleExtra(facedown_g:GetFirst():GetControler())
	end
	if #faceup_g>0 then
		Duel.SendtoExtraP(faceup_g,nil,REASON_EFFECT)
	end
end
function s.protectval(e,ct)
	local tp=e:GetHandlerPlayer()
	return Chain.IsTriggeringPlayer(ct,tp)
		and Chain.IsTriggeringLocation(ct,LOCATION_MZONE)
		and Chain.IsTriggeringSetcode(ct,Ourogear.SET)
		and Chain.IsTriggeringType(ct,TYPE_MONSTER)
end
