//
// VESpinner.m
// VESpinner
// The MIT License (MIT)
// Created by Tomasz Dubik on 1/9/16.
// Copyright (c) 2016 Tomasz Dubik Consulting
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "VESpinner.h"

@interface VESpinner()

@property (nonatomic, strong) CAShapeLayer *containerLayer;
@property (nonatomic, strong) NSMutableArray *starList;
@property (nonatomic, strong) CAKeyframeAnimation *animation;
@property (nonatomic, strong) UIColor *spinnerColor;
@property (nonatomic, strong) UIControl *overlayView;
@property (nonatomic, strong) NSDictionary *persistedAnimations;

@end

@implementation VESpinner

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        _containerLayer = [[CAShapeLayer alloc] init];
        [_containerLayer setBounds:frame];
        _animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
        [_containerLayer setPosition:self.center];
        [_containerLayer setAnchorPoint:CGPointMake(0.5, 0.5)];
        [_animation setRepeatCount:CGFLOAT_MAX];
        [_animation setCalculationMode:@"discrete"];
        [self setHidden:YES];
        [[self layer] addSublayer:_containerLayer];
        
        [self registerForAppStateNotifications];
    }
    return self;
}

- (void)dealloc {
    [self unregisterFromAppStateNotifications];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(![[_animation values] count]){
        [self prepare];
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self updateViewHierarchy];
    }];
}

- (void)prepare
{
    BOOL clockwise = NO;
    BOOL roundedCornes = YES;
    if(_dotSize == 0){
        _dotSize = 8.0;
    }
    CGSize starSize = CGSizeMake(_dotSize,_dotSize);
    UIColor *foregrdound = self.spinnerColor;
    if(!foregrdound){
        foregrdound = [UIColor grayColor];
    }
    if([_animation values]){
        [_animation setValues:[NSArray array]];
    }
    if(_dotCount == 0){
        _dotCount = 10.0;
    }
    
    if(_animationType == 0){
        _animationType = VESpinnerAnimationTypeRotate;
    }
    
    if(_animationDuration == 0){
        _animationDuration = 1.0;
    }
    
    [_animation setDuration:_animationDuration];
    
    CGFloat distance = self.frame.size.width * 0.5 - starSize.width;
    CGRect frame = self.frame;
    NSMutableArray *starList = [NSMutableArray new];
    NSMutableArray *animationValues = [NSMutableArray array];
    int animationFrameMultiplier = 1.0;
    int animationFrameMultiplierIndex = 0;
    UIView *starShape = nil;
    for (CGFloat  i = 0.0; i < 360; i = i + 360 / ( animationFrameMultiplier * _dotCount))
    {

        CGFloat iRadian = i * M_PI / 180.0;
        if (clockwise){
            iRadian = -iRadian;
        }
        
        BOOL isCreateFrame = fmod(animationFrameMultiplierIndex, animationFrameMultiplier) == 0;
        if (isCreateFrame) {
            starShape = nil;
        }
        animationFrameMultiplierIndex++;
        if (_animationType == VESpinnerAnimationTypeRotate) {
            [animationValues addObject:@(iRadian)];
        }
        if (starShape == nil){
            starShape = [UIView new];
            starShape.layer.cornerRadius = (roundedCornes) ? starSize.width * 0.5 : 0;
            CGPoint centerLocation = CGPointMake(frame.size.width * 0.5 - starSize.width * 0.5, frame.size.width * 0.5 - starSize.height  *0.5);
            starShape.frame = CGRectMake(centerLocation.x, centerLocation.y, starSize.width, starSize.height);
            starShape.layer.backgroundColor = [foregrdound CGColor];
            [starShape setBackgroundColor:foregrdound];
            if(_colorsArray) {
                int index = fmod(floor((i * _dotCount/360.0)), [_colorsArray count]);
                UIColor *color = _colorsArray[index];
                starShape.layer.backgroundColor = [color CGColor];
            }
        }
        
        starShape.layer.anchorPoint = CGPointMake(0.5,0.0);
        
        if (_animationType == VESpinnerAnimationTypeRotate) {
            CATransform3D rotation = CATransform3DMakeTranslation(0, 0, 0.0);
            rotation = CATransform3DRotate(rotation, -iRadian, 0.0, 0.0, 1.0);
            rotation = CATransform3DTranslate(rotation, 0, distance, 0.0);
            starShape.layer.transform = rotation;
            starShape.layer.opacity = (360 - i) / 360;
        } else if (_animationType == VESpinnerAnimationTypeInsideOutside) {
            CATransform3D rotation = CATransform3DMakeTranslation(0, 0, 0.0);
            rotation = CATransform3DRotate(rotation, -iRadian, 0.0, 0.0, 1.0);
            CGFloat scale = 1.00001;
            CGFloat newDistance = scale * distance;
            rotation = CATransform3DTranslate(rotation, 0, newDistance, 0.0);
            rotation = CATransform3DScale(rotation, scale, scale, scale);
            starShape.layer.transform = rotation;
        }
        starShape.tag = i;
        [_containerLayer addSublayer:starShape.layer];
        [starList addObject:starShape];
    }
    [_animation setValues:animationValues];
    
    if (_animationType == VESpinnerAnimationTypeInsideOutside) {
        
        CGFloat i = 0;
        [[self layer] setHidden:YES];
        
        for (UIView *star in starList) {
            CGFloat delay = i/_dotCount * _animationDuration;
            i = i + 1;
            [star.layer removeAllAnimations];
            [UIView animateWithDuration:.5 * _animationDuration delay:delay options: UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
                CGFloat iRadian = star.tag * M_PI / 180.0;
                CATransform3D rotation = CATransform3DMakeTranslation(0, 0, 0.0);
                rotation = CATransform3DRotate(rotation, -iRadian, 0.0, 0.0, 1.0);
                CGFloat scale = 2;
                CGFloat newDistance = distance + scale * 0.25;
                rotation = CATransform3DScale(rotation, scale, scale, scale);
                rotation = CATransform3DTranslate(rotation, 0, newDistance, 0.0);
                
                star.layer.transform = rotation;
                
            } completion:nil];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_animationDuration * 0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[self layer] setHidden:NO];
        });
    }

}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if(_spinnerColor != backgroundColor){
        _spinnerColor = backgroundColor;
    }
}

- (void)startAnimating
{
    if(![[_animation values] count] && ![self isAnimating]){
        [self prepare];
    }
    [self setHidden:NO];
    [_containerLayer addAnimation:_animation forKey:@"rotation"];
//    [_containerLayer VE_setCurrentAnimationsPersistent];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self updateViewHierarchy];
    }];
}

- (void)stopAnimating
{
    [_containerLayer removeAllAnimations];
    for (UIView *dot in _starList) {
        [dot.layer removeAllAnimations];
    }
    [self setHidden:YES];
    [self.overlayView removeFromSuperview];
}

- (BOOL) isAnimating
{
    return [[self containerLayer] animationKeys] != nil;
}

- (UIControl*)overlayView {
    if(!_overlayView) {
        _overlayView = [[UIControl alloc] init];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [UIColor clearColor];
        _overlayView.userInteractionEnabled = _blockBackgroundUserInteraction;
    }
    // Update frame
    CGRect windowBounds = [[[UIApplication sharedApplication] delegate] window].bounds;
    _overlayView.frame = windowBounds;
    
    return _overlayView;
}


- (void)updateViewHierarchy {
    if(!self.overlayView.superview) {
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows) {
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= UIWindowLevelNormal);
            
            if(windowOnMainScreen && windowIsVisible && windowLevelSupported) {
                [window addSubview:self.overlayView];
                break;
            }
        }
    } else {
        [self.overlayView.superview bringSubviewToFront:self.overlayView];
    }
    
    
    if(!self.superview){
        [self.overlayView addSubview:self];
    }
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    [self.containerLayer setHidden:hidden];
    self.overlayView.hidden = hidden;
}

- (void)setBlockBackgroundUserInteraction:(BOOL)blockBackgroundUserInteraction
{
    _blockBackgroundUserInteraction = blockBackgroundUserInteraction;
    self.overlayView.userInteractionEnabled = blockBackgroundUserInteraction;
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


- (void)persistLayerAnimationsAndPause {
    CALayer *layer = _containerLayer;
    if (!layer) {
        return;
    }
    NSMutableDictionary *animations = [NSMutableDictionary new];
    for (NSString *key in _containerLayer.animationKeys) {
        CAAnimation *animation = [layer animationForKey:key];
        if (animation) {
            animations[key] = animation;
        }
    }
    if (animations.count > 0) {
        self.persistedAnimations = animations;
        [self VE_pauseLayer];
    }
}

- (void)restoreLayerAnimationsAndResume {
    CALayer *layer = _containerLayer;
    if (!layer) {
        return;
    }
    [self.persistedAnimations enumerateKeysAndObjectsUsingBlock:^(NSString *key, CAAnimation *animation, BOOL *stop) {
        [layer addAnimation:animation forKey:key];
    }];
    if (self.persistedAnimations.count > 0) {
        [self VE_resumeLayer];
    }
    self.persistedAnimations = nil;
}

- (void)VE_pauseLayer {
    CFTimeInterval pausedTime = [_containerLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    _containerLayer.speed = 0.0;
    _containerLayer.timeOffset = pausedTime;
}

- (void)VE_resumeLayer {
    CFTimeInterval pausedTime = [_containerLayer timeOffset];
    _containerLayer.speed = 1.0;
    _containerLayer.timeOffset = 0.0;
    _containerLayer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [_containerLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    _containerLayer.beginTime = timeSincePause;
}

@end
