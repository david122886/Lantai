//
//  AppDelegate.m
//  Dida
//
//  Created by test on 8/11/12.
//  Copyright (c) 2012 aurora. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate(Additions)

+ (NSDate *)dateFromStringByFormat:(NSString *)string format:(NSString *)format;

+ (NSString *)dateToStringByFormat:(NSDate *)date format:(NSString *)format;

+ (NSString *)dateToStringByFormatWithSystemZone:(NSDate *)date format:(NSString *)format;

+ (NSString *)dateConvert:(NSString *)string format:(NSString *)format;

@end
