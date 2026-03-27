//Created by Salty on 3/19/26.

#import "SOTrackLayer.h"

@implementation SOTrackLayer

- (instancetype)init{
    if (self = [super init]){
        self.contentsScale = 2.0;
        self.contentsGravity = kCAGravityResize;
        self.geometryFlipped = NO;
    }
    return self;
}

- (void)changeOrientationTo:(SOScrollOrientation)orientation{
    if (self.orientation == orientation)
        return;
    
    self.contents = (__bridge id)[[SOScrollerResources sharedInstance] trackImageForOrientation:orientation];

    self.orientation = orientation;
}

@end
