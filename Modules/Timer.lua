local addonName, TC = ...

local currentTime = nil 
local timerFrame = CreateFrame("Frame")
local lastBeat = 0

-- ============================================================
-- HELPERS
-- ============================================================

function TC.RestoreTimer()
    if TokenCoreDB.remainingTime then
        currentTime = TokenCoreDB.remainingTime
        TC.Print("Timer restored: " .. TC.FormatTime(currentTime))
    else
        TC.ResetTimer()
    end
end

function TC.ResetTimer()
    local duration = TokenCoreDB.timerDuration or 300
    currentTime = duration
    TokenCoreDB.remainingTime = currentTime
    TC.UpdateTimerText(TC.FormatTime(currentTime), 1, 1, 1)
end

function TC.SetTimerVal(seconds)
    currentTime = seconds
    TokenCoreDB.remainingTime = currentTime
    TC.UpdateTimerText(TC.FormatTime(currentTime))
    TC.Print("Debug: Timer manuell gesetzt auf " .. seconds .. "s")
end

function TC.FormatTime(seconds)
    if not seconds then return "00:00" end
    local m = math.floor(seconds / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d", m, s)
end

-- ============================================================
-- TIMER LOOP
-- ============================================================

timerFrame:SetScript("OnUpdate", function(self, elapsed)
    if not TokenCoreDB or not TokenCoreDB.setupComplete then return end
    
    -- 1. GAME OVER CHECK
    if TokenCoreDB.isDead then
        TC.UpdateTimerText("YOU'VE DIED", 1, 0, 0)
        TC.UpdateCurseText(nil)
        return
    end

    -- 2. CURSE INFO UPDATE
    if TokenCoreDB.decayEnabled then
        local currentLvl = UnitLevel("player")
        local remainder = currentLvl % 10
        local levelsLeft = 10 - remainder
        
        local r, g, b = 0.8, 0.4, 1
        if levelsLeft <= 1 then r, g, b = 1, 0.2, 0.2 end
        
        TC.UpdateCurseText("Curse in: " .. levelsLeft .. " Lvl", r, g, b)
    else
        TC.UpdateCurseText(nil)
    end

    -- 3. TIMER INFO UPDATE
    
    if TokenCoreDB.timerEnabled == false then
        TC.UpdateTimerText("")
        return
    end

    if currentTime == nil then
        TC.RestoreTimer()
        return
    end

    -- Safezones
    if IsResting() or UnitOnTaxi("player") then
        TC.UpdateTimerText("SAFEZONE", 0, 1, 1) -- Cyan
        return 
    end

    currentTime = currentTime - elapsed
    TokenCoreDB.remainingTime = currentTime

    if currentTime <= 10 then
        TC.UpdateTimerText(TC.FormatTime(currentTime), 1, 0, 0)
        
        local interval = 1.0
        if currentTime <= 5 then interval = 0.5 end
        if (GetTime() - lastBeat) >= interval then
            PlaySoundFile("Sound\\Interface\\AlarmClockWarning3.ogg", "Master")
            lastBeat = GetTime()
        end
    else
        TC.UpdateTimerText(TC.FormatTime(currentTime), 1, 1, 1)
    end

    if currentTime <= 0 then
        TC.ShowNotification("TIME'S UP!", "The adrenaline stops your heart.", "Interface\\Icons\\Spell_Holy_BorrowedTime", 8959)
        TC.RemoveToken()
        TC.ResetTimer()
    end
end)