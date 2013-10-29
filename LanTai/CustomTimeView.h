//
//  CustomTimeView.h
//  LanTai
//
//  Created by comdosoft on 13-10-29.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTimeView : UIView

@property (nonatomic, strong) NSString *dateString;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *timeLab;

- (id)initWithDateStr:(NSString *)dateStr andFrame:(CGRect)frame;
- (void)setup;
- (void)stop;
@end
