#import "Tweak.h"
#import "YTCDTPrefs.h"

static YTCDTThemeMode cachedThemeMode = YTCDTThemeModeOff;
static BOOL cachedOLEDKeyboardEnabled = NO;
static UIColor *customThemeColor = nil;

static inline BOOL isThemeEnabled() {
    return cachedThemeMode == YTCDTThemeModeClassicGray ||
           cachedThemeMode == YTCDTThemeModeOLED ||
           cachedThemeMode == YTCDTThemeModeCustom;
}

static inline BOOL isOLEDThemeEnabled() {
    return cachedThemeMode == YTCDTThemeModeOLED;
}

static inline BOOL isCustomThemeEnabled() {
    return cachedThemeMode == YTCDTThemeModeCustom && customThemeColor != nil;
}

static inline UIColor *oldDarkThemeColor() {
    return [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.0];
}

static inline UIColor *oledThemeColor() {
    return [UIColor blackColor];
}

static inline UIColor *sheetRaisedColor() {
    return [UIColor colorWithRed:0.035 green:0.035 blue:0.035 alpha:1.0];
}

static inline UIColor *activeThemeColor() {
    if (isOLEDThemeEnabled()) {
        return oledThemeColor();
    }

    if (isCustomThemeEnabled()) {
        return customThemeColor;
    }

    return oldDarkThemeColor();
}

static inline UIColor *activeSecondaryThemeColor() {
    return [activeThemeColor() colorWithAlphaComponent:0.9];
}

%group gClassicDarkTheme

%hook YTCommonColorPalette
- (UIColor *)background1 {
    return activeThemeColor();
}
- (UIColor *)background2 {
    return activeThemeColor();
}
- (UIColor *)background3 {
    return activeThemeColor();
}
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
- (UIColor *)menuBackground {
    return activeThemeColor();
}
%end

%hook YTColdConfig
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteBgColorForNative {
    return NO;
}
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteTextColorForNative {
    return NO;
}
- (BOOL)enableCinematicContainerOnClient {
    return NO;
}
%end

%hook YTInnerTubeCollectionViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return activeThemeColor();
}
%end

%hook ASScrollView
- (void)didMoveToWindow {
    %orig;

    if (isThemeEnabled()) {
        self.backgroundColor = [UIColor clearColor];
    }
}
%end

%hook ASCollectionView
- (void)didMoveToWindow {
    %orig;

    if (!isThemeEnabled()) {
        return;
    }

    if (self.superview) {
        self.superview.backgroundColor = activeThemeColor();
    }

    if ([self.nextResponder isKindOfClass:NSClassFromString(@"_ASDisplayView")]) {
        self.backgroundColor = [UIColor clearColor];
    }
}
%end

%hook YTFullscreenEngagementOverlayView
- (void)didMoveToWindow {
    %orig;

    if (!isThemeEnabled()) {
        return;
    }

    if (self.subviews.count > 0) {
        self.subviews[0].backgroundColor = [UIColor clearColor];
    }
}
%end

%hook YTRelatedVideosView
- (void)didMoveToWindow {
    %orig;

    if (!isThemeEnabled()) {
        return;
    }

    if (self.subviews.count > 0) {
        self.subviews[0].backgroundColor = [UIColor clearColor];
    }
}
%end

%hook YTSearchBarView
- (void)setBackgroundColor:(UIColor *)color {
    if (isThemeEnabled()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook YTSearchBoxView
- (void)setBackgroundColor:(UIColor *)color {
    if (isThemeEnabled()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook YTCommentView
- (void)setBackgroundColor:(UIColor *)color {
    if (isThemeEnabled()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook YTCreateCommentAccessoryView
- (void)setBackgroundColor:(UIColor *)color {
    if (isThemeEnabled()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook YTCreateCommentTextView
- (void)setBackgroundColor:(UIColor *)color {
    if (isThemeEnabled()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}

- (void)setTextColor:(UIColor *)color {
    if (isThemeEnabled()) {
        %orig([UIColor whiteColor]);
    } else {
        %orig;
    }
}
%end

%hook YTFormattedStringLabel
- (void)setBackgroundColor:(UIColor *)color {
    if (isThemeEnabled()) {
        %orig([UIColor clearColor]);
    } else {
        %orig;
    }
}
%end

%hook YCHLiveChatActionPanelView
- (void)setBackgroundColor:(UIColor *)color {
    if (isThemeEnabled()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook YTEmojiTextView
- (void)setBackgroundColor:(UIColor *)color {
    if (isThemeEnabled()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook YTCollectionView
- (void)setBackgroundColor:(UIColor *)color {
    if (isThemeEnabled()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook YTBackstageCreateRepostDetailView
- (void)setBackgroundColor:(UIColor *)color {
    if (isThemeEnabled()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook UIApplication
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    %orig;

    if (!isThemeEnabled()) {
        return;
    }

    if (@available(iOS 14.0, *)) {
        UIWindow *window = application.windows.firstObject;
        if (window) {
            window.backgroundColor = activeThemeColor();
        }
    }
}
%end

%hook _ASDisplayView
- (void)layoutSubviews {
    %orig;

    if (!isThemeEnabled()) {
        return;
    }

    UIResponder *responder = [self nextResponder];
    while (responder != nil) {
        if ([responder isKindOfClass:NSClassFromString(@"YTActionSheetDialogViewController")]) {
            self.backgroundColor = activeThemeColor();
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTPanelLoadingStrategyViewController")]) {
            self.backgroundColor = activeThemeColor();
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTTabHeaderElementsViewController")]) {
            self.backgroundColor = activeThemeColor();
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTEditSheetControllerElementsContentViewController")]) {
            self.backgroundColor = activeThemeColor();
        }
        responder = [responder nextResponder];
    }
}

- (void)didMoveToWindow {
    %orig;

    if (!isThemeEnabled()) {
        return;
    }

    UIResponder *responder = self.nextResponder;
    UIViewController *closestViewController = nil;

    while (responder != nil) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            closestViewController = (UIViewController *)responder;
            break;
        }
        responder = responder.nextResponder;
    }

    NSString *controllerName = closestViewController ? NSStringFromClass([closestViewController class]) : nil;
    NSString *superviewName = self.superview ? NSStringFromClass([self.superview class]) : nil;
    NSString *identifier = self.accessibilityIdentifier;

    if ([controllerName isEqualToString:@"YTActionSheetDialogViewController"] &&
        ([superviewName isEqualToString:@"YTELMView"] ||
         [superviewName isEqualToString:@"_ASDisplayView"] ||
         [superviewName isEqualToString:@"ELMView"])) {
        self.backgroundColor = [UIColor clearColor];
    }

    if ([controllerName isEqualToString:@"YTBottomSheetController"]) {
        self.backgroundColor = [UIColor clearColor];
    }

    if ([controllerName isEqualToString:@"YTMySubsFilterHeaderViewController"] &&
        [superviewName isEqualToString:@"YTELMView"]) {
        self.backgroundColor = [UIColor clearColor];
    }

    if ([identifier isEqualToString:@"brand_promo.view"]) {
        self.backgroundColor = activeThemeColor();
    }
    if ([identifier isEqualToString:@"eml.cvr"]) {
        self.backgroundColor = activeThemeColor();
    }
    if ([identifier isEqualToString:@"eml.topic_channel_details"]) {
        self.backgroundColor = activeThemeColor();
    }
    if ([identifier isEqualToString:@"eml.live_chat_text_message"]) {
        self.backgroundColor = activeThemeColor();
    }
    if ([identifier isEqualToString:@"rich_header"]) {
        self.backgroundColor = activeThemeColor();
    }
    if ([identifier isEqualToString:@"id.ui.comment_cell"]) {
        self.backgroundColor = activeThemeColor();
        if (self.superview) {
            self.superview.backgroundColor = activeThemeColor();
        }
    }
    if ([identifier isEqualToString:@"id.ui.comment_thread"]) {
        self.backgroundColor = activeThemeColor();
    }
    if ([identifier isEqualToString:@"id.elements.components.comment_composer"]) {
        self.backgroundColor = activeThemeColor();
    }
    if ([identifier isEqualToString:@"id.elements.components.filter_chip_bar"]) {
        self.backgroundColor = activeThemeColor();
    }
    if ([identifier isEqualToString:@"id.elements.components.video_list_entry"]) {
        self.backgroundColor = activeThemeColor();
    }
    if ([identifier isEqualToString:@"id.comment.guidelines_text"]) {
        self.superview.backgroundColor = activeThemeColor();
    }
    if ([identifier isEqualToString:@"id.comment.timed_comments_welcome"]) {
        self.superview.backgroundColor = activeThemeColor();
        self.backgroundColor = activeThemeColor();
    }
    if ([identifier isEqualToString:@"id.comment.channel_guidelines_bottom_sheet_container"]) {
        self.backgroundColor = activeThemeColor();
    }
    if ([identifier isEqualToString:@"id.comment.channel_guidelines_entry_banner_container"]) {
        self.superview.backgroundColor = activeThemeColor();
        self.backgroundColor = activeThemeColor();
    }
    if ([identifier isEqualToString:@"id.comment.comment_group_detail_container"]) {
        self.backgroundColor = [UIColor clearColor];
    }
    if ([identifier hasPrefix:@"id.elements.components.overflow_menu_item_"]) {
        self.backgroundColor = [UIColor clearColor];
    }
}
%end

%hook ASWAppSwitchingSheetHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    if (isOLEDThemeEnabled() || isCustomThemeEnabled()) {
        %orig(sheetRaisedColor());
    } else {
        %orig;
    }
}
%end

%hook ASWAppSwitchingSheetFooterView
- (void)setBackgroundColor:(UIColor *)color {
    if (isOLEDThemeEnabled() || isCustomThemeEnabled()) {
        %orig(sheetRaisedColor());
    } else {
        %orig;
    }
}
%end

%hook ASWAppSwitcherCollectionViewCell
- (void)didMoveToWindow {
    %orig;

    if (isOLEDThemeEnabled() || isCustomThemeEnabled()) {
        self.backgroundColor = sheetRaisedColor();
        if (self.superview) {
            self.superview.backgroundColor = sheetRaisedColor();
        }
    }
}
%end

%end

%group gOLEDKeyboard

%hook TUIEmojiSearchView
- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor blackColor];
}
%end

%hook UIPredictionViewController
- (void)loadView {
    %orig;
    self.view.backgroundColor = [UIColor blackColor];
}
%end

%hook UICandidateViewController
- (void)loadView {
    %orig;
    self.view.backgroundColor = [UIColor blackColor];
}
%end

%hook UIKeyboardDockView
- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor blackColor];
}
%end

%hook UIKeyboardLayoutStar
- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor blackColor];
}
%end

%hook UIKBRenderConfig
- (void)setLightKeyboard:(BOOL)arg1 {
    %orig(NO);
}
%end

%end

%ctor {
    cachedThemeMode = YTCDTThemeModeValue();
    cachedOLEDKeyboardEnabled = YTCDTOLEDKeyboardEnabled();
    customThemeColor = YTCDTCustomThemeColor();

    if (cachedThemeMode == YTCDTThemeModeClassicGray ||
        cachedThemeMode == YTCDTThemeModeOLED ||
        (cachedThemeMode == YTCDTThemeModeCustom && customThemeColor != nil)) {
        %init(gClassicDarkTheme);
    }

    if (cachedOLEDKeyboardEnabled) {
        %init(gOLEDKeyboard);
    }
}
