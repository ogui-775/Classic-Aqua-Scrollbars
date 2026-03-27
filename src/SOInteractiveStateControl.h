//Created by Salty on 3/21/26.

#import "SOStateControl.h"
#import <AppKit/AppKit.h>

#import "../ext/SOMath.h"

@interface SOInteractiveStateControl : SOStateControl
@property BOOL mouseDownInFrame;
@property SEL pressedSel;
@property (strong) NSTimer * timer;
@property (assign) CGFloat modAmount;
@property (weak) id weakTarg;
- (void)handleMouseDown:(NSEvent *)event inView:(NSView *)view;
- (void)handleMouseUp:(NSEvent *)event inView:(NSView *)view;
@end
