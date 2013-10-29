//
//  CarPosionView.m
//  LanTai
//
//  Created by david on 13-10-16.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "CarPosionView.h"
#import <QuartzCore/QuartzCore.h>
#define  CAR_PADDING 5
#define CAR_CARPADDING 40
#define CAR_TITLE_HEIGHT 35
#define CAR_DATE_IMAGEWIDTH 25
#define CAR_FONT_SIZE 20


@interface CarPosionView()
@property(nonatomic,strong) UILabel *posinIDLabel;

@property(nonatomic,strong) UILabel *posinDateLabel;
@property(nonatomic,strong) UIImageView *posionDateImageView;
@property(nonatomic,strong) UIImageView *titileBackView;
@property(nonatomic,strong) UILabel *coverLabel;
@property(nonatomic,strong) UILabel *serveNameLabel;
@property(nonatomic,strong) UIImageView *carImageView;
@end


@implementation CarPosionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titileBackView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.titileBackView];
        [self.titileBackView setBackgroundColor:[UIColor clearColor]];
        
        self.serveNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.serveNameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.serveNameLabel setFont:[UIFont systemFontOfSize:CAR_FONT_SIZE]];
        self.serveNameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.serveNameLabel];
        
        self.posinIDLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.posinIDLabel.backgroundColor = [UIColor clearColor];
        [self.posinIDLabel setFont:[UIFont systemFontOfSize:CAR_FONT_SIZE]];
        [self.titileBackView addSubview:self.posinIDLabel];
        
        self.posionDateImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.posionDateImageView.image = [UIImage imageNamed:@"clock.png"];
        [self.titileBackView addSubview:self.posionDateImageView];
        
        self.posinDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.posinDateLabel.backgroundColor = [UIColor clearColor];
        [self.posinDateLabel setFont:[UIFont systemFontOfSize:CAR_FONT_SIZE-2]];
        [self.titileBackView addSubview:self.posinDateLabel];
        
        self.carImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grayCar.png"]];
        [self addSubview:self.carImageView];
        self.carView = [[CarCellView alloc]initWithFrame:CGRectZero];
        self.carView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.carView];
        
        self.coverLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.coverLabel.center = self.carView.center;
        [self.coverLabel setFont:[UIFont systemFontOfSize:CAR_FONT_SIZE]];
        self.coverLabel.text = @"暂无";
        [self.coverLabel setTextAlignment:NSTextAlignmentCenter];
        self.coverLabel.textColor = [UIColor darkGrayColor];
        self.coverLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.coverLabel];
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

-(void)setIsEmpty:(BOOL)isEmpty{
    _isEmpty = isEmpty;
    if (isEmpty) {
        [self.titileBackView setImage:[[UIImage imageNamed:@"posinTitlegraybg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 20, 0)]];
        self.cusTime.hidden = YES;
        self.carView.state = CARNOTHING;
        self.serveNameLabel.text = nil;
        self.posinDateLabel.text = @"00:00:00";
        self.serveNameLabel.text = nil;
        self.posinIDLabel.textColor = [UIColor darkGrayColor];
        self.posinDateLabel.textColor = [UIColor darkGrayColor];
        [self.cusTime stop];
    }else{
        self.posinDateLabel.text = self.posionDate;
        self.carView.state = CARBEGINNING;
        self.serveNameLabel.text = self.posionServeName;

        [self.titileBackView setImage:[[UIImage imageNamed:@"posionTitlegreenbg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 2, 0)]];

        self.posinIDLabel.textColor = [UIColor whiteColor];
        self.posinDateLabel.textColor = [UIColor whiteColor];
        
        self.cusTime.timeLab = self.posinDateLabel;
        self.cusTime.startTime = self.timeStart;
        self.cusTime.endTime = self.timeEnd;
        [self.cusTime setup]; 
    }
    [self.coverLabel setHidden:!isEmpty];
    [self.carImageView setHidden:!isEmpty];
    
    [self.cusTime setHidden:isEmpty];
}

-(void)setPosinName:(NSString *)posinName{
    _posinName = posinName;
    self.posinIDLabel.text = posinName;
}

-(void)setCarObj:(CarObj*)car{
    if (car) {
        self.carView.carNumber = car.carPlateNumber;
        self.carView.state = CARBEGINNING;

        self.timeStart = [NSString stringWithFormat:@"%@",car.serviceStartTime];
        self.timeEnd = [NSString stringWithFormat:@"%@",car.serviceEndTime];

        self.posionServeName = car.serviceName;
        self.isEmpty = NO;
    }else{
        self.isEmpty = YES;
    }
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.titileBackView.frame = (CGRect){0,0,self.frame.size.width,CAR_TITLE_HEIGHT+CAR_PADDING*2};
    self.posinIDLabel.frame = (CGRect){CAR_PADDING,CAR_PADDING,(CGRectGetWidth(self.frame)-CAR_PADDING*3)*2/3,CAR_TITLE_HEIGHT};
    self.posionDateImageView.frame = (CGRect){CGRectGetMaxX(self.posinIDLabel.frame)-20,CGRectGetHeight(self.titileBackView.frame)/2 - CAR_DATE_IMAGEWIDTH/2,CAR_DATE_IMAGEWIDTH,CAR_DATE_IMAGEWIDTH};
    self.posinDateLabel.frame = (CGRect){CAR_PADDING/2+CGRectGetMaxX(self.posionDateImageView.frame),CAR_PADDING,(CGRectGetWidth(self.frame))/3-CAR_DATE_IMAGEWIDTH+20,CAR_TITLE_HEIGHT};
    self.serveNameLabel.frame = (CGRect){CAR_PADDING,CGRectGetMaxY(self.titileBackView.frame),self.frame.size.width - CAR_PADDING*2,CAR_TITLE_HEIGHT};
    
    float carHeight = CGRectGetHeight(self.frame) - CGRectGetHeight(self.titileBackView.frame) - CAR_CARPADDING*4/3;
    float carWidth = CGRectGetWidth(self.frame) - CAR_CARPADDING*2;
    self.carView.frame = (CGRect){CAR_CARPADDING,CAR_CARPADDING+CGRectGetMaxY(self.titileBackView.frame),carWidth,carHeight};
    self.coverLabel.frame = (CGRect){0,0,self.frame.size.width,CAR_TITLE_HEIGHT};
    self.coverLabel.center = self.carView.center;
    self.carImageView.frame = self.carView.frame;
}

-(CustomTimeView *)cusTime {
    if (!_cusTime) {
        _cusTime = [[CustomTimeView alloc]init];
 
    }
    return _cusTime;
}
@end
