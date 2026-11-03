#import <UIKit/UIKit.h>

#import <YouTubeHeader/YTCommonColorPalette.h>
#import <YouTubeHeader/ELMPropertiesResolver.h>
#import <YouTubeHeader/YTWatchView.h>

#import "YTCDTPrefs.h"

#import <objc/runtime.h>

@interface UIColor (YTCDTElementsColor)
+ (UIColor *)colorWithElementsColor:(uint32_t)elementsColor;
@end

static BOOL cachedEnabled = NO;
static YTCDTThemeType cachedThemeType = YTCDTThemeTypeBuiltIn;
static YTCDTBuiltInStyle cachedBuiltInStyle = YTCDTBuiltInStyleClassicGray;
static UIColor *customThemeColor = nil;

static const uint32_t kYTCDTELMStylePropertiesExtension = 0x0A0F4B95;
static const uint32_t kYTCDTNativeELMDarkBackgroundColor = 0xFF0F0F0F;

static __thread uint32_t currentELMPropertiesExtension = 0;
static __thread unsigned int nestedELMStylePropertiesResolveDepth = 0;

static inline BOOL isBuiltInThemeEnabled() {
    return cachedEnabled && cachedThemeType == YTCDTThemeTypeBuiltIn;
}

static inline BOOL isOLEDThemeEnabled() {
    return isBuiltInThemeEnabled() && cachedBuiltInStyle == YTCDTBuiltInStyleOLED;
}

static inline BOOL isCustomThemeEnabled() {
    return cachedEnabled &&
           cachedThemeType == YTCDTThemeTypeCustomColor &&
           customThemeColor != nil;
}

static inline UIColor *classicGrayThemeColor() {
    return [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.0];
}

static inline UIColor *oledThemeColor() {
    return [UIColor blackColor];
}

static inline UIColor *activeThemeColor() {
    if (isCustomThemeEnabled()) {
        return customThemeColor;
    }

    if (isOLEDThemeEnabled()) {
        return oledThemeColor();
    }

    return classicGrayThemeColor();
}

static inline UIColor *activeSecondaryThemeColor() {
    return [activeThemeColor() colorWithAlphaComponent:0.9];
}

static inline BOOL shouldApplyYTCDTTheme(void) {
    return isBuiltInThemeEnabled() || isCustomThemeEnabled();
}

static inline BOOL shouldReplaceELMDarkBackgroundColor(uint32_t elementsColor) {
    return shouldApplyYTCDTTheme() &&
           currentELMPropertiesExtension == kYTCDTELMStylePropertiesExtension &&
           nestedELMStylePropertiesResolveDepth == 0 &&
           elementsColor == kYTCDTNativeELMDarkBackgroundColor;
}

static inline id YTCDTPrepareCommonColorPalette(id palette) {
    if (!shouldApplyYTCDTTheme() || palette == nil) {
        return palette;
    }

    Class themedPaletteClass = objc_getClass("YTCDTThemeColorPalette");
    if (themedPaletteClass != Nil &&
        object_getClass(palette) != themedPaletteClass) {
        object_setClass(palette, themedPaletteClass);
    }

    return palette;
}

static inline BOOL isNTYTSettingsViewController(id object) {
    Class ruleListClass = NSClassFromString(@"NTYTRuleListViewController");
    Class categoryClass = NSClassFromString(@"NTYTCategoryViewController");

    return (ruleListClass != Nil && [object isKindOfClass:ruleListClass]) ||
           (categoryClass != Nil && [object isKindOfClass:categoryClass]);
}

%group gClassicDarkTheme

%subclass YTCDTThemeColorPalette : YTCommonColorPalette

- (UIColor *)baseBackground {
    return activeThemeColor();
}

- (UIColor *)brandBackgroundSolid {
    return activeThemeColor();
}

- (UIColor *)brandBackgroundPrimary {
    return activeThemeColor();
}

- (UIColor *)brandBackgroundSecondary {
    return activeSecondaryThemeColor();
}

- (UIColor *)raisedBackground {
    return activeThemeColor();
}

- (UIColor *)staticBrandBlack {
    return activeThemeColor();
}

- (UIColor *)generalBackgroundA {
    return activeThemeColor();
}

- (UIColor *)generalBackgroundB {
    return activeThemeColor();
}

- (UIColor *)generalBackgroundC {
    return activeThemeColor();
}

- (UIColor *)menuBackground {
    return activeThemeColor();
}

%end

%hook YTCommonColorPalette

+ (instancetype)lightPalette {
    return YTCDTPrepareCommonColorPalette(%orig);
}

+ (instancetype)darkPalette {
    return YTCDTPrepareCommonColorPalette(%orig);
}

%end

%hook ELMPropertiesResolver

- (void)resolveProperties:(const void *)properties
      propertiesExtension:(int)propertiesExtension
            owningElement:(id)owningElement
          serializedValue:(ELMStringView)serializedValue
               controller:(id)controller
                  context:(id)context {
    if (!shouldApplyYTCDTTheme()) {
        %orig;
        return;
    }

    uint32_t previousPropertiesExtension = currentELMPropertiesExtension;
    currentELMPropertiesExtension = (uint32_t)propertiesExtension;

    @try {
        %orig;
    } @finally {
        currentELMPropertiesExtension = previousPropertiesExtension;
    }
}

- (void)resolveStyleProperties:(const void *)styleProperties
                     extension:(int)extension
                    controller:(id)controller
                       context:(id)context {
    BOOL isNestedELMStylePropertiesResolve =
        shouldApplyYTCDTTheme() &&
        currentELMPropertiesExtension == kYTCDTELMStylePropertiesExtension;

    if (!isNestedELMStylePropertiesResolve) {
        %orig;
        return;
    }

    nestedELMStylePropertiesResolveDepth++;

    @try {
        %orig;
    } @finally {
        nestedELMStylePropertiesResolveDepth--;
    }
}

%end

%hook UIColor

+ (UIColor *)colorWithElementsColor:(uint32_t)elementsColor {
    if (shouldReplaceELMDarkBackgroundColor(elementsColor)) {
        return activeThemeColor();
    }

    return %orig;
}

%end

%hook YTWatchView
- (UIColor *)cinematicBackgroundColor {
    if (!shouldApplyYTCDTTheme()) {
        return %orig;
    }

    Class watchViewClass = object_getClass(self);
    Ivar pageStyleIvar = class_getInstanceVariable(watchViewClass, "_pageStyle");
    Ivar fullscreenIvar = class_getInstanceVariable(watchViewClass, "_fullscreen");

    if (pageStyleIvar == NULL || fullscreenIvar == NULL) {
        return %orig;
    }

    const char *objectBytes = (const char *)(__bridge const void *)self;
    NSInteger pageStyle =
        *(const NSInteger *)(objectBytes + ivar_getOffset(pageStyleIvar));
    BOOL fullscreen =
        *(const BOOL *)(objectBytes + ivar_getOffset(fullscreenIvar));

    if (pageStyle == 1 && !fullscreen) {
        return activeThemeColor();
    }

    return %orig;
}
%end

%hook UIViewController

- (void)viewDidLoad {
    %orig;

    if (!shouldApplyYTCDTTheme() || !isNTYTSettingsViewController(self)) {
        return;
    }

    self.view.backgroundColor = activeThemeColor();

    if ([self isKindOfClass:[UITableViewController class]]) {
        UITableView *tableView = ((UITableViewController *)self).tableView;
        if ([tableView isKindOfClass:[UITableView class]]) {
            tableView.backgroundColor = activeThemeColor();
        }
    }

    UINavigationController *nav = self.navigationController;
    if ([nav isKindOfClass:[UINavigationController class]]) {
        nav.toolbar.barTintColor = activeThemeColor();
        nav.toolbar.backgroundColor = activeThemeColor();
        nav.toolbar.translucent = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;

    if (!shouldApplyYTCDTTheme() || !isNTYTSettingsViewController(self)) {
        return;
    }

    self.view.backgroundColor = activeThemeColor();

    if ([self isKindOfClass:[UITableViewController class]]) {
        UITableView *tableView = ((UITableViewController *)self).tableView;
        if ([tableView isKindOfClass:[UITableView class]]) {
            tableView.backgroundColor = activeThemeColor();
        }
    }

    UINavigationController *nav = self.navigationController;
    if ([nav isKindOfClass:[UINavigationController class]]) {
        nav.toolbar.barTintColor = activeThemeColor();
        nav.toolbar.backgroundColor = activeThemeColor();
    }
}

%end

%end

%ctor {
    cachedEnabled = YTCDTEnabled();
    cachedThemeType = YTCDTThemeTypeValue();
    cachedBuiltInStyle = YTCDTBuiltInStyleValue();
    customThemeColor = YTCDTCustomThemeColor();

    if (cachedEnabled &&
        (cachedThemeType == YTCDTThemeTypeBuiltIn ||
         (cachedThemeType == YTCDTThemeTypeCustomColor && customThemeColor != nil))) {
        %init(gClassicDarkTheme);
    }
}
