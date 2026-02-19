local Library = {Toggle = true,FirstTab = nil,TabCount = 0,ColorTable = {}}

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function MakeDraggable(ClickObject, Object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil
	
	ClickObject.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
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
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
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

function Library:CreateWindow(Config, Parent)
	local WindowInit = {}
	local Folder = game:GetObjects("rbxassetid://7141683860")[1]
	local Screen = Folder.Bracket:Clone()
	local Main = Screen.Main
	local Holder = Main.Holder
	local Topbar = Main.Topbar
	local TContainer = Holder.TContainer
	local TBContainer = Holder.TBContainer.Holder
	--[[
	-- idk probably fix for exploits that dont have this function
	if syn and syn.protect_gui then
		syn.protect_gui(Screen)
	end
	]]

	Screen.Name = HttpService:GenerateGUID(false)
	Screen.Parent = Parent
	Topbar.WindowName.Text = Config.WindowName

	MakeDraggable(Topbar,Main)
	local function CloseAll()
		for _,Tab in pairs(TContainer:GetChildren()) do
			if Tab:IsA("ScrollingFrame") then
				Tab.Visible = false
			end
		end
	end
	local function ResetAll()
		for _,TabButton in pairs(TBContainer:GetChildren()) do
			if TabButton:IsA("TextButton") then
				TabButton.BackgroundTransparency = 1
			end
		end
		for _,TabButton in pairs(TBContainer:GetChildren()) do
			if TabButton:IsA("TextButton") then
				TabButton.Size = UDim2.new(0,480 / Library.TabCount,1,0)
			end
		end
		for _,Pallete in pairs(Screen:GetChildren()) do
			if Pallete:IsA("Frame") and Pallete.Name ~= "Main" then
				Pallete.Visible = false
			end
		end
	end
	local function KeepFirst()
		for _,Tab in pairs(TContainer:GetChildren()) do
			if Tab:IsA("ScrollingFrame") then
				if Tab.Name == Library.FirstTab .. " T" then
					Tab.Visible = true
				else
					Tab.Visible = false
				end
			end
		end
		for _,TabButton in pairs(TBContainer:GetChildren()) do
			if TabButton:IsA("TextButton") then
				if TabButton.Name == Library.FirstTab .. " TB" then
					TabButton.BackgroundTransparency = 0
				else
					TabButton.BackgroundTransparency = 1
				end
			end
		end
	end
	local function Toggle(State)
		if State then
			Main.Visible = true
		elseif not State then
			for _,Pallete in pairs(Screen:GetChildren()) do
				if Pallete:IsA("Frame") and Pallete.Name ~= "Main" then
					Pallete.Visible = false
				end
			end
			Screen.ToolTip.Visible = false
			Main.Visible = false
		end
		Library.Toggle = State
	end
	local function ChangeColor(Color)
		Config.Color = Color
		for i, v in pairs(Library.ColorTable) do
			if v.BackgroundColor3 ~= Color3.fromRGB(50, 50, 50) then
				v.BackgroundColor3 = Color
			end
		end
	end

	function WindowInit:Toggle(State)
		Toggle(State)
	end

	function WindowInit:ChangeColor(Color)
		ChangeColor(Color)
	end

	function WindowInit:SetBackground(ImageId)
		Holder.Image = "rbxassetid://" .. ImageId
	end

	function WindowInit:SetBackgroundColor(Color)
		Holder.ImageColor3 = Color
	end
	function WindowInit:SetBackgroundTransparency(Transparency)
		Holder.ImageTransparency = Transparency
	end

	function WindowInit:SetTileOffset(Offset)
		Holder.TileSize = UDim2.new(0,Offset,0,Offset)
	end
	function WindowInit:SetTileScale(Scale)
		Holder.TileSize = UDim2.new(Scale,0,Scale,0)
	end

	RunService.RenderStepped:Connect(function()
		if Library.Toggle then
			Screen.ToolTip.Position = UDim2.new(0,UserInputService:GetMouseLocation().X + 10,0,UserInputService:GetMouseLocation().Y - 5)
		end
	end)

	function WindowInit:CreateTab(Name)
		local TabInit = {}
		local Tab = Folder.Tab:Clone()
		local TabButton = Folder.TabButton:Clone()

		Tab.Name = Name .. " T"
		Tab.Parent = TContainer

		TabButton.Name = Name .. " TB"
		TabButton.Parent = TBContainer
		TabButton.Title.Text = Name
		TabButton.BackgroundColor3 = Config.Color

		table.insert(Library.ColorTable, TabButton)
		Library.TabCount = Library.TabCount + 1
		if Library.TabCount == 1 then
			Library.FirstTab = Name
		end

		CloseAll()
		ResetAll()
		KeepFirst()

		local function GetSide(Longest)
			if Longest then
				if Tab.LeftSide.ListLayout.AbsoluteContentSize.Y > Tab.RightSide.ListLayout.AbsoluteContentSize.Y then
					return Tab.LeftSide
				else
					return Tab.RightSide
				end
			else
				if Tab.LeftSide.ListLayout.AbsoluteContentSize.Y > Tab.RightSide.ListLayout.AbsoluteContentSize.Y then
					return Tab.RightSide
				else
					return Tab.LeftSide
				end
			end
		end

		TabButton.MouseButton1Click:Connect(function()
			CloseAll()
			ResetAll()
			Tab.Visible = true
			TabButton.BackgroundTransparency = 0
		end)

		function TabInit:CreateSection(Name)
			local SectionInit = {}
			local Section = Folder.Section:Clone()
			local Side = GetSide()
			Section.Name = Name
			Section.Parent = Side

			function SectionInit:CreateLabel(Text)
				local LabelInit = {}
				local Label = Folder.Label:Clone()

				Label.Name = "Label"
				Label.Parent = Section
				Label.Label.Text = Text

				function LabelInit:UpdateText(Text)
					Label.Label.Text = Text
				end

				return LabelInit
			end

			function SectionInit:CreateButton(Name, Callback)
				local ButtonInit = {}
				local Button = Folder.Button:Clone()

				Button.Name = "Button"
				Button.Parent = Section
				Button.Button.Text = Name

				Button.MouseButton1Click:Connect(function()
					Callback()
				end)

				function ButtonInit:AddToolTip(Name)
					if tostring(Name):gsub(" ", "") ~= "" then
						Button.MouseEnter:Connect(function()
							Screen.ToolTip.Text = Name
							Screen.ToolTip.Size = UDim2.new(0,Screen.ToolTip.TextBounds.X + 5,0,Screen.ToolTip.TextBounds.Y + 5)
							Screen.ToolTip.Visible = true
						end)

						Button.MouseLeave:Connect(function()
							Screen.ToolTip.Visible = false
						end)
					end
				end

				return ButtonInit
			end

			function SectionInit:CreateToggle(Name, Default, Callback)
				local ToggleInit = {}
				local Toggle = Folder.Toggle:Clone()

				Toggle.Name = "Toggle"
				Toggle.Parent = Section
				Toggle.Toggle.Text = Name
				if Default == nil then
					Default = false
				end
				Toggle.Toggle.BackgroundColor3 = Default and Config.Color or Color3.fromRGB(50, 50, 50)

				Toggle.MouseButton1Click:Connect(function()
					Default = not Default
					Toggle.Toggle.BackgroundColor3 = Default and Config.Color or Color3.fromRGB(50, 50, 50)
					Callback(Default)
				end)

				function ToggleInit:AddToolTip(Name)
					if tostring(Name):gsub(" ", "") ~= "" then
						Toggle.MouseEnter:Connect(function()
							Screen.ToolTip.Text = Name
							Screen.ToolTip.Size = UDim2.new(0,Screen.ToolTip.TextBounds.X + 5,0,Screen.ToolTip.TextBounds.Y + 5)
							Screen.ToolTip.Visible = true
						end)

						Toggle.MouseLeave:Connect(function()
							Screen.ToolTip.Visible = false
						end)
					end
				end

				function ToggleInit:CreateKeybind(Key, Callback)
					local Keybind = Key
					Toggle.Keybind.Text = "["..Keybind.."]"
					local KeybindDown = UserInputService.InputBegan:Connect(function(Input)
						if Input.KeyCode == Enum.KeyCode[Keybind] then
							Callback(Keybind)
						end
					end)

					function ToggleInit:UpdateKeybind(NewKey)
						Keybind = NewKey
						Toggle.Keybind.Text = "["..Keybind.."]"
						KeybindDown:Disconnect()
						KeybindDown = UserInputService.InputBegan:Connect(function(Input)
							if Input.KeyCode == Enum.KeyCode[Keybind] then
								Callback(Keybind)
							end
						end)
					end

					return ToggleInit
				end

				function ToggleInit:SetValue(Value)
					Default = Value
					Toggle.Toggle.BackgroundColor3 = Default and Config.Color or Color3.fromRGB(50, 50, 50)
				end

				return ToggleInit
			end

			function SectionInit:CreateTextBox(Name, Placeholder, NumbersOnly, Callback)
				local TextBoxInit = {}
				local TextBox = Folder.TextBox:Clone()

				TextBox.Name = "TextBox"
				TextBox.Parent = Section
				TextBox.TextBox.PlaceholderText = Placeholder
				TextBox.TextBox.Text = ""

				TextBox.TextBox.FocusLost:Connect(function(Enter)
					if not Enter then
						if NumbersOnly then
							if tonumber(TextBox.TextBox.Text) then
								Callback(TextBox.TextBox.Text)
							else
								TextBox.TextBox.Text = ""
							end
						else
							Callback(TextBox.TextBox.Text)
						end
					end
				end)

				function TextBoxInit:AddToolTip(Name)
					if tostring(Name):gsub(" ", "") ~= "" then
						TextBox.MouseEnter:Connect(function()
							Screen.ToolTip.Text = Name
							Screen.ToolTip.Size = UDim2.new(0,Screen.ToolTip.TextBounds.X + 5,0,Screen.ToolTip.TextBounds.Y + 5)
							Screen.ToolTip.Visible = true
						end)

						TextBox.MouseLeave:Connect(function()
							Screen.ToolTip.Visible = false
						end)
					end
				end

				function TextBoxInit:SetValue(Value)
					TextBox.TextBox.Text = Value
				end

				return TextBoxInit
			end

			function SectionInit:CreateSlider(Name, Min, Max, Default, Precise, Callback)
				local SliderInit = {}
				local Slider = Folder.Slider:Clone()

				Slider.Name = "Slider"
				Slider.Parent = Section
				Slider.Label.Text = Name
				Slider.Slider.MinValue = Min
				Slider.Slider.MaxValue = Max
				if Precise == nil then
					Precise = false
				end
				if Default == nil then
					Default = Min
				end
				Slider.Slider.Value = Default
				Slider.Value.Text = tostring(Default)

				local Value
				local SliderDown
				Slider.Slider.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if SliderDown then
							SliderDown:Disconnect()
						end
						SliderDown = RunService.RenderStepped:Connect(function()
							local Mouse = UserInputService:GetMouseLocation()
							local SliderX = math.clamp(Mouse.X - Slider.Slider.AbsolutePosition.X, 0, Slider.Slider.AbsoluteSize.X) / Slider.Slider.AbsoluteSize.X
							Value = Min + (Max - Min) * SliderX
							if Precise then
								Slider.Value.Text = string.format("%.2f", Value)
							else
								Slider.Value.Text = math.floor(Value)
							end
							Slider.Slider:SetValue(Value)
							Callback(Value)
						end)
					end
				end)

				Slider.Slider.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if SliderDown then
							SliderDown:Disconnect()
						end
					end
				end)

				function SliderInit:AddToolTip(Name)
					if tostring(Name):gsub(" ", "") ~= "" then
						Slider.MouseEnter:Connect(function()
							Screen.ToolTip.Text = Name
							Screen.ToolTip.Size = UDim2.new(0,Screen.ToolTip.TextBounds.X + 5,0,Screen.ToolTip.TextBounds.Y + 5)
							Screen.ToolTip.Visible = true
						end)

						Slider.MouseLeave:Connect(function()
							Screen.ToolTip.Visible = false
						end)
					end
				end

				function SliderInit:SetValue(Value)
					Slider.Slider.Value = Value
					if Precise then
						Slider.Value.Text = string.format("%.2f", Value)
					else
						Slider.Value.Text = math.floor(Value)
					end
					Callback(Value)
				end

				return SliderInit
			end

			function SectionInit:CreateDropdown(Name, Options, Callback)
				local DropdownInit = {}
				local Dropdown = Folder.Dropdown:Clone()

				Dropdown.Name = "Dropdown"
				Dropdown.Parent = Section
				Dropdown.Dropdown.Text = Name.." ▼"
				Dropdown.Size = UDim2.new(0,480,0,30)
				Dropdown.OptionHolder.Size = UDim2.new(0,480,0,#Options * 30)
				Dropdown.OptionHolder.CanvasSize = UDim2.new(0,0,0,#Options * 30)

				for i, v in pairs(Options) do
					local Option = Folder.Option:Clone()
					Option.Name = "Option"
					Option.Parent = Dropdown.OptionHolder
					Option.Option.Text = v
					Option.Position = UDim2.new(0,0,0,(i - 1) * 30)
					Option.MouseButton1Click:Connect(function()
						Callback(v)
						Dropdown.Dropdown.Text = Name.." ▼"
						Dropdown.OptionHolder.Visible = false
					end)
				end

				Dropdown.MouseButton1Click:Connect(function()
					Dropdown.OptionHolder.Visible = not Dropdown.OptionHolder.Visible
					if Dropdown.OptionHolder.Visible then
						Dropdown.Dropdown.Text = Name.." ▲"
					else
						Dropdown.Dropdown.Text = Name.." ▼"
					end
				end)

				function DropdownInit:AddToolTip(Name)
					if tostring(Name):gsub(" ", "") ~= "" then
						Dropdown.MouseEnter:Connect(function()
							Screen.ToolTip.Text = Name
							Screen.ToolTip.Size = UDim2.new(0,Screen.ToolTip.TextBounds.X + 5,0,Screen.ToolTip.TextBounds.Y + 5)
							Screen.ToolTip.Visible = true
						end)

						Dropdown.MouseLeave:Connect(function()
							Screen.ToolTip.Visible = false
						end)
					end
				end

				function DropdownInit:SetOption(Option)
					for _, v in pairs(Dropdown.OptionHolder:GetChildren()) do
						if v:IsA("TextButton") and v.Option.Text == Option then
							v.Option.Text = Option
							Callback(Option)
						end
					end
				end

				return DropdownInit
			end

			function SectionInit:CreateColorpicker(Name, Callback)
				local ColorpickerInit = {}
				local Colorpicker = Folder.Colorpicker:Clone()
				local Pallete = Folder.ColorPallete:Clone()

				Colorpicker.Name = "Colorpicker"
				Colorpicker.Parent = Section
				Colorpicker.Color.BackgroundColor3 = Config.Color

				Pallete.Name = "ColorPallete"
				Pallete.Parent = Screen
				Pallete.Visible = false

				local ColorTable = {
					Hue = 0,
					Saturation = 0,
					Value = 1
				}

				local function UpdateColor()
					Colorpicker.Color.BackgroundColor3 = Color3.fromHSV(ColorTable.Hue,ColorTable.Saturation,ColorTable.Value)
					Pallete.GradientPallete.BackgroundColor3 = Color3.fromHSV(ColorTable.Hue,1,1)
					Pallete.Input.InputBox.PlaceholderText = "RGB: " .. math.round(Colorpicker.Color.BackgroundColor3.R* 255) .. "," .. math.round(Colorpicker.Color.BackgroundColor3.G * 255) .. "," .. math.round(Colorpicker.Color.BackgroundColor3.B * 255)
					Callback(Colorpicker.Color.BackgroundColor3)
				end

				Colorpicker.MouseButton1Click:Connect(function()
					Pallete.Visible = not Pallete.Visible
				end)

				Pallete.GradientPallete.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if ColorRender then
							ColorRender:Disconnect()
						end
						ColorRender = RunService.RenderStepped:Connect(function()
							local Mouse = UserInputService:GetMouseLocation()
							local ColorX = math.clamp(Mouse.X - Pallete.GradientPallete.AbsolutePosition.X, 0, Pallete.GradientPallete.AbsoluteSize.X) / Pallete.GradientPallete.AbsoluteSize.X
							local ColorY = math.clamp(Mouse.Y - Pallete.GradientPallete.AbsolutePosition.Y, 0, Pallete.GradientPallete.AbsoluteSize.Y) / Pallete.GradientPallete.AbsoluteSize.Y
							ColorTable.Saturation = ColorX
							ColorTable.Value = 1 - ColorY
							UpdateColor()
						end)
					end
				end)

				Pallete.GradientPallete.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if ColorRender then
							ColorRender:Disconnect()
						end
					end
				end)

				Pallete.ColorSlider.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if HueRender then
							HueRender:Disconnect()
						end
						HueRender = RunService.RenderStepped:Connect(function()
							local Mouse = UserInputService:GetMouseLocation()
							local HueX = math.clamp(Mouse.X - Pallete.ColorSlider.AbsolutePosition.X, 0, Pallete.ColorSlider.AbsoluteSize.X) / Pallete.ColorSlider.AbsoluteSize.X
							ColorTable.Hue = 1 - HueX
							UpdateColor()
						end)
					end
				end)

				Pallete.ColorSlider.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if HueRender then
							HueRender:Disconnect()
						end
					end
				end)

				function ColorpickerInit:UpdateColor(Color)
					local Hue, Saturation, Value = Color:ToHSV()
					Colorpicker.Color.BackgroundColor3 = Color3.fromHSV(Hue,Saturation,Value)
					Pallete.GradientPallete.BackgroundColor3 = Color3.fromHSV(Hue,1,1)
					Pallete.Input.InputBox.PlaceholderText = "RGB: " .. math.round(Colorpicker.Color.BackgroundColor3.R* 255) .. "," .. math.round(Colorpicker.Color.BackgroundColor3.G * 255) .. "," .. math.round(Colorpicker.Color.BackgroundColor3.B * 255)
					ColorTable = {
						Hue = Hue,
						Saturation = Saturation,
						Value = Value
					}
					Callback(Color)
				end

				Pallete.Input.InputBox.FocusLost:Connect(function(Enter)
					if Enter then
						local ColorString = string.split(string.gsub(Pallete.Input.InputBox.Text," ", ""), ",")
						ColorpickerInit:UpdateColor(Color3.fromRGB(ColorString[1],ColorString[2],ColorString[3]))
						Pallete.Input.InputBox.Text = ""
					end
				end)

				function ColorpickerInit:AddToolTip(Name)
					if tostring(Name):gsub(" ", "") ~= "" then
						Colorpicker.MouseEnter:Connect(function()
							Screen.ToolTip.Text = Name
							Screen.ToolTip.Size = UDim2.new(0,Screen.ToolTip.TextBounds.X + 5,0,Screen.ToolTip.TextBounds.Y + 5)
							Screen.ToolTip.Visible = true
						end)

						Colorpicker.MouseLeave:Connect(function()
							Screen.ToolTip.Visible = false
						end)
					end
				end

				return ColorpickerInit
			end
			return SectionInit
		end
		return TabInit
	end
	return WindowInit
end

return Library
