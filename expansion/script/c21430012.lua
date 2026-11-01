if not Ourogear then Duel.LoadScript("ourogear.lua") end
-- Ourogear Breach Frame
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Ourogear.AddXyzProcedure(c,2,Ourogear.Level4GenericXyzMaterial,Ourogear.Level4ArchetypeXyzMaterial)
	Ourogear.AddRitualRankLevel(c)
	--Detach 1 material; destroy up to 2 cards your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Inherited: once per turn, destroy 1 opponent card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e) return Ourogear.IsWindMachineXyz(e:GetHandler()) end)
	e2:SetTarget(s.idestg)
	e2:SetOperation(s.idesop)
	c:RegisterEffect(e2)
end
s.listed_series={Ourogear.SET}
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
end
function s.idestg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.idesop(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
