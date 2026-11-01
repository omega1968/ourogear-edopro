-- Ourogear shared utilities
-- Written for Project Ignis / EDOPro CardScripts API (2026-10-31 baseline)
Ourogear=Ourogear or {}
Ourogear.SET=0x7f0
Ourogear.TOKEN=21430099
Ourogear.FLAG_LOOM=21439901

function Ourogear.IsWindMachineXyz(c)
	return c and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ)
end

function Ourogear.IsWindMachineOrToken(c)
	return c and c:IsFaceup() and ((c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_MACHINE)) or c:IsType(TYPE_TOKEN))
end

function Ourogear.HandSpCondition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Ourogear.IsWindMachineOrToken,tp,LOCATION_MZONE,0,1,nil)
end

function Ourogear.AddHandSpecialSummon(c,id)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(Ourogear.HandSpCondition)
	c:RegisterEffect(e1)
	return e1
end

function Ourogear.CanSummonToken(tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,Ourogear.TOKEN,Ourogear.SET,TYPES_TOKEN,0,0,4,RACE_MACHINE,ATTRIBUTE_WIND)
end

function Ourogear.ApplyTokenRestrictions(token,cannot_tribute)
	local e1=Effect.CreateEffect(token)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e1:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_LINK))
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	token:RegisterEffect(e1,true)
	if cannot_tribute then
		local e2=Effect.CreateEffect(token)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCode(EFFECT_UNRELEASABLE_SUM)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		token:RegisterEffect(e2,true)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		token:RegisterEffect(e3,true)
	end
end

function Ourogear.SpecialSummonToken(e,tp,cannot_tribute)
	if not Ourogear.CanSummonToken(tp) then return 0,nil end
	local token=Duel.CreateToken(tp,Ourogear.TOKEN)
	Ourogear.ApplyTokenRestrictions(token,cannot_tribute)
	local ct=Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	return ct,token
end

function Ourogear.TokenTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 and Ourogear.CanSummonToken(tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function Ourogear.RandomRevealAndToken(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #hg==0 then return end
	local rc=hg:RandomSelect(1-tp,1)
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(tp)
	if Ourogear.CanSummonToken(tp) then
		Ourogear.SpecialSummonToken(e,tp,false)
	end
end

function Ourogear.Level4GenericXyzMaterial(c,xyz,tp)
	return c:IsFaceup() and c:IsLevel(4) and c:IsCanBeXyzMaterial(xyz,tp)
end

function Ourogear.Level4ArchetypeXyzMaterial(c,xyz,tp)
	return c:IsFaceup() and c:IsLevel(4) and c:IsSetCard(Ourogear.SET) and c:IsCanBeXyzMaterial(xyz,tp)
end

function Ourogear.Rank4GenericXyzMaterial(c,xyz,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRank(4) and c:IsCanBeXyzMaterial(xyz,tp)
end

function Ourogear.Rank4ArchetypeXyzMaterial(c,xyz,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRank(4) and c:IsSetCard(Ourogear.SET) and c:IsCanBeXyzMaterial(xyz,tp)
end

function Ourogear.IsXyzSubstitute(c,xyz,tp)
	if not c:IsFaceup() then return false end
	if c:IsType(TYPE_TOKEN) then
		return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_MACHINE)
	end
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ)
		and c:IsCanBeXyzMaterial(xyz,tp)
end

local function ourogear_xyz_group_ok(sg,xyz,tp,count,generic_filter,archetype_filter,mustg)
	if #sg~=count then return false end
	if mustg and not sg:Includes(mustg) then return false end
	local has_archetype_slot=false
	local token_count=0
	for mc in sg:Iter() do
		local sub=Ourogear.IsXyzSubstitute(mc,xyz,tp)
		if not sub and not generic_filter(mc,xyz,tp) then return false end
		if sub or archetype_filter(mc,xyz,tp) then has_archetype_slot=true end
		if mc:IsType(TYPE_TOKEN) then token_count=token_count+1 end
	end
	if not has_archetype_slot then return false end
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<token_count then return false end
	return Duel.GetLocationCountFromEx(tp,tp,sg,xyz)>0
end

local function ourogear_xyz_material_pool(tp,xyz,og,generic_filter,archetype_filter)
	local g
	if og then
		g=og:Filter(Card.IsFaceup,nil)
	else
		g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	end
	local mg=g:Filter(function(mc)
		return Ourogear.IsXyzSubstitute(mc,xyz,tp) or generic_filter(mc,xyz,tp) or archetype_filter(mc,xyz,tp)
	end,nil)
	return g,mg
end

function Ourogear.AddXyzProcedure(c,count,generic_filter,archetype_filter)
	local function condition(e,xyz,must,og,min,max)
		if xyz==nil then return true end
		local tp=xyz:GetControler()
		if min and min>count then return false end
		if max and max<count then return false end
		local g,mg=ourogear_xyz_material_pool(tp,xyz,og,generic_filter,archetype_filter)
		local mustg=aux.GetMustBeMaterialGroup(tp,g,tp,xyz,mg,REASON_XYZ)
		if must then mustg:Merge(must) end
		if #mustg>count or not mg:Includes(mustg) then return false end
		local rescon=function(sg)
			return ourogear_xyz_group_ok(sg,xyz,tp,count,generic_filter,archetype_filter,mustg)
		end
		return #mg>=count and aux.SelectUnselectGroup(mg,e,tp,count,count,rescon,0)
	end
	local function target(e,tp,eg,ep,ev,re,r,rp,chk,xyz,must,og,min,max)
		local g,mg=ourogear_xyz_material_pool(tp,xyz,og,generic_filter,archetype_filter)
		local mustg=aux.GetMustBeMaterialGroup(tp,g,tp,xyz,mg,REASON_XYZ)
		if must then mustg:Merge(must) end
		local rescon=function(sg)
			return ourogear_xyz_group_ok(sg,xyz,tp,count,generic_filter,archetype_filter,mustg)
		end
		local cancelable=not og and Duel.IsSummonCancelable()
		local sg=aux.SelectUnselectGroup(mg,e,tp,count,count,rescon,1,tp,HINTMSG_XMATERIAL,rescon,nil,cancelable)
		if #sg~=count then return false end
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	local function operation(e,tp,eg,ep,ev,re,r,rp,xyz)
		local sg=e:GetLabelObject()
		if not sg then return end
		local token_g=sg:Filter(Card.IsType,nil,TYPE_TOKEN)
		local mat_g=sg:Clone()
		mat_g:Sub(token_g)
		xyz:SetMaterial(mat_g)
		if #mat_g>0 then
			-- No third argument: Project Ignis carries existing materials of Xyz monsters forward.
			Duel.Overlay(xyz,mat_g)
		end
		if #token_g>0 then
			Duel.SendtoGrave(token_g,REASON_RULE|REASON_MATERIAL|REASON_XYZ)
			local top=Duel.GetDecktopGroup(tp,#token_g)
			if #top==#token_g then
				Duel.Overlay(xyz,top,true)
			end
		end
		sg:DeleteGroup()
	end

	local chk=Effect.CreateEffect(c)
	chk:SetType(EFFECT_TYPE_SINGLE)
	chk:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	chk:SetCode(946)
	chk:SetCondition(condition)
	chk:SetTarget(target)
	chk:SetOperation(operation)
	c:RegisterEffect(chk)

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1173)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(condition)
	e1:SetTarget(target)
	e1:SetOperation(operation)
	e1:SetValue(SUMMON_TYPE_XYZ)
	e1:SetLabelObject(chk)
	c:RegisterEffect(e1)
end

function Ourogear.AddRitualRankLevel(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_RITUAL_LEVEL)
	e1:SetValue(function(e,rc)
		if rc and rc:IsRace(RACE_REPTILE) then return e:GetHandler():GetRank() end
		return 0
	end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e2:SetValue(function(e,sc,sumtype,tp)
		return sumtype and (sumtype&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL and sc and not sc:IsRace(RACE_REPTILE)
	end)
	c:RegisterEffect(e2)
end

function Ourogear.RitualFromDeckTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local params={
		lvtype=RITPROC_GREATER,
		filter=function(c) return c:IsRace(RACE_REPTILE) end,
		location=LOCATION_DECK,
		matfilter=function(c) return c:IsLocation(LOCATION_MZONE) end
	}
	return Ritual.Target(params)(e,tp,eg,ep,ev,re,r,rp,chk)
end

function Ourogear.RitualFromDeckOperation(e,tp,eg,ep,ev,re,r,rp)
	local params={
		lvtype=RITPROC_GREATER,
		filter=function(c) return c:IsRace(RACE_REPTILE) end,
		location=LOCATION_DECK,
		matfilter=function(c) return c:IsLocation(LOCATION_MZONE) end
	}
	Ritual.Operation(params)(e,tp,eg,ep,ev,re,r,rp)
end

function Ourogear.AddLevel4RitualHandEffect(c,id)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local hc=e:GetHandler()
		if chk==0 then return hc:IsDiscardable() end
		Duel.SendtoGrave(hc,REASON_COST|REASON_DISCARD)
	end)
	e1:SetTarget(Ourogear.RitualFromDeckTarget)
	e1:SetOperation(Ourogear.RitualFromDeckOperation)
	c:RegisterEffect(e1)
end

function Ourogear.MarkRitualLeftField(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(function(e)
		return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
	end)
	e1:SetOperation(function(e)
		e:GetHandler():RegisterFlagEffect(21439902,RESET_PHASE|PHASE_END,0,1)
	end)
	c:RegisterEffect(e1)
end

function Ourogear.IsOurogearContinuousST(c)
	return c:IsSetCard(Ourogear.SET) and (c:IsContinuousSpell() or c:IsContinuousTrap())
end

function Ourogear.SelfSendTokenCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end

function Ourogear.SelfSendTokenTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Ourogear.CanSummonToken(tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function Ourogear.SelfSendTokenOperation(e,tp,eg,ep,ev,re,r,rp)
	Ourogear.SpecialSummonToken(e,tp,false)
end

function Ourogear.AddSelfSendTokenEffect(c,id,desc_index,count_index)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,desc_index))
	e1:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,count_index})
	e1:SetCost(Ourogear.SelfSendTokenCost)
	e1:SetTarget(Ourogear.SelfSendTokenTarget)
	e1:SetOperation(Ourogear.SelfSendTokenOperation)
	c:RegisterEffect(e1)
	return e1
end
