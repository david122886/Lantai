//
//  LanTaiMenuMainController.h
//  LanTai
//
//  Created by david on 13-10-15.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PayViewController.h"
#import "BZGFormField.h"
#import "CarCellView.h"
#import "ServeItemView.h"
@class ShaixuanView;
@class PlateVViewController;
@protocol BZGFormFieldDelegate;

@interface LanTaiMenuMainController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,BZGFormFieldDelegate,CarCellViewDelegate,ServeItemViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *leftTopScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *bottomLeftScrollView;

@property (weak, nonatomic) IBOutlet UIView *leftBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *touchView;
@property (weak, nonatomic) IBOutlet BZGFormField *carNumberTextField;
@property (weak, nonatomic) IBOutlet UIView *leftMiddlebgView;


@property (nonatomic,strong) IBOutlet UITableView *orderTable;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) ShaixuanView *sxView;
@property (nonatomic,strong) NSMutableArray *letterArray;
@property (nonatomic,strong) NSString *is_car_num;//0:电话  1:车牌
@property (nonatomic,strong) PlateVViewController *plateView;


//菊花
@property (nonatomic,strong) MBProgressHUD *hud;
@property (weak, nonatomic) IBOutlet UIButton *serveRefreshBt;

- (IBAction)refreshServeItemsBtClicked:(id)sender;
- (IBAction)touchDragGesture:(UIPanGestureRecognizer *)sender;
@end
