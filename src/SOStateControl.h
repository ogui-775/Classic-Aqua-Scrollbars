//Created by Salty on 3/20/26.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AppKit/AppKit.h>
#import <objc/runtime.h>

#import "SOScrollerResources.h"
#import "SOStateControl.h"

@interface SOStateControl : NSControl
- (instancetype)initWithLayer:(CALayer *)layer trackLayer:(CALayer *)trackLayer activeSel:(SEL)activeSel inactiveSel:(SEL)inactiveSel currentOrientation:(SOScrollOrientation)o;
@property SEL activeSel;
@property SEL inactiveSel;
@property (weak) CALayer * boundLayer;
@property (weak) CALayer * trackLayer;
@property (assign) SOScrollOrientation orientation;
@property (assign) BOOL isActive;
- (void)forceActiveStateTo:(BOOL)active;
@end
