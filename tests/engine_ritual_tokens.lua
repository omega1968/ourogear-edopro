Duel.LoadScript('constant.lua')
Duel.LoadScript('utility.lua')
Debug.ReloadFieldBegin(0)
Debug.SetPlayerInfo(0,8000,0,0)
Debug.SetPlayerInfo(1,8000,0,0)
local driver=Debug.AddCard(990071018,0,0,LOCATION_SZONE,0,POS_FACEUP)
local fang=Debug.AddCard(990071004,0,0,LOCATION_HAND,0,POS_FACEDOWN)
local target=Debug.AddCard(990071007,0,0,LOCATION_DECK,0,POS_FACEDOWN)
Debug.AddCard(990071007,0,0,LOCATION_HAND,0,POS_FACEDOWN)
if OG_TEST_VARIANT then Debug.AddCard(990071017,0,0,LOCATION_SZONE,1,POS_FACEUP) end
Debug.ReloadFieldEnd()
local tokens={}
local startup=Effect.CreateEffect(driver)
startup:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
startup:SetCode(EVENT_STARTUP)
startup:SetOperation(function(e,tp)
    for i=1,(OG_TEST_VARIANT and 1 or 2) do
        tokens[i]=assert(Ourogear.CreateToken(0,driver),'Token creation failed')
    end
    local pool=Duel.GetRitualMaterial(0)
    for _,token in ipairs(tokens) do
        assert(token:GetLevel()==4,'Ritual substitution changed printed Level')
        assert(token:IsPosition(OG_TEST_TOKEN_POSITION=='defense' and POS_FACEUP_DEFENSE or POS_FACEUP_ATTACK),'Token position choice ignored')
        assert(pool:IsContains(token),'ordinary Token absent from Ritual material pool')
        assert(token:IsRace(RACE_MACHINE),'Token unexpectedly changed race')
        assert(token:GetRitualLevel(target)==(OG_TEST_VARIANT and ((4<<16)|8) or 4),'incorrect Token Ritual Level')
    end
    -- Simulate Relay's printed same-turn restriction, then remove only the fixture effects.
    Ourogear.MakeTokenUnreleasableThisTurn(tokens[1],driver)
    assert(not Duel.GetRitualMaterial(0):IsContains(tokens[1]),'Relay-locked Token incorrectly eligible')
    for _,code in ipairs({EFFECT_UNRELEASABLE_SUM,EFFECT_UNRELEASABLE_NONSUM}) do
        for _,te in ipairs({tokens[1]:GetCardEffect(code)}) do te:Reset() end
    end
    assert(Duel.GetRitualMaterial(0):IsContains(tokens[1]),'normal Token eligibility not restored')
    assert(not c990071017 or not c990071017.rittg(e,0,nil,0,0,nil,0,0,0),'Rite Circuit incorrectly used board Tokens instead of Deck Reptiles')
end)
Duel.RegisterEffect(startup,0)
local run=Effect.CreateEffect(driver)
run:SetType(EFFECT_TYPE_IGNITION)
run:SetRange(LOCATION_SZONE)
run:SetDescription(0x7fffff)
run:SetTarget(Ritual.Target(c990071004.ritparams))
run:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
    Ritual.Operation(c990071004.ritparams)(e,tp,eg,ep,ev,re,r,rp)
    assert(target:IsLocation(LOCATION_MZONE) and target:IsSummonType(SUMMON_TYPE_RITUAL),'Ritual Summon with Tokens failed')
    local mat=target:GetMaterial()
    assert(#mat==#tokens,'wrong Ritual material count')
    for _,token in ipairs(tokens) do assert(mat:IsContains(token) and not token:IsLocation(LOCATION_MZONE),'Token not used as Tribute') end
    Debug.Message('PASS actions: ordinary Tokens pay Ritual costs; Circuit one-Token Level 8; Relay exclusion; printed Levels unchanged')
    Duel.Win(0,0x99)
end)
driver:RegisterEffect(run)
