# UI Libraries Directory

This directory contains the main UI libraries used by scripts in this repository.

## 🎯 Primary Libraries

### **LaqourLib (Recommended)**
- **File**: `LaqourLib_Rebranded.lua`
- **Size**: 25KB
- **Source**: Rebranded from Bracket library
- **Features**: Complete UI system with tabs, sections, and controls
- **Status**: Active development
- **Loadstring**: `https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/main/Libraries/LaqourLib_Rebranded.lua`

### **LaqourLib Fixed**
- **File**: `LaqourLib_Fixed.lua`
- **Size**: 22KB
- **Features**: Fixed version without asset dependencies
- **Status**: Backup version
- **Purpose**: Fallback if main version fails

### **LaqourLib Patched**
- **File**: `LaqourLib_Patched.lua`
- **Size**: 24KB
- **Features**: Patched version with dynamic UI creation
- **Status**: Alternative version
- **Purpose**: No asset loading issues

### **Vape UI Library**
- **File**: `Vape4_Library.lua`
- **Size**: 78KB
- **Features**: Vape-style UI components
- **Status**: Active
- **Compatibility**: Vape executors

### **Vape UI Raw**
- **File**: `VapeUiRaw.lua`
- **Size**: 2KB
- **Features**: Minimal Vape UI
- **Status**: Lightweight version

### **Luna Interface Suite**
- **File**: `Luna_Interface_Suite_Ui.lua`
- **Size**: 6KB
- **Features**: Luna-style interface
- **Status**: Alternative UI option

### **Orion UI Library**
- **Directory**: `Orion-Library/`
- **File**: `source.lua`
- **Features**: Professional UI system
- **Status**: Industry standard
- **Loadstring**: `https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/main/Libraries/Orion-Library/source.lua`

## 🔧 Usage Instructions

### **Loading LaqourLib (Recommended)**
```lua
local Laqour = loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/main/Libraries/LaqourLib_Rebranded.lua"))()

local Window = Laqour:CreateWindow({
    WindowName = "My Script",
    Color = Color3.new(0, 0.7, 1)
}, game:GetService("CoreGui"))

local Tab = Window:CreateTab("Main")
local Section = Tab:CreateSection("Settings")
local Toggle = Section:CreateToggle("Enable Feature", false, function(Value)
    print("Feature:", Value)
end)
```

### **Loading Vape UI**
```lua
local Vape = loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/main/Libraries/Vape4_Library.lua"))()

local Window = Vape:CreateWindow({
    Name = "Vape UI",
    Size = UDim2.new(0, 600, 0, 400),
    Theme = "Dark"
})
```

### **Loading Orion UI**
```lua
local Orion = loadstring(game:GetObjects("rbxassetid://7141683860")[1]

local Window = OrionLib:MakeWindow({
    Name = "Orion UI",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionConfig"
})
```

## 📋 Library Comparison

| Library | Size | Features | Asset Loading | Customization | Status |
|---------|------|---------|---------------|-------------|--------|
| LaqourLib | 25KB | Complete | No assets | High | ✅ Active |
| Vape UI | 78KB | Professional | Yes | Medium | ✅ Active |
| Orion UI | 50KB | Industry | Yes | Low | ✅ Active |
| Luna UI | 6KB | Simple | No assets | Low | ✅ Active |

## 🎨 UI Components Available

### **LaqourLib Components:**
- ✅ Windows with dragging
- ✅ Tab system with sections
- ✅ Labels with text updates
- ✅ Buttons with tooltips
- ✅ Text boxes with validation
- ✅ Toggles with keybinds
- ✅ Sliders with precision
- ✅ Dropdowns with options
- ✅ Color pickers with HSV
- ✅ Tooltips for all elements

### **Vape UI Components:**
- ✅ Modern interface design
- ✅ Theme support
- ✅ Configuration saving
- ✅ Professional animations

### **Orion UI Components:**
- ✅ Industry standard UI
- ✅ Configuration system
- ✅ Premium features
- ✅ Extensive customization

## 🔒 Security & Compatibility

### **✅ Safe Libraries:**
- No malicious code
- Regular security updates
- Community tested
- Open source transparency

### **✅ Executor Support:**
- **LaqourLib**: All current executors (2025-2026)
- **Vape UI**: Vape-compatible executors
- **Orion UI**: Premium executors
- **Luna UI**: Universal compatibility

### **✅ Performance:**
- **LaqourLib**: Lightweight and fast
- **Vape UI**: Optimized for gaming
- **Orion UI**: Professional grade
- **Luna UI**: Minimal overhead

## 🔄 Version Management

### **LaqourLib Versions:**
- **Rebranded**: Latest version with Bracket rebranding
- **Fixed**: Asset dependency fixes
- **Patched**: Dynamic UI creation
- **Original**: Legacy version (archived)

### **Loading Priority:**
1. **Rebranded** (recommended)
2. **Fixed** (fallback)
3. **Patched** (alternative)
4. **Original** (last resort)

## 📚 Documentation

- **Main README**: Repository overview
- **Scripts README**: Script documentation
- **Archive README**: Library collection index
- **Individual READMEs**: Library-specific guides

## 🚀 Getting Started

1. **Choose a library** based on your needs
2. **Copy the loadstring** from the table above
3. **Integrate** with your script
4. **Test** in your executor
5. **Configure** UI elements as needed

## 🤝 Contributing

- **Report issues** via GitHub
- **Submit pull requests** for improvements
- **Share custom themes** and configurations
- **Document new features** and components

## 📞 Support Channels

- **GitHub Issues**: Repository issues
- **Documentation**: README files
- **Community**: Discord/Forum links
- **Direct**: Repository maintainers
