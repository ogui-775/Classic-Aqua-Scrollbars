//Created by Salty on 3/21/26.

#import "SOInteractiveStateControl.h"
#import "SOTrackLayer.h"
#import "SOScrollerResources.h"

@interface SOScrollButton : NSControl
- (instancetype)initWithFrame:(NSRect)frameRect track:(SOTrackLayer *)track orientation:(SOScrollOrientation)o isUpArrow:(BOOL)up;
- (void)changeOrientationTo:(SOScrollOrientation)orientation;
@property (strong) SOInteractiveStateControl * iStateController;
@property (assign) BOOL isUpArrow;
@end
