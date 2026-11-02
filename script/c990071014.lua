-- Ourogear Dominion Ark
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    Ourogear.AddXyzProcedure(c,4,4,3)
    -- Temporarily banish 1 card on the field
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
    e1:SetCost(Cost.DetachFromSelf(1))
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)
    -- The first 2 Extra Deck Special Summon attempts each turn are taxed
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DISABLE_SUMMON|CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(2)
    e2:SetCondition(s.sumcon)
    e2:SetOperation(s.sumop)
    c:RegisterEffect(e2)
end
s.listed_series={Ourogear.SET}
function s.rmfilter(c) return c:IsAbleToRemove() end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.rmfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    if Duel.Remove(tc,0,REASON_EFFECT|REASON_TEMPORARY)==0 then return end
    tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
    local g=Group.FromCards(tc); g:KeepAlive()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE|PHASE_END)
    e1:SetReset(RESET_PHASE|PHASE_END)
    e1:SetLabelObject(g)
    e1:SetOperation(function(e)
        local rg=e:GetLabelObject(); local c=rg:GetFirst(); rg:DeleteGroup()
        if c and c:GetFlagEffect(id)>0 then Duel.ReturnToField(c) end
    end)
    Duel.RegisterEffect(e1,tp)
end
function s.sumfilter(c,tp)
    return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.sumcon(e,tp,eg)
    return Duel.GetCurrentChain()==0 and eg:IsExists(s.sumfilter,1,nil,tp)
end
function s.desfilter(c) return c:IsDestructable() end
function s.sumop(e,tp,eg)
    local opp=1-tp
    local dg=Duel.GetMatchingGroup(s.desfilter,opp,LOCATION_ONFIELD,0,nil)
    if #dg>0 and Duel.SelectYesNo(opp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,opp,HINTMSG_DESTROY)
        local sg=dg:Select(opp,1,1,nil)
        if #sg>0 and Duel.Destroy(sg,REASON_EFFECT)>0 then
            return
        end
    end
    Duel.NegateSummon(eg)
end
