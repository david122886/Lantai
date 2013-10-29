//
//  CustomTimeView.m
//  LanTai
//
//  Created by comdosoft on 13-10-29.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "CustomTimeView.h"

@implementation CustomTimeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)setup
{
    [self customizeAppearance];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [self.timer fire];
    NSLog(@"create timer:%@",self.timer);
}

- (void)customizeAppearance {
    self.backgroundColor = [UIColor clearColor];
}

- (void)timerFireMethod:(NSTimer*)theTimer {
    if (self.startTime && self.endTime) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        NSDate *startDate = [dateFormatter dateFromString:self.startTime];
        NSDate *endDate = [dateFormatter dateFromString:self.endTime];

        if ([startDate compare:[self getNowDateFromatAnDate]] == NSOrderedAscending &&
            [endDate compare:[self getNowDateFromatAnDate]] == NSOrderedDescending) {
            NSArray *date = [self.endTime componentsSeparatedByString:@" "];
            if ([date count] > 1) {
                NSCalendar *cal = [NSCalendar currentCalendar];
                NSDateComponents *time = [[NSDateComponents alloc] init];
                
                NSArray *yearArr = [[date objectAtIndex:0] componentsSeparatedByString:@"-"];
                if ([yearArr count] == 3) {
                    [time setYear:[[yearArr objectAtIndex:0]intValue]];
                    [time setMonth:[[yearArr objectAtIndex:1]intValue]];
                    [time setDay:[[yearArr objectAtIndex:2]intValue]];
                }
                
                NSArray *timeArr = [[date objectAtIndex:1] componentsSeparatedByString:@":"];
                if ([timeArr count] == 3) {
                    [time setHour:[[timeArr objectAtIndex:0]intValue]];
                    [time setMinute:[[timeArr objectAtIndex:1]intValue]];
                    [time setSecond:[[timeArr objectAtIndex:2]intValue]];
                }
                NSDate *todate = [cal dateFromComponents:time];
                NSDate *today = [NSDate date];
                
                unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
                NSDateComponents *d = [cal components:unitFlags fromDate:today toDate:todate options:0];
                int hour =[d hour];
                int minute = [d minute];
                int second = [d second];
                if (hour<=0 && minute<=0 && second<=0) {
                    self.timeLab.text = @"施工完成";
                    [self stop];
                }else {
                    NSString *h =[NSString stringWithFormat:@"%d",[d hour]];
                    NSString *m =[NSString stringWithFormat:@"%d",[d minute]];
                    NSString *s =[NSString stringWithFormat:@"%d",[d second]];
                    self.timeLab.text= [NSString stringWithFormat:@"%@:%@:%@",h.length!=1?h:[NSString stringWithFormat:@"0%@",h],m.length!=1?m:[NSString stringWithFormat:@"0%@",m],s.length!=1?s:[NSString stringWithFormat:@"0%@",s]];
                }
            }
        }
        if ([endDate compare:[self getNowDateFromatAnDate]] == NSOrderedAscending) {
            self.timeLab.text = @"施工完成";
            [self stop];
        }
        if ([startDate compare:[self getNowDateFromatAnDate]] == NSOrderedDescending) {
            self.timeLab.text = @"等待施工";
        }
    }
}

- (void)stop
{
    self.timeLab = nil;
    [self.timer invalidate];
    self.timer = nil;
}

- (NSDate *)getNowDateFromatAnDate
{
    NSDate *anyDate = [NSDate date];
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}

@end
