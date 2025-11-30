-- Namespace holen (damit wir Funktionen dateiübergreifend nutzen können)
local addonName, TC = ... 

-- Wir speichern globale Funktionen in 'TC', damit andere Dateien darauf zugreifen können.
-- Z.B. TC.ShowSetupWizard() oder TC.UpdateHUD()

-- Standardwerte für die Datenbank
TC.defaults = {
    setupComplete = false,
    mode = nil,
    tokens = 0,
    maxTokens = 0,
    isDead = false
}

-- Einfache Print-Hilfsfunktion
function TC.Print(msg)
    print("|cffFF0000TokenCore:|r " .. msg)
end

-- ============================================================
-- SKINNING ENGINE (ROBUST MIXIN FIX)
-- ============================================================

function TC.ApplyFrameSkin(frame)
    if not frame then return end

    -- FIX: Prüfen ob SetBackdrop existiert. Falls nicht -> Mixin laden!
    if not frame.SetBackdrop then
        Mixin(frame, BackdropTemplateMixin)
    end

    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8", 
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
        tile = false,
        tileSize = 0, 
        edgeSize = 32, 
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    }

    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0, 0, 0, 0.9)
    frame:SetBackdropBorderColor(1, 1, 1, 1)
    
    if frame.title then
        frame.title:ClearAllPoints()
        frame.title:SetPoint("TOP", frame, "TOP", 0, -15)
        frame.title:SetTextColor(1, 0.82, 0, 1) 
    end
    
    if not frame.closeBtn then
        local btn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        btn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
        btn:SetScript("OnClick", function() frame:Hide() end)
        btn:SetFrameLevel(frame:GetFrameLevel() + 5)
        frame.closeBtn = btn
    end
end