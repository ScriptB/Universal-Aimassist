# Universal Aimassist Repository

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-2.0-green.svg)](CHANGELOG.md)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen.svg)](README.md)
[![Roblox](https://img.shields.io/badge/Platform-Roblox-red.svg)](https://www.roblox.com)

## 🎯 Overview

The Universal Aimassist repository is a comprehensive collection of Roblox scripts and UI libraries designed for gaming purposes. It features advanced aimbot functionality, modern user interfaces, and extensive executor compatibility.

## ✨ Key Features

- 🎯 **Advanced Aimbot Suite** - Complete aimbot functionality with customizable settings
- 🎨 **Modern UI Libraries** - Professional interfaces with multiple themes
- 🔧 **Executor Compatibility** - Support for all current executors (2025-2026)
- 📊 **UNC Support** - Full UNC compatibility testing and reporting
- 🔄 **Auto-Detection** - Intelligent executor and feature detection
- 📚 **Extensive Documentation** - Comprehensive guides and tutorials

## 📁 Repository Structure

```
Universal Aimassist/
├── 📄 Scripts/                    # Main script collection
│   ├── Nexac.lua                 # Main aimbot suite (39KB)
│   ├── AimAssist.lua            # Lightweight aim assist (8.8KB)
│   ├── AimAssist_v1_Rayfield-Cleaned.lua  # Rayfield version (8.2KB)
│   ├── PhantomCMD.lua           # Command-based interface (41KB)
│   ├── PhantomSuite_BubbleGUI.lua  # Bubble UI interface (16KB)
│   ├── NexusVape.lua            # Vape-based script (439KB)
│   ├── 833sMenu_Rayfield_Loader.lua  # Rayfield menu (14KB)
│   ├── KeySystem.lua            # Key authentication (17KB)
│   ├── Loader.lua               # Script loader (1.2KB)
│   └── README.md                # Script documentation
├── 📚 Libraries/                 # UI library collection
│   ├── LaqourLib_Rebranded.lua  # Main UI library (25KB)
│   ├── LaqourLib_Fixed.lua      # Fixed version (22KB)
│   ├── LaqourLib_Patched.lua    # Patched version (24KB)
│   ├── Vape4_Library.lua        # Vape UI library (78KB)
│   ├── VapeUiRaw.lua           # Vape UI raw (2KB)
│   ├── Luna_Interface_Suite_Ui/  # Luna UI (6KB)
│   ├── Orion-Library/           # Orion UI library
│   └── README.md                # Library documentation
├── 📖 Docs/                      # Documentation
│   ├── README.md                # Main documentation
│   ├── GETTING_STARTED.md       # Quick start guide
│   ├── README_Orion_Loadstring.md  # Orion usage guide
│   └── README_Orion_Setup.md    # Orion setup guide
├── 🗂️ Archive/                   # Archived content
│   ├── UI-Libraries-main/       # Library collection (210+ libraries)
│   └── README.md                # Archive documentation
├── 📄 REPOSITORY_STRUCTURE.md    # Structure documentation
├── 📄 README.md                 # This file
└── 📄 .git/                     # Git repository
```

## 🚀 Quick Start

### **1. Choose Your Script**

#### **🎯 Nexac Suite (Recommended)**
- **Features**: Complete aimbot with LaqourLib UI
- **Size**: 39KB
- **Compatibility**: All current executors
- **UNC Support**: Full UNC compatibility
- **Loadstring**: `https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/main/Scripts/Nexac.lua`

#### **🎯 AimAssist (Lightweight)**
- **Features**: Basic aim assist functionality
- **Size**: 8.8KB
- **Compatibility**: Universal
- **UNC Support**: High compatibility
- **Loadstring**: `https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/main/Scripts/AimAssist.lua`

#### **🎯 Rayfield Version**
- **Features**: Rayfield UI integration
- **Size**: 8.2KB
- **Compatibility**: Rayfield executors
- **UNC Support**: Good compatibility
- **Loadstring**: `https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/main/Scripts/AimAssist_v1_Rayfield-Cleaned.lua`

### **2. Check Executor Compatibility**

| Script | Synapse X | KRNL | Script-Ware | Ronix | JJSploit | Solara | Delta | Xeno | Punk X | Velocity |
|--------|----------|------|------------|-------|----------|--------|--------|-------|------|--------|----------|
| Nexac | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| AimAssist | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Rayfield | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Phantom | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Vape | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

### **3. Execute Your Script**

```lua
-- Example: Loading Nexac Suite
local Nexac = loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/main/Scripts/Nexac.lua"))()
Nexac:Initialize()
```

## 🎨 UI Libraries

### **LaqourLib (Recommended)**
- **File**: `Libraries/LaqourLib_Rebranded.lua`
- **Size**: 25KB
- **Features**: Complete UI system with tabs, sections, and controls
- **Status**: Active development
- **Loadstring**: `https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/main/Libraries/LaqourLib_Rebranded.lua`

```lua
-- Example: Using LaqourLib
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

### **Other Available Libraries**
- **Vape UI** - Professional gaming interface
- **Orion UI** - Industry standard UI system
- **Luna UI** - Lightweight alternative

## 📊 UNC Compatibility

### **Executor UNC Levels (2025-2026)**

| Executor | UNC % | Level | Status | Source |
|----------|--------|-------|--------|--------|
| Ronix | 100% | Level 8 | ✅ Active | WeAreDevs |
| Delta | 100% | Level 8 | ✅ Active | WeAreDevs |
| LX63 | 100% | Level 8 | ✅ Active | WeAreDevs |
| Punk X | 100% | Level 8 | ✅ Active | WeAreDevs |
| JJSploit | 98% | Level 7 | ✅ Active | YouTube Testing |
| Velocity | 98% | Level 7 | ✅ Active | Official Website |
| Xeno | 90% | Level 7 | ✅ Active | Official Website |
| Drift | 85% | Level 7 | ✅ Active | WeAreDevs |
| Valex | 75% | Level 6 | ✅ Active | WeAreDevs |
| Pluto | 70% | Level 6 | ✅ Active | WeAreDevs |
| Solara | 66% | Level 6 | ✅ Active | Official Website |
| CheatHub | 60% | Level 6 | ✅ Active | WeAreDevs |

### **Essential UNC Functions**
- **httpget** - HTTP requests
- **require** - Module loading
- **loadstring** - Script execution

## 🔧 Features

### **Nexac Suite Features**
- ✅ **Advanced Aimbot** - Multiple aim modes and settings
- ✅ **ESP System** - Player visualization and tracking
- ✅ **Visual Enhancements** - Fullbright, no fog, crosshair
- ✅ **Movement Tools** - Speed, fly, jump power
- ✅ **Settings Management** - Save/load configurations
- ✅ **Executor Detection** - Automatic compatibility checking
- ✅ **UNC Testing** - Real-time UNC compatibility reporting

### **UI Library Features**
- ✅ **Modern Interface** - Professional, clean design
- ✅ **Responsive Layout** - Adapts to different screen sizes
- ✅ **Customizable Themes** - Multiple color schemes
- ✅ **Smooth Animations** - Fluid transitions and effects
- ✅ **Draggable Windows** - Easy window positioning
- ✅ **Tooltips** - Helpful hover information
- ✅ **Configuration Saving** - Persistent user settings

## 📋 Requirements

### **System Requirements**
- **Roblox Executor** - Compatible with current executors
- **UNC Support** - Recommended for full functionality
- **HTTP Access** - For loading external libraries
- **Script Execution** - Basic script execution capabilities

### **Supported Executors**
- **Premium**: Synapse X, KRNL, Script-Ware, Ronix
- **Free**: JJSploit, Solara, Delta, Xeno, Punk X, Velocity
- **Mobile**: Delta, mobile-specific executors
- **Legacy**: Limited support for older executors

## 🔄 Updates & Maintenance

### **Version History**
- **v2.0** - Nexac Suite with rebranded LaqourLib
- **v1.5** - Added Rayfield support and UNC testing
- **v1.0** - Initial repository setup
- **v0.5** - Legacy script collection

### **Recent Updates**
- ✅ **LaqourLib Rebranded** - Complete Bracket library rebrand
- ✅ **Executor Updates** - Added 2025-2026 executors
- ✅ **UNC Data** - Updated with current compatibility
- ✅ **Documentation** - Comprehensive guides and tutorials
- ✅ **Repository Structure** - Streamlined organization

### **Maintenance Schedule**
- **Weekly**: Check for executor updates
- **Monthly**: Update UNC compatibility data
- **Quarterly**: Review and update documentation
- **Annually**: Major feature updates and reorganization

## 🛠️ Development

### **Contributing Guidelines**
1. **Fork** the repository
2. **Create** a feature branch
3. **Make** your changes
4. **Test** thoroughly
5. **Submit** a pull request
6. **Wait** for review and merge

### **Code Standards**
- **Lua 5.1** compatibility
- **Proper error handling**
- **Comprehensive documentation**
- **Consistent naming conventions**
- **Security best practices**

### **Testing Requirements**
- **Multiple executors** - Test on different platforms
- **UNC compatibility** - Verify function availability
- **UI functionality** - Test all interface elements
- **Performance** - Check for memory leaks and optimization

## 📞 Support

### **Documentation**
- **Getting Started**: `Docs/GETTING_STARTED.md`
- **Script Documentation**: `Scripts/README.md`
- **Library Documentation**: `Libraries/README.md`
- **Archive Documentation**: `Archive/README.md`

### **Community Support**
- **GitHub Issues**: Report bugs and request features
- **Discord**: Community support channels
- **Forums**: Developer discussions
- **Wiki**: Community knowledge base

### **Direct Support**
- **Repository Maintainers**: Contact via GitHub
- **Developer Guides**: Technical documentation
- **Video Tutorials**: Visual learning resources
- **FAQ**: Common questions and answers

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Bracket Library** - Original LaqourLib source
- **Orion UI** - Industry standard UI system
- **Vape UI** - Gaming interface components
- **Community Contributors** - Feature suggestions and testing
- **Executor Developers** - Compatibility testing and feedback

## 📈 Statistics

### **Repository Metrics**
- **Total Scripts**: 9 main scripts
- **UI Libraries**: 4 active libraries
- **Archive Libraries**: 210+ libraries
- **Documentation**: 8 comprehensive guides
- **Repository Size**: ~50MB

### **Usage Statistics**
- **Nexac Suite**: Most popular script
- **LaqourLib**: Most used UI library
- **Ronix**: Most compatible executor
- **WeAreDevs**: Primary source for UNC data

## 🔒 Security

### **Security Measures**
- ✅ **Code Review** - All scripts reviewed for security
- ✅ **No Malicious Code** - Verified safe to use
- ✅ **Regular Updates** - Security patches applied
- ✅ **Community Testing** - Extensive user testing
- ✅ **Open Source** - Full transparency

### **Best Practices**
- **Use trusted executors** - Verified compatibility
- **Check script integrity** - Verify loadstring URLs
- **Test in safe environments** - Before production use
- **Keep scripts updated** - Latest security patches
- **Report issues** - Security concerns immediately

## 🎉 Conclusion

The Universal Aimassist repository provides a comprehensive solution for Roblox script development with modern UI libraries, extensive executor compatibility, and professional documentation. Whether you're a beginner or an advanced user, you'll find the tools and resources you need to create powerful Roblox scripts.

**Get started now!** 🚀

---

**Repository Status**: ✅ Active  
**Last Updated**: Current  
**Version**: 2.0  
**License**: MIT
