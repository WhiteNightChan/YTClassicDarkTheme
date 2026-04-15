#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YTCDTThemeType) {
    YTCDTThemeTypeBuiltIn = 0,
    YTCDTThemeTypeCustomColor = 1,
};

typedef NS_ENUM(NSInteger, YTCDTBuiltInStyle) {
    YTCDTBuiltInStyleClassicGray = 0,
    YTCDTBuiltInStyleOLED = 1,
};

typedef NS_ENUM(NSInteger, YTCDTCustomColorSource) {
    YTCDTCustomColorSourceUnset = 0,
    YTCDTCustomColorSourceHex = 1,
    YTCDTCustomColorSourcePreset = 2,
};

BOOL YTCDTEnabled(void);
void YTCDTSetEnabled(BOOL enabled);

YTCDTThemeType YTCDTThemeTypeValue(void);
void YTCDTSetThemeType(YTCDTThemeType themeType);

YTCDTBuiltInStyle YTCDTBuiltInStyleValue(void);
void YTCDTSetBuiltInStyle(YTCDTBuiltInStyle builtInStyle);

YTCDTCustomColorSource YTCDTCustomColorSourceValue(void);
void YTCDTSetCustomColorSource(YTCDTCustomColorSource source);

BOOL YTCDTHasCustomThemeColor(void);
UIColor *YTCDTCustomThemeColor(void);
NSString *YTCDTCustomThemeColorHexString(void);
void YTCDTSetCustomThemeColor(UIColor *color);
BOOL YTCDTSetCustomThemeColorFromHexString(NSString *hexString);
void YTCDTClearCustomThemeColor(void);

BOOL YTCDTHasSavedHexColor(void);
NSString *YTCDTSavedHexColorString(void);
BOOL YTCDTActivateSavedHexColor(void);

BOOL YTCDTHasCustomPresetIdentifier(void);
NSString *YTCDTCustomPresetIdentifier(void);
void YTCDTSetCustomPresetIdentifier(NSString *identifier);
void YTCDTClearCustomPresetIdentifier(void);

BOOL YTCDTOLEDKeyboardEnabled(void);
void YTCDTSetOLEDKeyboardEnabled(BOOL enabled);

BOOL YTCDTRemoveRoundedCornersEnabled(void);
void YTCDTSetRemoveRoundedCornersEnabled(BOOL enabled);

BOOL YTCDTDisablePullToFullEnabled(void);
void YTCDTSetDisablePullToFullEnabled(BOOL enabled);

BOOL YTCDTHidePreviewCommentSectionEnabled(void);
void YTCDTSetHidePreviewCommentSectionEnabled(BOOL enabled);
