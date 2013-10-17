//
//  CarObj.h
//  LanTai
//
//  Created by david on 13-10-15.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <Foundation/Foundation.h>
//hkkbb
@interface CarObj : NSObject
@property (nonatomic,strong) NSString *carID;
@property (nonatomic,strong) NSString *carPlateNumber;
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *stationId;
@property (nonatomic, strong) NSString *serviceName;
@property (nonatomic, strong) NSString *lastTime;
@property (nonatomic, strong) NSString *workOrderId;
@property (nonatomic, strong) NSString *serviceStartTime;
@property (nonatomic, strong) NSString *serviceEndTime;

@end
