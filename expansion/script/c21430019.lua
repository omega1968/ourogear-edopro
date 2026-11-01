if not Ourogear then Duel.LoadScript("ourogear.lua") end
-- Ourogear Material Loom
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Before the first detach by each WIND Machine Xyz each turn, attach the top card of the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.repcon)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
	--Target 3 different-named Ourogear cards in GY; opponent randomly chooses 1 to add, shuffle the other 2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
	--Send this face-up card to GY; Special Summon an Ourogear Token
	Ourogear.AddSelfSendTokenEffect(c,id,2,1)
end
s.listed_series={Ourogear.SET}
function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re and re:GetHandler()
	return ep==tp and (r&REASON_COST)~=0 and rc and Ourogear.IsWindMachineXyz(rc)
		and rc:GetOverlayCount()>=ev and rc:GetFlagEffect(Ourogear.FLAG_LOOM)==0
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not Ourogear.IsWindMachineXyz(rc) or rc:GetFlagEffect(Ourogear.FLAG_LOOM)>0 then return false end
	rc:RegisterFlagEffect(Ourogear.FLAG_LOOM,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
	local top=Duel.GetDecktopGroup(tp,1)
	if #top~=1 then return false end
	Duel.Overlay(rc,top,true)
	return rc:RemoveOverlayCard(tp,ev,ev,REASON_COST)
end
function s.recfilter(c)
	return c:IsSetCard(Ourogear.SET)
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.recfilter(chkc) end
	local g=Duel.GetMatchingGroup(s.recfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>=3 and aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
end
function s.recop(e,tp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #g~=3 then return end
	local chosen=g:RandomSelect(1-tp,1)
	local rest=g-chosen
	if Duel.SendtoHand(chosen,nil,REASON_EFFECT)>0 then Duel.ConfirmCards(1-tp,chosen) end
	if #rest>0 then Duel.SendtoDeck(rest,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
end
