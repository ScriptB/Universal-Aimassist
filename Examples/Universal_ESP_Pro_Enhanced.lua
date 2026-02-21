-- Universal ESP Pro Enhanced v3.3
-- UI: LinoriaLib | Full ESP | Config System
-- Loadstring: loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptB/Universal-Scripts/main/Examples/Universal_ESP_Pro_Enhanced.lua", true))()

repeat task.wait() until game:IsLoaded()

-- ══════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Camera      = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════
-- LOAD LINORIA UI LIBRARY
-- ══════════════════════════════════════════
local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library      = loadstring(game:HttpGet(repo .. "Library.lua", true))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua", true))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua", true))()

-- ══════════════════════════════════════════
-- ESP SETTINGS
-- ══════════════════════════════════════════
local Settings = {
    Enabled   = true,
    TeamCheck = false,
    TeamColor = false,
    MaxDist   = 1000,
    Box = {
        Enabled   = true,
        Color     = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
    },
    Tracer = {
        Enabled   = true,
        Color     = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        Origin    = "Bottom",
    },
    Name = {
        Enabled      = true,
        Color        = Color3.fromRGB(255, 255, 255),
        Size         = 14,
        ShowDistance = true,
        ShowHealth   = false,
        Outline      = true,
    },
    Health = {
        Enabled   = true,
        ShowBar   = true,
        ShowText  = false,
        Thickness = 3,
    },
    Rainbow = {
        Enabled = false,
        Speed   = 1,
    },
}

-- ══════════════════════════════════════════
-- CONFIG SYSTEM
-- ══════════════════════════════════════════
local CONFIG_FILE = "UniversalESP_Config.json"

local function SerializeColor(c)
    return { R = c.R, G = c.G, B = c.B }
end
local function DeserializeColor(d)
    return Color3.new(d.R, d.G, d.B)
end
local function DeepSerialize(t)
    local o = {}
    for k, v in pairs(t) do
        if typeof(v) == "Color3" then
            o[k] = SerializeColor(v)
        elseif type(v) == "table" then
            o[k] = DeepSerialize(v)
        else
            o[k] = v
        end
    end
    return o
end
local function DeepDeserialize(t)
    local o = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            if v.R ~= nil and v.G ~= nil and v.B ~= nil then
                o[k] = DeserializeColor(v)
            else
                o[k] = DeepDeserialize(v)
            end
        else
            o[k] = v
        end
    end
    return o
end

local function SaveConfig()
    local ok, err = pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(DeepSerialize(Settings)))
    end)
    if ok then
        print("[ESP] Config saved.")
        Library:Notify("Config saved!", 3)
    else
        warn("[ESP] Save failed: " .. tostring(err))
    end
end

local function LoadConfig()
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(CONFIG_FILE))
    end)
    if ok and data then
        local loaded = DeepDeserialize(data)
        for k, v in pairs(loaded) do
            if Settings[k] ~= nil then
                if type(v) == "table" and type(Settings[k]) == "table" then
                    for sk, sv in pairs(v) do
                        Settings[k][sk] = sv
                    end
                else
                    Settings[k] = v
                end
            end
        end
        print("[ESP] Config loaded.")
        Library:Notify("Config loaded!", 3)
    else
        Library:Notify("No config found.", 3)
    end
end

-- ══════════════════════════════════════════
-- ESP CORE
-- ══════════════════════════════════════════
local ESPObjects = {}

local function GetColor(player, default)
    if Settings.Rainbow.Enabled then
        return Color3.fromHSV((tick() * Settings.Rainbow.Speed) % 1, 1, 1)
    end
    if Settings.TeamColor and player.Team then
        return player.TeamColor.Color
    end
    return default
end

local function NewDrawing(class, props)
    local ok, obj = pcall(Drawing.new, class)
    if not ok then
        return { Visible = false, Remove = function() end }
    end
    for k, v in pairs(props) do
        pcall(function() obj[k] = v end)
    end
    return obj
end

local function HideESP(e)
    for _, l in ipairs(e.Boxes) do l.Visible = false end
    e.Tracer.Visible  = false
    e.Name.Visible    = false
    e.HpBg.Visible    = false
    e.HpBar.Visible   = false
    e.HpText.Visible  = false
end

local function CreateESP(player)
    if ESPObjects[player] then return end
    local e = {
        Player = player,
        Boxes = {
            NewDrawing("Line", { Thickness = 1, Color = Color3.new(1,1,1), Transparency = 1, Visible = false }),
            NewDrawing("Line", { Thickness = 1, Color = Color3.new(1,1,1), Transparency = 1, Visible = false }),
            NewDrawing("Line", { Thickness = 1, Color = Color3.new(1,1,1), Transparency = 1, Visible = false }),
            NewDrawing("Line", { Thickness = 1, Color = Color3.new(1,1,1), Transparency = 1, Visible = false }),
        },
        Tracer = NewDrawing("Line", { Thickness = 1, Color = Color3.new(1,1,1), Transparency = 1, Visible = false }),
        Name   = NewDrawing("Text", { Text = player.Name, Size = 14, Center = true, Outline = true, Color = Color3.new(1,1,1), Transparency = 1, Visible = false }),
        HpBg   = NewDrawing("Line", { Thickness = 4, Color = Color3.new(0,0,0), Transparency = 0.5, Visible = false }),
        HpBar  = NewDrawing("Line", { Thickness = 3, Color = Color3.new(0,1,0), Transparency = 1, Visible = false }),
        HpText = NewDrawing("Text", { Text = "100hp", Size = 11, Center = true, Outline = true, Color = Color3.new(1,1,1), Transparency = 1, Visible = false }),
    }
    ESPObjects[player] = e
end

local function RemoveESP(player)
    local e = ESPObjects[player]
    if not e then return end
    for _, l in ipairs(e.Boxes) do pcall(function() l:Remove() end) end
    pcall(function() e.Tracer:Remove() end)
    pcall(function() e.Name:Remove() end)
    pcall(function() e.HpBg:Remove() end)
    pcall(function() e.HpBar:Remove() end)
    pcall(function() e.HpText:Remove() end)
    ESPObjects[player] = nil
end

local function UpdateESP(e)
    local player = e.Player
    local char   = player.Character
    if not char then HideESP(e); return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp then HideESP(e); return end

    local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
    if dist > Settings.MaxDist then HideESP(e); return end
    if Settings.TeamCheck and player.Team == LocalPlayer.Team then HideESP(e); return end

    local rv, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    if not onScreen then HideESP(e); return end

    local sf = 1 / rv.Z
    local w  = math.clamp(35 * sf * 100, 20, 200)
    local h  = math.clamp(55 * sf * 100, 30, 300)
    local cx, cy = rv.X, rv.Y

    local tl = Vector2.new(cx - w/2, cy - h/2)
    local tr = Vector2.new(cx + w/2, cy - h/2)
    local bl = Vector2.new(cx - w/2, cy + h/2)
    local br = Vector2.new(cx + w/2, cy + h/2)

    local bc = GetColor(player, Settings.Box.Color)
    local bv = Settings.Enabled and Settings.Box.Enabled
    local bt = Settings.Box.Thickness
    e.Boxes[1].From = tl; e.Boxes[1].To = tr; e.Boxes[1].Color = bc; e.Boxes[1].Thickness = bt; e.Boxes[1].Visible = bv
    e.Boxes[2].From = tr; e.Boxes[2].To = br; e.Boxes[2].Color = bc; e.Boxes[2].Thickness = bt; e.Boxes[2].Visible = bv
    e.Boxes[3].From = br; e.Boxes[3].To = bl; e.Boxes[3].Color = bc; e.Boxes[3].Thickness = bt; e.Boxes[3].Visible = bv
    e.Boxes[4].From = bl; e.Boxes[4].To = tl; e.Boxes[4].Color = bc; e.Boxes[4].Thickness = bt; e.Boxes[4].Visible = bv

    local tOrigin
    if Settings.Tracer.Origin == "Top" then
        tOrigin = Vector2.new(Camera.ViewportSize.X / 2, 0)
    elseif Settings.Tracer.Origin == "Center" then
        tOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        tOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    end
    e.Tracer.From      = tOrigin
    e.Tracer.To        = Vector2.new(cx, cy + h/2)
    e.Tracer.Color     = GetColor(player, Settings.Tracer.Color)
    e.Tracer.Thickness = Settings.Tracer.Thickness
    e.Tracer.Visible   = Settings.Enabled and Settings.Tracer.Enabled

    local nameStr = player.Name
    if Settings.Name.ShowDistance then nameStr = nameStr .. " [" .. math.floor(dist) .. "m]" end
    if Settings.Name.ShowHealth and hum then nameStr = nameStr .. " [" .. math.floor(hum.Health) .. "hp]" end
    e.Name.Text     = nameStr
    e.Name.Size     = Settings.Name.Size
    e.Name.Color    = GetColor(player, Settings.Name.Color)
    e.Name.Outline  = Settings.Name.Outline
    e.Name.Position = Vector2.new(cx, tl.Y - Settings.Name.Size - 2)
    e.Name.Visible  = Settings.Enabled and Settings.Name.Enabled

    if hum and Settings.Health.Enabled and Settings.Health.ShowBar then
        local ratio  = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        local bx     = tl.X - 6
        local hColor = Color3.fromRGB(math.floor(255 * (1 - ratio)), math.floor(255 * ratio), 0)
        e.HpBg.From       = Vector2.new(bx, tl.Y)
        e.HpBg.To         = Vector2.new(bx, bl.Y)
        e.HpBg.Thickness  = Settings.Health.Thickness + 1
        e.HpBg.Visible    = Settings.Enabled
        e.HpBar.From      = Vector2.new(bx, bl.Y - (bl.Y - tl.Y) * ratio)
        e.HpBar.To        = Vector2.new(bx, bl.Y)
        e.HpBar.Color     = hColor
        e.HpBar.Thickness = Settings.Health.Thickness
        e.HpBar.Visible   = Settings.Enabled
        if Settings.Health.ShowText then
            e.HpText.Text     = math.floor(hum.Health) .. "hp"
            e.HpText.Position = Vector2.new(bx, tl.Y - 12)
            e.HpText.Visible  = Settings.Enabled
        else
            e.HpText.Visible = false
        end
    else
        e.HpBg.Visible   = false
        e.HpBar.Visible  = false
        e.HpText.Visible = false
    end
end

-- ══════════════════════════════════════════
-- BUILD LINORIA UI
-- ══════════════════════════════════════════
local Window = Library:CreateWindow({
    Title        = "Universal ESP Pro Enhanced",
    Center       = true,
    AutoShow     = true,
    TabPadding   = 8,
    MenuFadeTime = 0.2,
})

local Tabs = {
    ESP     = Window:AddTab("ESP"),
    Visuals = Window:AddTab("Visuals"),
    Config  = Window:AddTab("Config"),
    UI      = Window:AddTab("UI Settings"),
}

-- ══════════════════════════════════════════
-- TAB: ESP
-- ══════════════════════════════════════════

-- Left: Master controls
local GbMaster = Tabs.ESP:AddLeftGroupbox("Master")
GbMaster:AddToggle("ESPEnabled", {
    Text    = "ESP Enabled",
    Default = Settings.Enabled,
    Tooltip = "Master toggle — disables all ESP rendering when off",
})
GbMaster:AddLabel("ESP Keybind"):AddKeyPicker("ESPKeybind", {
    Default         = "RightShift",
    SyncToggleState = true,
    Mode            = "Toggle",
    Text            = "Toggle ESP",
    Tooltip         = "Keybind to toggle ESP on/off",
})
GbMaster:AddDivider()
GbMaster:AddToggle("TeamCheck", {
    Text    = "Team Check",
    Default = Settings.TeamCheck,
    Tooltip = "Hides ESP on players in your own team",
})
GbMaster:AddToggle("TeamColor", {
    Text    = "Use Team Color",
    Default = Settings.TeamColor,
    Tooltip = "Overrides ESP colors with each player's team color",
})
GbMaster:AddDivider()
GbMaster:AddSlider("MaxDist", {
    Text     = "Max Distance",
    Default  = Settings.MaxDist,
    Min      = 100,
    Max      = 5000,
    Rounding = 0,
    Suffix   = " studs",
    Tooltip  = "Players beyond this distance will not have ESP drawn",
})

-- Right: Feature tabbox (Box / Tracer / Name / Health)
local EspTabbox = Tabs.ESP:AddRightTabbox()

-- Box tab
local TbBox = EspTabbox:AddTab("Box")
TbBox:AddToggle("BoxEnabled", {
    Text    = "Enabled",
    Default = Settings.Box.Enabled,
    Tooltip = "Draw a bounding box around players",
})
local DepBox = TbBox:AddDependencyBox()
DepBox:AddSlider("BoxThickness", {
    Text     = "Thickness",
    Default  = Settings.Box.Thickness,
    Min      = 1,
    Max      = 5,
    Rounding = 0,
    Tooltip  = "Line thickness of the box",
})
DepBox:AddLabel("Color"):AddColorPicker("BoxColor", {
    Default = Settings.Box.Color,
    Title   = "Box ESP Color",
})
DepBox:SetupDependencies({ { Toggles.BoxEnabled, true } })

-- Tracer tab
local TbTracer = EspTabbox:AddTab("Tracer")
TbTracer:AddToggle("TracerEnabled", {
    Text    = "Enabled",
    Default = Settings.Tracer.Enabled,
    Tooltip = "Draw a line from screen edge to each player",
})
local DepTracer = TbTracer:AddDependencyBox()
DepTracer:AddSlider("TracerThickness", {
    Text     = "Thickness",
    Default  = Settings.Tracer.Thickness,
    Min      = 1,
    Max      = 5,
    Rounding = 0,
    Tooltip  = "Line thickness of the tracer",
})
DepTracer:AddDropdown("TracerOrigin", {
    Values  = { "Bottom", "Center", "Top" },
    Default = 1,
    Text    = "Origin",
    Tooltip = "Where on screen the tracer line starts from",
})
DepTracer:AddLabel("Color"):AddColorPicker("TracerColor", {
    Default = Settings.Tracer.Color,
    Title   = "Tracer Color",
})
DepTracer:SetupDependencies({ { Toggles.TracerEnabled, true } })

-- Name tab
local TbName = EspTabbox:AddTab("Name")
TbName:AddToggle("NameEnabled", {
    Text    = "Enabled",
    Default = Settings.Name.Enabled,
    Tooltip = "Show player names above their heads",
})
local DepName = TbName:AddDependencyBox()
DepName:AddToggle("ShowDistance", {
    Text    = "Show Distance",
    Default = Settings.Name.ShowDistance,
    Tooltip = "Appends distance in studs to the name label",
})
DepName:AddToggle("ShowHealthName", {
    Text    = "Show Health",
    Default = Settings.Name.ShowHealth,
    Tooltip = "Appends current HP to the name label",
})
DepName:AddToggle("NameOutline", {
    Text    = "Outline",
    Default = Settings.Name.Outline,
    Tooltip = "Draws a dark outline behind the name text",
})
DepName:AddSlider("NameSize", {
    Text     = "Font Size",
    Default  = Settings.Name.Size,
    Min      = 10,
    Max      = 24,
    Rounding = 0,
    Tooltip  = "Size of the name label text",
})
DepName:AddLabel("Color"):AddColorPicker("NameColor", {
    Default = Settings.Name.Color,
    Title   = "Name Label Color",
})
DepName:SetupDependencies({ { Toggles.NameEnabled, true } })

-- Health tab
local TbHealth = EspTabbox:AddTab("Health")
TbHealth:AddToggle("HealthEnabled", {
    Text    = "Enabled",
    Default = Settings.Health.Enabled,
    Tooltip = "Show a health bar beside each player",
})
local DepHealth = TbHealth:AddDependencyBox()
DepHealth:AddToggle("HealthText", {
    Text    = "Show HP Text",
    Default = Settings.Health.ShowText,
    Tooltip = "Displays the numeric HP value above the health bar",
})
DepHealth:AddSlider("HealthThickness", {
    Text     = "Bar Thickness",
    Default  = Settings.Health.Thickness,
    Min      = 1,
    Max      = 6,
    Rounding = 0,
    Tooltip  = "Thickness of the health bar line",
})
DepHealth:SetupDependencies({ { Toggles.HealthEnabled, true } })

-- ══════════════════════════════════════════
-- TAB: VISUALS
-- ══════════════════════════════════════════
local GbRainbow = Tabs.Visuals:AddLeftGroupbox("Rainbow Mode")
GbRainbow:AddToggle("RainbowEnabled", {
    Text    = "Rainbow Enabled",
    Default = Settings.Rainbow.Enabled,
    Tooltip = "Cycles all ESP element colors through the full color spectrum",
})
local DepRainbow = GbRainbow:AddDependencyBox()
DepRainbow:AddSlider("RainbowSpeed", {
    Text     = "Cycle Speed",
    Default  = Settings.Rainbow.Speed,
    Min      = 1,
    Max      = 20,
    Rounding = 0,
    Suffix   = "x",
    Tooltip  = "How fast the rainbow cycles",
})
DepRainbow:SetupDependencies({ { Toggles.RainbowEnabled, true } })

local GbVisInfo = Tabs.Visuals:AddRightGroupbox("Info")
GbVisInfo:AddLabel("Rainbow overrides all custom\nESP colors when enabled.", true)
GbVisInfo:AddDivider()
GbVisInfo:AddLabel("Team Color overrides custom\ncolors per-player when enabled.", true)

-- ══════════════════════════════════════════
-- TAB: CONFIG
-- ══════════════════════════════════════════
local GbConfig = Tabs.Config:AddLeftGroupbox("Manual Config")
GbConfig:AddButton({
    Text    = "Save Config",
    Func    = SaveConfig,
    Tooltip = "Saves current ESP settings to UniversalESP_Config.json",
})
GbConfig:AddButton({
    Text    = "Load Config",
    Func    = LoadConfig,
    Tooltip = "Loads ESP settings from UniversalESP_Config.json",
})
GbConfig:AddDivider()
GbConfig:AddLabel("File: UniversalESP_Config.json", true)

local GbScriptInfo = Tabs.Config:AddRightGroupbox("Script Info")
GbScriptInfo:AddLabel("Universal ESP Pro Enhanced", true)
GbScriptInfo:AddLabel("Version: v3.4", true)
GbScriptInfo:AddLabel("UI: LinoriaLib", true)
GbScriptInfo:AddDivider()
GbScriptInfo:AddLabel("See script header for\nGitHub raw loadstring.", true)

-- ══════════════════════════════════════════
-- TAB: UI SETTINGS
-- ══════════════════════════════════════════
local GbMenu = Tabs.UI:AddLeftGroupbox("Menu")
GbMenu:AddButton({
    Text    = "Unload Script",
    Func    = function()
        Library:Notify("Unloading Universal ESP...", 2)
        task.wait(0.5)
        Library:Unload()
    end,
    Tooltip = "Removes all ESP and destroys the UI",
})
GbMenu:AddDivider()
GbMenu:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
    Default = "End",
    NoUI    = true,
    Text    = "Toggle Menu",
    Tooltip = "Press this key to show/hide the menu",
})
Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("UniversalESP")
SaveManager:SetFolder("UniversalESP")
ThemeManager:ApplyToTab(Tabs.UI)
SaveManager:BuildConfigSection(Tabs.UI)

-- ══════════════════════════════════════════
-- ONCHANGED CALLBACKS (decoupled from UI)
-- ══════════════════════════════════════════
Toggles.ESPEnabled:OnChanged(function()    Settings.Enabled          = Toggles.ESPEnabled.Value    end)
Toggles.TeamCheck:OnChanged(function()     Settings.TeamCheck         = Toggles.TeamCheck.Value     end)
Toggles.TeamColor:OnChanged(function()     Settings.TeamColor         = Toggles.TeamColor.Value     end)
Options.MaxDist:OnChanged(function()       Settings.MaxDist           = Options.MaxDist.Value       end)

Toggles.BoxEnabled:OnChanged(function()    Settings.Box.Enabled       = Toggles.BoxEnabled.Value    end)
Options.BoxThickness:OnChanged(function()  Settings.Box.Thickness      = Options.BoxThickness.Value  end)
Options.BoxColor:OnChanged(function()      Settings.Box.Color          = Options.BoxColor.Value      end)

Toggles.TracerEnabled:OnChanged(function()   Settings.Tracer.Enabled   = Toggles.TracerEnabled.Value   end)
Options.TracerThickness:OnChanged(function() Settings.Tracer.Thickness  = Options.TracerThickness.Value end)
Options.TracerOrigin:OnChanged(function()    Settings.Tracer.Origin     = Options.TracerOrigin.Value    end)
Options.TracerColor:OnChanged(function()     Settings.Tracer.Color      = Options.TracerColor.Value     end)

Toggles.NameEnabled:OnChanged(function()    Settings.Name.Enabled      = Toggles.NameEnabled.Value    end)
Toggles.ShowDistance:OnChanged(function()   Settings.Name.ShowDistance  = Toggles.ShowDistance.Value   end)
Toggles.ShowHealthName:OnChanged(function() Settings.Name.ShowHealth    = Toggles.ShowHealthName.Value  end)
Toggles.NameOutline:OnChanged(function()    Settings.Name.Outline       = Toggles.NameOutline.Value     end)
Options.NameSize:OnChanged(function()       Settings.Name.Size          = Options.NameSize.Value        end)
Options.NameColor:OnChanged(function()      Settings.Name.Color         = Options.NameColor.Value       end)

Toggles.HealthEnabled:OnChanged(function()   Settings.Health.Enabled    = Toggles.HealthEnabled.Value   end)
Toggles.HealthText:OnChanged(function()      Settings.Health.ShowText    = Toggles.HealthText.Value      end)
Options.HealthThickness:OnChanged(function() Settings.Health.Thickness   = Options.HealthThickness.Value end)

Toggles.RainbowEnabled:OnChanged(function() Settings.Rainbow.Enabled    = Toggles.RainbowEnabled.Value  end)
Options.RainbowSpeed:OnChanged(function()   Settings.Rainbow.Speed       = Options.RainbowSpeed.Value    end)

Options.ESPKeybind:OnClick(function()
    Settings.Enabled = Toggles.ESPEnabled.Value
end)

-- ══════════════════════════════════════════
-- WATERMARK
-- ══════════════════════════════════════════
Library:SetWatermarkVisibility(true)
Library.KeybindFrame.Visible = true

local _frameTimer   = tick()
local _frameCounter = 0
local _fps          = 60

-- ══════════════════════════════════════════
-- ESP RUNTIME
-- ══════════════════════════════════════════
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

local _wmConn = RunService.RenderStepped:Connect(function()
    _frameCounter += 1
    if (tick() - _frameTimer) >= 1 then
        _fps          = _frameCounter
        _frameTimer   = tick()
        _frameCounter = 0
    end
    Library:SetWatermark(("Universal ESP  |  %d fps  |  %d players"):format(
        math.floor(_fps),
        math.max(0, #Players:GetPlayers() - 1)
    ))
    for _, e in pairs(ESPObjects) do
        pcall(UpdateESP, e)
    end
end)

Library:OnUnload(function()
    _wmConn:Disconnect()
    for player in pairs(ESPObjects) do
        RemoveESP(player)
    end
    print("[Universal ESP] Unloaded.")
end)

-- ══════════════════════════════════════════
-- GLOBAL API
-- ══════════════════════════════════════════
getgenv().UniversalESP = {
    Settings   = Settings,
    SaveConfig = SaveConfig,
    LoadConfig = LoadConfig,
    Destroy    = function() Library:Unload() end,
}

SaveManager:LoadAutoloadConfig()
Library:Notify("Universal ESP Pro Enhanced loaded!\nPress End to toggle menu.", 5)
print("[Universal ESP Pro Enhanced v3.4] Loaded successfully.")
