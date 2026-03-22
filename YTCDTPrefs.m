#import "YTCDTPrefs.h"

static NSString * const kYTCDTThemeModeKey = @"classicDarkTheme_mode";
static NSString * const kYTCDTOLEDKeyboardKey = @"classicDarkTheme_oledKeyboard";
static NSString * const kYTCDTCustomColorKey = @"classicDarkTheme_customColor";

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

NSString *YTCDTCustomThemeColorHexString(void) {
    return YTCDTHexStringFromColor(YTCDTCustomThemeColor());
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

BOOL YTCDTSetCustomThemeColorFromHexString(NSString *hexString) {
    UIColor *color = YTCDTColorFromHexString(hexString);
    if (!color) {
        return NO;
    }

    YTCDTSetCustomThemeColor(color);
    return YES;
}

void YTCDTClearCustomThemeColor(void) {
    [YTCDTDefaults() removeObjectForKey:kYTCDTCustomColorKey];
    [YTCDTDefaults() synchronize];
}
