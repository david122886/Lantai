//
//  UITextView+Border.m
//  LanTaiOrder
//
//  Created by Ruby on 13-3-17.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import "UITextView+Border.h"
#import <QuartzCore/QuartzCore.h>

@implementation UITextView_Border

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [self.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [self.layer setBorderWidth:1.0];
    [self.layer setCornerRadius:8.0f];
    [self.layer setMasksToBounds:YES];
}


@end
