# YTClassicDarkTheme

YTClassicDarkTheme is a standalone rootless YouTube tweak that restores the older darker gray appearance, provides an OLED pure black option, and now supports custom dark theme colors including manual HEX input.

This tweak is designed to apply a darker theme across YouTube while keeping the implementation simple and stable. Theme changes are applied through launch-time caching, so changes take effect after restarting YouTube.

## Features

YTClassicDarkTheme currently provides the following theme modes:

- **Off**
- **Classic Gray**
- **OLED**
- **Custom**

It also provides:

- **OLED Keyboard** toggle
- **Preset custom colors**
- **Manual HEX color input**
- **In-app YouTube settings integration**
- **Standalone operation without YouGroupSettings dependency**

## Theme Modes

### Off
Disables YTClassicDarkTheme.

### Classic Gray
Restores the older gray-style dark appearance instead of YouTube’s newer darker palette.

### OLED
Uses pure black where the tweak’s active theme color is applied.

### Custom
Uses a saved custom theme color.

If Custom mode is selected but no custom color is saved, the mode will not apply until a valid custom color is stored.

## OLED Keyboard

YTClassicDarkTheme includes an optional OLED Keyboard setting.

When enabled, supported keyboard-related surfaces used inside YouTube are forced to black. Like the main theme setting, this is applied after restarting YouTube.

## Settings

YTClassicDarkTheme provides its settings inside YouTube’s own settings UI.

Current settings:

- **Mode**
- **OLED Keyboard**
- **Custom Color**
- **HEX Color**

These settings appear and function even without YouGroupSettings.

## Custom Color

Custom Color supports preset dark colors:

- Slate Gray
- Warm Gray
- Midnight Blue
- Deep Purple
- Olive Dark
- Charcoal
- None

Selecting a preset color automatically sets **Mode** to **Custom**.

Selecting **None** clears the saved custom color. If the current mode is **Custom**, selecting **None** also sets **Mode** to **Off**.

## HEX Color

YTClassicDarkTheme supports manual HEX color entry for custom theme colors.

Supported formats:

- `#RRGGBB`
- `RRGGBB`

Examples:

- `#1E1E1E`
- `1E1E1E`

Behavior:

- Saving a valid HEX color automatically sets **Mode** to **Custom**
- Invalid HEX input is rejected
- Invalid input does not overwrite the existing saved color
- The saved custom color status can appear as a HEX string when it does not match a preset color

## How Settings Are Stored

YTClassicDarkTheme uses the following preference keys:

- `classicDarkTheme_mode`
- `classicDarkTheme_oledKeyboard`
- `classicDarkTheme_customColor`

Mode values:

- `0 = Off`
- `1 = Classic Gray`
- `2 = OLED`
- `3 = Custom`

The custom theme color is stored as a serialized `UIColor`, not as a raw HEX string. HEX input is converted to `UIColor` before saving. This keeps the runtime theme application path compatible with existing behavior.

## Apply Behavior

YTClassicDarkTheme uses a launch-time cache model.

That means:

- theme settings are read when YouTube starts
- changing settings does **not** live-refresh the whole theme
- you must **restart YouTube** after changing:
  - Mode
  - OLED Keyboard
  - Custom Color
  - HEX Color

## Notes

- This tweak is intended to be a **standalone rootless tweak**
- It is implemented using `Tweak.x`
- Preference access is centralized in `YTCDTPrefs.h` / `YTCDTPrefs.m`
- In-app settings are provided through `Settings.x`
- YouGroupSettings is **not required**
- A comments-detail bright gray leak on the left side was resolved with a minimal `_ASDisplayView` background fill adjustment for `id.ui.comment_cell`
- The tweak intentionally uses a fill-based approach in certain places to reduce visual mismatch and help avoid screen-burn-style bright patches

## Compatibility Notes

Because the tweak relies on YouTube internal classes and view structures, some areas may require additional maintenance if YouTube changes internal UI behavior.

The theme is currently based on targeted background overrides and related hooks. Future YouTube updates may introduce new surfaces that need separate coverage.

## Source Layout

Typical relevant files:

- `Tweak.x`
- `Settings.x`
- `YTCDTPrefs.h`
- `YTCDTPrefs.m`

## Version

**v0.5.0**

### Highlights in v0.5.0

- Added **manual HEX custom color input**
- Preserved existing `UIColor`-based saved color format
- Kept `Tweak.x` theme application flow unchanged
- Added HEX-based custom color status display for non-preset saved colors
- Preserved existing preset color, None, Custom mode, and OLED Keyboard behavior

## Usage

1. Open YouTube settings
2. Open **Classic Dark Theme**
3. Choose a theme mode, preset color, or enter a HEX color
4. Restart YouTube
5. Reopen YouTube to see the applied theme

## Disclaimer

This project modifies YouTube’s internal UI behavior and may require updates as the app changes.
Use at your own discretion.
