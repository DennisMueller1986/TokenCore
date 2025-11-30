local addonName, TC = ...

-- Cache für Mob-Daten
local mobCache = {}

-- ============================================================
-- 1. TOKEN MANAGEMENT
-- ============================================================
function TC.TriggerGameOver()
    TokenCoreDB.isDead = true
    TokenCoreDB.tokens = 0
    if TC.UpdateHUD then TC.UpdateHUD() end
    
    -- NEU: Das definitive Game Over Banner
    PlaySound(12867) -- Death Sound
    TC.ShowNotification("GAME OVER", "Your journey ends here.", "Interface\\Icons\\Spell_Shadow_DeathScream", 12867)
    
    TC.Print("|cffFF0000GAME OVER!|r Your journey ends here.")
end

function TC.RemoveToken(customTitle, customMsg, customIcon)
    if TokenCoreDB.isDead then return end
    
    if TokenCoreDB.tokens > 0 then
        TokenCoreDB.tokens = TokenCoreDB.tokens - 1
        
        if TC.UpdateHUD then TC.UpdateHUD() end
        
        -- Ist es das allerletzte Token?
        local isLastToken = (TokenCoreDB.tokens == 0)
        
        -- LOGIK FÜR BENACHRICHTIGUNGEN:
        
        -- Fall A: Wir haben einen speziellen Grund (z.B. Rule Violation)
        if customTitle then
            -- Den Grund zeigen wir IMMER an (z.B. "Forbidden Item")
            TC.ShowNotification(customTitle, customMsg, customIcon or "Interface\\Icons\\INV_Hammer_05", 12867)
            
        -- Fall B: Kein spezieller Grund (Normaler Tod / Timer)
        else
            -- Wenn es NICHT das letzte Token ist, zeigen wir "You Died"
            -- (Wenn es das letzte ist, kommt gleich eh das "GAME OVER" Banner aus TriggerGameOver, 
            --  daher sparen wir uns hier das doppelte Banner)
            if not isLastToken then
                local msg = "Token lost. Remaining: " .. TokenCoreDB.tokens
                TC.ShowNotification("YOU DIED!", msg, "Interface\\Icons\\Spell_Shadow_DeathScream", 12867)
            end
        end
    end
    
    if TokenCoreDB.tokens <= 0 then
        TC.TriggerGameOver()
    end
end

function TC.AddToken()
    if TokenCoreDB.regenEnabled == false then return end

    -- Wer tot ist, bleibt tot (Anti-Abuse)
    if TokenCoreDB.isDead then return end

    -- Cap prüfen
    if TokenCoreDB.tokens >= TokenCoreDB.maxTokens then return end

    TokenCoreDB.tokens = TokenCoreDB.tokens + 1
    
    if TC.UpdateHUD then TC.UpdateHUD() end
    
    PlaySound(619) 
    TC.ShowNotification("TOKEN REGAINED!", "Your valor is rewarded.", "Interface\\Icons\\INV_Misc_Coin_02", 619)
end

function TC.HandlePlayerDeath()
    -- Hier rufen wir RemoveToken ohne Argumente auf (Standard "You Died")
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
    local mobInfo = mobCache[destGUID]
    
    -- Fallback: Target prüfen
    if not mobInfo and UnitGUID("target") == destGUID then
         mobInfo = { 
            lvl = UnitLevel("target"), 
            class = UnitClassification("target"), 
            name = UnitName("target") 
         }
    end

    if not mobInfo then return end 

    local playerLevel = UnitLevel("player")
    
    -- A) Ist es ein würdiger Gegner? (Rare, RareElite, Boss)
    local isRareOrBoss = (mobInfo.class == "rare") or (mobInfo.class == "rareelite") or (mobInfo.class == "worldboss")
    
    -- B) Ist er stark genug? (Gleiches Level oder höher, oder Boss-Level -1)
    local isHardEnough = (mobInfo.lvl == -1) or (mobInfo.lvl >= playerLevel)

    -- C) Die Entscheidung
    if isRareOrBoss and isHardEnough then
        TC.Print("Rare Enemy Defeated: " .. mobInfo.name)
        TC.AddToken()
    end
    
    mobCache[destGUID] = nil
end

-- ============================================================
-- 3. PEASANT MODE (ITEM CHECK)
-- ============================================================
function TC.CheckEquipment()
    -- Wenn kein Limit gesetzt ist (oder Limit = 4/Epic ist), machen wir nichts
    if not TokenCoreDB.peasantLimit or TokenCoreDB.peasantLimit >= 4 then return end
    if TokenCoreDB.isDead then return end

    local limit = TokenCoreDB.peasantLimit
    local violationFound = false
    local offendingItemLink = nil

    -- Slots 1 bis 19 durchsuchen
    for slot = 1, 19 do
        local quality = GetInventoryItemQuality("player", slot)
        
        if quality and quality > limit then
            violationFound = true
            offendingItemLink = GetInventoryItemLink("player", slot)
            break 
        end
    end

    if violationFound then
        local limitNames = {[0]="Grey",[1]="White",[2]="Green",[3]="Blue"}
        local limitName = limitNames[limit] or "Unknown"
        local itemMsg = "Quality too high (Max: "..limitName..")"
        
        if offendingItemLink then
            itemMsg = offendingItemLink .. " is forbidden!"
        end
        
        -- Wir nutzen jetzt den Richterhammer als Icon
        TC.RemoveToken(
            "RULE VIOLATION",
            itemMsg,
            "Interface\\Icons\\INV_Hammer_05" 
        )
        
        TC.Print("|cffFF0000WARNING:|r Forbidden Item equipped! Token lost.")
    end
end