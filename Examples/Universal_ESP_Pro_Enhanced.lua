-- Universal ESP Pro Enhanced v3.8
-- UI: LinoriaLib | Full ESP | Aimbot | Config System
-- Features: Advanced ESP, Silent Aimbot, Third Person Aimbot, Rainbow Effects, Performance Optimized
-- Loadstring: loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptB/Universal-Scripts/main/Examples/Universal_ESP_Pro_Enhanced.lua", true))()

-- DEBUG: Script starting
print("[DEBUG] Universal ESP Pro Enhanced v3.8 - Script loading...")
print("[DEBUG] Third Person Aimbot Mode Added!")

-- ══════════════════════════════════════════
-- INITIALIZATION
-- ══════════════════════════════════════════
repeat task.wait() until game:IsLoaded()
print("[DEBUG] Game loaded, initializing services...")

-- Performance tracking
local _startTime = tick()
local _memoryUsage = 0
local _lastCleanup = tick()

-- ══════════════════════════════════════════
-- SERVICES & UTILITIES
-- ══════════════════════════════════════════
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera      = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Wait for character to load
repeat task.wait() until LocalPlayer and LocalPlayer.Character

-- Utility functions
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    return success, result
end

local function IsValidPlayer(player)
    return player and player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid")
end

local function GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- ══════════════════════════════════════════
-- LOAD LINORIA UI LIBRARY
-- ══════════════════════════════════════════
print("[DEBUG] Loading Linoria UI Library...")
local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library      = loadstring(game:HttpGet(repo .. "Library.lua", true))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua", true))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua", true))()
print("[DEBUG] Linoria UI Library loaded successfully!")

-- ══════════════════════════════════════════
-- ESP SETTINGS (Enhanced)
-- ══════════════════════════════════════════
local Settings = {
    Enabled   = true,
    TeamCheck = false,
    TeamColor = false,
    MaxDist   = 1000,
    Performance = {
        UpdateRate = 60,  -- FPS limit for ESP updates
        CullingDistance = 2000,
        CleanupInterval = 30,  -- seconds
    },
    Box = {
        Enabled   = true,
        Color     = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        Style     = "Corner",  -- Corner, Full, 3D
        CornerSize = 8,
    },
    Tracer = {
        Enabled   = true,
        Color     = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        Origin    = "Bottom",
        Style     = "Line",  -- Line, Arrow
    },
    Name = {
        Enabled      = true,
        Color        = Color3.fromRGB(255, 255, 255),
        Size         = 14,
        ShowDistance = true,
        ShowHealth   = false,
        ShowWeapon   = true,
        Outline      = true,
        Font         = "UI",
    },
    Health = {
        Enabled   = true,
        ShowBar   = true,
        ShowText  = false,
        Thickness = 3,
        Style     = "Bar",  -- Bar, Text, Both
        Position  = "Left",  -- Left, Right, Top, Bottom
    },
    Rainbow = {
        Enabled = false,
        Speed   = 1,
        Saturation = 1,
        Value = 1,
    },
    Chams = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.5,
        Material = "ForceField",
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

local function Notify(title, content, duration)
    Library:Notify(title .. "\n" .. content, duration or 4)
end

local function SaveConfig()
    local ok, err = pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(DeepSerialize(Settings)))
    end)
    if ok then
        print("[ESP] Config saved.")
        Notify("Config Saved", "Written to " .. CONFIG_FILE, 3)
    else
        warn("[ESP] Save failed: " .. tostring(err))
        Notify("Save Failed", tostring(err), 5)
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
        Notify("Config Loaded", "Restored from " .. CONFIG_FILE, 3)
    else
        Notify("No Config Found", "Save a config first.", 4)
    end
end

-- ══════════════════════════════════════════
-- ESP CORE (Enhanced)
-- ══════════════════════════════════════════
local ESPObjects = {}
local _lastESPUpdate = 0
local _espUpdateCount = 0

-- Enhanced color function with more options
local function GetColor(player, default)
    if Settings.Rainbow.Enabled then
        return Color3.fromHSV((tick() * Settings.Rainbow.Speed) % 1, Settings.Rainbow.Saturation, Settings.Rainbow.Value)
    end
    if Settings.TeamColor and player.Team then
        return player.TeamColor.Color
    end
    return default
end

-- Enhanced drawing function with better error handling
local function NewDrawing(class, props)
    local success, obj = SafeCall(Drawing.new, class)
    if not success or not obj then
        return { Visible = false, Remove = function() end, Color = Color3.new(1,1,1), Thickness = 1 }
    end
    
    -- Apply properties safely
    if props then
        for k, v in pairs(props) do
            SafeCall(function() obj[k] = v end)
        end
    end
    
    return obj
end

-- Optimized ESP hiding function
local function HideESP(e)
    if not e then return end
    
    -- Hide all drawing objects
    if e.Boxes then
        for _, l in ipairs(e.Boxes) do
            SafeCall(function() l.Visible = false end)
        end
    end
    
    local objects = {e.Tracer, e.Name, e.HpBg, e.HpBar, e.HpText, e.CornerBox, e.Chams}
    for _, obj in pairs(objects) do
        if obj then
            SafeCall(function() obj.Visible = false end)
        end
    end
end

-- Enhanced ESP creation with more features
local function CreateESP(player)
    if not IsValidPlayer(player) or ESPObjects[player] then return end
    
    local e = {
        Player = player,
        LastUpdate = tick(),
        Visible = true,
        Distance = 0,
        
        -- Standard ESP elements
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
        
        -- Enhanced features
        CornerBox = NewDrawing("Square", { Visible = false, Color = Color3.new(1,1,1), Thickness = 1, Size = Vector2.new(10,10), Filled = false }),
        Chams = {},  -- Will be populated if enabled
    }
    
    ESPObjects[player] = e
end

-- Enhanced ESP removal with proper cleanup
local function RemoveESP(player)
    local e = ESPObjects[player]
    if not e then return end
    
    -- Safely remove all drawing objects
    if e.Boxes then
        for _, l in ipairs(e.Boxes) do
            SafeCall(function() l:Remove() end)
        end
    end
    
    local objects = {e.Tracer, e.Name, e.HpBg, e.HpBar, e.HpText, e.CornerBox}
    for _, obj in pairs(objects) do
        if obj then
            SafeCall(function() obj:Remove() end)
        end
    end
    
    -- Remove chams if they exist
    if e.Chams then
        for _, cham in pairs(e.Chams) do
            SafeCall(function() cham:Remove() end)
        end
    end
    
    ESPObjects[player] = nil
end

-- Performance monitoring and cleanup
local function PerformCleanup()
    local currentTime = tick()
    if (currentTime - _lastCleanup) < Settings.Performance.CleanupInterval then return end
    
    _lastCleanup = currentTime
    local removedCount = 0
    
    for player, e in pairs(ESPObjects) do
        if not IsValidPlayer(player) then
            RemoveESP(player)
            removedCount = removedCount + 1
        end
    end
    
    if removedCount > 0 then
        print("[ESP] Cleaned up " .. removedCount .. " invalid ESP objects")
    end
end

-- Enhanced ESP update function with performance optimizations
local function UpdateESP(e)
    if not e or not e.Player then return end
    
    local player = e.Player
    local char = player.Character
    
    -- Quick validation checks
    if not char or not IsValidPlayer(player) then
        HideESP(e)
        return
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then
        HideESP(e)
        return
    end
    
    -- Distance and visibility checks
    local distance = GetDistance(hrp.Position, Camera.CFrame.Position)
    e.Distance = distance
    
    if distance > Settings.Performance.CullingDistance then
        HideESP(e)
        return
    end
    
    if Settings.TeamCheck and player.Team == LocalPlayer.Team then
        HideESP(e)
        return
    end
    
    -- Screen position calculation
    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    if not onScreen then
        HideESP(e)
        return
    end
    
    -- Update timing for performance
    e.LastUpdate = tick()
    
    -- Calculate box dimensions
    local scaleFactor = 1 / screenPos.Z
    local boxWidth = math.clamp(35 * scaleFactor * 100, 20, 200)
    local boxHeight = math.clamp(55 * scaleFactor * 100, 30, 300)
    local centerX, centerY = screenPos.X, screenPos.Y
    
    -- Box corners
    local topLeft = Vector2.new(centerX - boxWidth/2, centerY - boxHeight/2)
    local topRight = Vector2.new(centerX + boxWidth/2, centerY - boxHeight/2)
    local bottomLeft = Vector2.new(centerX - boxWidth/2, centerY + boxHeight/2)
    local bottomRight = Vector2.new(centerX + boxWidth/2, centerY + boxHeight/2)
    
    -- Get colors
    local boxColor = GetColor(player, Settings.Box.Color)
    local tracerColor = GetColor(player, Settings.Tracer.Color)
    local nameColor = GetColor(player, Settings.Name.Color)
    
    -- Update boxes based on style
    local boxVisible = Settings.Enabled and Settings.Box.Enabled
    if Settings.Box.Style == "Corner" and e.CornerBox then
        -- Corner box style
        e.CornerBox.Visible = boxVisible
        e.CornerBox.Position = topLeft
        e.CornerBox.Size = Vector2.new(boxWidth, boxHeight)
        e.CornerBox.Color = boxColor
        e.CornerBox.Thickness = Settings.Box.Thickness
        
        -- Hide regular boxes
        for _, box in ipairs(e.Boxes) do
            SafeCall(function() box.Visible = false end)
        end
    else
        -- Full box style
        e.Boxes[1].From = topLeft; e.Boxes[1].To = topRight; e.Boxes[1].Color = boxColor; e.Boxes[1].Thickness = Settings.Box.Thickness; e.Boxes[1].Visible = boxVisible
        e.Boxes[2].From = topRight; e.Boxes[2].To = bottomRight; e.Boxes[2].Color = boxColor; e.Boxes[2].Thickness = Settings.Box.Thickness; e.Boxes[2].Visible = boxVisible
        e.Boxes[3].From = bottomRight; e.Boxes[3].To = bottomLeft; e.Boxes[3].Color = boxColor; e.Boxes[3].Thickness = Settings.Box.Thickness; e.Boxes[3].Visible = boxVisible
        e.Boxes[4].From = bottomLeft; e.Boxes[4].To = topLeft; e.Boxes[4].Color = boxColor; e.Boxes[4].Thickness = Settings.Box.Thickness; e.Boxes[4].Visible = boxVisible
        
        -- Hide corner box
        if e.CornerBox then
            SafeCall(function() e.CornerBox.Visible = false end)
        end
    end
    
    -- Update tracer
    local tracerOrigin
    if Settings.Tracer.Origin == "Top" then
        tracerOrigin = Vector2.new(Camera.ViewportSize.X / 2, 0)
    elseif Settings.Tracer.Origin == "Center" then
        tracerOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        tracerOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    end
    
    e.Tracer.From = tracerOrigin
    e.Tracer.To = Vector2.new(centerX, centerY + boxHeight/2)
    e.Tracer.Color = tracerColor
    e.Tracer.Thickness = Settings.Tracer.Thickness
    e.Tracer.Visible = Settings.Enabled and Settings.Tracer.Enabled
    
    -- Update name with enhanced information
    local nameText = player.Name
    if Settings.Name.ShowDistance then
        nameText = nameText .. " [" .. math.floor(distance) .. "m]"
    end
    if Settings.Name.ShowHealth then
        nameText = nameText .. " [" .. math.floor(hum.Health) .. "hp]"
    end
    if Settings.Name.ShowWeapon then
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool and tool.Name then
            nameText = nameText .. " [" .. tool.Name .. "]"
        end
    end
    
    e.Name.Text = nameText
    e.Name.Position = Vector2.new(centerX, centerY - boxHeight/2 - 15)
    e.Name.Color = nameColor
    e.Name.Size = Settings.Name.Size
    e.Name.Visible = Settings.Enabled and Settings.Name.Enabled
    
    -- Update health bar
    if Settings.Health.Enabled then
        local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local healthColor = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
        
        -- Health bar positioning based on setting
        local barX, barY
        if Settings.Health.Position == "Left" then
            barX, barY = centerX - boxWidth/2 - 10, centerY
        elseif Settings.Health.Position == "Right" then
            barX, barY = centerX + boxWidth/2 + 10, centerY
        elseif Settings.Health.Position == "Top" then
            barX, barY = centerX, centerY - boxHeight/2 - 10
        else -- Bottom
            barX, barY = centerX, centerY + boxHeight/2 + 10
        end
        
        if Settings.Health.Position == "Left" or Settings.Health.Position == "Right" then
            -- Vertical health bar
            e.HpBg.From = Vector2.new(barX, barY - boxHeight/2)
            e.HpBg.To = Vector2.new(barX, barY + boxHeight/2)
            e.HpBar.From = Vector2.new(barX, barY + boxHeight/2 - (boxHeight * healthPercent))
            e.HpBar.To = Vector2.new(barX, barY + boxHeight/2)
        else
            -- Horizontal health bar
            e.HpBg.From = Vector2.new(barX - boxWidth/2, barY)
            e.HpBg.To = Vector2.new(barX + boxWidth/2, barY)
            e.HpBar.From = Vector2.new(barX - boxWidth/2, barY)
            e.HpBar.To = Vector2.new(barX - boxWidth/2 + (boxWidth * healthPercent), barY)
        end
        
        e.HpBg.Color = Color3.new(0, 0, 0)
        e.HpBg.Thickness = Settings.Health.Thickness + 1
        e.HpBg.Visible = Settings.Enabled and Settings.Health.ShowBar
        
        e.HpBar.Color = healthColor
        e.HpBar.Thickness = Settings.Health.Thickness
        e.HpBar.Visible = Settings.Enabled and Settings.Health.ShowBar
        
        -- Health text
        if Settings.Health.ShowText then
            e.HpText.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
            e.HpText.Position = Vector2.new(centerX, barY + 15)
            e.HpText.Color = healthColor
            e.HpText.Visible = Settings.Enabled and Settings.Health.ShowText
        else
            e.HpText.Visible = false
        end
    else
        e.HpBg.Visible = false
        e.HpBar.Visible = false
        e.HpText.Visible = false
    end
end

-- ══════════════════════════════════════════
-- AIMBOT CORE (Fixed)
-- ══════════════════════════════════════════
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local mouse = LocalPlayer:GetMouse()

local AimbotSettings = {
    Enabled        = false,
    TeamCheck      = false,
    AliveCheck     = true,
    WallCheck      = false,
    Toggle         = false,
    LockPart       = "Head",
    TriggerKey     = Enum.UserInputType.MouseButton2,
    Sensitivity    = 0.05,
    Sensitivity2   = 3.5,
    LockMode       = 1,  -- 1 = CFrame, 2 = MouseMove, 3 = ThirdPerson
    Prediction     = 0.065,
    ThirdPerson = {
        Smoothness    = 0.1,  -- Mouse movement smoothing
        MaxSpeed      = 15,   -- Maximum mouse speed
        Acceleration  = 0.8,  -- Mouse acceleration
        Deadzone      = 5,    -- Deadzone around target
    },
    FOV = {
        Enabled       = true,
        Visible       = true,
        Radius        = 120,
        Thickness     = 1,
        Color         = Color3.fromRGB(255, 255, 255),
        LockedColor   = Color3.fromRGB(255, 100, 100),
        OutlineColor  = Color3.fromRGB(0, 0, 0),
        Rainbow       = false,
        RainbowSpeed  = 1,
    },
}

local _aimbotRunning  = false
local _aimbotLocked   = nil
local _aimbotAnim     = nil
local _aimbotConns    = {}
local currentTarget  = nil
local aiming          = false
local _lastEnabledState = false

print("[DEBUG] Aimbot initialized - _aimbotRunning:", _aimbotRunning, "Enabled:", AimbotSettings.Enabled)

local FOVCircle        = Drawing.new("Circle")
local FOVCircleOutline = Drawing.new("Circle")
FOVCircle.Visible        = false
FOVCircleOutline.Visible = false

-- Fixed functions (using same method as ESP)
local function _aimbotGetRainbow()
    return Color3.fromHSV((tick() * AimbotSettings.FOV.RainbowSpeed) % 1, 1, 1)
end

local function _aimbotCancelLock()
    _aimbotLocked = nil
    currentTarget = nil
    if _aimbotAnim then 
        _aimbotAnim:Cancel() 
        _aimbotAnim = nil
    end
end

local function checkTeam(player)
    if AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then
        return true
    end
    return false
end

local function checkWall(targetCharacter)
    if not AimbotSettings.WallCheck then return false end
    
    local targetHead = targetCharacter:FindFirstChild(AimbotSettings.LockPart)
    if not targetHead then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (targetHead.Position - origin).unit * (targetHead.Position - origin).magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    return raycastResult and raycastResult.Instance ~= nil
end

local function predict(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local velocity = hrp.Velocity
        local predictedPosition = hrp.Position + (velocity * AimbotSettings.Prediction)
        return predictedPosition
    end
    return nil
end

local function getHeadPosition(player)
    if player and player.Character then
        local head = player.Character:FindFirstChild("Head")
        if head then
            return head.Position
        end
    end
    return nil
end

-- Third Person Mouse Aimbot Function
local _lastMousePos = Vector2.new(0, 0)
local _mouseVelocity = Vector2.new(0, 0)
local _targetMousePos = Vector2.new(0, 0)

local function thirdPersonAimbot(targetPos)
    if not targetPos then return end
    
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
    if not onScreen then return end
    
    local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
    local currentMousePos = UserInputService:GetMouseLocation()
    
    local distance = (targetScreenPos - currentMousePos).Magnitude
    
    if distance <= AimbotSettings.ThirdPerson.Deadzone then
        return
    end
    
    if AimbotSettings.ThirdPerson.Smoothness <= 0.01 then
        local delta = targetScreenPos - currentMousePos
        mousemoverel(delta.X, delta.Y)
        _mouseVelocity = Vector2.new(0, 0)
    else
        local desiredVelocity = (targetScreenPos - currentMousePos) * AimbotSettings.ThirdPerson.Acceleration
        
        local speed = desiredVelocity.Magnitude
        if speed > AimbotSettings.ThirdPerson.MaxSpeed then
            desiredVelocity = desiredVelocity.Unit * AimbotSettings.ThirdPerson.MaxSpeed
        end
        
        _mouseVelocity = _mouseVelocity:Lerp(desiredVelocity, AimbotSettings.ThirdPerson.Smoothness)
        mousemoverel(_mouseVelocity.X, _mouseVelocity.Y)
    end
    
    _lastMousePos = currentMousePos
    _targetMousePos = targetScreenPos
end

local function _aimbotGetClosest()
    if _aimbotLocked and currentTarget then
        local char = currentTarget.Character
        local part = char and char:FindFirstChild(AimbotSettings.LockPart)
        if not part or not char:FindFirstChildOfClass("Humanoid") or char.Humanoid.Health <= 0 then 
            _aimbotCancelLock()
            return 
        end
        
        if AimbotSettings.LockMode ~= 3 then
            local sv, _ = Camera:WorldToViewportPoint(part.Position)
            local dist = (UserInputService:GetMouseLocation() - Vector2.new(sv.X, sv.Y)).Magnitude
            local radius = AimbotSettings.FOV.Enabled and AimbotSettings.FOV.Radius or 2000
            if dist > radius or checkTeam(currentTarget) or checkWall(char) then 
                _aimbotCancelLock()
            end
        else
            -- Third person: check FOV from screen center
            local sv, _ = Camera:WorldToViewportPoint(part.Position)
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local dist = (screenCenter - Vector2.new(sv.X, sv.Y)).Magnitude
            local radius = AimbotSettings.FOV.Enabled and AimbotSettings.FOV.Radius or 2000
            if dist > radius or checkTeam(currentTarget) or checkWall(char) then
                _aimbotCancelLock()
            end
        end
        return
    end

    local best, bestDist = nil, math.huge
    local radius = AimbotSettings.FOV.Enabled and AimbotSettings.FOV.Radius or 2000
    bestDist = radius

    -- In third person mode, measure FOV from screen center
    local refPos = AimbotSettings.LockMode == 3
        and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        or UserInputService:GetMouseLocation()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local part = char and char:FindFirstChild(AimbotSettings.LockPart)
        
        if not char or not hum or not part then continue end
        if AimbotSettings.AliveCheck and hum.Health <= 0 then continue end
        if checkTeam(plr) then continue end
        if checkWall(char) then continue end
        
        local sv, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        
        local dist = (refPos - Vector2.new(sv.X, sv.Y)).Magnitude
        if dist < bestDist then
            bestDist, best = dist, plr
        end
    end
    
    _aimbotLocked = best
    currentTarget = best
end

local function smoothCFrame(from, to)
    return from:Lerp(to, AimbotSettings.Sensitivity)
end

local function _aimbotUpdate()
    local fov = AimbotSettings.FOV
    local mousePos = UserInputService:GetMouseLocation()

    -- Update FOV Circle
    if fov.Enabled and AimbotSettings.Enabled then
        local fovColor
        if fov.Rainbow then
            fovColor = _aimbotGetRainbow()
        elseif _aimbotLocked then
            fovColor = fov.LockedColor
        else
            fovColor = fov.Color
        end
        
        -- Update FOV circle properties
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        FOVCircleOutline.Position = Vector2.new(mousePos.X, mousePos.Y)
        FOVCircle.Visible = fov.Visible
        FOVCircleOutline.Visible = fov.Visible
        FOVCircle.Radius = fov.Radius
        FOVCircleOutline.Radius = fov.Radius
        FOVCircle.Thickness = fov.Thickness
        FOVCircleOutline.Thickness = fov.Thickness + 2
        FOVCircle.Color = fovColor
        FOVCircleOutline.Color = fov.OutlineColor
    else
        FOVCircle.Visible = false
        FOVCircleOutline.Visible = false
    end

    -- Only run aimbot logic if it's enabled and running
    if not AimbotSettings.Enabled or not _aimbotRunning then
        if _aimbotLocked then
            _aimbotCancelLock()
        end
        return
    end

    _aimbotGetClosest()

    if not _aimbotLocked or not currentTarget then 
        return 
    end
    
    local char = currentTarget.Character
    if not char then 
        _aimbotCancelLock()
        return 
    end
    
    -- Get the correct target part
    local targetPart = char:FindFirstChild(AimbotSettings.LockPart)
    if not targetPart then 
        _aimbotCancelLock()
        return 
    end

    -- Use prediction for moving targets
    local targetPos
    if AimbotSettings.LockPart == "Head" then
        -- For head, use head position with prediction
        local headPos = getHeadPosition(currentTarget)
        if headPos then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local velocity = hrp.Velocity
                targetPos = headPos + (velocity * AimbotSettings.Prediction)
            else
                targetPos = headPos
            end
        else
            targetPos = targetPart.Position
        end
    else
        -- For other parts, use prediction on the part itself
        targetPos = predict(currentTarget) or targetPart.Position
    end

    if AimbotSettings.LockMode == 2 then
        -- MouseMove mode
        local sv = Camera:WorldToViewportPoint(targetPos)
        local targetPos2D = Vector2.new(sv.X, sv.Y)
        local delta = targetPos2D - mousePos
        mousemoverel(delta.X / AimbotSettings.Sensitivity2, delta.Y / AimbotSettings.Sensitivity2)
    elseif AimbotSettings.LockMode == 3 then
        -- Third Person mode
        thirdPersonAimbot(targetPos)
    else
        -- CFrame mode (silent aim)
        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        
        if AimbotSettings.Sensitivity > 0 then
            Camera.CFrame = smoothCFrame(Camera.CFrame, targetCFrame)
        else
            Camera.CFrame = targetCFrame
        end
    end
end

-- Fixed input handling
_aimbotConns.render = RunService.RenderStepped:Connect(_aimbotUpdate)

_aimbotConns.inputBegan = UserInputService.InputBegan:Connect(function(input)
    if not AimbotSettings.Enabled then 
        return 
    end
    
    if not _lastEnabledState then
        _lastEnabledState = true
    end
    
    local tk = AimbotSettings.TriggerKey
    local inputMatched = false
    
    -- Check for right mouse button
    if input.UserInputType == Enum.UserInputType.MouseButton2 and tk == Enum.UserInputType.MouseButton2 then
        inputMatched = true
    end
    
    -- Check for keyboard keybind
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == tk then
        inputMatched = true
    end
    
    -- If input matches the trigger key
    if inputMatched then
        if AimbotSettings.Toggle then
            _aimbotRunning = not _aimbotRunning
            aiming = _aimbotRunning
            if not _aimbotRunning then 
                _aimbotCancelLock()
            end
        else
            _aimbotRunning = true
            aiming = true
        end
    end
end)

_aimbotConns.inputEnded = UserInputService.InputEnded:Connect(function(input)
    if AimbotSettings.Toggle or not AimbotSettings.Enabled then return end
    
    local tk = AimbotSettings.TriggerKey
    local inputMatched = false
    
    -- Check for right mouse button release
    if input.UserInputType == Enum.UserInputType.MouseButton2 and tk == Enum.UserInputType.MouseButton2 then
        inputMatched = true
    end
    
    -- Check for keyboard keybind release
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == tk then
        inputMatched = true
    end
    
    -- If input matches the trigger key and not in toggle mode
    if inputMatched then
        _aimbotRunning = false
        aiming = false
        _aimbotCancelLock()
    end
end)

-- ══════════════════════════════════════════
-- BUILD LINORIA UI
-- ══════════════════════════════════════════
local Window = Library:CreateWindow({
    Title        = "Universal ESP Pro Enhanced",
    Center       = true,
    AutoShow     = true,
    TabPadding   = 10,
    MenuFadeTime = 0.35,
})

local Tabs = {
    ESP     = Window:AddTab("ESP"),
    Aimbot  = Window:AddTab("Aimbot"),
    Visuals = Window:AddTab("Visuals"),
    Config  = Window:AddTab("Config"),
    UI      = Window:AddTab("UI Settings"),
}

-- ══════════════════════════════════════════
-- TAB: ESP
-- ══════════════════════════════════════════

-- LEFT: General + Box + Health
local GbMaster = Tabs.ESP:AddLeftGroupbox("General")
GbMaster:AddToggle("ESPEnabled", {
    Text    = "ESP Enabled",
    Default = Settings.Enabled,
    Tooltip = "Master switch — turns off all ESP rendering",
})
GbMaster:AddLabel("Toggle Keybind"):AddKeyPicker("ESPKeybind", {
    Default         = "RightShift",
    SyncToggleState = true,
    Mode            = "Toggle",
    Text            = "ESP On/Off",
    Tooltip         = "Keybind synced to the ESP Enabled toggle",
})
GbMaster:AddDivider()
GbMaster:AddToggle("TeamCheck", {
    Text    = "Team Check",
    Default = Settings.TeamCheck,
    Tooltip = "Skip ESP for players on your team",
})
GbMaster:AddToggle("TeamColor", {
    Text    = "Team Color",
    Default = Settings.TeamColor,
    Tooltip = "Use each player's team color instead of custom colors",
})
GbMaster:AddDivider()
GbMaster:AddSlider("MaxDist", {
    Text     = "Max Distance",
    Default  = Settings.MaxDist,
    Min      = 100,
    Max      = 5000,
    Rounding = 0,
    Suffix   = " st",
    Compact  = false,
    Tooltip  = "ESP hidden beyond this distance",
})

local GbBox = Tabs.ESP:AddLeftGroupbox("Box")
GbBox:AddToggle("BoxEnabled", {
    Text    = "Enabled",
    Default = Settings.Box.Enabled,
    Tooltip = "Bounding box around each player",
})
local DepBox = GbBox:AddDependencyBox()
DepBox:AddSlider("BoxThickness", {
    Text     = "Thickness",
    Default  = Settings.Box.Thickness,
    Min      = 1,
    Max      = 5,
    Rounding = 0,
    Compact  = true,
    Tooltip  = "Box line thickness",
})
DepBox:AddLabel("Color"):AddColorPicker("BoxColor", {
    Default = Settings.Box.Color,
    Title   = "Box Color",
})
DepBox:SetupDependencies({ { Toggles.BoxEnabled, true } })

local GbHealth = Tabs.ESP:AddLeftGroupbox("Health Bar")
GbHealth:AddToggle("HealthEnabled", {
    Text    = "Enabled",
    Default = Settings.Health.Enabled,
    Tooltip = "Side health bar for each player",
})
local DepHealth = GbHealth:AddDependencyBox()
DepHealth:AddToggle("HealthText", {
    Text    = "Show HP Number",
    Default = Settings.Health.ShowText,
    Tooltip = "Show numeric HP above the bar",
})
DepHealth:AddSlider("HealthThickness", {
    Text     = "Thickness",
    Default  = Settings.Health.Thickness,
    Min      = 1,
    Max      = 6,
    Rounding = 0,
    Compact  = true,
    Tooltip  = "Health bar line thickness",
})
DepHealth:SetupDependencies({ { Toggles.HealthEnabled, true } })

-- RIGHT: Tracer + Name
local GbTracer = Tabs.ESP:AddRightGroupbox("Tracer")
GbTracer:AddToggle("TracerEnabled", {
    Text    = "Enabled",
    Default = Settings.Tracer.Enabled,
    Tooltip = "Line from screen edge to each player",
})
local DepTracer = GbTracer:AddDependencyBox()
DepTracer:AddDropdown("TracerOrigin", {
    Values  = { "Bottom", "Center", "Top" },
    Default = 1,
    Text    = "Origin Point",
    Tooltip = "Where the tracer starts on screen",
})
DepTracer:AddSlider("TracerThickness", {
    Text     = "Thickness",
    Default  = Settings.Tracer.Thickness,
    Min      = 1,
    Max      = 5,
    Rounding = 0,
    Compact  = true,
    Tooltip  = "Tracer line thickness",
})
DepTracer:AddLabel("Color"):AddColorPicker("TracerColor", {
    Default = Settings.Tracer.Color,
    Title   = "Tracer Color",
})
DepTracer:SetupDependencies({ { Toggles.TracerEnabled, true } })

local GbName = Tabs.ESP:AddRightGroupbox("Name Label")
GbName:AddToggle("NameEnabled", {
    Text    = "Enabled",
    Default = Settings.Name.Enabled,
    Tooltip = "Player name above their character",
})
local DepName = GbName:AddDependencyBox()
DepName:AddToggle("ShowDistance", {
    Text    = "Distance",
    Default = Settings.Name.ShowDistance,
    Tooltip = "Append [Xm] to the name",
})
DepName:AddToggle("ShowHealthName", {
    Text    = "Health",
    Default = Settings.Name.ShowHealth,
    Tooltip = "Append [Xhp] to the name",
})
DepName:AddToggle("NameOutline", {
    Text    = "Outline",
    Default = Settings.Name.Outline,
    Tooltip = "Dark outline behind text",
})
DepName:AddSlider("NameSize", {
    Text     = "Size",
    Default  = Settings.Name.Size,
    Min      = 10,
    Max      = 24,
    Rounding = 0,
    Compact  = true,
    Tooltip  = "Name text size",
})
DepName:AddLabel("Color"):AddColorPicker("NameColor", {
    Default = Settings.Name.Color,
    Title   = "Name Color",
})
DepName:SetupDependencies({ { Toggles.NameEnabled, true } })

-- ══════════════════════════════════════════
-- TAB: AIMBOT
-- ══════════════════════════════════════════

-- LEFT: General aimbot settings
local GbAimbot = Tabs.Aimbot:AddLeftGroupbox("Aimbot")
GbAimbot:AddToggle("AimbotEnabled", {
    Text    = "Enabled",
    Default = AimbotSettings.Enabled,
    Tooltip = "Master aimbot toggle",
})
GbAimbot:AddLabel("Trigger Key"):AddKeyPicker("AimbotKey", {
    Default         = "RightControl",
    SyncToggleState = false,
    Mode            = "Hold",
    Text            = "Aim",
    Tooltip         = "Hold/press this key to activate aimbot (default: RCtrl; RMB handled automatically)",
})
GbAimbot:AddDivider()
GbAimbot:AddToggle("AimbotToggleMode", {
    Text    = "Toggle Mode",
    Default = AimbotSettings.Toggle,
    Tooltip = "Press key to toggle instead of hold",
})
GbAimbot:AddToggle("AimbotTeamCheck", {
    Text    = "Team Check",
    Default = AimbotSettings.TeamCheck,
    Tooltip = "Skip teammates",
})
GbAimbot:AddToggle("AimbotAliveCheck", {
    Text    = "Alive Check",
    Default = AimbotSettings.AliveCheck,
    Tooltip = "Skip dead players",
})
GbAimbot:AddToggle("AimbotWallCheck", {
    Text    = "Wall Check",
    Default = AimbotSettings.WallCheck,
    Tooltip = "Skip players behind walls",
})
GbAimbot:AddDivider()
GbAimbot:AddDropdown("AimbotLockPart", {
    Values  = { "Head", "HumanoidRootPart", "UpperTorso", "Torso" },
    Default = 1,
    Text    = "Lock Part",
    Tooltip = "Body part to aim at",
})
GbAimbot:AddDropdown("AimbotLockMode", {
    Values  = { "CFrame (Silent)", "MouseMove", "Third Person" },
    Default = 1,
    Text    = "Lock Mode",
    Tooltip = "CFrame = silent aim; MouseMove = moves cursor; Third Person = smooth mouse control",
})
GbAimbot:AddSlider("AimbotSensitivity", {
    Text     = "Smoothness",
    Default  = 0.05,
    Min      = 0,
    Max      = 1,
    Rounding = 2,
    Compact  = true,
    Tooltip  = "0 = instant lock; higher = smoother (CFrame mode)",
})
GbAimbot:AddSlider("AimbotPrediction", {
    Text     = "Prediction",
    Default  = 0.065,
    Min      = 0,
    Max      = 0.2,
    Rounding = 3,
    Compact  = true,
    Tooltip  = "Bullet prediction for moving targets",
})
GbAimbot:AddSlider("AimbotSensitivity2", {
    Text     = "Mouse Sensitivity",
    Default  = 35,
    Min      = 1,
    Max      = 100,
    Rounding = 0,
    Compact  = true,
    Tooltip  = "Divisor for MouseMove mode speed",
})
GbAimbot:AddDivider()
GbAimbot:AddLabel("Third Person Settings")
GbAimbot:AddSlider("ThirdPersonSmoothness", {
    Text     = "Smoothness",
    Default  = AimbotSettings.ThirdPerson.Smoothness,
    Min      = 0,
    Max      = 1,
    Rounding = 2,
    Compact  = true,
    Tooltip  = "0 = Instant Aimlock | Lower = Smoother | Higher = More Responsive",
})
GbAimbot:AddSlider("ThirdPersonMaxSpeed", {
    Text     = "Max Speed",
    Default  = AimbotSettings.ThirdPerson.MaxSpeed,
    Min      = 1,
    Max      = 50,
    Rounding = 0,
    Compact  = true,
    Tooltip  = "Maximum mouse movement speed",
})
GbAimbot:AddSlider("ThirdPersonAcceleration", {
    Text     = "Acceleration",
    Default  = AimbotSettings.ThirdPerson.Acceleration,
    Min      = 0.1,
    Max      = 2,
    Rounding = 2,
    Compact  = true,
    Tooltip  = "Mouse acceleration factor",
})
GbAimbot:AddSlider("ThirdPersonDeadzone", {
    Text     = "Deadzone",
    Default  = AimbotSettings.ThirdPerson.Deadzone,
    Min      = 0,
    Max      = 20,
    Rounding = 0,
    Compact  = true,
    Tooltip  = "Deadzone around target (pixels)",
})

-- RIGHT: FOV circle
local GbFOV = Tabs.Aimbot:AddRightGroupbox("FOV Circle")
GbFOV:AddToggle("FOVEnabled", {
    Text    = "Enabled",
    Default = AimbotSettings.FOV.Enabled,
    Tooltip = "Use FOV circle to limit targeting range",
})
GbFOV:AddToggle("FOVVisible", {
    Text    = "Visible",
    Default = AimbotSettings.FOV.Visible,
    Tooltip = "Show the FOV circle on screen",
})
local DepFOV = GbFOV:AddDependencyBox()
DepFOV:AddSlider("FOVRadius", {
    Text     = "Radius",
    Default  = AimbotSettings.FOV.Radius,
    Min      = 10,
    Max      = 600,
    Rounding = 0,
    Compact  = true,
    Tooltip  = "FOV circle radius in pixels",
})
DepFOV:AddSlider("FOVThickness", {
    Text     = "Thickness",
    Default  = AimbotSettings.FOV.Thickness,
    Min      = 1,
    Max      = 5,
    Rounding = 0,
    Compact  = true,
    Tooltip  = "FOV circle line thickness",
})
DepFOV:AddToggle("FOVRainbow", {
    Text    = "Rainbow",
    Default = AimbotSettings.FOV.Rainbow,
    Tooltip = "Rainbow color on FOV circle",
})
DepFOV:AddSlider("FOVRainbowSpeed", {
    Text     = "Rainbow Speed",
    Default  = AimbotSettings.FOV.RainbowSpeed,
    Min      = 0.1,
    Max      = 5,
    Rounding = 1,
    Compact  = true,
    Tooltip  = "Speed of rainbow color change",
})
DepFOV:AddLabel("Circle Color"):AddColorPicker("FOVColor", {
    Default = AimbotSettings.FOV.Color,
    Title   = "FOV Circle Color",
})
DepFOV:AddLabel("Locked Color"):AddColorPicker("FOVLockedColor", {
    Default = AimbotSettings.FOV.LockedColor,
    Title   = "FOV Locked Color",
})
DepFOV:AddLabel("Outline Color"):AddColorPicker("FOVOutlineColor", {
    Default = AimbotSettings.FOV.OutlineColor,
    Title   = "FOV Outline Color",
})
DepFOV:SetupDependencies({ { Toggles.FOVEnabled, true } })

-- ══════════════════════════════════════════
-- TAB: VISUALS
-- ══════════════════════════════════════════
local GbRainbow = Tabs.Visuals:AddLeftGroupbox("Rainbow")
GbRainbow:AddToggle("RainbowEnabled", {
    Text    = "Rainbow Mode",
    Default = Settings.Rainbow.Enabled,
    Tooltip = "Cycle all ESP colors through the spectrum",
})
local DepRainbow = GbRainbow:AddDependencyBox()
DepRainbow:AddSlider("RainbowSpeed", {
    Text     = "Speed",
    Default  = Settings.Rainbow.Speed,
    Min      = 1,
    Max      = 20,
    Rounding = 0,
    Compact  = true,
    Suffix   = "x",
    Tooltip  = "Rainbow cycle speed",
})
DepRainbow:SetupDependencies({ { Toggles.RainbowEnabled, true } })

local GbColorNote = Tabs.Visuals:AddRightGroupbox("Color Priority")
GbColorNote:AddLabel("1. Rainbow (overrides all)", true)
GbColorNote:AddLabel("2. Team Color (per player)", true)
GbColorNote:AddLabel("3. Custom colors (default)", true)
GbColorNote:AddDivider()
GbColorNote:AddLabel("Set colors in the ESP tab\nunder each feature.", true)

-- ══════════════════════════════════════════
-- TAB: CONFIG
-- ══════════════════════════════════════════
local GbConfig = Tabs.Config:AddLeftGroupbox("ESP Config")
GbConfig:AddButton({
    Text    = "Save Config",
    Func    = SaveConfig,
    Tooltip = "Save current settings to " .. CONFIG_FILE,
})
GbConfig:AddButton({
    Text    = "Load Config",
    Func    = LoadConfig,
    Tooltip = "Load settings from " .. CONFIG_FILE,
})
GbConfig:AddDivider()
GbConfig:AddLabel("File: " .. CONFIG_FILE, true)

local GbScriptInfo = Tabs.Config:AddRightGroupbox("About")
GbScriptInfo:AddLabel("Universal ESP Pro Enhanced", true)
GbScriptInfo:AddLabel("v3.5  |  LinoriaLib", true)
GbScriptInfo:AddDivider()
GbScriptInfo:AddLabel("Loadstring in script header.", true)
GbScriptInfo:AddDivider()
GbScriptInfo:AddButton({
    Text    = "Copy Loadstring",
    Func    = function()
        if setclipboard then
            setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptB/Universal-Scripts/main/Examples/Universal_ESP_Pro_Enhanced.lua",true))()')
            Notify("Copied!", "Loadstring copied to clipboard.", 3)
        else
            Notify("Unavailable", "setclipboard not supported.", 3)
        end
    end,
    Tooltip = "Copy the loadstring to clipboard",
})

-- ══════════════════════════════════════════
-- TAB: UI SETTINGS
-- ══════════════════════════════════════════
local GbMenu = Tabs.UI:AddLeftGroupbox("Menu")
GbMenu:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
    Default = "End",
    NoUI    = true,
    Text    = "Toggle Menu",
    Tooltip = "Show/hide the menu",
})
GbMenu:AddDivider()
GbMenu:AddButton({
    Text    = "Unload Script",
    Func    = function()
        Notify("Unloading", "Removing all ESP...", 2)
        task.wait(0.6)
        Library:Unload()
    end,
    Tooltip = "Remove all ESP and destroy the UI",
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

-- Aimbot callbacks
Toggles.AimbotEnabled:OnChanged(function()    
    AimbotSettings.Enabled = Toggles.AimbotEnabled.Value
    _lastEnabledState = AimbotSettings.Enabled
    print("[DEBUG] Aimbot enabled state changed to:", _lastEnabledState)
end)
Toggles.AimbotToggleMode:OnChanged(function() AimbotSettings.Toggle          = Toggles.AimbotToggleMode.Value end)
Toggles.AimbotTeamCheck:OnChanged(function()  AimbotSettings.TeamCheck       = Toggles.AimbotTeamCheck.Value  end)
Toggles.AimbotAliveCheck:OnChanged(function() AimbotSettings.AliveCheck      = Toggles.AimbotAliveCheck.Value end)
Toggles.AimbotWallCheck:OnChanged(function()  AimbotSettings.WallCheck       = Toggles.AimbotWallCheck.Value  end)
Options.AimbotLockPart:OnChanged(function()   AimbotSettings.LockPart        = Options.AimbotLockPart.Value   end)
Options.AimbotLockMode:OnChanged(function()
    local mode = Options.AimbotLockMode.Value
    if mode == "CFrame (Silent)" then
        AimbotSettings.LockMode = 1
        print("[DEBUG] LockMode changed to: CFrame (Silent)")
    elseif mode == "MouseMove" then
        AimbotSettings.LockMode = 2
        print("[DEBUG] LockMode changed to: MouseMove")
    else
        AimbotSettings.LockMode = 3  -- Third Person
        print("[DEBUG] LockMode changed to: Third Person")
    end
end)
Options.AimbotSensitivity:OnChanged(function()  AimbotSettings.Sensitivity  = Options.AimbotSensitivity.Value  end)
Options.AimbotSensitivity2:OnChanged(function() AimbotSettings.Sensitivity2 = Options.AimbotSensitivity2.Value end)
Options.AimbotPrediction:OnChanged(function() AimbotSettings.Prediction = Options.AimbotPrediction.Value end)

-- Third Person callbacks
Options.ThirdPersonSmoothness:OnChanged(function() AimbotSettings.ThirdPerson.Smoothness = Options.ThirdPersonSmoothness.Value end)
Options.ThirdPersonMaxSpeed:OnChanged(function() AimbotSettings.ThirdPerson.MaxSpeed = Options.ThirdPersonMaxSpeed.Value end)
Options.ThirdPersonAcceleration:OnChanged(function() AimbotSettings.ThirdPerson.Acceleration = Options.ThirdPersonAcceleration.Value end)
Options.ThirdPersonDeadzone:OnChanged(function() AimbotSettings.ThirdPerson.Deadzone = Options.ThirdPersonDeadzone.Value end)

-- FOV callbacks
Toggles.FOVEnabled:OnChanged(function()   AimbotSettings.FOV.Enabled      = Toggles.FOVEnabled.Value   end)
Toggles.FOVVisible:OnChanged(function()   AimbotSettings.FOV.Visible      = Toggles.FOVVisible.Value   end)
Toggles.FOVRainbow:OnChanged(function()   AimbotSettings.FOV.Rainbow      = Toggles.FOVRainbow.Value   end)
Options.FOVRainbowSpeed:OnChanged(function() AimbotSettings.FOV.RainbowSpeed = Options.FOVRainbowSpeed.Value end)
Options.FOVRadius:OnChanged(function()    AimbotSettings.FOV.Radius       = Options.FOVRadius.Value    end)
Options.FOVThickness:OnChanged(function() AimbotSettings.FOV.Thickness    = Options.FOVThickness.Value end)
Options.FOVColor:OnChanged(function()     AimbotSettings.FOV.Color        = Options.FOVColor.Value     end)
Options.FOVLockedColor:OnChanged(function()  AimbotSettings.FOV.LockedColor  = Options.FOVLockedColor.Value  end)
Options.FOVOutlineColor:OnChanged(function() AimbotSettings.FOV.OutlineColor = Options.FOVOutlineColor.Value end)

Options.AimbotKey:OnChanged(function()
    local kc = Options.AimbotKey.Value
    if kc and kc ~= Enum.KeyCode.Unknown then
        AimbotSettings.TriggerKey = kc
        print("[DEBUG] Aimbot keybind changed to: " .. tostring(kc))
    end
end)

-- ══════════════════════════════════════════
-- WATERMARK
-- ══════════════════════════════════════════
-- Watermark: bottom-left
Library:SetWatermarkVisibility(true)
Library.Watermark.Position = UDim2.new(0, 10, 1, -30)

-- KeybindFrame: bottom-left above watermark, auto-hide after 10s
Library.KeybindFrame.Position = UDim2.new(0, 10, 1, -55)
Library.KeybindFrame.Visible = true
task.delay(10, function()
    if Library.KeybindFrame then
        Library.KeybindFrame.Visible = false
    end
end)

-- NotificationArea: bottom-right corner exactly at screen corner
Library.NotificationArea.AnchorPoint = Vector2.new(1, 1)
Library.NotificationArea.Position    = UDim2.new(1, 0, 1, 0)
Library.NotificationArea.Size        = UDim2.new(0, 300, 0, 600)
-- Make the list layout stack from the bottom upward
local _notifLayout = Library.NotificationArea:FindFirstChildOfClass("UIListLayout")
if _notifLayout then
    _notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
end

local _frameTimer   = tick()
local _frameCounter = 0
local _fps          = 60
local _ping         = 0

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
    local ok, p = pcall(function()
        return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    _ping = ok and p or _ping
    Library:SetWatermark(("Universal ESP v3.5  |  %d fps  |  %dms  |  %d players"):format(
        math.floor(_fps), _ping,
        math.max(0, #Players:GetPlayers() - 1)
    ))
    for _, e in pairs(ESPObjects) do
        pcall(UpdateESP, e)
    end
end)

Library:OnUnload(function()
    _wmConn:Disconnect()
    for _, c in pairs(_aimbotConns) do pcall(function() c:Disconnect() end) end
    pcall(function() FOVCircle:Remove() end)
    pcall(function() FOVCircleOutline:Remove() end)
    _aimbotCancelLock()
    UserInputService.MouseDeltaSensitivity = 1
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
print("[DEBUG] Config loaded, showing notification...")
Notify("Universal ESP Pro Enhanced", "Loaded! Press End to toggle menu.", 5)
print("[DEBUG] Universal ESP Pro Enhanced v3.8 loaded successfully!")
print("[DEBUG] Script is ready. Press End key to toggle UI.")
print("[DEBUG] Third Person Aimbot Mode: Select 'Third Person' in Lock Mode dropdown!")
