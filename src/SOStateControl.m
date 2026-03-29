//Created by Salty on 3/20/26.

#import "SOStateControl.h"

@implementation SOStateControl

- (instancetype)initWithLayer:(CALayer *)layer trackLayer:(CALayer *)trackLayer activeSel:(SEL)activeSel inactiveSel:(SEL)inactiveSel currentOrientation:(SOScrollOrientation)o{
    self = [super init];
    if (self){
        self.boundLayer = layer;
        self.activeSel = activeSel;
        self.inactiveSel = inactiveSel;
        self.trackLayer = trackLayer;
        self.orientation = o;
        self.isActive = [[NSApplication sharedApplication] isActive];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stateDidChange:)
                                                     name:NSWindowDidBecomeKeyNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stateDidChange:)
                                                     name:NSWindowDidResignKeyNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stateDidChange:)
                                                     name:NSWindowDidBecomeMainNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stateDidChange:)
                                                     name:NSWindowDidResignMainNotification
                                                   object:nil];
    }
    return self;
}

- (void)stateDidChange:(NSNotification *)notification{
    if (self.beingForcedToInactive)
        return;
    
    static CGImageRef (*resourceSelFunc)(id, SEL, SOScrollOrientation);
    
    SOScrollOrientation o = self.orientation;
    
    SOScrollerResources * instance = [SOScrollerResources sharedInstance];
    
    if ((notification.name == NSWindowDidBecomeKeyNotification || notification.name == NSWindowDidBecomeMainNotification)
            && !self.isActive){
        self.isActive = YES;
        Method m = class_getInstanceMethod(SOScrollerResources.class, self.activeSel);
        resourceSelFunc = (void *)method_getImplementation(m);
        
        self.boundLayer.contents = (__bridge id)resourceSelFunc(instance, self.activeSel, o);
    } else if ((notification.name == NSWindowDidResignKeyNotification || notification.name == NSWindowDidResignMainNotification)
            && self.isActive){
        self.isActive = NO;
        Method m = class_getInstanceMethod(SOScrollerResources.class, self.inactiveSel);
        resourceSelFunc = (void *)method_getImplementation(m);
        
        self.boundLayer.contents = (__bridge id)resourceSelFunc(instance, self.inactiveSel, o);
    }
}

- (void)forceActiveStateTo:(BOOL)active{
    if ((active && self.isActive) || (!active && !self.isActive))
        return;
    
    static CGImageRef (*resourceSelFunc)(id, SEL, SOScrollOrientation);
    
    SOScrollOrientation o = self.orientation;
    
    SOScrollerResources * instance = [SOScrollerResources sharedInstance];
    
    self.isActive = active;
    self.beingForcedToInactive = YES;
    
    if (self.isActive){
        Method m = class_getInstanceMethod(SOScrollerResources.class, self.activeSel);
        resourceSelFunc = (void *)method_getImplementation(m);
        
        self.boundLayer.contents = (__bridge id)resourceSelFunc(instance, self.activeSel, o);
    } else if (!self.isActive){
        Method m = class_getInstanceMethod(SOScrollerResources.class, self.inactiveSel);
        resourceSelFunc = (void *)method_getImplementation(m);
        
        self.boundLayer.contents = (__bridge id)resourceSelFunc(instance, self.inactiveSel, o);
    }
}
@end
