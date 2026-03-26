#import <objc/runtime.h>
#import <YouTubeHeader/YTIIcon.h>
#import <YouTubeHeader/YTSettingsGroupData.h>
#import <YouTubeHeader/YTSettingsPickerViewController.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTSettingsViewController.h>
#import "YTCDTPrefs.h"

#define SECTION_HEADER(headerTitle)                                                                                    \
    [sectionItems addObject:[objc_getClass("YTSettingsSectionItem")                                                    \
                                          itemWithTitle:@"\t"                                                          \
                                       titleDescription:headerTitle                                                    \
                                accessibilityIdentifier:nil                                                            \
                                        detailTextBlock:nil                                                            \
                                            selectBlock:^BOOL(YTSettingsCell *cell, NSUInteger sectionItemIndex) {     \
                                                return NO;                                                             \
                                            }]]

#ifndef PACKAGE_VERSION
#define PACKAGE_VERSION @"Unknown"
#endif

static inline NSString *YTCDTVersionLabel(void) {
    return PACKAGE_VERSION;
}

static NSString *YTCDTLocalizationBundlePath(void) {
    NSString *rootlessBundlePath =
        @"/var/jb/Library/Application Support/YTClassicDarkTheme.bundle";

    if ([[NSFileManager defaultManager] fileExistsAtPath:rootlessBundlePath]) {
        return rootlessBundlePath;
    }

    NSString *sideloadBundlePath =
        [[NSBundle mainBundle] pathForResource:@"YTClassicDarkTheme"
                                        ofType:@"bundle"];
    if (sideloadBundlePath.length > 0) {
        return sideloadBundlePath;
    }

    return nil;
}

static NSBundle *YTCDTLocalizationBundle(void) {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSString *bundlePath = YTCDTLocalizationBundlePath();
        if (bundlePath.length > 0) {
            bundle = [NSBundle bundleWithPath:bundlePath];
        }
    });

    return bundle;
}

static NSString *YTCDTLocalizedText(NSString *key) {
    NSBundle *bundle = YTCDTLocalizationBundle();
    if (!bundle) {
        return key;
    }

    return [bundle localizedStringForKey:key
                                   value:key
                                   table:nil];
}

static const NSInteger YTClassicDarkThemeSection = 'ycdt';

@interface NSObject (YTClassicDarkThemeSettings)
- (void)reloadData;
- (void)pushViewController:(UIViewController *)viewController;
@end

@interface YTSettingsSectionItemManager (YTClassicDarkTheme)
- (void)updateYTClassicDarkThemeSectionWithEntry:(id)entry;
@end

static inline NSString *ThemeTypeLabel(void) {
    switch (YTCDTThemeTypeValue()) {
        case YTCDTThemeTypeCustomColor:
            return YTCDTLocalizedText(@"SETTINGS_CUSTOM_COLOR_TITLE");
        case YTCDTThemeTypeBuiltIn:
        default:
            return YTCDTLocalizedText(@"SETTINGS_BUILT_IN_TITLE");
    }
}

static inline NSString *BuiltInStyleLabel(void) {
    switch (YTCDTBuiltInStyleValue()) {
        case YTCDTBuiltInStyleOLED:
            return YTCDTLocalizedText(@"SETTINGS_OLED_TITLE");
        case YTCDTBuiltInStyleClassicGray:
        default:
            return YTCDTLocalizedText(@"SETTINGS_CLASSIC_GRAY_TITLE");
    }
}

static inline NSArray<NSString *> *YTCDTCustomColorTitles(void) {
    return @[
        YTCDTLocalizedText(@"SETTINGS_PRESET_SLATE_GRAY"),
        YTCDTLocalizedText(@"SETTINGS_PRESET_WARM_GRAY"),
        YTCDTLocalizedText(@"SETTINGS_PRESET_MIDNIGHT_BLUE"),
        YTCDTLocalizedText(@"SETTINGS_PRESET_DEEP_PURPLE"),
        YTCDTLocalizedText(@"SETTINGS_PRESET_OLIVE_DARK"),
        YTCDTLocalizedText(@"SETTINGS_PRESET_CHARCOAL")
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

static inline NSArray<NSString *> *YTCDTCustomColorIdentifiers(void) {
    return @[
        @"slate_gray",
        @"warm_gray",
        @"midnight_blue",
        @"deep_purple",
        @"olive_dark",
        @"charcoal"
    ];
}

static inline NSInteger YTCDTCustomPresetIndexForIdentifier(NSString *identifier) {
    if (![identifier isKindOfClass:[NSString class]] || identifier.length == 0) {
        return NSNotFound;
    }

    NSArray<NSString *> *identifiers = YTCDTCustomColorIdentifiers();
    for (NSUInteger i = 0; i < identifiers.count; i++) {
        if ([identifiers[i] isEqualToString:identifier]) {
            return (NSInteger)i;
        }
    }

    return NSNotFound;
}

static inline NSString *YTCDTCustomColorTitleForIdentifier(NSString *identifier) {
    NSInteger index = YTCDTCustomPresetIndexForIdentifier(identifier);
    NSArray<NSString *> *titles = YTCDTCustomColorTitles();

    if (index == NSNotFound || index >= (NSInteger)titles.count) {
        return nil;
    }

    return titles[(NSUInteger)index];
}

static inline NSString *CustomColorStatusLabel(void) {
    if (YTCDTCustomColorSourceValue() == YTCDTCustomColorSourceHex) {
        return YTCDTLocalizedText(@"SETTINGS_HEX_TITLE");
    }

    NSString *identifier = YTCDTCustomPresetIdentifier();
    NSString *title = YTCDTCustomColorTitleForIdentifier(identifier);
    return title ?: YTCDTLocalizedText(@"SETTINGS_STATUS_NONE");
}

static inline void YTCDTPresentInvalidHexAlert(UIViewController *presenter) {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:YTCDTLocalizedText(@"ALERT_INVALID_HEX_TITLE")
                                            message:YTCDTLocalizedText(@"ALERT_INVALID_HEX_MESSAGE")
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:YTCDTLocalizedText(@"ALERT_OK")
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
        [UIAlertController alertControllerWithTitle:YTCDTLocalizedText(@"ALERT_HEX_TITLE")
                                            message:YTCDTLocalizedText(@"ALERT_HEX_MESSAGE")
                                     preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = YTCDTLocalizedText(@"ALERT_HEX_PLACEHOLDER");
        textField.text = YTCDTSavedHexColorString();
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];

    __weak UIAlertController *weakAlert = alert;
    __weak UIViewController *weakPresenter = presenter;

    [alert addAction:[UIAlertAction actionWithTitle:YTCDTLocalizedText(@"ALERT_CANCEL")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];

    [alert addAction:[UIAlertAction actionWithTitle:YTCDTLocalizedText(@"ALERT_SAVE")
                                              style:UIAlertActionStyleDefault
                                            handler:^(__unused UIAlertAction *action) {
        NSString *input = weakAlert.textFields.firstObject.text;

        if (!YTCDTSetCustomThemeColorFromHexString(input)) {
            if (weakPresenter) {
                YTCDTPresentInvalidHexAlert(weakPresenter);
            }
            return;
        }

        YTCDTSetThemeType(YTCDTThemeTypeCustomColor);
        YTCDTSetCustomColorSource(YTCDTCustomColorSourceHex);
        YTCDTClearCustomPresetIdentifier();

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

    SECTION_HEADER(YTCDTLocalizedText(@"SETTINGS_RESTART_REQUIRED_HEADER"));

    YTSettingsSectionItem *enableThemeItem =
        [%c(YTSettingsSectionItem) switchItemWithTitle:YTCDTLocalizedText(@"SETTINGS_ENABLE_THEME_TITLE")
                                      titleDescription:YTCDTLocalizedText(@"SETTINGS_ENABLE_THEME_DESCRIPTION")
                               accessibilityIdentifier:@"YTClassicDarkThemeEnabled"
                                              switchOn:YTCDTEnabled()
                                           switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                                               YTCDTSetEnabled(enabled);

                                               if ([delegate respondsToSelector:@selector(reloadData)]) {
                                                   [delegate reloadData];
                                               }

                                               return YES;
                                           }
                                         settingItemId:0];
    [sectionItems addObject:enableThemeItem];

    YTSettingsSectionItem *themeTypeItem =
        [%c(YTSettingsSectionItem) itemWithTitle:YTCDTLocalizedText(@"SETTINGS_THEME_TYPE_TITLE")
                                titleDescription:YTCDTLocalizedText(@"SETTINGS_THEME_TYPE_DESCRIPTION")
                         accessibilityIdentifier:@"YTClassicDarkThemeThemeType"
                                 detailTextBlock:^NSString *{
                                     return ThemeTypeLabel();
                                 }
                                     selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                                         NSArray<NSString *> *titles = @[
                                             YTCDTLocalizedText(@"SETTINGS_BUILT_IN_TITLE"),
                                             YTCDTLocalizedText(@"SETTINGS_CUSTOM_COLOR_TITLE")
                                         ];

                                         NSArray<NSString *> *descriptions = @[
                                             YTCDTLocalizedText(@"SETTINGS_THEME_TYPE_BUILT_IN_DESCRIPTION"),
                                             YTCDTLocalizedText(@"SETTINGS_THEME_TYPE_CUSTOM_COLOR_DESCRIPTION")
                                         ];

                                         NSMutableArray *rows = [NSMutableArray array];

                                         for (NSUInteger i = 0; i < titles.count; i++) {
                                             NSString *title = titles[i];
                                             NSString *desc = descriptions[i];

                                             YTSettingsSectionItem *row =
                                                 [%c(YTSettingsSectionItem) checkmarkItemWithTitle:title
                                                                                  titleDescription:desc
                                                                                       selectBlock:^BOOL (YTSettingsCell *pickerCell, NSUInteger arg2) {
                                                                                           YTCDTSetThemeType((YTCDTThemeType)i);

                                                                                           if ([delegate respondsToSelector:@selector(reloadData)]) {
                                                                                               [delegate reloadData];
                                                                                           }

                                                                                           return YES;
                                                                                       }];
                                             [rows addObject:row];
                                         }

                                         YTSettingsPickerViewController *picker =
                                             [[%c(YTSettingsPickerViewController) alloc]
                                                 initWithNavTitle:YTCDTLocalizedText(@"SETTINGS_SECTION_TITLE")
                                                 pickerSectionTitle:YTCDTLocalizedText(@"SETTINGS_THEME_TYPE_PICKER_TITLE")
                                                 rows:rows
                                                 selectedItemIndex:YTCDTThemeTypeValue()
                                                 parentResponder:delegate];

                                         [delegate pushViewController:picker];
                                         return YES;
                                     }];
    [sectionItems addObject:themeTypeItem];

    SECTION_HEADER(YTCDTLocalizedText(@"SETTINGS_APPEARANCE_HEADER"));

    YTSettingsSectionItem *builtInStyleItem =
        [%c(YTSettingsSectionItem) itemWithTitle:YTCDTLocalizedText(@"SETTINGS_BUILT_IN_STYLE_TITLE")
                                titleDescription:YTCDTLocalizedText(@"SETTINGS_BUILT_IN_STYLE_DESCRIPTION")
                         accessibilityIdentifier:@"YTClassicDarkThemeBuiltInStyle"
                                 detailTextBlock:^NSString *{
                                     return BuiltInStyleLabel();
                                 }
                                     selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                                         NSArray<NSString *> *titles = @[
                                             YTCDTLocalizedText(@"SETTINGS_CLASSIC_GRAY_TITLE"),
                                             YTCDTLocalizedText(@"SETTINGS_OLED_TITLE")
                                         ];

                                         NSArray<NSString *> *descriptions = @[
                                             YTCDTLocalizedText(@"SETTINGS_CLASSIC_GRAY_DESCRIPTION"),
                                             YTCDTLocalizedText(@"SETTINGS_OLED_DESCRIPTION")
                                         ];

                                         NSMutableArray *rows = [NSMutableArray array];

                                         for (NSUInteger i = 0; i < titles.count; i++) {
                                             NSString *title = titles[i];
                                             NSString *desc = descriptions[i];

                                             YTSettingsSectionItem *row =
                                                 [%c(YTSettingsSectionItem) checkmarkItemWithTitle:title
                                                                                  titleDescription:desc
                                                                                       selectBlock:^BOOL (YTSettingsCell *pickerCell, NSUInteger arg2) {
                                                                                           YTCDTSetThemeType(YTCDTThemeTypeBuiltIn);
                                                                                           YTCDTSetBuiltInStyle((YTCDTBuiltInStyle)i);

                                                                                           if ([delegate respondsToSelector:@selector(reloadData)]) {
                                                                                               [delegate reloadData];
                                                                                           }

                                                                                           return YES;
                                                                                       }];
                                             [rows addObject:row];
                                         }

                                         YTSettingsPickerViewController *picker =
                                             [[%c(YTSettingsPickerViewController) alloc]
                                                 initWithNavTitle:YTCDTLocalizedText(@"SETTINGS_SECTION_TITLE")
                                                 pickerSectionTitle:YTCDTLocalizedText(@"SETTINGS_BUILT_IN_STYLE_PICKER_TITLE")
                                                 rows:rows
                                                 selectedItemIndex:YTCDTBuiltInStyleValue()
                                                 parentResponder:delegate];

                                         [delegate pushViewController:picker];
                                         return YES;
                                     }];
    [sectionItems addObject:builtInStyleItem];

    YTSettingsSectionItem *customColorItem =
        [%c(YTSettingsSectionItem) itemWithTitle:YTCDTLocalizedText(@"SETTINGS_CUSTOM_COLOR_TITLE")
                                titleDescription:YTCDTLocalizedText(@"SETTINGS_CUSTOM_COLOR_DESCRIPTION")
                         accessibilityIdentifier:@"YTClassicDarkThemeCustomColor"
                                 detailTextBlock:^NSString *{
                                     return CustomColorStatusLabel();
                                 }
                                     selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                                         NSArray<NSString *> *titles = YTCDTCustomColorTitles();
                                         NSArray<NSString *> *identifiers = YTCDTCustomColorIdentifiers();
                                         NSArray<UIColor *> *colors = YTCDTCustomColorValues();
                                         NSString *savedHex = YTCDTSavedHexColorString();
                                         NSString *presetIdentifier = YTCDTCustomPresetIdentifier();

                                         NSMutableArray *rows = [NSMutableArray array];

                                         NSString *hexDescription =
                                             savedHex
                                                 ? [NSString stringWithFormat:YTCDTLocalizedText(@"SETTINGS_HEX_DESCRIPTION_FORMAT"), savedHex]
                                                 : YTCDTLocalizedText(@"SETTINGS_HEX_DESCRIPTION_NONE");

                                         YTSettingsSectionItem *hexRow =
                                             [%c(YTSettingsSectionItem) checkmarkItemWithTitle:YTCDTLocalizedText(@"SETTINGS_HEX_TITLE")
                                                                              titleDescription:hexDescription
                                                                                  selectBlock:^BOOL (YTSettingsCell *pickerCell, NSUInteger arg2) {
                                                                                      if (YTCDTActivateSavedHexColor()) {
                                                                                          YTCDTSetThemeType(YTCDTThemeTypeCustomColor);
                                                                                          YTCDTSetCustomColorSource(YTCDTCustomColorSourceHex);
                                                                                          YTCDTClearCustomPresetIdentifier();

                                                                                          if ([delegate respondsToSelector:@selector(reloadData)]) {
                                                                                              [delegate reloadData];
                                                                                          }
                                                                                      }

                                                                                      return YES;
                                                                                  }];
                                         [rows addObject:hexRow];

                                         for (NSUInteger i = 0; i < titles.count; i++) {
                                             NSString *title = titles[i];
                                             NSString *identifier = identifiers[i];
                                             UIColor *color = colors[i];

                                             YTSettingsSectionItem *row =
                                                 [%c(YTSettingsSectionItem) checkmarkItemWithTitle:title
                                                                                  titleDescription:YTCDTLocalizedText(@"SETTINGS_PRESET_APPLY_DESCRIPTION")
                                                                                       selectBlock:^BOOL (YTSettingsCell *pickerCell, NSUInteger arg2) {
                                                                                           YTCDTSetThemeType(YTCDTThemeTypeCustomColor);
                                                                                           YTCDTSetCustomColorSource(YTCDTCustomColorSourcePreset);
                                                                                           YTCDTSetCustomPresetIdentifier(identifier);
                                                                                           YTCDTSetCustomThemeColor(color);

                                                                                           if ([delegate respondsToSelector:@selector(reloadData)]) {
                                                                                               [delegate reloadData];
                                                                                           }

                                                                                           return YES;
                                                                                       }];
                                             [rows addObject:row];
                                         }

                                         NSUInteger pickerSelectedIndex = NSNotFound;

                                         if (YTCDTCustomColorSourceValue() == YTCDTCustomColorSourceHex) {
                                             pickerSelectedIndex = 0;
                                         } else {
                                             NSInteger presetIndex = YTCDTCustomPresetIndexForIdentifier(presetIdentifier);
                                             if (presetIndex != NSNotFound) {
                                                 pickerSelectedIndex = (NSUInteger)(presetIndex + 1);
                                             }
                                         }

                                         YTSettingsPickerViewController *picker =
                                             [[%c(YTSettingsPickerViewController) alloc]
                                                 initWithNavTitle:YTCDTLocalizedText(@"SETTINGS_SECTION_TITLE")
                                                 pickerSectionTitle:YTCDTLocalizedText(@"SETTINGS_CUSTOM_COLOR_PICKER_TITLE")
                                                 rows:rows
                                                 selectedItemIndex:pickerSelectedIndex
                                                 parentResponder:delegate];

                                         [delegate pushViewController:picker];
                                         return YES;
                                     }];
    [sectionItems addObject:customColorItem];

    YTSettingsSectionItem *editHexItem =
        [%c(YTSettingsSectionItem) itemWithTitle:YTCDTLocalizedText(@"SETTINGS_EDIT_HEX_TITLE")
                                titleDescription:YTCDTLocalizedText(@"SETTINGS_EDIT_HEX_DESCRIPTION")
                         accessibilityIdentifier:@"YTClassicDarkThemeEditHexColor"
                                 detailTextBlock:^NSString *{
                                     NSString *savedHex = YTCDTSavedHexColorString();
                                     return savedHex ?: YTCDTLocalizedText(@"SETTINGS_STATUS_NONE");
                                 }
                                     selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                                         YTCDTPresentHexColorAlert(delegate);
                                         return YES;
                                     }];
    [sectionItems addObject:editHexItem];

    SECTION_HEADER(YTCDTLocalizedText(@"SETTINGS_OPTIONS_HEADER"));

    YTSettingsSectionItem *removeRoundedCornersItem =
        [%c(YTSettingsSectionItem) switchItemWithTitle:YTCDTLocalizedText(@"SETTINGS_REMOVE_ROUNDED_CORNERS_TITLE")
                                      titleDescription:YTCDTLocalizedText(@"SETTINGS_REMOVE_ROUNDED_CORNERS_DESCRIPTION")
                               accessibilityIdentifier:@"YTClassicDarkThemeRemoveRoundedCorners"
                                              switchOn:YTCDTRemoveRoundedCornersEnabled()
                                           switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                                              YTCDTSetRemoveRoundedCornersEnabled(enabled);

                                              if ([delegate respondsToSelector:@selector(reloadData)]) {
                                                  [delegate reloadData];
                                              }

                                              return YES;
                                          }
                                        settingItemId:0];
    [sectionItems addObject:removeRoundedCornersItem];

    YTSettingsSectionItem *keyboardItem =
        [%c(YTSettingsSectionItem) switchItemWithTitle:YTCDTLocalizedText(@"SETTINGS_OLED_KEYBOARD_TITLE")
                                      titleDescription:YTCDTLocalizedText(@"SETTINGS_OLED_KEYBOARD_DESCRIPTION")
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

    YTSettingsSectionItem *versionItem =
        [%c(YTSettingsSectionItem) itemWithTitle:YTCDTLocalizedText(@"SETTINGS_VERSION_TITLE")
                                titleDescription:nil
                         accessibilityIdentifier:@"YTClassicDarkThemeVersion"
                                 detailTextBlock:^NSString *{
                                     return YTCDTVersionLabel();
                                 }
                                     selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                                         return YES;
                                     }];
    [sectionItems addObject:versionItem];

    if ([delegate respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)]) {
        YTIIcon *icon = [%c(YTIIcon) new];
        icon.iconType = YT_MAGIC_WAND_FILLED;

        [delegate setSectionItems:sectionItems
                      forCategory:YTClassicDarkThemeSection
                            title:YTCDTLocalizedText(@"SETTINGS_SECTION_TITLE")
                             icon:icon
                 titleDescription:nil
                     headerHidden:NO];
    } else {
        [delegate setSectionItems:sectionItems
                      forCategory:YTClassicDarkThemeSection
                            title:YTCDTLocalizedText(@"SETTINGS_SECTION_TITLE")
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
