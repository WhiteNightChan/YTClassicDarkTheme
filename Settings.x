#import <objc/runtime.h>
#import <YouTubeHeader/YTIIcon.h>
#import <YouTubeHeader/YTSettingsGroupData.h>
#import <YouTubeHeader/YTSettingsPickerViewController.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTSettingsViewController.h>
#import "YTCDTPrefs.h"

static const NSInteger YTClassicDarkThemeSection = 'ycdt';

@interface NSObject (YTClassicDarkThemeSettings)
- (void)reloadData;
- (void)pushViewController:(UIViewController *)viewController;
@end

@interface YTSettingsSectionItemManager (YTClassicDarkTheme)
- (void)updateYTClassicDarkThemeSectionWithEntry:(id)entry;
@end

static inline NSString *ThemeModeLabel(void) {
    switch (YTCDTThemeModeValue()) {
        case YTCDTThemeModeClassicGray:
            return @"Classic Gray";
        case YTCDTThemeModeOLED:
            return @"OLED";
        case YTCDTThemeModeCustom:
            return YTCDTHasCustomThemeColor() ? @"Custom" : @"Custom (No Color Saved)";
        default:
            return @"Off";
    }
}

static inline NSArray<NSString *> *YTCDTCustomColorTitles(void) {
    return @[
        @"Slate Gray",
        @"Warm Gray",
        @"Midnight Blue",
        @"Deep Purple",
        @"Olive Dark",
        @"Charcoal"
    ];
}

static inline NSArray<UIColor *> *YTCDTCustomColorValues(void) {
    return @[
        [UIColor colorWithRed:0.23 green:0.26 blue:0.30 alpha:1.0], // Slate Gray
        [UIColor colorWithRed:0.24 green:0.22 blue:0.20 alpha:1.0], // Warm Gray
        [UIColor colorWithRed:0.10 green:0.12 blue:0.20 alpha:1.0], // Midnight Blue
        [UIColor colorWithRed:0.18 green:0.12 blue:0.24 alpha:1.0], // Deep Purple
        [UIColor colorWithRed:0.20 green:0.22 blue:0.14 alpha:1.0], // Olive Dark
        [UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1.0], // Charcoal
    ];
}

static inline BOOL YTCDTColorComponents(UIColor *color, CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
    if (!color) {
        return NO;
    }

    UIColor *converted = color;
    if (![converted getRed:r green:g blue:b alpha:a]) {
        CGFloat white = 0.0;
        if ([converted getWhite:&white alpha:a]) {
            *r = white;
            *g = white;
            *b = white;
            return YES;
        }
        return NO;
    }
    return YES;
}

static inline BOOL YTCDTColorsAreClose(UIColor *lhs, UIColor *rhs) {
    CGFloat lr = 0.0, lg = 0.0, lb = 0.0, la = 0.0;
    CGFloat rr = 0.0, rg = 0.0, rb = 0.0, ra = 0.0;

    if (!YTCDTColorComponents(lhs, &lr, &lg, &lb, &la) ||
        !YTCDTColorComponents(rhs, &rr, &rg, &rb, &ra)) {
        return NO;
    }

    CGFloat epsilon = 0.01;
    return fabs(lr - rr) < epsilon &&
           fabs(lg - rg) < epsilon &&
           fabs(lb - rb) < epsilon &&
           fabs(la - ra) < epsilon;
}

static inline NSInteger YTCDTSelectedCustomColorIndex(void) {
    UIColor *currentColor = YTCDTCustomThemeColor();
    if (!currentColor) {
        return NSNotFound;
    }

    NSArray<UIColor *> *presetColors = YTCDTCustomColorValues();
    for (NSUInteger i = 0; i < presetColors.count; i++) {
        if (YTCDTColorsAreClose(currentColor, presetColors[i])) {
            return (NSInteger)i;
        }
    }

    return NSNotFound;
}

static inline NSString *CustomColorStatusLabel(void) {
    if (!YTCDTHasCustomThemeColor()) {
        return @"None";
    }

    NSInteger selectedIndex = YTCDTSelectedCustomColorIndex();
    NSArray<NSString *> *titles = YTCDTCustomColorTitles();

    if (selectedIndex != NSNotFound && selectedIndex < (NSInteger)titles.count) {
        return titles[(NSUInteger)selectedIndex];
    }

    NSString *savedHex = YTCDTCustomThemeColorHexString();
    return savedHex ?: @"Saved";
}

static inline void YTCDTPresentInvalidHexAlert(UIViewController *presenter) {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Invalid HEX Color"
                                            message:@"Use #RRGGBB or RRGGBB."
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];

    [presenter presentViewController:alert animated:YES completion:nil];
}

static inline void YTCDTPresentHexColorAlert(YTSettingsViewController *delegate) {
    if (![delegate isKindOfClass:[UIViewController class]]) {
        return;
    }

    UIViewController *presenter = (UIViewController *)delegate;

    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"HEX Color"
                                            message:@"Enter #RRGGBB or RRGGBB. Saving also sets Mode to Custom."
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"#1E1E1E";
        textField.text = YTCDTCustomThemeColorHexString();
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];

    __weak UIAlertController *weakAlert = alert;
    __weak UIViewController *weakPresenter = presenter;

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Save"
                                              style:UIAlertActionStyleDefault
                                            handler:^(__unused UIAlertAction *action) {
        NSString *input = weakAlert.textFields.firstObject.text;

        if (!YTCDTSetCustomThemeColorFromHexString(input)) {
            if (weakPresenter) {
                YTCDTPresentInvalidHexAlert(weakPresenter);
            }
            return;
        }

        YTCDTSetThemeMode(YTCDTThemeModeCustom);

        if ([delegate respondsToSelector:@selector(reloadData)]) {
            [delegate reloadData];
        }
    }]];

    [presenter presentViewController:alert animated:YES completion:nil];
}

%hook YTAppSettingsPresentationData

+ (NSArray<NSNumber *> *)settingsCategoryOrder {
    NSArray<NSNumber *> *order = %orig;
    if (!order) {
        return @[@(YTClassicDarkThemeSection)];
    }

    NSMutableArray<NSNumber *> *mutableOrder = order.mutableCopy;
    if ([mutableOrder containsObject:@(YTClassicDarkThemeSection)]) {
        return mutableOrder.copy;
    }

    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound) {
        [mutableOrder insertObject:@(YTClassicDarkThemeSection) atIndex:insertIndex + 1];
    } else {
        [mutableOrder addObject:@(YTClassicDarkThemeSection)];
    }

    return mutableOrder.copy;
}

%end

%hook YTSettingsGroupData

- (NSArray<NSNumber *> *)orderedCategories {
    if (self.type != 1 || class_getClassMethod(objc_getClass("YTSettingsGroupData"), @selector(tweaks))) {
        return %orig;
    }

    NSArray *original = %orig;
    NSMutableArray *mutableCategories = original ? original.mutableCopy : [NSMutableArray array];
    if (![mutableCategories containsObject:@(YTClassicDarkThemeSection)]) {
        [mutableCategories insertObject:@(YTClassicDarkThemeSection) atIndex:0];
    }
    return mutableCategories.copy;
}

%end

%hook YTSettingsSectionItemManager

%new(v@:@)
- (void)updateYTClassicDarkThemeSectionWithEntry:(id)entry {
    YTSettingsViewController *delegate = nil;

    @try {
        delegate = [self valueForKey:@"_dataDelegate"];
    } @catch (id ex) {}

    if (!delegate) {
        @try {
            delegate = [self valueForKey:@"_settingsViewControllerDelegate"];
        } @catch (id ex) {}
    }

    if (!delegate) {
        return;
    }

    NSMutableArray *sectionItems = [NSMutableArray array];

    YTSettingsSectionItem *modeItem =
        [%c(YTSettingsSectionItem) itemWithTitle:@"Mode"
                                titleDescription:@"Restart YouTube after changing theme"
                         accessibilityIdentifier:@"YTClassicDarkThemeMode"
                                 detailTextBlock:^NSString *{
                                     return ThemeModeLabel();
                                 }
                                     selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                                         NSArray<NSString *> *titles = @[
                                             @"Off",
                                             @"Classic Gray",
                                             @"OLED",
                                             @"Custom"
                                         ];

                                         NSArray<NSString *> *descriptions = @[
                                             @"Disable the theme",
                                             @"Restore the classic gray dark theme",
                                             @"Use pure black OLED dark mode",
                                             YTCDTHasCustomThemeColor() ? @"Use saved custom color" : @"No custom color saved yet"
                                         ];

                                         NSMutableArray *rows = [NSMutableArray array];

                                         for (NSUInteger i = 0; i < titles.count; i++) {
                                             NSString *title = titles[i];
                                             NSString *desc = descriptions[i];

                                             YTSettingsSectionItem *row =
                                                 [%c(YTSettingsSectionItem) checkmarkItemWithTitle:title
                                                                                 titleDescription:desc
                                                                                      selectBlock:^BOOL (YTSettingsCell *pickerCell, NSUInteger arg2) {
                                                                                          if (i == YTCDTThemeModeCustom && !YTCDTHasCustomThemeColor()) {
                                                                                              return YES;
                                                                                          }

                                                                                          YTCDTSetThemeMode((YTCDTThemeMode)i);

                                                                                          if ([delegate respondsToSelector:@selector(reloadData)]) {
                                                                                              [delegate reloadData];
                                                                                          }

                                                                                          return YES;
                                                                                      }];
                                             [rows addObject:row];
                                         }

                                         YTSettingsPickerViewController *picker =
                                             [[%c(YTSettingsPickerViewController) alloc]
                                                 initWithNavTitle:@"Classic Dark Theme"
                                                 pickerSectionTitle:@"Mode"
                                                 rows:rows
                                                 selectedItemIndex:YTCDTThemeModeValue()
                                                 parentResponder:delegate];

                                         [delegate pushViewController:picker];
                                         return YES;
                                     }];
    [sectionItems addObject:modeItem];

    YTSettingsSectionItem *keyboardItem =
        [%c(YTSettingsSectionItem) switchItemWithTitle:@"OLED Keyboard"
                                      titleDescription:@"Restart YouTube after changing keyboard setting"
                               accessibilityIdentifier:@"YTClassicDarkThemeOLEDKeyboard"
                                             switchOn:YTCDTOLEDKeyboardEnabled()
                                          switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                                              YTCDTSetOLEDKeyboardEnabled(enabled);

                                              if ([delegate respondsToSelector:@selector(reloadData)]) {
                                                  [delegate reloadData];
                                              }

                                              return YES;
                                          }
                                        settingItemId:0];
    [sectionItems addObject:keyboardItem];

    YTSettingsSectionItem *customColorItem =
        [%c(YTSettingsSectionItem) itemWithTitle:@"Custom Color"
                                titleDescription:@"Preset colors. Selecting a color also sets Mode to Custom"
                         accessibilityIdentifier:@"YTClassicDarkThemeCustomColor"
                                 detailTextBlock:^NSString *{
                                     return CustomColorStatusLabel();
                                 }
                                     selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                                         NSArray<NSString *> *titles = YTCDTCustomColorTitles();
                                         NSArray<UIColor *> *colors = YTCDTCustomColorValues();
                                         NSInteger selectedIndex = YTCDTSelectedCustomColorIndex();

                                         NSMutableArray *rows = [NSMutableArray array];

                                         YTSettingsSectionItem *notSetRow =
                                             [%c(YTSettingsSectionItem) checkmarkItemWithTitle:@"None"
                                                                             titleDescription:@"Clear custom color and set Mode to Off"
                                                                                  selectBlock:^BOOL (YTSettingsCell *pickerCell, NSUInteger arg2) {
                                                                                      YTCDTClearCustomThemeColor();

                                                                                      if (YTCDTThemeModeValue() == YTCDTThemeModeCustom) {
                                                                                          YTCDTSetThemeMode(YTCDTThemeModeOff);
                                                                                      }

                                                                                      if ([delegate respondsToSelector:@selector(reloadData)]) {
                                                                                          [delegate reloadData];
                                                                                      }

                                                                                      return YES;
                                                                                  }];
                                         [rows addObject:notSetRow];

                                         for (NSUInteger i = 0; i < titles.count; i++) {
                                             NSString *title = titles[i];
                                             UIColor *color = colors[i];

                                             YTSettingsSectionItem *row =
                                                 [%c(YTSettingsSectionItem) checkmarkItemWithTitle:title
                                                                                 titleDescription:@"Apply after restarting YouTube"
                                                                                      selectBlock:^BOOL (YTSettingsCell *pickerCell, NSUInteger arg2) {
                                                                                          YTCDTSetCustomThemeColor(color);
                                                                                          YTCDTSetThemeMode(YTCDTThemeModeCustom);

                                                                                          if ([delegate respondsToSelector:@selector(reloadData)]) {
                                                                                              [delegate reloadData];
                                                                                          }

                                                                                          return YES;
                                                                                      }];
                                             [rows addObject:row];
                                         }

                                         NSUInteger pickerSelectedIndex =
                                             (selectedIndex == NSNotFound)
                                                 ? (YTCDTHasCustomThemeColor() ? NSNotFound : 0)
                                                 : (NSUInteger)(selectedIndex + 1);

                                         YTSettingsPickerViewController *picker =
                                             [[%c(YTSettingsPickerViewController) alloc]
                                                 initWithNavTitle:@"Classic Dark Theme"
                                                 pickerSectionTitle:@"Custom Color"
                                                 rows:rows
                                                 selectedItemIndex:pickerSelectedIndex
                                                 parentResponder:delegate];

                                         [delegate pushViewController:picker];
                                         return YES;
                                     }];
    [sectionItems addObject:customColorItem];

    YTSettingsSectionItem *hexColorItem =
        [%c(YTSettingsSectionItem) itemWithTitle:@"HEX Color"
                                titleDescription:@"Enter #RRGGBB manually. Saving also sets Mode to Custom"
                         accessibilityIdentifier:@"YTClassicDarkThemeHexColor"
                                 detailTextBlock:^NSString *{
                                     if (!YTCDTHasCustomThemeColor()) {
                                         return @"None";
                                     }

                                     NSString *savedHex = YTCDTCustomThemeColorHexString();
                                     return savedHex ?: @"Saved";
                                 }
                                     selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                                         YTCDTPresentHexColorAlert(delegate);
                                         return YES;
                                     }];
    [sectionItems addObject:hexColorItem];

    if ([delegate respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)]) {
        YTIIcon *icon = [%c(YTIIcon) new];
        icon.iconType = YT_SETTINGS;

        [delegate setSectionItems:sectionItems
                      forCategory:YTClassicDarkThemeSection
                            title:@"Classic Dark Theme"
                             icon:icon
                 titleDescription:nil
                     headerHidden:NO];
    } else {
        [delegate setSectionItems:sectionItems
                      forCategory:YTClassicDarkThemeSection
                            title:@"Classic Dark Theme"
                 titleDescription:nil
                     headerHidden:NO];
    }
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YTClassicDarkThemeSection) {
        [self updateYTClassicDarkThemeSectionWithEntry:entry];
        return;
    }

    %orig;
}

%end

%ctor {
    %init;
}
