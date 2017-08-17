//
// VESpinner.h
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

#import <UIKit/UIKit.h>
enum {
    VESpinnerAnimationTypeRotate = 1,
    VESpinnerAnimationTypeInsideOutside = 2
};
typedef NSUInteger VESpinnerAnimationType;

@interface VESpinner : UIView
/** Defines single dot size. Default value is 8.0 */
@property (nonatomic, assign) CGFloat dotSize;
/** Defines the number of dots to spin. Default value is 10.0 */
@property (nonatomic, assign) CGFloat dotCount;
/** Defines the type of dots animation. Default value is VESpinnerAnimationTypeRotate */
@property (nonatomic, assign) VESpinnerAnimationType animationType;
/** Defines the color of dots. Default value is empty array (dot color is set by backgroundColor property ) */
@property (nonatomic, strong) NSArray *colorsArray;
/** Defines the duration of animation cycle (default value 1 sec)*/
@property (nonatomic, assign) CGFloat animationDuration;
/** Defines if user can interact with views in background, (default value: NO)*/
@property (nonatomic, assign) BOOL blockBackgroundUserInteraction;
/** Defines overlay color, (default value:clearColor)*/
@property (nonatomic, strong) UIColor *overlayColor;




/** 
 Start animating
 */
- (void)startAnimating;

/** 
 Stop animating
 */
- (void)stopAnimating;

/**
 Is Animating
 */
- (BOOL) isAnimating;


@end
