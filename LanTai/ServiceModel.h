//
//  ServiceModel.h
//  LanTai
//
//  Created by comdosoft on 13-10-15.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceModel : NSObject
@property (nonatomic, strong) NSString *serviceId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *price;
@property (nonatomic,assign) BOOL isSelected;
@end
