#import "Tweak.h"

static inline UIColor *oldDarkThemeColor() {
    return [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.0];
}

%group gOldDarkTheme

%hook YTCommonColorPalette
- (UIColor *)background1 {
    return oldDarkThemeColor();
}
- (UIColor *)background2 {
    return oldDarkThemeColor();
}
- (UIColor *)background3 {
    return oldDarkThemeColor();
}
- (UIColor *)baseBackground {
    return oldDarkThemeColor();
}
- (UIColor *)brandBackgroundSolid {
    return oldDarkThemeColor();
}
- (UIColor *)brandBackgroundPrimary {
    return oldDarkThemeColor();
}
- (UIColor *)brandBackgroundSecondary {
    return [oldDarkThemeColor() colorWithAlphaComponent:0.9];
}
- (UIColor *)raisedBackground {
    return oldDarkThemeColor();
}
- (UIColor *)staticBrandBlack {
    return oldDarkThemeColor();
}
- (UIColor *)generalBackgroundA {
    return oldDarkThemeColor();
}
- (UIColor *)generalBackgroundB {
    return oldDarkThemeColor();
}
- (UIColor *)menuBackground {
    return oldDarkThemeColor();
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

%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;

    if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.comment_composer"]) {
        self.backgroundColor = [UIColor clearColor];
    }
    if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.video_list_entry"]) {
        self.backgroundColor = [UIColor clearColor];
    }
}
%end

%hook ASCollectionView
- (void)didMoveToWindow {
    %orig;
    if (self.superview) {
        self.superview.backgroundColor = oldDarkThemeColor();
    }
}
%end

%hook YTFullscreenEngagementOverlayView
- (void)didMoveToWindow {
    %orig;
    if (self.subviews.count > 0) {
        self.subviews[0].backgroundColor = [UIColor clearColor];
    }
}
%end

%hook YTRelatedVideosView
- (void)didMoveToWindow {
    %orig;
    if (self.subviews.count > 0) {
        self.subviews[0].backgroundColor = [UIColor clearColor];
    }
}
%end

%end

%ctor {
    %init(gOldDarkTheme);
}
