-- Ourogear Sovereign, Crown of the Endless Gale
if not Ourogear then Duel.LoadScript("ourogear.lua") end
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Ourogear.RegisterRitualLeftFieldTracker(c)
    -- Opponent's monsters lose 600 ATK/DEF for each other monster they control
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetValue(s.statval)
    c:RegisterEffect(e1)
    local e1b=e1:Clone(); e1b:SetCode(EFFECT_UPDATE_DEFENSE); c:RegisterEffect(e1b)
    -- Once per Chain, opponent chooses to negate their effect or temporarily lose a random Extra Deck card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DISABLE|CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_F)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
    e2:SetCondition(s.choicecon)
    e2:SetOperation(s.choiceop)
    c:RegisterEffect(e2)
    -- Activated effects of your Ourogear monsters cannot be negated
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_INACTIVATE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.chainfilter)
    c:RegisterEffect(e3)
    local e4=e3:Clone(); e4:SetCode(EFFECT_CANNOT_DISEFFECT); c:RegisterEffect(e4)
end
s.listed_series={Ourogear.SET}
function s.statval(e,c)
    local ct=Duel.GetMatchingGroupCount(Card.IsMonster,c:GetControler(),LOCATION_MZONE,0,c)
    return -600*ct
end
function s.choicecon(e,tp,eg,ep,ev,re,r,rp)
    if rp~=1-tp then return false end
    return Duel.IsChainDisablable(ev) or Duel.GetFieldGroupCount(1-tp,LOCATION_EXTRA,0)>0
end
function s.choiceop(e,tp,eg,ep,ev,re,r,rp)
    local canneg=Duel.IsChainDisablable(ev)
    local exg=Duel.GetFieldGroup(1-tp,LOCATION_EXTRA,0)
    local canban=#exg>0 and Duel.IsPlayerCanRemove(tp)
    local op
    if canneg and canban then
        op=Duel.SelectEffect(1-tp,{true,aux.Stringid(id,1)},{true,aux.Stringid(id,2)})
    elseif canneg then
        op=1
    elseif canban then
        op=2
    else
        return
    end
    if op==1 then
        Duel.NegateEffect(ev)
        return
    end
    local rg=exg:RandomSelect(1-tp,1)
    if #rg==0 then return end
    local activation_turn=Duel.GetTurnCount()
    local opponent=1-tp
    aux.RemoveUntil(
        rg,POS_FACEDOWN,REASON_EFFECT,PHASE_END,id,e,tp,s.exretop,
        function()
            return Duel.GetTurnPlayer()==opponent and Duel.GetTurnCount()>activation_turn
        end,
        RESET_PHASE|PHASE_END,3
    )
end
function s.exretop(rg,e,tp)
    local g=rg:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
    if #g==0 then return end
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    Duel.ShuffleExtra(1-tp)
end
function s.chainfilter(e,ct)
    local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
    if not te then return false end
    local tc=te:GetHandler()
    return Chain.IsTriggeringControler(ct,e:GetHandlerPlayer()) and tc:IsMonster() and tc:IsSetCard(Ourogear.SET)
end
