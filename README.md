# YTClassicDarkTheme

YTClassicDarkTheme is a standalone rootless YouTube tweak that restores the older classic gray dark theme, adds an OLED option, and supports custom dark theme colors.

The tweak is designed to keep YouTube's dark appearance customizable while staying simple and practical to use inside the YouTube app.

## Features

- **Classic Gray** theme mode
- **OLED** theme mode
- **Custom** theme mode
- **Preset custom colors**
- **Manual HEX editing**
- **HEX selection inside Custom Color**
- **Remove Rounded Corners** option
- **OLED Keyboard** option
- **In-app settings page**
- **Automatic version display in settings**
- **Standalone rootless tweak**

## Theme Modes

YTClassicDarkTheme currently supports these modes:

- **Off**
- **Classic Gray**
- **OLED**
- **Custom**

### Off
Disables the tweak’s theme mode.

### Classic Gray
Restores the older gray-style dark appearance.

### OLED
Uses a pure black style for supported themed surfaces.

### Custom
Uses the currently selected custom color.

## Custom Color

Custom Color includes:

- **Off**
- **HEX**
- **Preset colors**

Current preset colors:

- Slate Gray
- Warm Gray
- Midnight Blue
- Deep Purple
- Olive Dark
- Charcoal

## Edit HEX

HEX values can be edited from the main settings page through **Edit HEX**.

Supported formats:

- `#RRGGBB`
- `RRGGBB`

Examples:

- `#1E1E1E`
- `1E1E1E`

Invalid input is rejected.

## Remove Rounded Corners

YTClassicDarkTheme includes an optional **Remove Rounded Corners** setting.

When enabled, the rounded area below the player is removed using the tweak’s current behavior for those views.

## OLED Keyboard

YTClassicDarkTheme includes an optional **OLED Keyboard** setting.

When enabled, supported keyboard-related surfaces used inside YouTube are forced to black.

## Settings

YTClassicDarkTheme provides its settings directly inside YouTube.

Current settings:

- **Mode**
- **Custom Color**
- **Edit HEX**
- **Remove Rounded Corners**
- **OLED Keyboard**
- **Version**

## How Changes Are Applied

YTClassicDarkTheme uses a launch-time cache model.

That means changes are not fully live-applied across the app.

Restart YouTube after changing:

- Mode
- Custom Color
- Edit HEX
- Remove Rounded Corners
- OLED Keyboard

## Preferences

YTClassicDarkTheme currently uses these main preference keys:

- `classicDarkTheme_mode`
- `classicDarkTheme_oledKeyboard`
- `classicDarkTheme_removeRoundedCorners`
- `classicDarkTheme_customColor`

## Notes

- This tweak is intended to work as a **standalone rootless tweak**
- It does **not** require YouGroupSettings
- Settings are provided through YouTube’s in-app settings UI
- Theme behavior depends on YouTube’s internal UI structure
- Some surfaces may require future maintenance if YouTube changes internal classes or layouts

## Source Files

Main files currently include:

- `Tweak.x`
- `Settings.x`
- `YTCDTPrefs.h`
- `YTCDTPrefs.m`

## Version

**v0.6.0**

## Disclaimer

This project modifies YouTube’s internal UI behavior and may require updates as the app changes.

Use at your own discretion.