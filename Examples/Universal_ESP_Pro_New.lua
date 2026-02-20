--[[
	Universal ESP Pro Enhanced - Professional ESP System
	Redesigned with cleaner code and optimized performance
	
	ESP Types:
	- Box ESP (corner boxes with auto-scaling)
	- Name ESP (distance/health display)
	- Tracer ESP (screen edge tracers)
]]

-- ===================================
-- DEV COPY INTEGRATION (FIRST)
-- ===================================

-- Implement DevCopy functionality directly
print("🔧 Implementing DevCopy functionality directly...")
local success, devCopyLoaded = pcall(function()
    -- Direct implementation of essential DevCopy functionality
    local CoreGui = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")
    
    -- Executor clipboard compatibility
    local function copyToClipboard(text)
        if setclipboard then
            setclipboard(text)
            return true
        elseif toclipboard then
            toclipboard(text)
            return true
        elseif Clipboard and Clipboard.set then
            Clipboard.set(text)
            return true
        else
            warn("[LogCopier] No clipboard function available on this executor.")
            return false
        end
    end
    
    -- Safe instance check
    local function isAlive(instance)
        return instance and instance.Parent ~= nil
    end
    
    -- Get client log
    local function getClientLog()
        local master = CoreGui:FindFirstChild("DevConsoleMaster")
        if not master then return end
        
        -- Find the client log through various paths
        local clientLog
        
        -- Path 1: Standard path
        local window = master:FindFirstChild("DevConsoleWindow")
        if window then
            local ui = window:FindFirstChild("DevConsoleUI")
            if ui then
                local main = ui:FindFirstChild("MainView")
                if main then
                    clientLog = main:FindFirstChild("ClientLog")
                    if clientLog then return clientLog end
                end
            end
        end
        
        -- Path 2: Search all descendants (more reliable)
        for _, descendant in pairs(master:GetDescendants()) do
            if descendant.Name == "ClientLog" then
                return descendant
            end
        end
        
        return nil
    end
    
    -- Hook console
    local function hookConsole()
        local clientLog = getClientLog()
        if not clientLog then
            print("🔧 DevCopy: Waiting for console to load...")
            return
        end
        
        -- Create Copy All button
        if not clientLog:FindFirstChild("CopyAllLogs") then
            local btn = Instance.new("TextButton")
            btn.Name = "CopyAllLogs"
            btn.Size = UDim2.new(0, 120, 0, 22)
            btn.Position = UDim2.new(1, -130, 0, 6)
            btn.BackgroundTransparency = 0.2
            btn.Text = "Copy All"
            btn.Parent = clientLog
            
            btn.MouseButton1Click:Connect(function()
                local buffer = {}
                
                for _, obj in ipairs(clientLog:GetDescendants()) do
                    if obj:IsA("TextLabel") and obj.Text and obj.Text ~= "" then
                        table.insert(buffer, obj.Text)
                    end
                end
                
                if copyToClipboard(table.concat(buffer, "\n")) then
                    btn.Text = "Copied"
                    task.delay(0.6, function()
                        if isAlive(btn) then btn.Text = "Copy All" end
                    end)
                end
            end)
            
            print("🔧 DevCopy: Copy All button created")
        end
    end
    
    -- Initial run + periodic check
    hookConsole()
    
    -- Set up periodic check
    local elapsed = 0
    RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        if elapsed > 1 then
            elapsed = 0
            hookConsole()
        end
    end)
    
    return true
end)

if success and devCopyLoaded then
    print("📋 DevCopy functionality integrated successfully!")
else
    print("⚠️ DevCopy integration failed!")
    if not success then
        print("❌ HTTP request or loadstring failed:", devCopyLoaded)
    else
        print("❌ DevCopy execution returned:", devCopyLoaded)
    end
    print("🔧 Continuing without DevCopy...")
end

-- ===================================
-- BRACKET LIBRARY INTEGRATION
-- ===================================

-- Load Bracket library for UI
print("🎨 Attempting to load Bracket library...")
local bracketSuccess, Bracket = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/refs/heads/main/Library%20Repos/BracketLib"))()
end)

if bracketSuccess and Bracket then
    print("✅ Bracket library loaded successfully!")
else
    print("⚠️ Bracket library integration failed!")
    if not bracketSuccess then
        print("❌ HTTP request or loadstring failed:", Bracket)
    else
        print("❌ Bracket execution returned:", Bracket)
    end
    print("🔧 Continuing without UI...")
end

print("🚀 Loading Universal ESP Pro...")

-- ===================================
-- SERVICES AND VARIABLES
-- ===================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Performance tracking
local FrameCount = 0
local LastTime = tick()
local FPS = 60
local localTick = tick -- Local tick for rainbow effects

-- ===================================
-- ESP CONFIGURATION
-- ===================================

local ESPConfig = {
    Enabled = true,
    TeamCheck = false,
    MaxDistance = 1000,
    
    -- Performance Settings
    Performance = {
        MaxFPS = 60,
        UpdateInterval = 1,
        BatchRendering = true,
        DistanceCulling = true,
        OcclusionCulling = true
    },
    
    -- Box ESP Settings
    Box = {
        Enabled = true,
        Color = Color3.fromRGB(255, 0, 0),
        Thickness = 2,
        CornerLength = 8,
        AutoScale = true,
        Rainbow = false
    },
    
    -- Name ESP Settings
    Name = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        Size = 15,
        AutoScale = true,
        ShowDistance = true,
        ShowHealth = true
    },
    
    -- Tracer ESP Settings
    Tracer = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        AutoThickness = true,
        Origin = "Bottom", -- "Bottom", "Top", "Mouse"
        Rainbow = false
    },
    
    -- Visual Effects
    Effects = {
        Rainbow = false,
        RainbowSpeed = 1
    },
    
    -- Distance Scaling
    Distance = {
        Enabled = true,
        FadeDistance = 1500,
        ScaleFactor = 0.6,
        MinScale = 0.2,
        MaxScale = 1.2
    }
}

-- ===================================
-- ESP OBJECTS STORAGE
-- ===================================

local ESPObjects = {}
local Connections = {}

-- ===================================
-- UTILITY FUNCTIONS
-- ===================================

local function isDrawingAvailable()
    local success, drawing = pcall(function()
        return Drawing
    end)
    return success and drawing
end

local function worldToScreen(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

local function getDistance(part1, part2)
    return (part1.Position - part2.Position).Magnitude
end

local function getPlayerColor(player)
    if ESPConfig.TeamCheck and player.Team and LocalPlayer.Team then
        if player.TeamColor == LocalPlayer.TeamColor then
            return Color3.fromRGB(0, 255, 0) -- Green for same team
        else
            return Color3.fromRGB(255, 0, 0) -- Red for enemy team
        end
    end
    return ESPConfig.Box.Color
end

local function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function getRainbowColor(time, speed)
    local hue = (time * speed) % 1
    return Color3.fromHSV(hue, 1, 1)
end

local function getDistanceScale(distance)
    if not ESPConfig.Distance.Enabled then return 1 end
    
    local scale = 1 - (distance / ESPConfig.Distance.FadeDistance) * ESPConfig.Distance.ScaleFactor
    return clamp(scale, ESPConfig.Distance.MinScale, ESPConfig.Distance.MaxScale)
end

local function getFPS()
    FrameCount = FrameCount + 1
    local currentTime = tick()
    if currentTime - LastTime >= 1 then
        FPS = FrameCount
        FrameCount = 0
        LastTime = currentTime
    end
    return FPS
end

local function shouldUpdate()
    if not ESPConfig.Performance.BatchRendering then return true end
    
    local currentFPS = getFPS()
    if currentFPS < ESPConfig.Performance.MaxFPS then
        return FrameCount % ESPConfig.Performance.UpdateInterval == 0
    end
    return true
end

local function isOccluded(character)
    if not ESPConfig.Performance.OcclusionCulling then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (rootPart.Position - origin).Unit
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = Workspace:Raycast(origin, direction * getDistance(rootPart, LocalPlayer.Character.HumanoidRootPart), raycastParams)
    return result and result.Instance ~= rootPart
end

-- ===================================
-- DRAWING CREATION FUNCTIONS
-- ===================================

local function createDrawing(type, properties)
    local drawing = Drawing.new(type)
    for prop, value in pairs(properties) do
        -- Safely set properties, skip unsupported ones
        local success, error = pcall(function()
            drawing[prop] = value
        end)
        if not success then
            -- Silently skip unsupported properties like AntiAliasing
            -- This ensures compatibility across different Drawing API implementations
        end
    end
    return drawing
end

-- ===================================
-- ESP CREATION FUNCTIONS
-- ===================================

-- Create Box ESP for a player
local function createBoxESP(player)
    local boxESP = {
        TL1 = createDrawing("Line", {
            Visible = false,
            Color = ESPConfig.Box.Color,
            Thickness = ESPConfig.Box.Thickness,
            Transparency = 1
        }),
        TL2 = createDrawing("Line", {
            Visible = false,
            Color = ESPConfig.Box.Color,
            Thickness = ESPConfig.Box.Thickness,
            Transparency = 1
        }),
        TR1 = createDrawing("Line", {
            Visible = false,
            Color = ESPConfig.Box.Color,
            Thickness = ESPConfig.Box.Thickness,
            Transparency = 1
        }),
        TR2 = createDrawing("Line", {
            Visible = false,
            Color = ESPConfig.Box.Color,
            Thickness = ESPConfig.Box.Thickness,
            Transparency = 1
        }),
        BL1 = createDrawing("Line", {
            Visible = false,
            Color = ESPConfig.Box.Color,
            Thickness = ESPConfig.Box.Thickness,
            Transparency = 1
        }),
        BL2 = createDrawing("Line", {
            Visible = false,
            Color = ESPConfig.Box.Color,
            Thickness = ESPConfig.Box.Thickness,
            Transparency = 1
        }),
        BR1 = createDrawing("Line", {
            Visible = false,
            Color = ESPConfig.Box.Color,
            Thickness = ESPConfig.Box.Thickness,
            Transparency = 1
        }),
        BR2 = createDrawing("Line", {
            Visible = false,
            Color = ESPConfig.Box.Color,
            Thickness = ESPConfig.Box.Thickness,
            Transparency = 1
        })
    }
    
    return boxESP
end

-- Create Name ESP for a player
local function createNameESP(player)
    local nameESP = createDrawing("Text", {
        Visible = false,
        Text = player.Name,
        Size = ESPConfig.Name.Size,
        Center = true,
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Color = ESPConfig.Name.Color,
        Transparency = 1
    })
    
    return nameESP
end

-- Create Tracer ESP for a player
local function createTracerESP(player)
    local tracerESP = createDrawing("Line", {
        Visible = false,
        From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y),
        To = Vector2.new(0, 0),
        Color = ESPConfig.Tracer.Color,
        Thickness = ESPConfig.Tracer.Thickness,
        Transparency = 1
    })
    
    return tracerESP
end

-- ===================================
-- ESP UPDATE FUNCTIONS
-- ===================================

-- Update Box ESP for a player
local function updateBoxESP(player, box)
    if not player or not player.Character or not box then return end
    
    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    
    if not humanoid or not rootPart or not head or humanoid.Health <= 0 then
        for _, line in pairs(box) do
            line.Visible = false
        end
        return
    end
    
    -- Distance and occlusion culling
    local distance = getDistance(rootPart, LocalPlayer.Character.HumanoidRootPart)
    local isVisible = true
    
    if ESPConfig.Performance.DistanceCulling and distance > ESPConfig.MaxDistance then
        isVisible = false
    end
    
    if isVisible and ESPConfig.Performance.OcclusionCulling then
        isVisible = not isOccluded(character)
    end
    
    if not isVisible then
        for _, line in pairs(box) do
            line.Visible = false
        end
        return
    end
    
    -- Create orientation part for accurate box calculation
    local oripart = Instance.new("Part")
    oripart.Size = Vector3.new(rootPart.Size.X, rootPart.Size.Y * 1.5, rootPart.Size.Z)
    oripart.CFrame = CFrame.new(rootPart.CFrame.Position, Camera.CFrame.Position)
    oripart.Transparency = 1
    oripart.Parent = nil -- Don't add to workspace
    
    -- Calculate corner points
    local SizeX = oripart.Size.X / 2
    local SizeY = oripart.Size.Y / 2
    local TL = Camera:WorldToViewportPoint((oripart.CFrame * CFrame.new(SizeX, SizeY, 0)).p)
    local TR = Camera:WorldToViewportPoint((oripart.CFrame * CFrame.new(-SizeX, SizeY, 0)).p)
    local BL = Camera:WorldToViewportPoint((oripart.CFrame * CFrame.new(SizeX, -SizeY, 0)).p)
    local BR = Camera:WorldToViewportPoint((oripart.CFrame * CFrame.new(-SizeX, -SizeY, 0)).p)
    
    -- Apply color (team check or rainbow)
    local color = getPlayerColor(player)
    if ESPConfig.Box.Rainbow or ESPConfig.Effects.Rainbow then
        color = getRainbowColor(localTick(), ESPConfig.Effects.RainbowSpeed)
    end
    
    -- Ensure color is always a valid Color3
    if type(color) ~= "userdata" then
        color = Color3.fromRGB(255, 255, 255) -- Default to white if invalid
    end
    
    -- Calculate corner length based on distance
    local ratio = (Camera.CFrame.p - rootPart.Position).magnitude
    local offset = math.clamp(1/ratio*750, 2, 300)
    
    -- Calculate thickness based on distance
    local thickness = ESPConfig.Box.Thickness
    if ESPConfig.Box.AutoScale then
        thickness = math.clamp(1/distance*100, 1, 4)
    end
    
    -- Update all box lines
    -- Top Left Corner
    box.TL1.From = Vector2.new(TL.X, TL.Y)
    box.TL1.To = Vector2.new(TL.X + offset, TL.Y)
    box.TL1.Color = color
    box.TL1.Thickness = thickness
    box.TL1.Visible = true
    
    box.TL2.From = Vector2.new(TL.X, TL.Y)
    box.TL2.To = Vector2.new(TL.X, TL.Y + offset)
    box.TL2.Color = color
    box.TL2.Thickness = thickness
    box.TL2.Visible = true
    
    -- Top Right Corner
    box.TR1.From = Vector2.new(TR.X, TR.Y)
    box.TR1.To = Vector2.new(TR.X - offset, TR.Y)
    box.TR1.Color = color
    box.TR1.Thickness = thickness
    box.TR1.Visible = true
    
    box.TR2.From = Vector2.new(TR.X, TR.Y)
    box.TR2.To = Vector2.new(TR.X, TR.Y + offset)
    box.TR2.Color = color
    box.TR2.Thickness = thickness
    box.TR2.Visible = true
    
    -- Bottom Left Corner
    box.BL1.From = Vector2.new(BL.X, BL.Y)
    box.BL1.To = Vector2.new(BL.X + offset, BL.Y)
    box.BL1.Color = color
    box.BL1.Thickness = thickness
    box.BL1.Visible = true
    
    box.BL2.From = Vector2.new(BL.X, BL.Y)
    box.BL2.To = Vector2.new(BL.X, BL.Y - offset)
    box.BL2.Color = color
    box.BL2.Thickness = thickness
    box.BL2.Visible = true
    
    -- Bottom Right Corner
    box.BR1.From = Vector2.new(BR.X, BR.Y)
    box.BR1.To = Vector2.new(BR.X - offset, BR.Y)
    box.BR1.Color = color
    box.BR1.Thickness = thickness
    box.BR1.Visible = true
    
    box.BR2.From = Vector2.new(BR.X, BR.Y)
    box.BR2.To = Vector2.new(BR.X, BR.Y - offset)
    box.BR2.Color = color
    box.BR2.Thickness = thickness
    box.BR2.Visible = true
end

-- Update Name ESP for a player
local function updateNameESP(player, nameText)
    if not player or not player.Character or not nameText then return end
    
    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    
    if not humanoid or not rootPart or not head or humanoid.Health <= 0 then
        nameText.Visible = false
        return
    end
    
    -- Distance and occlusion culling
    local distance = getDistance(rootPart, LocalPlayer.Character.HumanoidRootPart)
    local isVisible = true
    
    if ESPConfig.Performance.DistanceCulling and distance > ESPConfig.MaxDistance then
        isVisible = false
    end
    
    if isVisible and ESPConfig.Performance.OcclusionCulling then
        isVisible = not isOccluded(character)
    end
    
    if not isVisible then
        nameText.Visible = false
        return
    end
    
    -- Get head position in 2D
    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
    
    if not onScreen then
        nameText.Visible = false
        return
    end
    
    -- Construct name text with optional distance and health
    local displayText = player.Name
    
    if ESPConfig.Name.ShowDistance then
        displayText = displayText .. string.format(" [%d]m", math.floor(distance))
    end
    
    if ESPConfig.Name.ShowHealth then
        displayText = displayText .. string.format(" [%d%%]", math.floor(humanoid.Health / humanoid.MaxHealth * 100))
    end
    
    -- Apply color (team check or rainbow)
    local color = ESPConfig.Name.Color
    if ESPConfig.Effects.Rainbow then
        color = getRainbowColor(localTick(), ESPConfig.Effects.RainbowSpeed)
    end
    
    -- Ensure color is always a valid Color3
    if type(color) ~= "userdata" then
        color = Color3.fromRGB(255, 255, 255) -- Default to white if invalid
    end
    
    -- Calculate text size based on distance
    local textSize = ESPConfig.Name.Size
    if ESPConfig.Name.AutoScale then
        textSize = math.clamp(1/distance*1000, 2, 30) -- Min 2, max 30
    end
    
    -- Update name text properties
    nameText.Text = displayText
    nameText.Position = Vector2.new(headPos.X, headPos.Y - 15) -- Position above head
    nameText.Color = color
    nameText.Size = textSize
    nameText.Visible = true
end

-- Update Tracer ESP for a player
local function updateTracerESP(player, tracer)
    if not player or not player.Character or not tracer then return end
    
    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    
    if not humanoid or not rootPart or not head or humanoid.Health <= 0 then
        tracer.Visible = false
        return
    end
    
    -- Distance and occlusion culling
    local distance = getDistance(rootPart, LocalPlayer.Character.HumanoidRootPart)
    local isVisible = true
    
    if ESPConfig.Performance.DistanceCulling and distance > ESPConfig.MaxDistance then
        isVisible = false
    end
    
    if isVisible and ESPConfig.Performance.OcclusionCulling then
        isVisible = not isOccluded(character)
    end
    
    if not isVisible then
        tracer.Visible = false
        return
    end
    
    -- Get head position in 2D
    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
    
    if not onScreen then
        tracer.Visible = false
        return
    end
    
    -- Apply color (team check or rainbow)
    local color = ESPConfig.Tracer.Color
    if ESPConfig.Tracer.Rainbow or ESPConfig.Effects.Rainbow then
        color = getRainbowColor(localTick(), ESPConfig.Effects.RainbowSpeed)
    end
    
    -- Ensure color is always a valid Color3
    if type(color) ~= "userdata" then
        color = Color3.fromRGB(255, 255, 255) -- Default to white if invalid
    end
    
    -- Calculate tracer origin position
    local fromPos
    if ESPConfig.Tracer.Origin == "Bottom" then
        fromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    elseif ESPConfig.Tracer.Origin == "Top" then
        fromPos = Vector2.new(Camera.ViewportSize.X / 2, 0)
    elseif ESPConfig.Tracer.Origin == "Mouse" then
        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
        fromPos = Vector2.new(mousePos.X, mousePos.Y)
    else
        fromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    end
    
    -- Calculate thickness based on distance
    local thickness = ESPConfig.Tracer.Thickness
    if ESPConfig.Tracer.AutoThickness then
        thickness = math.clamp(1/distance*100, 0.1, 3) -- Min 0.1, max 3
    end
    
    -- Update tracer properties
    tracer.From = fromPos
    tracer.To = Vector2.new(headPos.X, headPos.Y)
    tracer.Color = color
    tracer.Thickness = thickness
    tracer.Visible = true
end

-- ===================================
-- ESP PLAYER SETUP AND UPDATE
-- ===================================

-- Initialize ESP for a player
local function setupPlayerESP(player)
    if player == LocalPlayer then return end
    
    -- Create ESP objects for the player
    ESPObjects[player] = {
        box = ESPConfig.Box.Enabled and createBoxESP(player) or nil,
        name = ESPConfig.Name.Enabled and createNameESP(player) or nil,
        tracer = ESPConfig.Tracer.Enabled and createTracerESP(player) or nil
    }
    
    -- Create update function for this player
    local function updateESP()
        if not ESPConfig.Enabled then
            for _, espType in pairs(ESPObjects[player]) do
                if type(espType) == "table" then
                    for _, obj in pairs(espType) do
                        obj.Visible = false
                    end
                elseif espType then
                    espType.Visible = false
                end
            end
            return
        end
        
        if not player or not player.Character or not player.Character:FindFirstChild("Humanoid") then
            return
        end
        
        if not shouldUpdate() then return end
        
        -- Update each ESP type
        if ESPConfig.Box.Enabled and ESPObjects[player].box then
            updateBoxESP(player, ESPObjects[player].box)
        end
        
        if ESPConfig.Name.Enabled and ESPObjects[player].name then
            updateNameESP(player, ESPObjects[player].name)
        end
        
        if ESPConfig.Tracer.Enabled and ESPObjects[player].tracer then
            updateTracerESP(player, ESPObjects[player].tracer)
        end
    end
    
    -- Connect update function to RenderStepped
    Connections[player] = {
        update = RunService.RenderStepped:Connect(updateESP)
    }
    
    -- Initial update
    updateESP()
    
    return ESPObjects[player]
end

-- ===================================
-- ESP CLEANUP FUNCTION
-- ===================================

local function cleanupPlayerESP(player)
    if ESPObjects[player] then
        for _, espType in pairs(ESPObjects[player]) do
            if type(espType) == "table" then
                for _, obj in pairs(espType) do
                    pcall(function()
                        obj:Remove()
                    end)
                end
            elseif espType then
                pcall(function()
                    espType:Remove()
                end)
            end
        end
        ESPObjects[player] = nil
    end
    
    if Connections[player] then
        for _, connection in pairs(Connections[player]) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        Connections[player] = nil
    end
end

-- ===================================
-- MAIN ESP INITIALIZATION
-- ===================================

-- Initialize ESP system
local function initializeESP()
    -- Check if Drawing API is available
    if not isDrawingAvailable() then
        print("❌ Drawing API not available! ESP cannot function.")
        return false
    end
    
    print("✅ Universal ESP Pro initialized successfully!")
    
    -- Setup ESP for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            setupPlayerESP(player)
        end
    end
    
    -- Connect player added/removed events
    Players.PlayerAdded:Connect(function(player)
        setupPlayerESP(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        cleanupPlayerESP(player)
    end)
    
    return true
end

-- ===================================
-- PERFORMANCE MONITORING
-- ===================================

-- Get performance statistics
local function getPerformanceStats()
    local stats = {}
    stats.FPS = FPS
    stats.Players = #Players:GetPlayers()
    stats.Memory = (gcinfo or collectgarbage)("count") / 1024 -- Convert from KB to MB
    return stats
end

-- ===================================
-- PUBLIC API
-- ===================================

-- Create global API
local function createAPI()
    local api = {}
    
    -- ESP toggle functions
    api.toggleESP = function(state)
        ESPConfig.Enabled = state ~= nil and state or not ESPConfig.Enabled
        return ESPConfig.Enabled
    end
    
    api.toggleBoxESP = function(state)
        ESPConfig.Box.Enabled = state ~= nil and state or not ESPConfig.Box.Enabled
        return ESPConfig.Box.Enabled
    end
    
    api.toggleNameESP = function(state)
        ESPConfig.Name.Enabled = state ~= nil and state or not ESPConfig.Name.Enabled
        return ESPConfig.Name.Enabled
    end
    
    api.toggleTracerESP = function(state)
        ESPConfig.Tracer.Enabled = state ~= nil and state or not ESPConfig.Tracer.Enabled
        return ESPConfig.Tracer.Enabled
    end
    
    api.toggleTeamCheck = function(state)
        ESPConfig.TeamCheck = state ~= nil and state or not ESPConfig.TeamCheck
        return ESPConfig.TeamCheck
    end
    
    api.toggleRainbow = function(state)
        ESPConfig.Effects.Rainbow = state ~= nil and state or not ESPConfig.Effects.Rainbow
        return ESPConfig.Effects.Rainbow
    end
    
    -- Performance functions
    api.getPerformanceStats = getPerformanceStats
    
    -- Configuration functions
    api.setMaxDistance = function(distance)
        ESPConfig.MaxDistance = distance
        return ESPConfig.MaxDistance
    end
    
    api.setBoxColor = function(color)
        ESPConfig.Box.Color = color
        return ESPConfig.Box.Color
    end
    
    api.setNameColor = function(color)
        ESPConfig.Name.Color = color
        return ESPConfig.Name.Color
    end
    
    api.setTracerColor = function(color)
        ESPConfig.Tracer.Color = color
        return ESPConfig.Tracer.Color
    end
    
    api.setTracerOrigin = function(origin)
        ESPConfig.Tracer.Origin = origin
        return ESPConfig.Tracer.Origin
    end
    
    api.setRainbowSpeed = function(speed)
        ESPConfig.Effects.RainbowSpeed = speed
        return ESPConfig.Effects.RainbowSpeed
    end
    
    -- Cleanup function
    api.unload = function()
        for _, player in pairs(Players:GetPlayers()) do
            cleanupPlayerESP(player)
        end
        print("🧹 Universal ESP Pro unloaded successfully!")
    end
    
    return api
end

-- ===================================
-- BRACKET UI INTEGRATION
-- ===================================

-- Initialize ESP
local espInitialized = initializeESP()

-- Export API to global environment
if espInitialized then
    if getgenv then
        getgenv().UniversalESP = createAPI()
        print("🏁 Universal ESP Pro functions exported to getgenv().UniversalESP")
    else
        _G.UniversalESP = createAPI()
        print("🏁 Universal ESP Pro functions exported to _G.UniversalESP")
    end
end

-- Create Bracket UI if available
if bracketSuccess and Bracket then
    -- Create notification system
    local Notify = Bracket:Notification({
        Title = "Universal ESP Pro",
        Description = "ESP system loaded successfully!",
        Duration = 5
    })
    
    -- Create main window
    local Window = Bracket:Window({
        Title = "Universal ESP Pro",
        Position = UDim2.new(0.05, 0, 0.5, 0),
        Size = UDim2.new(0, 550, 0, 450),
        Transparency = 0.8
    })
    
    -- Create tabs
    local ESPTab = Window:Tab({ Title = "ESP" })
    local VisualsTab = Window:Tab({ Title = "Visuals" })
    local PerformanceTab = Window:Tab({ Title = "Performance" })
    local SettingsTab = Window:Tab({ Title = "Settings" })
    
    -- ESP Tab
    ESPTab:Toggle({
        Title = "Enable ESP",
        Description = "Toggle all ESP features",
        Default = ESPConfig.Enabled,
        Callback = function(state)
            ESPConfig.Enabled = state
        end
    })
    
    ESPTab:Toggle({
        Title = "Team Check",
        Description = "Use team colors for ESP",
        Default = ESPConfig.TeamCheck,
        Callback = function(state)
            ESPConfig.TeamCheck = state
        end
    })
    
    ESPTab:Slider({
        Title = "Max Distance",
        Description = "Maximum distance for ESP visibility",
        Default = ESPConfig.MaxDistance,
        Min = 100,
        Max = 5000,
        Callback = function(value)
            ESPConfig.MaxDistance = value
        end
    })
    
    ESPTab:Divider({ Text = "ESP Types", Side = "Left" })
    
    ESPTab:Toggle({
        Title = "Box ESP",
        Description = "Show corner boxes around players",
        Default = ESPConfig.Box.Enabled,
        Side = "Left",
        Callback = function(state)
            ESPConfig.Box.Enabled = state
        end
    })
    
    ESPTab:Toggle({
        Title = "Name ESP",
        Description = "Show player names, distance and health",
        Default = ESPConfig.Name.Enabled,
        Side = "Left",
        Callback = function(state)
            ESPConfig.Name.Enabled = state
        end
    })
    
    ESPTab:Toggle({
        Title = "Tracer ESP",
        Description = "Show lines pointing to players",
        Default = ESPConfig.Tracer.Enabled,
        Side = "Left",
        Callback = function(state)
            ESPConfig.Tracer.Enabled = state
        end
    })
    
    ESPTab:Dropdown({
        Title = "Tracer Origin",
        Description = "Where tracers start from",
        Default = ESPConfig.Tracer.Origin,
        Side = "Left",
        List = {"Bottom", "Top", "Mouse"},
        Callback = function(option)
            ESPConfig.Tracer.Origin = option
        end
    })
    
    -- Visuals Tab
    VisualsTab:Divider({ Text = "Colors", Side = "Left" })
    
    VisualsTab:ColorPicker({
        Title = "Box Color",
        Description = "Color for box ESP",
        Default = ESPConfig.Box.Color,
        Side = "Left",
        Callback = function(color)
            ESPConfig.Box.Color = color
        end
    })
    
    VisualsTab:ColorPicker({
        Title = "Name Color",
        Description = "Color for name ESP",
        Default = ESPConfig.Name.Color,
        Side = "Left",
        Callback = function(color)
            ESPConfig.Name.Color = color
        end
    })
    
    VisualsTab:ColorPicker({
        Title = "Tracer Color",
        Description = "Color for tracer ESP",
        Default = ESPConfig.Tracer.Color,
        Side = "Left",
        Callback = function(color)
            ESPConfig.Tracer.Color = color
        end
    })
    
    VisualsTab:Divider({ Text = "Effects", Side = "Right" })
    
    VisualsTab:Toggle({
        Title = "Rainbow Effect",
        Description = "Apply rainbow color effect to ESP",
        Default = ESPConfig.Effects.Rainbow,
        Side = "Right",
        Callback = function(state)
            ESPConfig.Effects.Rainbow = state
        end
    })
    
    VisualsTab:Slider({
        Title = "Rainbow Speed",
        Description = "Speed of rainbow color cycling",
        Default = ESPConfig.Effects.RainbowSpeed,
        Min = 0.1,
        Max = 5,
        Decimals = 1,
        Side = "Right",
        Callback = function(value)
            ESPConfig.Effects.RainbowSpeed = value
        end
    })
    
    VisualsTab:Toggle({
        Title = "Box Rainbow",
        Description = "Apply rainbow effect to boxes",
        Default = ESPConfig.Box.Rainbow,
        Side = "Right",
        Callback = function(state)
            ESPConfig.Box.Rainbow = state
        end
    })
    
    VisualsTab:Toggle({
        Title = "Tracer Rainbow",
        Description = "Apply rainbow effect to tracers",
        Default = ESPConfig.Tracer.Rainbow,
        Side = "Right",
        Callback = function(state)
            ESPConfig.Tracer.Rainbow = state
        end
    })
    
    -- Performance Tab
    PerformanceTab:Divider({ Text = "Performance Information", Side = "Left" })
    
    -- Static performance information instead of dynamic updates
    PerformanceTab:Label({ Text = "🎯 Press F9 to toggle UI visibility", Side = "Left" })
    PerformanceTab:Label({ Text = "📊 Check console (F9) for performance stats", Side = "Left" })
    PerformanceTab:Label({ Text = "💾 Use getgenv().UniversalESP.getPerformanceStats() for stats", Side = "Left" })
    
    -- Print stats to console periodically
    task.spawn(function()
        while true do
            task.wait(5) -- Update every 5 seconds to reduce spam
            
            -- Get updated stats
            local stats = getPerformanceStats()
            print("📊 Performance: FPS: " .. stats.FPS .. ", Players: " .. stats.Players .. ", Memory: " .. math.floor(stats.Memory) .. " MB")
        end
    end)
    
    PerformanceTab:Slider({
        Title = "Max FPS",
        Description = "Maximum FPS for ESP updates",
        Default = ESPConfig.Performance.MaxFPS,
        Min = 15,
        Max = 240,
        Side = "Left",
        Callback = function(value)
            ESPConfig.Performance.MaxFPS = value
        end
    })
    
    PerformanceTab:Slider({
        Title = "Update Interval",
        Description = "Frames between ESP updates when FPS is low",
        Default = ESPConfig.Performance.UpdateInterval,
        Min = 1,
        Max = 10,
        Side = "Left",
        Callback = function(value)
            ESPConfig.Performance.UpdateInterval = value
        end
    })
    
    PerformanceTab:Divider({ Text = "Optimizations", Side = "Right" })
    
    PerformanceTab:Toggle({
        Title = "Batch Rendering",
        Description = "Optimize ESP updates based on FPS",
        Default = ESPConfig.Performance.BatchRendering,
        Side = "Right",
        Callback = function(state)
            ESPConfig.Performance.BatchRendering = state
        end
    })
    
    PerformanceTab:Toggle({
        Title = "Distance Culling",
        Description = "Hide ESP for far away players",
        Default = ESPConfig.Performance.DistanceCulling,
        Side = "Right",
        Callback = function(state)
            ESPConfig.Performance.DistanceCulling = state
        end
    })
    
    PerformanceTab:Toggle({
        Title = "Occlusion Culling",
        Description = "Hide ESP for players behind walls",
        Default = ESPConfig.Performance.OcclusionCulling,
        Side = "Right",
        Callback = function(state)
            ESPConfig.Performance.OcclusionCulling = state
        end
    })
    
    -- Settings Tab
    SettingsTab:Divider({ Text = "Settings", Side = "Left" })
    
    SettingsTab:Button({
        Title = "Reset Settings",
        Description = "Reset all ESP settings to default",
        Side = "Left",
        Callback = function()
            ESPConfig = {
                Enabled = true,
                TeamCheck = false,
                MaxDistance = 1000,
                
                Performance = {
                    MaxFPS = 60,
                    UpdateInterval = 1,
                    BatchRendering = true,
                    DistanceCulling = true,
                    OcclusionCulling = true
                },
                
                Box = {
                    Enabled = true,
                    Color = Color3.fromRGB(255, 0, 0),
                    Thickness = 2,
                    CornerLength = 8,
                    AutoScale = true,
                    Rainbow = false
                },
                
                Name = {
                    Enabled = true,
                    Color = Color3.fromRGB(255, 255, 255),
                    Size = 15,
                    AutoScale = true,
                    ShowDistance = true,
                    ShowHealth = true
                },
                
                Tracer = {
                    Enabled = true,
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 1,
                    AutoThickness = true,
                    Origin = "Bottom",
                    Rainbow = false
                },
                
                Effects = {
                    Rainbow = false,
                    RainbowSpeed = 1
                },
                
                Distance = {
                    Enabled = true,
                    FadeDistance = 1500,
                    ScaleFactor = 0.6,
                    MinScale = 0.2,
                    MaxScale = 1.2
                }
            }
            
            Notify:Update({
                Title = "Settings Reset",
                Description = "All ESP settings have been reset to default"
            })
        end
    })
    
    -- DevCopy buttons
    SettingsTab:Divider({ Text = "DevCopy Tools", Side = "Right" })
    
    SettingsTab:Button({
        Title = "Copy Console Log",
        Description = "Copy developer console logs to clipboard",
        Side = "Right",
        Callback = function()
            -- Try to refresh DevCopy
            local refreshSuccess, refreshResult = pcall(function()
                -- Attempt to reload DevCopy to refresh console content
                local response = game:HttpGet("https://raw.githubusercontent.com/ScriptB/Universal-Scripts/refs/heads/main/Useful/DevCopy")
                return loadstring(response)()
            end)
            
            if refreshSuccess then
                Notify:Update({
                    Title = "DevCopy",
                    Description = "Console logs copied to clipboard!"
                })
            else
                Notify:Update({
                    Title = "DevCopy Error",
                    Description = "Failed to copy console logs: " .. tostring(refreshResult)
                })
            end
        end
    })
    
    SettingsTab:Button({
        Title = "Copy Script Loadstring",
        Description = "Copy loadstring for this ESP script",
        Side = "Right",
        Callback = function()
            local loadstringText = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptB/Universal-Scripts/refs/heads/main/Examples/Universal_ESP_Pro_New.lua"))()'            
            
            local copySuccess = pcall(function()
                if setclipboard then
                    setclipboard(loadstringText)
                elseif toclipboard then
                    toclipboard(loadstringText)
                elseif Clipboard and Clipboard.set then
                    Clipboard.set(loadstringText)
                else
                    error("No clipboard function found")
                end
            end)
            
            if copySuccess then
                Notify:Update({
                    Title = "Loadstring Copied",
                    Description = "ESP script loadstring copied to clipboard!"
                })
            else
                Notify:Update({
                    Title = "Copy Error",
                    Description = "Failed to copy loadstring to clipboard"
                })
            end
        end
    })
    
    SettingsTab:Button({
        Title = "Copy Script URL",
        Description = "Copy direct GitHub URL for this script",
        Side = "Right",
        Callback = function()
            local scriptUrl = "https://raw.githubusercontent.com/ScriptB/Universal-Scripts/refs/heads/main/Examples/Universal_ESP_Pro_New.lua"
            
            local copySuccess = pcall(function()
                if setclipboard then
                    setclipboard(scriptUrl)
                elseif toclipboard then
                    toclipboard(scriptUrl)
                elseif Clipboard and Clipboard.set then
                    Clipboard.set(scriptUrl)
                else
                    error("No clipboard function found")
                end
            end)
            
            if copySuccess then
                Notify:Update({
                    Title = "URL Copied",
                    Description = "Script URL copied to clipboard!"
                })
            else
                Notify:Update({
                    Title = "Copy Error",
                    Description = "Failed to copy URL to clipboard"
                })
            end
        end
    })
    
    SettingsTab:Button({
        Title = "Destroy UI (Stealth)",
        Description = "Hide UI but keep ESP running",
        Side = "Left",
        Callback = function()
            Window:Destroy()
            Notify:Update({
                Title = "UI Destroyed",
                Description = "UI has been hidden, ESP still running"
            })
        end
    })
    
    SettingsTab:Button({
        Title = "Unload ESP",
        Description = "Completely unload ESP and UI",
        Side = "Left",
        Callback = function()
            -- Clean up all ESP objects
            for _, player in pairs(Players:GetPlayers()) do
                cleanupPlayerESP(player)
            end
            
            -- Destroy UI
            Window:Destroy()
            
            Notify:Update({
                Title = "ESP Unloaded",
                Description = "Universal ESP Pro has been unloaded"
            })
        end
    })
    
    -- UI Keybinds
    local function toggleUI()
        Window.Enabled = not Window.Enabled
    end
    
    -- F9 to toggle UI
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode.F9 then
                toggleUI()
            elseif input.KeyCode == Enum.KeyCode.Delete then
                Window.Enabled = false
            end
        end
    end)
    
    -- Final notifications
    print("✅ Universal ESP Pro UI loaded successfully!")
    print("⌨️ Press F9 to toggle UI")
else
    print("⚠️ Bracket UI not available, running in headless mode")
end
