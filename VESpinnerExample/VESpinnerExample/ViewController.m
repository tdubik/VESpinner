//
// ViewController.m
// VESpinnerExample
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

#import "ViewController.h"
#import "VESpinner.h"

@interface ViewController ()
@property (nonatomic, strong) VESpinner *spinner;
@property (nonatomic, strong) UIButton *backgroundButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGFloat spinnerSize = 70.0;
    _spinner = [[VESpinner alloc] initWithFrame:CGRectMake(0.0, 0.0, spinnerSize,spinnerSize)];
    [_spinner setBlockBackgroundUserInteraction:YES];
    [self.view addSubview:_spinner];
    [_spinner setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    [_spinner setAnimationDuration:1.5];
    [_spinner setAnimationType:VESpinnerAnimationTypeRotate];
    [_spinner setDotCount:18];
    [_spinner setBackgroundColor:[UIColor purpleColor]];
    [_spinner setDotSize:9.0];
    [_spinner startAnimating];
    [_spinner setHidden:YES];
    [_spinner setHidden:NO];



    _backgroundButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_backgroundButton setFrame:CGRectMake(20, 20, 220, 20)];
    [self.view addSubview:_backgroundButton];
    
    [_backgroundButton setTitle:@"background button" forState:UIControlStateNormal];
    [_backgroundButton addTarget:self action:@selector(backgroundButtonAction) forControlEvents:UIControlEventTouchUpInside];

}

- (void)backgroundButtonAction
{
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Title"
                                                       message:@"This is the message."
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    
    [theAlert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
