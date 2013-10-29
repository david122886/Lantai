//
//  CarPosionView.h
//  LanTai
//
//  Created by david on 13-10-16.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarObj.h"
#import "CarCellView.h"
#import "CustomTimeView.h"
@interface CarPosionView : UIView
@property(nonatomic,assign) int posionID;
@property(nonatomic,strong) NSString *posinName;
@property(nonatomic,strong) NSString *posionDate;
@property(nonatomic,strong) NSString *posionCarNumber;
@property(nonatomic,strong) NSString *posionServeName;
@property(nonatomic,assign)BOOL isEmpty;
@property(nonatomic,strong) CarCellView *carView;
@property(nonatomic,strong) CustomTimeView *cusTime;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSString *timeStr;

-(void)setCarObj:(CarObj*)car;
@end
