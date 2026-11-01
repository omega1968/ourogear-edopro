if not Ourogear then Duel.LoadScript("ourogear.lua") end
-- Ourogear Rite Circuit
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Ourogear monsters can be treated as Level 4 or Level 8 for a Reptile Ritual Summon
	local ge=Effect.CreateEffect(c)
	ge:SetType(EFFECT_TYPE_SINGLE)
	ge:SetCode(EFFECT_RITUAL_LEVEL)
	ge:SetValue(function(e,rc)
		if rc and rc:IsRace(RACE_REPTILE) then return 4|(8<<16) end
		return e:GetHandler():GetLevel()
	end)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,tc) return tc:IsSetCard(Ourogear.SET) and tc:IsMonster() end)
	e1:SetLabelObject(ge)
	c:RegisterEffect(e1)
	--Quick Ritual Summon from hand/GY using Level 4 Reptiles from Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e2:SetTarget(s.rittg)
	e2:SetOperation(s.ritop)
	c:RegisterEffect(e2)
	--Send this face-up card to GY; Special Summon an Ourogear Token
	Ourogear.AddSelfSendTokenEffect(c,id,1,1)
end
s.listed_series={Ourogear.SET}
function s.ritfilter(c)
	return c:IsSetCard(Ourogear.SET) and c:IsRitualMonster()
		and (not c:IsLocation(LOCATION_GRAVE) or c:GetFlagEffect(21439902)==0)
end
function s.deckmatfilter(c)
	return c:IsLevel(4) and c:IsRace(RACE_REPTILE) and c:IsReleasableByEffect()
end
function s.extrafil(e,tp)
	return Duel.GetMatchingGroup(s.deckmatfilter,tp,LOCATION_DECK,0,nil)
end
function s.matfilter(c)
	return c:IsLocation(LOCATION_DECK) and s.deckmatfilter(c)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	Duel.ReleaseRitualMaterial(mat,true)
end
function s.params()
	return {
		filter=s.ritfilter,
		lvtype=RITPROC_GREATER,
		extrafil=s.extrafil,
		extraop=s.extraop,
		matfilter=s.matfilter,
		location=LOCATION_HAND|LOCATION_GRAVE
	}
end
function s.rittg(e,tp,eg,ep,ev,re,r,rp,chk)
	return Ritual.Target(s.params())(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.ritop(e,tp,eg,ep,ev,re,r,rp)
	Ritual.Operation(s.params())(e,tp,eg,ep,ev,re,r,rp)
end
