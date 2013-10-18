//
//  CarPosionView.m
//  LanTai
//
//  Created by david on 13-10-16.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "CarPosionView.h"

#define  CAR_PADDING 5
#define CAR_CARPADDING 40
#define CAR_TITLE_HEIGHT 35
#define CAR_DATE_IMAGEWIDTH 25
#define CAR_FONT_SIZE 20
@interface CarPosionView()
@property(nonatomic,strong) UILabel *posinIDLabel;

@property(nonatomic,strong) UILabel *posinDateLabel;
@property(nonatomic,strong) UIImageView *posionDateImageView;
@property(nonatomic,strong) UIView *titileBackView;
@property(nonatomic,strong) UILabel *coverLabel;
@property(nonatomic,strong) UILabel *serveNameLabel;
@end


@implementation CarPosionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.titileBackView = [[UIView alloc] initWithFrame:CGRectZero];
        self.titileBackView.backgroundColor = [UIColor orangeColor];
        [self addSubview:self.titileBackView];
        
        self.serveNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.serveNameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.serveNameLabel setFont:[UIFont systemFontOfSize:CAR_FONT_SIZE]];
        self.serveNameLabel.backgroundColor = [UIColor orangeColor];
        [self addSubview:self.serveNameLabel];
        
        self.posinIDLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.posinIDLabel.backgroundColor = [UIColor redColor];
        [self.posinIDLabel setFont:[UIFont systemFontOfSize:CAR_FONT_SIZE]];
        [self.titileBackView addSubview:self.posinIDLabel];
        
        self.posionDateImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        self.posionDateImageView.backgroundColor = [UIColor blueColor];
        self.posionDateImageView.image = [UIImage imageNamed:@"clock.png"];
        [self.titileBackView addSubview:self.posionDateImageView];
        
        self.posinDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.posinDateLabel.backgroundColor = [UIColor purpleColor];
        [self.posinDateLabel setFont:[UIFont systemFontOfSize:CAR_FONT_SIZE]];
        [self.titileBackView addSubview:self.posinDateLabel];
        
       
        self.carView = [[CarCellView alloc]initWithFrame:CGRectZero];
        self.carView.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:self.carView];
        
        self.coverLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.coverLabel.center = self.carView.center;
        [self.coverLabel setFont:[UIFont systemFontOfSize:CAR_FONT_SIZE]];
        self.coverLabel.text = @"暂无";
        [self.coverLabel setTextAlignment:NSTextAlignmentCenter];
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

-(void)layoutSubviews{
    [super layoutSubviews];
    self.titileBackView.frame = (CGRect){0,0,self.frame.size.width,CAR_TITLE_HEIGHT+CAR_PADDING*2};
    self.posinIDLabel.frame = (CGRect){CAR_PADDING,CAR_PADDING,(CGRectGetWidth(self.frame)-CAR_PADDING*3)*2/3,CAR_TITLE_HEIGHT};
    self.posionDateImageView.frame = (CGRect){CGRectGetMaxX(self.posinIDLabel.frame)+CAR_PADDING,CGRectGetHeight(self.titileBackView.frame)/2 - CAR_DATE_IMAGEWIDTH/2,CAR_DATE_IMAGEWIDTH,CAR_DATE_IMAGEWIDTH};
    self.posinDateLabel.frame = (CGRect){CAR_PADDING/2+CGRectGetMaxX(self.posionDateImageView.frame),CAR_PADDING,(CGRectGetWidth(self.frame)-CAR_PADDING*3)/3-CAR_DATE_IMAGEWIDTH,CAR_TITLE_HEIGHT};
    self.serveNameLabel.frame = (CGRect){CAR_PADDING,CGRectGetMaxY(self.titileBackView.frame),self.frame.size.width - CAR_PADDING*2,CAR_TITLE_HEIGHT};
    
    float carHeight = CGRectGetHeight(self.frame) - CGRectGetHeight(self.titileBackView.frame) - CAR_CARPADDING*4/3;
    float carWidth = CGRectGetWidth(self.frame) - CAR_CARPADDING*2;
    self.carView.frame = (CGRect){CAR_CARPADDING,CAR_CARPADDING+CGRectGetMaxY(self.titileBackView.frame),carWidth,carHeight};
    self.coverLabel.frame = (CGRect){0,0,self.frame.size.width,CAR_TITLE_HEIGHT};
    self.coverLabel.center = self.carView.center;
}

-(void)setIsEmpty:(BOOL)isEmpty{
    _isEmpty = isEmpty;
    if (isEmpty) {
        [self.titileBackView setBackgroundColor:[UIColor clearColor]];
        self.carView.state = CARNOTHING;
        self.serveNameLabel.text = nil;
        self.posinDateLabel.text = @"00:00";
        self.serveNameLabel.text = nil;
    }else{
        [self.titileBackView setBackgroundColor:[UIColor yellowColor]];
        self.posinDateLabel.text = self.posionDate;
        self.carView.state = CARBEGINNING;
        self.serveNameLabel.text = self.posionServeName;
    }
    [self.coverLabel setHidden:!isEmpty];
}

-(void)setPosionID:(int)posionID{
    _posionID = posionID;
    self.posinIDLabel.text = [NSString stringWithFormat:@"%d工号位",_posionID];
}


-(void)setCarObj:(CarObj*)car{
    if (car) {
        
        self.carView.carNumber = car.carPlateNumber;
        self.carView.state = CARBEGINNING;
        self.posionDate = car.serviceStartTime;
        self.posionServeName = car.serviceName;
        self.isEmpty = NO;
    }else{
        self.isEmpty = YES;
    }
}
@end
