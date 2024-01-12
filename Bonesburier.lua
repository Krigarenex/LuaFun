--[[
    @name Boneburier
    @description Buries bones at GE with powder of burials
    @author Krigaren
    @version 1.0

#### Boneburier Script ####

What it Does:
--------------
Buries bones whilst using Powder of Burials. 
If there are no bones or Powder of Burials present in your inventory after attempting to withdraw, the script will halt.

Instructions:
--------------
1. Put the desired bones in your preset 1. Ensure they are in the list on line 124. If not, easily add them.
2. Ensure you have Powder of Burials inside your bank.
3. Assign the following keybinds:
   - A: Bury the selected bone (make sure it's in your hotbar)
   - X: Use Powder of Burials (ensure it's in your hotbar)
4. Grand exchange in Varrock

List of Supported Bones:
------------------------
- Regular Bone (ID: 526)
- Big Bone (ID: 532)
- Wyvern Bone (ID: 6812)
- Baby Dragon Bone (ID: 534)
- Reinforced Dragon Bone (ID: 35010)
- Frost Dragon Bone (ID: 18832)
- Dragon Bone (ID: 536)
- Hardened Dragon Bone (ID: 35008)

Note: Add more bones to the list as needed.

-------------------------------
--]]

local API = require("api")
local startTime = os.time()
local startXp = API.GetSkillXP("PRAYER")
local skill = "PRAYER"
local currentlvl = API.XPLevelTable(API.GetSkillXP(skill))

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
local function calcProgressPercentage(skill, currentExp)
  local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
  if currentLevel == 120 then return 100 end
  local nextLevelExp = XPForLevel(currentLevel + 1)
  local currentLevelExp = XPForLevel(currentLevel)
  local progressPercentage = (currentExp - currentLevelExp) / (nextLevelExp - currentLevelExp) * 100
  return math.floor(progressPercentage)
end

local function printProgressReport(final)
  local skill = "PRAYER"
  local currentXp = API.GetSkillXP(skill)
  local elapsedMinutes = (os.time() - startTime) / 60
  local diffXp = math.abs(currentXp - startXp)
  local xpPH = round((diffXp * 60) / elapsedMinutes)
  local time = formatElapsedTime(startTime)
  local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
  local xplvlup = API.XPForLevel(currentLevel +1)
  local xp99 = API.XPForLevel(99)
  local timeNeeded = round(((xplvlup - currentXp) / xpPH)*60)
  local timeneededfor99 = round(((xp99 - currentXp) / xpPH)*60)
  IGP.radius = calcProgressPercentage(skill, API.GetSkillXP(skill)) / 100
  IGP.string_value = time ..
  " | " ..
  string.lower(skill):gsub("^%l", string.upper) ..
  ": " .. currentLevel .. " | XP/H: " .. formatNumber(xpPH) .. " | XP: " .. formatNumber(diffXp)  .. " | TTL: " .. formatNumber(timeNeeded) .. "m" .. " | TTL99: " .. formatNumber(timeneededfor99) .. "m"
end

local function setupGUI()
  IGP = API.CreateIG_answer()
  IGP.box_start = FFPOINT.new(5, 5, 0)
  IGP.box_name = "PROGRESSBAR"
  IGP.colour = ImColor.new(116, 2, 179);
  IGP.string_value = "PRAYER"
end



local bones = {526, 532, 6812, 534, 35010, 18832, 536, 35008}

local function weHasBones()
  local inventory = API.ReadInvArrays33()

  for _, bone in ipairs(inventory) do
    for _, id in pairs(bones) do
    if bone.itemid1 == id then
      return true
    end
  end
end
return false
end


local function openBank()
  if not API.BankOpen2() then
  API.DoAction_NPC(0x5, API.OFF_ACT_InteractNPC_route, {3418}, 50)
  API.RandomSleep(2000, 1800, 1800)
  end
end

local function withdrawBones()
      API.RandomSleep2(1000, 1000, 1000)
      API.KeyboardPress2(0x31, 50, 150)
      API.RandomSleep2(600, 500, 800)
  end

local function withdrawPowder()
      API.RandomSleep2(800, 1000, 1000)
      API.DoAction_Bank(52805, 1, API.OFF_ACT_GeneralInterface_route)
      API.RandomSleep2(1000, 1000, 1000)
      API.KeyboardPress2(0x1B, 50, 150)
      API.RandomSleep2(2000, 2000, 2000)
      if API.InvStackSize(52805) < 1 then
        API.Write_LoopyLoop(false)
      else
      API.KeyboardPress2(0x58, 50, 150)
      API.RandomSleep2(1000, 1000, 1000)
      end
end


local function readPowderofBurial()
  local buffs = API.Buffbar_GetIDstatus(52805)
  if buffs.conv_text < 2 then
    return true
  else
    return false
  end
  end

  function drawGUI()
    DrawProgressBar(IGP)
end

setupGUI()
API.Write_LoopyLoop(true)
while API.Read_LoopyLoop() do
  drawGUI()
  API.DoRandomEvents()

  if not weHasBones() then
      openBank()

      if readPowderofBurial() then
          withdrawPowder()
          API.RandomSleep2(1200, 1200, 1400)
      else
          withdrawBones()
          API.RandomSleep2(1200, 1200, 1400)
          if not weHasBones() then
              break
          end
      end
  else
      API.KeyboardPress2(0x41, 50, 150)
  end

  printProgressReport()
  API.RandomSleep2(200, 200, 250)
end
