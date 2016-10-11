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
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(![[_animation values] count]){
        [self prepare];
    }
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
        for (UIView *star in starList) {
            CGFloat delay = i/_dotCount * _animationDuration;
            i = i + 1;
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
    if(![[_animation values] count]){
        [self prepare];
    }
    [self setHidden:NO];
    [_containerLayer addAnimation:_animation forKey:@"rotation"];
}

- (void)stopAnimating
{
    [_containerLayer removeAllAnimations];
    [self setHidden:YES];
}

@end
