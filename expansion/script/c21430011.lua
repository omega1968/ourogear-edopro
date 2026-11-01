if not Ourogear then Duel.LoadScript("ourogear.lua") end
-- Ourogear Relay Frame
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Ourogear.AddXyzProcedure(c,2,Ourogear.Level4GenericXyzMaterial,Ourogear.Level4ArchetypeXyzMaterial)
	Ourogear.AddRitualRankLevel(c)
	--Detach 1 material; Special Summon an Ourogear Token that cannot be Tributed this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Ourogear.CanSummonToken(tp) end
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	end)
	e1:SetOperation(function(e,tp) Ourogear.SpecialSummonToken(e,tp,true) end)
	c:RegisterEffect(e1)
	--Inherited: once per turn, if opponent Special Summons, attach 1 of those monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1)
	e2:SetCondition(s.attcon)
	e2:SetTarget(s.atttg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
end
s.listed_series={Ourogear.SET}
function s.attfilter(c,tp,xyz)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsMonster() and not c:IsType(TYPE_TOKEN)
		and c:IsCanBeXyzMaterial(xyz,tp,REASON_EFFECT)
end
function s.attcon(e,tp,eg)
	local c=e:GetHandler()
	return Ourogear.IsWindMachineXyz(c) and eg:IsExists(s.attfilter,1,nil,tp,c)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return eg:IsContains(chkc) and s.attfilter(chkc,tp,c) end
	if chk==0 then return eg:IsExists(s.attfilter,1,nil,tp,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=eg:FilterSelect(tp,s.attfilter,1,1,nil,tp,c)
	Duel.SetTargetCard(g)
end
function s.attop(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Ourogear.IsWindMachineXyz(c) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Overlay(c,tc,true)
	end
end
