//Created by Salty on 3/15/26.

#import "SOClassicAquaScrollbar.h"

static NSString * const kCAContentsScalingRepeat = @"repeat";
static NSString * const kCAContentsScalingStretch = @"stretch";

static const void *kNeedsLayoutKey = &kNeedsLayoutKey;
static const void *iAmAWebKit = &iAmAWebKit;
static const void *downArrow = &downArrow;
static const void *upArrow = &upArrow;
static const void *downArrowsScroller = &downArrowsScroller;
static const void *upArrowsScroller = &upArrowsScroller;

static const void *kSOTrackLayer = &kSOTrackLayer;
static const void *kSOTiledLayer = &kSOTiledLayer;
static const void *kSOOverlayLayer = &kSOOverlayLayer;

static inline BOOL isXPCService(void){
    return [[[NSBundle mainBundle] bundlePath] containsString:@"xpc"];
}

static inline BOOL isDockProcess(void){
    return [[[NSProcessInfo processInfo] processName] containsString:@"Dock"];
}

static inline BOOL isOverlayMode(void){
    return ![[[NSUserDefaults standardUserDefaults] stringForKey:@"AppleShowScrollBars"] isEqualToString:@"Always"];
}

@implementation SOClassicAquaScrollbar

#pragma mark - Loader

+ (void)load{
    if (!isXPCService() && !isDockProcess()){
        [SOClassicAquaScrollbar replaceLegacyScroller];
        [SOClassicAquaScrollbar hookSetFrameSize];
        [SOClassicAquaScrollbar hookSetDoubleValue];
        [SOClassicAquaScrollbar hookSetKnobProportion];
        [SOClassicAquaScrollbar preventWKFromOverridingScrollbarColor];
        [SOClassicAquaScrollbar insetKnobEnds];
    }
}

#pragma mark - Tweak

+ (void)replaceLegacyScroller{
    static void (*orig_updateLayer)(id, SEL);
    
    Class cls = NSClassFromString(@"NSScrollerImp");
    SEL sel = NSSelectorFromString(@"_updateLayerGeometry");
    Method m = class_getInstanceMethod(cls, sel);
    if (!m) return;
    
    orig_updateLayer = (void *)method_getImplementation(m);
    
    IMP newImp = imp_implementationWithBlock(^void(id selfObj){
        orig_updateLayer(selfObj, sel);
        NSRegularLegacyScrollerImp * imp = selfObj;
        
        if (!imp.layer)
            return;
        
        SOScrollOrientation o = imp.layer.frame.size.height > imp.layer.frame.size.width
            ? SOScrollOrientationVertical : SOScrollOrientationHorizontal;
        
        if (imp.knobLayer){
            
            SOTiledLayer *tiledLayer = objc_getAssociatedObject(imp, kSOTiledLayer);
            SOScrollerOverlay *knobOverlayLayer = objc_getAssociatedObject(imp, kSOOverlayLayer);
            SOTrackLayer *newTrackLayer = objc_getAssociatedObject(imp, kSOTrackLayer);
            
            NSScroller *scroller = [imp valueForKey:@"_scroller"];
            
            if (!newTrackLayer){
                newTrackLayer = [SOTrackLayer layer];
                newTrackLayer.name = @"nt";
                [newTrackLayer changeOrientationTo:o];
                [imp.layer insertSublayer:newTrackLayer atIndex:0];
                [newTrackLayer setFrame:[SOClassicAquaScrollbar TrackFrame:o imp:imp]];
                [newTrackLayer setContents:(__bridge id)[[SOScrollerResources sharedInstance] trackImageForOrientation:o]];
                if (isOverlayMode()){
                    newTrackLayer.opacity = 0;
                    [imp.trackLayer setHidden:YES];
                }
                objc_setAssociatedObject(imp,
                                         kSOTrackLayer,
                                         newTrackLayer,
                                         OBJC_ASSOCIATION_RETAIN);
            }
            
            if (!knobOverlayLayer){
                knobOverlayLayer = [[SOScrollerOverlay alloc] initWithLayer:imp.knobLayer orientation:o];
                knobOverlayLayer.name = @"ko";
                [knobOverlayLayer setHidden:imp.knobLayer.isHidden];
                SOReplicantMask *replicant = [[SOReplicantMask alloc] initWithParent:(SOScrollerOverlay *)knobOverlayLayer];
                [knobOverlayLayer setReplicantMask:replicant];
                [knobOverlayLayer setTrackLayer:newTrackLayer];
                [imp.layer addSublayer:knobOverlayLayer];
                objc_setAssociatedObject(imp,
                                         kSOOverlayLayer,
                                         knobOverlayLayer,
                                         OBJC_ASSOCIATION_RETAIN);
            }
            
            if (!tiledLayer){
                tiledLayer = [[SOTiledLayer alloc] initWithOrientation:o];
                tiledLayer.name = @"t";
                
                [imp.layer insertSublayer:tiledLayer below:knobOverlayLayer];
                [imp setKnobAlpha:0];
                [imp.trackLayer setHidden:YES];
                [tiledLayer setMask:[knobOverlayLayer replicantMask]];
                objc_setAssociatedObject(imp,
                                         kSOTiledLayer,
                                         tiledLayer,
                                         OBJC_ASSOCIATION_RETAIN);
            }
            
            if (tiledLayer && knobOverlayLayer){
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                if (o != [(SOScrollerOverlay *)knobOverlayLayer orientation]){
                    [(SOScrollerOverlay *)knobOverlayLayer changeOrientationTo:o];
                    [imp.trackLayer setHidden:YES];
                }
                
                if (!objc_getAssociatedObject(imp, downArrow) && !isOverlayMode()){
                    SOScrollButton *downArrowO = [[SOScrollButton alloc] initWithFrame:CGRectMake(0, newTrackLayer.bounds.size.height - 38, newTrackLayer.bounds.size.width - 2, 38)
                                                                                  track:(SOTrackLayer *)newTrackLayer
                                                                            orientation:o
                                                                              isUpArrow:NO];
                    
                    objc_setAssociatedObject(imp, downArrow, downArrowO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    [scroller addSubview:downArrowO positioned:NSWindowAbove relativeTo:scroller];
                    [downArrowO.iStateController setWeakTarg:imp];
                    [downArrowO.iStateController setMod:-1];
                }
                
                if (!objc_getAssociatedObject(imp, upArrow) && !isOverlayMode()){
                    SOScrollButton *upArrowO = [[SOScrollButton alloc] initWithFrame:CGRectMake(0, 0, newTrackLayer.bounds.size.width - 2, 38)
                                                                                  track:(SOTrackLayer *)newTrackLayer
                                                                            orientation:o
                                                                              isUpArrow:YES];
                    
                    objc_setAssociatedObject(imp, upArrow, upArrowO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    [scroller addSubview:upArrowO positioned:NSWindowAbove relativeTo:scroller];
                    [upArrowO.iStateController setWeakTarg:imp];
                    [upArrowO.iStateController setMod:1];
                }

                //Safari handliog (imp is destroyed -> reparented to WebKit)
                if ([[imp.layer className] containsString:@"WK"] &&
                        (![[knobOverlayLayer knobParentLayer] isEqualTo:imp.knobLayer] ||
                            !objc_getAssociatedObject(imp, iAmAWebKit))){
                    
                    objc_setAssociatedObject(imp, iAmAWebKit, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    
                    [imp setKnobAlpha:0];
                    [imp.knobLayer setNeedsDisplay];
                    [imp.layer insertSublayer:tiledLayer
                                        above:imp.trackLayer];
                    [imp.layer addSublayer:knobOverlayLayer];
                    [imp.trackLayer setHidden:YES];
                    [knobOverlayLayer setKnobParentLayer:imp.knobLayer];
                    [tiledLayer setMask:[knobOverlayLayer replicantMask]];
                    
                    objc_setAssociatedObject(imp,
                                             kSOTiledLayer,
                                             tiledLayer,
                                             OBJC_ASSOCIATION_RETAIN);
                    objc_setAssociatedObject(imp,
                                             kSOOverlayLayer,
                                             knobOverlayLayer,
                                             OBJC_ASSOCIATION_RETAIN);
                    
                    SOScrollButton *downArrowObj = objc_getAssociatedObject(imp, downArrow);
                    if (downArrowObj)
                        [scroller addSubview:downArrowObj positioned:NSWindowAbove relativeTo:scroller];
                    
                    SOScrollButton *upArrowObj = objc_getAssociatedObject(imp, upArrow);
                    if (upArrowObj)
                        [scroller addSubview:upArrowObj positioned:NSWindowAbove relativeTo:scroller];
                }
                
                //End Safari handling
                
                [CATransaction commit];
            }
        }
    });
    
    method_setImplementation(m, newImp);
}

+ (void)hookSetFrameSize{
    static void (*orig_setFrameSize)(id, SEL, CGSize);
    
    Class cls = NSClassFromString(@"NSScrollerImp");
    SEL sel = @selector(setBoundsSize:);
    Method m = class_getInstanceMethod(cls, sel);
    if (!m) return;
    
    orig_setFrameSize = (void *)method_getImplementation(m);
    
    IMP newImp = imp_implementationWithBlock(^void(id selfObj, CGSize size){
        orig_setFrameSize(selfObj, sel, size);
        NSRegularLegacyScrollerImp * imp = selfObj;
        
        if (!imp.layer)
            return;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if ([SOClassicAquaScrollbar iAmAWebKit:imp])
            [SOClassicAquaScrollbar scheduleInteriorUpdateForImp:imp];
        else
            [SOClassicAquaScrollbar DoInteriorWithImp:imp];
        [CATransaction commit];
        
        return;
    });
    
    method_setImplementation(m, newImp);
}


+ (void)hookSetDoubleValue{
    static void (*orig_setDoubleValue)(id, SEL, CGFloat);
    
    Class cls = NSClassFromString(@"NSScrollerImp");
    SEL sel = @selector(setDoubleValue:);
    Method m = class_getInstanceMethod(cls, sel);
    if (!m) return;
    
    orig_setDoubleValue = (void *)method_getImplementation(m);
    
    IMP newImp = imp_implementationWithBlock(^void(id selfObj, CGFloat value){
        orig_setDoubleValue(selfObj, sel, value);
        NSRegularLegacyScrollerImp * imp = selfObj;
        
        if (!imp.layer)
            return;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if ([SOClassicAquaScrollbar iAmAWebKit:imp])
            [SOClassicAquaScrollbar scheduleInteriorUpdateForImp:imp];
        else
            [SOClassicAquaScrollbar DoInteriorWithImp:imp];
        [CATransaction commit];

        return;
    });
    
    method_setImplementation(m, newImp);
}

+ (void)hookSetKnobProportion{
    static void (*orig_setKnobProportion)(id, SEL, CGFloat);
    
    Class cls = NSClassFromString(@"NSScrollerImp");
    SEL sel = @selector(setKnobProportion:);
    Method m = class_getInstanceMethod(cls, sel);
    if (!m) return;
    
    orig_setKnobProportion = (void *)method_getImplementation(m);
    
    IMP newImp = imp_implementationWithBlock(^void(id selfObj, CGFloat value){
        orig_setKnobProportion(selfObj, sel, value);
        NSRegularLegacyScrollerImp * imp = selfObj;
        
        if (!imp.layer)
            return;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if ([SOClassicAquaScrollbar iAmAWebKit:imp])
            [SOClassicAquaScrollbar scheduleInteriorUpdateForImp:imp];
        else
            [SOClassicAquaScrollbar DoInteriorWithImp:imp];
        [CATransaction commit];

        return;
    });
    
    method_setImplementation(m, newImp);
}
 
//Safari handling, prevent browser from overriding scrollbar alpha (mask visibility) and stop crazy amount of layout calls to the classes
+ (void)preventWKFromOverridingScrollbarColor{
    static void (*orig_setKnobAlpha)(id, SEL, CGFloat);
    
    Class cls = NSClassFromString(@"NSScrollerImp");
    SEL sel = @selector(setKnobAlpha:);
    Method m = class_getInstanceMethod(cls, sel);
    if (!m) return;
    
    orig_setKnobAlpha = (void *)method_getImplementation(m);
    
    IMP newImp = imp_implementationWithBlock(^void(id selfObj, CGFloat alpha){
        orig_setKnobAlpha(selfObj, sel, 0);
    });
    
    method_setImplementation(m, newImp);
}
//This was somewhat motivated by Safari but also the fact that any app really could call these a crazy amount of time which slows down
//when no guard is in place
+ (void)scheduleInteriorUpdateForImp:(NSRegularLegacyScrollerImp *)imp {
    if (!imp.layer)
        return;

    NSNumber *pending = objc_getAssociatedObject(imp, kNeedsLayoutKey);
    
    if (pending.boolValue)
        return;
    
    if (!pending.boolValue) {
        objc_setAssociatedObject(imp, kNeedsLayoutKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
        
        [CATransaction setCompletionBlock:^{
            objc_setAssociatedObject(imp, kNeedsLayoutKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [SOClassicAquaScrollbar DoInteriorWithImp:imp];
        }];
    }
}
//End Safari handling

+ (void)insetKnobEnds{
    static CGFloat (*orig_knobEndInset)(id, SEL);
    
    Class cls = NSClassFromString(@"NSScrollerImp");
    SEL sel = NSSelectorFromString(@"trackEndInset");
    Method m = class_getInstanceMethod(cls, sel);
    if (!m) return;
    
    orig_knobEndInset = (void *)method_getImplementation(m);
    
    IMP newImp = imp_implementationWithBlock(^CGFloat(id selfObj){
        return 20;
    });
    
    method_setImplementation(m, newImp);
}

+(void)DoInteriorWithImp:(NSRegularLegacyScrollerImp *)imp{
    SOScrollOrientation o = imp.layer.frame.size.height > imp.layer.frame.size.width
    ? SOScrollOrientationVertical : SOScrollOrientationHorizontal;
    
    SOTiledLayer *tiledLayer = objc_getAssociatedObject(imp, kSOTiledLayer);
    SOScrollerOverlay *knobOverlayLayer = objc_getAssociatedObject(imp, kSOOverlayLayer);
    SOTrackLayer *newTrackLayer = objc_getAssociatedObject(imp, kSOTrackLayer);
    SOScrollButton *upArrowB = objc_getAssociatedObject(imp, upArrow);
    SOScrollButton *downArrowB = objc_getAssociatedObject(imp, downArrow);
    
    if (knobOverlayLayer){
        if (   o != [(SOScrollerOverlay *)knobOverlayLayer orientation]
            || o != [(SOTrackLayer *)newTrackLayer orientation]
            || o != [(SOTiledLayer *)tiledLayer orientation]
            || o != upArrowB.iStateController.orientation
            || o != downArrowB.iStateController.orientation){
            [(SOScrollerOverlay *)knobOverlayLayer changeOrientationTo:o];
            [(SOTrackLayer *)newTrackLayer changeOrientationTo:o];
            [(SOTiledLayer *)tiledLayer changeOrientationTo:o];
            [upArrowB changeOrientationTo:o];
            [downArrowB changeOrientationTo:o];
        }
        
        CGRect trackFrame = [SOClassicAquaScrollbar TrackFrame:o imp:imp];

        [newTrackLayer setFrame:trackFrame];
        if (o == SOScrollOrientationVertical){
            [knobOverlayLayer setFrame:CGRectMake(trackFrame.origin.x - 2,
                                                  imp.knobLayer.frame.origin.y,
                                                  30,
                                                  imp.knobLayer.frame.size.height)];
            [upArrowB setFrame:CGRectMake(0, 0, trackFrame.size.width - 2, 38)];
            [downArrowB setFrame:CGRectMake(0, trackFrame.size.height - 38, trackFrame.size.width - 2, 38)];
            [tiledLayer setFrame:CGRectMake(0,
                                            [SOClassicAquaScrollbar iAmAWebKit:imp] ? -2 : 0,
                                            30,
                                            trackFrame.size.height)];
        } else {
            [knobOverlayLayer setFrame:CGRectMake(imp.knobLayer.frame.origin.x,
                                                  trackFrame.origin.y - 2,
                                                  imp.knobLayer.frame.size.width,
                                                  30)];
            [upArrowB setFrame:CGRectMake(trackFrame.size.width - 38, 0, 38, trackFrame.size.height - 2)];
            [downArrowB setFrame:CGRectMake(0, 0, 38, trackFrame.size.height - 2)];
            [tiledLayer setFrame:CGRectMake(0,
                                            [SOClassicAquaScrollbar iAmAWebKit:imp] ? -2 : 0,
                                            trackFrame.size.width,
                                            30)];
        }
        
        BOOL isHiddenKnobby = imp.knobLayer.isHidden;
        [knobOverlayLayer setHidden:isHiddenKnobby];
    }
}

+ (CGRect)TrackFrame:(SOScrollOrientation)orientation imp:(NSRegularLegacyScrollerImp *)imp {
    if (orientation == SOScrollOrientationVertical){
        return CGRectMake(0,
                          imp.trackLayer.frame.origin.y - 20,
                          19,
                          imp.trackLayer.bounds.size.height + 40);
    }
    
     return CGRectMake(imp.trackLayer.frame.origin.x - 20,
                             0,
                             imp.trackLayer.bounds.size.width + 40,
                             19);
}
    
+ (BOOL)iAmAWebKit:(NSRegularLegacyScrollerImp *)imp{
    return [(NSNumber *)objc_getAssociatedObject(imp, iAmAWebKit) boolValue];
}
@end
