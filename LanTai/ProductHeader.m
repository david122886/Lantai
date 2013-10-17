//
//  ProductHeader.m
//  LanTaiOrder
//
//  Created by Ruby on 13-3-4.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import "ProductHeader.h"

@implementation ProductHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect frame = CGRectMake(100, 2, 100, 36);
        UILabel *lblName = [[UILabel alloc] initWithFrame:frame];
        lblName.text = @"服务项目";
        lblName.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lblName];
        frame.origin.x = 475;
        UILabel *lblPrice = [[UILabel alloc] initWithFrame:frame];
        lblPrice.text = @"单价（元）";
        lblPrice.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lblPrice];
        self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
