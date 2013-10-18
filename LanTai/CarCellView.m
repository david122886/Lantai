//
//  CarCellView.m
//  LanTai
//
//  Created by david on 13-10-15.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "CarCellView.h"
#define CAR_PADDING 10
#define CAR_HEIGHT 44
@interface CarCellView()
@property (nonatomic,strong) UIImageView  *carImageView;
@property (nonatomic,strong) UILabel *carNumberLabel;

@end
@implementation CarCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.carImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self addSubview:self.carImageView];
        
        self.carNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.carNumberLabel];
        self.carNumberLabel.backgroundColor = [UIColor clearColor];
        [self.carNumberLabel setTextAlignment:NSTextAlignmentCenter];
        [self.carNumberLabel setFont:[UIFont systemFontOfSize:25]];
        [self.carNumberLabel setTextColor:[UIColor whiteColor]];
        
        self.coverView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.coverView];
        self.coverView.backgroundColor = [UIColor blackColor];
        self.coverView.alpha = 0.5;
        [self.coverView setHidden:YES];
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

-(CarCellView*)copyCarCellView{
    CarCellView *copyView = [[CarCellView alloc] init];
    copyView.carNumber = self.carNumber;
    copyView.state = self.state;
    copyView.frame = [self convertRect:self.frame toView:self.superview];
    return copyView;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.carImageView.frame = (CGRect){0,0,self.frame.size};
    self.carNumberLabel.frame = (CGRect){CAR_PADDING,CAR_PADDING,CGRectGetWidth(self.frame) - CAR_PADDING*2,CAR_HEIGHT};
     self.carNumberLabel.center = (CGPoint){CGRectGetWidth(self.frame)/2,CGRectGetHeight(self.frame)/2};
    self.coverView.frame = (CGRect){0,0,self.frame.size};
}
-(void)setState:(CarState)state{
    _state = state;
    switch (state) {
        case CARWAITTING:
        {
            [self.carImageView setImage:[UIImage imageNamed:@"redCar.png"]];
            self.carNumberLabel.text = self.carNumber;
        break;
        }
        case CARBEGINNING:
        {
            [self.carImageView setImage:[UIImage imageNamed:@"greenCar.png"]];
            self.carNumberLabel.text = self.carNumber;
            break;
        }
        case CARPAYING:
        case CARFINISHED:
        {
            [self.carImageView setImage:[UIImage imageNamed:@"blueCar.png"]];
            self.carNumberLabel.text = self.carNumber;
            break;
        }
        case CARNOTHING:
        {
            [self.carImageView setImage:nil];
            self.carNumberLabel.text = nil;
            [self.coverView setHidden:YES];
            break;
        }
            
        default:
            break;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    
    if (self.state == CARBEGINNING || self.state == CARPAYING) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenCoverView) object:nil];
        [self performSelector:@selector(appearCoverView) withObject:nil afterDelay:0.05];
        [self performSelector:@selector(hiddenCoverView) withObject:nil afterDelay:0.2];
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(appearCoverView) object:nil];
    [super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    if (self.delegate && [self.delegate respondsToSelector:@selector(carCellViewDidSelected:)]) {
        [self.delegate carCellViewDidSelected:self];
    }
    [self.coverView setHidden:YES];
}

-(void)hiddenCoverView{
    [self.coverView setHidden:YES];
}

-(void)appearCoverView{
    [self.coverView setHidden:NO];
}
@end
