# Universal Aimassist Repository

## Overview
This repository contains Roblox scripts and UI libraries for gaming purposes, including aimbot functionality and user interfaces.

## Main Files

### 🎯 PhantomSuite.lua
- **Version**: 7.6
- **Features**: Comprehensive aimbot suite with embedded Orion UI
- **Status**: Production ready with embedded UI system

### 📚 UI Libraries

#### Orion UI Library
- **Location**: `Orion-Library/source.lua`
- **Loadstring URL**: `https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/main/Orion-Library/source.lua`
- **Usage**: 
  ```lua
  local Orion = loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/main/Orion-Library/source.lua"))()
  ```

#### Additional UI Libraries
- **Location**: `UI-Libraries-main/`
- **Contents**: Various UI libraries for different use cases
- **Status**: Archive collection

## Project Structure

```
├── PhantomSuite.lua          # Main aimbot script
├── Orion-Library/           # Hosted Orion UI library
│   └── source.lua          # Loadstring-ready source
├── UI-Libraries-main/      # Archive of UI libraries
├── README_Orion_Loadstring.md  # Orion usage instructions
└── README.md               # This file
```

## Branch Management
- **Main Branch**: `main` (primary development branch)
- **Previous**: `master` (deprecated and removed)

## Usage Instructions

### Loading Orion UI
```lua
local Orion = loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptB/Universal-Aimassist/main/Orion-Library/source.lua"))()

local Window = OrionLib:MakeWindow({
    Name = "My Script",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionConfig"
})
```

### Using PhantomSuite
1. Execute `PhantomSuite.lua` in your Roblox executor
2. The script includes embedded UI system
3. Configure settings through the interface

## Features
- ✅ GitHub-hosted UI libraries
- ✅ Loadstring compatibility
- ✅ Embedded UI system (no external dependencies)
- ✅ Multiple UI library options
- ✅ Comprehensive aimbot functionality

## Repository Status
- **Active**: ✅ Maintained
- **Branch**: main
- **Last Updated**: Current with Orion UI hosting

## Notes
- All UI libraries are optimized for Roblox executors
- External HTTP requests minimized for reliability
- Configuration files saved locally when enabled
