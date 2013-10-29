//
//  DRScrollView.m
//  LanTai
//
//  Created by david on 13-10-28.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "DRScrollView.h"
@interface DRScrollView ()
@property (nonatomic,strong) NSTimer *scrollTimer;
@property (nonatomic,assign) int step;
@end
@implementation DRScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[CarPosionView class]]) {
            CarPosionView *posionView = (CarPosionView*)subView;
            CGRect superRect = [posionView convertRect:posionView.carView.frame toView:self];
            if (CGRectContainsPoint(superRect, point) && !posionView.isEmpty) {
                return [self superview];
            }
        }
    }
    return self;
}

-(void)startScrollContentWithStep:(int)step{
    self.step = step;
    self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(scrollMiddleScrollview) userInfo:nil repeats:YES];
}

-(void)stopScroll{
    [self.scrollTimer invalidate];
    self.scrollTimer = nil;
}

-(void)scrollMiddleScrollview{
    if (self.step > 0 && self.contentOffset.x < self.contentSize.width - CGRectGetWidth(self.frame)) {
        self.contentOffset = (CGPoint){self.contentOffset.x+self.step,self.contentOffset.y};
    }else
        if (self.step < 0 && self.contentOffset.x > 0) {
            self.contentOffset = (CGPoint){self.contentOffset.x+self.step,self.contentOffset.y};
        }else{
            [self stopScroll];
        }
}
@end
