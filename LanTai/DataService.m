//
//  DataService.m
//  LanTaiOrder
//
//  Created by Ruby on 13-1-23.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import "DataService.h"

@implementation DataService

@synthesize user_id,reserve_count,car_num,reserve_list,kPosAppId;
@synthesize number,payNumber;
@synthesize doneArray;
@synthesize tagOfBtn;
@synthesize first,row_id_countArray,productList,row_id_numArray,price_id,number_id;
@synthesize ReservationFirst,refreshing,packageCard_dic,total_count,row,matchArray,sectionArray;
@synthesize id_count_price,saleArray;
@synthesize package_product;
@synthesize service_array,firstTime;

- (id)init{
    self = [super init];
    if (!self) {
        self.reserve_count = [NSString string];
        self.user_id = [NSString string];
        self.store_id = [NSString string];
        self.workingOrders = [NSMutableDictionary dictionary];
        self.car_num = [NSString string];
        self.reserve_list = [NSMutableArray array];
        self.doneArray = [NSMutableArray array];
        self.tagOfBtn = 0;
        self.first = YES;
        self.ReservationFirst = YES;
        self.refreshing = NO;
        self.row_id_countArray = [NSMutableArray array];
        self.row_id_numArray = [NSMutableArray array];
        self.productList = [NSMutableArray array];
        self.price_id = [NSMutableDictionary dictionary];
        self.number_id = [NSMutableDictionary dictionary];
        self.packageCard_dic = [NSMutableDictionary dictionary];
        self.row = [NSMutableArray array];
        self.matchArray = [NSMutableArray array];
        self.sectionArray = [NSMutableArray array];
        self.id_count_price = [NSMutableArray array];
        self.saleArray = [NSMutableArray array];
   
        self.package_product = [NSMutableArray array];
        self.sectionArray = [NSMutableArray array];
    }
    return self;
}


+ (DataService *)sharedService {
    static dispatch_once_t once;
    static DataService *dataService = nil;
    
    dispatch_once(&once, ^{
        dataService = [[super alloc] init];
    });
    return dataService;
}

@end
