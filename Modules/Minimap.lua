local addonName, TC = ...

-- ============================================================
-- MINIMAP BUTTON
-- ============================================================

local button = nil
local isDragging = false

-- Funktion: Button an den Kreis heften
local function UpdatePosition()
    local angle = TokenCoreDB.minimapPos or 225 -- Standard: Unten Links
    local radius = 80 -- Standard Minimap Radius
    
    -- Position berechnen: Wir bewegen uns auf einer Kreisbahn um die Minimap
    -- (Minimap ist der Anker "CENTER")
    local x = math.cos(math.rad(angle)) * radius
    local y = math.sin(math.rad(angle)) * radius

    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function TC.CreateMinimapButton()
    if button then return end
    
    -- DB Check
    if not TokenCoreDB.minimapPos then TokenCoreDB.minimapPos = 225 end

    -- 1. FRAME ERSTELLEN
    button = CreateFrame("Button", "TokenCoreMinimapButton", Minimap)
    button:SetSize(32, 32) 
    button:SetFrameStrata("HIGH") -- Hoch genug, um über allem zu liegen
    button:SetFrameLevel(Minimap:GetFrameLevel() + 10)
    
    -- WICHTIG: Movable & Mouse aktivieren
    button:SetMovable(true) 
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton") -- Nur Linksklick zieht

    -- 2. HINTERGRUND (Kreis)
    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(20, 20)
    bg:SetPoint("CENTER")
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetVertexColor(0.1, 0.1, 0.1, 1)
    
    -- Runde Maske
    local circleMask = button:CreateMaskTexture()
    circleMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    circleMask:SetSize(20, 20)
    circleMask:SetPoint("CENTER")
    bg:AddMaskTexture(circleMask)

    -- 3. ICON (Dein Token)
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\AddOns\\TokenCore\\Media\\token_active.png")
    
    -- Icon auch rund schneiden
    icon:AddMaskTexture(circleMask)

    -- 4. RAND (Der Ring)
    -- Hier nutzen wir die Einstellungen, die bei dir funktioniert haben.
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(52, 52)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    
    -- Reset und Neupositionierung
    border:ClearAllPoints()
    border:SetPoint("TOPLEFT", 0, 0)

    -- 5. HIGHLIGHT
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- ============================================================
    -- SKRIPTE (Drag & Click)
    -- ============================================================

    -- Start Dragging
    button:SetScript("OnDragStart", function(self)
        self:LockHighlight()
        isDragging = true
        
        -- Wir nutzen einen OnUpdate Handler nur während des Ziehens (Performance)
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            
            -- Mausposition relativ zur Minimap-Mitte berechnen
            cx, cy = cx / scale, cy / scale
            local dx, dy = cx - mx, cy - my
            
            -- Winkel berechnen
            local angle = math.deg(math.atan2(dy, dx))
            
            -- Speichern und Updaten
            TokenCoreDB.minimapPos = angle
            UpdatePosition()
        end)
    end)
    
    -- Stop Dragging
    button:SetScript("OnDragStop", function(self)
        self:UnlockHighlight()
        self:SetScript("OnUpdate", nil) -- Loop beenden
        
        -- Kleiner Hack: Wir setzen isDragging erst verzögert zurück,
        -- damit der "OnClick" Handler weiß, dass wir gerade gezogen haben 
        -- und nicht das Fenster öffnet.
        C_Timer.After(0.1, function() isDragging = false end)
    end)

    -- Klick Handler
    button:SetScript("OnClick", function(self, btn)
        -- Wenn wir gerade gezogen haben, ignorieren wir den Klick
        if isDragging then return end
        
        -- Nur Linksklick erlaubt (Achievements öffnen)
        -- Rechtsklick ist deaktiviert (Setup öffnet nur automatisch)
        if btn == "LeftButton" then
            if TC.ToggleAchievementWindow then TC.ToggleAchievementWindow() end
        end
    end)

    -- Tooltip
    button:SetScript("OnEnter", function(self)
        if isDragging then return end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Token Core", 1, 0.82, 0)
        
        local mode = TokenCoreDB.mode or "Unknown"
        local tokens = TokenCoreDB.tokens or 0
        local max = TokenCoreDB.maxTokens or 0
        
        GameTooltip:AddDoubleLine("Mode:", mode, 1,1,1, 1,1,1)
        GameTooltip:AddDoubleLine("Tokens:", tokens .. " / " .. max, 1,1,1, 1,1,1)
        
        if TokenCoreDB.decayEnabled then
            local lvl = UnitLevel("player")
            local nextLoss = 10 - (lvl % 10)
            GameTooltip:AddDoubleLine("Next Decay:", "in " .. nextLoss .. " Lvls", 1,0.5,0.5, 1,0.5,0.5)
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cff00FF00Left-Click:|r Achievements")
        -- Rechtsklick Info entfernt
        GameTooltip:AddLine("|cff808080Drag to move|r")
        GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Initiale Position
    UpdatePosition()
    TC.Print("Minimap button loaded.")
end