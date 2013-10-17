//
//  MovieCoverView.m
//  LanTai
//
//  Created by david on 13-10-15.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "MovieCoverView.h"
@interface MovieCoverView()
@property (nonatomic,strong) UIWindow *win;
@property (nonatomic,strong) UIView *subView;
@end
@implementation MovieCoverView

- (id)initWithFrame:(CGRect)frame withMovingView:(UIView*)movieView;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.subView = movieView;
        self.win = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.win addSubview:self];
        [self addSubview:self.subView];
        [self.win setHidden:NO];
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
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    self.subView.center = point;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    self.subView.center = point;
}

@end
