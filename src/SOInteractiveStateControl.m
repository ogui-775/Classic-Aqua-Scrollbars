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
        NSRect bounds = cv.bounds;
        NSRect docFrame = docView.frame;
        BOOL flipped = docView.isFlipped;
        NSRect visible = cv.documentVisibleRect;
        
        if (o == SOScrollOrientationVertical){
            CGFloat delta = self.modAmount * (flipped ? 1 : -1);
            CGFloat maxY = docFrame.size.height - visible.size.height;
            if (maxY < 0) maxY = 0;
            
            CGFloat minY = bounds.origin.y - visible.size.height;

            CGFloat newY = bounds.origin.y - delta;
            newY = CLAMP(minY, newY, maxY);

            NSPoint constrained = [cv constrainScrollPoint:CGPointMake(bounds.origin.x, newY)];

            [cv scrollToPoint:constrained];
            [v reflectScrolledClipView:cv];
        } else {
            CGFloat delta = self.modAmount * (flipped ? -1 : 1);
            CGFloat maxX = docFrame.size.width - visible.size.width;
            if (maxX < 0) maxX = 0;
            
            CGFloat minX = bounds.origin.x - visible.size.width;

            CGFloat newX = bounds.origin.x - delta;
            newX = CLAMP(minX, newX, maxX);

            NSPoint constrained = [cv constrainScrollPoint:CGPointMake(newX, bounds.origin.y)];

            [cv scrollToPoint:constrained];
            [v reflectScrolledClipView:cv];
        }

    };

    scrollBlock();

    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer *timer) {
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
