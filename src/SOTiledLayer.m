//Created by Salty on 3/19/26.

#import "SOTiledLayer.h"

static NSString * const kCAContentsScalingRepeat = @"repeat";
static NSString * const kCAContentsScalingStretch = @"stretch";

@implementation SOTiledLayer

- (instancetype)initWithOrientation:(SOScrollOrientation)o{
    self = [super init];
    if (self){
        [self setContentsScale:2];
        [self setContentsGravity:kCAGravityResize];
        [self setContentsScaling:kCAContentsScalingRepeat];
        self.orientation = o;
        [self setContents:(__bridge id)[[SOScrollerResources sharedInstance] tilingImageForOrientation:o]];
        self.stateController = [[SOStateControl alloc] initWithLayer:self
                                                          trackLayer:self
                                                           activeSel:@selector(tilingImageForOrientation:)
                                                         inactiveSel:@selector(inactiveTilingImageForOrientation:)
                                                  currentOrientation:o];
        
        self.backgroundColor = [NSColor clearColor].CGColor;
        self.zPosition++;
    }
    return self;
}

- (void)changeOrientationTo:(SOScrollOrientation)orientation{
    if (self.orientation == orientation)
        return;
    
    [self.stateController setOrientation:orientation];
    [self setContents:(__bridge id)[[SOScrollerResources sharedInstance] tilingImageForOrientation:orientation]];
    
    self.orientation = orientation;
}
@end
