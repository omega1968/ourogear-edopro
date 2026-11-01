-- Ourogear Suppression Grid
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c); e0:SetType(EFFECT_TYPE_ACTIVATE); e0:SetCode(EVENT_FREE_CHAIN); c:RegisterEffect(e0)
    -- Change opponent's newly Special Summoned Attack Position monsters to Defense Position
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS); e1:SetCode(EVENT_SPSUMMON_SUCCESS); e1:SetRange(LOCATION_SZONE); e1:SetCondition(s.poscon); e1:SetOperation(s.posop); c:RegisterEffect(e1)
    -- At 4+ Defense Position monsters, opponent cannot activate effects of Defense Position monsters
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD); e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET); e2:SetCode(EFFECT_CANNOT_ACTIVATE); e2:SetRange(LOCATION_SZONE); e2:SetTargetRange(0,1)
    e2:SetCondition(s.lockcon); e2:SetValue(s.aclimit); c:RegisterEffect(e2)
end
function s.posfilter(c,tp)
    return c:IsSummonPlayer(1-tp) and c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE)
        and c:IsFaceup() and c:IsAttackPos() and not c:IsType(TYPE_LINK) and c:IsCanChangePosition()
end
function s.poscon(e,tp,eg) return eg:IsExists(s.posfilter,1,nil,tp) end
function s.posop(e,tp,eg)
    local c=e:GetHandler(); local fid=c:GetFieldID()
    local g=eg:Filter(s.posfilter,nil,tp)
    for tc in g:Iter() do
        if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)>0 then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE); e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION); e1:SetLabel(fid); e1:SetLabelObject(c)
            e1:SetCondition(function(e)
                local sc=e:GetLabelObject()
                return sc and sc:IsFaceup() and sc:IsLocation(LOCATION_SZONE) and sc:GetFieldID()==e:GetLabel()
            end)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end
function s.deffilter(c) return c:IsDefensePos() end
function s.lockcon(e,tp) return Duel.GetMatchingGroupCount(s.deffilter,tp,0,LOCATION_MZONE,nil)>=4 end
function s.aclimit(e,re,tp)
    local rc=re:GetHandler()
    return re:IsMonsterEffect() and rc:IsControler(tp) and rc:IsLocation(LOCATION_MZONE) and rc:IsFaceup() and rc:IsDefensePos()
end
