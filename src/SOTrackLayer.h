//Created by Salty on 3/19/26.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AppKit/NSColor.h>

#import "SOScrollerResources.h"

@interface SOTrackLayer : CALayer
@property (assign) SOScrollOrientation orientation;

- (void)changeOrientationTo:(SOScrollOrientation)orientation;
@end

@interface CALayer (PrivateB)
- (void)setContentsScaling:(NSString *)scaling;
- (NSString *)contentsScaling;
@end
