if not Ourogear then Duel.LoadScript("ourogear.lua") end
-- Ourogear Suppression Grid
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Opponent monsters Special Summoned in Attack Position are changed to Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.poscon)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	--While opponent controls 4+ Defense Position monsters, they cannot activate effects of Defense Position monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.lockcon)
	e2:SetTarget(function(e,tc) return tc:IsDefensePos() end)
	c:RegisterEffect(e2)
end
s.listed_series={Ourogear.SET}
function s.posfilter(c,tp)
	return c:IsControler(1-tp) and c:IsFaceup() and c:IsAttackPos() and c:IsCanChangePosition()
end
function s.poscon(e,tp,eg)
	return eg:IsExists(s.posfilter,1,nil,tp)
end
function s.posop(e,tp,eg)
	local trap=e:GetHandler()
	local field_id=trap:GetFieldID()
	local g=eg:Filter(s.posfilter,nil,tp)
	for tc in g:Iter() do
		if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)>0 then
			local e1=Effect.CreateEffect(trap)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetLabel(field_id)
			e1:SetCondition(function(e)
				local lc=e:GetLabelObject()
				return lc and lc:IsFaceup() and lc:IsLocation(LOCATION_SZONE) and lc:GetFieldID()==e:GetLabel()
			end)
			e1:SetLabelObject(trap)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
function s.lockcon(e,tp)
	return Duel.GetMatchingGroupCount(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)>=4
end
