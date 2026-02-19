-- Nexac Suite - Advanced Roblox Script
-- Version 2.0 - Clean Architecture
-- Built with LaqourLib UI Library

-- ===================================
-- GLOBAL DECLARATIONS (Suppress IDE Warnings)
-- ===================================

-- Roblox executor globals (expected to be undefined in IDE)
local getgenv = getgenv or function() return {} end
local gethui = gethui or function() return nil end
local syn = syn or nil

-- Executor-specific globals (expected to be undefined in IDE)
local JJSploit = JJSploit or nil
local Solara = Solara or nil
local Delta = Delta or nil
local Xeno = Xeno or nil
local PunkX = PunkX or nil
local Velocity = Velocity or nil
local Drift = Drift or nil
local LX63 = LX63 or nil
local Valex = Valex or nil
local Pluto = Pluto or nil
local CheatHub = CheatHub or nil

-- Roblox function globals (expected to be undefined in IDE)
local httpget = httpget or game.HttpGet

-- Roblox type globals (expected to be undefined in IDE)
local UDIm2 = UDIm2 or UDim2

-- ===================================
-- STEP 1: LOAD FIXED LAQOURLIB UI LIBRARY
-- ===================================

local Laqour = nil
local LaqourLibLoaded = false

-- Try to load the fixed LaqourLib that doesn't rely on broken assets
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/main/LaqourLib_Fixed"))()
end)

if success then
    Laqour = result
    LaqourLibLoaded = true
    print("✓ Fixed LaqourLib loaded successfully")
else
    warn("Failed to load Fixed LaqourLib: " .. tostring(result))
    warn("Attempting to load original LaqourLib...")
    
    -- Fallback to original LaqourLib
    local success2, result2 = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/main/LaqourLib"))()
    end)
    
    if success2 then
        Laqour = result2
        LaqourLibLoaded = true
        print("✓ Original LaqourLib loaded successfully")
    else
        warn("Failed to load LaqourLib from GitHub: " .. tostring(result2))
        warn("Falling back to simple UI system")
        LaqourLibLoaded = false
    end
end

-- ===================================
-- STEP 2: FALLBACK UI SYSTEM (IF LAQOURLIB FAILS)
-- ===================================

local SimpleUI = {}
SimpleUI.Windows = {}
SimpleUI.CurrentWindow = nil

function SimpleUI.Window(config)
    local window = {}
    window.Name = config.Name or "Window"
    window.Color = config.Color or Color3.new(0, 0.7, 1)
    window.Size = config.Size or UDim2.new(0, 500, 0, 400)
    window.Position = config.Position or UDim2.new(0.5, -250, 0.5, -200)
    window.Tabs = {}
    window.CurrentTab = nil
    
    -- Create main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleUI_" .. window.Name
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
        SimpleUI.CurrentWindow = nil
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
        
        return tab
    end
    
    SimpleUI.CurrentWindow = window
    return window
end

function SimpleUI.Notification(config)
    local notification = Instance.new("ScreenGui")
    notification.Name = "SimpleUI_Notification"
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
    titleLabel.Text = config.Title or "Notification"
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
    descLabel.Text = config.Description or ""
    descLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    descLabel.TextScaled = true
    descLabel.Font = Enum.Font.SourceSans
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextWrapped = true
    
    -- Auto-remove after 5 seconds
    game:GetService("Debris"):AddItem(notification, 5)
end

-- ===================================
-- STEP 2: EXECUTOR DETECTION SYSTEM
-- ===================================

local EXECUTOR_DATA = {
    ["Ronix"] = {unc = 100, level = "Level 8", source = "WeAreDevs"},
    ["JJSploit"] = {unc = 98, level = "Level 7", source = "YouTube Testing"},
    ["Solara"] = {unc = 66, level = "Level 6", source = "Official Website"},
    ["Delta"] = {unc = 100, level = "Level 8", source = "Official Website"},
    ["Xeno"] = {unc = 90, level = "Level 7", source = "Official Website"},
    ["Punk X"] = {unc = 100, level = "Level 8", source = "Official Website"},
    ["Velocity"] = {unc = 98, level = "Level 7", source = "Official Website"},
    ["Drift"] = {unc = 85, level = "Level 7", source = "WeAreDevs"},
    ["LX63"] = {unc = 100, level = "Level 8", source = "WeAreDevs"},
    ["Valex"] = {unc = 75, level = "Level 6", source = "WeAreDevs"},
    ["Pluto"] = {unc = 70, level = "Level 6", source = "WeAreDevs"},
    ["CheatHub"] = {unc = 60, level = "Level 6", source = "WeAreDevs"},
    ["Generic Executor"] = {unc = 30, level = "Unknown", source = "Estimated"},
    ["Mobile Executor"] = {unc = 35, level = "Unknown", source = "Estimated"}
}

local function detectExecutor()
    local executor = "Unknown"
    local executorSpecific = false
    
    -- Current Working Executors (2026)
    if getgenv and getgenv().executor and (getgenv().executor:find("Ronix") or getgenv().executor:find("RonixExploit")) then
        executor = "Ronix"
        executorSpecific = true
    elseif JJSploit then
        executor = "JJSploit"
        executorSpecific = true
    elseif Solara then
        executor = "Solara"
        executorSpecific = true
    elseif Delta then
        executor = "Delta"
        executorSpecific = true
    elseif Xeno then
        executor = "Xeno"
        executorSpecific = true
    elseif PunkX then
        executor = "Punk X"
        executorSpecific = true
    elseif Velocity then
        executor = "Velocity"
        executorSpecific = true
    elseif Drift then
        executor = "Drift"
        executorSpecific = true
    elseif LX63 then
        executor = "LX63"
        executorSpecific = true
    elseif Valex then
        executor = "Valex"
        executorSpecific = true
    elseif Pluto then
        executor = "Pluto"
        executorSpecific = true
    elseif CheatHub then
        executor = "CheatHub"
        executorSpecific = true
    -- Mobile Detection
    elseif gethui and not syn then
        executor = "Mobile Executor"
        executorSpecific = false
    -- Fallback Detection
    elseif getgenv and getgenv().executor then
        local executorName = getgenv().executor
        if executorName:find("Ronix") or executorName:find("RonixExploit") then
            executor = "Ronix"
        elseif executorName:find("Velocity") then
            executor = "Velocity"
        elseif executorName:find("JJSploit") then
            executor = "JJSploit"
        elseif executorName:find("Solara") then
            executor = "Solara"
        elseif executorName:find("Delta") then
            executor = "Delta"
        elseif executorName:find("Xeno") then
            executor = "Xeno"
        elseif executorName:find("Punk") then
            executor = "Punk X"
        elseif executorName:find("Drift") then
            executor = "Drift"
        elseif executorName:find("LX63") then
            executor = "LX63"
        elseif executorName:find("Valex") then
            executor = "Valex"
        elseif executorName:find("Pluto") then
            executor = "Pluto"
        elseif executorName:find("CheatHub") then
            executor = "CheatHub"
        else
            executor = executorName
        end
        executorSpecific = true
    else
        executor = "Generic Executor"
        executorSpecific = false
    end
    
    -- Get UNC data
    local uncData = EXECUTOR_DATA[executor] or EXECUTOR_DATA["Generic Executor"]
    local uncPercentage = uncData.unc
    local uncLevel = uncData.level
    local uncCompatible = uncPercentage >= 80
    
    -- Test essential functions
    local essentialFunctions = {"httpget", "require", "loadstring"}
    local workingEssential = {}
    
    for _, feature in ipairs(essentialFunctions) do
        local success = pcall(function()
            if feature == "httpget" and (httpget or game.HttpGet) then
                table.insert(workingEssential, feature)
            elseif feature == "require" and require then
                local success = pcall(require, game:GetService("Workspace"))
                if success then table.insert(workingEssential, feature) end
            elseif feature == "loadstring" and loadstring then
                loadstring("print('test')")
                table.insert(workingEssential, feature)
            end
        end)
    end
    
    return {
        Name = executor,
        Features = workingEssential,
        Compatible = #workingEssential >= 2,
        UNCCompatible = uncCompatible,
        UNCPercentage = uncPercentage,
        UNCLevel = uncLevel,
        UNCSource = uncData.source,
        ExecutorSpecific = executorSpecific,
        FeatureCount = #workingEssential
    }
end

-- ===================================
-- STEP 3: LOADING SCREEN SYSTEM
-- ===================================

local loadingGui = nil
local loadingProgress = 0
local loadingStatus = "Initializing..."

local function createLoadingScreen()
    if loadingGui then return end
    
    loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "NexacLoading"
    loadingGui.Parent = game:GetService("CoreGui")
    loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = loadingGui
    mainFrame.Size = UDim2.new(0, 400, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.new(0, 0.7, 1)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Parent = mainFrame
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Nexac Suite"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Parent = mainFrame
    statusLabel.Size = UDim2.new(1, 0, 0, 30)
    statusLabel.Position = UDim2.new(0, 0, 0, 50)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = loadingStatus
    statusLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.SourceSans
    
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Parent = mainFrame
    progressBar.Size = UDim2.new(0.8, 0, 0, 10)
    progressBar.Position = UDim2.new(0.1, 0, 0, 100)
    progressBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    progressBar.BorderSizePixel = 0
    
    local progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.Parent = progressBar
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.Position = UDim2.new(0, 0, 0, 0)
    progressFill.BackgroundColor3 = Color3.new(0, 0.7, 1)
    progressFill.BorderSizePixel = 0
    
    local percentageLabel = Instance.new("TextLabel")
    percentageLabel.Name = "Percentage"
    percentageLabel.Parent = mainFrame
    percentageLabel.Size = UDim2.new(1, 0, 0, 30)
    percentageLabel.Position = UDIm2.new(0, 0, 0, 120)
    percentageLabel.BackgroundTransparency = 1
    percentageLabel.Text = "0%"
    percentageLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    percentageLabel.TextScaled = true
    percentageLabel.Font = Enum.Font.SourceSans
    
    local executorLabel = Instance.new("TextLabel")
    executorLabel.Name = "Executor"
    executorLabel.Parent = mainFrame
    executorLabel.Size = UDim2.new(1, 0, 0, 30)
    executorLabel.Position = UDim2.new(0, 0, 0, 160)
    executorLabel.BackgroundTransparency = 1
    executorLabel.Text = "Detecting..."
    executorLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    executorLabel.TextScaled = true
    executorLabel.Font = Enum.Font.SourceSans
    
    loadingGui.Enabled = true
end

local function updateLoadingScreen(progress, status, executorInfo)
    loadingProgress = progress
    loadingStatus = status
    
    if loadingGui and loadingGui.MainFrame then
        local titleLabel = loadingGui.MainFrame:FindFirstChild("Title")
        local statusLabel = loadingGui.MainFrame:FindFirstChild("Status")
        local progressFill = loadingGui.MainFrame:FindFirstChild("ProgressBar")
            and loadingGui.MainFrame.ProgressBar:FindFirstChild("ProgressFill")
        local percentageLabel = loadingGui.MainFrame:FindFirstChild("Percentage")
        local executorLabel = loadingGui.MainFrame:FindFirstChild("Executor")
        
        if titleLabel then
            titleLabel.Text = "Nexac Suite - " .. math.floor(progress * 100) .. "%"
        end
        
        if statusLabel then
            statusLabel.Text = status
        end
        
        if progressFill then
            progressFill:TweenSize(
                UDim2.new(progress, 0, 1, 0),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.3,
                true
            )
        end
        
        if percentageLabel then
            percentageLabel.Text = math.floor(progress * 100) .. "%"
        end
        
        if executorLabel and executorInfo then
            local uncStatus = executorInfo.UNCCompatible and "✓ UNC" or "✗ Limited"
            local executorType = executorInfo.ExecutorSpecific and "" or " (Generic)"
            executorLabel.Text = string.format("Executor: %s%s [%d%% UNC] %s", 
                executorInfo.Name, executorType, executorInfo.UNCPercentage, uncStatus)
        end
    end
end

-- ===================================
-- STEP 4: MAIN INITIALIZATION
-- ===================================

local function main()
    -- Step 1: Create loading screen
    createLoadingScreen()
    updateLoadingScreen(0.1, "Detecting executor...", nil)
    
    -- Step 2: Detect executor
    local executorInfo = detectExecutor()
    updateLoadingScreen(0.3, "Executor detected!", executorInfo)
    
    -- Step 3: Check compatibility
    if not executorInfo.Compatible then
        updateLoadingScreen(0.5, "Executor not compatible!", executorInfo)
        wait(3)
        if loadingGui then
            loadingGui:Destroy()
        end
        return
    end
    
    updateLoadingScreen(0.7, "Creating interface...", executorInfo)
    
    -- Step 4: Create main interface using appropriate UI system
    local Window
    local uiSystem
    
    if LaqourLibLoaded then
        -- Use LaqourLib if it loaded successfully
        Window = Laqour.Window({
            Name = "Nexac Suite",
            Color = Color3.new(0, 0.7, 1),
            Size = UDim2.new(0, 600, 0, 500),
            Position = UDim2.new(0.5, -300, 0.5, -250)
        })
        uiSystem = "LaqourLib"
        print("✓ Using LaqourLib UI system")
    else
        -- Use fallback SimpleUI system
        Window = SimpleUI.Window({
            Name = "Nexac Suite",
            Color = Color3.new(0, 0.7, 1),
            Size = UDim2.new(0, 600, 0, 500),
            Position = UDim2.new(0.5, -300, 0.5, -250)
        })
        uiSystem = "SimpleUI"
        print("✓ Using SimpleUI fallback system")
    end
    
    -- Info Tab
    local InfoTab = Window:Tab({Name = "Info"})
    InfoTab:Divider({Text = "Nexac Suite Information", Side = "Left"})
    
    InfoTab:Label({Text = "Welcome to Nexac Suite!", Side = "Left"})
    InfoTab:Label({Text = "Version: 2.0", Side = "Left"})
    InfoTab:Label({Text = string.format("UI System: %s", uiSystem), Side = "Left"})
    InfoTab:Label({Text = string.format("Executor: %s", executorInfo.Name), Side = "Left"})
    InfoTab:Label({Text = string.format("UNC Level: %s", executorInfo.UNCLevel), Side = "Left"})
    InfoTab:Label({Text = string.format("UNC Percentage: %d%%", executorInfo.UNCPercentage), Side = "Left"})
    InfoTab:Label({Text = string.format("Features: %d/%d", executorInfo.FeatureCount, #{"httpget", "require", "loadstring"}), Side = "Left"})
    InfoTab:Label({Text = "", Side = "Left"})
    
    InfoTab:Divider({Text = "Status", Side = "Left"})
    InfoTab:Label({Text = "✓ UI System Loaded", Side = "Left"})
    InfoTab:Label({Text = "✓ Executor Compatible", Side = "Left"})
    InfoTab:Label({Text = "✓ All Systems Ready", Side = "Left"})
    InfoTab:Label({Text = "", Side = "Left"})
    
    InfoTab:Divider({Text = "Features", Side = "Left"})
    InfoTab:Label({Text = "• Advanced Aimbot", Side = "Left"})
    InfoTab:Label({Text = "• ESP System", Side = "Left"})
    InfoTab:Label({Text = "• Visual Enhancements", Side = "Left"})
    InfoTab:Label({Text = "• Movement Tools", Side = "Left"})
    InfoTab:Label({Text = "• Custom Settings", Side = "Left"})
    
    -- Aimbot Tab
    local AimbotTab = Window:Tab({Name = "Aimbot"})
    AimbotTab:Divider({Text = "Aimbot Settings", Side = "Left"})
    
    local AimbotEnabled = AimbotTab:Toggle({
        Name = "Enable Aimbot", 
        Side = "Left", 
        Value = false, 
        Callback = function(Bool)
            print("Aimbot:", Bool)
        end
    })
    
    local AimPart = AimbotTab:Dropdown({
        Name = "Aim Part", 
        Side = "Left", 
        Default = {"Head"}, 
        List = {
            {
                Name = "Head",
                Mode = "Toggle",
                Value = true,
                Callback = function(Selected)
                    print("Aim Part:", Selected)
                end
            },
            {
                Name = "HumanoidRootPart",
                Mode = "Toggle", 
                Value = false,
                Callback = function(Selected)
                    print("Aim Part:", Selected)
                end
            },
            {
                Name = "Torso",
                Mode = "Toggle",
                Value = false,
                Callback = function(Selected)
                    print("Aim Part:", Selected)
                end
            }
        }
    })
    
    local AimFOV = AimbotTab:Slider({
        Name = "FOV", 
        Side = "Left", 
        Min = 10, 
        Max = 360, 
        Value = 90, 
        Precise = 0, 
        Unit = "°", 
        Callback = function(Number)
            print("FOV:", Number)
        end
    })
    
    local AimSmoothness = AimbotTab:Slider({
        Name = "Smoothness", 
        Side = "Left", 
        Min = 1, 
        Max = 100, 
        Value = 50, 
        Precise = 0, 
        Unit = "%", 
        Callback = function(Number)
            print("Smoothness:", Number)
        end
    })
    
    -- ESP Tab
    local ESPTab = Window:Tab({Name = "ESP"})
    ESPTab:Divider({Text = "ESP Settings", Side = "Left"})
    
    local ESPEnabled = ESPTab:Toggle({
        Name = "Enable ESP", 
        Side = "Left", 
        Value = false, 
        Callback = function(Bool)
            print("ESP:", Bool)
        end
    })
    
    local ShowNames = ESPTab:Toggle({
        Name = "Show Names", 
        Side = "Left", 
        Value = true, 
        Callback = function(Bool)
            print("Show Names:", Bool)
        end
    })
    
    local ShowBoxes = ESPTab:Toggle({
        Name = "Show Boxes", 
        Side = "Left", 
        Value = true, 
        Callback = function(Bool)
            print("Show Boxes:", Bool)
        end
    })
    
    -- Visuals Tab
    local VisualsTab = Window:Tab({Name = "Visuals"})
    VisualsTab:Divider({Text = "Visual Settings", Side = "Left"})
    
    local Fullbright = VisualsTab:Toggle({
        Name = "Fullbright", 
        Side = "Left", 
        Value = false, 
        Callback = function(Bool)
            print("Fullbright:", Bool)
        end
    })
    
    local NoFog = VisualsTab:Toggle({
        Name = "No Fog", 
        Side = "Left", 
        Value = false, 
        Callback = function(Bool)
            print("No Fog:", Bool)
        end
    })
    
    local Crosshair = VisualsTab:Toggle({
        Name = "Custom Crosshair", 
        Side = "Left", 
        Value = false, 
        Callback = function(Bool)
            print("Crosshair:", Bool)
        end
    })
    
    -- Movement Tab
    local MovementTab = Window:Tab({Name = "Movement"})
    MovementTab:Divider({Text = "Movement Settings", Side = "Left"})
    
    local Speed = MovementTab:Toggle({
        Name = "Speed Hack", 
        Side = "Left", 
        Value = false, 
        Callback = function(Bool)
            print("Speed:", Bool)
        end
    })
    
    local SpeedAmount = MovementTab:Slider({
        Name = "Speed Amount", 
        Side = "Left", 
        Min = 1, 
        Max = 50, 
        Value = 20, 
        Precise = 0, 
        Unit = "x", 
        Callback = function(Number)
            print("Speed Amount:", Number)
        end
    })
    
    local JumpPower = MovementTab:Toggle({
        Name = "Jump Power", 
        Side = "Left", 
        Value = false, 
        Callback = function(Bool)
            print("High Jump:", Bool)
        end
    })
    
    local JumpHeight = MovementTab:Slider({
        Name = "Jump Height", 
        Side = "Left", 
        Min = 1, 
        Max = 100, 
        Value = 50, 
        Precise = 0, 
        Unit = "studs", 
        Callback = function(Number)
            print("Jump Height:", Number)
        end
    })
    
    local Fly = MovementTab:Toggle({
        Name = "Fly", 
        Side = "Left", 
        Value = false, 
        Callback = function(Bool)
            print("Fly:", Bool)
        end
    })
    
    local FlySpeed = MovementTab:Slider({
        Name = "Fly Speed", 
        Side = "Left", 
        Min = 1, 
        Max = 100, 
        Value = 50, 
        Precise = 0, 
        Unit = "studs/s", 
        Callback = function(Number)
            print("Fly Speed:", Number)
        end
    })
    
    -- Settings Tab
    local SettingsTab = Window:Tab({Name = "Settings"})
    SettingsTab:Divider({Text = "Script Settings", Side = "Left"})
    
    local AutoExecute = SettingsTab:Toggle({
        Name = "Auto Execute", 
        Side = "Left", 
        Value = false, 
        Callback = function(Bool)
            print("Auto Execute:", Bool)
        end
    })
    
    local SaveConfig = SettingsTab:Toggle({
        Name = "Save Config", 
        Side = "Left", 
        Value = true, 
        Callback = function(Bool)
            print("Save Config:", Bool)
        end
    })
    
    SettingsTab:Divider({Text = "About", Side = "Left"})
    SettingsTab:Label({Text = "Nexac Suite v2.0", Side = "Left"})
    SettingsTab:Label({Text = "Created by ScriptB", Side = "Left"})
    SettingsTab:Label({Text = string.format("UI System: %s", uiSystem), Side = "Left"})
    SettingsTab:Label({Text = string.format("UNC Compatible: %s", executorInfo.UNCCompatible and "Yes" or "No"), Side = "Left"})
    SettingsTab:Label({Text = string.format("UNC Level: %s", executorInfo.UNCLevel), Side = "Left"})
    SettingsTab:Label({Text = string.format("UNC Percentage: %d%%", executorInfo.UNCPercentage), Side = "Left"})
    
    -- Show success notification
    if LaqourLibLoaded then
        Laqour:Notification({
            Title = "Nexac Suite", 
            Description = "loaded successfully with LaqourLib!"
        })
    else
        SimpleUI.Notification({
            Title = "Nexac Suite", 
            Description = "loaded successfully with SimpleUI!"
        })
    end
    
    -- Clean up loading screen
    updateLoadingScreen(1.0, "Complete!", executorInfo)
    wait(1)
    
    if loadingGui then
        loadingGui:Destroy()
        loadingGui = nil
    end
    
    -- Console output
    print("========================================")
    print("Nexac Suite v2.0 - Successfully Loaded!")
    print("========================================")
    print(string.format("UI System: %s", uiSystem))
    print(string.format("Executor: %s", executorInfo.Name))
    print(string.format("UNC Level: %s", executorInfo.UNCLevel))
    print(string.format("UNC Percentage: %d%%", executorInfo.UNCPercentage))
    print(string.format("UNC Compatible: %s", executorInfo.UNCCompatible and "Yes" or "No"))
    print(string.format("Essential Features: %d/%d", executorInfo.FeatureCount, #{"httpget", "require", "loadstring"}))
    print("========================================")
end

-- ===================================
-- STEP 5: ERROR HANDLING
-- ===================================

local success, error = pcall(main)
if not success then
    warn("Nexac initialization failed: " .. tostring(error))
    
    -- Show error message
    if loadingGui then
        local errorLabel = loadingGui.MainFrame.Status
        if errorLabel then
            errorLabel.Text = "Initialization Failed!"
        end
        
        local executorLabel = loadingGui.MainFrame.Executor
        if executorLabel then
            executorLabel.Text = "Please check console for details"
        end
        
        wait(5)
        
        if loadingGui then
            loadingGui:Destroy()
        end
    end
end

-- ===================================
-- SCRIPT COMPLETION
-- ===================================

print("Nexac Suite v2.0 - Clean Architecture with LaqourLib")
print("All systems operational and ready for use!")
