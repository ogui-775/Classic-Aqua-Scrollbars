//Created by Salty on 3/21/26.

#import "SOInteractiveStateControl.h"

@implementation SOInteractiveStateControl

- (void)handleMouseDown:(NSEvent *)event inView:(NSView *)view{
    NSPoint p = [view convertPoint:event.locationInWindow fromView:nil];
    if (!NSPointInRect(p, view.bounds))
        return;

    self.mouseDownInFrame = YES;
    
    static CGImageRef (*resourceSelFunc)(id, SEL, SOScrollOrientation);
    SOScrollOrientation o = self.orientation;
    SOScrollerResources * instance = [SOScrollerResources sharedInstance];
    Method m = class_getInstanceMethod(SOScrollerResources.class, self.pressedSel);
    resourceSelFunc = (void *)method_getImplementation(m);
    self.boundLayer.contents = (__bridge id)resourceSelFunc(instance, self.pressedSel, o);
    
    void (^scrollBlock)(void) = ^{
        NSScrollView * v = (NSScrollView *)[[self.weakTarg valueForKey:@"_scroller"] superview];
        NSClipView * cv = [v contentView];
        NSView * docView = cv.documentView;
        CGRect bounds = [cv constrainBoundsRect:cv.bounds];
        BOOL flipped = docView.isFlipped;
        
        if (o == SOScrollOrientationVertical){
            CGFloat delta = (self.mod * v.verticalLineScroll) * (flipped ? 1 : -1);
            
            if ((v.verticalScroller.doubleValue == 1 && delta < 0) || (v.verticalScroller.doubleValue == 0 && delta > 0))
                return;

            CGFloat newY = bounds.origin.y - delta;

            [cv scrollToPoint:[cv constrainScrollPoint:CGPointMake(bounds.origin.x, newY)]];
            [v reflectScrolledClipView:cv];
            
        } else {
            CGFloat delta = (self.mod * v.horizontalLineScroll) * (flipped ? -1 : 1);

            if ((v.horizontalScroller.doubleValue == 1 && delta < 0) || (v.horizontalScroller.doubleValue == 0 && delta > 0))
                return;
            
            CGFloat newX = bounds.origin.x - delta;

            [cv scrollToPoint:[cv constrainScrollPoint:CGPointMake(newX, bounds.origin.y)]];
            [v reflectScrolledClipView:cv];
        }

    };

    scrollBlock();

    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.10 repeats:YES block:^(NSTimer *timer) {
        
        scrollBlock();
    }];

    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSEventTrackingRunLoopMode];
}

- (void)handleMouseUp:(NSEvent *)event inView:(NSView *)view{
    if (!self.mouseDownInFrame)
        return;
    
    static CGImageRef (*resourceSelFunc)(id, SEL, SOScrollOrientation);
    SEL correctSel = self.isActive ? self.activeSel : self.inactiveSel;
    SOScrollOrientation o = self.orientation;
    SOScrollerResources * instance = [SOScrollerResources sharedInstance];
    Method m = class_getInstanceMethod(SOScrollerResources.class, correctSel);
    resourceSelFunc = (void *)method_getImplementation(m);
    self.boundLayer.contents = (__bridge id)resourceSelFunc(instance, correctSel, o);
    
    self.mouseDownInFrame = NO;
    [self.timer invalidate];
}

-(void)dealloc{
    if (self.timer)
        [self.timer invalidate];
}
@end
