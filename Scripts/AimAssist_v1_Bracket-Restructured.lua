--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

-- ===================================
-- LOAD BRACKET LIBRARY FIRST
-- ===================================

local success, Bracket = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Roblox/main/BracketV3.lua"))()
end)

if not success or not Bracket then
    warn("❌ Failed to load Bracket Library!")
    warn("⚠️ Script cannot continue without GUI library")
    return
end

print("✅ Bracket Library loaded successfully")

-- ===================================
-- SERVICES
-- ===================================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local plr = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = plr:GetMouse()

-- ===================================
-- VARIABLES
-- ===================================

local hue = 0
local rainbowFov = false
local rainbowSpeed = 0.005

local aimFov = 100
local aiming = false
local predictionStrength = 0.065
local smoothing = 0.05

local aimbotEnabled = false
local wallCheck = true
local stickyAimEnabled = false
local teamCheck = false
local healthCheck = false
local minHealth = 0

local circleColor = Color3.fromRGB(255, 0, 0)
local targetedCircleColor = Color3.fromRGB(0, 255, 0)

-- ===================================
-- BRACKET WINDOW CONFIG
-- ===================================

local Config = {
    WindowName = "▶ Universal Aimbot ◀",
    Color = Color3.fromRGB(255, 128, 64),
    Keybind = Enum.KeyCode.RightBracket
}

local Window = Bracket:CreateWindow(Config, game:GetService("CoreGui"))

-- ===================================
-- CREATE TABS
-- ===================================

local AimbotTab = Window:CreateTab("Aimbot 🎯")
local SettingsTab = Window:CreateTab("Settings ⚙️")
local VisualTab = Window:CreateTab("Visual 🎨")

-- ===================================
-- AIMBOT TAB SECTIONS
-- ===================================

local MainSection = AimbotTab:CreateSection("Main Controls")
local SettingsSection = AimbotTab:CreateSection("Aimbot Settings")

-- ===================================
-- MAIN CONTROLS
-- ===================================

local aimbotToggle = MainSection:CreateToggle("Aimbot", nil, function(Value)
    aimbotEnabled = Value
    fovCircle.Visible = Value
end)

aimbotToggle:AddToolTip("Enable/Disable the aimbot")

-- ===================================
-- AIMBOT SETTINGS
-- ===================================

local smoothingSlider = SettingsSection:CreateSlider("Smoothing", 0, 100, 5, false, function(Value)
    smoothing = 1 - (Value / 100)
end)
smoothingSlider:AddToolTip("Higher values = smoother aim")

local predictionSlider = SettingsSection:CreateSlider("Prediction Strength", 0, 0.2, 0.065, true, function(Value)
    predictionStrength = Value
end)
predictionSlider:AddToolTip("How much to predict enemy movement")

local fovSlider = SettingsSection:CreateSlider("Aimbot FOV", 10, 500, 100, false, function(Value)
    aimFov = Value
    fovCircle.Radius = Value
end)
fovSlider:AddToolTip("Field of view for aimbot")

-- ===================================
-- CHECK SETTINGS
-- ===================================

local wallCheckToggle = SettingsSection:CreateToggle("Wall Check", true, function(Value)
    wallCheck = Value
end)
wallCheckToggle:AddToolTip("Only aim at visible enemies")

local teamCheckToggle = SettingsSection:CreateToggle("Team Check", false, function(Value)
    teamCheck = Value
end)
teamCheckToggle:AddToolTip("Don't aim at teammates")

local healthCheckToggle = SettingsSection:CreateToggle("Health Check", false, function(Value)
    healthCheck = Value
end)
healthCheckToggle:AddToolTip("Don't aim at dead players")

local minHealthSlider = SettingsSection:CreateSlider("Min Health", 0, 100, 0, false, function(Value)
    minHealth = Value
end)
minHealthSlider:AddToolTip("Minimum health to target")

local stickyAimToggle = SettingsSection:CreateToggle("Sticky Aim", false, function(Value)
    stickyAimEnabled = Value
end)
stickyAimToggle:AddToolTip("Stay locked on target")

-- ===================================
-- VISUAL TAB
-- ===================================

local VisualSection = VisualTab:CreateSection("Visual Settings")

local rainbowFovToggle = VisualSection:CreateToggle("Rainbow FOV", false, function(Value)
    rainbowFov = Value
end)
rainbowFovToggle:AddToolTip("Rainbow colored FOV circle")

local rainbowSpeedSlider = VisualSection:CreateSlider("Rainbow Speed", 0.001, 0.02, 0.005, true, function(Value)
    rainbowSpeed = Value
end)
rainbowSpeedSlider:AddToolTip("Speed of rainbow effect")

local fovColorPicker = VisualSection:CreateColorpicker("FOV Color", function(Color)
    circleColor = Color
end)
fovColorPicker:AddToolTip("Color of FOV circle")
fovColorPicker:UpdateColor(circleColor)

local targetColorPicker = VisualSection:CreateColorpicker("Target Color", function(Color)
    targetedCircleColor = Color
end)
targetColorPicker:AddToolTip("Color when targeting")
targetColorPicker:UpdateColor(targetedCircleColor)

-- ===================================
-- SETTINGS TAB
-- ===================================

local ConfigSection = SettingsTab:CreateSection("Configuration")

ConfigSection:CreateLabel("Press RightBracket to toggle UI")

local resetButton = ConfigSection:CreateButton("Reset All Settings", function()
    -- Reset all variables to defaults
    aimbotEnabled = false
    wallCheck = true
    stickyAimEnabled = false
    teamCheck = false
    healthCheck = false
    minHealth = 0
    aimFov = 100
    predictionStrength = 0.065
    smoothing = 0.05
    rainbowFov = false
    rainbowSpeed = 0.005
    
    -- Update UI elements
    aimbotToggle:SetValue(false)
    wallCheckToggle:SetValue(true)
    stickyAimToggle:SetValue(false)
    teamCheckToggle:SetValue(false)
    healthCheckToggle:SetValue(false)
    minHealthSlider:SetValue(0)
    fovSlider:SetValue(100)
    predictionSlider:SetValue(0.065)
    smoothingSlider:SetValue(5)
    rainbowFovToggle:SetValue(false)
    rainbowSpeedSlider:SetValue(0.005)
    
    Bracket:Notification({
        Title = "Settings Reset",
        Description = "All settings have been reset to defaults",
        Duration = 3
    })
end)
resetButton:AddToolTip("Reset all settings to default values")

-- ===================================
-- FOV CIRCLE
-- ===================================

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Radius = aimFov
fovCircle.Filled = false
fovCircle.Color = circleColor
fovCircle.Visible = false

local currentTarget = nil

-- ===================================
-- AIMBOT FUNCTIONS
-- ===================================

local function checkTeam(player)
    if teamCheck and player.Team == plr.Team then
        return true
    end
    return false
end

local function checkWall(targetCharacter)
    local targetHead = targetCharacter:FindFirstChild("Head")
    if not targetHead then return true end

    local origin = camera.CFrame.Position
    local direction = (targetHead.Position - origin).unit * (targetHead.Position - origin).magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {plr.Character, targetCharacter}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    return raycastResult and raycastResult.Instance ~= nil
end

local function getTarget()
    local nearestPlayer = nil
    local shortestCursorDistance = aimFov
    local shortestPlayerDistance = math.huge
    local cameraPos = camera.CFrame.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= plr and player.Character and player.Character:FindFirstChild("Head") and not checkTeam(player) then
            if player.Character.Humanoid.Health >= minHealth or not healthCheck then
                local head = player.Character.Head
                local headPos = camera:WorldToViewportPoint(head.Position)
                local screenPos = Vector2.new(headPos.X, headPos.Y)
                local mousePos = Vector2.new(mouse.X, mouse.Y)
                local cursorDistance = (screenPos - mousePos).Magnitude
                local playerDistance = (head.Position - cameraPos).Magnitude

                if cursorDistance < shortestCursorDistance and headPos.Z > 0 then
                    if not checkWall(player.Character) or not wallCheck then
                        if playerDistance < shortestPlayerDistance then
                            shortestPlayerDistance = playerDistance
                            shortestCursorDistance = cursorDistance
                            nearestPlayer = player
                        end
                    end
                end
            end
        end
    end

    return nearestPlayer
end

local function predict(player)
    if player and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") then
        local head = player.Character.Head
        local hrp = player.Character.HumanoidRootPart
        local velocity = hrp.Velocity
        local predictedPosition = head.Position + (velocity * predictionStrength)
        return predictedPosition
    end
    return nil
end

local function smooth(from, to)
    return from:Lerp(to, smoothing)
end

local function aimAt(player)
    local predictedPosition = predict(player)
    if predictedPosition then
        if player.Character.Humanoid.Health >= minHealth or not healthCheck then
            local targetCFrame = CFrame.new(camera.CFrame.Position, predictedPosition)
            camera.CFrame = smooth(camera.CFrame, targetCFrame)
        end
    end
end

-- ===================================
-- MAIN LOOP
-- ===================================

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local offset = 50
        fovCircle.Position = Vector2.new(mouse.X, mouse.Y + offset)

        if rainbowFov then
            hue = hue + rainbowSpeed
            if hue > 1 then hue = 0 end
            fovCircle.Color = Color3.fromHSV(hue, 1, 1)
        else
            if aiming and currentTarget then
                fovCircle.Color = targetedCircleColor
            else
                fovCircle.Color = circleColor
            end
        end

        if aiming then
            if stickyAimEnabled and currentTarget then
                local headPos = camera:WorldToViewportPoint(currentTarget.Character.Head.Position)
                local screenPos = Vector2.new(headPos.X, headPos.Y)
                local cursorDistance = (screenPos - Vector2.new(mouse.X, mouse.Y)).Magnitude

                if cursorDistance > aimFov or (wallCheck and checkWall(currentTarget.Character)) or checkTeam(currentTarget) then
                    currentTarget = nil
                end
            end

            if not stickyAimEnabled or not currentTarget then
                currentTarget = getTarget()
            end

            if currentTarget then
                aimAt(currentTarget)
            end
        else
            currentTarget = nil
        end
    end
end)

-- ===================================
-- MOUSE INPUT
-- ===================================

mouse.Button2Down:Connect(function()
    if aimbotEnabled then
        aiming = true
    end
end)

mouse.Button2Up:Connect(function()
    if aimbotEnabled then
        aiming = false
    end
end)

-- ===================================
-- KEYBIND FOR UI TOGGLE
-- ===================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightBracket and not gameProcessed then
        Window:Toggle()
    end
end)

-- ===================================
-- NOTIFICATION ON LOAD
-- ===================================

Bracket:Notification({
    Title = "Universal Aimbot",
    Description = "Loaded successfully! Press RightBracket to toggle UI",
    Duration = 3
})

print("✅ Universal Aimbot loaded successfully!")
print("🎯 Right Click to aim")
print("⌨️ Press RightBracket to toggle UI")
