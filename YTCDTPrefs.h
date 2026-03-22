#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YTCDTThemeMode) {
    YTCDTThemeModeOff = 0,
    YTCDTThemeModeClassicGray = 1,
    YTCDTThemeModeOLED = 2,
    YTCDTThemeModeCustom = 3,
};

YTCDTThemeMode YTCDTThemeModeValue(void);
BOOL YTCDTOLEDKeyboardEnabled(void);

BOOL YTCDTHasCustomThemeColor(void);
UIColor *YTCDTCustomThemeColor(void);
NSString *YTCDTCustomThemeColorHexString(void);

void YTCDTSetThemeMode(YTCDTThemeMode mode);
void YTCDTSetOLEDKeyboardEnabled(BOOL enabled);
void YTCDTSetCustomThemeColor(UIColor *color);
BOOL YTCDTSetCustomThemeColorFromHexString(NSString *hexString);
void YTCDTClearCustomThemeColor(void);
