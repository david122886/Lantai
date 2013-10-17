//
//  AppDelegate.m
//  Dida
//
//  Created by test on 8/11/12.
//  Copyright (c) 2012 aurora. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate(Additions)

+ (NSDate *)dateFromStringByFormat:(NSString *)string format:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	NSDate *returnDate = [dateFormatter dateFromString:string];
    return returnDate;
}

+ (NSString *)dateToStringByFormat:(NSDate *)date format:(NSString *)format {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	NSString *returnString = [dateFormatter stringFromDate:date];
    return returnString;
}

+ (NSString *)dateToStringByFormatWithSystemZone:(NSDate *)date format:(NSString *)format {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
	[dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
	NSString *returnString = [dateFormatter stringFromDate:date];
    return returnString;
}

+ (NSString *)dateConvert:(NSString *)string format:(NSString *)format {
    NSString *dayStr, *timeStr;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
	[dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    if ([[string componentsSeparatedByString:@":"] count] == 3){
        string = [string substringToIndex:string.length-3];
    }
    [timeFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [dateFormatter dateFromString:string];
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"MM-dd"];
	[dayFormatter setTimeZone:[NSTimeZone systemTimeZone]];
	[timeFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSUInteger componentFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:componentFlags fromDate:date];
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    NSDateComponents *now_components = [[NSCalendar currentCalendar] components:componentFlags fromDate:[NSDate date]];
    NSInteger now_year = [now_components year];
    NSInteger now_month = [now_components month];
    NSInteger now_day = [now_components day];
    if (year == now_year && month == now_month) {
        if (day == now_day) {
            dayStr = @"今天";
        } else if (day + 1 == now_day) {
            dayStr = @"昨天";
        } else {
            dayStr = [dayFormatter stringFromDate:date];
        }
    } else {
        dayStr = [dayFormatter stringFromDate:date];
    }
    timeStr = [timeFormatter stringFromDate:date];
    NSString *returnStr = [NSString stringWithFormat:@"%@ %@", dayStr, timeStr];
    return returnStr;
}

@end
