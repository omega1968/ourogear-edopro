Duel.LoadScript('constant.lua')
Duel.LoadScript('utility.lua')
Debug.ReloadFieldBegin(0)
Debug.SetPlayerInfo(0,8000,0,0)
Debug.SetPlayerInfo(1,8000,0,0)
local ark=Debug.AddCard(990071014,0,0,LOCATION_MZONE,0,POS_FACEUP_ATTACK,true)
Debug.AddCard(990071009,0,0,LOCATION_MZONE,1,POS_FACEUP_ATTACK,true)
local victim=Debug.AddCard(990071010,1,1,LOCATION_MZONE,0,POS_FACEUP_ATTACK,true)
local extra=Debug.AddCard(990071011,1,1,LOCATION_EXTRA,0,POS_FACEDOWN)
Debug.ReloadFieldEnd()
local run=Effect.CreateEffect(ark)
run:SetType(EFFECT_TYPE_IGNITION)
run:SetCode(EVENT_FREE_CHAIN)
run:SetRange(LOCATION_MZONE)
run:SetDescription(0x7fffff)
run:SetProperty(EFFECT_FLAG_CARD_TARGET)
run:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetCard(victim)
end)
run:SetOperation(function(e,tp)
    local register=Duel.RegisterEffect
    local delayed
    Duel.RegisterEffect=function(effect,p) delayed=effect; register(effect,p) end
    c990071014.rmop(e,tp)
    Duel.RegisterEffect=register
    assert(victim:IsLocation(LOCATION_REMOVED),'Ark did not banish its target')
    assert(delayed and delayed:GetCode()==EVENT_PHASE|PHASE_END,'Ark did not schedule a return')
    delayed:GetOperation()(delayed,tp)
    assert(victim:IsLocation(LOCATION_MZONE) and victim:IsControler(1),'Ark return callback did not restore its target')

    local disablable,turnplayer,turncount=Duel.IsChainDisablable,Duel.GetTurnPlayer,Duel.GetTurnCount
    local player=OG_TEST_VARIANT and 1 or 0
    local turn=OG_TEST_VARIANT and 2 or 1
    Duel.IsChainDisablable=function() return false end
    Duel.GetTurnPlayer=function() return player end
    Duel.GetTurnCount=function() return turn end
    delayed=nil
    Duel.RegisterEffect=function(effect,p) delayed=effect; register(effect,p) end
    c990071009.choiceop(e,tp,nil,0,1,nil,0,1)
    Duel.RegisterEffect=register
    assert(extra:IsLocation(LOCATION_REMOVED) and extra:IsFacedown(),'Sovereign did not banish exactly the Extra Deck card')
    assert(delayed,'Sovereign did not schedule a return')
    assert(not delayed:GetCondition()(delayed,tp),'Sovereign return allowed during activation turn')
    player=1
    turn=OG_TEST_VARIANT and 4 or 2
    assert(delayed:GetCondition()(delayed,tp),'Sovereign return rejected opponent next End Phase')
    delayed:GetOperation()(delayed,tp)
    assert(extra:IsLocation(LOCATION_EXTRA),'Sovereign return callback did not return card to Extra Deck')
    Duel.IsChainDisablable,Duel.GetTurnPlayer,Duel.GetTurnCount=disablable,turnplayer,turncount
    Debug.Message('PASS actions: Ark/Sovereign banishment and return callbacks; next-opponent-turn condition')
    Duel.Win(0,0x99)
end)
ark:RegisterEffect(run)
