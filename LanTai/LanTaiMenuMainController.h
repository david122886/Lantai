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
@class ShaixuanView;
@class PlateVViewController;
@protocol BZGFormFieldDelegate;

@interface LanTaiMenuMainController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,BZGFormFieldDelegate,CarCellViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *leftTopScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *bottomLeftScrollView;

@property (weak, nonatomic) IBOutlet UIView *leftBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *touchView;
@property (weak, nonatomic) IBOutlet BZGFormField *carNumberTextField;


@property (nonatomic,strong) IBOutlet UITableView *orderTable;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) ShaixuanView *sxView;
@property (nonatomic,strong) NSMutableArray *letterArray;
//@property (nonatomic,strong) PayViewController *payView;
@property (nonatomic,strong) NSString *is_car_num;//0:电话  1:车牌
@property (nonatomic,strong) PlateVViewController *plateView;
@property (nonatomic,strong) NSMutableArray *waitArray;//排队等候
@property (nonatomic,strong) NSMutableArray *workingArray;//施工中
@property (nonatomic,strong) NSMutableArray *waitPayArray;//等待付款

//菊花
@property (nonatomic,strong) MBProgressHUD *hud;

- (IBAction)refreshServeItemsBtClicked:(id)sender;
- (IBAction)touchDragGesture:(UIPanGestureRecognizer *)sender;
@end
