//
//  CALayer+VEUtils.m
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "CALayer+VEUtils.h"


@interface VEPersistentAnimationContainer : NSObject
@property (nonatomic, weak) CALayer *layer;
@property (nonatomic, copy) NSArray *persistentAnimationKeys;
@property (nonatomic, copy) NSDictionary *persistedAnimations;
- (id)initWithLayer:(CALayer *)layer;
@end


@interface CALayer (VEAnimationPersistencePrivate)
@property (nonatomic, strong) VEPersistentAnimationContainer *VE_animationContainer;
@end


@implementation CALayer (VEAnimationPersistence)

#pragma mark - Public

- (NSArray *)VE_persistentAnimationKeys {
    return self.VE_animationContainer.persistentAnimationKeys;
}

- (void)setVE_persistentAnimationKeys:(NSArray *)persistentAnimationKeys {
    VEPersistentAnimationContainer *container = [self VE_animationContainer];
    if (!container) {
        container = [[VEPersistentAnimationContainer alloc] initWithLayer:self];
        [self VE_setAnimationContainer:container];
    }
    container.persistentAnimationKeys = persistentAnimationKeys;
}

- (void)VE_setCurrentAnimationsPersistent {
    self.VE_persistentAnimationKeys = [self animationKeys];
}

#pragma mark - Associated objects

- (void)VE_setAnimationContainer:(VEPersistentAnimationContainer *)animationContainer {
    objc_setAssociatedObject(self, @selector(VE_animationContainer), animationContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VEPersistentAnimationContainer *)VE_animationContainer {
    return objc_getAssociatedObject(self, @selector(VE_animationContainer));
}

#pragma mark - Pause and resume

// TechNote QA1673 - How to pause the animation of a layer tree
// @see https://developer.apple.com/library/ios/qa/qa1673/_index.html

- (void)VE_pauseLayer {
    CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
    self.speed = 0.0;
    self.timeOffset = pausedTime;
}

- (void)VE_resumeLayer {
    CFTimeInterval pausedTime = [self timeOffset];
    self.speed = 1.0;
    self.timeOffset = 0.0;
    self.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.beginTime = timeSincePause;
}

@end

@implementation VEPersistentAnimationContainer

#pragma mark - Lifecycle

- (id)initWithLayer:(CALayer *)layer {
    self = [super init];
    if (self) {
        _layer = layer;
    }
    return self;
}

- (void)dealloc {
    [self unregisterFromAppStateNotifications];
}

#pragma mark - Keys

- (void)setPersistentAnimationKeys:(NSArray *)persistentAnimationKeys {
    if (persistentAnimationKeys != _persistentAnimationKeys) {
        if (!_persistentAnimationKeys) {
            [self registerForAppStateNotifications];
        } else if (!persistentAnimationKeys) {
            [self unregisterFromAppStateNotifications];
        }
        _persistentAnimationKeys = persistentAnimationKeys;
    }
}

#pragma mark - Persistence

- (void)persistLayerAnimationsAndPause {
    CALayer *layer = self.layer;
    if (!layer) {
        return;
    }
    NSMutableDictionary *animations = [NSMutableDictionary new];
    for (NSString *key in self.persistentAnimationKeys) {
        CAAnimation *animation = [layer animationForKey:key];
        if (animation) {
            animations[key] = animation;
        }
    }
    if (animations.count > 0) {
        self.persistedAnimations = animations;
        [layer VE_pauseLayer];
    }
}

- (void)restoreLayerAnimationsAndResume {
    CALayer *layer = self.layer;
    if (!layer) {
        return;
    }
    [self.persistedAnimations enumerateKeysAndObjectsUsingBlock:^(NSString *key, CAAnimation *animation, BOOL *stop) {
        [layer addAnimation:animation forKey:key];
    }];
    if (self.persistedAnimations.count > 0) {
        [layer VE_resumeLayer];
    }
    self.persistedAnimations = nil;
}

#pragma mark - Notifications

- (void)registerForAppStateNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)unregisterFromAppStateNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterBackground {
    [self persistLayerAnimationsAndPause];
}

- (void)applicationWillEnterForeground {
    [self restoreLayerAnimationsAndResume];
}

@end