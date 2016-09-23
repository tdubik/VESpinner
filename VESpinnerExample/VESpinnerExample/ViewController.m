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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGFloat spinnerSize = 70.0;
    _spinner = [[VESpinner alloc] initWithFrame:CGRectMake(0.0, 0.0, spinnerSize,spinnerSize)];
    [self.view addSubview:_spinner];
    [_spinner setCenter:self.view.center];
    
    [_spinner setBackgroundColor:[UIColor purpleColor]];
    [_spinner setAnimationType:VESpinnerAnimationTypeInsideOutside];
    
    [_spinner setColorsArray:@[[UIColor colorWithRed:0.1804 green:0.1804 blue:0.1804 alpha:1.0], [UIColor colorWithRed:0.1647 green:0.6667 blue:0.7725 alpha:1.0] , [UIColor colorWithRed:0.8941 green:0.3765 blue:0.251 alpha:1.0] , [UIColor colorWithRed:0.9059 green:0.6353 blue:0.2275 alpha:1.0]]];
    
    [_spinner setDotCount:8];
    [_spinner setDotSize:16.0];
    [_spinner startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
