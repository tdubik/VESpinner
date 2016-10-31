//
//  CALayer+VEUtils.h
//


#import <QuartzCore/QuartzCore.h>


@interface CALayer (VEUtils)

/**
 Animation keys for animations that should be persisted.
 Inspect the `animationKeys` array to find valid keys for your layer.
 
 `CAAnimation` instances associated with the provided keys will be copied and held onto,
 when the applications enters background mode and restored when exiting background mode.
 
 Set to `nil`to disable persistance.
 */
@property (nonatomic, strong) NSArray *VE_persistentAnimationKeys;

/** Set all current `animationKeys` as persistent. */
- (void)VE_setCurrentAnimationsPersistent;

@end
