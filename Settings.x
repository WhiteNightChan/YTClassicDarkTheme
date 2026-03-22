#import <objc/runtime.h>
#import <YouTubeHeader/YTIIcon.h>
#import <YouTubeHeader/YTSettingsGroupData.h>
#import <YouTubeHeader/YTSettingsPickerViewController.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTSettingsViewController.h>

static const NSInteger YTClassicDarkThemeSection = 2901;

static NSString * const kThemeModeKey = @"classicDarkTheme_mode";
static NSString * const kOLEDKeyboardKey = @"classicDarkTheme_oledKeyboard";
static NSString * const kCustomColorKey = @"classicDarkTheme_customColor";

@interface NSObject (YTClassicDarkThemeSettings)
- (void)reloadData;
- (void)pushViewController:(UIViewController *)viewController;
@end

@interface YTSettingsSectionItemManager (YTClassicDarkTheme)
- (void)updateYTClassicDarkThemeSectionWithEntry:(id)entry;
@end

static inline NSInteger ThemeMode(void) {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kThemeModeKey];
}

static inline BOOL OLEDKeyboardEnabled(void) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kOLEDKeyboardKey];
}

static inline BOOL HasSavedCustomColor(void) {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kCustomColorKey] != nil;
}

static inline NSString *ThemeModeLabel(void) {
    switch (ThemeMode()) {
        case 1:
            return @"Classic Gray";
        case 2:
            return @"OLED";
        case 3:
            return HasSavedCustomColor() ? @"Custom" : @"Custom (No Color Saved)";
        default:
            return @"Off";
    }
}

%hook YTAppSettingsPresentationData

+ (NSArray <NSNumber *> *)settingsCategoryOrder {
    NSArray <NSNumber *> *order = %orig;
    NSUInteger insertIndex = [order indexOfObject:@(1)];

    if (insertIndex != NSNotFound) {
        NSMutableArray <NSNumber *> *mutableOrder = order.mutableCopy;
        if (![mutableOrder containsObject:@(YTClassicDarkThemeSection)]) {
            [mutableOrder insertObject:@(YTClassicDarkThemeSection) atIndex:insertIndex + 1];
        }
        order = mutableOrder.copy;
    }

    return order;
}

%end

%hook YTSettingsGroupData

- (NSArray <NSNumber *> *)orderedCategories {
    if (self.type != 1 || class_getClassMethod(objc_getClass("YTSettingsGroupData"), @selector(tweaks))) {
        return %orig;
    }

    NSMutableArray *mutableCategories = %orig.mutableCopy;
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
                                             HasSavedCustomColor() ? @"Use saved custom color" : @"No custom color saved yet"
                                         ];

                                         NSMutableArray *rows = [NSMutableArray array];

                                         for (NSUInteger i = 0; i < titles.count; i++) {
                                             NSString *title = titles[i];
                                             NSString *desc = descriptions[i];

                                             YTSettingsSectionItem *row =
                                                 [%c(YTSettingsSectionItem) checkmarkItemWithTitle:title
                                                                                 titleDescription:desc
                                                                                      selectBlock:^BOOL (YTSettingsCell *pickerCell, NSUInteger arg2) {
                                                                                          if (i == 3 && !HasSavedCustomColor()) {
                                                                                              return YES;
                                                                                          }

                                                                                          [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)i forKey:kThemeModeKey];
                                                                                          [[NSUserDefaults standardUserDefaults] synchronize];

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
                                                 selectedItemIndex:ThemeMode()
                                                 parentResponder:delegate];

                                         [delegate pushViewController:picker];
                                         return YES;
                                     }];
    [sectionItems addObject:modeItem];

    YTSettingsSectionItem *keyboardItem =
        [%c(YTSettingsSectionItem) switchItemWithTitle:@"OLED Keyboard"
                                      titleDescription:@"Restart YouTube after changing keyboard setting"
                               accessibilityIdentifier:@"YTClassicDarkThemeOLEDKeyboard"
                                             switchOn:OLEDKeyboardEnabled()
                                          switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                                              [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kOLEDKeyboardKey];
                                              [[NSUserDefaults standardUserDefaults] synchronize];

                                              if ([delegate respondsToSelector:@selector(reloadData)]) {
                                                  [delegate reloadData];
                                              }

                                              return YES;
                                          }
                                        settingItemId:0];
    [sectionItems addObject:keyboardItem];

    YTSettingsSectionItem *customColorStatus =
        [%c(YTSettingsSectionItem) itemWithTitle:@"Custom Color"
                                titleDescription:@"Color picker can be added later"
                         accessibilityIdentifier:@"YTClassicDarkThemeCustomColor"
                                 detailTextBlock:^NSString *{
                                     return HasSavedCustomColor() ? @"Saved" : @"Not Set";
                                 }
                                     selectBlock:nil];
    customColorStatus.enabled = NO;
    [sectionItems addObject:customColorStatus];

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
