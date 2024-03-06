local API = require("api")
local startTime, afk = os.time(), os.time()
local idleTimeThreshold = math.random(153, 189) -- Random number between 180 (3 minutes) and 300 (5 minutes)
-- have eatfood on action bar
-- have wars tp on action bar
-- use preset 1, it will load last preset if available, if not it will open bank first time
-- It will teleport to Wars when less than this amount of food

local foodName = "Rocktail"
local foodAmount = 1


--[[
uncut onyx 6571
crimson charm 12160
medium blunt orikalkum salvage 52121 -- 52122
onyx dust 42954
uncut dragonstone 1631 -- noted 1632
sirenic scale 29863
dark nilas 52019
scripture of wen 52115
leng artefact 52021
water battlestaff 1395
hydrix bolt tip  31867

Crystal triskelion fragment 1 28547
Crystal triskelion fragment 2 28548
crystal triskelion fragment 3 28549
crystal triskelion hela 28550
summoning focus 32821
crystal key noted - 990
water talisman
Elder drove t1 51798
Elder trove t2 51799
Elder trove t3 51800
]] --

--- add whichever item ID you want it to loot, ive added as many as i had motivation for
local itemIdsToLoot = {
    28550, 1395, 6571, 1445, 28550, 51800, 51808, 12163, 12160, 51817, 52018,
    1396, 52121, 42954, 1631, 29863, 52019, 52115, 52021, 32821, 1445, 1632,
    52122, 31867, 990, 28547, 28548, 28549, 51800, 51799, 51798
}

local LOCATIONS = {
    warsRetreat = {x = 3294, y = 10128, radius = 8},
    entranceArch = {x = 1753, y = 1111, radius = 15}
}

local IDS = {
    PORTALS = {
        firstportal = {121370},
        secondportal = {121338},
        thirdportal = {121341}
    },
    BANKCHEST = {114750},
    ALTAR = {114748},
    FOOD = {rocktail = {15272}},
    ARCH_GLACOR = {28241}
}

local function antiIdleTask()
    local currentTime = os.time()
    local elapsedTime = os.difftime(currentTime, afk)
    if elapsedTime >= idleTimeThreshold then
        API.PIdle2()
        afk = os.time()
        idleTimeThreshold = math.random(110, 180)
        print("Reset Timer & Threshold")
    end
end

local function isAtLocation(location)
    return API.PInArea(location.x, location.radius, location.y, location.radius, 0)
end

local function needBank() 
    return API.InvItemcount_String(foodName) < foodAmount or API.InvFull_()
end

local function retrieveLastPreset() 
    return API.DoAction_Object1(0x33, API.OFF_ACT_GeneralObject_route3, IDS.BANKCHEST, 50)
end

local function isAtArchGlacor()
    local portal = API.GetAllObjArray1(IDS.PORTALS.thirdportal, 20, {0})
    return #portal > 0
end

local function findNpc(npcid, distance)
    local distance = distance or 20
    return API.GetAllObjArrayInteract({npcid}, distance, {1})[1]
end

local function healthCheck()
    local hp = API.GetHPrecent()
    local eatFoodAB = API.GetABs_name1("Eat Food")
    if hp < 60 then
        if eatFoodAB.id ~= 0 and eatFoodAB.enabled then
            print("Eating")
            API.DoAction_Ability_Direct(eatFoodAB, 1, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(600, 600, 600)
        end
        elseif hp < 20 or needBank() then
            print("Teleporting out")
            API.DoAction_Ability("War's Retreat Teleport", 1, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(3000, 3000, 3000)
    end
end

local timer = {
    InterfaceComp5.new(861, 0, -1, -1, 0), InterfaceComp5.new(861, 2, -1, 0, 0),
    InterfaceComp5.new(861, 4, -1, 2, 0), InterfaceComp5.new(861, 8, -1, 4, 0)
}

local function timerHitZero()
    local result = API.ScanForInterfaceTest2Get(false, timer)
    if result and #result > 0 and result[1].textids then
        local textids = result[1].textids
        local startIndex, endIndex = string.find(textids, "00:00")
        if startIndex then
            return true
        else
            return false
        end
    else
        print("No result or textids field not found.")
    end
end

local function hasTarget()
    local interacting = API.ReadLpInteracting()
    if interacting.Id ~= 0 then
        return true
    else
        return false
    end
end

local function standInFrontOfArchGlacor()
    local portals = API.GetAllObjArray1({121341}, 50, {0})
    if #portals > 0 then
        local portal = portals[1]
        if portal.Tile_XYZ then
            local newTileX = portal.Tile_XYZ.x + 13
            local newTileY = portal.Tile_XYZ.y - 4
            local newTileZ = portal.Tile_XYZ.z
            API.RandomSleep2(300, 300, 400)
            if not API.PInArea(newTileX, 5, newTileY, 5, newTileZ) then
                API.DoAction_Tile(WPOINT.new(newTileX, newTileY, newTileZ))
                API.RandomSleep2(300, 300, 400)
            end
        end
    end
end


local function loot()
    if not API.InvFull_() then
        API.DoAction_Loot_w(itemIdsToLoot, 5, API.PlayerCoordfloat(), 10)
        API.RandomSleep2(1000, 1000, 1000)
        API.WaitUntilMovingEnds()
    end
end


local function killArchGlacor()
    if not hasTarget() and not API.CheckAnim(20) then
        API.DoAction_NPC(0x2a, 1600, IDS.ARCH_GLACOR, 50)
        API.RandomSleep2(600, 600, 600)
    end
end

local function isportalInterfaceOpen() 
    return API.VB_FindPSett(2874, 1, 0).state == 18
end

while API.Read_LoopyLoop() do
    if isAtArchGlacor() then goto continue end

    if isAtLocation(LOCATIONS.warsRetreat) and not API.ReadPlayerMovin2() then
        if needBank() then
            if API.BankOpen2() then
                API.KeyBoardPress2(0x31, 50, 150)
                API.RandomSleep2(600, 600, 600)
            end
            if API.VB_FindPSettinOrder(9932, 0).state == 1 then
                API.DoAction_Object1(0x33, API.OFF_ACT_GeneralObject_route3, IDS.BANKCHEST, 50)
                API.RandomSleep2(600, 500, 600)
                API.WaitUntilMovingEnds()
            else
                API.DoAction_Object1(0x2e, API.OFF_ACT_GeneralObject_route1, IDS.BANKCHEST, 50)
                API.RandomSleep2(600, 500, 600)
                API.WaitUntilMovingEnds()
            end
        else
            API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, IDS.PORTALS.firstportal, 50)
            API.RandomSleep2(600, 500, 600)
            API.WaitUntilMovingEnds()
        end
    end

    if isAtLocation(LOCATIONS.entranceArch) then
        if isportalInterfaceOpen() and not API.ReadPlayerMovin2() then
            API.DoAction_Interface(0x24, API.OFF_ACT_GeneralInterface_route, 1, 1591, 60, -1, 3808)
            API.RandomSleep2(600, 600, 400)
        else
            API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, IDS.PORTALS.secondportal, 50)
            API.RandomSleep2(600, 600, 400)
            API.WaitUntilMovingEnds()
        end
    end

    ::continue::
    if isAtArchGlacor() then
        antiIdleTask()
        if hasTarget() then 
            killArchGlacor()
            healthCheck()
        else
            loot()
            standInFrontOfArchGlacor()
        end
        if timerHitZero() then
            API.DoAction_Ability("War's Retreat Teleport", 1, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(3000, 3000, 3000)
        end
    end

    API.RandomSleep2(300, 300, 300)
end
