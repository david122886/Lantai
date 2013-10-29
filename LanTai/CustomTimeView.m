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

- (id)initWithDateStr:(NSString *)dateStr andFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.dateString = dateStr;

    }
    return self;
}
- (void)setup
{
    [self customizeAppearance];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(timerFireMethod:)
                                                userInfo:nil
                                                 repeats:YES];
}
- (void)customizeAppearance {
    self.backgroundColor = [UIColor clearColor];
}

- (void)timerFireMethod:(NSTimer*)theTimer {
    if (self.dateString) {
        NSArray *date = [self.dateString componentsSeparatedByString:@" "];
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
                self.timeLab.text = @"00:00";
                [self stop];
            }else {
                NSString *h =[NSString stringWithFormat:@"%d",[d hour]];
                NSString *m =[NSString stringWithFormat:@"%d",[d minute]];
                NSString *s =[NSString stringWithFormat:@"%d",[d second]];
                self.timeLab.text= [NSString stringWithFormat:@"%@:%@:%@",h.length!=1?h:[NSString stringWithFormat:@"0%@",h],m.length!=1?m:[NSString stringWithFormat:@"0%@",m],s.length!=1?s:[NSString stringWithFormat:@"0%@",s]];
            }
        }
    }
}

- (void)stop
{
    self.timeLab = nil;
    [self.timer invalidate];
}
@end
