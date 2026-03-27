//Created by Salty on 3/15/26.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AppKit/AppKit.h>
#import <objc/runtime.h>

#import "SOScrollerResources.h"
#import "SOScrollerOverlay.h"
#import "SOReplicantMask.h"
#import "SOTrackLayer.h"
#import "SOTiledLayer.h"
#import "SOScrollButton.h"

@interface SOClassicAquaScrollbar : NSObject @end

@interface NSRegularLegacyScrollerImp : NSObject
@property CALayer * trackLayer;
@property CALayer * knobLayer;
@property CALayer * layer;
@property CGFloat knobLength;
@property CGFloat doubleValue;
@property CGFloat knobAlpha;
- (void)setKnobColor:(NSColor *)color;
+ (BOOL)iAmAWebKit:(NSRegularLegacyScrollerImp *)imp;
@end
