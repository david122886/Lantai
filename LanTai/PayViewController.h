//
//  PayViewController.h
//  LanTaiOrder
//
//  Created by Ruby on 13-3-3.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceCell.h"
#import "SVCardCell.h"
#import "PackageCardCell.h"
#import "ProductHeader.h"


@interface PayViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
}

@property (nonatomic,strong) IBOutlet UILabel *lblCarNum;
@property (nonatomic,strong) IBOutlet UITableView *productTable;
@property (nonatomic,strong) NSMutableArray *productList;
@property (nonatomic,strong) NSMutableDictionary *orderInfo;
@property (nonatomic,assign) CGFloat total_count;
@property (nonatomic,strong) IBOutlet UIView *pleaseView;
@property (nonatomic,strong) IBOutlet UIView *orderBgView;
@property (nonatomic,strong) IBOutlet UISegmentedControl *segBtn;

@property (nonatomic,strong) IBOutlet UILabel *lblService,*lblTotal;
@property (nonatomic,strong) NSString *serviceName;
@property (nonatomic,strong) NSString *car_num;
@property (nonatomic,strong) NSString *payString;

@property (nonatomic,assign) CGFloat total_count_temp;
@property (nonatomic,strong) NSString *orderId;

- (IBAction)clickSegBtn:(UISegmentedControl *)sender;

@end
