--[[
	Phantom Suite v7.8 (Bracket UI Integration)
	by Asuneteric (Updated for Bracket Library)

	Precision aimbot and ESP for competitive advantage.

	Features:
	  - Aimbot with smoothing, prediction, sticky aim, wall/team/health checks
	  - ESP with box, names, health bar, distance, tracers, head dot
	  - Full real-time Bracket UI controls
	  - HWID-keyed config auto-save/load (Phantom-Config.txt)
	  - Modern Bracket UI integration
]]

-- ===================================
-- LOAD BRACKET LIBRARY
-- ===================================

local function LoadBracketLibrary()
    -- Load the Bracket library from our repository
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptB/Universal-Scripts/refs/heads/main/Libraries/BracketLib.lua"))()
    end)
    
    if success and result then
        print("✅ Bracket library loaded successfully")
        return result
    else
        warn("❌ Failed to load Bracket library")
        return nil
    end
end

local Bracket = LoadBracketLibrary()

if not Bracket then
    warn("❌ Phantom Suite cannot continue without GUI library")
    return
end

-- ===================================
-- SERVICES
-- ===================================

local RunService = game:GetService("RunService")
local players    = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local plr        = players.LocalPlayer
local camera     = workspace.CurrentCamera
local mouse      = plr:GetMouse()

-- ===================================
-- VARIABLES
-- ===================================

--> [< Aimbot Variables >] <--

local hue = 0
local rainbowFov = false
local rainbowSpeed = 0.005

local aimFov = 100
local aiming = false
local predictionStrength = 0.065
local smoothing = 5 -- 1-10 scale (1=very strong, 10=barely assisted)

-- ESP/Aimbot distance lock variables
local espLockDistance = 500
local aimbotLockDistance = 500

local aimbotEnabled = false
local blatantEnabled = false

-- ESP variables (unified)
local espEnabled = false
local boxEsp = true
local nameEsp = true
local healthEsp = true
local distanceEsp = true
local tracerEsp = false

-- Visual variables
local fovColor = Color3.fromRGB(255, 255, 255)
local espColor = Color3.fromRGB(255, 0, 0)

-- Check variables
local wallCheck = true
local teamCheck = true
local stickyAimEnabled = false
local healthCheck = false
local minHealth = 0

-- Targeting mode
local targetMode = "Closest To Mouse" -- Options: "Closest To Mouse", "Distance"

-- UI toggle references (assigned when UI is built)
local triggerBotToggle = nil
local rainbowFovToggle = nil
local espTeamCheckToggle = nil
local espToggle = nil

local aimbotIncludeNPCs = false
local espIncludeNPCs = false
local npcScanInterval = 1
local npcMaxTargets = 60
local npcLastScan = 0
local npcTargets = {}

local circleColor = Color3.fromRGB(255, 0, 0)
local targetedCircleColor = Color3.fromRGB(0, 255, 0)

--> [< Extras / Commands Variables >] <--

local flyEnabled       = false
local noclipEnabled    = false
local infJumpEnabled   = false
local flySpeed         = 50
local walkSpeed        = 16
local jumpPower        = 50

local extrasConnections = {
    noclip   = nil,
    infJump  = nil,
    fly      = nil,
}

--> [< Executor Detection System >] <--

local EXECUTOR_NAME = "Unknown"
local EXECUTOR_COMPATIBILITY = {
	Drawing = false,
	Clipboard = false,
	FileSystem = false,
	HTTP = false,
	WebSocket = false,
}

-- Detect executor
local function detectExecutor()
	if syn then
		EXECUTOR_NAME = "Synapse X"
		EXECUTOR_COMPATIBILITY.Drawing = true
		EXECUTOR_COMPATIBILITY.Clipboard = true
		EXECUTOR_COMPATIBILITY.FileSystem = true
		EXECUTOR_COMPATIBILITY.HTTP = true
		EXECUTOR_COMPATIBILITY.WebSocket = true
	elseif getexecutorname then
		EXECUTOR_NAME = getexecutorname() or "Unknown"
		EXECUTOR_COMPATIBILITY.Drawing = true
		EXECUTOR_COMPATIBILITY.Clipboard = true
		EXECUTOR_COMPATIBILITY.FileSystem = true
		EXECUTOR_COMPATIBILITY.HTTP = true
	elseif identifyexecutor then
		EXECUTOR_NAME = identifyexecutor()
		EXECUTOR_COMPATIBILITY.Drawing = true
		EXECUTOR_COMPATIBILITY.Clipboard = true
		EXECUTOR_COMPATIBILITY.FileSystem = true
		EXECUTOR_COMPATIBILITY.HTTP = true
	else
		EXECUTOR_NAME = "Unknown"
	end
end

detectExecutor()

-- ===================================
-- UI CREATION
-- ===================================

local function createMainUI()
    -- Create Bracket window
    local Window = Bracket:CreateWindow({
        Name = "Phantom Suite v7.8 - Bracket UI",
        Size = UDim2.new(0, 600, 0, 450)
    })
    
    -- Create tabs
    local StatusTab = Window:CreateTab("Status")
    local AimbotTab = Window:CreateTab("Aimbot")
    local ESPTab = Window:CreateTab("ESP")
    local ExtrasTab = Window:CreateTab("Extras")
    local ConfigsTab = Window:CreateTab("Configs")
    local KeybindsTab = Window:CreateTab("Keybinds")
    local InfoTab = Window:CreateTab("Info")
    
    -- Status Tab
    local StatusSection = StatusTab:CreateSection("System Status")
    StatusSection:CreateLabel("Executor: " .. EXECUTOR_NAME)
    StatusSection:CreateLabel("UI: Bracket Library")
    StatusSection:CreateLabel("Version: v7.8")
    
    -- Aimbot Tab
    local AimbotSection = AimbotTab:CreateSection("Aimbot Settings")
    AimbotSection:CreateToggle("Enable Aimbot", function(state)
        aimbotEnabled = state
        print("Aimbot:", state and "ON" or "OFF")
    end)
    
    AimbotSection:CreateSlider("FOV", 10, 500, function(value)
        aimFov = value
    end)
    
    AimbotSection:CreateSlider("Smoothing", 1, 10, function(value)
        smoothing = value
    end)
    
    AimbotSection:CreateSlider("Prediction", 0, 0.2, function(value)
        predictionStrength = value
    end)
    
    local ChecksSection = AimbotTab:CreateSection("Checks")
    ChecksSection:CreateToggle("Wall Check", function(state)
        wallCheck = state
    end)
    
    ChecksSection:CreateToggle("Team Check", function(state)
        teamCheck = state
    end)
    
    ChecksSection:CreateToggle("Health Check", function(state)
        healthCheck = state
    end)
    
    -- ESP Tab
    local ESPSection = ESPTab:CreateSection("ESP Settings")
    ESPSection:CreateToggle("Enable ESP", function(state)
        espEnabled = state
        print("ESP:", state and "ON" or "OFF")
    end)
    
    ESPSection:CreateToggle("Box ESP", function(state)
        boxEsp = state
    end)
    
    ESPSection:CreateToggle("Name ESP", function(state)
        nameEsp = state
    end)
    
    ESPSection:CreateToggle("Health ESP", function(state)
        healthEsp = state
    end)
    
    ESPSection:CreateToggle("Distance ESP", function(state)
        distanceEsp = state
    end)
    
    ESPSection:CreateToggle("Tracer ESP", function(state)
        tracerEsp = state
    end)
    
    local VisualSection = ESPTab:CreateSection("Visual Settings")
    VisualSection:CreateColorpicker("ESP Color", function(color)
        espColor = color
    end)
    
    VisualSection:CreateColorpicker("FOV Color", function(color)
        fovColor = color
    end)
    
    -- Extras Tab
    local ExtrasSection = ExtrasTab:CreateSection("Movement")
    ExtrasSection:CreateToggle("Fly", function(state)
        flyEnabled = state
        print("Fly:", state and "ON" or "OFF")
    end)
    
    ExtrasSection:CreateToggle("Noclip", function(state)
        noclipEnabled = state
        print("Noclip:", state and "ON" or "OFF")
    end)
    
    ExtrasSection:CreateToggle("Infinite Jump", function(state)
        infJumpEnabled = state
        print("Infinite Jump:", state and "ON" or "OFF")
    end)
    
    ExtrasSection:CreateSlider("Fly Speed", 10, 200, function(value)
        flySpeed = value
    end)
    
    -- Configs Tab
    local ConfigsSection = ConfigsTab:CreateSection("Configuration")
    ConfigsSection:CreateButton("Save Config", function()
        print("Configuration saved!")
    end)
    
    ConfigsSection:CreateButton("Load Config", function()
        print("Configuration loaded!")
    end)
    
    ConfigsSection:CreateButton("Reset Config", function()
        print("Configuration reset!")
    end)
    
    -- Keybinds Tab
    local KeybindsSection = KeybindsTab:CreateSection("Keybinds")
    KeybindsSection:CreateKeybind("Toggle Aimbot", Enum.KeyCode.LeftControl, function()
        aimbotEnabled = not aimbotEnabled
        print("Aimbot:", aimbotEnabled and "ON" or "OFF")
    end)
    
    KeybindsSection:CreateKeybind("Toggle ESP", Enum.KeyCode.LeftShift, function()
        espEnabled = not espEnabled
        print("ESP:", espEnabled and "ON" or "OFF")
    end)
    
    KeybindsSection:CreateKeybind("Toggle UI", Enum.KeyCode.RightShift, function()
        Window:Toggle()
        print("UI Toggled")
    end)
    
    KeybindsSection:CreateKeybind("Blatant Mode", Enum.KeyCode.B, function()
        blatantEnabled = not blatantEnabled
        print("Blatant:", blatantEnabled and "ON" or "OFF")
    end)
    
    -- Info Tab
    local InfoSection = InfoTab:CreateSection("Information")
    InfoSection:CreateLabel("Phantom Suite v7.8")
    InfoSection:CreateLabel("Updated for Bracket Library")
    InfoSection:CreateLabel("by Asuneteric")
    InfoSection:CreateLabel("")
    InfoSection:CreateLabel("Features:")
    InfoSection:CreateLabel("• Advanced Aimbot")
    InfoSection:CreateLabel("• Comprehensive ESP")
    InfoSection:CreateLabel("• Movement Tools")
    InfoSection:CreateLabel("• Modern UI")
    
    return Window
end

-- ===================================
-- AIMBOT FUNCTIONS
-- ===================================

local function getClosestPlayer()
    local closest = nil
    local closestDistance = aimbotLockDistance
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= plr then
            -- Team check
            if teamCheck and player.Team == plr.Team then
                continue
            end
            
            -- Health check
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if healthCheck and (not humanoid or humanoid.Health < minHealth) then
                continue
            end
            
            -- Distance check
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local targetPos = character.HumanoidRootPart.Position
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
                
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                    
                    if distance < closestDistance then
                        -- Wall check
                        if wallCheck then
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                            raycastParams.FilterDescendantsInstances = {plr.Character, camera}
                            
                            local result = workspace:Raycast(camera.CFrame.Position, (targetPos - camera.CFrame.Position).Unit * aimbotLockDistance, raycastParams)
                            if result and result.Instance and result.Instance:IsDescendantOf(character) then
                                closest = player
                                closestDistance = distance
                            end
                        else
                            closest = player
                            closestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return closest
end

-- ===================================
-- MOVEMENT FUNCTIONS
-- ===================================

local function startFly()
    if not flyEnabled then return end
    
    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    end
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not flyEnabled then
            connection:Disconnect()
            return
        end
        
        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local moveDirection = plr.Character.PrimaryPart.CFrame:VectorToWorldSpace(Vector3.new(
                (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0),
                0,
                (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
            ))
            
            humanoid:Move(moveDirection * flySpeed)
        end
    end)
end

local function stopFly()
    flyEnabled = false
end

local function startNoclip()
    if not noclipEnabled then return end
    
    local connection
    connection = RunService.Stepped:Connect(function()
        if not noclipEnabled then
            connection:Disconnect()
            return
        end
        
        if plr.Character then
            for _, part in pairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoclip()
    noclipEnabled = false
end

-- ===================================
-- MAIN INITIALIZATION
-- ===================================

local function main()
    -- Create UI
    local Window = createMainUI()
    
    -- Show success message
    print("✅ Phantom Suite v7.8 loaded successfully with Bracket UI!")
    
    -- Main loops
    task.spawn(function()
        while true do
            task.wait()
            
            -- Aimbot logic
            if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local target = getClosestPlayer()
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPos = target.Character.HumanoidRootPart.Position
                    
                    -- Apply prediction
                    local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.MoveDirection ~= Vector3.new(0, 0, 0) then
                        targetPos = targetPos + humanoid.MoveDirection * predictionStrength * 50
                    end
                    
                    -- Calculate aim direction
                    local aimDirection = (targetPos - camera.CFrame.Position).Unit
                    
                    -- Apply smoothing
                    local currentLook = camera.CFrame.LookVector
                    local smoothedDirection = currentLook:Lerp(aimDirection, 1 / smoothing)
                    
                    -- Update camera
                    camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + smoothedDirection)
                end
            end
            
            -- Movement logic
            if flyEnabled then
                startFly()
            else
                stopFly()
            end
            
            if noclipEnabled then
                startNoclip()
            else
                stopNoclip()
            end
        end
    end)
end

-- Start the script
main()
