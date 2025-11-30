local addonName, TC = ...

-- ============================================================
-- NOTIFICATION SYSTEM (MULTI-STACK)
-- ============================================================

local bannerPool = {}
local MAX_BANNERS = 3
local START_Y = -180
local SPACING = 80 -- Abstand zwischen den Bannern

-- Hilfsfunktion: Ein einzelnes Banner erstellen
local function CreateBannerFrame(index)
    local f = CreateFrame("Frame", "TokenCoreBanner"..index, UIParent, "BackdropTemplate")
    f:SetSize(350, 70)
    -- Wir setzen den Punkt fest basierend auf dem Index (1 ist oben, 2 darunter, etc.)
    local yOffset = START_Y - ((index - 1) * SPACING)
    f:SetPoint("TOP", 0, yOffset)
    f:SetFrameStrata("DIALOG")
    f:Hide()
    
    TC.ApplyFrameSkin(f)
    
    -- Icon
    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetSize(50, 50)
    f.icon:SetPoint("LEFT", 15, 0)
    
    -- Titel
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOPLEFT", f.icon, "TOPRIGHT", 15, -5)
    f.title:SetPoint("RIGHT", f, "RIGHT", -15, 0)
    f.title:SetJustifyH("LEFT")
    f.title:SetWordWrap(false)
    
    -- Text
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.text:SetPoint("BOTTOMLEFT", f.icon, "BOTTOMRIGHT", 15, 5)
    f.text:SetPoint("RIGHT", f, "RIGHT", -15, 0)
    f.text:SetJustifyH("LEFT")
    f.text:SetWordWrap(false)
    
    -- Animation
    local ag = f:CreateAnimationGroup()
    
    local fadeIn = ag:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.4)
    fadeIn:SetOrder(1)
    
    local hold = ag:CreateAnimation("Alpha")
    hold:SetFromAlpha(1)
    hold:SetToAlpha(1)
    hold:SetDuration(3.5)
    hold:SetOrder(2)
    
    local fadeOut = ag:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.8)
    fadeOut:SetOrder(3)
    
    ag:SetScript("OnFinished", function()
        f:Hide()
        f.inUse = false -- Wieder freigeben
    end)
    
    f.animGroup = ag
    f.inUse = false -- Status-Flag
    
    return f
end

-- GLOBALE FUNKTION
function TC.ShowNotification(title, message, iconPath, soundId)
    -- 1. Ein freies Banner suchen
    local banner = nil
    
    for i = 1, MAX_BANNERS do
        if not bannerPool[i] then
            bannerPool[i] = CreateBannerFrame(i)
        end
        
        -- Ist dieses Banner gerade frei?
        if not bannerPool[i].inUse then
            banner = bannerPool[i]
            break
        end
    end
    
    -- Falls alle voll sind (sehr unwahrscheinlich), überschreiben wir einfach das erste
    if not banner then
        banner = bannerPool[1]
        banner.animGroup:Stop()
    end
    
    -- 2. Banner belegen
    banner.inUse = true
    
    -- Inhalt setzen
    banner.title:SetText(title)
    banner.title:SetTextColor(1, 0.82, 0)
    banner.text:SetText(message)
    
    if iconPath then
        banner.icon:SetTexture(iconPath)
    else
        banner.icon:SetTexture("Interface\\Icons\\INV_Scroll_03")
    end
    
    if soundId then PlaySound(soundId) end
    
    -- Starten
    banner:SetAlpha(0)
    banner:Show()
    banner.animGroup:Play()
end