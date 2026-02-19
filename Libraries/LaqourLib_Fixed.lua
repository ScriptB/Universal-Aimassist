-- LaqourLib - Fixed Version (No Asset Dependencies)
-- Patched to work without Roblox asset loading issues

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Debug,LocalPlayer = false,PlayerService.LocalPlayer

-- Create a virtual asset folder instead of loading from Roblox assets
local MainAssetFolder = Instance.new("Folder")
MainAssetFolder.Name = "LaqourV32"
MainAssetFolder.Parent = ReplicatedStorage

-- Create virtual asset structure
local function CreateVirtualAsset(path, assetType)
    local folder = MainAssetFolder
    for part in string.gmatch(path, "[^.]+") do
        if folder:FindFirstChild(part) then
            folder = folder[part]
        else
            local newFolder = Instance.new(assetType)
            newFolder.Name = part
            newFolder.Parent = folder
            folder = newFolder
        end
    end
    return folder
end

-- Create virtual assets for UI components
CreateVirtualAsset("Window", "Folder")
CreateVirtualAsset("Screen", "Folder")
CreateVirtualAsset("Notification", "Folder")
CreateVirtualAsset("NDHandle", "Folder")
CreateVirtualAsset("NLHandle", "Folder")

local function GetAsset(AssetPath)
    AssetPath = AssetPath:split("/")
    local Asset = MainAssetFolder
    for Index, Name in pairs(AssetPath) do
        if Asset[Name] then
            Asset = Asset[Name]
        else
            return nil
        end
    end
    return Asset:Clone()
end

local function GetLongest(A,B)
    return A > B and A or B
end

local function GetType(Object,Default,Type)
    if typeof(Object) == Type then
        return Object
    end
    return Default
end

local function MakeDraggable(Dragger,Object,Callback)
    local StartPosition,StartDrag = nil,nil
    Dragger.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            StartPosition = UserInputService:GetMouseLocation()
            StartDrag = Object.AbsolutePosition
        end
    end)
    UserInputService.InputChanged:Connect(function(Input)
        if StartDrag and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Mouse = UserInputService:GetMouseLocation()
            local Delta = Mouse - StartPosition
            StartPosition = Mouse
            Object.Position = Object.Position + UDim2.new(0,Delta.X,0,Delta.Y)
        end
    end)
    Dragger.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            StartPosition,StartDrag = nil,nil
            Callback(Object.Position)
        end
    end)
end

local function MakeResizeable(Dragger,Object,MinSize,Callback)
    local StartPosition,StartSize = nil,nil
    Dragger.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            StartPosition = UserInputService:GetMouseLocation()
            StartSize = Object.AbsoluteSize
        end
    end)
    UserInputService.InputChanged:Connect(function(Input)
        if StartPosition and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Mouse = UserInputService:GetMouseLocation()
            local Delta = Mouse - StartPosition
            local Size = StartSize + Delta
            local SizeX = math.max(MinSize.X,Size.X)
            local SizeY = math.max(MinSize.Y,Size.Y)
            Object.Size = UDim2.fromOffset(SizeX,SizeY)
        end
    end)
    Dragger.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            StartPosition,StartSize = nil,nil
            Callback(Object.Size)
        end
    end)
end

local function ChooseTab(ScreenAsset,TabButtonAsset,TabAsset)
    for Index,Instance in pairs(ScreenAsset:GetChildren()) do
        if Instance.Name == "Palette" or Instance.Name == "OptionContainer" then
            Instance.Visible = false
        end
    end
    for Index,Instance in pairs(ScreenAsset.Window.TabContainer:GetChildren()) do
        if Instance:IsA("ScrollingFrame") and Instance ~= TabAsset then
            Instance.Visible = false
        else
            Instance.Visible = true
        end
    end
    for Index,Instance in pairs(ScreenAsset.Window.TabButtonContainer:GetChildren()) do
        if Instance:IsA("TextButton") then
            Instance.Highlight.Visible = Instance == TabButtonAsset
        end
    end
end

local function ChooseTabSide(TabAsset,Mode)
    if Mode == "Longest" then
        if TabAsset.LeftSide.ListLayout.AbsoluteContentSize.Y > TabAsset.RightSide.ListLayout.AbsoluteContentSize.Y then
            return TabAsset.LeftSide
        else
            return TabAsset.RightSide
        end
    elseif Mode == "Left" then
        return TabAsset.LeftSide
    elseif Mode == "Right" then
        return TabAsset.RightSide
    else
        if TabAsset.LeftSide.ListLayout.AbsoluteContentSize.Y > TabAsset.RightSide.ListLayout.AbsoluteContentSize.Y then
            return TabAsset.RightSide
        else
            return TabAsset.LeftSide
        end
    end
end

local function GetConfigs(PFName)
    if not isfolder(PFName) then makefolder(PFName) end
    if not isfolder(PFName.."\\Configs") then makefolder(PFName.."\\Configs") end
    if not isfile(PFName.."\\DefaultConfig.txt") then writefile(PFName.."\\DefaultConfig.txt","") end

    local Configs = {}
    for Index,Config in pairs(listfiles(PFName.."\\Configs") or {}) do
        Config = Config:gsub(PFName.."\\Configs\\","")
        Config = Config:gsub(".json","")
        Configs[Index] = Config
    end
    return Configs
end

local function ConfigsToList(PFName)
    if not isfolder(PFName) then makefolder(PfName) end
    if not isfolder(PFName.."\\Configs") then makefolder(PFName.."\\Configs") end
    if not isfile(PFName.."\\DefaultConfig.txt") then writefile(PFName.."\\DefaultConfig.txt","") end

    local Configs = {}
    for Index,Config in pairs(listfiles(PFName.."\\Configs") or {}) do
        Config = Config:gsub(PFName.."\\Configs\\","")
        Config = Config:gsub(".json","")
        Configs[Index] = Config
    end
    return Configs
end

-- Create virtual UI elements dynamically instead of loading from assets
local function CreateVirtualUIElement(elementType, parent, properties)
    local element = Instance.new(elementType)
    element.Parent = parent
    
    for key, value in pairs(properties or {}) do
        if element[key] and type(element[key]) == "function" then
            element[key](value)
        elseif element[key] and type(element[key]) == "userdata" and value then
            element[key] = value
        elseif element[key] and type(element[key]) ~= "function" then
            element[key] = value
        end
    end
    
    return element
end

-- Laqour Library - Main API
local Laqour = {}

function Laqour:Window(config)
    config = config or {}
    local window = {}
    window.Name = config.Name or "Window"
    window.Color = config.Color or Color3.new(0, 0.7, 1)
    window.Size = config.Size or UDim2.new(0, 500, 0, 400)
    window.Position = config.Position or Udim2.new(0.5, -250, 0.5, -200)
    window.Tabs = {}
    window.CurrentTab = nil
    window.Elements = {}
    window.Flags = {}
    
    -- Create main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LaqourUI_" .. window.Name
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Create main frame
    local mainFrame = CreateVirtualUIElement("Frame", screenGui, {
        Size = window.Size,
        Position = window.Position,
        BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
        BorderSizePixel = 2,
        BorderColor3 = window.Color
    })
    
    -- Create title bar
    local titleBar = CreateVirtualUIElement("Frame", mainFrame, {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = window.Color,
        BorderSizePixel = 0
    })
    
    local titleLabel = CreateVirtualUIElement("TextLabel", titleBar, {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = window.Name,
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
        Font = Enum.Font.SourceSansBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local closeButton = CreateVirtualUIElement("TextButton", titleBar, {
        Size = UDim2.new(0, 50, 1, 0),
        Position = UDim2.new(1, -50, 0, 0),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
        Font = Enum.Font.SourceSansBold
    })
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        SimpleUI.CurrentWindow = nil
    end)
    
    -- Create tab container
    local tabContainer = CreateVirtualUIElement("Frame", mainFrame, {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
        BorderSizePixel = 0
    })
    
    local tabLayout = CreateVirtualUIElement("UIListLayout", tabContainer, {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Create content area
    local contentArea = CreateVirtualUIElement("Frame", mainFrame, {
        Size = UDim2.new(1, 0, 1, -70),
        Position = UDim2.new(0, 0, 0, 70),
        BackgroundColor3 = Color3.new(0.05, 0.05, 0.05),
        BorderSizePixel = 0
    })
    
    local scrollingFrame = CreateVirtualUIElement("ScrollingFrame", contentArea, {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.new(0.05, 0.05, 0.05),
        BorderSizePixel = 0,
        ScrollBarThickness = 8,
        ScrollBarImageColor3 = window.Color
    })
    
    local contentList = CreateVirtualUIElement("UIListLayout", scrollingFrame, {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim2.new(0, 10)
    })
    
    window.ScreenGui = screenGui
    window.MainFrame = mainFrame
    window.TabContainer = tabContainer
    window.ScrollingFrame = scrollingFrame
    window.ContentList = contentList
    
    function window:Tab(config)
        local tab = {}
        tab.Name = config.Name or "Tab"
        tab.Elements = {}
        
        -- Create tab button
        local tabButton = CreateVirtualUIElement("TextButton", window.TabContainer, {
            Size = UDim2.new(0, 100, 1, 0),
            BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
            BorderSizePixel = 0,
            Text = tab.Name,
            TextColor3 = Color3.new(0.8, 0.8, 0.8),
            TextScaled = true,
            Font = Enum.Font.SourceSans,
            LayoutOrder = #window.Tabs + 1
        })
        
        -- Create content frame
        local contentFrame = CreateVirtualUIElement("Frame", window.ScrollingFrame, {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Color3.new(0.05, 0.05, 0.05),
            BorderSizePixel = 0,
            Visible = false
        })
        
        local contentList = CreateVirtualUIElement("UIListLayout", contentFrame, {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim2.new(0, 5)
        })
        
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all content frames
            for _, existingTab in pairs(window.Tabs) do
                if existingTab.ContentFrame then
                    existingTab.ContentFrame.Visible = false
                end
                if existingTab.TabButton then
                    existingTab.TabButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
                    existingTab.TabButton.TextColor3 = Color3.new(0.8, 0.8, 0.8)
                end
            end
            
            -- Show this content frame
            contentFrame.Visible = true
            tabButton.BackgroundColor3 = window.Color
            tabButton.TextColor3 = Color3.new(1, 1, 1)
            window.CurrentTab = tab
        end)
        
        tab.TabButton = tabButton
        tab.ContentFrame = contentFrame
        tab.ContentList = contentList
        
        table.insert(window.Tabs, tab)
        
        -- Auto-select first tab
        if #window.Tabs == 1 then
            tabButton.BackgroundColor3 = window.Color
            tabButton.TextColor3 = Color3.new(1, 1, 1)
            contentFrame.Visible = true
            window.CurrentTab = tab
        end
        
        function tab:Divider(config)
            local divider = CreateVirtualUIElement("Frame", tab.ContentFrame, {
                Size = UDim2.new(1, 0, 0, 2),
                BackgroundColor3 = window.Color,
                BorderSizePixel = 0,
                LayoutOrder = #tab.Elements + 1
            })
            
            local label = CreateVirtualUIElement("TextLabel", divider, {
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = config.Text or "Divider",
                TextColor3 = Color3.new(1, 1, 1),
                TextScaled = true,
                Font = Enum.Font.SourceSans,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            table.insert(tab.Elements, divider)
            return divider
        end
        
        function tab:Label(config)
            local label = CreateVirtualUIElement("TextLabel", tab.ContentFrame, {
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
                BorderSizePixel = 0,
                Text = config.Text or "Label",
                TextColor3 = Color3.new(0.8, 0.8, 0.8),
                TextScaled = true,
                Font = Enum.Font.SourceSans,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = #tab.Elements + 1
            })
            
            table.insert(tab.Elements, label)
            return label
        end
        
        function tab:Toggle(config)
            local toggle = CreateVirtualUIElement("Frame", tab.ContentFrame, {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
                BorderSizePixel = 0,
                LayoutOrder = #tab.Elements + 1
            })
            
            local button = CreateVirtualUIElement("TextButton", toggle, {
                Size = UDim2.new(0, 25, 0, 25),
                Position = UDim2.new(0, 10, 0, 2.5),
                BackgroundColor3 = config.Value and window.Color or Color3.new(0.3, 0.3, 0.3),
                BorderSizePixel = 0,
                Text = "",
                Font = Enum.Font.SourceSans
            })
            
            local label = CreateVirtualUIElement("TextLabel", toggle, {
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 50, 0, 0),
                BackgroundTransparency = 1,
                Text = config.Name or "Toggle",
                TextColor3 = Color3.new(0.8, 0.8, 0.8),
                TextScaled = true,
                Font = Enum.Font.SourceSans,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local isOn = config.Value or false
            
            button.MouseButton1Click:Connect(function()
                isOn = not isOn
                button.BackgroundColor3 = isOn and window.Color or Color3.new(0.3, 0.3, 0.3)
                if config.Callback then
                    config.Callback(isOn)
                end
            end)
            
            table.insert(tab.Elements, toggle)
            return toggle
        end
        
        function tab:Slider(config)
            local slider = CreateVirtualUIElement("Frame", tab.ContentFrame, {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
                BorderSizePixel = 0,
                LayoutOrder = #tab.Elements + 1
            })
            
            local label = CreateVirtualUIElement("TextLabel", slider, {
                Size = UDim2.new(0, 200, 0, 20),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = config.Name .. ": " .. (config.Value or 0) .. (config.Unit or ""),
                TextColor3 = Color3.new(0.8, 0.8, 0.8),
                TextScaled = true,
                Font = Enum.Font.SourceSans,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local sliderBar = CreateVirtualUIElement("Frame", slider, {
                Size = UDim2.new(0, 200, 0, 4),
                Position = UDim2.new(0, 10, 0, 25),
                BackgroundColor3 = Color3.new(0.3, 0.3, 0.3),
                BorderSizePixel = 0
            })
            
            local sliderFill = CreateVirtualUIElement("Frame", sliderBar, {
                Size = UDim2.new(0, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = window.Color,
                BorderSizePixel = 0
            })
            
            local sliderButton = CreateVirtualUIElement("TextButton", sliderBar, {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Font = Enum.Font.SourceSans
            })
            
            local value = config.Value or (config.Min + config.Max) / 2
            
            local function updateSlider()
                local percent = (value - config.Min) / (config.Max - config.Min)
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                label.Text = config.Name .. ": " .. math.floor(value * (10 ^ (config.Precise or 0))) / (10 ^ (config.Precise or 0)) .. (config.Unit or "")
            end
            
            sliderButton.MouseButton1Down:Connect(function()
                local connection
                connection = game:GetService("UserInputService").InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                        value = config.Min + relativeX * (config.Max - config.Min)
                        updateSlider()
                        if config.Callback then
                            config.Callback(value)
                        end
                    end
                end)
                
                game:GetService("UserInputService").InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if connection then
                            connection:Disconnect()
                        end
                    end
                end)
            end)
            
            updateSlider()
            
            table.insert(tab.Elements, slider)
            return slider
        end
        
        function tab:Button(config)
            local button = CreateVirtualUIElement("TextButton", tab.ContentFrame, {
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundColor3 = window.Color,
                BorderSizePixel = 0,
                Text = config.Name or "Button",
                TextColor3 = Color3.new(1, 1, 1),
                TextScaled = true,
                Font = Enum.Font.SourceSans,
                LayoutOrder = #tab.Elements + 1
            })
            
            button.MouseButton1Click:Connect(function()
                if config.Callback then
                    config.Callback()
                end
            end)
            
            table.insert(tab.Elements, button)
            return button
        end
        
        return tab
    end
    
    return window
end

function Laqour:Notification(Notification)
    Notification = Notification or {}
    Notification.Title = Notification.Title or "Notification"
    Notification.Description = Notification.Description or ""
    
    local notification = CreateVirtualUIElement("ScreenGui", CoreGui, {
        Name = "LaqourNotification",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local frame = CreateVirtualUIElement("Frame", notification, {
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, -320, 0, 100),
        BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
        BorderSizePixel = 2,
        BorderColor3 = Color3.new(0, 0.7, 1)
        Active = true
    })
    
    local titleLabel = CreateVirtualUIElement("TextLabel", frame, {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = Notification.Title or "Notification",
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
        Font = Enum.Font.SourceSansBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local descLabel = CreateVirtualUIElement("TextLabel", frame, {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundTransparency = 1,
        Text = Notification.Description or "",
        TextColor3 = Color3.new(0.8, 0.8, 0.8),
        TextScaled = true,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    
    -- Auto-remove after 5 seconds
    game:GetService("Debris"):AddItem(notification, 5)
end

function Laqour:TableToColor(Table)
    if type(Table) ~= "table" then return Table end
    return Color3.fromHSV(Table[1], Table[2], Table[3])
end

return Laqour
