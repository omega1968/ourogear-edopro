-- Shared helpers for the custom "Ourogear" archetype.
-- Designed for Project Ignis / EDOPro Lua 5.3 conventions.
if Ourogear then return end
Ourogear={}
local OG=Ourogear

OG.SET=0x1f99
OG.TOKEN=990071099
OG.FLAG_XYZ_TOKEN_COUNT=990071900
OG.FLAG_RITUAL_LEFT_FIELD=990071901
OG.FLAG_LOOM_USED=990071902
OG.FLAG_LAUNCH_HARNESS_TOKEN=990071917

function OG.IsOurogear(c)
    return c:IsSetCard(OG.SET)
end
function OG.IsWindMachine(c)
    return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_MACHINE)
end
function OG.IsWindMachineXyz(c)
    return c:IsType(TYPE_XYZ) and OG.IsWindMachine(c)
end
function OG.IsWindMachineToken(c)
    return c:IsType(TYPE_TOKEN) and OG.IsWindMachine(c)
end
function OG.IsXyzSubstitute(c)
    return OG.IsWindMachineToken(c) or OG.IsWindMachineXyz(c)
end
function OG.CanUseAsXyzMaterial(c,xyz,tp)
    if not c:IsFaceup() then return false end
    if OG.IsWindMachineToken(c) then return true end
    return c:IsCanBeXyzMaterial(xyz,tp)
end
function OG.XyzCandidate(c,xyz,tp,mode,rank)
    if not OG.CanUseAsXyzMaterial(c,xyz,tp) then return false end
    if OG.IsXyzSubstitute(c) then return true end
    if c:IsType(TYPE_TOKEN) then return false end
    if mode==4 then
        return c:IsLevel(rank)
    end
    return c:IsType(TYPE_XYZ) and c:IsRank(rank)
end
function OG.FillsArchetypeSlot(c,mode,rank)
    if OG.IsXyzSubstitute(c) then return true end
    if mode==4 then
        return c:IsLevel(rank) and c:IsSetCard(OG.SET)
    end
    return c:IsType(TYPE_XYZ) and c:IsRank(rank) and c:IsSetCard(OG.SET)
end
function OG.ValidXyzGroup(sg,xyz,tp,mode,rank,ct,mustg)
    if #sg~=ct then return false end
    if mustg and not sg:Includes(mustg) then return false end
    if not sg:IsExists(OG.FillsArchetypeSlot,1,nil,mode,rank) then return false end
    return Duel.GetLocationCountFromEx(tp,tp,sg,xyz)>0
end
function OG.GetXyzMaterialPool(tp,xyz,mode,rank,og)
    local base=og or Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
    return base:Filter(OG.XyzCandidate,nil,xyz,tp,mode,rank),base
end
function OG.XyzCondition(mode,rank,ct)
    return function(e,c,must,og,min,max)
        if c==nil then return true end
        if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
        if (min and ct<min) or (max and ct>max) then return false end
        local tp=c:GetControler()
        local mg,base=OG.GetXyzMaterialPool(tp,c,mode,rank,og)
        local mustg=Auxiliary.GetMustBeMaterialGroup(tp,base,tp,c,mg,REASON_XYZ)
        if must then mustg:Merge(must) end
        if not mg:Includes(mustg) then return false end
        return aux.SelectUnselectGroup(mg,e,tp,ct,ct,
            function(sg) return OG.ValidXyzGroup(sg,c,tp,mode,rank,ct,mustg) end,0)
    end
end
function OG.XyzTarget(mode,rank,ct)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,og,min,max)
        local mg,base=OG.GetXyzMaterialPool(tp,c,mode,rank,og)
        local mustg=Auxiliary.GetMustBeMaterialGroup(tp,base,tp,c,mg,REASON_XYZ)
        if must then mustg:Merge(must) end
        if not mg:Includes(mustg) then return false end
        local rescon=function(sg) return OG.ValidXyzGroup(sg,c,tp,mode,rank,ct,mustg) end
        local sg
        if og and #og==ct and rescon(og) then
            sg=og:Clone()
        else
            sg=aux.SelectUnselectGroup(mg,e,tp,ct,ct,rescon,1,tp,HINTMSG_XMATERIAL,rescon)
        end
        if not sg or #sg~=ct then return false end
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    end
end
function OG.XyzOperation(mode,rank,ct)
    return function(e,tp,eg,ep,ev,re,r,rp,c,must,og,min,max)
        local g=e:GetLabelObject()
        if not g then return end
        local tokenct=g:FilterCount(Card.IsType,nil,TYPE_TOKEN)
        c:SetMaterial(g)
        -- Ourogear keeps the existing materials of any WIND Machine Xyz used.
        for tc in g:Iter() do
            if OG.IsWindMachineXyz(tc) and tc:GetOverlayCount()>0 then
                Duel.Overlay(c,tc:GetOverlayGroup())
            end
        end
        local ng=g:Filter(aux.NOT(Card.IsType),nil,TYPE_TOKEN)
        local tg=g:Filter(Card.IsType,nil,TYPE_TOKEN)
        if #ng>0 then Duel.Overlay(c,ng,true) end
        if #tg>0 then Duel.SendtoGrave(tg,REASON_MATERIAL|REASON_XYZ) end
        if tokenct>0 then
            c:RegisterFlagEffect(OG.FLAG_XYZ_TOKEN_COUNT,RESET_EVENT|(RESETS_STANDARD&~RESET_TOFIELD)|RESET_PHASE|PHASE_END,0,1,tokenct)
        end
        g:DeleteGroup()
    end
end
function OG.AddXyzProcedure(c,mode,rank,ct)
    c:EnableReviveLimit()
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(1173)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(OG.XyzCondition(mode,rank,ct))
    e1:SetTarget(OG.XyzTarget(mode,rank,ct))
    e1:SetOperation(OG.XyzOperation(mode,rank,ct))
    e1:SetValue(SUMMON_TYPE_XYZ)
    c:RegisterEffect(e1)
    -- If a Token substituted for a material, replace it with the top card of the Deck after the Summon succeeds.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(function(e)
        return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetHandler():GetFlagEffect(OG.FLAG_XYZ_TOKEN_COUNT)>0
    end)
    e2:SetOperation(function(e,tp)
        local xc=e:GetHandler()
        local ct=xc:GetFlagEffectLabel(OG.FLAG_XYZ_TOKEN_COUNT) or 0
        xc:ResetFlagEffect(OG.FLAG_XYZ_TOKEN_COUNT)
        if ct<=0 then return end
        local g=Duel.GetDecktopGroup(tp,math.min(ct,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)))
        if #g>0 then
            Duel.DisableShuffleCheck()
            Duel.Overlay(xc,g)
        end
    end)
    c:RegisterEffect(e2)
    -- This Xyz Monster can count its Rank as its Level for a Reptile Ritual Summon.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_RITUAL_LEVEL)
    e3:SetValue(function(e,rc)
        if rc and rc:IsRace(RACE_REPTILE) then return e:GetHandler():GetRank() end
        return 0
    end)
    c:RegisterEffect(e3)
end

function OG.RegisterTokenRestrictions(token,source)
    local e1=Effect.CreateEffect(source or token)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e1:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_LINK))
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    token:RegisterEffect(e1,true)
end
function OG.CreateToken(tp,source,pos)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return nil end
    local token=Duel.CreateToken(tp,OG.TOKEN)
    OG.RegisterTokenRestrictions(token,source)
    if Duel.SpecialSummon(token,0,tp,tp,false,false,pos or POS_FACEUP_DEFENSE)>0 then
        return token
    end
    return nil
end
function OG.MakeTokenUnreleasableThisTurn(token,source)
    for _,code in ipairs({EFFECT_UNRELEASABLE_SUM,EFFECT_UNRELEASABLE_NONSUM}) do
        local e=Effect.CreateEffect(source or token)
        e:SetType(EFFECT_TYPE_SINGLE)
        e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
        e:SetCode(code)
        e:SetValue(1)
        e:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
        token:RegisterEffect(e,true)
    end
end

function OG.CanCreateLaunchHarnessToken(tp)
    return Duel.GetFlagEffect(tp,OG.FLAG_LAUNCH_HARNESS_TOKEN)==0
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function OG.CreateLaunchHarnessToken(tp,source)
    if not OG.CanCreateLaunchHarnessToken(tp) then return nil end
    local token=OG.CreateToken(tp,source)
    if token then Duel.RegisterFlagEffect(tp,OG.FLAG_LAUNCH_HARNESS_TOKEN,RESET_PHASE|PHASE_END,0,1) end
    return token
end

function OG.RegisterRitualLeftFieldTracker(c)
    local e=Effect.CreateEffect(c)
    e:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
    e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e:SetCode(EVENT_TO_GRAVE)
    e:SetCondition(function(e)
        local rc=e:GetHandler()
        return rc:IsPreviousLocation(LOCATION_MZONE)
    end)
    e:SetOperation(function(e)
        e:GetHandler():RegisterFlagEffect(OG.FLAG_RITUAL_LEFT_FIELD,RESET_PHASE|PHASE_END,0,1)
    end)
    c:RegisterEffect(e)
end

function OG.IsOurogearContinuousST(c)
    return c:IsSetCard(OG.SET) and c:IsType(TYPE_CONTINUOUS) and (c:IsSpell() or c:IsTrap())
end
function OG.IsOurogearMonster(c)
    return c:IsMonster() and c:IsSetCard(OG.SET)
end
function OG.IsOurogearST(c)
    return c:IsSpellTrap() and c:IsSetCard(OG.SET)
end
