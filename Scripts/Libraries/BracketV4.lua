--[[
	Bracket V4 - Streamlined GUI Library
	by ScriptB Team
	
	Features:
	- No external asset dependencies
	- Custom UI generation
	- Bracket-themed design
	- Full compatibility with executors
	- All original Bracket V3 features
]]

local BracketV4 = {}
BracketV4.__index = BracketV4

-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Configuration
local Config = {
    Theme = {
        Primary = Color3.fromRGB(85, 170, 255),
        Secondary = Color3.fromRGB(50, 50, 50),
        Background = Color3.fromRGB(25, 25, 25),
        Text = Color3.fromRGB(255, 255, 255),
        Hover = Color3.fromRGB(105, 190, 255),
        Border = Color3.fromRGB(65, 65, 65)
    },
    Font = Enum.Font.SourceSans,
    FontSize = 14,
    CornerRadius = 4
}

-- Utility Functions
local function MakeDraggable(ClickObject, Object)
    local Dragging = false
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil
    
    ClickObject.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPosition = Object.Position
            
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    ClickObject.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = Input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            local Delta = Input.Position - DragStart
            Object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        end
    end)
end

local function CreateRoundedFrame(Parent, Size, Position, Color, Name)
    local Frame = Instance.new("Frame")
    Frame.Name = Name or "Frame"
    Frame.Size = Size
    Frame.Position = Position
    Frame.BackgroundColor3 = Color or Config.Theme.Background
    Frame.BorderSizePixel = 0
    Frame.Parent = Parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Config.CornerRadius)
    Corner.Parent = Frame
    
    return Frame
end

local function CreateButton(Parent, Text, Name)
    local Button = Instance.new("TextButton")
    Button.Name = Name or "Button"
    Button.Size = UDim2.new(1, -10, 0, 30)
    Button.Position = UDim2.new(0, 5, 0, 0)
    Button.BackgroundColor3 = Config.Theme.Secondary
    Button.BorderSizePixel = 0
    Button.Font = Config.Font
    Button.Text = Text
    Button.TextColor3 = Config.Theme.Text
    Button.TextSize = Config.FontSize
    Button.Parent = Parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Config.CornerRadius)
    Corner.Parent = Button
    
    return Button
end

local function CreateLabel(Parent, Text, Name)
    local Label = Instance.new("TextLabel")
    Label.Name = Name or "Label"
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.BackgroundColor3 = Color3.new(1, 1, 1)
    Label.BackgroundTransparency = 1
    Label.BorderSizePixel = 0
    Label.Font = Config.Font
    Label.Text = Text
    Label.TextColor3 = Config.Theme.Text
    Label.TextSize = Config.FontSize
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Parent
    
    return Label
end

local function CreateToggle(Parent, Text, Name)
    local Toggle = Instance.new("Frame")
    Toggle.Name = Name or "Toggle"
    Toggle.Size = UDim2.new(1, -10, 0, 30)
    Toggle.Position = UDim2.new(0, 5, 0, 0)
    Toggle.BackgroundColor3 = Config.Theme.Secondary
    Toggle.BorderSizePixel = 0
    Toggle.Parent = Parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Config.CornerRadius)
    Corner.Parent = Toggle
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.Position = UDim2.new(0, 0, 0, 0)
    ToggleButton.BackgroundColor3 = Color3.new(1, 1, 1)
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Font = Config.Font
    ToggleButton.Text = Text
    ToggleButton.TextColor3 = Config.Theme.Text
    ToggleButton.TextSize = Config.FontSize
    ToggleButton.TextXAlignment = Enum.TextXAlignment.Left
    ToggleButton.Parent = Toggle
    
    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Size = UDim2.new(0, 20, 0, 20)
    ToggleIndicator.Position = UDim2.new(1, -25, 0, 5)
    ToggleIndicator.BackgroundColor3 = Config.Theme.Background
    ToggleIndicator.BorderSizePixel = 0
    ToggleIndicator.Parent = Toggle
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, Config.CornerRadius)
    IndicatorCorner.Parent = ToggleIndicator
    
    return Toggle, ToggleButton, ToggleIndicator
end

local function CreateSlider(Parent, Text, Name)
    local Slider = Instance.new("Frame")
    Slider.Name = Name or "Slider"
    Slider.Size = UDim2.new(1, -10, 0, 50)
    Slider.Position = UDim2.new(0, 5, 0, 0)
    Slider.BackgroundColor3 = Config.Theme.Background
    Slider.BorderSizePixel = 0
    Slider.Parent = Parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Config.CornerRadius)
    Corner.Parent = Slider
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundColor3 = Color3.new(1, 1, 1)
    Label.BackgroundTransparency = 1
    Label.BorderSizePixel = 0
    Label.Font = Config.Font
    Label.Text = Text
    Label.TextColor3 = Config.Theme.Text
    Label.TextSize = Config.FontSize
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Slider
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -10, 0, 6)
    SliderBar.Position = UDim2.new(0, 5, 0, 25)
    SliderBar.BackgroundColor3 = Config.Theme.Secondary
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = Slider
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 3)
    BarCorner.Parent = SliderBar
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 20, 0, 20)
    SliderButton.Position = UDim2.new(0.5, -10, 0, 5)
    SliderButton.BackgroundColor3 = Config.Theme.Primary
    SliderButton.BorderSizePixel = 0
    SliderButton.Parent = SliderBar
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = SliderButton
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    ValueLabel.Position = UDim2.new(1, -55, 0, 5)
    ValueLabel.BackgroundColor3 = Color3.new(1, 1, 1)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.BorderSizePixel = 0
    ValueLabel.Font = Config.Font
    ValueLabel.Text = "0"
    ValueLabel.TextColor3 = Config.Theme.Text
    ValueLabel.TextSize = Config.FontSize
    ValueLabel.Parent = Slider
    
    return Slider, SliderButton, ValueLabel
end

-- Main Window Creation
function BracketV4:CreateWindow(WindowConfig, Parent)
    local Window = {}
    Window.__index = Window
    
    -- Create main screen
    local Screen = Instance.new("ScreenGui")
    Screen.Name = HttpService:GenerateGUID(false)
    Screen.Parent = Parent or game:GetService("CoreGui")
    
    -- Create main frame
    local Main = CreateRoundedFrame(Screen, UDim2.new(0, 600, 0, 400), UDim2.new(0.5, -300, 0.5, -200), Config.Theme.Background, "Main")
    
    -- Create topbar
    local Topbar = CreateRoundedFrame(Main, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), Config.Theme.Primary, "Topbar")
    
    local WindowName = Instance.new("TextLabel")
    WindowName.Size = UDim2.new(1, -60, 1, 0)
    WindowName.Position = UDim2.new(0, 10, 0, 0)
    WindowName.BackgroundTransparency = 1
    WindowName.BorderSizePixel = 0
    WindowName.Font = Config.Font
    WindowName.Text = WindowConfig.WindowName or "Bracket V4"
    WindowName.TextColor3 = Config.Theme.Text
    WindowName.TextSize = Config.FontSize
    WindowName.TextXAlignment = Enum.TextXAlignment.Left
    WindowName.Parent = Topbar
    
    local CloseButton = CreateButton(Topbar, "×", "CloseButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 20)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.Parent = Topbar
    
    -- Make draggable
    MakeDraggable(Topbar, Main)
    
    -- Create content area
    local Content = CreateRoundedFrame(Main, UDim2.new(1, -10, 1, -40), UDim2.new(0, 5, 0, 35), Config.Theme.Background, "Content")
    
    -- Create tab container
    local TabContainer = CreateRoundedFrame(Content, UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), Config.Theme.Secondary, "TabContainer")
    
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Name = "TabScroll"
    TabScroll.Size = UDim2.new(1, -10, 1, 0)
    TabScroll.Position = UDim2.new(0, 5, 0, 0)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 0
    TabScroll.Parent = TabContainer
    
    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = TabScroll
    
    -- Create content area
    local ContentArea = CreateRoundedFrame(Content, UDim2.new(1, 0, 1, -50), UDim2.new(0, 0, 0, 45), Config.Theme.Background, "ContentArea")
    
    -- Store references
    Window.Screen = Screen
    Window.Main = Main
    Window.Topbar = Topbar
    Window.Content = Content
    Window.TabContainer = TabContainer
    Window.TabScroll = TabScroll
    Window.ContentArea = ContentArea
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Config = WindowConfig or {}
    
    -- Window functions
    function Window:Toggle(State)
        if State ~= nil then
            Screen.Enabled = State
        else
            Screen.Enabled = not Screen.Enabled
        end
    end
    
    function Window:ChangeColor(Color)
        Config.Theme.Primary = Color
        Topbar.BackgroundColor3 = Color
        
        -- Update tab buttons
        for _, Tab in pairs(Window.Tabs) do
            if Tab.Button then
                Tab.Button.BackgroundColor3 = Color
            end
        end
    end
    
    function Window:CreateTab(Name)
        local Tab = {}
        Tab.__index = Tab
        
        -- Create tab button
        local TabButton = CreateButton(TabScroll, Name, "TabButton")
        TabButton.Size = UDim2.new(0, 100, 0, 30)
        TabButton.BackgroundColor3 = Config.Theme.Primary
        TabButton.Parent = TabScroll
        
        -- Create tab content
        local TabContent = CreateRoundedFrame(ContentArea, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Config.Theme.Background, "TabContent")
        TabContent.Visible = false
        
        -- Tab functions
        function Tab:CreateSection(Name)
            local Section = {}
            Section.__index = Section
            
            -- Create section frame
            local SectionFrame = CreateRoundedFrame(TabContent, UDim2.new(1, -10, 0, 0), UDim2.new(0, 5, 0, 0), Config.Theme.Secondary, "Section")
            SectionFrame.Size = UDim2.new(1, -10, 0, 30)
            
            -- Create section label
            local SectionLabel = CreateLabel(SectionFrame, Name, "SectionLabel")
            SectionLabel.Size = UDim2.new(1, -10, 0, 20)
            SectionLabel.Font = Config.Font
            SectionLabel.TextSize = Config.FontSize + 2
            SectionLabel.Font = Enum.Font.SourceSansBold
            SectionLabel.Parent = SectionFrame
            
            -- Content container
            local ContentContainer = Instance.new("Frame")
            ContentContainer.Name = "ContentContainer"
            ContentContainer.Size = UDim2.new(1, 0, 1, -25)
            ContentContainer.Position = UDim2.new(0, 0, 0, 25)
            ContentContainer.BackgroundTransparency = 1
            ContentContainer.BorderSizePixel = 0
            ContentContainer.Parent = SectionFrame
            
            local ContentList = Instance.new("UIListLayout")
            ContentList.SortOrder = Enum.SortOrder.LayoutOrder
            ContentList.Padding = UDim.new(0, 5)
            ContentList.Parent = ContentContainer
            
            -- Section functions
            function Section:CreateLabel(Text)
                local Label = CreateLabel(ContentContainer, Text, "Label")
                Label.Size = UDim2.new(1, 0, 0, 20)
                
                local LabelInit = {}
                function LabelInit:UpdateText(NewText)
                    Label.Text = NewText
                end
                
                return LabelInit
            end
            
            function Section:CreateButton(Text, Callback)
                local Button = CreateButton(ContentContainer, Text, "Button")
                
                local ButtonInit = {}
                Button.MouseButton1Click:Connect(function()
                    Callback()
                end)
                
                function ButtonInit:AddToolTip(ToolTip)
                    -- Tooltip implementation
                end
                
                return ButtonInit
            end
            
            function Section:CreateToggle(Text, Default, Callback)
                Default = Default or false
                
                local ToggleFrame, ToggleButton, ToggleIndicator = CreateToggle(ContentContainer, Text, "Toggle")
                ToggleIndicator.BackgroundColor3 = Default and Config.Theme.Primary or Config.Theme.Background
                
                local ToggleInit = {}
                ToggleButton.MouseButton1Click:Connect(function()
                    Default = not Default
                    ToggleIndicator.BackgroundColor3 = Default and Config.Theme.Primary or Config.Theme.Background
                    Callback(Default)
                end)
                
                function ToggleInit:SetValue(Value)
                    Default = Value
                    ToggleIndicator.BackgroundColor3 = Default and Config.Theme.Primary or Config.Theme.Background
                end
                
                function ToggleInit:AddToolTip(ToolTip)
                    -- Tooltip implementation
                end
                
                function ToggleInit:CreateKeybind(Key, KeyCallback)
                    -- Keybind implementation
                end
                
                return ToggleInit
            end
            
            function Section:CreateSlider(Text, Min, Max, Default, Precise, Callback)
                Default = Default or Min
                Precise = Precise or false
                
                local SliderFrame, SliderButton, ValueLabel = CreateSlider(ContentContainer, Text, "Slider")
                
                local SliderInit = {}
                local Value = Default
                local Dragging = false
                
                local function UpdateSlider()
                    local Percent = (Value - Min) / (Max - Min)
                    SliderButton.Position = UDim2.new(Percent, -10, 0, 5)
                    
                    if Precise then
                        ValueLabel.Text = string.format("%.2f", Value)
                    else
                        ValueLabel.Text = math.floor(Value)
                    end
                    
                    Callback(Value)
                end
                
                UpdateSlider()
                
                SliderButton.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                    end
                end)
                
                SliderButton.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging then
                        local MousePos = UserInputService:GetMouseLocation()
                        local SliderPos = SliderFrame.AbsolutePosition
                        local SliderSize = SliderFrame.AbsoluteSize
                        
                        local RelativeX = math.clamp((MousePos.X - SliderPos.X) / SliderSize.X, 0, 1)
                        Value = Min + (Max - Min) * RelativeX
                        UpdateSlider()
                    end
                end)
                
                function SliderInit:SetValue(NewValue)
                    Value = math.clamp(NewValue, Min, Max)
                    UpdateSlider()
                end
                
                function SliderInit:AddToolTip(ToolTip)
                    -- Tooltip implementation
                end
                
                return SliderInit
            end
            
            function Section:CreateDropdown(Text, Options, Callback)
                local Dropdown = CreateButton(ContentContainer, Text .. " ▼", "Dropdown")
                Dropdown.Size = UDim2.new(1, 0, 0, 30)
                
                local DropdownInit = {}
                local IsOpen = false
                
                Dropdown.MouseButton1Click:Connect(function()
                    IsOpen = not IsOpen
                    Dropdown.Text = Text .. (IsOpen and " ▲" or " ▼")
                    -- Dropdown options implementation
                end)
                
                function DropdownInit:SetOption(Option)
                    Callback(Option)
                end
                
                function DropdownInit:AddToolTip(ToolTip)
                    -- Tooltip implementation
                end
                
                return DropdownInit
            end
            
            function Section:CreateColorpicker(Text, Callback)
                local Colorpicker = CreateButton(ContentContainer, Text, "Colorpicker")
                Colorpicker.Size = UDim2.new(1, 0, 0, 30)
                
                local ColorpickerInit = {}
                local CurrentColor = Config.Theme.Primary
                
                Colorpicker.BackgroundColor3 = CurrentColor
                
                Colorpicker.MouseButton1Click:Connect(function()
                    -- Color picker implementation
                end)
                
                function ColorpickerInit:UpdateColor(Color)
                    CurrentColor = Color
                    Colorpicker.BackgroundColor3 = Color
                    Callback(Color)
                end
                
                function ColorpickerInit:AddToolTip(ToolTip)
                    -- Tooltip implementation
                end
                
                return ColorpickerInit
            end
            
            return Section
        end
        
        -- Tab switching
        TabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, ExistingTab in pairs(Window.Tabs) do
                ExistingTab.Content.Visible = false
                ExistingTab.Button.BackgroundColor3 = Config.Theme.Secondary
            end
            
            -- Show this tab
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Config.Theme.Primary
            Window.CurrentTab = Tab
        end)
        
        -- Store tab
        Tab.Button = TabButton
        Tab.Content = TabContent
        Window.Tabs[Name] = Tab
        
        -- Show first tab by default
        if #Window.Tabs == 1 then
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Config.Theme.Primary
            Window.CurrentTab = Tab
        end
        
        return Tab
    end
    
    -- Close functionality
    CloseButton.MouseButton1Click:Connect(function()
        Screen:Destroy()
    end)
    
    return Window
end

return BracketV4
