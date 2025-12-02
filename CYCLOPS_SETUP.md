# Cyclops Level Builder Setup Guide

This guide will help you install and configure Cyclops Level Builder for your project.

## Prerequisites

- ✅ Godot 4.5 (you have this!)
- ✅ Cyclops Level Builder v1.0.2+ (compatible with Godot 4.2+)

## Installation Steps

### Step 1: Download Cyclops Level Builder

1. Go to the [Cyclops Level Builder Releases page](https://github.com/blackears/cyclopsLevelBuilder/releases)
2. Download the **latest release** (recommended: v1.0.2 or newer)
3. Extract the ZIP file to a temporary location

### Step 2: Copy Plugin Files

You need to copy the plugin folder to your project:

1. From the extracted ZIP, find the `addons/cyclops_level_builder` folder
2. Copy the entire `cyclops_level_builder` folder
3. Paste it into your project's `addons/` directory

**Project structure should look like:**
```
projectB/
├── addons/
│   └── cyclops_level_builder/
│       ├── (all plugin files)
│       └── plugin.cfg
├── data/
├── entity/
└── ...
```

### Step 3: Enable the Autoload

1. Open Godot Editor
2. Go to **Project → Project Settings**
3. Click the **Autoload** tab
4. Click the folder icon next to the **Path** field
5. Browse to: `res://addons/cyclops_level_builder/cyclops_global_scene.tscn`
6. Set the **Node Name** to: `CyclopsAutoload` (case-sensitive! Only C and A capitalized)
7. Click **Add**
8. Make sure the **Enable** checkbox is checked

### Step 4: Enable the Plugin

1. Still in **Project Settings**, click the **Plugins** tab
2. Find **Cyclops Level Builder** in the list
3. Check the **Enable** checkbox next to it
4. You may need to restart Godot for the plugin to fully activate

## Verification

After installation, you should see:

1. **New toolbar buttons** in the 3D viewport (Cyclops tools)
2. **Cyclops menu** in the editor menu bar
3. **No errors** in the Output panel

## Usage

Once installed, you can:

1. **Create blocks**: Click and drag in the viewport to create blocks
2. **Edit blocks**: Select blocks and use the material editor
3. **Toggle collision**: All blocks have collision automatically
4. **Layer management**: Use visibility toggles for different layers

## Troubleshooting

### Errors after installation
- **Close and reopen your project twice** - Godot needs to rebuild its class name cache
- Make sure the autoload name is exactly `CyclopsAutoload` (case-sensitive)

### Plugin not showing up
- Check that the plugin folder is in `addons/cyclops_level_builder/`
- Verify `plugin.cfg` exists in that folder
- Restart Godot completely

### Version compatibility
- Make sure you downloaded a version compatible with Godot 4.5
- Version 1.0.2+ works with Godot 4.2+

## Next Steps

Once Cyclops is installed:
1. Replace your GridMap-based maze with Cyclops blocks
2. Use visual editing for easier iteration
3. Toggle visibility of layers (floor, walls, ceiling) easily

## Resources

- [Cyclops Level Builder GitHub](https://github.com/blackears/cyclopsLevelBuilder)
- [Documentation](https://github.com/blackears/cyclopsLevelBuilder/blob/master/README.md)

