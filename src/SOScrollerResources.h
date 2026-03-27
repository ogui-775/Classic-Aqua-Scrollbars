//Created by Salty on 3/15/26.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AppKit/NSScreen.h>

typedef enum : NSUInteger {
    SOScrollOrientationHorizontal,
    SOScrollOrientationVertical,
} SOScrollOrientation;

@interface SOScrollerResources : NSObject
+ (instancetype)sharedInstance;

//Track
- (CGImageRef)trackImageForOrientation:(SOScrollOrientation)orientation;
- (CGImageRef)tilingImageForOrientation:(SOScrollOrientation)orientation;

//Masked tiling
- (CGImageRef)inactiveTilingImageForOrientation:(SOScrollOrientation)orientation;

//Knob
- (CGImageRef)knobOverlayTopForOrientation:(SOScrollOrientation)orientation;
- (CGImageRef)inactiveKnobOverlayTopForOrientation:(SOScrollOrientation)orientation;
- (CGImageRef)knobOverlayMiddleForOrientation:(SOScrollOrientation)orientation;
- (CGImageRef)inactiveKnobOverlayMiddleForOrientation:(SOScrollOrientation)orientation;
- (CGImageRef)knobOverlayBottomForOrientation:(SOScrollOrientation)orientation;
- (CGImageRef)inactiveKnobOverlayBottomForOrientation:(SOScrollOrientation)orientation;

// Arrows - Up //
- (CGImageRef)upArrowForOrientation:(SOScrollOrientation)orientation;
- (CGImageRef)inactiveUpArrowForOrientation:(SOScrollOrientation)orientation;
- (CGImageRef)pressedUpArrowForOrientation:(SOScrollOrientation)orientation;
// Down
- (CGImageRef)downArrowForOrientation:(SOScrollOrientation)orientation;
- (CGImageRef)inactiveDownArrowForOrientation:(SOScrollOrientation)orientation;
- (CGImageRef)pressedDownArrowForOrientation:(SOScrollOrientation)orientation;
@end
