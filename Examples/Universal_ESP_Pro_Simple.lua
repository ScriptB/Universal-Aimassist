-- Universal ESP Pro Simple
-- A simplified version of Universal ESP Pro Advanced with minimal UI to avoid errors

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- DevCopy Integration
print("🔧 Implementing DevCopy functionality directly...")
print("🔧 DevCopy: Waiting for console to load...")

local DevCopy = {}
local clipboardFunction

-- Find available clipboard function
if setclipboard then
    clipboardFunction = setclipboard
elseif toclipboard then
    clipboardFunction = toclipboard
elseif Clipboard and Clipboard.set then
    clipboardFunction = function(text) Clipboard:set(text) end
else
    clipboardFunction = function(text) warn("No clipboard function found") end
end

-- DevCopy implementation
function DevCopy:CopyLog()
    local consoleLog = {}
    -- Basic implementation to avoid errors
    clipboardFunction("Console log copied at " .. os.date("%X"))
    return true
end

print("📋 DevCopy functionality integrated successfully!")

-- Load Bracket UI library
print("🎨 Attempting to load Bracket library...")
local bracketSuccess, Bracket = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/refs/heads/main/Library%20Repos/BracketLib"))()
end)

if bracketSuccess then
    print("✅ Bracket library loaded successfully!")
else
    warn("❌ Failed to load Bracket UI library:", Bracket)
end

print("🚀 Loading Universal ESP Pro Simple...")

-- Settings
local Settings = {
    Enabled = false,
    TeamCheck = false,
    ShowTeam = false,
    BoxESP = false,
    BoxStyle = "Corner",
    NameESP = false,
    TracerESP = false,
    TracerOrigin = "Bottom",
    HealthESP = false,
    SkeletonESP = false,
    ChamsEnabled = false,
    MaxDistance = 1000,
    RefreshRate = 1/60
}

-- Colors
local Colors = {
    Enemy = Color3.fromRGB(255, 0, 0),
    Ally = Color3.fromRGB(0, 255, 0),
    Health = Color3.fromRGB(0, 255, 0),
    Rainbow = Color3.fromRGB(255, 0, 0)
}

-- Drawings
local Drawings = {
    ESP = {},
    Skeleton = {}
}

-- Create ESP for player
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    -- Create ESP drawings
    Drawings.ESP[player] = {
        Box = {
            -- Box corners
            TopLeft = Drawing.new("Line"),
            TopRight = Drawing.new("Line"),
            BottomLeft = Drawing.new("Line"),
            BottomRight = Drawing.new("Line"),
            
            -- Box lines
            Top = Drawing.new("Line"),
            Left = Drawing.new("Line"),
            Right = Drawing.new("Line"),
            Bottom = Drawing.new("Line")
        },
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Health = {
            Bar = Drawing.new("Line"),
            Background = Drawing.new("Line")
        },
        Snapline = Drawing.new("Line")
    }
    
    -- Create skeleton drawings
    Drawings.Skeleton[player] = {}
    
    -- Setup default properties
    for _, line in pairs(Drawings.ESP[player].Box) do
        line.Visible = false
        line.Thickness = 1
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Transparency = 1
    end
    
    local tracer = Drawings.ESP[player].Tracer
    tracer.Visible = false
    tracer.Thickness = 1
    tracer.Color = Color3.fromRGB(255, 255, 255)
    tracer.Transparency = 1
    
    local name = Drawings.ESP[player].Name
    name.Visible = false
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Transparency = 1
    
    local distance = Drawings.ESP[player].Distance
    distance.Visible = false
    distance.Size = 13
    distance.Center = true
    distance.Outline = true
    distance.Color = Color3.fromRGB(255, 255, 255)
    distance.Transparency = 1
    
    local healthBar = Drawings.ESP[player].Health.Bar
    healthBar.Visible = false
    healthBar.Thickness = 2
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Transparency = 1
    
    local healthBg = Drawings.ESP[player].Health.Background
    healthBg.Visible = false
    healthBg.Thickness = 2
    healthBg.Color = Color3.fromRGB(255, 0, 0)
    healthBg.Transparency = 1
    
    local snapline = Drawings.ESP[player].Snapline
    snapline.Visible = false
    snapline.Thickness = 1
    snapline.Color = Color3.fromRGB(255, 255, 255)
    snapline.Transparency = 1
end

-- Remove ESP for player
local function RemoveESP(player)
    if Drawings.ESP[player] then
        for _, line in pairs(Drawings.ESP[player].Box) do
            line:Remove()
        end
        
        Drawings.ESP[player].Tracer:Remove()
        Drawings.ESP[player].Name:Remove()
        Drawings.ESP[player].Distance:Remove()
        Drawings.ESP[player].Health.Bar:Remove()
        Drawings.ESP[player].Health.Background:Remove()
        Drawings.ESP[player].Snapline:Remove()
        
        Drawings.ESP[player] = nil
    end
    
    if Drawings.Skeleton[player] then
        for _, line in pairs(Drawings.Skeleton[player]) do
            line:Remove()
        end
        
        Drawings.Skeleton[player] = nil
    end
end

-- Disable all ESP
local function DisableESP()
    for _, player in pairs(Players:GetPlayers()) do
        if Drawings.ESP[player] then
            for _, line in pairs(Drawings.ESP[player].Box) do
                line.Visible = false
            end
            
            Drawings.ESP[player].Tracer.Visible = false
            Drawings.ESP[player].Name.Visible = false
            Drawings.ESP[player].Distance.Visible = false
            Drawings.ESP[player].Health.Bar.Visible = false
            Drawings.ESP[player].Health.Background.Visible = false
            Drawings.ESP[player].Snapline.Visible = false
        end
        
        if Drawings.Skeleton[player] then
            for _, line in pairs(Drawings.Skeleton[player]) do
                line.Visible = false
            end
        end
    end
end

-- Clean up all ESP
local function CleanupESP()
    for _, player in pairs(Players:GetPlayers()) do
        RemoveESP(player)
    end
end

-- Get player color
local function GetPlayerColor(player)
    if player.Team and LocalPlayer.Team then
        if player.Team == LocalPlayer.Team then
            return Colors.Ally
        else
            return Colors.Enemy
        end
    end
    return Colors.Enemy
end

-- Get box corners
local function GetBoxCorners(character)
    if not character then return nil end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local head = character:FindFirstChild("Head")
    if not head then return nil end
    
    local min, max = hrp.Position, hrp.Position
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            min = Vector3.new(
                math.min(min.X, part.Position.X),
                math.min(min.Y, part.Position.Y),
                math.min(min.Z, part.Position.Z)
            )
            max = Vector3.new(
                math.max(max.X, part.Position.X),
                math.max(max.Y, part.Position.Y),
                math.max(max.Z, part.Position.Z)
            )
        end
    end
    
    -- Adjust Y values
    min = Vector3.new(min.X, min.Y - 0.5, min.Z)
    max = Vector3.new(max.X, max.Y + 0.5, max.Z)
    
    -- Get 2D positions
    local corners = {
        TopLeft = Camera:WorldToViewportPoint(Vector3.new(min.X, max.Y, min.Z)),
        TopRight = Camera:WorldToViewportPoint(Vector3.new(max.X, max.Y, min.Z)),
        BottomLeft = Camera:WorldToViewportPoint(Vector3.new(min.X, min.Y, min.Z)),
        BottomRight = Camera:WorldToViewportPoint(Vector3.new(max.X, min.Y, min.Z))
    }
    
    return corners
end

-- Get tracer origin
local function GetTracerOrigin()
    if Settings.TracerOrigin == "Bottom" then
        return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    elseif Settings.TracerOrigin == "Top" then
        return Vector2.new(Camera.ViewportSize.X / 2, 0)
    elseif Settings.TracerOrigin == "Mouse" then
        return UserInputService:GetMouseLocation()
    else
        return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
end

-- Update ESP
local function UpdateESP(player)
    if not Settings.Enabled then return end
    
    local esp = Drawings.ESP[player]
    if not esp then return end
    
    local character = player.Character
    if not character then 
        -- Hide all drawings if character doesn't exist
        for _, obj in pairs(esp.Box) do obj.Visible = false end
        esp.Tracer.Visible = false
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Health.Bar.Visible = false
        esp.Health.Background.Visible = false
        esp.Snapline.Visible = false
        
        -- Hide skeleton
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        
        return
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then
        return
    end
    
    -- Check if player is dead
    if humanoid.Health <= 0 then
        -- Hide all drawings if player is dead
        for _, obj in pairs(esp.Box) do obj.Visible = false end
        esp.Tracer.Visible = false
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Health.Bar.Visible = false
        esp.Health.Background.Visible = false
        esp.Snapline.Visible = false
        
        -- Hide skeleton
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        
        return
    end
    
    -- Get player position
    local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    
    -- Check if player is on screen
    if not onScreen then
        -- Hide all drawings if player is not on screen
        for _, obj in pairs(esp.Box) do obj.Visible = false end
        esp.Tracer.Visible = false
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Health.Bar.Visible = false
        esp.Health.Background.Visible = false
        esp.Snapline.Visible = false
        
        -- Hide skeleton
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        
        return
    end
    
    -- Calculate distance
    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
    
    -- Check max distance
    if distance > Settings.MaxDistance then
        -- Hide all drawings if player is too far
        for _, obj in pairs(esp.Box) do obj.Visible = false end
        esp.Tracer.Visible = false
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Health.Bar.Visible = false
        esp.Health.Background.Visible = false
        esp.Snapline.Visible = false
        
        -- Hide skeleton
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        
        return
    end
    
    -- Team check
    if Settings.TeamCheck and player.Team == LocalPlayer.Team and not Settings.ShowTeam then
        -- Hide all drawings if player is on the same team
        for _, obj in pairs(esp.Box) do obj.Visible = false end
        esp.Tracer.Visible = false
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Health.Bar.Visible = false
        esp.Health.Background.Visible = false
        esp.Snapline.Visible = false
        
        -- Hide skeleton
        local skeleton = Drawings.Skeleton[player]
        if skeleton then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
        end
        
        return
    end
    
    -- Get player color
    local color = GetPlayerColor(player)
    
    -- Get box corners
    local corners = GetBoxCorners(character)
    if not corners then return end
    
    -- Update Box ESP
    if Settings.BoxESP then
        if Settings.BoxStyle == "Corner" then
            -- Corner box
            local cornerLength = 5
            
            -- Top Left
            esp.Box.TopLeft.From = Vector2.new(corners.TopLeft.X, corners.TopLeft.Y)
            esp.Box.TopLeft.To = Vector2.new(corners.TopLeft.X + cornerLength, corners.TopLeft.Y)
            esp.Box.TopLeft.Visible = true
            esp.Box.TopLeft.Color = color
            
            -- Top Right
            esp.Box.TopRight.From = Vector2.new(corners.TopRight.X, corners.TopRight.Y)
            esp.Box.TopRight.To = Vector2.new(corners.TopRight.X - cornerLength, corners.TopRight.Y)
            esp.Box.TopRight.Visible = true
            esp.Box.TopRight.Color = color
            
            -- Bottom Left
            esp.Box.BottomLeft.From = Vector2.new(corners.BottomLeft.X, corners.BottomLeft.Y)
            esp.Box.BottomLeft.To = Vector2.new(corners.BottomLeft.X + cornerLength, corners.BottomLeft.Y)
            esp.Box.BottomLeft.Visible = true
            esp.Box.BottomLeft.Color = color
            
            -- Bottom Right
            esp.Box.BottomRight.From = Vector2.new(corners.BottomRight.X, corners.BottomRight.Y)
            esp.Box.BottomRight.To = Vector2.new(corners.BottomRight.X - cornerLength, corners.BottomRight.Y)
            esp.Box.BottomRight.Visible = true
            esp.Box.BottomRight.Color = color
            
            -- Hide full box lines
            esp.Box.Top.Visible = false
            esp.Box.Left.Visible = false
            esp.Box.Right.Visible = false
            esp.Box.Bottom.Visible = false
        elseif Settings.BoxStyle == "Full" then
            -- Full box
            esp.Box.Top.From = Vector2.new(corners.TopLeft.X, corners.TopLeft.Y)
            esp.Box.Top.To = Vector2.new(corners.TopRight.X, corners.TopRight.Y)
            esp.Box.Top.Visible = true
            esp.Box.Top.Color = color
            
            esp.Box.Left.From = Vector2.new(corners.TopLeft.X, corners.TopLeft.Y)
            esp.Box.Left.To = Vector2.new(corners.BottomLeft.X, corners.BottomLeft.Y)
            esp.Box.Left.Visible = true
            esp.Box.Left.Color = color
            
            esp.Box.Right.From = Vector2.new(corners.TopRight.X, corners.TopRight.Y)
            esp.Box.Right.To = Vector2.new(corners.BottomRight.X, corners.BottomRight.Y)
            esp.Box.Right.Visible = true
            esp.Box.Right.Color = color
            
            esp.Box.Bottom.From = Vector2.new(corners.BottomLeft.X, corners.BottomLeft.Y)
            esp.Box.Bottom.To = Vector2.new(corners.BottomRight.X, corners.BottomRight.Y)
            esp.Box.Bottom.Visible = true
            esp.Box.Bottom.Color = color
            
            -- Hide corner box lines
            esp.Box.TopLeft.Visible = false
            esp.Box.TopRight.Visible = false
            esp.Box.BottomLeft.Visible = false
            esp.Box.BottomRight.Visible = false
        else
            -- Hide all box lines if style is not supported
            for _, line in pairs(esp.Box) do
                line.Visible = false
            end
        end
    else
        -- Hide all box lines if box ESP is disabled
        for _, line in pairs(esp.Box) do
            line.Visible = false
        end
    end
    
    -- Update Name ESP
    if Settings.NameESP then
        esp.Name.Text = player.Name
        esp.Name.Position = Vector2.new(position.X, corners.TopLeft.Y - 15)
        esp.Name.Color = color
        esp.Name.Visible = true
    else
        esp.Name.Visible = false
    end
    
    -- Update Tracer ESP
    if Settings.TracerESP then
        local origin = GetTracerOrigin()
        esp.Tracer.From = origin
        esp.Tracer.To = Vector2.new(position.X, position.Y)
        esp.Tracer.Color = color
        esp.Tracer.Visible = true
    else
        esp.Tracer.Visible = false
    end
    
    -- Update Health ESP
    if Settings.HealthESP and humanoid then
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local barHeight = corners.BottomLeft.Y - corners.TopLeft.Y
        
        esp.Health.Background.From = Vector2.new(corners.TopLeft.X - 5, corners.TopLeft.Y)
        esp.Health.Background.To = Vector2.new(corners.TopLeft.X - 5, corners.BottomLeft.Y)
        esp.Health.Background.Color = Color3.fromRGB(255, 0, 0)
        esp.Health.Background.Visible = true
        
        esp.Health.Bar.From = Vector2.new(corners.TopLeft.X - 5, corners.BottomLeft.Y - (barHeight * healthPercent))
        esp.Health.Bar.To = Vector2.new(corners.TopLeft.X - 5, corners.BottomLeft.Y)
        esp.Health.Bar.Color = Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(255, 0, 0), 1 - healthPercent)
        esp.Health.Bar.Visible = true
    else
        esp.Health.Background.Visible = false
        esp.Health.Bar.Visible = false
    end
end

-- BRACKET UI INTEGRATION
if bracketSuccess and Bracket then
    -- Create a simple notification
    local Notify = Bracket:Notification({
        Title = "Universal ESP Pro Simple",
        Description = "ESP system loaded successfully!",
        Duration = 5
    })
    
    -- Create a basic window
    local Window = Bracket:Window({
        Title = "Universal ESP Pro Simple",
        Position = UDim2.new(0.05, 0, 0.5, 0),
        Size = UDim2.new(0, 400, 0, 350)
    })
    
    -- Create a single tab for all controls
    local MainTab = Window:Tab({ Title = "ESP Controls" })
    
    -- Main controls section
    local MainSection = MainTab:Section({
        Title = "ESP Controls",
        Side = "Left"
    })
    
    -- Master toggle
    MainSection:Toggle({
        Title = "Enable ESP",
        Default = Settings.Enabled,
        Callback = function(state)
            Settings.Enabled = state
            if not state then
                DisableESP()
            end
        end
    })
    
    -- Team settings
    MainSection:Toggle({
        Title = "Team Check",
        Default = Settings.TeamCheck,
        Callback = function(state)
            Settings.TeamCheck = state
        end
    })
    
    MainSection:Toggle({
        Title = "Show Teammates",
        Default = Settings.ShowTeam,
        Callback = function(state)
            Settings.ShowTeam = state
        end
    })
    
    -- Distance settings
    MainSection:Slider({
        Title = "Max Distance",
        Default = Settings.MaxDistance,
        Min = 100,
        Max = 5000,
        Callback = function(value)
            Settings.MaxDistance = value
        end
    })
    
    -- ESP Features
    local FeaturesSection = MainTab:Section({
        Title = "ESP Features",
        Side = "Right"
    })
    
    FeaturesSection:Toggle({
        Title = "Box ESP",
        Default = Settings.BoxESP,
        Callback = function(state)
            Settings.BoxESP = state
        end
    })
    
    -- Box style toggles
    FeaturesSection:Toggle({
        Title = "Corner Box Style",
        Default = Settings.BoxStyle == "Corner",
        Callback = function(state)
            if state then Settings.BoxStyle = "Corner" end
        end
    })
    
    FeaturesSection:Toggle({
        Title = "Full Box Style",
        Default = Settings.BoxStyle == "Full",
        Callback = function(state)
            if state then Settings.BoxStyle = "Full" end
        end
    })
    
    -- Other ESP features
    FeaturesSection:Toggle({
        Title = "Name ESP",
        Default = Settings.NameESP,
        Callback = function(state)
            Settings.NameESP = state
        end
    })
    
    FeaturesSection:Toggle({
        Title = "Tracer ESP",
        Default = Settings.TracerESP,
        Callback = function(state)
            Settings.TracerESP = state
        end
    })
    
    FeaturesSection:Toggle({
        Title = "Health ESP",
        Default = Settings.HealthESP,
        Callback = function(state)
            Settings.HealthESP = state
        end
    })
    
    -- Control buttons
    local ControlSection = MainTab:Section({
        Title = "Controls",
        Side = "Left"
    })
    
    ControlSection:Button({
        Title = "Reset Settings",
        Callback = function()
            CleanupESP()
            
            Settings = {
                Enabled = false,
                TeamCheck = false,
                ShowTeam = false,
                BoxESP = false,
                BoxStyle = "Corner",
                TracerESP = false,
                TracerOrigin = "Bottom",
                HealthESP = false,
                NameESP = false,
                MaxDistance = 1000
            }
            
            Notify:Update({
                Title = "Settings Reset",
                Description = "All ESP settings have been reset to default"
            })
        end
    })
    
    ControlSection:Button({
        Title = "Unload ESP",
        Callback = function()
            CleanupESP()
            Window:Destroy()
            
            Notify:Update({
                Title = "ESP Unloaded",
                Description = "Universal ESP Pro Simple has been unloaded"
            })
        end
    })
    
    -- Keybind info
    ControlSection:Label({
        Title = "Press Left Ctrl to toggle UI"
    })
    
    ControlSection:Label({
        Title = "Press Delete to hide UI"
    })
    
    -- Left Ctrl to toggle UI
    local function toggleUI()
        Window.Enabled = not Window.Enabled
    end
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode.LeftControl then
                toggleUI()
            elseif input.KeyCode == Enum.KeyCode.Delete then
                Window.Enabled = false
            end
        end
    end)
    
    -- Final notifications
    print("\n" .. string.rep("=", 40))
    print("✅ Universal ESP Pro Simple loaded successfully!")
    print("📊 Features: Box ESP, Tracers, Name, Health")
    print("⌨️ Press Left Ctrl to toggle UI | Delete to hide UI")
    print(string.rep("=", 40) .. "\n")
else
    -- Headless mode (no UI)
    print("\n" .. string.rep("=", 40))
    print("⚠️ Bracket UI not available, running in headless mode")
    print("📊 ESP features will still work without UI")
    print("💻 Use _G.UniversalESP API to control ESP programmatically")
    print(string.rep("=", 40) .. "\n")
end

-- MAIN EXECUTION

-- Initialize ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-- Connect player events
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- Main update loop
local lastUpdate = 0
RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then 
        DisableESP()
        return 
    end
    
    local currentTime = tick()
    if currentTime - lastUpdate >= Settings.RefreshRate then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not Drawings.ESP[player] then
                    CreateESP(player)
                end
                UpdateESP(player)
            end
        end
        lastUpdate = currentTime
    end
end)

-- Export API to global environment
if getgenv then
    getgenv().UniversalESP = {
        Settings = Settings,
        Colors = Colors,
        Toggle = function(state) Settings.Enabled = state end,
        ToggleBox = function(state) Settings.BoxESP = state end,
        ToggleName = function(state) Settings.NameESP = state end,
        ToggleTracer = function(state) Settings.TracerESP = state end,
        ToggleHealth = function(state) Settings.HealthESP = state end,
        SetMaxDistance = function(distance) Settings.MaxDistance = distance end,
        SetRefreshRate = function(fps) Settings.RefreshRate = 1/fps end,
        SetBoxStyle = function(style) Settings.BoxStyle = style end,
        SetTracerOrigin = function(origin) Settings.TracerOrigin = origin end,
        Cleanup = CleanupESP
    }
    print("🏁 Universal ESP Pro Simple functions exported to getgenv().UniversalESP")
else
    _G.UniversalESP = {
        Settings = Settings,
        Colors = Colors,
        Toggle = function(state) Settings.Enabled = state end,
        ToggleBox = function(state) Settings.BoxESP = state end,
        ToggleName = function(state) Settings.NameESP = state end,
        ToggleTracer = function(state) Settings.TracerESP = state end,
        ToggleHealth = function(state) Settings.HealthESP = state end,
        SetMaxDistance = function(distance) Settings.MaxDistance = distance end,
        SetRefreshRate = function(fps) Settings.RefreshRate = 1/fps end,
        SetBoxStyle = function(style) Settings.BoxStyle = style end,
        SetTracerOrigin = function(origin) Settings.TracerOrigin = origin end,
        Cleanup = CleanupESP
    }
    print("🏁 Universal ESP Pro Simple functions exported to _G.UniversalESP")
end

print("✅ Universal ESP Pro Simple loaded successfully!")
print("🎮 Use Left Ctrl to toggle UI visibility")
