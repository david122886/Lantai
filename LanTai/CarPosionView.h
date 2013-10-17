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
@interface CarPosionView : UIView
@property(nonatomic,assign) int posionID;
@property(nonatomic,strong) NSString *posionDate;
@property(nonatomic,strong) NSString *posionCarNumber;
@property(nonatomic,strong) NSString *posionServeName;
@property(nonatomic,assign)BOOL isEmpty;
@property(nonatomic,strong) CarCellView *carView;
-(void)setCarObj:(CarObj*)car;
@end
