-- CombatlogTimestamper: A red button that stamps your combat log
-- Usage: /cts show | /cts hide | /cts size <number> | /cts msg <text>

CTS_Config = CTS_Config or {}
CTS_Stamps = CTS_Stamps or {}

local DEFAULTS = {
    buttonSize = 40,
    posX = 0,
    posY = 0,
    point = "CENTER",
    shown = true,
    message = "=== TIMESTAMP MARKER ===",
    stampCount = 0,
}

local function GetConfig(key)
    if CTS_Config[key] == nil then
        return DEFAULTS[key]
    end
    return CTS_Config[key]
end

----------------------------------------------------------------------
-- Timestamp helper: returns combat-log-style timestamp  M/DD HH:MM:SS
----------------------------------------------------------------------
local function GetCombatLogTimestamp()
    local h, m = GetGameTime()
    local dateInfo = date("*t")
    local s = dateInfo.sec
    return string.format("%d/%02d %02d:%02d:%02d", dateInfo.month, dateInfo.day, h, m, s)
end

----------------------------------------------------------------------
-- Stamp function: writes to WoWCombatLog.txt via SuperWoW CombatLogAdd
----------------------------------------------------------------------
local function StampCombatLog()
    CTS_Config.stampCount = (CTS_Config.stampCount or 0) + 1
    local count = CTS_Config.stampCount
    local msg = GetConfig("message")

    -- Ensure combat logging is on
    LoggingCombat(1)

    -- Write directly to WoWCombatLog.txt via SuperWoW
    if CombatLogAdd then
        CombatLogAdd("CTS_MARKER: [#" .. count .. "] " .. msg)
        -- Flush: toggle logging off/on to force write to disk
        LoggingCombat(0)
        LoggingCombat(1)
        DEFAULT_CHAT_FRAME:AddMessage("|cff44ff44[CTS]|r Marker #" .. count .. " written.")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS]|r CombatLogAdd not found - SuperWoW required!")
    end
end

----------------------------------------------------------------------
-- Create the button
----------------------------------------------------------------------
local btn = CreateFrame("Button", "CTS_Button", UIParent)
btn:SetMovable(true)
btn:EnableMouse(true)
btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
btn:SetClampedToScreen(true)
btn:SetFrameStrata("HIGH")

-- Icon texture
local tex = btn:CreateTexture(nil, "ARTWORK")
tex:SetAllPoints(btn)
tex:SetTexture("Interface\\Icons\\Ability_Spy")
btn.texture = tex

-- Highlight on mouseover
local hi = btn:CreateTexture(nil, "HIGHLIGHT")
hi:SetAllPoints(btn)
hi:SetTexture(1, 0.4, 0.4, 0.4)

-- Label
local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
label:SetPoint("CENTER", btn, "CENTER", 0, 0)
label:SetText("CTS")
label:SetTextColor(1, 1, 1, 1)

-- Border
local border = btn:CreateTexture(nil, "OVERLAY")
border:SetPoint("TOPLEFT", btn, "TOPLEFT", -2, 2)
border:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 2, -2)
border:SetTexture(0, 0, 0, 1)
border:SetDrawLayer("BACKGROUND")

-- Dragging
btn:RegisterForDrag("LeftButton")
btn:SetScript("OnDragStart", function()
    this:StartMoving()
end)
btn:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
    local p, _, rp, x, y = this:GetPoint()
    CTS_Config.point = p
    CTS_Config.posX = x
    CTS_Config.posY = y
end)

-- Click: left = stamp, right = config
btn:SetScript("OnClick", function()
    if arg1 == "LeftButton" then
        StampCombatLog()
    elseif arg1 == "RightButton" then
        ToggleConfig()
    end
end)

-- Tooltip
btn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
    GameTooltip:AddLine("|cffff4444Combat Log Timestamper|r")
    GameTooltip:AddLine("Left-click: Stamp combat log", 0.8, 0.8, 0.8)
    GameTooltip:AddLine("Drag: Move button", 0.8, 0.8, 0.8)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Stamps so far: " .. (CTS_Config.stampCount or 0), 0.5, 1, 0.5)
    GameTooltip:AddLine("/cts help for commands", 0.6, 0.6, 0.6)
    GameTooltip:Show()
end)
btn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

----------------------------------------------------------------------
-- Apply saved settings
----------------------------------------------------------------------
local function ApplySize(size)
    btn:SetWidth(size)
    btn:SetHeight(size)
    CTS_Config.buttonSize = size
end

local function ApplyPosition()
    btn:ClearAllPoints()
    local p = GetConfig("point")
    local x = GetConfig("posX")
    local y = GetConfig("posY")
    btn:SetPoint(p, UIParent, p, x, y)
end

----------------------------------------------------------------------
-- Config Panel  (/cts cfg)
----------------------------------------------------------------------
local cfg = CreateFrame("Frame", "CTS_ConfigFrame", UIParent)
cfg:SetWidth(280)
cfg:SetHeight(250)
cfg:SetPoint("CENTER", UIParent, "CENTER", 0, 60)
cfg:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
cfg:SetBackdropColor(0.1, 0.1, 0.1, 0.92)
cfg:SetBackdropBorderColor(0.8, 0.2, 0.2, 1)
cfg:SetMovable(true)
cfg:EnableMouse(true)
cfg:RegisterForDrag("LeftButton")
cfg:SetScript("OnDragStart", function() this:StartMoving() end)
cfg:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
cfg:SetFrameStrata("DIALOG")
cfg:Hide()

-- Title
local cfgTitle = cfg:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
cfgTitle:SetPoint("TOP", cfg, "TOP", 0, -12)
cfgTitle:SetText("|cffff4444CTS Config|r")

-- Close button
local cfgClose = CreateFrame("Button", nil, cfg, "UIPanelCloseButton")
cfgClose:SetPoint("TOPRIGHT", cfg, "TOPRIGHT", -2, -2)

----------------------------------------------------------------------
-- Show/Hide checkbox
----------------------------------------------------------------------
local chkShow = CreateFrame("CheckButton", "CTS_ChkShow", cfg, "UICheckButtonTemplate")
chkShow:SetPoint("TOPLEFT", cfg, "TOPLEFT", 14, -40)
chkShow:SetWidth(24)
chkShow:SetHeight(24)
getglobal("CTS_ChkShowText"):SetText("Show Button")
chkShow:SetScript("OnClick", function()
    if this:GetChecked() then
        btn:Show()
        CTS_Config.shown = true
    else
        btn:Hide()
        CTS_Config.shown = false
    end
end)

----------------------------------------------------------------------
-- Size slider
----------------------------------------------------------------------
local sizeLabel = cfg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sizeLabel:SetPoint("TOPLEFT", cfg, "TOPLEFT", 18, -72)
sizeLabel:SetText("Button Size:")

local sizeValue = cfg:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
sizeValue:SetPoint("LEFT", sizeLabel, "RIGHT", 6, 0)

local sizeSlider = CreateFrame("Slider", "CTS_SizeSlider", cfg, "OptionsSliderTemplate")
sizeSlider:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 0, -12)
sizeSlider:SetWidth(240)
sizeSlider:SetHeight(16)
sizeSlider:SetMinMaxValues(16, 200)
sizeSlider:SetValueStep(2)
getglobal("CTS_SizeSliderLow"):SetText("16")
getglobal("CTS_SizeSliderHigh"):SetText("200")
getglobal("CTS_SizeSliderText"):SetText("")
sizeSlider:SetScript("OnValueChanged", function()
    local v = math.floor(this:GetValue())
    sizeValue:SetText(v .. " px")
    ApplySize(v)
end)

----------------------------------------------------------------------
-- Message editbox
----------------------------------------------------------------------
local msgLabel = cfg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
msgLabel:SetPoint("TOPLEFT", sizeSlider, "BOTTOMLEFT", 0, -20)
msgLabel:SetText("Stamp Message:")

local msgBox = CreateFrame("EditBox", "CTS_MsgBox", cfg, "InputBoxTemplate")
msgBox:SetPoint("TOPLEFT", msgLabel, "BOTTOMLEFT", 6, -4)
msgBox:SetWidth(232)
msgBox:SetHeight(24)
msgBox:SetAutoFocus(false)
msgBox:SetMaxLetters(200)
msgBox:SetScript("OnEnterPressed", function()
    local txt = this:GetText()
    if txt and txt ~= "" then
        CTS_Config.message = txt
        DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS]|r Message saved.")
    end
    this:ClearFocus()
end)
msgBox:SetScript("OnEscapePressed", function()
    this:ClearFocus()
end)

----------------------------------------------------------------------
-- Save button
----------------------------------------------------------------------
local saveBtn = CreateFrame("Button", nil, cfg, "UIPanelButtonTemplate")
saveBtn:SetWidth(80)
saveBtn:SetHeight(22)
saveBtn:SetPoint("TOPLEFT", msgBox, "BOTTOMLEFT", -6, -6)
saveBtn:SetText("Save")
saveBtn:SetScript("OnClick", function()
    local box = getglobal("CTS_MsgBox")
    if box then
        local txt = box:GetText()
        if txt and txt ~= "" then
            CTS_Config.message = txt
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS]|r Message saved: " .. txt)
        end
    end
end)

----------------------------------------------------------------------
-- Reset counter button + stamp display
----------------------------------------------------------------------
local resetBtn = CreateFrame("Button", nil, cfg, "UIPanelButtonTemplate")
resetBtn:SetWidth(120)
resetBtn:SetHeight(22)
resetBtn:SetPoint("BOTTOMLEFT", cfg, "BOTTOMLEFT", 16, 14)
resetBtn:SetText("Reset Counter")

-- Stamp counter display
local stampLabel = cfg:CreateFontString("CTS_StampLabel", "OVERLAY", "GameFontHighlight")
stampLabel:SetPoint("LEFT", resetBtn, "RIGHT", 10, 0)

resetBtn:SetScript("OnClick", function()
    CTS_Config.stampCount = 0
    getglobal("CTS_StampLabel"):SetText("Stamps: 0")
    DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS]|r Counter reset to 0.")
end)

----------------------------------------------------------------------
-- Refresh config panel values from saved vars
----------------------------------------------------------------------
function CTS_RefreshConfig()
    chkShow:SetChecked(GetConfig("shown"))
    sizeSlider:SetValue(GetConfig("buttonSize"))
    sizeValue:SetText(GetConfig("buttonSize") .. " px")
    getglobal("CTS_MsgBox"):SetText(GetConfig("message"))
    getglobal("CTS_StampLabel"):SetText("Stamps: " .. (CTS_Config.stampCount or 0))
end

function ToggleConfig()
    if cfg:IsVisible() then
        cfg:Hide()
    else
        CTS_RefreshConfig()
        cfg:Show()
    end
end

----------------------------------------------------------------------
-- Init on VARIABLES_LOADED
----------------------------------------------------------------------
local loader = CreateFrame("Frame")
loader:RegisterEvent("VARIABLES_LOADED")
loader:SetScript("OnEvent", function()
    if CTS_Config == nil then CTS_Config = {} end
    if CTS_Stamps == nil then CTS_Stamps = {} end
    ApplySize(GetConfig("buttonSize"))
    ApplyPosition()
    if GetConfig("shown") then
        btn:Show()
    else
        btn:Hide()
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS]|r Combatlog Timestamper loaded. /cts cfg")
end)

----------------------------------------------------------------------
-- Slash commands
----------------------------------------------------------------------
SLASH_CTS1 = "/cts"
SlashCmdList["CTS"] = function(msg)
    msg = msg or ""
    local cmd = ""
    local rest = ""
    local _, _, c, r = string.find(msg, "^(%S+)%s*(.*)")
    if c then cmd = string.lower(c) end
    if r then rest = r end

    if cmd == "cfg" or cmd == "config" or cmd == "" then
        ToggleConfig()
    elseif cmd == "show" then
        btn:Show()
        CTS_Config.shown = true
        DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS]|r Button shown.")
    elseif cmd == "hide" then
        btn:Hide()
        CTS_Config.shown = false
        DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS]|r Button hidden.")
    elseif cmd == "size" then
        local s = tonumber(rest)
        if s and s >= 16 and s <= 200 then
            ApplySize(s)
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS]|r Button size set to " .. s .. "px.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS]|r Usage: /cts size <16-200>")
        end
    elseif cmd == "msg" then
        if rest and rest ~= "" then
            CTS_Config.message = rest
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS]|r Stamp message set to: " .. rest)
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS]|r Current message: " .. GetConfig("message"))
        end
    elseif cmd == "stamp" then
        StampCombatLog()
    elseif cmd == "reset" then
        CTS_Config.stampCount = 0
        DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS]|r Counter reset.")
    elseif cmd == "list" then
        if table.getn(CTS_Stamps) == 0 then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS]|r No stamps recorded yet.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS] Saved Stamps:|r")
            for i, entry in ipairs(CTS_Stamps) do
                DEFAULT_CHAT_FRAME:AddMessage("  " .. entry)
            end
        end
    elseif cmd == "clear" then
        CTS_Stamps = {}
        CTS_Config.stampCount = 0
        DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS]|r All stamps cleared.")
    elseif cmd == "help" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS] Commands:|r")
        DEFAULT_CHAT_FRAME:AddMessage("  /cts  or  /cts cfg  - Toggle config panel")
        DEFAULT_CHAT_FRAME:AddMessage("  /cts show  - Show button")
        DEFAULT_CHAT_FRAME:AddMessage("  /cts hide  - Hide button")
        DEFAULT_CHAT_FRAME:AddMessage("  /cts size <16-200>  - Resize button")
        DEFAULT_CHAT_FRAME:AddMessage("  /cts msg <text>  - Set stamp message")
        DEFAULT_CHAT_FRAME:AddMessage("  /cts stamp  - Stamp without clicking")
        DEFAULT_CHAT_FRAME:AddMessage("  /cts list  - List all saved stamps")
        DEFAULT_CHAT_FRAME:AddMessage("  /cts clear  - Clear all stamps & reset counter")
        DEFAULT_CHAT_FRAME:AddMessage("  /cts reset  - Reset stamp counter")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff4444[CTS]|r Unknown command. /cts help")
    end
end
