local addonName, TC = ...

local hudFrame = nil
local tokenTextures = {} 

-- ============================================================
-- HUD UPDATE (Smart Layout)
-- ============================================================

function TC.UpdateHUD()
    if not hudFrame then return end
    
    local current = TokenCoreDB.tokens or 0
    local max = TokenCoreDB.maxTokens or 0
    local mode = TokenCoreDB.mode or "Hardcore"
    local level = UnitLevel("player")
    local isDead = TokenCoreDB.isDead

    -- ============================================================
    -- 1. HEADER LOGIK (LEBEND vs TOT)
    -- ============================================================
    if isDead then
        hudFrame.header:SetText("GAME OVER")
        hudFrame.header:SetTextColor(1, 0.1, 0.1) -- Knallrot
    else
        local infoText = mode .. " Mode (Lvl " .. level .. ")"
        hudFrame.header:SetText(infoText)
        hudFrame.header:SetTextColor(0.9, 0.8, 0.5) -- Gold/Beige
    end

    -- ============================================================
    -- 2. ICONS (Fest unter Header)
    -- ============================================================
    local iconSize = 26
    local spacing = 4
    local totalWidth = (max * iconSize) + ((max - 1) * spacing)
    local startX = -(totalWidth / 2) + (iconSize / 2)

    for i = 1, max do
        if not tokenTextures[i] then
            local t = hudFrame:CreateTexture(nil, "ARTWORK")
            t:SetSize(iconSize, iconSize)
            tokenTextures[i] = t
        end

        local xPos = startX + ((i-1) * (iconSize + spacing))
        tokenTextures[i]:ClearAllPoints()
        tokenTextures[i]:SetPoint("TOP", hudFrame, "TOP", xPos, -26) 

        -- Wenn tot, sind alle Tokens inaktiv (da current = 0)
        if i <= current then
            tokenTextures[i]:SetTexture("Interface\\AddOns\\TokenCore\\Media\\token_active.png")
            tokenTextures[i]:SetDesaturated(false); tokenTextures[i]:SetAlpha(1)
        else
            tokenTextures[i]:SetTexture("Interface\\AddOns\\TokenCore\\Media\\token_inactive.png")
            tokenTextures[i]:SetDesaturated(true); tokenTextures[i]:SetAlpha(0.3)
        end
        tokenTextures[i]:Show()
    end
    
    for i = max + 1, #tokenTextures do tokenTextures[i]:Hide() end
    
    -- Mindestbreite
    local neededWidth = math.max(170, totalWidth + 40)
    hudFrame:SetWidth(neededWidth)

    -- ============================================================
    -- 3. TEXT STATUS (DYNAMISCH)
    -- ============================================================
    
    local currentY = -60 
    local spacingY = 2 
    
    -- GAME OVER ZUSTAND
    if isDead then
        -- Curse ausblenden
        hudFrame.curseText:Hide()
        
        -- Timer Text missbrauchen für "Final Level"
        hudFrame.timerText:ClearAllPoints()
        hudFrame.timerText:SetPoint("TOP", hudFrame, "TOP", 0, currentY)
        hudFrame.timerText:SetText("Final Level: " .. level)
        hudFrame.timerText:SetTextColor(0.7, 0.7, 0.7) -- Grau
        hudFrame.timerText:Show()
        
        currentY = currentY - 18 - spacingY
        
    else
        -- NORMALER ZUSTAND (LEBEND)
        
        -- A) CURSE TEXT
        if TokenCoreDB.decayEnabled then
            hudFrame.curseText:ClearAllPoints()
            hudFrame.curseText:SetPoint("TOP", hudFrame, "TOP", 0, currentY)
            hudFrame.curseText:Show()
            currentY = currentY - 14 - spacingY
        else
            hudFrame.curseText:Hide()
        end

        -- B) TIMER TEXT
        if TokenCoreDB.timerEnabled then
            hudFrame.timerText:ClearAllPoints()
            hudFrame.timerText:SetPoint("TOP", hudFrame, "TOP", 0, currentY)
            hudFrame.timerText:Show()
            currentY = currentY - 18 - spacingY
        else
            hudFrame.timerText:Hide()
        end
    end
    
    -- C) HÖHE ANPASSEN
    local finalHeight = math.abs(currentY) + 5
    if finalHeight < 65 then finalHeight = 65 end
    
    hudFrame:SetHeight(finalHeight)
end

function TC.UpdateTimerText(text, r, g, b)
    -- Wenn wir tot sind, darf der Timer nicht mehr dazwischenfunken!
    if TokenCoreDB.isDead then return end

    if hudFrame and hudFrame.timerText then
        hudFrame.timerText:SetText(text)
        if not r then r, g, b = 1, 1, 1 end
        hudFrame.timerText:SetTextColor(r, g, b)
    end
end

function TC.UpdateCurseText(text, r, g, b)
    if TokenCoreDB.isDead then return end

    if hudFrame and hudFrame.curseText then
        if text then
            hudFrame.curseText:SetText(text)
            if not r then r, g, b = 1, 0.4, 0.4 end
            hudFrame.curseText:SetTextColor(r, g, b)
        end
    end
end

function TC.CreateHUD()
    if hudFrame then return end 

    hudFrame = CreateFrame("Frame", "TokenCoreHUD", UIParent, "BackdropTemplate")
    hudFrame:SetSize(170, 70) 
    
    hudFrame:ClearAllPoints()
    if TokenCoreDB.hudPosition then
        local pos = TokenCoreDB.hudPosition
        hudFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
    else
        hudFrame:SetPoint("TOP", UIParent, "TOP", 0, -50)
    end
    
    if not hudFrame.SetBackdrop then Mixin(hudFrame, BackdropTemplateMixin) end

    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8", 
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
        tile = false, tileSize = 16, edgeSize = 16, 
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    }
    hudFrame:SetBackdrop(backdrop)
    hudFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.75) 
    hudFrame:SetBackdropBorderColor(0.6, 0.5, 0.3, 1)

    hudFrame:EnableMouse(true); hudFrame:SetMovable(true)
    hudFrame:RegisterForDrag("LeftButton")
    hudFrame:SetScript("OnDragStart", hudFrame.StartMoving)
    hudFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        TokenCoreDB.hudPosition = { point = point, relativePoint = relativePoint, x = x, y = y }
    end)

    -- HEADER
    hudFrame.header = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hudFrame.header:SetPoint("TOP", hudFrame, "TOP", 0, -8)
    
    -- CURSE TEXT
    hudFrame.curseText = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    
    -- TIMER TEXT
    hudFrame.timerText = hudFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge") 

    TC.Print("HUD loaded.")
    TC.UpdateHUD()
end