//
//  OrderModel.h
//  LanTai
//
//  Created by comdosoft on 13-10-16.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderModel : NSObject

@property (nonatomic, strong) NSString *workOrderId;
@property (nonatomic, strong) NSString *lastTime;
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *serviceName;
@property (nonatomic, strong) NSString *serviceStartTime;
@property (nonatomic, strong) NSString *serviceEndTime;
@property (nonatomic, strong) NSString *carNum;
@property (nonatomic, strong) NSString *carNumId;
@property (nonatomic, strong) NSString *stationId;


@end
