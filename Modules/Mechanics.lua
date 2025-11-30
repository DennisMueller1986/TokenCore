local addonName, TC = ...

-- Cache für Mob-Daten
local mobCache = {}

-- ============================================================
-- 1. TOKEN MANAGEMENT
-- ============================================================
function TC.RemoveToken()
    if TokenCoreDB.isDead then return end
    if TokenCoreDB.tokens > 0 then
        TokenCoreDB.tokens = TokenCoreDB.tokens - 1
        if TC.UpdateHUD then TC.UpdateHUD() end
        TC.ShowNotification("YOU DIED!", "Token lost. Remaining: " .. TokenCoreDB.tokens, "Interface\\Icons\\Spell_Shadow_DeathScream", 12867)
    end
    if TokenCoreDB.tokens <= 0 then
        TC.TriggerGameOver()
    end
end

function TC.AddToken()
    if TokenCoreDB.regenEnabled == false then return end

    -- REGEL 1: Wer Game Over ist, bekommt keine Belohnungen mehr! (Anti-Abuse)
    if TokenCoreDB.isDead then 
        -- TC.Print("Du bist tot. Keine Belohnung mehr möglich.") -- Optional
        return 
    end

    -- REGEL 2: Cap prüfen
    if TokenCoreDB.tokens >= TokenCoreDB.maxTokens then return end

    TokenCoreDB.tokens = TokenCoreDB.tokens + 1
    
    -- HIER KEIN 'isDead = false' MEHR! Das war der Fehler.
    
    if TC.UpdateHUD then TC.UpdateHUD() end
    
    PlaySound(619) 
    TC.ShowNotification("TOKEN REGAINED!", "Your valor is rewarded.", "Interface\\Icons\\INV_Misc_Coin_02", 619)
end

function TC.TriggerGameOver()
    TokenCoreDB.isDead = true
    TokenCoreDB.tokens = 0
    if TC.UpdateHUD then TC.UpdateHUD() end
    PlaySound(12867)
    TC.Print("|cffFF0000GAME OVER!|r Your journey ends here.")
end

function TC.HandlePlayerDeath()
    TC.RemoveToken()
end

-- ============================================================
-- 2. MOB SCANNER (PRODUCTION MODE)
-- ============================================================
function TC.ScanUnit(unitID)
    local guid = UnitGUID(unitID)
    if not guid then return end
    
    if not UnitIsPlayer(unitID) then
        local level = UnitLevel(unitID)
        local classification = UnitClassification(unitID)
        local name = UnitName(unitID)
        
        -- Nur speichern, wenn Cache leer
        if not mobCache[guid] then
            mobCache[guid] = { lvl = level, class = classification, name = name }
        end
    end
end

function TC.CheckKill(destGUID)
    -- 1. Daten holen
    local mobInfo = mobCache[destGUID]
    
    -- Fallback: Wenn Cache leer, prüfen wir das aktuelle Target
    if not mobInfo and UnitGUID("target") == destGUID then
         mobInfo = { 
            lvl = UnitLevel("target"), 
            class = UnitClassification("target"), 
            name = UnitName("target") 
         }
    end

    if not mobInfo then return end -- Mob unbekannt, Abbruch.

    local playerLevel = UnitLevel("player")
    
    -- ============================================
    -- DIE REGELN (TITAN RULE)
    -- ============================================
    
    -- A) Ist es ein würdiger Gegner? (Rare, RareElite, Boss)
    local isRareOrBoss = (mobInfo.class == "rare") or (mobInfo.class == "rareelite") or (mobInfo.class == "worldboss")
    
    -- B) Ist er stark genug? (Gleiches Level oder höher, oder Boss-Level -1)
    local isHardEnough = (mobInfo.lvl == -1) or (mobInfo.lvl >= playerLevel)

    -- C) Die Entscheidung
    if isRareOrBoss and isHardEnough then
        TC.Print("Rare Enemy Defeated: " .. mobInfo.name)
        TC.AddToken()
    end
    
    -- Cache aufräumen
    mobCache[destGUID] = nil
end

