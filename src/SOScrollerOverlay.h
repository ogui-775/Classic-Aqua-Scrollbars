//Created by Salty on 3/16/26.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AppKit/NSScreen.h>
#import <AppKit/NSColor.h>

#import "SOScrollerResources.h"
#import "SOTrackLayer.h"
#import "SOStateControl.h"

@interface SOScrollerOverlay : CALayer

- (instancetype)initWithLayer:(CALayer *)layer orientation:(SOScrollOrientation)orientation;
- (void)changeOrientationTo:(SOScrollOrientation)orientation;

@property (assign) SOScrollOrientation orientation;
@property (weak)   CALayer * knobParentLayer;
@property (strong) CALayer * replicantMask;
@property (strong) CALayer * topCapLayer;
@property (strong) CALayer * middleLayer;
@property (strong) CALayer * bottomLayer;
@property (weak)   SOTrackLayer * trackLayer;
@property (strong) SOStateControl * stateControllerTop;
@property (strong) SOStateControl * stateControllerMiddle;
@property (strong) SOStateControl * stateControllerBottom;
@end

@interface CALayer (Private)
- (void)setContentsScaling:(NSString *)scaling;
- (NSString *)contentsScaling;
@end
