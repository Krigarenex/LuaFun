---- Start in Alkharid bank and have Shrimp, Trout, Sweetcorn and Desert Sole inside your bank.
---- Level 1-15: Shrimp. You need to cook 50 ish (not burnt) to reach lvl 15
---- Level 15-28: Trout. You need to cook 100 ish (not burnt) to reach lvl 28
---- Level 28-52: Sweetcorn. You need to cook 1000 ish (not burnt) to reach lvl 52
---- Level 52-99: Desert Sole. Ofcourse its not optimal up to 99 this strat but up to 80 its recommended to run Desert soles. Not sure how many.
---- Thamls Higgins for this absolutely fantastic GUI. 


local API = require("api")
local startTime = os.time()
local startXp = API.GetSkillXP("COOKING")
local skill = "COOKING"
local currentlvl = API.XPLevelTable(API.GetSkillXP(skill))
local foodID = {shrimp = 317, 
trout = 335, 
sweetcorn = 5986, 
DesertSole = 40287}
-- Rounds a number to the nearest integer or to a specified number of decimal places.
local function round(val, decimal)
    if decimal then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

-- Format a number with commas as thousands separator
local function formatNumberWithCommas(amount)
    local formatted = tostring(amount)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

function formatNumber(num)
    if num >= 1e6 then
        return string.format("%.1fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.1fK", num / 1e3)
    else
        return tostring(num)
    end
end

-- Format script elapsed time to [hh:mm:ss]
local function formatElapsedTime(startTime)
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = elapsedTime % 60
    return string.format("[%02d:%02d:%02d]", hours, minutes, seconds)
end

local function printProgressReport(final)
    local skill = "COOKING"
    local currentXp = API.GetSkillXP(skill)
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - startXp);
    local xpPH = round((diffXp * 60) / elapsedMinutes);
    local time = formatElapsedTime(startTime)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    IGP.radius = 1.0
    IGP.string_value = time .. " | " .. string.lower(skill):gsub("^%l", string.upper) .. ": " .. currentLevel .." | XP/H: " .. formatNumber(xpPH) .. " | XP: " .. formatNumber(diffXp)
end

local function setupGUI()
    IGP = API.CreateIG_answer()
    IGP.box_start = FFPOINT.new(5, 5, 0)
    IGP.box_name = "PROGRESSBAR"
    IGP.colour = ImColor.new(116, 2, 179);
    IGP.string_value = "COOKING"
end

local foodThresholds = {
    { minLevel = 0, maxLevel = 14, foodID = foodID.shrimp },
    { minLevel = 15, maxLevel = 27, foodID = foodID.trout },
    { minLevel = 28, maxLevel = 51, foodID = foodID.sweetcorn },
    { minLevel = 52, maxLevel = 100, foodID = foodID.DesertSole }
}

local function withdrawFood()
    currentlvl = API.XPLevelTable(API.GetSkillXP(skill))
    print("We are currently lvl: " .. currentlvl)
    
    for _, foodInfo in ipairs(foodThresholds) do
        if currentlvl >= foodInfo.minLevel and currentlvl <= foodInfo.maxLevel then
            API.RandomSleep2(600, 600, 600)
            API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 517, 39, -1, 5392)
            API.RandomSleep2(600, 600, 600)
            API.DoAction_Bank(foodInfo.foodID, 7, 6112)
            print("Retrieving item with id: " .. foodInfo.foodID)
        end
    end
return false
end
function drawGUI()
    DrawProgressBar(IGP)
end

setupGUI()
while API.Read_LoopyLoop() do
    drawGUI()
    API.DoRandomEvents()
    ::continue::
    if not API.isProcessing() then
        API.DoAction_Object1(0x5,80,{ 76274 },50)
        API.RandomSleep2(1250, 1000, 1200)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(2000, 2000, 2000)
        if BankOpen2() then
            print("Bank is open, withdrawing food")
        withdrawFood()
        else goto continue
        end
            API.DoAction_Object1(0x40,0,{ 76295 },50)
            API.RandomSleep2(1250, 1000, 1200)
            API.WaitUntilMovingEnds()
            API.RandomSleep2(2000, 2000, 2000)
            API.KeyboardPress2(0x20, 50, 150)
            API.RandomSleep2(50, 100, 100)
        
    else 
        API.RandomSleep2(1200, 1200, 1200)
    end
    printProgressReport()
    API.RandomSleep2(1200, 1200, 1200) -- denna l�ste det
    -- nu fanns det mindre �n 120 energy s� den stoppa script
end