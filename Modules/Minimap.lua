local addonName, TC = ...

-- ============================================================
-- MINIMAP BUTTON
-- ============================================================

local button = nil
local isDragging = false

local function UpdatePosition()
    local angle = TokenCoreDB.minimapPos or 225
    local radius = 80
    
    local x = math.cos(math.rad(angle)) * radius
    local y = math.sin(math.rad(angle)) * radius

    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function TC.CreateMinimapButton()
    if button then return end
    
    if not TokenCoreDB.minimapPos then TokenCoreDB.minimapPos = 225 end

    button = CreateFrame("Button", "TokenCoreMinimapButton", Minimap)
    button:SetSize(32, 32) 
    button:SetFrameStrata("HIGH")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 10)
    
    button:SetMovable(true) 
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(20, 20)
    bg:SetPoint("CENTER")
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetVertexColor(0.1, 0.1, 0.1, 1)
    
    local circleMask = button:CreateMaskTexture()
    circleMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    circleMask:SetSize(20, 20)
    circleMask:SetPoint("CENTER")
    bg:AddMaskTexture(circleMask)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\AddOns\\TokenCore\\Media\\token_active.png")
    
    icon:AddMaskTexture(circleMask)

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(52, 52)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    
    border:ClearAllPoints()
    border:SetPoint("TOPLEFT", 0, 0)

    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- ============================================================
    -- SCRIPTS (Drag & Click)
    -- ============================================================

    button:SetScript("OnDragStart", function(self)
        self:LockHighlight()
        isDragging = true
        
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            
            cx, cy = cx / scale, cy / scale
            local dx, dy = cx - mx, cy - my
            
            local angle = math.deg(math.atan2(dy, dx))
            
            TokenCoreDB.minimapPos = angle
            UpdatePosition()
        end)
    end)
    
    button:SetScript("OnDragStop", function(self)
        self:UnlockHighlight()
        self:SetScript("OnUpdate", nil)
        C_Timer.After(0.1, function() isDragging = false end)
    end)

    button:SetScript("OnClick", function(self, btn)
        if isDragging then return end

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
        GameTooltip:AddLine("|cff808080Drag to move|r")
        GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    UpdatePosition()
    TC.Print("Minimap button loaded.")
end