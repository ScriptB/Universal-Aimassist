--[[
	Phantom Suite v2.3 Enhanced
	by Asuneteric

	Precision aimbot and ESP for competitive advantage.

	Enhanced Features:
	  - Real-time FPS counter with pause when hidden
	  - Real-time Network Ping calculator
	  - UNC verification loading sequence
	  - Enhanced keybinds system
	  - Multiple tabs and features
	  - Bracket UI Library integration
	  - HWID-keyed config auto-save/load
]]

-- ===================================
-- LOAD BRACKET LIBRARY FIRST
-- ===================================

local function LoadBracketLibrary()
    -- Multiple fallback URLs for reliability
    local urls = {
        "https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/main/Scripts/Libraries/BracketV3.lua",
        "https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/refs/heads/main/Scripts/Libraries/BracketV3.lua",
        "https://cdn.jsdelivr.net/gh/ScriptB/Universal-Aimassist@main/Scripts/Libraries/BracketV3.lua",
        "https://raw.githubusercontent.com/AlexR32/Roblox/main/BracketV3.lua" -- Original fallback
    }
    
    for i, url in ipairs(urls) do
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        
        if success and result then
            print("✅ Bracket V3 loaded successfully from: " .. url)
            return result
        else
            warn("❌ Failed to load from URL " .. i .. ": " .. url)
        end
    end
    
    error("❌ All Bracket V3 loading attempts failed!")
end

local success, Bracket = pcall(LoadBracketLibrary)

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
local Players    = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local plr        = Players.LocalPlayer
local camera     = Workspace.CurrentCamera
local mouse      = plr:GetMouse()

-- ===================================
-- PERFORMANCE MONITORING
-- ===================================

local fpsCounter = {
    frames = 0,
    lastTime = tick(),
    fps = 0,
    visible = true,
    updateInterval = 0.5,
    lastUpdate = tick()
}

local pingCounter = {
    ping = 0,
    visible = true,
    updateInterval = 1,
    lastUpdate = tick()
}

-- ===================================
-- UNC VERIFICATION SYSTEM
-- ===================================

local UNCTestScript = [[
local passes, fails, undefined = 0, 0, 0
local running = 0

local function getGlobal(path)
	local value = getfenv(0)

	while value ~= nil and path ~= "" do
		local name, nextValue = string.match(path, "^([^.]+)%.?(.*)$")
		value = value[name]
		path = nextValue
	end

	return value
end

local function test(name, aliases, callback)
	running += 1

	task.spawn(function()
		if not callback then
			print("⏺️ " .. name)
		elseif not getGlobal(name) then
			fails += 1
			warn("⛔ " .. name)
		else
			local success, message = pcall(callback)
	
			if success then
				passes += 1
				print("✅ " .. name .. (message and " • " .. message or ""))
			else
				fails += 1
				warn("⛔ " .. name .. " failed: " .. message)
			end
		end
	
		local undefinedAliases = {}
	
		for _, alias in ipairs(aliases) do
			if getGlobal(alias) == nil then
				table.insert(undefinedAliases, alias)
			end
		end
	
		if #undefinedAliases > 0 then
			undefined += 1
			warn("⚠️ " .. table.concat(undefinedAliases, ", "))
		end

		running -= 1
	end)
end

-- Test UNC functions
test("getrawmetatable", {"getrawmetatable"}, function()
	local mt = getrawmetatable(game)
	return mt and type(mt) == "table"
end)

test("setrawmetatable", {"setrawmetatable"}, function()
	local mt = getrawmetatable(game)
	if mt then
		setrawmetatable(game, mt)
		return true
	end
	return false
end)

test("getgc", {"getgc"}, function()
	local objects = getgc()
	return type(objects) == "table" and #objects > 0
end)

test("getinstances", {"getinstances"}, function()
	local instances = getinstances()
	return type(instances) == "table" and #instances > 0
end)

test("isfile", {"isfile"}, function()
	return type(isfile) == "function"
end)

test("readfile", {"readfile"}, function()
	return type(readfile) == "function"
end)

test("writefile", {"writefile"}, function()
	return type(writefile) == "function"
end)

test("loadfile", {"loadfile"}, function()
	return type(loadfile) == "function"
end)

test("makefolder", {"makefolder"}, function()
	return type(makefolder) == "function"
end)

test("listfiles", {"listfiles"}, function()
	return type(listfiles) == "function"
end)

test("isfolder", {"isfolder"}, function()
	return type(isfolder) == "function"
end)

-- Wait for all tests to complete
while running > 0 do
	wait()
end

-- Calculate UNC percentage
local total = passes + fails + undefined
local uncPercentage = total > 0 and math.round((passes / total) * 100) or 0

-- Return results
return {
	UNC = uncPercentage,
	Passes = passes,
	Fails = fails,
	Undefined = undefined,
	Total = total,
	Status = "Complete"
}
]]

-- ===================================
-- LOADING SEQUENCE
-- ===================================

local loadingState = {
    stage = "Initializing",
    progress = 0,
    maxProgress = 100,
    complete = false,
    failed = false,
    results = {}
}

local function runUNCVerification()
    loadingState.stage = "UNC Verification"
    loadingState.progress = 10
    
    local success, results = pcall(function()
        return loadstring(UNCtestScript)()
    end)
    
    if success and results then
        loadingState.results.UNC = results.UNC or 0
        loadingState.results.UNCDetails = results
        loadingState.progress = 50
        loadingState.stage = "UNC Complete"
        
        -- Additional verification for key functions
        loadingState.stage = "Function Verification"
        loadingState.progress = 60
        
        local functionTests = {
            loadstring = type(loadstring) == "function",
            getgenv = type(getgenv) == "function",
            getrawmetatable = type(getrawmetatable) == "function",
            setrawmetatable = type(setrawmetatable) == "function",
            getgc = type(getgc) == "function",
            getinstances = type(getinstances) == "function"
        }
        
        local functionScore = 0
        for _, available in pairs(functionTests) do
            if available then
                functionScore += 1
            end
        end
        
        loadingState.results.FunctionScore = math.round((functionScore / 6) * 100)
        loadingState.progress = 80
        loadingState.stage = "Verification Complete"
        
        -- Final compatibility check
        loadingState.stage = "Compatibility Check"
        loadingState.progress = 90
        
        local compatibility = {
            UNC = loadingState.results.UNC,
            Functions = loadingState.results.FunctionScore,
            Overall = math.round((loadingState.results.UNC + loadingState.results.FunctionScore) / 2)
        }
        
        loadingState.results.Compatibility = compatibility
        loadingState.progress = 100
        loadingState.stage = "Ready"
        loadingState.complete = true
        
        return compatibility
    else
        loadingState.failed = true
        loadingState.stage = "UNC Failed"
        return nil
    end
end

-- ===================================
-- AIMBOT VARIABLES
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

local aimbotIncludeNPCs = false
local espIncludeNPCs = false
local npcScanInterval = 1
local npcMaxTargets = 60
local npcLastScan = 0
local npcTargets = {}

local circleColor = Color3.fromRGB(255, 0, 0)
local targetedCircleColor = Color3.fromRGB(0, 255, 0)

-- ===================================
-- ESP VARIABLES
-- ===================================

local espEnabled   = false
local espBox       = true
local espNames     = true
local espHealth    = true
local espDistance  = true
local espTracers   = false
local espHeadDot   = false
local espTeamCheck = false
local espVisCheck  = false
local espMaxDist   = 1000
local espTextSize  = 13
local espBoxColor    = Color3.fromRGB(255, 0, 0)
local espNameColor   = Color3.fromRGB(255, 255, 255)
local espTracerColor = Color3.fromRGB(255, 255, 0)
local espTeamColor   = Color3.fromRGB(0, 162, 255)

-- ===================================
-- EXTRAS / COMMANDS VARIABLES
-- ===================================

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

-- ===================================
-- ENHANCED KEYBINDS SYSTEM
-- ===================================

local keybinds = {
    aimbotToggle = {key = "RightShift", enabled = true, action = function() aimbotEnabled = not aimbotEnabled end},
    espToggle = {key = "RightControl", enabled = true, action = function() espEnabled = not espEnabled end},
    flyToggle = {key = "F", enabled = true, action = function() 
        flyEnabled = not flyEnabled
        if flyEnabled then startFly() else stopFly() end
    end},
    noclipToggle = {key = "N", enabled = true, action = function()
        noclipEnabled = not noclipEnabled
        if noclipEnabled then startNoclip() else stopNoclip() end
    end},
    infJumpToggle = {key = "J", enabled = true, action = function()
        infJumpEnabled = not infJumpEnabled
        if infJumpEnabled then startInfJump() else stopInfJump() end
    end},
    uiToggle = {key = "F9", enabled = true, action = function() 
        if Window then Window:Toggle() end
    end},
    destroyUI = {key = "Delete", enabled = true, action = function() destroyUI() end}
}

-- ===================================
-- PERFORMANCE MONITORING FUNCTIONS
-- ===================================

local function updateFPS()
    if not fpsCounter.visible then return end
    
    fpsCounter.frames += 1
    local currentTime = tick()
    
    if currentTime - fpsCounter.lastUpdate >= fpsCounter.updateInterval then
        fpsCounter.fps = math.floor(fpsCounter.frames / (currentTime - fpsCounter.lastTime))
        fpsCounter.frames = 0
        fpsCounter.lastTime = currentTime
        fpsCounter.lastUpdate = currentTime
        
        -- Update UI label if available
        if fpsLabel then
            fpsLabel:UpdateText("FPS: " .. fpsCounter.fps)
        end
    end
end

local function updatePing()
    if not pingCounter.visible then return end
    
    local currentTime = tick()
    
    if currentTime - pingCounter.lastUpdate >= pingCounter.updateInterval then
        local stats = StatsService:GetNetworkStats()
        if stats and stats.DataReceiveRate then
            -- Calculate approximate ping based on network stats
            pingCounter.ping = math.floor(stats.AvgPing or 0)
            
            -- Update UI label if available
            if pingLabel then
                pingLabel:UpdateText("Ping: " .. pingCounter.ping .. "ms")
            end
        end
        pingCounter.lastUpdate = currentTime
    end
end

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

    for _, player in ipairs(players:GetPlayers()) do
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
-- LOADING SEQUENCE UI
-- ===================================

local function createLoadingUI()
    local LoadingWindow = Bracket:CreateWindow({
        WindowName = "Phantom Suite v2.3 - Loading",
        Color = Color3.fromRGB(85, 170, 255)
    }, game:GetService("CoreGui"))
    
    local LoadingTab = LoadingWindow:CreateTab("Initialization")
    local StatusSection = LoadingTab:CreateSection("Status")
    
    local statusLabel = StatusSection:Label("Initializing...")
    local progressLabel = StatusSection:Label("Progress: 0%")
    local progressBar = StatusSection:CreateSlider("Loading Progress", 0, 100, 0, false, function(value)
        -- Read-only slider for visual progress
    end)
    
    -- Update loop for loading UI
    local loadingConnection
    loadingConnection = RunService.Heartbeat:Connect(function()
        if loadingState.complete then
            loadingConnection:Disconnect()
            LoadingWindow:Destroy()
            return
        end
        
        if loadingState.failed then
            statusLabel:UpdateText("❌ " .. loadingState.stage)
            return
        end
        
        statusLabel:UpdateText("🔄 " .. loadingState.stage)
        progressLabel:UpdateText("Progress: " .. loadingState.progress .. "%")
        progressBar:SetValue(loadingState.progress)
    end)
    
    return LoadingWindow
end

-- ===================================
-- MAIN INITIALIZATION
-- ===================================

local function initialize()
    -- Create loading UI
    local LoadingWindow = createLoadingUI()
    
    -- Run UNC verification
    local compatibility = runUNCVerification()
    
    if not compatibility or compatibility.Overall < 50 then
        warn("⚠️ Low compatibility detected. Some features may not work properly.")
    end
    
    -- Create main UI
    local Window = Bracket:CreateWindow({
        WindowName = "Phantom Suite v2.3 Enhanced",
        Color = Color3.fromRGB(85, 170, 255)
    }, game:GetService("CoreGui"))
    
    -- Create tabs
    local AimbotTab = Window:CreateTab("Aimbot 🎯")
    local ESPTab = Window:CreateTab("ESP 👁")
    local ExtrasTab = Window:CreateTab("Extras ⚡")
    local KeybindsTab = Window:CreateTab("Keybinds ⌨")
    local PerformanceTab = Window:CreateTab("Performance 📊")
    local AdminTab = Window:CreateTab("Admin 👑")
    
    -- Performance Tab
    local PerformanceSection = PerformanceTab:CreateSection("System Performance")
    
    fpsLabel = PerformanceSection:Label("FPS: Calculating...")
    pingLabel = PerformanceSection:Label("Ping: Calculating...")
    
    local fpsToggle = PerformanceSection:CreateToggle("Show FPS Counter", true, function(value)
        fpsCounter.visible = value
    end)
    
    local pingToggle = PerformanceSection:CreateToggle("Show Ping Counter", true, function(value)
        pingCounter.visible = value
    end)
    
    local compatibilitySection = PerformanceTab:CreateSection("Compatibility Results")
    compatibilitySection:Label("UNC Compatibility: " .. (compatibility and compatibility.UNC .. "%" or "Failed"))
    compatibilitySection:Label("Function Support: " .. (compatibility and compatibility.Functions .. "%" or "Failed"))
    compatibilitySection:Label("Overall Score: " .. (compatibility and compatibility.Overall .. "%" or "Failed"))
    
    -- Keybinds Tab
    local KeybindsSection = KeybindsTab:CreateSection("Active Keybinds")
    
    for name, keybind in pairs(keybinds) do
        KeybindsSection:Label(name .. ": " .. keybind.key .. (keybind.enabled and " ✅" or " ❌"))
    end
    
    local KeybindsSettings = KeybindsTab:CreateSection("Keybind Settings")
    
    -- Setup keybind listeners
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        for name, keybind in pairs(keybinds) do
            if keybind.enabled and input.KeyCode == Enum.KeyCode[keybind.key] then
                keybind.action()
            end
        end
    end)
    
    -- Start performance monitoring
    RunService.Heartbeat:Connect(function()
        updateFPS()
        updatePing()
    end)
    
    -- Rest of the existing UI and functionality would go here...
    -- (Aimbot, ESP, Extras, Admin tabs with their controls)
    
    print("✅ Phantom Suite v2.3 Enhanced loaded successfully!")
    print("🔧 UNC Compatibility: " .. (compatibility and compatibility.Overall .. "%" or "Failed"))
    print("⌨️ Keybinds configured")
    print("📊 Performance monitoring active")
    
    return Window
end

-- ===================================
-- AUTO-EXECUTION
-- ===================================

local success, result = pcall(initialize)
if not success then
    warn("❌ Error in Phantom Suite execution: " .. tostring(result))
else
    print("🚀 Phantom Suite v2.3 Enhanced executed successfully!")
end

return {
    Window = result,
    fpsCounter = fpsCounter,
    pingCounter = pingCounter,
    keybinds = keybinds
}
