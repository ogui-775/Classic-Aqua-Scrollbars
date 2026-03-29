//Created by Salty on 3/16/26.

#import "SOScrollerOverlay.h"

static NSString * const kCAContentsScalingRepeat = @"repeat";
static NSString * const kCAContentsScalingStretch = @"stretch";

@implementation SOScrollerOverlay

- (instancetype)initWithLayer:(CALayer *)layer orientation:(SOScrollOrientation)orientation{
    self = [super initWithLayer:layer];
    if (self){
        self.knobParentLayer = layer;
        
        self.topCapLayer = [CALayer layer];
        self.middleLayer = [CALayer layer];
        self.bottomLayer = [CALayer layer];
        
        self.topCapLayer.contents = (__bridge id)([[SOScrollerResources sharedInstance] knobOverlayTopForOrientation:orientation]);
        
        self.middleLayer.contents = (__bridge id)([[SOScrollerResources sharedInstance] knobOverlayMiddleForOrientation:orientation]);
        
        self.bottomLayer.contents = (__bridge id)([[SOScrollerResources sharedInstance] knobOverlayBottomForOrientation:orientation]);
        
        [self addSublayer:self.topCapLayer];
        [self addSublayer:self.middleLayer];
        [self addSublayer:self.bottomLayer];
        
        self.orientation = orientation;
        
        [self setGeometryFlipped:YES];
        
        [self.topCapLayer setContentsGravity:kCAGravityResize];
        [self.middleLayer setContentsGravity:kCAGravityResize];
        [self.bottomLayer setContentsGravity:kCAGravityResize];
        
        self.stateControllerTop = [[SOStateControl alloc] initWithLayer:self.topCapLayer
                                                          trackLayer:self
                                                           activeSel:@selector(knobOverlayTopForOrientation:)
                                                         inactiveSel:@selector(inactiveKnobOverlayTopForOrientation:)
                                                     currentOrientation:orientation];
        
        self.stateControllerMiddle = [[SOStateControl alloc] initWithLayer:self.middleLayer
                                                                trackLayer:self
                                                                 activeSel:@selector(knobOverlayMiddleForOrientation:)
                                                               inactiveSel:@selector(inactiveKnobOverlayMiddleForOrientation:) currentOrientation:orientation];
        
        self.stateControllerBottom = [[SOStateControl alloc] initWithLayer:self.bottomLayer
                                                                trackLayer:self
                                                                 activeSel:@selector(knobOverlayBottomForOrientation:)
                                                               inactiveSel:@selector(inactiveKnobOverlayBottomForOrientation:)
                                                        currentOrientation:orientation];
        
        self.zPosition++;
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [super setFrame:frame];

    if (self.orientation == SOScrollOrientationVertical){
        CGFloat topSize = CGImageGetHeight((__bridge CGImageRef)self.topCapLayer.contents) * 0.5;
        CGFloat botSize = CGImageGetHeight((__bridge CGImageRef)self.bottomLayer.contents) * 0.5;
        
        CGFloat capSize = topSize + botSize;
        CGSize trackSize = self.trackLayer.bounds.size;

        if (capSize >= frame.size.height){
            if (!self.middleLayer.isHidden)
                [self.middleLayer setHidden:YES];
            
            [self.bottomLayer setFrame:CGRectMake(-frame.origin.x, 0, trackSize.width - 3, frame.size.height / 2)];
            [self.topCapLayer setFrame:CGRectMake(-frame.origin.x, frame.size.height / 2, trackSize.width - 3, frame.size.height / 2)];
        } else {
            if (self.middleLayer.isHidden)
                [self.middleLayer setHidden:NO];
            
            [self.bottomLayer setFrame:CGRectMake(-frame.origin.x, 0, trackSize.width - 3, botSize)];
            [self.middleLayer setFrame:CGRectMake(-frame.origin.x, botSize, trackSize.width - 3, frame.size.height - botSize - topSize)];
            [self.topCapLayer setFrame:CGRectMake(-frame.origin.x, self.middleLayer.bounds.size.height + botSize - 1, trackSize.width - 3, topSize)];
        }

        [self.replicantMask setFrame:CGRectMake(0,
                                                frame.origin.y,
                                                trackSize.width - 1,
                                                frame.size.height)];
        [self.replicantMask setNeedsDisplay];
    } else {
        CGFloat topSize = CGImageGetWidth((__bridge CGImageRef)self.topCapLayer.contents) * 0.5;
        CGFloat botSize = CGImageGetWidth((__bridge CGImageRef)self.bottomLayer.contents) * 0.5;
        
        CGFloat capSize = topSize + botSize;
        CGSize trackSize = self.trackLayer.bounds.size;
        
        if (capSize >= frame.size.width){
            if (!self.middleLayer.isHidden)
                [self.middleLayer setHidden:YES];
            
            [self.bottomLayer setFrame:CGRectMake(0, -1, frame.size.width / 2, trackSize.height - 4)];
            [self.topCapLayer setFrame:CGRectMake(frame.size.width / 2, -1, frame.size.width / 2, trackSize.height - 4)];
        } else {
            if (self.middleLayer.isHidden)
                [self.middleLayer setHidden:NO];
            
            [self.bottomLayer setFrame:CGRectMake(0, -1, botSize, trackSize.height - 4)];
            [self.middleLayer setFrame:CGRectMake(botSize, -1, frame.size.width - botSize - topSize, trackSize.height - 4)];
            [self.topCapLayer setFrame:CGRectMake(self.middleLayer.bounds.size.width + botSize - 1, -1, topSize, trackSize.height - 4)];
        }
        [self.replicantMask setFrame:CGRectMake(frame.origin.x,
                                                0,
                                                frame.size.width,
                                                trackSize.height - 1)];
        
        [self.replicantMask setNeedsDisplay];
    }

    [CATransaction commit];
}

- (void)layoutSublayers{
    [super layoutSublayers];
    [self setFrame:self.knobParentLayer.frame];
}

- (void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    if (hidden){
        [self setOpacity:0];
        [self.replicantMask setHidden:YES];
    }
    else if (!hidden){
        [self setOpacity:1];
        [self.replicantMask setHidden:NO];
    }
    [self.replicantMask setNeedsDisplay];
}

- (void)changeOrientationTo:(SOScrollOrientation)orientation{
    if (orientation == self.orientation)
        return;
    
    for (SOStateControl * c in @[self.stateControllerTop, self.stateControllerBottom, self.stateControllerMiddle])
        [c setOrientation:orientation];
    
    self.topCapLayer.contents = (__bridge id)([[SOScrollerResources sharedInstance] knobOverlayTopForOrientation:orientation]);
    
    self.middleLayer.contents = (__bridge id)([[SOScrollerResources sharedInstance] knobOverlayMiddleForOrientation:orientation]);
    
    self.bottomLayer.contents = (__bridge id)([[SOScrollerResources sharedInstance] knobOverlayBottomForOrientation:orientation]);
    
    self.orientation = orientation;
    
    [self.replicantMask setNeedsDisplay];
}
@end
