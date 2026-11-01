Duel.LoadScript('constant.lua')
Duel.LoadScript('utility.lua')
Debug.ReloadFieldBegin(0)
Debug.SetPlayerInfo(0,8000,0,0)
Debug.SetPlayerInfo(1,8000,0,0)
local tokens={}
for i=1,3 do tokens[i]=Debug.AddCard(990071099,0,0,LOCATION_MZONE,i-1,POS_FACEUP_DEFENSE) end
local siege=Debug.AddCard(990071013,0,0,LOCATION_EXTRA,0,POS_FACEDOWN)
for i=1,3 do Debug.AddCard(990071002,0,0,LOCATION_DECK,0,POS_FACEDOWN) end
Debug.ReloadFieldEnd()
if OG_TEST_VARIANT then
    local negate=Effect.CreateEffect(siege)
    negate:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
    negate:SetCode(EVENT_SPSUMMON)
    negate:SetCondition(function(e,tp,eg) return eg:IsContains(siege) end)
    negate:SetOperation(function(e,tp,eg) Duel.NegateSummon(eg) end)
    Duel.RegisterEffect(negate,1)
end
local run=Effect.CreateEffect(siege)
run:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
run:SetCode(EVENT_STARTUP)
run:SetOperation(function(e,tp)
    local materials=Group.FromCards(table.unpack(tokens))
    Duel.XyzSummon(0,siege,nil,materials,3,3)
    for _,token in ipairs(tokens) do assert(not token:IsLocation(LOCATION_MZONE),'Token not consumed') end
    if OG_TEST_VARIANT then
        assert(siege:IsLocation(LOCATION_GRAVE),'test Summon was not negated')
        assert(Duel.GetFieldGroupCount(0,LOCATION_DECK,0)==3,'negated Summon incorrectly attached top-deck cards')
        assert(siege:GetFlagEffect(Ourogear.FLAG_XYZ_TOKEN_COUNT)==0,'negated Summon left stale Token count')
    else
        assert(siege:IsLocation(LOCATION_MZONE),'all-Token Rank 8 procedure failed')
        assert(siege:GetOverlayCount()==3,'three Tokens did not attach exactly three cards')
        assert(siege:GetAttack()==3900,'Siege material stat scaling failed')
        assert(Duel.GetFieldGroupCount(0,LOCATION_DECK,0)==0,'wrong number of cards attached from Deck')
    end
    Debug.Message('PASS actions: all-Token Rank 8 Summon and negated-Summon cleanup')
    Duel.Win(0,0x99)
end)
Duel.RegisterEffect(run,0)
