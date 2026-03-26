#import "Tweak.h"
#import "YTCDTPrefs.h"

static BOOL cachedEnabled = NO;
static YTCDTThemeType cachedThemeType = YTCDTThemeTypeBuiltIn;
static YTCDTBuiltInStyle cachedBuiltInStyle = YTCDTBuiltInStyleClassicGray;
static BOOL cachedOLEDKeyboardEnabled = NO;
static BOOL cachedRemoveRoundedCornersEnabled = NO;
static UIColor *customThemeColor = nil;

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

static inline UIColor *sheetRaisedColor() {
    return [UIColor colorWithRed:0.035 green:0.035 blue:0.035 alpha:1.0];
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

static inline BOOL isGonerinoListViewController(id object) {
    Class cls = NSClassFromString(@"ListViewController");
    return cls != Nil && [object isKindOfClass:cls];
}

%group gClassicDarkTheme

%hook YTCommonColorPalette
- (UIColor *)background1 {
    UIColor *origColor = %orig;
    return shouldApplyYTCDTTheme() ? activeThemeColor() : origColor;
}
- (UIColor *)background2 {
    UIColor *origColor = %orig;
    return shouldApplyYTCDTTheme() ? activeThemeColor() : origColor;
}
- (UIColor *)background3 {
    UIColor *origColor = %orig;
    return shouldApplyYTCDTTheme() ? activeThemeColor() : origColor;
}
- (UIColor *)baseBackground {
    UIColor *origColor = %orig;
    return shouldApplyYTCDTTheme() ? activeThemeColor() : origColor;
}
- (UIColor *)brandBackgroundSolid {
    UIColor *origColor = %orig;
    return shouldApplyYTCDTTheme() ? activeThemeColor() : origColor;
}
- (UIColor *)brandBackgroundPrimary {
    UIColor *origColor = %orig;
    return shouldApplyYTCDTTheme() ? activeThemeColor() : origColor;
}
- (UIColor *)brandBackgroundSecondary {
    UIColor *origColor = %orig;
    return shouldApplyYTCDTTheme() ? activeSecondaryThemeColor() : origColor;
}
- (UIColor *)raisedBackground {
    UIColor *origColor = %orig;
    return shouldApplyYTCDTTheme() ? activeThemeColor() : origColor;
}
- (UIColor *)staticBrandBlack {
    UIColor *origColor = %orig;
    return shouldApplyYTCDTTheme() ? activeThemeColor() : origColor;
}
- (UIColor *)generalBackgroundA {
    UIColor *origColor = %orig;
    return shouldApplyYTCDTTheme() ? activeThemeColor() : origColor;
}
- (UIColor *)generalBackgroundB {
    UIColor *origColor = %orig;
    return shouldApplyYTCDTTheme() ? activeThemeColor() : origColor;
}
- (UIColor *)menuBackground {
    UIColor *origColor = %orig;
    return shouldApplyYTCDTTheme() ? activeThemeColor() : origColor;
}
%end

%hook YTColdConfig
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteBgColorForNative {
    return shouldApplyYTCDTTheme() ? NO : %orig;
}
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteTextColorForNative {
    return shouldApplyYTCDTTheme() ? NO : %orig;
}
- (BOOL)enableCinematicContainerOnClient {
    return shouldApplyYTCDTTheme() ? NO : %orig;
}
%end

%hook YTInnerTubeCollectionViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    UIColor *origColor = %orig;
    return shouldApplyYTCDTTheme() ? activeThemeColor() : origColor;
}
%end

%hook YTWatchRoundedCornersView
- (void)didMoveToWindow {
    %orig;

    if (shouldApplyYTCDTTheme() && !cachedRemoveRoundedCornersEnabled) {
        self.backgroundColor = activeThemeColor();
    }
}

- (void)setHidden:(BOOL)hidden {
    if (cachedRemoveRoundedCornersEnabled) {
        %orig(YES);
        return;
    }

    %orig(hidden);
}
%end

%hook ASScrollView
- (void)didMoveToWindow {
    %orig;

    if (shouldApplyYTCDTTheme()) {
        self.backgroundColor = [UIColor clearColor];
    }
}
%end

%hook ASCollectionView
- (void)didMoveToWindow {
    %orig;

    if (!shouldApplyYTCDTTheme()) {
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

    if (!shouldApplyYTCDTTheme()) {
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

    if (!shouldApplyYTCDTTheme()) {
        return;
    }

    if (self.subviews.count > 0) {
        self.subviews[0].backgroundColor = [UIColor clearColor];
    }
}
%end

%hook YTSearchBarView
- (void)setBackgroundColor:(UIColor *)color {
    if (shouldApplyYTCDTTheme()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook YTSearchBoxView
- (void)setBackgroundColor:(UIColor *)color {
    if (shouldApplyYTCDTTheme()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook YTCommentView
- (void)setBackgroundColor:(UIColor *)color {
    if (shouldApplyYTCDTTheme()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook YTChipCloudCell
- (void)didMoveToWindow {
    %orig;

    if (!cachedRemoveRoundedCornersEnabled) {
        return;
    }

    self.hidden = YES;
}
%end

%hook YTCreateCommentAccessoryView
- (void)setBackgroundColor:(UIColor *)color {
    if (shouldApplyYTCDTTheme()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook YTCreateCommentTextView
- (void)setBackgroundColor:(UIColor *)color {
    if (shouldApplyYTCDTTheme()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}

- (void)setTextColor:(UIColor *)color {
    if (shouldApplyYTCDTTheme()) {
        %orig([UIColor whiteColor]);
    } else {
        %orig;
    }
}
%end

%hook YTFormattedStringLabel
- (void)setBackgroundColor:(UIColor *)color {
    if (shouldApplyYTCDTTheme()) {
        %orig([UIColor clearColor]);
    } else {
        %orig;
    }
}
%end

%hook YCHLiveChatActionPanelView
- (void)setBackgroundColor:(UIColor *)color {
    if (shouldApplyYTCDTTheme()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook YTEmojiTextView
- (void)setBackgroundColor:(UIColor *)color {
    if (shouldApplyYTCDTTheme()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook YTCollectionView
- (void)setBackgroundColor:(UIColor *)color {
    if (shouldApplyYTCDTTheme()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook YTBackstageCreateRepostDetailView
- (void)setBackgroundColor:(UIColor *)color {
    if (shouldApplyYTCDTTheme()) {
        %orig(activeThemeColor());
    } else {
        %orig;
    }
}
%end

%hook UIViewController

- (void)viewDidLoad {
    %orig;

    if (!shouldApplyYTCDTTheme() || !isGonerinoListViewController(self)) {
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

    if (!shouldApplyYTCDTTheme() || !isGonerinoListViewController(self)) {
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

%hook UIApplication
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    %orig;

    if (!shouldApplyYTCDTTheme()) {
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

    if (!shouldApplyYTCDTTheme()) {
        return;
    }

    NSString *identifier = self.accessibilityIdentifier;
    NSString *parentIdentifier = self.superview.accessibilityIdentifier;

    if ([identifier isEqualToString:@"eml.animated_subscribe_button"] ||
        [parentIdentifier isEqualToString:@"eml.animated_subscribe_button"]) {
        self.backgroundColor = [UIColor clearColor];
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

    if (!shouldApplyYTCDTTheme()) {
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

    NSString *parentIdentifier = self.superview.accessibilityIdentifier;

    if ([identifier isEqualToString:@"eml.animated_subscribe_button"] ||
        [parentIdentifier isEqualToString:@"eml.animated_subscribe_button"]) {
        return;
    }

    if ([identifier isEqualToString:@"brand_promo.view"] ||
        [parentIdentifier isEqualToString:@"brand_promo.view"]) {
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
        if (self.superview) {
            self.superview.backgroundColor = activeThemeColor();
        }
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
    if (shouldApplyYTCDTTheme() &&
        (isOLEDThemeEnabled() || isCustomThemeEnabled())) {
        %orig(sheetRaisedColor());
    } else {
        %orig;
    }
}
%end

%hook ASWAppSwitchingSheetFooterView
- (void)setBackgroundColor:(UIColor *)color {
    if (shouldApplyYTCDTTheme() &&
        (isOLEDThemeEnabled() || isCustomThemeEnabled())) {
        %orig(sheetRaisedColor());
    } else {
        %orig;
    }
}
%end

%hook ASWAppSwitcherCollectionViewCell
- (void)didMoveToWindow {
    %orig;
    if (shouldApplyYTCDTTheme() &&
        (isOLEDThemeEnabled() || isCustomThemeEnabled())) {
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
    cachedEnabled = YTCDTEnabled();
    cachedThemeType = YTCDTThemeTypeValue();
    cachedBuiltInStyle = YTCDTBuiltInStyleValue();
    cachedOLEDKeyboardEnabled = YTCDTOLEDKeyboardEnabled();
    cachedRemoveRoundedCornersEnabled = YTCDTRemoveRoundedCornersEnabled();
    customThemeColor = YTCDTCustomThemeColor();

    if (cachedRemoveRoundedCornersEnabled ||
        (cachedEnabled &&
         (cachedThemeType == YTCDTThemeTypeBuiltIn ||
          (cachedThemeType == YTCDTThemeTypeCustomColor && customThemeColor != nil)))) {
        %init(gClassicDarkTheme);
    }

    if (cachedOLEDKeyboardEnabled) {
        %init(gOLEDKeyboard);
    }
}
