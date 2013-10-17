//
//  Utils.h
//  LanTaiOrder
//
//  Created by Ruby on 13-1-23.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>
#import <SystemConfiguration/SystemConfiguration.h>
@interface Utils : NSObject
+ (NSString *) localWiFiIPAddress;
+ (void)errorAlert:(NSString *)message;
+ (NSString *)isExistenceNetwork;
+ (NSMutableArray *)matchArray;
+ (NSString *)connectToInternet;
+ (NSString *)orderStatus:(int)status;
+ (NSString *)formateDate:(NSString *)date;
+ (NSString *)MD5:(NSString *)str;
+ (NSMutableURLRequest *)getRequest:(NSMutableDictionary *)params string:(NSString *)theStr;
@end
