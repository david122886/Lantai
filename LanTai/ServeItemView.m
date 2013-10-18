//
//  ServeItemView.m
//  LanTai
//
//  Created by david on 13-10-15.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "ServeItemView.h"
#import <QuartzCore/QuartzCore.h>
@implementation ServeItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.serveBt addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.serveBt.layer.cornerRadius = 10;
    self.serveBt.layer.shadowColor = [UIColor blackColor].CGColor;
    self.serveBt.layer.shadowOffset = (CGSize){2,5};
    self.serveBt.layer.shadowOpacity = 1;
    [self.serveBt setBackgroundImage:[UIImage imageNamed:@"posinTitlegraybg.png"] forState:UIControlStateHighlighted];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)buttonClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(serveItemView:didSelectedItemAtIndexPath:)]) {
        [self.delegate serveItemView:self didSelectedItemAtIndexPath:self.path];
    }
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    if (isSelected) {
        [self.serveBt setBackgroundImage:[UIImage imageNamed:@"serveRedbg.png"] forState:UIControlStateNormal];
    }else{
        [self.serveBt setBackgroundImage:[UIImage imageNamed:@"serveGraybg.png"] forState:UIControlStateNormal];
    }
}
@end
