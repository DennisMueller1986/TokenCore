local addonName, TC = ...

-- State
local achWindow, scrollChild = nil, nil
local currentCategory = "ELITE" 

-- ============================================================
-- KONFIGURATION & BLACKLIST
-- ============================================================

-- Tab Definitionen
local TAB_MAPPING = {
    [1] = { key = "ELITE", text = "Targets" },
    [2] = { key = "DUNGEON", text = "Dungeons" },
    [3] = { key = "SLAYER", text = "Slayer" },
    [4] = { key = "MISC", text = "Challenges" }
}

-- BLACKLIST: Diese Achievements geben KEINE Token-Belohnung
local NO_TOKEN_REWARD = {
    ["Level10"] = true,
    ["Level20"] = true,
    ["Level30"] = true,
    ["Level40"] = true,
    ["Level50"] = true,
    ["Level60"] = true
}

-- ============================================================
-- 1. HILFSFUNKTIONEN & EVENT LOGIK
-- ============================================================

local function IsEligible(ach)
    local playerFaction = UnitFactionGroup("player") 
    if ach.faction ~= "Both" and ach.faction ~= playerFaction then return false end
    return true
end

local function IsMobRelevant(mobLevel)
    local playerLevel = UnitLevel("player")
    if mobLevel == -1 then return true end 
    local grayLimit
    if playerLevel <= 5 then grayLimit = 0
    elseif playerLevel <= 39 then grayLimit = playerLevel - (math.floor(playerLevel / 10) + 5)
    else grayLimit = playerLevel - (math.floor(playerLevel / 5) + 1) end
    return mobLevel > grayLimit
end

local function GrantAchievement(ach)
    if not TokenCoreDB.completedAchievements then TokenCoreDB.completedAchievements = {} end
    if TokenCoreDB.completedAchievements[ach.achId] == true then return end

    local playerLevel = UnitLevel("player")
    if ach.levelCap and playerLevel >= ach.levelCap then
        TokenCoreDB.completedAchievements[ach.achId] = "FAILED"
        return
    end

    TokenCoreDB.completedAchievements[ach.achId] = true
    
    local iconPath = ach.icon or 134400
    if TC.ShowNotification then
        TC.ShowNotification("ACHIEVEMENT UNLOCKED!", ach.title, iconPath, 12892)
    else
        PlaySound(12892); TC.Print("|cffFFD700ACHIEVEMENT: " .. ach.title .. "!|r")
    end

    -- LOGIK: Token nur geben, wenn es erlaubt ist UND nicht auf der Blacklist steht
    local rewardsAllowed = TokenCoreDB.regenEnabled
    local isBlacklisted = NO_TOKEN_REWARD[ach.achId]

    if rewardsAllowed and not isBlacklisted then
        if TC.AddToken then 
            for i=1, ach.rewardTokens do TC.AddToken() end
        end
    end
    
    if TC.RefreshAchievementWindow then TC.RefreshAchievementWindow() end
end

-- Event Checker
function TC.CheckAchievementKill(destGUID)
    if not destGUID or not TC.AchievementsDB then return end
    local npcID = tonumber(select(6, strsplit("-", destGUID)))
    if not npcID then return end
    
    local mobName, mobLevel, mobType = UnitName("target"), UnitLevel("target"), UnitCreatureType("target")
    if UnitGUID("target") ~= destGUID then 
        if UnitGUID("mouseover") == destGUID then
            mobName, mobLevel, mobType = UnitName("mouseover"), UnitLevel("mouseover"), UnitCreatureType("mouseover")
        end
    end
    if not mobLevel then mobLevel = 0 end

    for _, ach in ipairs(TC.AchievementsDB) do
        if IsEligible(ach) then
            if ach.type == "SLAYER" and mobName then
                if not TokenCoreDB.slayerProgress then TokenCoreDB.slayerProgress = {} end
                if not TokenCoreDB.completedAchievements[ach.achId] and IsMobRelevant(mobLevel) then
                    local match = false
                    if ach.slayerName and string.find(mobName, ach.slayerName) then match = true end
                    if ach.slayerCreatureType and mobType == ach.slayerCreatureType then match = true end
                    if match then
                        local current = TokenCoreDB.slayerProgress[ach.achId] or 0
                        current = current + 1
                        TokenCoreDB.slayerProgress[ach.achId] = current
                        if TC.RefreshAchievementWindow then TC.RefreshAchievementWindow() end
                        if current >= ach.slayerCount then GrantAchievement(ach) end
                    end
                end
            end
            if ach.targetNpcId == npcID and not ach.requiredQuestId and ach.type ~= "SLAYER" then GrantAchievement(ach) end
        end
    end
end

function TC.CheckQuestComplete(questID)
    if not TC.AchievementsDB then return end
    for _, ach in ipairs(TC.AchievementsDB) do
        if IsEligible(ach) and ach.requiredQuestId == questID then GrantAchievement(ach) end
    end
end

function TC.CheckLevelUp(newLevel)
    if not TC.AchievementsDB then return end
    for _, ach in ipairs(TC.AchievementsDB) do
        if IsEligible(ach) and ach.customCheck then if ach.customCheck() then GrantAchievement(ach) end end
    end
end


-- ============================================================
-- 3. GUI: DAS FENSTER IM OG BLIZZARD STYLE
-- ============================================================

local tabs = {}

local function SelectTab(id)
    PanelTemplates_SetTab(achWindow, id)
    currentCategory = TAB_MAPPING[id].key
    
    -- Subtitle wird jetzt in RefreshAchievementWindow gesetzt, 
    -- damit der Count immer aktuell ist.
    TC.RefreshAchievementWindow()
end

local function CreateAchWindow()
    if achWindow then return end
    
    -- 1. FRAME
    achWindow = CreateFrame("Frame", "TokenCoreAchFrame", UIParent)
    achWindow:SetSize(384, 512) 
    achWindow:SetPoint("CENTER")
    achWindow:EnableMouse(true); achWindow:SetMovable(true)
    achWindow:SetToplevel(true) 
    
    achWindow:RegisterForDrag("LeftButton")
    achWindow:SetScript("OnDragStart", achWindow.StartMoving)
    achWindow:SetScript("OnDragStop", achWindow.StopMovingOrSizing)
    achWindow:Hide()

    -- 2. TEXTUREN (Character Frame Style)
    local texPath = "Interface\\PaperDollInfoFrame\\UI-Character-General-"
    
    local tl = achWindow:CreateTexture(nil, "BORDER"); tl:SetSize(256, 256); tl:SetPoint("TOPLEFT", 0, 0); tl:SetTexture(texPath.."TopLeft")
    local tr = achWindow:CreateTexture(nil, "BORDER"); tr:SetSize(128, 256); tr:SetPoint("TOPRIGHT", 0, 0); tr:SetTexture(texPath.."TopRight")
    local bl = achWindow:CreateTexture(nil, "BORDER"); bl:SetSize(256, 256); bl:SetPoint("BOTTOMLEFT", 0, 0); bl:SetTexture(texPath.."BottomLeft")
    local br = achWindow:CreateTexture(nil, "BORDER"); br:SetSize(128, 256); br:SetPoint("BOTTOMRIGHT", 0, 0); br:SetTexture(texPath.."BottomRight")

    -- 3. PORTRAIT
    local portrait = achWindow:CreateTexture(nil, "ARTWORK")
    portrait:SetSize(60, 60)
    portrait:SetPoint("TOPLEFT", 7, -6)
    portrait:SetTexture("Interface\\AddOns\\TokenCore\\Media\\token_active.png") 
    
    local mask = achWindow:CreateMaskTexture()
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    mask:SetSize(60, 60)
    mask:SetPoint("TOPLEFT", 7, -6)
    portrait:AddMaskTexture(mask)

    -- 4. HAUPT-TITEL (Oben im Metall-Balken)
    achWindow.title = achWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    achWindow.title:SetPoint("TOP", achWindow, "TOP", 0, -18) 
    achWindow.title:SetText("Achievements")

    -- 5. SUB-TITEL (Der Tab Name)
    achWindow.subtitle = achWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    achWindow.subtitle:SetPoint("TOP", achWindow, "TOP", 0, -53) 
    achWindow.subtitle:SetText("Targets") 

    local closeBtn = CreateFrame("Button", nil, achWindow, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -30, -8)
    closeBtn:SetScript("OnClick", function() achWindow:Hide() end)

    -- 6. SCROLL FRAME
    local scrollFrame = CreateFrame("ScrollFrame", "TokenCoreAchScroll", achWindow, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 25, -85) 
    scrollFrame:SetPoint("BOTTOMRIGHT", -65, 85)

    scrollChild = CreateFrame("Frame")
    scrollChild:SetSize(300, 500)
    scrollFrame:SetScrollChild(scrollChild)
    achWindow.scrollChild = scrollChild
    
    -- 7. TABS
    achWindow.Tabs = {}
    achWindow.numTabs = #TAB_MAPPING

    for i, data in ipairs(TAB_MAPPING) do
        local tab = CreateFrame("Button", "$parentTab"..i, achWindow, "CharacterFrameTabButtonTemplate")
        tab:SetID(i)
        tab:SetText(data.text)
        
        if i == 1 then
            tab:SetPoint("TOPLEFT", achWindow, "BOTTOMLEFT", 15, 75)
        else
            tab:SetPoint("TOPLEFT", achWindow.Tabs[i-1], "TOPRIGHT", -16, 0)
        end
        
        tab:SetScript("OnClick", function()
            SelectTab(i)
            PlaySound(841)
        end)
        
        PanelTemplates_TabResize(tab, 0)
        achWindow.Tabs[i] = tab
    end
    
    SelectTab(1)
end

function TC.RefreshAchievementWindow()
    if not achWindow then CreateAchWindow() end
    if not TC.AchievementsDB then return end
    if not TokenCoreDB then return end

    -- Cleanup
    local regions = { scrollChild:GetRegions() }
    for _, r in ipairs(regions) do r:Hide() end
    local children = { scrollChild:GetChildren() }
    for _, c in ipairs(children) do c:Hide() end

    local completedDB = TokenCoreDB.completedAchievements or {}
    local progressDB = TokenCoreDB.slayerProgress or {}
    local playerLevel = UnitLevel("player")
    local rewardsEnabled = TokenCoreDB.regenEnabled 

    local displayList = {}
    local countDone, countTotal = 0, 0

    for _, ach in ipairs(TC.AchievementsDB) do
        if IsEligible(ach) then
            if ach.category == currentCategory then
                table.insert(displayList, ach)
                countTotal = countTotal + 1
                if completedDB[ach.achId] == true then countDone = countDone + 1 end
            end
        end
    end

    table.sort(displayList, function(a, b)
        local lvlA = a.levelCap or 999
        local lvlB = b.levelCap or 999
        return lvlA < lvlB
    end)

    local yOffset = 0 

    for _, ach in ipairs(displayList) do
        local status = completedDB[ach.achId]
        
        -- TITEL ZEILE
        local line = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        line:SetPoint("TOPLEFT", 5, yOffset)
        line:SetWidth(290)
        line:SetJustifyH("LEFT")
        
        local iconStr = "|T" .. (ach.icon or 134400) .. ":16|t"
        
        local extraInfo = ""
        if ach.type == "SLAYER" and status ~= true then
            local current = progressDB[ach.achId] or 0
            extraInfo = " |cffffffff(" .. current .. "/" .. ach.slayerCount .. ")|r"
        elseif ach.levelCap then 
            extraInfo = " |cffbbbbbb(Limit: " .. ach.levelCap .. ")|r"
        end

        local showRewardIcon = false
        if rewardsEnabled and not NO_TOKEN_REWARD[ach.achId] then
            showRewardIcon = true
        end

        if status == true then
            line:SetText(iconStr .. " |cff00FF00" .. ach.title .. "|r")
        elseif status == "FAILED" then
            line:SetText(iconStr .. " |cffFF6666" .. ach.title .. " (Failed)|r")
        else
            if ach.levelCap and playerLevel >= ach.levelCap then
                 line:SetText(iconStr .. " |cffFF6666" .. ach.title .. " (Too high level)|r")
            else
                 line:SetText(iconStr .. " |cffffffff" .. ach.title .. "|r" .. extraInfo)
            end
        end
        
        if showRewardIcon then
            local btn = CreateFrame("Button", nil, scrollChild)
            btn:SetSize(16, 16)
            local tex = btn:CreateTexture(nil, "ARTWORK")
            tex:SetAllPoints(btn)
            tex:SetTexture("Interface\\AddOns\\TokenCore\\Media\\token_active.png")
            local textWidth = line:GetStringWidth()
            btn:SetPoint("LEFT", line, "LEFT", textWidth + 8, 0)
            
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Token Reward", 1, 0.82, 0)
                GameTooltip:AddLine("Completing this achievement restores 1 Life Token.", 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end
        
        local desc = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        desc:SetPoint("TOPLEFT", 25, yOffset - 15)
        desc:SetWidth(270)
        desc:SetJustifyH("LEFT")
        desc:SetText(ach.description)
        desc:SetTextColor(0.8, 0.8, 0.8) 

        yOffset = yOffset - 40
    end
    
    -- UPDATE TITLES
    -- 1. Main Title Reset
    achWindow.title:SetText("Achievements")
    
    -- 2. Subtitle (Category Name + Count)
    local categoryName = "Unknown"
    for _, data in ipairs(TAB_MAPPING) do
        if data.key == currentCategory then
            categoryName = data.text
            break
        end
    end
    
    achWindow.subtitle:SetText(categoryName .. " (" .. countDone .. "/" .. countTotal .. ")")
    
    scrollChild:SetHeight(math.abs(yOffset) + 20)
end

function TC.ToggleAchievementWindow()
    if not achWindow then CreateAchWindow() end
    if achWindow:IsShown() then achWindow:Hide() else achWindow:Show(); TC.RefreshAchievementWindow() end
end

CreateAchWindow()

SLASH_TOKENCOREACH1 = "/tca"
SlashCmdList["TOKENCOREACH"] = function() TC.ToggleAchievementWindow() end