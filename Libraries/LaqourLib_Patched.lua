-- LaqourLib - Patched Version (No Asset Dependencies)
-- Fixed to work without Roblox asset loading issues

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Debug,LocalPlayer = false,PlayerService.LocalPlayer

-- Create virtual asset structure instead of loading from Roblox assets
local MainAssetFolder = Instance.new("Folder")
MainAssetFolder.Name = "LaqourV32"
MainAssetFolder.Parent = ReplicatedStorage

local function GetAsset(AssetPath)
    -- Return nil for all asset requests - we'll create UI elements dynamically
    return nil
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

-- Laqour Library - Main API
local Laqour = {}

function Laqour:Window(config)
    config = config or {}
    local window = {}
    window.Name = config.Name or "Window"
    window.Color = config.Color or Color3.new(0, 0.7, 1)
    window.Size = config.Size or UDim2.new(0, 500, 0, 400)
    window.Position = config.Position or UDim2.new(0.5, -250, 0.5, -200)
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
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.Size = window.Size
    mainFrame.Position = window.Position
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = window.Color
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    -- Create title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Parent = mainFrame
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = window.Color
    titleBar.BorderSizePixel = 0
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Parent = titleBar
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = window.Name
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "Close"
    closeButton.Parent = titleBar
    closeButton.Size = UDim2.new(0, 50, 1, 0)
    closeButton.Position = UDim2.new(1, -50, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Create tab container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Parent = mainFrame
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.Position = UDim2.new(0, 0, 0, 30)
    tabContainer.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    tabContainer.BorderSizePixel = 0
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = tabContainer
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Create content area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Parent = mainFrame
    contentArea.Size = UDim2.new(1, 0, 1, -70)
    contentArea.Position = UDim2.new(0, 0, 0, 70)
    contentArea.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
    contentArea.BorderSizePixel = 0
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Name = "ScrollingFrame"
    scrollingFrame.Parent = contentArea
    scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
    scrollingFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.ScrollBarThickness = 8
    scrollingFrame.ScrollBarImageColor3 = window.Color
    
    local contentList = Instance.new("UIListLayout")
    contentList.Parent = scrollingFrame
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Padding = UDim.new(0, 10)
    
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
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tab.Name
        tabButton.Parent = window.TabContainer
        tabButton.Size = UDim2.new(0, 100, 1, 0)
        tabButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        tabButton.BorderSizePixel = 0
        tabButton.Text = tab.Name
        tabButton.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        tabButton.TextScaled = true
        tabButton.Font = Enum.Font.SourceSans
        tabButton.LayoutOrder = #window.Tabs + 1
        
        -- Create content frame
        local contentFrame = Instance.new("Frame")
        contentFrame.Name = tab.Name .. "Content"
        contentFrame.Parent = window.ScrollingFrame
        contentFrame.Size = UDim2.new(1, 0, 0, 0)
        contentFrame.Position = UDim2.new(0, 0, 0, 0)
        contentFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
        contentFrame.BorderSizePixel = 0
        contentFrame.Visible = false
        
        local contentList = Instance.new("UIListLayout")
        contentList.Parent = contentFrame
        contentList.SortOrder = Enum.SortOrder.LayoutOrder
        contentList.Padding = UDim.new(0, 5)
        
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
            local divider = Instance.new("Frame")
            divider.Name = "Divider"
            divider.Parent = tab.ContentFrame
            divider.Size = UDim2.new(1, 0, 0, 2)
            divider.BackgroundColor3 = window.Color
            divider.BorderSizePixel = 0
            divider.LayoutOrder = #tab.Elements + 1
            
            local label = Instance.new("TextLabel")
            label.Name = "DividerLabel"
            label.Parent = divider
            label.Size = UDim2.new(1, -10, 1, 0)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = config.Text or "Divider"
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextScaled = true
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            table.insert(tab.Elements, divider)
            return divider
        end
        
        function tab:Label(config)
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Parent = tab.ContentFrame
            label.Size = UDim2.new(1, 0, 0, 25)
            label.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
            label.BorderSizePixel = 0
            label.Text = config.Text or "Label"
            label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
            label.TextScaled = true
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.LayoutOrder = #tab.Elements + 1
            
            table.insert(tab.Elements, label)
            return label
        end
        
        function tab:Toggle(config)
            local toggle = Instance.new("Frame")
            toggle.Name = "Toggle"
            toggle.Parent = tab.ContentFrame
            toggle.Size = UDim2.new(1, 0, 0, 30)
            toggle.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
            toggle.BorderSizePixel = 0
            toggle.LayoutOrder = #tab.Elements + 1
            
            local button = Instance.new("TextButton")
            button.Name = "Button"
            button.Parent = toggle
            button.Size = UDim2.new(0, 25, 0, 25)
            button.Position = UDim2.new(0, 10, 0, 2.5)
            button.BackgroundColor3 = config.Value and window.Color or Color3.new(0.3, 0.3, 0.3)
            button.BorderSizePixel = 0
            button.Text = ""
            button.Font = Enum.Font.SourceSans
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Parent = toggle
            label.Size = UDim2.new(1, -50, 1, 0)
            label.Position = UDim2.new(0, 50, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = config.Name or "Toggle"
            label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
            label.TextScaled = true
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            
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
            local slider = Instance.new("Frame")
            slider.Name = "Slider"
            slider.Parent = tab.ContentFrame
            slider.Size = UDim2.new(1, 0, 0, 40)
            slider.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
            slider.BorderSizePixel = 0
            slider.LayoutOrder = #tab.Elements + 1
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Parent = slider
            label.Size = UDim2.new(0, 200, 0, 20)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = config.Name .. ": " .. (config.Value or 0) .. (config.Unit or "")
            label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
            label.TextScaled = true
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            local sliderBar = Instance.new("Frame")
            sliderBar.Name = "SliderBar"
            sliderBar.Parent = slider
            sliderBar.Size = UDim2.new(0, 200, 0, 4)
            sliderBar.Position = UDim2.new(0, 10, 0, 25)
            sliderBar.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
            sliderBar.BorderSizePixel = 0
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Name = "SliderFill"
            sliderFill.Parent = sliderBar
            sliderFill.Size = UDim2.new(0, 0, 1, 0)
            sliderFill.Position = UDim2.new(0, 0, 0, 0)
            sliderFill.BackgroundColor3 = window.Color
            sliderFill.BorderSizePixel = 0
            
            local sliderButton = Instance.new("TextButton")
            sliderButton.Name = "SliderButton"
            sliderButton.Parent = sliderBar
            sliderButton.Size = UDim2.new(1, 0, 1, 0)
            sliderButton.BackgroundTransparency = 1
            sliderButton.Text = ""
            sliderButton.Font = Enum.Font.SourceSans
            
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
            local button = Instance.new("TextButton")
            button.Name = "Button"
            button.Parent = tab.ContentFrame
            button.Size = UDim2.new(1, -20, 0, 30)
            button.Position = UDim2.new(0, 10, 0, 0)
            button.BackgroundColor3 = window.Color
            button.BorderSizePixel = 0
            button.Text = config.Name or "Button"
            button.TextColor3 = Color3.new(1, 1, 1)
            button.TextScaled = true
            button.Font = Enum.Font.SourceSans
            button.LayoutOrder = #tab.Elements + 1
            
            button.MouseButton1Click:Connect(function()
                if config.Callback then
                    config.Callback()
                end
            end)
            
            table.insert(tab.Elements, button)
            return button
        end
        
        function tab:Dropdown(config)
            local dropdown = Instance.new("Frame")
            dropdown.Name = "Dropdown"
            dropdown.Parent = tab.ContentFrame
            dropdown.Size = UDim2.new(1, 0, 0, 30)
            dropdown.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
            dropdown.BorderSizePixel = 0
            dropdown.LayoutOrder = #tab.Elements + 1
            
            local button = Instance.new("TextButton")
            button.Name = "Button"
            button.Parent = dropdown
            button.Size = UDim2.new(1, -20, 1, 0)
            button.Position = UDim2.new(0, 10, 0, 0)
            button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
            button.BorderSizePixel = 0
            button.Text = config.Name or "Dropdown"
            button.TextColor3 = Color3.new(0.8, 0.8, 0.8)
            button.TextScaled = true
            button.Font = Enum.Font.SourceSans
            button.TextXAlignment = Enum.TextXAlignment.Left
            
            local selectedValue = config.Default and config.Default[1] or config.List[1] and config.List[1].Name or ""
            button.Text = config.Name .. ": " .. selectedValue
            
            button.MouseButton1Click:Connect(function()
                -- Simple dropdown implementation
                for _, item in ipairs(config.List or {}) do
                    if item.Callback then
                        item.Callback(item.Name)
                    end
                end
            end)
            
            table.insert(tab.Elements, dropdown)
            return dropdown
        end
        
        return tab
    end
    
    return window
end

function Laqour:Notification(Notification)
    Notification = Notification or {}
    Notification.Title = Notification.Title or "Notification"
    Notification.Description = Notification.Description or ""
    
    local notification = Instance.new("ScreenGui")
    notification.Name = "LaqourNotification"
    notification.Parent = game:GetService("CoreGui")
    notification.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.Parent = notification
    frame.Size = UDim2.new(0, 300, 0, 80)
    frame.Position = UDim2.new(1, -320, 0, 100)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(0, 0.7, 1)
    frame.Active = true
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Parent = frame
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = Notification.Title or "Notification"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Parent = frame
    descLabel.Size = UDim2.new(1, -20, 0, 30)
    descLabel.Position = UDim2.new(0, 10, 0, 40)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = Notification.Description or ""
    descLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    descLabel.TextScaled = true
    descLabel.Font = Enum.Font.SourceSans
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextWrapped = true
    
    -- Auto-remove after 5 seconds
    game:GetService("Debris"):AddItem(notification, 5)
end

function Laqour:TableToColor(Table)
    if type(Table) ~= "table" then return Table end
    return Color3.fromHSV(Table[1], Table[2], Table[3])
end

return Laqour
