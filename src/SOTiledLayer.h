//Created by Salty on 3/19/26.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AppKit/NSImage.h>

#import "SOScrollerResources.h"
#import "SOScrollerOverlay.h"
#import "SOStateControl.h"

@interface SOTiledLayer : CALayer
@property (assign) SOScrollOrientation orientation;
@property (strong) SOStateControl * stateController;
- (instancetype)initWithOrientation:(SOScrollOrientation)o;
- (void)changeOrientationTo:(SOScrollOrientation)orientation;
@end
