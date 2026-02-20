-- Universal ESP Pro Enhanced
-- A custom implementation with enhanced Bracket UI, animations, and scaling

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Variables
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- UI Themes
local UI_THEMES = {
    Default = {
        Background = Color3.fromRGB(25, 25, 30),
        Accent = Color3.fromRGB(114, 137, 218), -- Discord-like blurple
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(185, 185, 185),
        Success = Color3.fromRGB(87, 242, 135),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(240, 71, 71),
        
        -- Component Colors
        WindowBackground = Color3.fromRGB(35, 35, 40),
        SectionBackground = Color3.fromRGB(45, 45, 50),
        ToggleEnabled = Color3.fromRGB(114, 137, 218),
        ToggleDisabled = Color3.fromRGB(65, 65, 70),
        SliderBackground = Color3.fromRGB(55, 55, 60),
        SliderFill = Color3.fromRGB(114, 137, 218),
        ButtonBackground = Color3.fromRGB(55, 55, 60),
        ButtonHover = Color3.fromRGB(65, 65, 70),
        TabActive = Color3.fromRGB(114, 137, 218),
        TabInactive = Color3.fromRGB(55, 55, 60),
    },
    
    Dark = {
        Background = Color3.fromRGB(15, 15, 20),
        Accent = Color3.fromRGB(90, 90, 180),
        Text = Color3.fromRGB(230, 230, 230),
        SubText = Color3.fromRGB(170, 170, 170),
        Success = Color3.fromRGB(70, 200, 120),
        Warning = Color3.fromRGB(220, 150, 20),
        Error = Color3.fromRGB(200, 60, 60),
        
        -- Component Colors
        WindowBackground = Color3.fromRGB(20, 20, 25),
        SectionBackground = Color3.fromRGB(30, 30, 35),
        ToggleEnabled = Color3.fromRGB(90, 90, 180),
        ToggleDisabled = Color3.fromRGB(50, 50, 55),
        SliderBackground = Color3.fromRGB(40, 40, 45),
        SliderFill = Color3.fromRGB(90, 90, 180),
        ButtonBackground = Color3.fromRGB(40, 40, 45),
        ButtonHover = Color3.fromRGB(50, 50, 55),
        TabActive = Color3.fromRGB(90, 90, 180),
        TabInactive = Color3.fromRGB(40, 40, 45),
    },
    
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Accent = Color3.fromRGB(100, 120, 220),
        Text = Color3.fromRGB(30, 30, 30),
        SubText = Color3.fromRGB(80, 80, 80),
        Success = Color3.fromRGB(60, 180, 100),
        Warning = Color3.fromRGB(220, 150, 20),
        Error = Color3.fromRGB(200, 60, 60),
        
        -- Component Colors
        WindowBackground = Color3.fromRGB(250, 250, 255),
        SectionBackground = Color3.fromRGB(235, 235, 240),
        ToggleEnabled = Color3.fromRGB(100, 120, 220),
        ToggleDisabled = Color3.fromRGB(200, 200, 205),
        SliderBackground = Color3.fromRGB(220, 220, 225),
        SliderFill = Color3.fromRGB(100, 120, 220),
        ButtonBackground = Color3.fromRGB(220, 220, 225),
        ButtonHover = Color3.fromRGB(210, 210, 215),
        TabActive = Color3.fromRGB(100, 120, 220),
        TabInactive = Color3.fromRGB(220, 220, 225),
    },
    
    Discord = {
        Background = Color3.fromRGB(54, 57, 63),
        Accent = Color3.fromRGB(114, 137, 218),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(185, 185, 185),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(240, 71, 71),
        
        -- Component Colors
        WindowBackground = Color3.fromRGB(47, 49, 54),
        SectionBackground = Color3.fromRGB(64, 68, 75),
        ToggleEnabled = Color3.fromRGB(114, 137, 218),
        ToggleDisabled = Color3.fromRGB(80, 83, 90),
        SliderBackground = Color3.fromRGB(72, 75, 81),
        SliderFill = Color3.fromRGB(114, 137, 218),
        ButtonBackground = Color3.fromRGB(72, 75, 81),
        ButtonHover = Color3.fromRGB(80, 83, 90),
        TabActive = Color3.fromRGB(114, 137, 218),
        TabInactive = Color3.fromRGB(72, 75, 81),
    },
    
    Monokai = {
        Background = Color3.fromRGB(39, 40, 34),
        Accent = Color3.fromRGB(249, 38, 114),
        Text = Color3.fromRGB(248, 248, 242),
        SubText = Color3.fromRGB(200, 200, 190),
        Success = Color3.fromRGB(166, 226, 46),
        Warning = Color3.fromRGB(244, 191, 117),
        Error = Color3.fromRGB(249, 38, 114),
        
        -- Component Colors
        WindowBackground = Color3.fromRGB(45, 46, 40),
        SectionBackground = Color3.fromRGB(56, 58, 50),
        ToggleEnabled = Color3.fromRGB(249, 38, 114),
        ToggleDisabled = Color3.fromRGB(80, 82, 76),
        SliderBackground = Color3.fromRGB(70, 72, 65),
        SliderFill = Color3.fromRGB(249, 38, 114),
        ButtonBackground = Color3.fromRGB(70, 72, 65),
        ButtonHover = Color3.fromRGB(80, 82, 76),
        TabActive = Color3.fromRGB(249, 38, 114),
        TabInactive = Color3.fromRGB(70, 72, 65),
    },
}

-- Current theme (default to Default theme)
local UI_THEME = UI_THEMES.Default

-- Theme switching function
local function SwitchTheme(themeName)
    if UI_THEMES[themeName] then
        UI_THEME = UI_THEMES[themeName]
        return true
    end
    return false
end

local UI_FONTS = {
    Main = Enum.Font.SourceSansSemibold,
    Bold = Enum.Font.SourceSansBold,
    Light = Enum.Font.SourceSans,
    Mono = Enum.Font.Code,
}

local UI_SIZES = {
    WindowWidth = 550,
    WindowHeight = 400,
    TabHeight = 35,
    SectionPadding = 8,
    ElementHeight = 30,
    ElementPadding = 5,
    BorderRadius = 4,
}

-- Animation utilities
local ANIMATION = {
    EasingStyle = Enum.EasingStyle.Quint,
    EasingDirection = Enum.EasingDirection.Out,
    
    FadeIn = function(obj, duration)
        duration = duration or 0.3
        local originalTransparency = obj.Transparency
        obj.Transparency = 1
        
        local tween = TweenService:Create(
            obj,
            TweenInfo.new(duration, ANIMATION.EasingStyle, ANIMATION.EasingDirection),
            {Transparency = originalTransparency}
        )
        tween:Play()
        return tween
    end,
    
    FadeOut = function(obj, duration)
        duration = duration or 0.3
        local originalTransparency = obj.Transparency
        
        local tween = TweenService:Create(
            obj,
            TweenInfo.new(duration, ANIMATION.EasingStyle, ANIMATION.EasingDirection),
            {Transparency = 1}
        )
        
        tween.Completed:Connect(function()
            obj.Transparency = originalTransparency
        end)
        
        tween:Play()
        return tween
    end,
    
    SlideIn = function(obj, direction, duration)
        duration = duration or 0.5
        direction = direction or "Right"
        
        local originalPosition = obj.Position
        local offscreenPosition
        
        if direction == "Right" then
            offscreenPosition = Vector2.new(originalPosition.X + 200, originalPosition.Y)
        elseif direction == "Left" then
            offscreenPosition = Vector2.new(originalPosition.X - 200, originalPosition.Y)
        elseif direction == "Up" then
            offscreenPosition = Vector2.new(originalPosition.X, originalPosition.Y - 200)
        elseif direction == "Down" then
            offscreenPosition = Vector2.new(originalPosition.X, originalPosition.Y + 200)
        end
        
        obj.Position = offscreenPosition
        local tween = TweenService:Create(
            obj,
            TweenInfo.new(duration, ANIMATION.EasingStyle, ANIMATION.EasingDirection),
            {Position = originalPosition}
        )
        tween:Play()
        return tween
    end,
    
    SlideOut = function(obj, direction, duration)
        duration = duration or 0.5
        direction = direction or "Right"
        
        local originalPosition = obj.Position
        local offscreenPosition
        
        if direction == "Right" then
            offscreenPosition = Vector2.new(originalPosition.X + 200, originalPosition.Y)
        elseif direction == "Left" then
            offscreenPosition = Vector2.new(originalPosition.X - 200, originalPosition.Y)
        elseif direction == "Up" then
            offscreenPosition = Vector2.new(originalPosition.X, originalPosition.Y - 200)
        elseif direction == "Down" then
            offscreenPosition = Vector2.new(originalPosition.X, originalPosition.Y + 200)
        end
        
        local tween = TweenService:Create(
            obj,
            TweenInfo.new(duration, ANIMATION.EasingStyle, ANIMATION.EasingDirection),
            {Position = offscreenPosition}
        )
        
        tween.Completed:Connect(function()
            obj.Position = originalPosition
        end)
        
        tween:Play()
        return tween
    end,
    
    ScaleIn = function(obj, duration)
        duration = duration or 0.3
        local originalSize = obj.Size
        obj.Size = Vector2.new(0, 0)
        
        local tween = TweenService:Create(
            obj,
            TweenInfo.new(duration, ANIMATION.EasingStyle, ANIMATION.EasingDirection),
            {Size = originalSize}
        )
        tween:Play()
        return tween
    end,
    
    ScaleOut = function(obj, duration)
        duration = duration or 0.3
        local originalSize = obj.Size
        
        local tween = TweenService:Create(
            obj,
            TweenInfo.new(duration, ANIMATION.EasingStyle, ANIMATION.EasingDirection),
            {Size = Vector2.new(0, 0)}
        )
        
        tween.Completed:Connect(function()
            obj.Size = originalSize
        end)
        
        tween:Play()
        return tween
    end,
    
    Pulse = function(obj, duration, scale)
        duration = duration or 0.5
        scale = scale or 1.05
        local originalSize = obj.Size
        local pulseSize = Vector2.new(
            originalSize.X * scale,
            originalSize.Y * scale
        )
        
        local sequence = TweenService:Create(
            obj,
            TweenInfo.new(duration/2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            {Size = pulseSize}
        )
        
        local sequenceBack = TweenService:Create(
            obj,
            TweenInfo.new(duration/2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
            {Size = originalSize}
        )
        
        sequence:Play()
        sequence.Completed:Connect(function()
            sequenceBack:Play()
        end)
        
        return sequence
    end,
    
    ColorShift = function(obj, targetColor, duration)
        duration = duration or 0.5
        local originalColor = obj.Color
        
        local tween = TweenService:Create(
            obj,
            TweenInfo.new(duration, ANIMATION.EasingStyle, ANIMATION.EasingDirection),
            {Color = targetColor}
        )
        
        tween.Completed:Connect(function()
            -- Optional callback
        end)
        
        tween:Play()
        return tween
    end,
    
    Shake = function(obj, intensity, duration)
        intensity = intensity or 5
        duration = duration or 0.5
        local originalPosition = obj.Position
        local startTime = tick()
        
        -- Create a connection that will be disconnected later
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local elapsed = tick() - startTime
            
            if elapsed >= duration then
                obj.Position = originalPosition
                connection:Disconnect()
                return
            end
            
            local offsetX = math.random(-intensity, intensity)
            local offsetY = math.random(-intensity, intensity)
            
            obj.Position = Vector2.new(
                originalPosition.X + offsetX,
                originalPosition.Y + offsetY
            )
        end)
        
        return connection
    end,
    
    Bounce = function(obj, height, duration)
        height = height or 20
        duration = duration or 0.5
        local originalPosition = obj.Position
        
        local upTween = TweenService:Create(
            obj,
            TweenInfo.new(duration/2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            {Position = Vector2.new(originalPosition.X, originalPosition.Y - height)}
        )
        
        local downTween = TweenService:Create(
            obj,
            TweenInfo.new(duration/2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
            {Position = originalPosition}
        )
        
        upTween:Play()
        upTween.Completed:Connect(function()
            downTween:Play()
        end)
        
        return upTween
    end
}

-- Enhanced UI Framework
local EnhancedUI = {}
EnhancedUI.__index = EnhancedUI

-- Utility functions
local function CreateElement(class, properties)
    local element = Drawing.new(class)
    for property, value in pairs(properties) do
        element[property] = value
    end
    return element
end

local function RoundNumber(num, decimalPlaces)
    local mult = 10^(decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- DevCopy Integration (Direct Implementation)
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
    local success, result = pcall(function()
        table.insert(consoleLog, "=== Console Log ===")
        table.insert(consoleLog, os.date("%Y-%m-%d %H:%M:%S"))
        table.insert(consoleLog, "Universal ESP Pro Enhanced")
        table.insert(consoleLog, "===================")
        return table.concat(consoleLog, "\n")
    end)
    
    if success then
        clipboardFunction(result)
        return true, result
    else
        return false, "Failed to copy log: " .. tostring(result)
    end
end

-- Configuration Management System
local ConfigSystem = {}

-- Default file name for saving/loading configs
ConfigSystem.DefaultFileName = "UniversalESPEnhanced_Config"

-- Convert Color3 to serializable format
function ConfigSystem.SerializeColor3(color)
    return {
        R = color.R,
        G = color.G,
        B = color.B
    }
end

-- Convert serialized format back to Color3
function ConfigSystem.DeserializeColor3(data)
    return Color3.new(data.R, data.G, data.B)
end

-- Save configuration to file
function ConfigSystem.SaveConfig(settings, fileName)
    fileName = fileName or ConfigSystem.DefaultFileName
    
    -- Create a deep copy of settings to avoid modifying the original
    local configToSave = {}
    
    -- Process settings to make them serializable
    for key, value in pairs(settings) do
        if type(value) == "table" then
            configToSave[key] = {}
            for subKey, subValue in pairs(value) do
                if typeof(subValue) == "Color3" then
                    configToSave[key][subKey] = ConfigSystem.SerializeColor3(subValue)
                else
                    configToSave[key][subKey] = subValue
                end
            end
        elseif typeof(value) == "Color3" then
            configToSave[key] = ConfigSystem.SerializeColor3(value)
        else
            configToSave[key] = value
        end
    end
    
    -- Convert to JSON
    local success, jsonData = pcall(function()
        return HttpService:JSONEncode(configToSave)
    end)
    
    if not success then
        warn("Failed to encode settings to JSON: " .. tostring(jsonData))
        return false
    end
    
    -- Save to file
    local success, err = pcall(function()
        writefile(fileName .. ".json", jsonData)
    end)
    
    if not success then
        warn("Failed to save config: " .. tostring(err))
        return false
    end
    
    print("✅ Configuration saved to " .. fileName .. ".json")
    return true
end

-- Load configuration from file
function ConfigSystem.LoadConfig(fileName)
    fileName = fileName or ConfigSystem.DefaultFileName
    
    -- Check if file exists
    local success, fileExists = pcall(function()
        return isfile(fileName .. ".json")
    end)
    
    if not success or not fileExists then
        warn("Config file does not exist: " .. fileName .. ".json")
        return nil
    end
    
    -- Read file
    local success, fileData = pcall(function()
        return readfile(fileName .. ".json")
    end)
    
    if not success then
        warn("Failed to read config file: " .. tostring(fileData))
        return nil
    end
    
    -- Parse JSON
    local success, configData = pcall(function()
        return HttpService:JSONDecode(fileData)
    end)
    
    if not success then
        warn("Failed to parse config JSON: " .. tostring(configData))
        return nil
    end
    
    -- Process loaded data to convert serialized values back
    local loadedConfig = {}
    
    for key, value in pairs(configData) do
        if type(value) == "table" then
            if value.R ~= nil and value.G ~= nil and value.B ~= nil then
                -- This is a serialized Color3
                loadedConfig[key] = ConfigSystem.DeserializeColor3(value)
            else
                loadedConfig[key] = {}
                for subKey, subValue in pairs(value) do
                    if type(subValue) == "table" and subValue.R ~= nil and subValue.G ~= nil and subValue.B ~= nil then
                        loadedConfig[key][subKey] = ConfigSystem.DeserializeColor3(subValue)
                    else
                        loadedConfig[key][subKey] = subValue
                    end
                end
            end
        else
            loadedConfig[key] = value
        end
    end
    
    print("✅ Configuration loaded from " .. fileName .. ".json")
    return loadedConfig
end

-- Get list of saved configurations
function ConfigSystem.GetSavedConfigs()
    local success, files = pcall(function()
        return listfiles()
    end)
    
    if not success then
        warn("Failed to list files: " .. tostring(files))
        return {}
    end
    
    local configs = {}
    for _, file in ipairs(files) do
        if file:match(".+%.json$") then
            table.insert(configs, file:match("(.+)%.json$"))
        end
    end
    
    return configs
end

-- ESP Settings
local ESPSettings = {
    Enabled = true,
    TeamCheck = false,
    TeamColor = true,
    VisibilityCheck = false,
    MaxDistance = 1000,
    RefreshRate = 10,
    
    BoxESP = {
        Enabled = true,
        Filled = false,
        Thickness = 1,
        Transparency = 0.7,
        Color = Color3.fromRGB(255, 255, 255),
    },
    
    TracerESP = {
        Enabled = true,
        Origin = "Bottom", -- Bottom, Center, Mouse
        Thickness = 1,
        Transparency = 0.7,
        Color = Color3.fromRGB(255, 255, 255),
    },
    
    NameESP = {
        Enabled = true,
        ShowDistance = true,
        ShowHealth = true,
        Outline = true,
        Size = 14,
        Color = Color3.fromRGB(255, 255, 255),
    },
    
    HealthESP = {
        Enabled = true,
        ShowBar = true,
        ShowText = false,
        Thickness = 1,
    },
    
    SkeletonESP = {
        Enabled = false,
        Thickness = 1,
        Transparency = 0.7,
        Color = Color3.fromRGB(255, 255, 255),
    },
    
    Rainbow = {
        Enabled = false,
        Speed = 1,
    },
    
    -- UI Settings
    UI = {
        Theme = "Default",
        Position = Vector2.new(20, 20),
        Size = Vector2.new(550, 400),
        Transparency = 0.95,
    },
    
    ChamsESP = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 0),
        Transparency = 0.5,
        FillColor = Color3.fromRGB(255, 0, 0),
        FillTransparency = 0.5,
        Visible = true,
        Occluded = true,
    },
    
    -- Global Settings
    TeamCheck = false,
    TeamColor = false,
    VisibilityCheck = false,
    TargetPlayers = true,
    TargetNPCs = false,
    MaxDistance = 1000,
    RefreshRate = 10, -- ms
    
    -- Rainbow Mode
    Rainbow = {
        Enabled = false,
        Speed = 1,
    },
}

-- ESP Objects Container
local ESPObjects = {
    Players = {},
    Connections = {},
}

-- ESP Drawing Functions
local ESPFunctions = {}

-- Create ESP for a player
function ESPFunctions:CreateESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local esp = {
        Player = player,
        Character = player.Character,
        Humanoid = player.Character:FindFirstChildOfClass("Humanoid"),
        RootPart = player.Character:FindFirstChild("HumanoidRootPart"),
        Head = player.Character:FindFirstChild("Head"),
        Torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso"),
        IsAlive = true,
        
        -- ESP Drawing Objects
        Box = {
            TopLeft = CreateElement("Line", {
                Thickness = ESPSettings.BoxESP.Thickness,
                Color = ESPSettings.BoxESP.Color,
                Transparency = ESPSettings.BoxESP.Transparency,
                Visible = ESPSettings.BoxESP.Enabled,
            }),
            TopRight = CreateElement("Line", {
                Thickness = ESPSettings.BoxESP.Thickness,
                Color = ESPSettings.BoxESP.Color,
                Transparency = ESPSettings.BoxESP.Transparency,
                Visible = ESPSettings.BoxESP.Enabled,
            }),
            BottomLeft = CreateElement("Line", {
                Thickness = ESPSettings.BoxESP.Thickness,
                Color = ESPSettings.BoxESP.Color,
                Transparency = ESPSettings.BoxESP.Transparency,
                Visible = ESPSettings.BoxESP.Enabled,
            }),
            BottomRight = CreateElement("Line", {
                Thickness = ESPSettings.BoxESP.Thickness,
                Color = ESPSettings.BoxESP.Color,
                Transparency = ESPSettings.BoxESP.Transparency,
                Visible = ESPSettings.BoxESP.Enabled,
            }),
            Fill = CreateElement("Square", {
                Thickness = 0,
                Color = ESPSettings.BoxESP.Color,
                Transparency = ESPSettings.BoxESP.Transparency + 0.5,
                Filled = true,
                Visible = ESPSettings.BoxESP.Enabled and ESPSettings.BoxESP.Filled,
            }),
        },
        
        Tracer = CreateElement("Line", {
            Thickness = ESPSettings.TracerESP.Thickness,
            Color = ESPSettings.TracerESP.Color,
            Transparency = ESPSettings.TracerESP.Transparency,
            Visible = ESPSettings.TracerESP.Enabled,
        }),
        
        Name = CreateElement("Text", {
            Text = player.Name,
            Size = ESPSettings.NameESP.Size,
            Center = true,
            Outline = ESPSettings.NameESP.Outline,
            Color = ESPSettings.NameESP.Color,
            Transparency = ESPSettings.NameESP.Transparency,
            Visible = ESPSettings.NameESP.Enabled,
        }),
        
        HealthBar = CreateElement("Line", {
            Thickness = ESPSettings.HealthESP.Thickness,
            Color = ESPSettings.HealthESP.Color,
            Transparency = ESPSettings.HealthESP.Transparency,
            Visible = ESPSettings.HealthESP.Enabled and ESPSettings.HealthESP.ShowBar,
        }),
        
        HealthText = CreateElement("Text", {
            Text = "100",
            Size = ESPSettings.NameESP.Size - 2,
            Center = true,
            Outline = true,
            Color = ESPSettings.HealthESP.Color,
            Transparency = ESPSettings.HealthESP.Transparency,
            Visible = ESPSettings.HealthESP.Enabled and ESPSettings.HealthESP.ShowText,
        }),
        
        -- Skeleton lines (simplified for brevity)
        Skeleton = {
            Head_Torso = CreateElement("Line", {
                Thickness = ESPSettings.SkeletonESP.Thickness,
                Color = ESPSettings.SkeletonESP.Color,
                Transparency = ESPSettings.SkeletonESP.Transparency,
                Visible = ESPSettings.SkeletonESP.Enabled,
            }),
            -- More skeleton lines would be added here
        },
    }
    
    -- Store ESP objects
    ESPObjects.Players[player] = esp
    
    return esp
end

-- Update ESP for a player
function ESPFunctions:UpdateESP(esp)
    if not esp or not esp.Player or not esp.Player.Character or not esp.RootPart then
        return
    end
    
    -- Check if player is within max distance
    local distance = (esp.RootPart.Position - Camera.CFrame.Position).Magnitude
    if distance > ESPSettings.MaxDistance then
        self:SetESPEnabled(esp, false)
        return
    end
    
    -- Check if player is on the same team
    local teamCheck = true
    if ESPSettings.TeamCheck and esp.Player.Team and LocalPlayer.Team then
        teamCheck = esp.Player.Team ~= LocalPlayer.Team
    end
    
    if not teamCheck then
        self:SetESPEnabled(esp, false)
        return
    end
    
    -- Check if player is alive
    esp.IsAlive = esp.Humanoid and esp.Humanoid.Health > 0
    if not esp.IsAlive then
        self:SetESPEnabled(esp, false)
        return
    end
    
    -- Enable ESP
    self:SetESPEnabled(esp, true)
    
    -- Get character bounds
    local rootPos, rootVis = Camera:WorldToViewportPoint(esp.RootPart.Position)
    if not rootVis then
        self:SetESPEnabled(esp, false)
        return
    end
    
    -- Calculate character size for ESP
    local head = esp.Head
    local torso = esp.Torso
    local rootPart = esp.RootPart
    
    if not head or not torso or not rootPart then
        return
    end
    
    local headPos = Camera:WorldToViewportPoint(head.Position)
    local torsoPos = Camera:WorldToViewportPoint(torso.Position)
    local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
    
    local height = math.abs(headPos.Y - legPos.Y)
    local width = height * 0.6
    
    -- Update Box ESP
    if ESPSettings.BoxESP.Enabled then
        local boxTopLeft = Vector2.new(rootPos.X - width / 2, headPos.Y)
        local boxTopRight = Vector2.new(rootPos.X + width / 2, headPos.Y)
        local boxBottomLeft = Vector2.new(rootPos.X - width / 2, legPos.Y)
        local boxBottomRight = Vector2.new(rootPos.X + width / 2, legPos.Y)
        
        -- Update box lines
        esp.Box.TopLeft.From = boxTopLeft
        esp.Box.TopLeft.To = boxTopRight
        
        esp.Box.TopRight.From = boxTopRight
        esp.Box.TopRight.To = boxBottomRight
        
        esp.Box.BottomLeft.From = boxBottomLeft
        esp.Box.BottomLeft.To = boxTopLeft
        
        esp.Box.BottomRight.From = boxBottomLeft
        esp.Box.BottomRight.To = boxBottomRight
        
        -- Update box fill
        esp.Box.Fill.Position = boxTopLeft
        esp.Box.Fill.Size = Vector2.new(width, height)
        
        -- Update box color
        local boxColor = ESPSettings.BoxESP.Color
        if ESPSettings.TeamColor then
            boxColor = esp.Player.TeamColor.Color
        end
        
        esp.Box.TopLeft.Color = boxColor
        esp.Box.TopRight.Color = boxColor
        esp.Box.BottomLeft.Color = boxColor
        esp.Box.BottomRight.Color = boxColor
        esp.Box.Fill.Color = boxColor
        esp.Box.Fill.Transparency = ESPSettings.BoxESP.Transparency + 0.5
        esp.Box.Fill.Visible = ESPSettings.BoxESP.Enabled and ESPSettings.BoxESP.Filled
    end
    
    -- Update Tracer ESP
    if ESPSettings.TracerESP.Enabled then
        local tracerStart
        local tracerOrigin = ESPSettings.TracerESP.Origin
        
        if tracerOrigin == "Bottom" then
            tracerStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        elseif tracerOrigin == "Center" then
            tracerStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        elseif tracerOrigin == "Mouse" then
            tracerStart = UserInputService:GetMouseLocation()
        end
        
        esp.Tracer.From = tracerStart
        esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
        
        -- Update tracer color
        local tracerColor = ESPSettings.TracerESP.Color
        if ESPSettings.TeamColor then
            tracerColor = esp.Player.TeamColor.Color
        end
        
        esp.Tracer.Color = tracerColor
    end
    
    -- Update Name ESP
    if ESPSettings.NameESP.Enabled then
        esp.Name.Position = Vector2.new(rootPos.X, headPos.Y - 15)
        
        local nameText = esp.Player.Name
        
        -- Add distance if enabled
        if ESPSettings.NameESP.ShowDistance then
            local roundedDistance = math.floor(distance)
            nameText = nameText .. " [" .. roundedDistance .. "]"
        end
        
        -- Add health if enabled
        if ESPSettings.NameESP.ShowHealth and esp.Humanoid then
            local health = math.floor(esp.Humanoid.Health)
            local maxHealth = math.floor(esp.Humanoid.MaxHealth)
            nameText = nameText .. " [" .. health .. "/" .. maxHealth .. "]"
        end
        
        esp.Name.Text = nameText
        
        -- Update name color
        local nameColor = ESPSettings.NameESP.Color
        if ESPSettings.TeamColor then
            nameColor = esp.Player.TeamColor.Color
        end
        
        esp.Name.Color = nameColor
    end
    
    -- Update Health Bar ESP
    if ESPSettings.HealthESP.Enabled and ESPSettings.HealthESP.ShowBar and esp.Humanoid then
        local health = esp.Humanoid.Health
        local maxHealth = esp.Humanoid.MaxHealth
        local healthRatio = math.clamp(health / maxHealth, 0, 1)
        
        local barHeight = height * healthRatio
        local barStart = Vector2.new(rootPos.X - width / 2 - 5, legPos.Y)
        local barEnd = Vector2.new(rootPos.X - width / 2 - 5, legPos.Y - barHeight)
        
        esp.HealthBar.From = barStart
        esp.HealthBar.To = barEnd
        
        -- Health color gradient (green to red)
        local healthColor = Color3.fromRGB(
            255 * (1 - healthRatio),
            255 * healthRatio,
            0
        )
        
        esp.HealthBar.Color = healthColor
    end
    
    -- Update Health Text ESP
    if ESPSettings.HealthESP.Enabled and ESPSettings.HealthESP.ShowText and esp.Humanoid then
        local health = math.floor(esp.Humanoid.Health)
        esp.HealthText.Text = tostring(health)
        esp.HealthText.Position = Vector2.new(rootPos.X, legPos.Y + 15)
        
        -- Health color gradient (green to red)
        local healthRatio = math.clamp(esp.Humanoid.Health / esp.Humanoid.MaxHealth, 0, 1)
        local healthColor = Color3.fromRGB(
            255 * (1 - healthRatio),
            255 * healthRatio,
            0
        )
        
        esp.HealthText.Color = healthColor
    end
    
    -- Update Skeleton ESP (simplified for brevity)
    if ESPSettings.SkeletonESP.Enabled then
        local headPos2D = Vector2.new(headPos.X, headPos.Y)
        local torsoPos2D = Vector2.new(torsoPos.X, torsoPos.Y)
        
        esp.Skeleton.Head_Torso.From = headPos2D
        esp.Skeleton.Head_Torso.To = torsoPos2D
        
        -- Additional skeleton connections would be updated here
    end
end

-- Set ESP visibility
function ESPFunctions:SetESPEnabled(esp, enabled)
    if not esp then return end
    
    -- Box ESP
    for _, part in pairs(esp.Box) do
        if type(part) == "table" and part.Visible ~= nil then
            part.Visible = enabled and ESPSettings.BoxESP.Enabled
        end
    end
    
    -- Tracer ESP
    esp.Tracer.Visible = enabled and ESPSettings.TracerESP.Enabled
    
    -- Name ESP
    esp.Name.Visible = enabled and ESPSettings.NameESP.Enabled
    
    -- Health ESP
    esp.HealthBar.Visible = enabled and ESPSettings.HealthESP.Enabled and ESPSettings.HealthESP.ShowBar
    esp.HealthText.Visible = enabled and ESPSettings.HealthESP.Enabled and ESPSettings.HealthESP.ShowText
    
    -- Skeleton ESP
    for _, part in pairs(esp.Skeleton) do
        if type(part) == "table" and part.Visible ~= nil then
            part.Visible = enabled and ESPSettings.SkeletonESP.Enabled
        end
    end
end

-- Remove ESP for a player
function ESPFunctions:RemoveESP(player)
    local esp = ESPObjects.Players[player]
    if not esp then return end
    
    -- Remove box ESP
    for _, part in pairs(esp.Box) do
        if type(part) == "table" and part.Remove then
            part:Remove()
        end
    end
    
    -- Remove tracer ESP
    if esp.Tracer and esp.Tracer.Remove then
        esp.Tracer:Remove()
    end
    
    -- Remove name ESP
    if esp.Name and esp.Name.Remove then
        esp.Name:Remove()
    end
    
    -- Remove health ESP
    if esp.HealthBar and esp.HealthBar.Remove then
        esp.HealthBar:Remove()
    end
    
    if esp.HealthText and esp.HealthText.Remove then
        esp.HealthText:Remove()
    end
    
    -- Remove skeleton ESP
    for _, part in pairs(esp.Skeleton) do
        if type(part) == "table" and part.Remove then
            part:Remove()
        end
    end
    
    -- Remove from ESP objects
    ESPObjects.Players[player] = nil
end

-- Clean up all ESP objects
function ESPFunctions:CleanupESP()
    -- Remove all player ESP
    for player, esp in pairs(ESPObjects.Players) do
        self:RemoveESP(player)
    end
    
    -- Disconnect all connections
    for _, connection in pairs(ESPObjects.Connections) do
        if connection.Disconnect then
            connection:Disconnect()
        end
    end
    
    ESPObjects.Connections = {}
end

-- Enhanced UI Components with Custom Naming
local VisualInterface = {}

-- Create main panel
function VisualInterface.CreateDisplayPanel(title, position)
    local panel = {
        Title = title or "Universal ESP Pro Enhanced",
        Visible = true,
        Position = position or Vector2.new(20, 20),
        Size = Vector2.new(UI_SIZES.WindowWidth, UI_SIZES.WindowHeight),
        Dragging = false,
        DragOffset = Vector2.new(0, 0),
        Elements = {},
        Categories = {}, -- Renamed from Tabs
        ActiveCategory = nil, -- Renamed from ActiveTab
        
        -- Drawing objects with custom naming
        PanelFrame = nil, -- Renamed from Background
        HeaderBar = nil,  -- Renamed from TitleBar
        HeaderText = nil, -- Renamed from TitleText
        ExitButton = nil, -- Renamed from CloseButton
        CollapseButton = nil, -- Renamed from MinimizeButton
        CategoryBar = nil, -- Renamed from TabContainer
        ContentFrame = nil, -- Renamed from ContentContainer
    }
    
    -- Initialize panel elements
    panel.PanelFrame = CreateElement("Square", {
        Size = Vector2.new(panel.Size.X, panel.Size.Y),
        Position = panel.Position,
        Color = UI_THEME.WindowBackground,
        Filled = true,
        Thickness = 0,
        Visible = panel.Visible,
        Transparency = 0.95,
    })
    
    panel.HeaderBar = CreateElement("Square", {
        Size = Vector2.new(panel.Size.X, 30),
        Position = panel.Position,
        Color = UI_THEME.Background,
        Filled = true,
        Thickness = 0,
        Visible = panel.Visible,
        Transparency = 0.95,
    })
    
    panel.HeaderText = CreateElement("Text", {
        Text = panel.Title,
        Size = 18,
        Center = false,
        Outline = false,
        Position = Vector2.new(panel.Position.X + 10, panel.Position.Y + 6),
        Color = UI_THEME.Text,
        Font = UI_FONTS.Bold,
        Visible = panel.Visible,
        Transparency = 1,
    })
    
    panel.ExitButton = CreateElement("Square", {
        Size = Vector2.new(20, 20),
        Position = Vector2.new(panel.Position.X + panel.Size.X - 25, panel.Position.Y + 5),
        Color = UI_THEME.Error,
        Filled = true,
        Thickness = 0,
        Visible = panel.Visible,
        Transparency = 0.8,
    })
    
    panel.CollapseButton = CreateElement("Square", {
        Size = Vector2.new(20, 20),
        Position = Vector2.new(panel.Position.X + panel.Size.X - 50, panel.Position.Y + 5),
        Color = UI_THEME.Warning,
        Filled = true,
        Thickness = 0,
        Visible = panel.Visible,
        Transparency = 0.8,
    })
    
    panel.CategoryBar = CreateElement("Square", {
        Size = Vector2.new(panel.Size.X, UI_SIZES.TabHeight),
        Position = Vector2.new(panel.Position.X, panel.Position.Y + 30),
        Color = UI_THEME.Background,
        Filled = true,
        Thickness = 0,
        Visible = panel.Visible,
        Transparency = 0.95,
    })
    
    panel.ContentFrame = CreateElement("Square", {
        Size = Vector2.new(panel.Size.X, panel.Size.Y - 30 - UI_SIZES.TabHeight),
        Position = Vector2.new(panel.Position.X, panel.Position.Y + 30 + UI_SIZES.TabHeight),
        Color = UI_THEME.WindowBackground,
        Filled = true,
        Thickness = 0,
        Visible = panel.Visible,
        Transparency = 0.95,
    })
    
    -- Panel methods
    function panel:CreateCategory(name)
        local categoryIndex = #self.Categories + 1
        local categoryWidth = 100
        local categoryPosition = Vector2.new(
            self.Position.X + (categoryIndex - 1) * categoryWidth,
            self.Position.Y + 30
        )
        
        local category = {
            Name = name,
            Visible = false,
            Elements = {},
            
            -- Drawing objects
            Background = CreateElement("Square", {
                Size = Vector2.new(categoryWidth, UI_SIZES.TabHeight),
                Position = categoryPosition,
                Color = UI_THEME.TabInactive,
                Filled = true,
                Thickness = 0,
                Visible = self.Visible,
                Transparency = 0.95,
            }),
            
            Text = CreateElement("Text", {
                Text = name,
                Size = 14,
                Center = true,
                Outline = false,
                Position = Vector2.new(tabPosition.X + tabWidth/2, tabPosition.Y + UI_SIZES.TabHeight/2 - 7),
                Color = UI_THEME.Text,
                Font = UI_FONTS.Main,
                Visible = self.Visible,
                Transparency = 1,
            }),
            
            Content = CreateElement("Square", {
                Size = Vector2.new(self.Size.X - 20, self.Size.Y - 30 - UI_SIZES.TabHeight - 10),
                Position = Vector2.new(self.Position.X + 10, self.Position.Y + 30 + UI_SIZES.TabHeight + 5),
                Color = UI_THEME.WindowBackground,
                Filled = true,
                Thickness = 0,
                Visible = false,
        }
        
        -- Initialize panel elements
        panel.PanelFrame = CreateElement("Square", {
            Size = Vector2.new(panel.Size.X, panel.Size.Y),
            Position = panel.Position,
            Color = UI_THEME.WindowBackground,
            Filled = true,
            Thickness = 0,
            Visible = panel.Visible,
            Transparency = 0.95,
        })
        
        panel.HeaderBar = CreateElement("Square", {
            Size = Vector2.new(panel.Size.X, 30),
            Position = panel.Position,
            Color = UI_THEME.Background,
            Filled = true,
            Thickness = 0,
            Visible = panel.Visible,
            Transparency = 0.95,
        })
        
        panel.HeaderText = CreateElement("Text", {
            Text = panel.Title,
            Size = 18,
            Center = false,
            Outline = false,
            Position = Vector2.new(panel.Position.X + 10, panel.Position.Y + 6),
            Color = UI_THEME.Text,
            Font = UI_FONTS.Bold,
            Visible = panel.Visible,
            Transparency = 1,
        })
        
        panel.ExitButton = CreateElement("Square", {
            Size = Vector2.new(20, 20),
            Position = Vector2.new(panel.Position.X + panel.Size.X - 25, panel.Position.Y + 5),
            Color = UI_THEME.Error,
            Filled = true,
            Thickness = 0,
            Visible = panel.Visible,
            Transparency = 0.8,
        })
        
        panel.CollapseButton = CreateElement("Square", {
            Size = Vector2.new(20, 20),
            Position = Vector2.new(panel.Position.X + panel.Size.X - 50, panel.Position.Y + 5),
            Color = UI_THEME.Warning,
            Filled = true,
            Thickness = 0,
            Visible = panel.Visible,
            Transparency = 0.8,
        })
        
        panel.CategoryBar = CreateElement("Square", {
            Size = Vector2.new(panel.Size.X, UI_SIZES.TabHeight),
            Position = Vector2.new(panel.Position.X, panel.Position.Y + 30),
            Color = UI_THEME.Background,
            Filled = true,
            Thickness = 0,
            Visible = panel.Visible,
            Transparency = 0.95,
        })
        
        panel.ContentFrame = CreateElement("Square", {
            Size = Vector2.new(panel.Size.X, panel.Size.Y - 30 - UI_SIZES.TabHeight),
            Position = Vector2.new(panel.Position.X, panel.Position.Y + 30 + UI_SIZES.TabHeight),
            Color = UI_THEME.WindowBackground,
            Filled = true,
            Thickness = 0,
            Visible = panel.Visible,
            Transparency = 0.95,
        })
        
        -- Panel methods
        function panel:CreateCategory(name)
            local categoryIndex = #self.Categories + 1
            local categoryWidth = 100
            local categoryPosition = Vector2.new(
                self.Position.X + (categoryIndex - 1) * categoryWidth,
                self.Position.Y + 30
            )
            
            local section = {
                Title = title,
                Elements = {},
                Position = sectionPosition,
                Size = Vector2.new(sectionWidth, sectionHeight),
                
                -- Drawing objects
                Background = CreateElement("Square", {
                    Size = Vector2.new(sectionWidth, sectionHeight),
                    Position = sectionPosition,
                    Color = UI_THEME.SectionBackground,
                    Filled = true,
                    Thickness = 0,
                    Visible = self.Visible,
                    Transparency = 0.95,
                }),
                
                TitleText = CreateElement("Text", {
                    Text = title,
                    Size = 14,
                    Center = false,
                    Outline = false,
                    Position = Vector2.new(sectionPosition.X + 10, sectionPosition.Y + 5),
                    Color = UI_THEME.Text,
                    Font = UI_FONTS.Bold,
                    Visible = self.Visible,
                    Transparency = 1,
                }),
                
                Divider = CreateElement("Square", {
                    Size = Vector2.new(sectionWidth - 20, 1),
                    Position = Vector2.new(sectionPosition.X + 10, sectionPosition.Y + 25),
                    Color = UI_THEME.Accent,
                    Filled = true,
                    Thickness = 0,
                    Visible = self.Visible,
                    Transparency = 0.7,
                }),
            }
            
            -- Section methods for UI components
            function section:AddToggle(name, default, callback)
                local elementCount = #self.Elements
                local togglePosition = Vector2.new(
                    self.Position.X + 15,
                    self.Position.Y + 35 + (elementCount * (UI_SIZES.ElementHeight + UI_SIZES.ElementPadding))
                )
                
                local toggle = {
                    Name = name,
                    Value = default or false,
                    Callback = callback or function() end,
                    
                    -- Drawing objects
                    Background = CreateElement("Square", {
                        Size = Vector2.new(UI_SIZES.ElementHeight - 10, UI_SIZES.ElementHeight - 10),
                        Position = togglePosition,
                        Color = default and UI_THEME.ToggleEnabled or UI_THEME.ToggleDisabled,
                        Filled = true,
                        Thickness = 0,
                        Visible = true,
                        Transparency = 0.95,
                    }),
                    
                    Text = CreateElement("Text", {
                        Text = name,
                        Size = 14,
                        Center = false,
                        Outline = false,
                        Position = Vector2.new(togglePosition.X + UI_SIZES.ElementHeight, togglePosition.Y + 2),
                        Color = UI_THEME.Text,
                        Font = UI_FONTS.Main,
                        Visible = true,
                        Transparency = 1,
                    }),
                    
                    Indicator = CreateElement("Square", {
                        Size = Vector2.new(UI_SIZES.ElementHeight - 14, UI_SIZES.ElementHeight - 14),
                        Position = Vector2.new(togglePosition.X + 2, togglePosition.Y + 2),
                        Color = UI_THEME.Accent,
                        Filled = true,
                        Thickness = 0,
                        Visible = default,
                        Transparency = 0.95,
                    }),
                }
                
                -- Toggle methods
                function toggle:SetValue(value)
                    self.Value = value
                    self.Indicator.Visible = value
                    self.Background.Color = value and UI_THEME.ToggleEnabled or UI_THEME.ToggleDisabled
                    
                    -- Animate toggle
                    if value then
                        ANIMATION.Pulse(self.Background, 0.3, 1.05)
                    end
                    
                    self.Callback(value)
                end
                
                -- Handle toggle click
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mousePos = UserInputService:GetMouseLocation()
                        if mousePos.X >= toggle.Background.Position.X and mousePos.X <= toggle.Background.Position.X + toggle.Background.Size.X and
                           mousePos.Y >= toggle.Background.Position.Y and mousePos.Y <= toggle.Background.Position.Y + toggle.Background.Size.Y then
                            toggle:SetValue(not toggle.Value)
                        end
                    end
                end)
                
                table.insert(self.Elements, toggle)
                return toggle
            end
            
            function section:AddSlider(name, min, max, default, increment, callback)
                local elementCount = #self.Elements
                local sliderPosition = Vector2.new(
                    self.Position.X + 15,
                    self.Position.Y + 35 + (elementCount * (UI_SIZES.ElementHeight + UI_SIZES.ElementPadding))
                )
                
                min = min or 0
                max = max or 100
                default = default or min
                increment = increment or 1
                
                -- Calculate slider values
                local sliderWidth = self.Size.X - 30
                local sliderHeight = UI_SIZES.ElementHeight - 10
                local valueRange = max - min
                local valueRatio = (default - min) / valueRange
                local fillWidth = sliderWidth * valueRatio
                
                local slider = {
                    Name = name,
                    Value = default,
                    Min = min,
                    Max = max,
                    Increment = increment,
                    Dragging = false,
                    Callback = callback or function() end,
                    
                    -- Drawing objects
                    Text = CreateElement("Text", {
                        Text = name .. ": " .. tostring(default),
                        Size = 14,
                        Center = false,
                        Outline = false,
                        Position = Vector2.new(sliderPosition.X, sliderPosition.Y - 18),
                        Color = UI_THEME.Text,
                        Font = UI_FONTS.Main,
                        Visible = true,
                        Transparency = 1,
                    }),
                    
                    Background = CreateElement("Square", {
                        Size = Vector2.new(sliderWidth, sliderHeight),
                        Position = sliderPosition,
                        Color = UI_THEME.SliderBackground,
                        Filled = true,
                        Thickness = 0,
                        Visible = true,
                        Transparency = 0.95,
                    }),
                    
                    Fill = CreateElement("Square", {
                        Size = Vector2.new(fillWidth, sliderHeight),
                        Position = sliderPosition,
                        Color = UI_THEME.SliderFill,
                        Filled = true,
                        Thickness = 0,
                        Visible = true,
                        Transparency = 0.95,
                    }),
                    
                    Knob = CreateElement("Square", {
                        Size = Vector2.new(sliderHeight, sliderHeight),
                        Position = Vector2.new(sliderPosition.X + fillWidth - sliderHeight/2, sliderPosition.Y),
                        Color = UI_THEME.Accent,
                        Filled = true,
                        Thickness = 0,
                        Visible = true,
                        Transparency = 0.95,
                    }),
                }
                
                -- Slider methods
                function slider:SetValue(value)
                    -- Clamp and round value to increment
                    value = math.clamp(value, self.Min, self.Max)
                    value = self.Min + (math.round((value - self.Min) / self.Increment) * self.Increment)
                    value = RoundNumber(value, 2)
                    
                    self.Value = value
                    self.Text.Text = self.Name .. ": " .. tostring(self.Value)
                    
                    -- Update slider visuals
                    local valueRatio = (value - self.Min) / (self.Max - self.Min)
                    local fillWidth = self.Background.Size.X * valueRatio
                    
                    self.Fill.Size = Vector2.new(fillWidth, self.Fill.Size.Y)
                    self.Knob.Position = Vector2.new(self.Background.Position.X + fillWidth - self.Knob.Size.X/2, self.Knob.Position.Y)
                    
                    self.Callback(value)
                end
                
                -- Handle slider interaction
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mousePos = UserInputService:GetMouseLocation()
                        if mousePos.X >= slider.Background.Position.X and mousePos.X <= slider.Background.Position.X + slider.Background.Size.X and
                           mousePos.Y >= slider.Background.Position.Y and mousePos.Y <= slider.Background.Position.Y + slider.Background.Size.Y then
                            slider.Dragging = true
                            
                            -- Calculate and set value based on mouse position
                            local relativeX = mousePos.X - slider.Background.Position.X
                            local valueRatio = math.clamp(relativeX / slider.Background.Size.X, 0, 1)
                            local value = slider.Min + (valueRatio * (slider.Max - slider.Min))
                            slider:SetValue(value)
                        end
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        slider.Dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if slider.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mousePos = UserInputService:GetMouseLocation()
                        local relativeX = mousePos.X - slider.Background.Position.X
                        local valueRatio = math.clamp(relativeX / slider.Background.Size.X, 0, 1)
                        local value = slider.Min + (valueRatio * (slider.Max - slider.Min))
                        slider:SetValue(value)
                    end
                end)
                
                table.insert(self.Elements, slider)
                return slider
            end
            
            function section:AddButton(name, callback)
                local elementCount = #self.Elements
                local buttonPosition = Vector2.new(
                    self.Position.X + 15,
                    self.Position.Y + 35 + (elementCount * (UI_SIZES.ElementHeight + UI_SIZES.ElementPadding))
                )
                
                local buttonWidth = self.Size.X - 30
                
                local button = {
                    Name = name,
                    Callback = callback or function() end,
                    Hovering = false,
                    
                    -- Drawing objects
                    Background = CreateElement("Square", {
                        Size = Vector2.new(buttonWidth, UI_SIZES.ElementHeight),
                        Position = buttonPosition,
                        Color = UI_THEME.ButtonBackground,
                        Filled = true,
                        Thickness = 0,
                        Visible = true,
                        Transparency = 0.95,
                    }),
                    
                    Text = CreateElement("Text", {
                        Text = name,
                        Size = 14,
                        Center = true,
                        Outline = false,
                        Position = Vector2.new(buttonPosition.X + buttonWidth/2, buttonPosition.Y + UI_SIZES.ElementHeight/2 - 7),
                        Color = UI_THEME.Text,
                        Font = UI_FONTS.Main,
                        Visible = true,
                        Transparency = 1,
                    }),
                }
                
                -- Handle button interaction
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mousePos = UserInputService:GetMouseLocation()
                        if mousePos.X >= button.Background.Position.X and mousePos.X <= button.Background.Position.X + button.Background.Size.X and
                           mousePos.Y >= button.Background.Position.Y and mousePos.Y <= button.Background.Position.Y + button.Background.Size.Y then
                            
                            -- Animate button press
                            button.Background.Color = UI_THEME.Accent
                            ANIMATION.Pulse(button.Background, 0.3, 1.02)
                            
                            -- Call callback after short delay for visual feedback
                            task.delay(0.1, function()
                                button.Background.Color = button.Hovering and UI_THEME.ButtonHover or UI_THEME.ButtonBackground
                                button.Callback()
                            end)
                        end
                    end
                end)
                
                -- Handle button hover
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mousePos = UserInputService:GetMouseLocation()
                        local isHovering = mousePos.X >= button.Background.Position.X and mousePos.X <= button.Background.Position.X + button.Background.Size.X and
                                          mousePos.Y >= button.Background.Position.Y and mousePos.Y <= button.Background.Position.Y + button.Background.Size.Y
                        
                        if isHovering ~= button.Hovering then
                            button.Hovering = isHovering
                            button.Background.Color = isHovering and UI_THEME.ButtonHover or UI_THEME.ButtonBackground
                        end
                    end
                end)
                
                table.insert(self.Elements, button)
                return button
            end
            
            function section:AddLabel(text)
                local elementCount = #self.Elements
                local labelPosition = Vector2.new(
                    self.Position.X + 15,
                    self.Position.Y + 35 + (elementCount * (UI_SIZES.ElementHeight + UI_SIZES.ElementPadding))
                )
                
                local label = {
                    Text = text,
                    
                    -- Drawing objects
                    TextObject = CreateElement("Text", {
                        Text = text,
                        Size = 14,
                        Center = false,
                        Outline = false,
                        Position = labelPosition,
                        Color = UI_THEME.Text,
                        Font = UI_FONTS.Main,
                        Visible = true,
                        Transparency = 1,
                    }),
                }
                
                -- Label methods
                function label:SetText(newText)
                    self.Text = newText
                    self.TextObject.Text = newText
                end
                
                table.insert(self.Elements, label)
                return label
            end
            
            function section:AddColorPicker(name, default, callback)
                local elementCount = #self.Elements
                local pickerPosition = Vector2.new(
                    self.Position.X + 15,
                    self.Position.Y + 35 + (elementCount * (UI_SIZES.ElementHeight + UI_SIZES.ElementPadding))
                )
                
                default = default or Color3.fromRGB(255, 255, 255)
                
                -- Convert default color to HSV
                local h, s, v = default:ToHSV()
                
                -- Create HSV picker elements (hidden by default)
                local hsvPanel = CreateElement("Square", {
                    Size = Vector2.new(180, 200),
                    Position = Vector2.new(pickerPosition.X + 100, pickerPosition.Y + 30),
                    Color = UI_THEME.SectionBackground,
                    Filled = true,
                    Thickness = 0,
                    Visible = false,
                    Transparency = 0.95,
                })
                
                -- Color gradient (saturation/value)
                local svGradient = CreateElement("Square", {
                    Size = Vector2.new(150, 150),
                    Position = Vector2.new(hsvPanel.Position.X + 15, hsvPanel.Position.Y + 10),
                    Color = Color3.fromHSV(h, 1, 1), -- Base color at full saturation/value
                    Filled = true,
                    Thickness = 0,
                    Visible = false,
                    Transparency = 0.95,
                })
                
                -- Hue slider
                local hueSlider = CreateElement("Square", {
                    Size = Vector2.new(150, 20),
                    Position = Vector2.new(hsvPanel.Position.X + 15, hsvPanel.Position.Y + 170),
                    Color = UI_THEME.SliderBackground,
                    Filled = true,
                    Thickness = 0,
                    Visible = false,
                    Transparency = 0.95,
                })
                
                -- Hue slider colors (rainbow gradient)
                local hueColors = {}
                for i = 0, 5 do
                    local hueColor = CreateElement("Square", {
                        Size = Vector2.new(30, 20),
                        Position = Vector2.new(hueSlider.Position.X + (i * 30), hueSlider.Position.Y),
                        Color = Color3.fromHSV(i/6, 1, 1),
                        Filled = true,
                        Thickness = 0,
                        Visible = false,
                        Transparency = 0.95,
                    })
                    table.insert(hueColors, hueColor)
                end
                
                -- Hue slider knob
                local hueKnob = CreateElement("Square", {
                    Size = Vector2.new(5, 20),
                    Position = Vector2.new(hueSlider.Position.X + (h * 150), hueSlider.Position.Y),
                    Color = UI_THEME.Accent,
                    Filled = true,
                    Thickness = 0,
                    Visible = false,
                    Transparency = 0.95,
                })
                
                -- SV selector (circle)
                local svSelector = CreateElement("Circle", {
                    Radius = 5,
                    Position = Vector2.new(
                        svGradient.Position.X + (s * svGradient.Size.X),
                        svGradient.Position.Y + ((1-v) * svGradient.Size.Y)
                    ),
                    Color = Color3.new(1, 1, 1),
                    Filled = true,
                    Thickness = 0,
                    Transparency = 0.95,
                    NumSides = 12,
                    Visible = false,
                })
                
                -- Apply button
                local applyButton = CreateElement("Square", {
                    Size = Vector2.new(70, 25),
                    Position = Vector2.new(hsvPanel.Position.X + 15, hsvPanel.Position.Y + 170),
                    Color = UI_THEME.ButtonBackground,
                    Filled = true,
                    Thickness = 0,
                    Visible = false,
                    Transparency = 0.95,
                })
                
                local applyText = CreateElement("Text", {
                    Text = "Apply",
                    Size = 14,
                    Center = true,
                    Outline = false,
                    Position = Vector2.new(applyButton.Position.X + applyButton.Size.X / 2, applyButton.Position.Y + 5),
                    Color = UI_THEME.Text,
                    Font = UI_FONTS.Main,
                    Transparency = 1,
                    Visible = false,
                })
                
                -- Main color picker display
                local colorPicker = {
                    Name = name,
                    Value = default,
                    Callback = callback or function() end,
                    Open = false,
                    
                    -- HSV values
                    H = h,
                    S = s,
                    V = v,
                    
                    -- State
                    DraggingHue = false,
                    DraggingSV = false,
                    
                    -- Drawing objects
                    Text = CreateElement("Text", {
                        Text = name,
                        Size = 14,
                        Center = false,
                        Outline = false,
                        Position = Vector2.new(pickerPosition.X, pickerPosition.Y + 2),
                        Color = UI_THEME.Text,
                        Font = UI_FONTS.Main,
                        Visible = true,
                        Transparency = 1,
                    }),
                    
                    Display = CreateElement("Square", {
                        Size = Vector2.new(UI_SIZES.ElementHeight - 10, UI_SIZES.ElementHeight - 10),
                        Position = Vector2.new(self.Size.X - 40, pickerPosition.Y),
                        Color = default,
                        Filled = true,
                        Thickness = 0,
                        Visible = true,
                        Transparency = 0.95,
                    }),
                    
                    Border = CreateElement("Square", {
                        Size = Vector2.new(UI_SIZES.ElementHeight - 8, UI_SIZES.ElementHeight - 8),
                        Position = Vector2.new(self.Size.X - 41, pickerPosition.Y - 1),
                        Color = UI_THEME.Text,
                        Filled = false,
                        Thickness = 1,
                        Visible = true,
                        Transparency = 0.5,
                    }),
                    
                    -- HSV picker elements
                    HSVPanel = hsvPanel,
                    SVGradient = svGradient,
                    HueSlider = hueSlider,
                    HueColors = hueColors,
                    HueKnob = hueKnob,
                    SVSelector = svSelector,
                    ApplyButton = applyButton,
                    ApplyText = applyText,
                }
                
                -- Color picker methods
                function colorPicker:SetValue(color)
                    self.Value = color
                    self.Display.Color = color
                    self.H, self.S, self.V = color:ToHSV()
                    self.Callback(color)
                end
                
                function colorPicker:UpdateFromHSV()
                    local color = Color3.fromHSV(self.H, self.S, self.V)
                    self.Value = color
                    self.Display.Color = color
                    
                    -- Update gradient base color
                    self.SVGradient.Color = Color3.fromHSV(self.H, 1, 1)
                    
                    -- Update knob positions
                    self.HueKnob.Position = Vector2.new(
                        self.HueSlider.Position.X + (self.H * self.HueSlider.Size.X),
                        self.HueSlider.Position.Y
                    )
                    
                    self.SVSelector.Position = Vector2.new(
                        self.SVGradient.Position.X + (self.S * self.SVGradient.Size.X),
                        self.SVGradient.Position.Y + ((1-self.V) * self.SVGradient.Size.Y)
                    )
                end
                
                function colorPicker:ToggleHSVPanel()
                    self.Open = not self.Open
                    
                    -- Toggle visibility of HSV panel elements
                    self.HSVPanel.Visible = self.Open
                    self.SVGradient.Visible = self.Open
                    self.HueSlider.Visible = self.Open
                    self.SVSelector.Visible = self.Open
                    self.HueKnob.Visible = self.Open
                    self.ApplyButton.Visible = self.Open
                    self.ApplyText.Visible = self.Open
                    
                    for _, hueColor in ipairs(self.HueColors) do
                        hueColor.Visible = self.Open
                    end
                    
                    -- Animate panel opening/closing
                    if self.Open then
                        ANIMATION.FadeIn(self.HSVPanel, 0.3)
                    else
                        ANIMATION.FadeOut(self.HSVPanel, 0.3)
                    end
                end
                
                -- Handle color picker interactions
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mousePos = UserInputService:GetMouseLocation()
                        
                        -- Check if main display is clicked
                        if mousePos.X >= colorPicker.Display.Position.X and 
                           mousePos.X <= colorPicker.Display.Position.X + colorPicker.Display.Size.X and
                           mousePos.Y >= colorPicker.Display.Position.Y and 
                           mousePos.Y <= colorPicker.Display.Position.Y + colorPicker.Display.Size.Y then
                            
                            colorPicker:ToggleHSVPanel()
                            ANIMATION.Pulse(colorPicker.Display, 0.3, 1.1)
                        
                        -- Check if HSV panel is open and elements are clicked
                        elseif colorPicker.Open then
                            -- Check if hue slider is clicked
                            if mousePos.X >= colorPicker.HueSlider.Position.X and 
                               mousePos.X <= colorPicker.HueSlider.Position.X + colorPicker.HueSlider.Size.X and
                               mousePos.Y >= colorPicker.HueSlider.Position.Y and 
                               mousePos.Y <= colorPicker.HueSlider.Position.Y + colorPicker.HueSlider.Size.Y then
                                
                                colorPicker.DraggingHue = true
                                
                                -- Update hue based on click position
                                local relativeX = mousePos.X - colorPicker.HueSlider.Position.X
                                colorPicker.H = math.clamp(relativeX / colorPicker.HueSlider.Size.X, 0, 1)
                                colorPicker:UpdateFromHSV()
                            
                            -- Check if SV gradient is clicked
                            elseif mousePos.X >= colorPicker.SVGradient.Position.X and 
                                   mousePos.X <= colorPicker.SVGradient.Position.X + colorPicker.SVGradient.Size.X and
                                   mousePos.Y >= colorPicker.SVGradient.Position.Y and 
                                   mousePos.Y <= colorPicker.SVGradient.Position.Y + colorPicker.SVGradient.Size.Y then
                                
                                colorPicker.DraggingSV = true
                                
                                -- Update saturation and value based on click position
                                local relativeX = mousePos.X - colorPicker.SVGradient.Position.X
                                local relativeY = mousePos.Y - colorPicker.SVGradient.Position.Y
                                
                                colorPicker.S = math.clamp(relativeX / colorPicker.SVGradient.Size.X, 0, 1)
                                colorPicker.V = math.clamp(1 - (relativeY / colorPicker.SVGradient.Size.Y), 0, 1)
                                colorPicker:UpdateFromHSV()
                            
                            -- Check if apply button is clicked
                            elseif mousePos.X >= colorPicker.ApplyButton.Position.X and 
                                   mousePos.X <= colorPicker.ApplyButton.Position.X + colorPicker.ApplyButton.Size.X and
                                   mousePos.Y >= colorPicker.ApplyButton.Position.Y and 
                                   mousePos.Y <= colorPicker.ApplyButton.Position.Y + colorPicker.ApplyButton.Size.Y then
                                
                                colorPicker:SetValue(Color3.fromHSV(colorPicker.H, colorPicker.S, colorPicker.V))
                                colorPicker:ToggleHSVPanel()
                                colorPicker.Callback(colorPicker.Value)
                                ANIMATION.Pulse(colorPicker.Display, 0.3, 1.1)
                            end
                        end
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mousePos = UserInputService:GetMouseLocation()
                        
                        -- Update while dragging hue slider
                        if colorPicker.DraggingHue then
                            local relativeX = mousePos.X - colorPicker.HueSlider.Position.X
                            colorPicker.H = math.clamp(relativeX / colorPicker.HueSlider.Size.X, 0, 1)
                            colorPicker:UpdateFromHSV()
                        
                        -- Update while dragging SV gradient
                        elseif colorPicker.DraggingSV then
                            local relativeX = mousePos.X - colorPicker.SVGradient.Position.X
                            local relativeY = mousePos.Y - colorPicker.SVGradient.Position.Y
                            
                            colorPicker.S = math.clamp(relativeX / colorPicker.SVGradient.Size.X, 0, 1)
                            colorPicker.V = math.clamp(1 - (relativeY / colorPicker.SVGradient.Size.Y), 0, 1)
                            colorPicker:UpdateFromHSV()
                        end
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        colorPicker.DraggingHue = false
                        colorPicker.DraggingSV = false
                    end
                end)
                
                table.insert(self.Elements, colorPicker)
                return colorPicker
            end
            
            function section:AddDropdown(name, options, default, callback)
                local elementCount = #self.Elements
                local dropdownPosition = Vector2.new(
                    self.Position.X + 15,
                    self.Position.Y + 35 + (elementCount * (UI_SIZES.ElementHeight + UI_SIZES.ElementPadding))
                )
                
                options = options or {}
                default = default or (options[1] or "")
                
                local dropdownWidth = self.Size.X - 30
                
                local dropdown = {
                    Name = name,
                    Value = default,
                    Options = options,
                    Callback = callback or function() end,
                    Open = false,
                    
                    -- Drawing objects
                    Text = CreateElement("Text", {
                        Text = name,
                        Size = 14,
                        Center = false,
                        Outline = false,
                        Position = Vector2.new(dropdownPosition.X, dropdownPosition.Y - 18),
                        Color = UI_THEME.Text,
                        Font = UI_FONTS.Main,
                        Visible = true,
                        Transparency = 1,
                    }),
                    
                    Background = CreateElement("Square", {
                        Size = Vector2.new(dropdownWidth, UI_SIZES.ElementHeight),
                        Position = dropdownPosition,
                        Color = UI_THEME.ButtonBackground,
                        Filled = true,
                        Thickness = 0,
                        Visible = true,
                        Transparency = 0.95,
                    }),
                    
                    SelectedText = CreateElement("Text", {
                        Text = default,
                        Size = 14,
                        Center = false,
                        Outline = false,
                        Position = Vector2.new(dropdownPosition.X + 10, dropdownPosition.Y + UI_SIZES.ElementHeight/2 - 7),
                        Color = UI_THEME.Text,
                        Font = UI_FONTS.Main,
                        Visible = true,
                        Transparency = 1,
                    }),
                    
                    Arrow = CreateElement("Text", {
                        Text = "▼",
                        Size = 14,
                        Center = false,
                        Outline = false,
                        Position = Vector2.new(dropdownPosition.X + dropdownWidth - 20, dropdownPosition.Y + UI_SIZES.ElementHeight/2 - 7),
                        Color = UI_THEME.Text,
                        Font = UI_FONTS.Main,
                        Visible = true,
                        Transparency = 1,
                    }),
                    
                    OptionContainer = CreateElement("Square", {
                        Size = Vector2.new(dropdownWidth, 0), -- Will be updated when opened
                        Position = Vector2.new(dropdownPosition.X, dropdownPosition.Y + UI_SIZES.ElementHeight),
                        Color = UI_THEME.ButtonBackground,
                        Filled = true,
                        Thickness = 0,
                        Visible = false,
                        Transparency = 0.95,
                    }),
                    
                    OptionTexts = {},
                    OptionBackgrounds = {},
                }
                
                -- Create option elements (hidden initially)
                for i, option in ipairs(options) do
                    local optionPosition = Vector2.new(
                        dropdownPosition.X,
                        dropdownPosition.Y + UI_SIZES.ElementHeight + ((i-1) * UI_SIZES.ElementHeight)
                    )
                    
                    local optionBackground = CreateElement("Square", {
                        Size = Vector2.new(dropdownWidth, UI_SIZES.ElementHeight),
                        Position = optionPosition,
                        Color = UI_THEME.ButtonBackground,
                        Filled = true,
                        Thickness = 0,
                        Visible = false,
                        Transparency = 0.95,
                    })
                    
                    local optionText = CreateElement("Text", {
                        Text = option,
                        Size = 14,
                        Center = false,
                        Outline = false,
                        Position = Vector2.new(optionPosition.X + 10, optionPosition.Y + UI_SIZES.ElementHeight/2 - 7),
                        Color = UI_THEME.Text,
                        Font = UI_FONTS.Main,
                        Visible = false,
                        Transparency = 1,
                    })
                    
                    table.insert(dropdown.OptionBackgrounds, optionBackground)
                    table.insert(dropdown.OptionTexts, optionText)
                end
                
                -- Dropdown methods
                function dropdown:SetValue(value)
                    if table.find(self.Options, value) then
                        self.Value = value
                        self.SelectedText.Text = value
                        self.Callback(value)
                    end
                end
                
                function dropdown:Toggle()
                    self.Open = not self.Open
                    
                    -- Update arrow
                    self.Arrow.Text = self.Open and "▲" or "▼"
                    
                    -- Show/hide options
                    self.OptionContainer.Visible = self.Open
                    self.OptionContainer.Size = Vector2.new(dropdownWidth, #self.Options * UI_SIZES.ElementHeight)
                    
                    for i = 1, #self.Options do
                        self.OptionBackgrounds[i].Visible = self.Open
                        self.OptionTexts[i].Visible = self.Open
                    end
                    
                    -- Animate dropdown
                    if self.Open then
                        ANIMATION.ScaleIn(self.OptionContainer, 0.2)
                    end
                end
                
                -- Handle dropdown click
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mousePos = UserInputService:GetMouseLocation()
                        
                        -- Check if clicked on dropdown header
                        if mousePos.X >= dropdown.Background.Position.X and mousePos.X <= dropdown.Background.Position.X + dropdown.Background.Size.X and
                           mousePos.Y >= dropdown.Background.Position.Y and mousePos.Y <= dropdown.Background.Position.Y + dropdown.Background.Size.Y then
                            dropdown:Toggle()
                        elseif dropdown.Open then
                            -- Check if clicked on an option
                            for i, option in ipairs(dropdown.Options) do
                                if mousePos.X >= dropdown.OptionBackgrounds[i].Position.X and mousePos.X <= dropdown.OptionBackgrounds[i].Position.X + dropdown.OptionBackgrounds[i].Size.X and
                                   mousePos.Y >= dropdown.OptionBackgrounds[i].Position.Y and mousePos.Y <= dropdown.OptionBackgrounds[i].Position.Y + dropdown.OptionBackgrounds[i].Size.Y then
                                    dropdown:SetValue(option)
                                    dropdown:Toggle() -- Close dropdown after selection
                                    break
                                end
                            end
                        end
                    end
                end)
                
                table.insert(self.Elements, dropdown)
                return dropdown
            end
            
            table.insert(self.Elements, section)
            return section
        end
        
        table.insert(self.Tabs, tab)
        
        -- Set first tab as active by default
        if tabIndex == 1 then
            self:SelectTab(1)
        end
        
        return tab
    end
    
    function window:SelectTab(index)
        -- Hide all tabs
        for i, tab in ipairs(self.Tabs) do
            tab.Background.Color = UI_THEME.TabInactive
            tab.Content.Visible = false
        end
        
        -- Show selected tab
        local selectedTab = self.Tabs[index]
        if selectedTab then
            selectedTab.Background.Color = UI_THEME.TabActive
            selectedTab.Content.Visible = true
            self.ActiveTab = index
            
            -- Animate tab selection
            ANIMATION.Pulse(selectedTab.Background, 0.3, 1.02)
        end
    end
    
    function window:UpdatePosition(newPosition)
        local deltaX = newPosition.X - self.Position.X
        local deltaY = newPosition.Y - self.Position.Y
        
        -- Update window position
        self.Position = newPosition
        self.Background.Position = newPosition
        self.TitleBar.Position = newPosition
        self.TitleText.Position = Vector2.new(newPosition.X + 10, newPosition.Y + 6)
        self.CloseButton.Position = Vector2.new(newPosition.X + self.Size.X - 25, newPosition.Y + 5)
        self.MinimizeButton.Position = Vector2.new(newPosition.X + self.Size.X - 50, newPosition.Y + 5)
        self.TabContainer.Position = Vector2.new(newPosition.X, newPosition.Y + 30)
        self.ContentContainer.Position = Vector2.new(newPosition.X, newPosition.Y + 30 + UI_SIZES.TabHeight)
        
        -- Update tabs positions
        for i, tab in ipairs(self.Tabs) do
            local tabWidth = 100
            tab.Background.Position = Vector2.new(newPosition.X + (i - 1) * tabWidth, newPosition.Y + 30)
            tab.Text.Position = Vector2.new(tab.Background.Position.X + tabWidth/2, tab.Background.Position.Y + UI_SIZES.TabHeight/2 - 7)
            tab.Content.Position = Vector2.new(newPosition.X + 10, newPosition.Y + 30 + UI_SIZES.TabHeight + 5)
            
            -- Update section positions
            for _, section in ipairs(tab.Elements) do
                section.Position = Vector2.new(section.Position.X + deltaX, section.Position.Y + deltaY)
                section.Background.Position = section.Position
                section.TitleText.Position = Vector2.new(section.Position.X + 10, section.Position.Y + 5)
                section.Divider.Position = Vector2.new(section.Position.X + 10, section.Position.Y + 25)
                
                -- Update elements in section (will be implemented in next part)
            end
        end
    end
    
    -- Handle window dragging
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            if mousePos.X >= window.Position.X and mousePos.X <= window.Position.X + window.Size.X and
               mousePos.Y >= window.Position.Y and mousePos.Y <= window.Position.Y + 30 then
                window.Dragging = true
                window.DragOffset = Vector2.new(mousePos.X - window.Position.X, mousePos.Y - window.Position.Y)
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            window.Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if window.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            window:UpdatePosition(Vector2.new(mousePos.X - window.DragOffset.X, mousePos.Y - window.DragOffset.Y))
        end
    end)
    
    -- Handle close button
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            if mousePos.X >= window.CloseButton.Position.X and mousePos.X <= window.CloseButton.Position.X + window.CloseButton.Size.X and
               mousePos.Y >= window.CloseButton.Position.Y and mousePos.Y <= window.CloseButton.Position.Y + window.CloseButton.Size.Y then
                window.Visible = false
                window:SetVisibility(false)
            end
        end
    end)
    
    -- Handle minimize button
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            if mousePos.X >= window.MinimizeButton.Position.X and mousePos.X <= window.MinimizeButton.Position.X + window.MinimizeButton.Size.X and
               mousePos.Y >= window.MinimizeButton.Position.Y and mousePos.Y <= window.MinimizeButton.Position.Y + window.MinimizeButton.Size.Y then
                -- Toggle content visibility
                window.ContentContainer.Visible = not window.ContentContainer.Visible
                for _, tab in ipairs(window.Tabs) do
                    tab.Content.Visible = window.ContentContainer.Visible and tab == window.Tabs[window.ActiveTab]
                end
            end
        end
    end)
    
    function window:SetVisibility(visible)
        self.Visible = visible
        self.Background.Visible = visible
        self.TitleBar.Visible = visible
        self.TitleText.Visible = visible
        self.CloseButton.Visible = visible
        self.MinimizeButton.Visible = visible
        self.TabContainer.Visible = visible
        self.ContentContainer.Visible = visible
        
        for _, tab in ipairs(self.Tabs) do
            tab.Background.Visible = visible
            tab.Text.Visible = visible
            tab.Content.Visible = visible and tab == self.Tabs[self.ActiveTab]
            
            for _, section in ipairs(tab.Elements) do
                section.Background.Visible = visible and tab == self.Tabs[self.ActiveTab]
                section.TitleText.Visible = visible and tab == self.Tabs[self.ActiveTab]
                section.Divider.Visible = visible and tab == self.Tabs[self.ActiveTab]
                
                -- Hide section elements (will be implemented in next part)
            end
        end
    end
    
    return window
end

-- Initialize UI and connect to ESP functionality
local function InitializeUI()
    print("🎨 Initializing Enhanced UI...")
    local mainPanel = VisualInterface.CreateDisplayPanel("Universal ESP Pro Enhanced", Vector2.new(20, 20))
    
    -- Create categories
    local espCategory = mainPanel:CreateCategory("ESP")
    local settingsCategory = mainPanel:CreateCategory("Settings")
    local appearanceCategory = mainPanel:CreateCategory("Appearance")
    local aboutCategory = mainPanel:CreateCategory("About")
    
    -- ESP Category - Master Controls Module
    local masterModule = espCategory:AddModule("Master Controls")
    
    -- Master toggle for ESP
    local masterToggle = masterModule:AddToggle("ESP Enabled", ESPSettings.Enabled, function(value)
        ESPSettings.Enabled = value
        
        -- Update all ESP objects
        for _, esp in pairs(ESPObjects.Players) do
            ESPFunctions:SetESPEnabled(esp, value)
        end
        
        -- Show notification
        local notificationText = value and "ESP Enabled" or "ESP Disabled"
        local notificationColor = value and UI_THEME.Success or UI_THEME.Error
        
        -- Animate toggle
        ANIMATION.Pulse(masterToggle.Background, 0.3, 1.05)
    end)
    
    -- Team check toggle
    masterModule:AddToggle("Team Check", ESPSettings.TeamCheck, function(value)
        ESPSettings.TeamCheck = value
    end)
    
    -- Team color toggle
    masterModule:AddToggle("Use Team Colors", ESPSettings.TeamColor, function(value)
        ESPSettings.TeamColor = value
    end)
    
    -- Visibility check toggle
    masterModule:AddToggle("Visibility Check", ESPSettings.VisibilityCheck, function(value)
        ESPSettings.VisibilityCheck = value
    end)
    
    -- Max distance slider
    masterModule:AddSlider("Max Distance", 100, 5000, ESPSettings.MaxDistance, 100, function(value)
        ESPSettings.MaxDistance = value
    end)
    
    -- Refresh rate slider
    masterModule:AddSlider("Refresh Rate", 1, 60, ESPSettings.RefreshRate, 1, function(value)
        ESPSettings.RefreshRate = value
    end)
    
    -- ESP Category - Box ESP Module
    local boxModule = espCategory:AddModule("Box ESP", Vector2.new(espCategory.Content.Position.X + 10, espCategory.Content.Position.Y + 220))
    
    -- Box ESP toggle
    boxModule:AddToggle("Box ESP", ESPSettings.BoxESP.Enabled, function(value)
        ESPSettings.BoxESP.Enabled = value
        
        -- Update all ESP objects
        for _, esp in pairs(ESPObjects.Players) do
            for _, part in pairs(esp.Box) do
                if type(part) == "table" and part.Visible ~= nil then
                    part.Visible = value and ESPSettings.Enabled
                end
            end
        end
    end)
    
    -- Box filled toggle
    boxModule:AddToggle("Filled Box", ESPSettings.BoxESP.Filled, function(value)
        ESPSettings.BoxESP.Filled = value
        
        -- Update all ESP objects
        for _, esp in pairs(ESPObjects.Players) do
            esp.Box.Fill.Visible = value and ESPSettings.BoxESP.Enabled and ESPSettings.Enabled
        end
    end)
    
    -- Box thickness slider
    boxModule:AddSlider("Thickness", 1, 5, ESPSettings.BoxESP.Thickness, 0.1, function(value)
        ESPSettings.BoxESP.Thickness = value
        
        -- Update all ESP objects
        for _, esp in pairs(ESPObjects.Players) do
            for _, part in pairs(esp.Box) do
                if type(part) == "table" and part.Thickness ~= nil then
                    part.Thickness = value
                end
            end
        end
    end)
    
    -- Box transparency slider
    boxModule:AddSlider("Transparency", 0, 1, ESPSettings.BoxESP.Transparency, 0.05, function(value)
        ESPSettings.BoxESP.Transparency = value
        
        -- Update all ESP objects
        for _, esp in pairs(ESPObjects.Players) do
            for _, part in pairs(esp.Box) do
                if type(part) == "table" and part.Transparency ~= nil then
                    part.Transparency = value
                end
            end
            
            if esp.Box.Fill then
                esp.Box.Fill.Transparency = value + 0.5
            end
        end
    end)
    
    -- Box color picker
    boxModule:AddColorPicker("Box Color", ESPSettings.BoxESP.Color, function(color)
        ESPSettings.BoxESP.Color = color
        
        -- Only update if team colors are disabled
        if not ESPSettings.TeamColor then
            for _, esp in pairs(ESPObjects.Players) do
                for _, part in pairs(esp.Box) do
                    if type(part) == "table" and part.Color ~= nil then
                        part.Color = color
                    end
                end
            end
        end
    end)
    
    -- ESP Category - Tracer ESP Module
    local tracerModule = espCategory:AddModule("Tracer ESP", Vector2.new(espCategory.Content.Position.X + 10, espCategory.Content.Position.Y + 430))
    
    -- Tracer ESP toggle
    tracerModule:AddToggle("Tracer ESP", ESPSettings.TracerESP.Enabled, function(value)
        ESPSettings.TracerESP.Enabled = value
        
        -- Update all ESP objects
        for _, esp in pairs(ESPObjects.Players) do
            esp.Tracer.Visible = value and ESPSettings.Enabled
        end
    end)
    
    -- Tracer origin dropdown
    local tracerOrigins = {"Bottom", "Center", "Mouse"}
    local tracerOriginDropdown = tracerModule:AddDropdown("Tracer Origin", tracerOrigins, ESPSettings.TracerESP.Origin, function(value)
        ESPSettings.TracerESP.Origin = value
    end)
    
    -- Tracer thickness slider
    tracerModule:AddSlider("Thickness", 1, 5, ESPSettings.TracerESP.Thickness, 0.1, function(value)
        ESPSettings.TracerESP.Thickness = value
        
        -- Update all ESP objects
        for _, esp in pairs(ESPObjects.Players) do
            esp.Tracer.Thickness = value
        end
    end)
    
    -- Tracer transparency slider
    tracerModule:AddSlider("Transparency", 0, 1, ESPSettings.TracerESP.Transparency, 0.05, function(value)
        ESPSettings.TracerESP.Transparency = value
        
        -- Update all ESP objects
        for _, esp in pairs(ESPObjects.Players) do
            esp.Tracer.Transparency = value
        end
    end)
    
    -- Tracer color picker
    tracerModule:AddColorPicker("Tracer Color", ESPSettings.TracerESP.Color, function(color)
        ESPSettings.TracerESP.Color = color
        
        -- Only update if team colors are disabled
        if not ESPSettings.TeamColor then
            for _, esp in pairs(ESPObjects.Players) do
                esp.Tracer.Color = color
            end
        end
    end)
    
    -- Settings Category - Name ESP Module
    local nameModule = settingsCategory:AddModule("Name ESP")
    
    -- Name ESP toggle
    nameModule:AddToggle("Name ESP", ESPSettings.NameESP.Enabled, function(value)
        ESPSettings.NameESP.Enabled = value
        
        -- Update all ESP objects
        for _, esp in pairs(ESPObjects.Players) do
            esp.Name.Visible = value and ESPSettings.Enabled
        end
    end)
    
    -- Show distance toggle
    nameModule:AddToggle("Show Distance", ESPSettings.NameESP.ShowDistance, function(value)
        ESPSettings.NameESP.ShowDistance = value
    end)
    
    -- Show health toggle
    nameModule:AddToggle("Show Health", ESPSettings.NameESP.ShowHealth, function(value)
        ESPSettings.NameESP.ShowHealth = value
    end)
    
    -- Name outline toggle
    nameModule:AddToggle("Text Outline", ESPSettings.NameESP.Outline, function(value)
        ESPSettings.NameESP.Outline = value
        
        -- Update all ESP objects
        for _, esp in pairs(ESPObjects.Players) do
            esp.Name.Outline = value
        end
    end)
    
    -- Name size slider
    nameModule:AddSlider("Text Size", 8, 24, ESPSettings.NameESP.Size, 1, function(value)
        ESPSettings.NameESP.Size = value
        
        -- Update all ESP objects
        for _, esp in pairs(ESPObjects.Players) do
            esp.Name.Size = value
        end
    end)
    
    -- Name color picker
    nameModule:AddColorPicker("Text Color", ESPSettings.NameESP.Color, function(color)
        ESPSettings.NameESP.Color = color
        
        -- Only update if team colors are disabled
        if not ESPSettings.TeamColor then
            for _, esp in pairs(ESPObjects.Players) do
                esp.Name.Color = color
            end
        end
    end)
    
    -- Settings Category - Health ESP Module
    local healthModule = settingsCategory:AddModule("Health ESP", Vector2.new(settingsCategory.Content.Position.X + 10, settingsCategory.Content.Position.Y + 220))
    
    -- Health ESP toggle
    healthModule:AddToggle("Health ESP", ESPSettings.HealthESP.Enabled, function(value)
        ESPSettings.HealthESP.Enabled = value
        
        -- Update all ESP objects
        for _, esp in pairs(ESPObjects.Players) do
            esp.HealthBar.Visible = value and ESPSettings.HealthESP.ShowBar and ESPSettings.Enabled
            esp.HealthText.Visible = value and ESPSettings.HealthESP.ShowText and ESPSettings.Enabled
        end
    end)
    
    -- Show health bar toggle
    healthModule:AddToggle("Show Health Bar", ESPSettings.HealthESP.ShowBar, function(value)
        ESPSettings.HealthESP.ShowBar = value
        
        -- Update all ESP objects
        for _, esp in pairs(ESPObjects.Players) do
            esp.HealthBar.Visible = value and ESPSettings.HealthESP.Enabled and ESPSettings.Enabled
        end
    end)
    
    -- Show health text toggle
    healthModule:AddToggle("Show Health Text", ESPSettings.HealthESP.ShowText, function(value)
        ESPSettings.HealthESP.ShowText = value
        
        -- Update all ESP objects
        for _, esp in pairs(ESPObjects.Players) do
            esp.HealthText.Visible = value and ESPSettings.HealthESP.Enabled and ESPSettings.Enabled
        end
    end)
    
    -- Health bar thickness slider
    healthModule:AddSlider("Bar Thickness", 1, 5, ESPSettings.HealthESP.Thickness, 0.1, function(value)
        ESPSettings.HealthESP.Thickness = value
        
        -- Update all ESP objects
        for _, esp in pairs(ESPObjects.Players) do
            esp.HealthBar.Thickness = value
        end
    end)
    
    -- Appearance Category - UI Customization
    local uiModule = appearanceCategory:AddModule("UI Customization")
    
    -- UI Theme dropdown (simplified for now)
    local themes = {"Default", "Dark", "Light", "Discord", "Monokai"}
    uiModule:AddDropdown("UI Theme", themes, "Default", function(value)
        -- Theme switching would be implemented here
        ANIMATION.Pulse(mainPanel.PanelFrame, 0.5, 1.02)
    end)
    
    -- Rainbow mode toggle
    uiModule:AddToggle("Rainbow Mode", ESPSettings.Rainbow.Enabled, function(value)
        ESPSettings.Rainbow.Enabled = value
    end)
    
    -- Rainbow speed slider
    uiModule:AddSlider("Rainbow Speed", 0.1, 5, ESPSettings.Rainbow.Speed, 0.1, function(value)
        ESPSettings.Rainbow.Speed = value
    end)
    
    -- About Category
    local aboutModule = aboutCategory:AddModule("About")
    
    -- Version label
    aboutModule:AddLabel("Universal ESP Pro Enhanced v1.0")
    
    -- Credits label
    aboutModule:AddLabel("Created with ❤️ by ScriptB")
    
    -- DevCopy button
    aboutModule:AddButton("Copy Console Log", function()
        local success, result = DevCopy:CopyLog()
        if success then
            -- Show success notification
            print("✅ Console log copied to clipboard!")
        else
            -- Show error notification
            print("❌ Failed to copy console log: " .. tostring(result))
        end
    end)
    
    -- Unload button
    aboutModule:AddButton("Unload ESP", function()
        -- Clean up ESP objects
        ESPFunctions:CleanupESP()
        
        -- Hide UI
        mainPanel:SetVisibility(false)
        
        -- Show notification
        print("👋 ESP has been unloaded!")
    end)
    
    print("✅ Enhanced UI initialized!")
    return mainPanel
end

-- Main initialization
local function Initialize()
    print("🚀 Initializing Universal ESP Pro Enhanced...")
    
    -- Check if Drawing API is available
    if not Drawing then
        warn("❌ Drawing API not available! ESP cannot function.")
        return false
    end
    
    -- Initialize UI
    local mainInterface = InitializeUI()
    
    -- Set up keybinds
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftControl then
            mainInterface:SetVisibility(not mainInterface.Visible)
        elseif input.KeyCode == Enum.KeyCode.Delete then
            mainInterface:SetVisibility(false)
        end
    end)
    
    -- Set up player events
    ESPObjects.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            ESPFunctions:CreateESP(player)
        end
    end)
    
    ESPObjects.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        ESPFunctions:RemoveESP(player)
    end)
    
    -- Create ESP for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESPFunctions:CreateESP(player)
        end
    end
    
    -- Set up render loop
    ESPObjects.Connections.RenderStepped = RunService.RenderStepped:Connect(function()
        for _, esp in pairs(ESPObjects.Players) do
            ESPFunctions:UpdateESP(esp)
        end
        
        -- Rainbow mode
        if ESPSettings.Rainbow.Enabled then
            local hue = (tick() * ESPSettings.Rainbow.Speed) % 1
            local rainbowColor = Color3.fromHSV(hue, 1, 1)
            
            -- Apply rainbow color to all ESP objects
            for _, esp in pairs(ESPObjects.Players) do
                for _, part in pairs(esp.Box) do
                    if type(part) == "table" and part.Color ~= nil then
                        part.Color = rainbowColor
                    end
                end
                
                esp.Tracer.Color = rainbowColor
                esp.Name.Color = rainbowColor
            end
        end
    end)
    
    print("✅ Universal ESP Pro Enhanced initialized successfully!")
    return true
end

-- Make sure VisualInterface is defined before using it
if not VisualInterface or not VisualInterface.CreateDisplayPanel then
    warn("❌ VisualInterface not properly defined! Initializing default implementation...")
    
    -- Fallback implementation
    VisualInterface = {}
    VisualInterface.CreateDisplayPanel = function(title, position)
        local panel = {
            Title = title or "Universal ESP Pro Enhanced",
            Visible = true,
            Position = position or Vector2.new(20, 20),
            Size = Vector2.new(550, 400),
            Categories = {},
        }
        
        -- Basic panel methods
        function panel:SetVisibility(visible)
            self.Visible = visible
            -- Update visibility of all elements
        end
        
        function panel:CreateCategory(name)
            local category = {
                Name = name,
                Visible = false,
                Elements = {},
                AddModule = function(self, title)
                    local module = {
                        Title = title,
                        Elements = {},
                        AddToggle = function() return {} end,
                        AddSlider = function() return {} end,
                        AddDropdown = function() return {} end,
                        AddButton = function() return {} end,
                        AddLabel = function() return {} end,
                        AddColorPicker = function() return {} end,
                    }
                    return module
                end
            }
            table.insert(self.Categories, category)
            return category
        end
        
        return panel
    end
end

-- Start the ESP
local success = Initialize()

-- Export API to global environment
getgenv().UniversalESPEnhanced = {
    Settings = ESPSettings,
    UI = CustomUI,
    DevCopy = DevCopy,
    Toggle = function(enabled)
        ESPSettings.Enabled = enabled
    end
}

return getgenv().UniversalESPEnhanced
