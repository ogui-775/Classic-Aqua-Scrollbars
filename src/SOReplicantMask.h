//Created by Salty on 3/18/26.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "SOScrollerOverlay.h"

@interface SOReplicantMask : CALayer
@property (weak) SOScrollerOverlay * parentOverlay;

- (instancetype)initWithParent:(SOScrollerOverlay *)parent;
@end
