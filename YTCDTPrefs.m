#import "YTCDTPrefs.h"

static NSString * const kYTCDTEnabledKey = @"classicDarkTheme_enabled";
static NSString * const kYTCDTThemeTypeKey = @"classicDarkTheme_themeType";
static NSString * const kYTCDTBuiltInStyleKey = @"classicDarkTheme_builtInStyle";
static NSString * const kYTCDTCustomColorSourceKey = @"classicDarkTheme_customColorSource";

static NSString * const kYTCDTCustomColorKey = @"classicDarkTheme_customColor";
static NSString * const kYTCDTSavedHexColorKey = @"classicDarkTheme_savedHexColor";
static NSString * const kYTCDTCustomPresetIdentifierKey = @"classicDarkTheme_customPresetIdentifier";

static NSString * const kYTCDTOLEDKeyboardKey = @"classicDarkTheme_oledKeyboard";
static NSString * const kYTCDTRemoveRoundedCornersKey = @"classicDarkTheme_removeRoundedCorners";

static NSString * const kYTCDTDisablePullToFullKey = @"classicDarkTheme_disablePullToFull";
static NSString * const kYTCDTHidePreviewCommentSectionKey = @"classicDarkTheme_hidePreviewCommentSection";

static inline NSUserDefaults *YTCDTDefaults(void) {
    return [NSUserDefaults standardUserDefaults];
}

static NSString *YTCDTNormalizedHexString(NSString *hexString) {
    if (![hexString isKindOfClass:[NSString class]]) {
        return nil;
    }

    NSString *trimmed =
        [[hexString stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    if ([trimmed hasPrefix:@"#"]) {
        trimmed = [trimmed substringFromIndex:1];
    }

    if (trimmed.length != 6) {
        return nil;
    }

    NSCharacterSet *allowed =
        [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];

    for (NSUInteger i = 0; i < trimmed.length; i++) {
        if (![allowed characterIsMember:[trimmed characterAtIndex:i]]) {
            return nil;
        }
    }

    return [@"#" stringByAppendingString:trimmed];
}

static UIColor *YTCDTColorFromHexString(NSString *hexString) {
    NSString *normalizedHex = YTCDTNormalizedHexString(hexString);
    if (!normalizedHex) {
        return nil;
    }

    unsigned int hexValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:[normalizedHex substringFromIndex:1]];
    if (![scanner scanHexInt:&hexValue]) {
        return nil;
    }

    return [UIColor colorWithRed:((hexValue >> 16) & 0xFF) / 255.0
                           green:((hexValue >> 8) & 0xFF) / 255.0
                            blue:(hexValue & 0xFF) / 255.0
                           alpha:1.0];
}

static NSString *YTCDTHexStringFromColor(UIColor *color) {
    if (!color) {
        return nil;
    }

    CGFloat r = 0.0;
    CGFloat g = 0.0;
    CGFloat b = 0.0;
    CGFloat a = 0.0;

    if (![color getRed:&r green:&g blue:&b alpha:&a]) {
        CGFloat white = 0.0;
        if ([color getWhite:&white alpha:&a]) {
            r = white;
            g = white;
            b = white;
        } else {
            return nil;
        }
    }

    NSUInteger red = (NSUInteger)(r * 255.0f + 0.5f);
    NSUInteger green = (NSUInteger)(g * 255.0f + 0.5f);
    NSUInteger blue = (NSUInteger)(b * 255.0f + 0.5f);

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            (unsigned long)red,
            (unsigned long)green,
            (unsigned long)blue];
}

static BOOL YTCDTStoreCustomThemeColor(UIColor *color) {
    if (!color) {
        return NO;
    }

    NSError *error = nil;
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color
                                             requiringSecureCoding:NO
                                                             error:&error];
    if (error || !colorData) {
        return NO;
    }

    [YTCDTDefaults() setObject:colorData forKey:kYTCDTCustomColorKey];
    return YES;
}

BOOL YTCDTEnabled(void) {
    return [YTCDTDefaults() boolForKey:kYTCDTEnabledKey];
}

void YTCDTSetEnabled(BOOL enabled) {
    [YTCDTDefaults() setBool:enabled forKey:kYTCDTEnabledKey];
    [YTCDTDefaults() synchronize];
}

YTCDTThemeType YTCDTThemeTypeValue(void) {
    return (YTCDTThemeType)[YTCDTDefaults() integerForKey:kYTCDTThemeTypeKey];
}

void YTCDTSetThemeType(YTCDTThemeType themeType) {
    [YTCDTDefaults() setInteger:themeType forKey:kYTCDTThemeTypeKey];
    [YTCDTDefaults() synchronize];
}

YTCDTBuiltInStyle YTCDTBuiltInStyleValue(void) {
    return (YTCDTBuiltInStyle)[YTCDTDefaults() integerForKey:kYTCDTBuiltInStyleKey];
}

void YTCDTSetBuiltInStyle(YTCDTBuiltInStyle builtInStyle) {
    [YTCDTDefaults() setInteger:builtInStyle forKey:kYTCDTBuiltInStyleKey];
    [YTCDTDefaults() synchronize];
}

YTCDTCustomColorSource YTCDTCustomColorSourceValue(void) {
    return (YTCDTCustomColorSource)[YTCDTDefaults() integerForKey:kYTCDTCustomColorSourceKey];
}

void YTCDTSetCustomColorSource(YTCDTCustomColorSource source) {
    [YTCDTDefaults() setInteger:source forKey:kYTCDTCustomColorSourceKey];
    [YTCDTDefaults() synchronize];
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

NSString *YTCDTCustomThemeColorHexString(void) {
    return YTCDTHexStringFromColor(YTCDTCustomThemeColor());
}

void YTCDTSetCustomThemeColor(UIColor *color) {
    if (!color) {
        YTCDTClearCustomThemeColor();
        return;
    }

    if (YTCDTStoreCustomThemeColor(color)) {
        [YTCDTDefaults() synchronize];
    }
}

BOOL YTCDTSetCustomThemeColorFromHexString(NSString *hexString) {
    NSString *normalizedHex = YTCDTNormalizedHexString(hexString);
    if (!normalizedHex) {
        return NO;
    }

    UIColor *color = YTCDTColorFromHexString(normalizedHex);
    if (!color) {
        return NO;
    }

    if (!YTCDTStoreCustomThemeColor(color)) {
        return NO;
    }

    [YTCDTDefaults() setObject:normalizedHex forKey:kYTCDTSavedHexColorKey];
    [YTCDTDefaults() synchronize];
    return YES;
}

void YTCDTClearCustomThemeColor(void) {
    [YTCDTDefaults() removeObjectForKey:kYTCDTCustomColorKey];
    [YTCDTDefaults() synchronize];
}

BOOL YTCDTHasSavedHexColor(void) {
    return [YTCDTDefaults() objectForKey:kYTCDTSavedHexColorKey] != nil;
}

NSString *YTCDTSavedHexColorString(void) {
    NSString *savedHex = [YTCDTDefaults() stringForKey:kYTCDTSavedHexColorKey];
    return YTCDTNormalizedHexString(savedHex);
}

BOOL YTCDTActivateSavedHexColor(void) {
    NSString *savedHex = YTCDTSavedHexColorString();
    if (!savedHex) {
        return NO;
    }

    UIColor *color = YTCDTColorFromHexString(savedHex);
    if (!color) {
        return NO;
    }

    if (!YTCDTStoreCustomThemeColor(color)) {
        return NO;
    }

    [YTCDTDefaults() synchronize];
    return YES;
}

BOOL YTCDTHasCustomPresetIdentifier(void) {
    return YTCDTCustomPresetIdentifier() != nil;
}

NSString *YTCDTCustomPresetIdentifier(void) {
    NSString *identifier = [YTCDTDefaults() stringForKey:kYTCDTCustomPresetIdentifierKey];
    if (![identifier isKindOfClass:[NSString class]] || identifier.length == 0) {
        return nil;
    }

    return identifier;
}

void YTCDTSetCustomPresetIdentifier(NSString *identifier) {
    if (![identifier isKindOfClass:[NSString class]] || identifier.length == 0) {
        YTCDTClearCustomPresetIdentifier();
        return;
    }

    [YTCDTDefaults() setObject:identifier forKey:kYTCDTCustomPresetIdentifierKey];
    [YTCDTDefaults() synchronize];
}

void YTCDTClearCustomPresetIdentifier(void) {
    [YTCDTDefaults() removeObjectForKey:kYTCDTCustomPresetIdentifierKey];
    [YTCDTDefaults() synchronize];
}

BOOL YTCDTOLEDKeyboardEnabled(void) {
    return [YTCDTDefaults() boolForKey:kYTCDTOLEDKeyboardKey];
}

void YTCDTSetOLEDKeyboardEnabled(BOOL enabled) {
    [YTCDTDefaults() setBool:enabled forKey:kYTCDTOLEDKeyboardKey];
    [YTCDTDefaults() synchronize];
}

BOOL YTCDTRemoveRoundedCornersEnabled(void) {
    return [YTCDTDefaults() boolForKey:kYTCDTRemoveRoundedCornersKey];
}

void YTCDTSetRemoveRoundedCornersEnabled(BOOL enabled) {
    [YTCDTDefaults() setBool:enabled forKey:kYTCDTRemoveRoundedCornersKey];
    [YTCDTDefaults() synchronize];
}

BOOL YTCDTDisablePullToFullEnabled(void) {
    return [YTCDTDefaults() boolForKey:kYTCDTDisablePullToFullKey];
}

void YTCDTSetDisablePullToFullEnabled(BOOL enabled) {
    [YTCDTDefaults() setBool:enabled forKey:kYTCDTDisablePullToFullKey];
    [YTCDTDefaults() synchronize];
}

BOOL YTCDTHidePreviewCommentSectionEnabled(void) {
    return [YTCDTDefaults() boolForKey:kYTCDTHidePreviewCommentSectionKey];
}

void YTCDTSetHidePreviewCommentSectionEnabled(BOOL enabled) {
    [YTCDTDefaults() setBool:enabled forKey:kYTCDTHidePreviewCommentSectionKey];
    [YTCDTDefaults() synchronize];
}
