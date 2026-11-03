#import <UIKit/UIKit.h>

#import "YTCDTPrefs.h"

@interface TUIEmojiSearchView : UIView
@end

@interface UIPredictionViewController : UIViewController
@end

@interface UICandidateViewController : UIViewController
@end

@interface UIKeyboardDockView : UIView
@end

@interface UIKeyboardLayoutStar : UIView
@end

@interface UIKBRenderConfig : NSObject
@end

static BOOL cachedOLEDKeyboardEnabled = NO;

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
    cachedOLEDKeyboardEnabled = YTCDTOLEDKeyboardEnabled();

    if (cachedOLEDKeyboardEnabled) {
        %init(gOLEDKeyboard);
    }
}