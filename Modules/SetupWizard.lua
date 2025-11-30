local addonName, TC = ...

function TC.ShowSetupWizard()
    local step1, step2
    local selectedMode = nil
    local mediaPath = "Interface\\AddOns\\TokenCore\\Media\\"

    local COLOR_GOLD = {r=1, g=0.82, b=0}
    local COLOR_CREAM = {r=0.9, g=0.8, b=0.6}
    local COLOR_WHITE = {r=1, g=1, b=1}
    local COLOR_RED = {r=1, g=0.2, b=0.2}
    local COLOR_GREY = {r=0.7, g=0.7, b=0.7}

    -- 1. MAIN FRAME
    local frame = CreateFrame("Frame", "TokenCoreSetupFrame", UIParent, "BackdropTemplate")
    TC.ApplyFrameSkin(frame)
    frame:SetSize(750, 500) 
    frame:SetPoint("CENTER")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    local bgLayer = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    bgLayer:SetAllPoints(frame)
    bgLayer:SetColorTexture(0.05, 0.05, 0.07, 0.92)
    frame:SetBackdropBorderColor(1, 1, 1, 1)

    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontNormalHuge")
    frame.title:SetPoint("TOP", frame, "TOP", 0, -20)
    frame.title:SetText("Token Core Setup")
    frame.title:SetTextColor(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b)

    -- ============================================================
    -- STEP 1: CHOOSE YOUR DESTINY
    -- ============================================================
    step1 = CreateFrame("Frame", nil, frame)
    step1:SetAllPoints(frame)
    
    local text1 = step1:CreateFontString(nil, "OVERLAY")
    text1:SetFontObject("GameFontHighlightLarge")
    text1:SetPoint("TOP", 0, -60)
    text1:SetText("STEP 1: Choose Your Destiny")
    text1:SetTextColor(COLOR_CREAM.r, COLOR_CREAM.g, COLOR_CREAM.b)

    -- FIX: Hintergrund (schwarze Box) entfernt!
    local function CreateModeIcon(parent, texturePath, xOffset)
        local icon = parent:CreateTexture(nil, "ARTWORK")
        icon:SetSize(90, 90) -- Ein bisschen größer, da der Rahmen weg ist
        icon:SetPoint("CENTER", frame, "CENTER", xOffset, 60)
        icon:SetTexture(texturePath)
        -- Leichter Glow, damit sie sich vom dunklen Hintergrund abheben
        icon:SetVertexColor(1, 1, 1) 
        return icon
    end

    local function AddDescriptionText(button, text)
        local fs = step1:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("TOP", button, "BOTTOM", 0, -12)
        fs:SetWidth(180)
        fs:SetText(text)
        fs:SetJustifyH("CENTER")
        fs:SetJustifyV("TOP")
        fs:SetTextColor(COLOR_GREY.r, COLOR_GREY.g, COLOR_GREY.b)
        fs:SetSpacing(2)
        return fs
    end

    -- ADRENALINE
    -- Wir bekommen nur noch das Icon zurück (kein bgAdrenalin mehr)
    local iconAdrenalin = CreateModeIcon(step1, mediaPath .. "mode_adrenaline.png", -200)
    
    local btnAdrenalin = CreateFrame("Button", nil, step1, "GameMenuButtonTemplate")
    btnAdrenalin:SetSize(150, 35)
    -- FIX: Wir verankern den Button jetzt direkt am Icon
    btnAdrenalin:SetPoint("TOP", iconAdrenalin, "BOTTOM", 0, -20) 
    btnAdrenalin:SetText("Adrenaline Mode")
    btnAdrenalin:GetFontString():SetTextColor(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b)
    AddDescriptionText(btnAdrenalin, "Time is your enemy!\n\nStart with a timer. Gain XP to regain time.\nIf it runs out, you lose a token.")

    -- CURSED
    local iconCursed = CreateModeIcon(step1, "Interface\\Icons\\Spell_Shadow_SacrificialShield", 0)
    iconCursed:SetTexture(mediaPath .. "mode_cursed.png") 

    local btnCursed = CreateFrame("Button", nil, step1, "GameMenuButtonTemplate")
    btnCursed:SetSize(150, 35)
    btnCursed:SetPoint("TOP", iconCursed, "BOTTOM", 0, -20)
    btnCursed:SetText("Cursed Mode")
    btnCursed:GetFontString():SetTextColor(COLOR_RED.r, COLOR_RED.g, COLOR_RED.b)
    AddDescriptionText(btnCursed, "The curse weighs upon you.\n\nLose a token every 10 levels.\nKill dangerous bosses to replenish your supply.")

    -- CUSTOM
    local iconCustom = CreateModeIcon(step1, mediaPath .. "mode_custom.png", 200)
    
    local btnCustom = CreateFrame("Button", nil, step1, "GameMenuButtonTemplate")
    btnCustom:SetSize(150, 35)
    btnCustom:SetPoint("TOP", iconCustom, "BOTTOM", 0, -20)
    btnCustom:SetText("Custom Mode")
    btnCustom:GetFontString():SetTextColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)
    AddDescriptionText(btnCustom, "Your rules.\n\nCreate your own challenge.\nCombine Timer, Level Decay, and Tokens as you see fit.")


    -- ============================================================
    -- STEP 2: CONFIGURATION
    -- ============================================================
    
    step2 = CreateFrame("Frame", nil, frame)
    step2:SetAllPoints(frame)
    step2:Hide()

    local text2 = step2:CreateFontString(nil, "OVERLAY")
    text2:SetFontObject("GameFontHighlightLarge")
    text2:SetPoint("TOP", 0, -60)
    text2:SetText("STEP 2: Configuration")
    text2:SetTextColor(COLOR_CREAM.r, COLOR_CREAM.g, COLOR_CREAM.b)

    local function SkinSlider(slider)
        _G[slider:GetName() .. "Low"]:SetTextColor(COLOR_CREAM.r, COLOR_CREAM.g, COLOR_CREAM.b)
        _G[slider:GetName() .. "High"]:SetTextColor(COLOR_CREAM.r, COLOR_CREAM.g, COLOR_CREAM.b)
        _G[slider:GetName() .. "Text"]:SetTextColor(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b)
    end

    local function AddTooltip(widget, title, text)
        widget:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(title, COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b)
            GameTooltip:AddLine(text, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        widget:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    end

    -- 1. SLIDER: TOKENS
    local tokenSlider = CreateFrame("Slider", "TCTokenSlider", step2, "OptionsSliderTemplate")
    tokenSlider:SetPoint("TOP", 0, -100)
    tokenSlider:SetMinMaxValues(1, 5)
    tokenSlider:SetValue(3)
    tokenSlider:SetValueStep(1)
    tokenSlider:SetObeyStepOnDrag(true)
    tokenSlider:SetWidth(220)
    _G[tokenSlider:GetName() .. "Low"]:SetText("1")
    _G[tokenSlider:GetName() .. "High"]:SetText("5")
    _G[tokenSlider:GetName() .. "Text"]:SetText("Starting Tokens: 3")
    SkinSlider(tokenSlider)
    AddTooltip(tokenSlider, "Life Tokens", "How many lives (tokens) does your character start with?")
    
    tokenSlider:SetScript("OnValueChanged", function(self, value)
        _G[self:GetName() .. "Text"]:SetText("Starting Tokens: " .. math.floor(value))
    end)

    -- TRENNLINIE 1
    local divider1 = step2:CreateTexture(nil, "ARTWORK")
    divider1:SetSize(450, 2)
    divider1:SetPoint("TOP", tokenSlider, "BOTTOM", 0, -50) 
    divider1:SetColorTexture(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b, 0.3)

    -- 2. CHECKBOXES
    local cbRegen = CreateFrame("CheckButton", nil, step2, "ChatConfigCheckButtonTemplate")
    cbRegen:SetPoint("TOPLEFT", tokenSlider, "BOTTOMLEFT", -15, -70) 
    
    -- ÄNDERUNG: Neuer Text & Standardwert
    cbRegen.Text:SetText(" Allow Token Rewards (Achievements)") 
    cbRegen.Text:SetTextColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)
    cbRegen:SetChecked(false) -- Standardmäßig AUS
    
    -- ÄNDERUNG: Tooltip angepasst
    AddTooltip(cbRegen, "Achievement Rewards", "If enabled, you can regain lost tokens by unlocking Achievements (Killing Bosses, Quests, Leveling).")

    local cbDecay = CreateFrame("CheckButton", nil, step2, "ChatConfigCheckButtonTemplate")
    cbDecay:SetPoint("TOPLEFT", cbRegen, "BOTTOMLEFT", 0, -5) 
    cbDecay.Text:SetText(" Level Decay (Lose Token every 10 Lvl)")
    AddTooltip(cbDecay, "Level Decay", "|cffFF0000WARNING:|r Lose a token automatically at level 10, 20, 30...")
    
    -- TRENNLINIE 2
    local divider2 = step2:CreateTexture(nil, "ARTWORK")
    divider2:SetSize(450, 2)
    divider2:SetPoint("TOP", divider1, "BOTTOM", 0, -80) 
    divider2:SetColorTexture(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b, 0.3)

    -- 3. CHECKBOX: TIMER
    local cbTimer = CreateFrame("CheckButton", nil, step2, "ChatConfigCheckButtonTemplate")
    cbTimer:SetPoint("TOPLEFT", tokenSlider, "BOTTOMLEFT", -15, -150) 
    cbTimer.Text:SetText(" Enable Timer")
    cbTimer.Text:SetTextColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)
    cbTimer:SetChecked(true)
    AddTooltip(cbTimer, "Timer", "Activates the Adrenaline Timer.")

    -- 4. SLIDER: TIME
    local timeSlider = CreateFrame("Slider", "TCTimeSlider", step2, "OptionsSliderTemplate")
    timeSlider:SetPoint("TOP", divider2, "BOTTOM", 0, -70) 
    timeSlider:SetMinMaxValues(1, 15)
    timeSlider:SetValue(5)
    timeSlider:SetValueStep(1)
    timeSlider:SetObeyStepOnDrag(true)
    timeSlider:SetWidth(220)
    _G[timeSlider:GetName() .. "Low"]:SetText("1 Min")
    _G[timeSlider:GetName() .. "High"]:SetText("15 Min")
    _G[timeSlider:GetName() .. "Text"]:SetText("Timer: 5 Minutes")
    SkinSlider(timeSlider)
    AddTooltip(timeSlider, "Time Limit", "Time before token loss.")

    timeSlider:SetScript("OnValueChanged", function(self, value)
        _G[self:GetName() .. "Text"]:SetText("Timer: " .. math.floor(value) .. " Minutes")
    end)

    cbTimer:SetScript("OnClick", function(self)
        if self:GetChecked() then timeSlider:Show() else timeSlider:Hide() end
    end)

    -- NAVIGATION
    local btnBack = CreateFrame("Button", nil, step2, "GameMenuButtonTemplate")
    btnBack:SetPoint("BOTTOMLEFT", 30, 30)
    btnBack:SetSize(120, 35)
    btnBack:SetText("<< Back")
    btnBack:SetScript("OnClick", function() step2:Hide(); step1:Show() end)

    local btnStart = CreateFrame("Button", nil, step2, "GameMenuButtonTemplate")
    btnStart:SetPoint("BOTTOMRIGHT", -30, 30)
    btnStart:SetSize(160, 35)
    btnStart:SetText("Start Adventure")
    btnStart:GetFontString():SetTextColor(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b)
    btnStart:SetScript("OnClick", function()
        TokenCoreDB.mode = selectedMode
        TokenCoreDB.tokens = math.floor(tokenSlider:GetValue())
        TokenCoreDB.maxTokens = TokenCoreDB.tokens
        TokenCoreDB.timerEnabled = cbTimer:GetChecked()
        TokenCoreDB.regenEnabled = cbRegen:GetChecked()
        TokenCoreDB.decayEnabled = cbDecay:GetChecked()
        
        if TokenCoreDB.timerEnabled then
            TokenCoreDB.timerDuration = math.floor(timeSlider:GetValue()) * 60
        else
            TokenCoreDB.timerDuration = nil
        end
        TokenCoreDB.setupComplete = true
        
        TC.Print("Adventure started! Mode: " .. selectedMode)
        if TC.CreateHUD then TC.CreateHUD() end
        if TC.ResetTimer then TC.ResetTimer() end
        frame:Hide()
    end)

    -- MODI LOGIK
    -- Hinweis: Adrenaline und Cursed setzen den Haken automatisch auf TRUE,
    -- da diese Modi ohne Rewards zu hart wären.
    -- Im Custom Mode muss der User es jetzt selbst aktivieren.

    -- ============================================================
    -- LOGIC & BUTTON HANDLERS
    -- ============================================================

    -- 1. ADRENALINE
    btnAdrenalin:SetScript("OnClick", function() 
        selectedMode = "Adrenalin"
        step1:Hide(); step2:Show()
        text2:SetText("Configuration: Adrenaline Mode")
        text2:SetTextColor(COLOR_GOLD.r, COLOR_GOLD.g, COLOR_GOLD.b)
        
        cbTimer:SetChecked(true); cbTimer:Disable(); cbTimer:SetAlpha(0.5)
        cbTimer.Text:SetTextColor(COLOR_RED.r, COLOR_RED.g, COLOR_RED.b)
        timeSlider:Show()
        
        cbRegen:Enable();
        cbRegen:SetAlpha(1);
        cbRegen:SetChecked(false)
        cbRegen.Text:SetTextColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)
        
        cbDecay:SetChecked(false); cbDecay:Disable(); cbDecay:SetAlpha(0.5)
        cbDecay.Text:SetTextColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)
    end)

    -- 2. CURSED
    btnCursed:SetScript("OnClick", function() 
        selectedMode = "Cursed"
        step1:Hide(); step2:Show()
        text2:SetText("Configuration: Cursed Mode")
        text2:SetTextColor(COLOR_RED.r, COLOR_RED.g, COLOR_RED.b)
        
        cbTimer:Enable(); cbTimer:SetAlpha(1); cbTimer:SetChecked(false)
        cbTimer.Text:SetTextColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)
        timeSlider:Hide()
        
        cbRegen:SetChecked(true); cbRegen:Disable(); cbRegen:SetAlpha(0.5)
        cbRegen.Text:SetTextColor(COLOR_RED.r, COLOR_RED.g, COLOR_RED.b)
        
        cbDecay:SetChecked(true); cbDecay:Disable(); cbDecay:SetAlpha(0.5)
        cbDecay.Text:SetTextColor(COLOR_RED.r, COLOR_RED.g, COLOR_RED.b)
    end)

    -- 3. CUSTOM
    btnCustom:SetScript("OnClick", function() 
        selectedMode = "Custom"
        step1:Hide(); step2:Show()
        text2:SetText("Configuration: Custom Mode")
        text2:SetTextColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)
        
        cbTimer:Enable(); cbTimer:SetAlpha(1)
        if cbTimer:GetChecked() then timeSlider:Show() else timeSlider:Hide() end
        
        cbRegen:Enable(); cbRegen:SetAlpha(1)
        cbRegen.Text:SetTextColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)
        
        cbDecay:Enable(); cbDecay:SetAlpha(1)
        cbDecay.Text:SetTextColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)
    end)
end