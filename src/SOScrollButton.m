//Created by Salty on 3/21/26.

#import "SOScrollButton.h"

@implementation SOScrollButton

- (instancetype)initWithFrame:(NSRect)frameRect track:(SOTrackLayer *)track orientation:(SOScrollOrientation)o isUpArrow:(BOOL)up{
    if (self = [super initWithFrame:frameRect]){
        [self setWantsLayer:YES];
        self.layer.frame = frameRect;
        self.isUpArrow = up;
        [self.layer setContentsScale:2];
        [self.layer setNeedsDisplayOnBoundsChange:YES];
        [self.layer setContentsGravity:kCAGravityResize];
        
        SEL activeSel = nil;
        SEL inactiveSel = nil;
        SEL pressedSel = nil;
        
        if (up){
            activeSel = @selector(upArrowForOrientation:);
            inactiveSel = @selector(inactiveUpArrowForOrientation:);
            pressedSel = @selector(pressedUpArrowForOrientation:);
        } else {
            activeSel = @selector(downArrowForOrientation:);
            inactiveSel = @selector(inactiveDownArrowForOrientation:);
            pressedSel = @selector(pressedDownArrowForOrientation:);
        }
        
        self.iStateController = [[SOInteractiveStateControl alloc] initWithLayer:self.layer
                                                                      trackLayer:track
                                                                       activeSel:activeSel
                                                                     inactiveSel:inactiveSel
                                                              currentOrientation:o];
        [self.iStateController setPressedSel:pressedSel];
        
        self.isUpArrow ?
            [self.layer setContents:(__bridge id)[[SOScrollerResources sharedInstance] upArrowForOrientation:o]] :                     [self.layer setContents:(__bridge id)[[SOScrollerResources sharedInstance] downArrowForOrientation:o]];
    }
    return self;
}

- (void)dealloc{
    [self.layer removeFromSuperlayer];
    [self removeFromSuperview];
}

- (void)mouseDown:(NSEvent *)event {
    [self.iStateController handleMouseDown:event inView:self];
}

- (void)mouseUp:(NSEvent *)event {
    [self.iStateController handleMouseUp:event inView:self];
}

- (BOOL)acceptsFirstResponder{
    return YES;
}

- (NSView *)hitTest:(NSPoint)point{
    NSView * ret = [super hitTest:point];
    return ret == self ? self : nil;
}

- (void)changeOrientationTo:(SOScrollOrientation)orientation{
    if (!self.iStateController)
        return;
    
    if (self.iStateController.orientation == orientation)
        return;
    
    self.isUpArrow ?
        [self.layer setContents:(__bridge id)[[SOScrollerResources sharedInstance] upArrowForOrientation:orientation]] :                     [self.layer setContents:(__bridge id)[[SOScrollerResources sharedInstance] downArrowForOrientation:orientation]];
    
    self.iStateController.orientation = orientation;
}
@end
