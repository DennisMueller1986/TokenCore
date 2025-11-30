local addonName, TC = ...

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_DEAD")
eventFrame:RegisterEvent("PLAYER_XP_UPDATE")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventFrame:RegisterEvent("QUEST_TURNED_IN")

-- NEUE EVENTS FÜR TITAN RULE:
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    
    -- ... Init & Login & Dead ... (Bleibt gleich wie vorher)
    if event == "ADDON_LOADED" and arg1 == addonName then
        if TokenCoreDB == nil then
            TokenCoreDB = {}
            for k,v in pairs(TC.defaults) do TokenCoreDB[k] = v end
            TC.Print("DB initialized.")
        end
    end

    if event == "PLAYER_LOGIN" then
        if not TokenCoreDB then return end
        if TC.CreateMinimapButton then TC.CreateMinimapButton() end
        if TokenCoreDB.setupComplete == false then
            if TC.ShowSetupWizard then TC.ShowSetupWizard() end
        else
            TC.Print("Mode active: " .. (TokenCoreDB.mode or "Unknown"))
            if TC.CreateHUD then TC.CreateHUD() end
            if TC.RestoreTimer then TC.RestoreTimer() end 
            if TokenCoreDB.isDead then TC.Print("WARNING: Game Over!") end
        end
    end

    if event == "PLAYER_DEAD" then
        if TC.HandlePlayerDeath then TC.HandlePlayerDeath() end
    end

    if event == "PLAYER_XP_UPDATE" then
        if TokenCoreDB and TokenCoreDB.timerEnabled then
             if TC.ResetTimer then 
                TC.ResetTimer() 
            end
        end
    end

    -- ============================================================
    -- NEUE LOGIK: MOB SCANNEN
    -- ============================================================
    if event == "PLAYER_TARGET_CHANGED" then
        if TC.ScanUnit then TC.ScanUnit("target") end
    end
    
    if event == "UPDATE_MOUSEOVER_UNIT" then
        if TC.ScanUnit then TC.ScanUnit("mouseover") end
    end

    -- ============================================================
    -- NEUE LOGIK: KAMPF LOG PRÜFEN (Mob Tod)
    -- ============================================================
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
        
        if subevent == "UNIT_DIED" then
            
            -- 1. Check für Rare Kills (Mechanics.lua)
            if TC.CheckKill then 
                TC.CheckKill(destGUID) 
            end

            -- 2. Check für Achievements (Achievements.lua) <-- NEU
            if TC.CheckAchievementKill then
                TC.CheckAchievementKill(destGUID)
            end
            
        end
    end

    -- NEU: QUEST ABGEGEBEN
    if event == "QUEST_TURNED_IN" then
        local questID = arg1 -- arg1 ist die questID beim Turn-In Event
        if TC.CheckQuestComplete then TC.CheckQuestComplete(questID) end
    end

    -- NEU: LEVEL UP
    if event == "PLAYER_LEVEL_UP" then
        local newLevel = arg1
        if TC.CheckLevelUp then TC.CheckLevelUp(newLevel) end
    end
end)