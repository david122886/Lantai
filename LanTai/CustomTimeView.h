//
//  CustomTimeView.h
//  LanTai
//
//  Created by comdosoft on 13-10-29.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTimeView : UIView

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *timeLab;

@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
- (id)init;
- (void)setup;
- (void)stop;
@end
