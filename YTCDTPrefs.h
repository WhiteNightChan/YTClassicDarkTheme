#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YTCDTThemeMode) {
    YTCDTThemeModeOff = 0,
    YTCDTThemeModeClassicGray = 1,
    YTCDTThemeModeOLED = 2,
    YTCDTThemeModeCustom = 3,
};

YTCDTThemeMode YTCDTThemeModeValue(void);
BOOL YTCDTOLEDKeyboardEnabled(void);
BOOL YTCDTRemoveRoundedCornersEnabled(void);

BOOL YTCDTHasCustomThemeColor(void);
UIColor *YTCDTCustomThemeColor(void);
NSString *YTCDTCustomThemeColorHexString(void);

BOOL YTCDTHasSavedHexColor(void);
NSString *YTCDTSavedHexColorString(void);
BOOL YTCDTActivateSavedHexColor(void);

void YTCDTSetThemeMode(YTCDTThemeMode mode);
void YTCDTSetOLEDKeyboardEnabled(BOOL enabled);
void YTCDTSetRemoveRoundedCornersEnabled(BOOL enabled);
void YTCDTSetCustomThemeColor(UIColor *color);
BOOL YTCDTSetCustomThemeColorFromHexString(NSString *hexString);
void YTCDTClearCustomThemeColor(void);
