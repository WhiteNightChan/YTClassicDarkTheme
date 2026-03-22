#import "YTCDTPrefs.h"

static NSString * const kYTCDTThemeModeKey = @"classicDarkTheme_mode";
static NSString * const kYTCDTOLEDKeyboardKey = @"classicDarkTheme_oledKeyboard";
static NSString * const kYTCDTCustomColorKey = @"classicDarkTheme_customColor";

static inline NSUserDefaults *YTCDTDefaults(void) {
    return [NSUserDefaults standardUserDefaults];
}

YTCDTThemeMode YTCDTThemeModeValue(void) {
    return (YTCDTThemeMode)[YTCDTDefaults() integerForKey:kYTCDTThemeModeKey];
}

BOOL YTCDTOLEDKeyboardEnabled(void) {
    return [YTCDTDefaults() boolForKey:kYTCDTOLEDKeyboardKey];
}

BOOL YTCDTHasCustomThemeColor(void) {
    return [YTCDTDefaults() objectForKey:kYTCDTCustomColorKey] != nil;
}

UIColor *YTCDTCustomThemeColor(void) {
    NSData *colorData = [YTCDTDefaults() objectForKey:kYTCDTCustomColorKey];
    if (!colorData) {
        return nil;
    }

    NSError *error = nil;
    NSKeyedUnarchiver *unarchiver =
        [[NSKeyedUnarchiver alloc] initForReadingFromData:colorData error:&error];
    if (error || !unarchiver) {
        return nil;
    }

    [unarchiver setRequiresSecureCoding:NO];
    id decodedObject = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    return [decodedObject isKindOfClass:[UIColor class]] ? decodedObject : nil;
}

void YTCDTSetThemeMode(YTCDTThemeMode mode) {
    [YTCDTDefaults() setInteger:mode forKey:kYTCDTThemeModeKey];
    [YTCDTDefaults() synchronize];
}

void YTCDTSetOLEDKeyboardEnabled(BOOL enabled) {
    [YTCDTDefaults() setBool:enabled forKey:kYTCDTOLEDKeyboardKey];
    [YTCDTDefaults() synchronize];
}

void YTCDTSetCustomThemeColor(UIColor *color) {
    if (!color) {
        YTCDTClearCustomThemeColor();
        return;
    }

    NSError *error = nil;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color
                                             requiringSecureCoding:NO
                                                             error:&error];
    if (!error && colorData) {
        [YTCDTDefaults() setObject:colorData forKey:kYTCDTCustomColorKey];
        [YTCDTDefaults() synchronize];
    }
}

void YTCDTClearCustomThemeColor(void) {
    [YTCDTDefaults() removeObjectForKey:kYTCDTCustomColorKey];
    [YTCDTDefaults() synchronize];
}

void YTCDTSynchronize(void) {
    [YTCDTDefaults() synchronize];
}
