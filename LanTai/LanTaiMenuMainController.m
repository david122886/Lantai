//
//  LanTaiMenuMainController.m
//  LanTai
//
//  Created by david on 13-10-15.
//  Copyright (c) 2013年 david. All rights reserved.
//
#import "AppDelegate.h"
#import "LanTaiMenuMainController.h"///qiueß

#import "CarObj.h"
#import "ServeItemView.h"
#import "ShaixuanView.h"
#import "PlateVViewController.h"
#import "PayViewController.h"
#import "ServiceModel.h"
#import "OrderModel.h"
#import "CarPosionView.h"

#define DEBUG 1
#define CELL_WIDHT  200
#define CELL_POSION_WIDHT  250
#define CELL_HEIGHT 134
#define CELL_PADDING 10
#define SERVE_ITEM_HEIGHT 70

@interface LanTaiMenuMainController ()
@property (nonatomic,strong) NSMutableArray *waittingCarsArr;
@property (nonatomic,strong) NSMutableDictionary *beginningCarsDic;
@property (nonatomic,strong) NSMutableArray *finishedCarsArr;
@property (nonatomic,strong) NSMutableArray *serveItemsArr;
@property (nonatomic,strong) NSMutableArray *posionItemArr;
@property (nonatomic,strong) CarCellView *moviedView;
@property (nonatomic,strong) CarPosionView *moviePosionView;
@property (nonatomic,strong) NSMutableArray *stationArray;
@end

@implementation LanTaiMenuMainController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)getData{
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    [params setObject:[DataService sharedService].store_id forKey:@"store_id"];
    NSMutableURLRequest *request=[Utils getRequest:params string:[NSString stringWithFormat:@"%@%@",kHost,kService]];
    NSOperationQueue *queue=[[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *respone,
                                                                                     NSData *data,
                                                                                     NSError *error)
     {
         if ([data length]>0 && error==nil) {
             [self performSelectorOnMainThread:@selector(setRespondtext:) withObject:data waitUntilDone:NO];
             
         }
     }
     ];
}
-(CarObj *)setAttributeWithDictionary:(NSDictionary *)result {
    CarObj *order = [[CarObj alloc]init];
    order.carID = [NSString stringWithFormat:@"%@",[result objectForKey:@"car_num_id"]];
    order.carPlateNumber = [NSString stringWithFormat:@"%@",[result objectForKey:@"num"]];
    order.orderId = [NSString stringWithFormat:@"%@",[result objectForKey:@"id"]];
    if (![[result objectForKey:@"station_id"]isKindOfClass:[NSNull class]] && [result objectForKey:@"station_id"]!=nil) {
        order.stationId =[NSString stringWithFormat:@"%@",[result objectForKey:@"station_id"]];
    }
    order.serviceName = [NSString stringWithFormat:@"%@",[result objectForKey:@"service_name"]];
    order.lastTime = [NSString stringWithFormat:@"%@",[result objectForKey:@"cost_time"]];
    order.workOrderId = [NSString stringWithFormat:@"%@",[result objectForKey:@"wo_id"]];
    if (![[result objectForKey:@"wo_started_at"]isKindOfClass:[NSNull class]] && [result objectForKey:@"wo_started_at"]!=nil) {
        order.serviceStartTime = [NSString stringWithFormat:@"%@",[result objectForKey:@"wo_started_at"]];
    }
    if (![[result objectForKey:@"wo_ended_at"]isKindOfClass:[NSNull class]] && [result objectForKey:@"wo_ended_at"]!=nil) {
        order.serviceEndTime = [NSString stringWithFormat:@"%@",[result objectForKey:@"wo_ended_at"]];
    }
    return order;
}
-(void)setRespondtext:(NSData *)data {
    id jsonObject=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if (jsonObject !=nil) {
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonData=(NSDictionary *)jsonObject;
            DLog(@"resu = %@",jsonData);
            if ([[jsonData objectForKey:@"status"]intValue] == 0) {
                //工位数组
                NSArray *station_array = [jsonData objectForKey:@"station_ids"];
                if (station_array.count>0) {
                    self.stationArray = [NSMutableArray arrayWithArray:station_array];
                    [self setBegningScrollViewContextWithPosionCount:station_array];
                }
                //服务
                NSArray *result_array = [NSArray arrayWithArray:[jsonData objectForKey:@"services"]];
                if (result_array.count>0) {
                    self.dataArray = [[NSMutableArray alloc]init];
                    for (int i=0; i<result_array.count; i++) {
                        NSDictionary *dic = [result_array objectAtIndex:i];
                        ServiceModel *service = [[ServiceModel alloc]init];
                        service.serviceId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
                        service.name = [NSString stringWithFormat:@"%@",[dic objectForKey:@"name"]];
                        service.price = [NSString stringWithFormat:@"%@.00元",[dic objectForKey:@"price"]];
                        [self.dataArray addObject:service];
                    }
                    if (self.dataArray.count>0) {
                        [self.orderTable reloadData];
                    }
                }
                //订单的数组
                NSDictionary *order_dic = [jsonData objectForKey:@"orders"];
                //排队等候
                if (![[order_dic objectForKey:@"0"]isKindOfClass:[NSNull class]] && [order_dic objectForKey:@"0"]!= nil) {
                    NSArray *waiting_array = [order_dic objectForKey:@"0"];
                    if (waiting_array.count>0) {
                        self.waittingCarsArr = [[NSMutableArray alloc]init];
                        for (int i=0; i<waiting_array.count; i++) {
                            NSDictionary *result = [waiting_array objectAtIndex:i];
                            CarObj *order = [self setAttributeWithDictionary:result];
                            [self.waittingCarsArr addObject:order];
                        }
                        [self setWaittingScrollViewContext];
                    }
                }
                //施工中
                if (![[order_dic objectForKey:@"1"]isKindOfClass:[NSNull class]] && [order_dic objectForKey:@"1"]!= nil) {
                     NSArray *working_array = [order_dic objectForKey:@"1"];
                    if (working_array.count>0) {
                        self.beginningCarsDic = [[NSMutableDictionary alloc]init];
                        for (int i=0; i<working_array.count; i++) {
                            NSDictionary *result = [working_array objectAtIndex:i];
                            CarObj *order = [self setAttributeWithDictionary:result];
                            [self.beginningCarsDic setObject:order forKey:order.stationId];
                        }
                        [self moveCarIntoCarPosion];
                    }
                }
                //等待付款
                if (![[order_dic objectForKey:@"2"]isKindOfClass:[NSNull class]] && [order_dic objectForKey:@"2"]!= nil) {
                    
                    NSArray *finish_array = [order_dic objectForKey:@"2"];
                    if (finish_array.count>0) {
                        self.finishedCarsArr = [[NSMutableArray alloc]init];
                        for (int i=0; i<finish_array.count; i++) {
                            NSDictionary *result = [finish_array objectAtIndex:i];
                            CarObj *order = [self setAttributeWithDictionary:result];
                            [self.finishedCarsArr addObject:order];
                        }
                        [self setFinishedScrollViewContext];
                    }
                }
            }
        }
    }
    if ([DataService sharedService].firstTime == YES) {
        [DataService sharedService].firstTime = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}
#if DEBUG
-(void)viewWillAppear:(BOOL)animated{

}
#else
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"]) {
        [Utils errorAlert:@"暂无网络!"];
    }else {
        if ([DataService sharedService].firstTime == YES) {
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.labelText = @"正在玩命加载...";
            [self getData];
        }
    }
}
#endif

-(void )addRightnaviItemsWithImage:(NSString *)imageName {
    NSMutableArray *mycustomButtons = [NSMutableArray array];
    if (imageName != nil && ![imageName isEqualToString:@""]) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_active", imageName]] forState:UIControlStateHighlighted];
        btn.userInteractionEnabled = YES;
        [btn addTarget:self action:@selector(rightTapped:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
        [mycustomButtons addObject: item];
        btn = nil;
        item = nil;
    }
    self.navigationItem.rightBarButtonItems=mycustomButtons;
    [self.navigationItem setHidesBackButton:YES animated:YES];
}
//返回按钮，到登录页面
- (void)rightTapped:(id)sender{
    [DataService sharedService].user_id = nil;
    [DataService sharedService].reserve_list = nil;
    [DataService sharedService].reserve_count = nil;
    [DataService sharedService].store_id = nil;
    [DataService sharedService].car_num = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"userId"];
    [defaults removeObjectForKey:@"storeId"];
    [defaults synchronize];
    
    [(AppDelegate *)[UIApplication sharedApplication].delegate showRootView];
}


-(void)moveCarIntoCarPosion{
    for (int index = 0; index < [self.posionItemArr count]; index++) {
        CarPosionView *posion = [self.posionItemArr objectAtIndex:index];
        if ([self.beginningCarsDic count] > index) {
            CarObj *obj = [self.beginningCarsDic objectForKey:[NSString stringWithFormat:@"%@",[self.stationArray objectAtIndex:index]]];
            
            [posion setCarObj:obj];
        }else{
            [posion setCarObj:nil];
        }
        
    }
}

-(void)setWaittingScrollViewContext{
    for (UIView *subView in [self.leftTopScrollView subviews]) {
        [subView removeFromSuperview];
    }
    for (int index = 0; index < [self.waittingCarsArr count]; index++) {
        CarCellView *view = [[CarCellView alloc] init];
        view.frame = (CGRect){CELL_PADDING+(CELL_WIDHT+CELL_PADDING)*index,CELL_PADDING*2,CELL_WIDHT,CELL_HEIGHT-CELL_PADDING*4};
        view.tag = index;
        CarObj *obj = [self.waittingCarsArr objectAtIndex:index];
        view.carNumber = obj.carPlateNumber;
        view.state = CARWAITTING;
        
        [self.leftTopScrollView addSubview:view];
    }
    self.leftTopScrollView.contentSize = (CGSize){(CELL_WIDHT+CELL_PADDING)*[self.waittingCarsArr count]+CELL_PADDING,CGRectGetHeight(self.leftTopScrollView.frame)};
}


-(void)setBegningScrollViewContextWithPosionCount:(NSArray *)array {
    [self.posionItemArr removeAllObjects];
    int ccount = 0;
    if (array.count >6) {
        ccount=6;
    }else {
        ccount = array.count;
    }
    for (int index = 0; index < ccount; index++) {
        CarPosionView *view = [[CarPosionView alloc] init];
        view.tag = -1;
        view.posionID = [[array objectAtIndex:index]intValue];
        view.isEmpty = YES;
        view.frame = [self getBeginningScrollViewItemRectWithIndex:index];
        view.backgroundColor = [UIColor whiteColor];
        [self.leftBackgroundView addSubview:view];
        [self.posionItemArr addObject:view];
    }
}

-(void)setFinishedScrollViewContext{
    for (UIView *subView in [self.bottomLeftScrollView subviews]) {
        [subView removeFromSuperview];
    }
    for (int index = 0; index < [self.finishedCarsArr count]; index++) {
        CarCellView *view = [[CarCellView alloc] init];
        CarObj *obj = [self.finishedCarsArr objectAtIndex:index];
        view.carNumber = obj.carPlateNumber;
        view.state = CARPAYING;
        view.frame = (CGRect){CELL_PADDING+(CELL_WIDHT+CELL_PADDING)*index,CELL_PADDING*2,CELL_WIDHT,CELL_HEIGHT-CELL_PADDING*4};
        view.tag = index;
        view.delegate = self;
        [self.bottomLeftScrollView addSubview:view];
    }
    self.bottomLeftScrollView.contentSize = (CGSize){(CELL_WIDHT+CELL_PADDING)*[self.finishedCarsArr count]+CELL_PADDING,CGRectGetHeight(self.bottomLeftScrollView.frame)};
}


-(void)moveCarViewFromTopRightScrollViewIntoBeginningScrollView:(CarCellView*)carView{
    NSLog(@"moveCarViewFromTopRightScrollViewIntoBeginningScrollView:carViewTag:%d",carView.tag);
    if ([self.waittingCarsArr count] > 0) {
        [self.beginningCarsDic setObject:[self.waittingCarsArr objectAtIndex:0] forKey:[NSString stringWithFormat:@"%d",carView.tag]];
        CarCellView *car = (CarCellView*)[self.leftTopScrollView viewWithTag:0];
        if (car) {
            CGRect rect = [self.leftTopScrollView convertRect:car.frame toView:self.leftBackgroundView];
            [car removeFromSuperview];
            car.frame = rect;
            [self.leftBackgroundView addSubview:car];
            
            for (UIView *subView in [self.leftTopScrollView subviews]) {
                [subView removeFromSuperview];
            }
            
            [self.waittingCarsArr removeObjectAtIndex:0];
            
            for (int index = 0; index < [self.waittingCarsArr count]; index++) {
                CarCellView *view = [[CarCellView alloc] init];
                view.frame = (CGRect){CELL_PADDING+(CELL_WIDHT+CELL_PADDING)*(index+1),CELL_PADDING,CELL_WIDHT,CELL_HEIGHT};
                view.tag = index;
                [self.leftTopScrollView addSubview:view];
            }
            
            self.leftTopScrollView.contentSize = (CGSize){(CELL_WIDHT+CELL_PADDING)*[self.waittingCarsArr count]+CELL_PADDING,CGRectGetHeight(self.leftTopScrollView.frame)};
            
            
            [UIView animateWithDuration:0.5 animations:^{
                for (int index = 0; index < [self.waittingCarsArr count]; index++) {
                    CarCellView *car = (CarCellView*)[self.leftTopScrollView viewWithTag:index];
                    car.frame = (CGRect){CELL_PADDING+(CELL_WIDHT+CELL_PADDING)*index,CELL_PADDING,CELL_WIDHT,CELL_HEIGHT};
                }
                car.frame = [self getBeginningScrollViewItemRectWithIndex:carView.tag];
                car.tag = carView.tag;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

-(CGRect)getBeginningScrollViewItemRectWithIndex:(int)index{
    
    float height = (708 -CGRectGetHeight(self.bottomLeftScrollView.frame)*2 - CELL_PADDING*3)/2;
    return (CGRect){CELL_PADDING+(CELL_POSION_WIDHT+CELL_PADDING)*(index/2),CELL_HEIGHT+CELL_PADDING+(height+CELL_PADDING)*(index%2),CELL_POSION_WIDHT,height};
}

-(void)exchangeBeginningCarCellViewPositionWithTouchView:(CarCellView*)touchView{
    for (CarPosionView *subView in self.posionItemArr) {
        //        NSLog(@"%@,%@",NSStringFromCGRect(subView.frame),NSStringFromCGRect(touchView.frame));
        if (CGRectContainsRect(subView.frame,touchView.frame) && subView.posionID != touchView.posionID) {
            
            CarObj *obj1 = [self.beginningCarsDic objectForKey:[NSString stringWithFormat:@"%d",touchView.posionID]];
            CarObj *obj2 = [self.beginningCarsDic objectForKey:[NSString stringWithFormat:@"%d",subView.posionID]];
            [self.beginningCarsDic setValue:obj1 forKey:[NSString stringWithFormat:@"%d",subView.posionID]];
            [self.beginningCarsDic setValue:obj2 forKey:[NSString stringWithFormat:@"%d",touchView.posionID]];
            [self.moviePosionView setCarObj:obj2];
            [subView setCarObj:obj1];
            [self didExchangeBeginningCarCellPosionFromIndex:touchView.posionID toIndex:subView.posionID orFromCarObj:obj1 toCarObj:obj2];
            return;
        }
    }
    
    [self.moviePosionView setIsEmpty:NO];
    
}

-(void)failureExchangeBeginningCarCellPosionFromIndex:(int)from toIndex:(int)to orFromCarObj:(CarObj*)fromObj toCarObj:(CarObj*)toObj{
    [self.beginningCarsDic setValue:fromObj forKey:[NSString stringWithFormat:@"%d",to]];
    [self.beginningCarsDic setValue:toObj forKey:[NSString stringWithFormat:@"%d",from]];
    
    CarPosionView *posion1 = [self.posionItemArr objectAtIndex:[self.stationArray indexOfObject:[NSString stringWithFormat:@"%d",from]]];
    CarPosionView *posion2 = [self.posionItemArr objectAtIndex:[self.stationArray indexOfObject:[NSString stringWithFormat:@"%d",to]]];
    [posion1 setCarObj:toObj];
    [posion2 setCarObj:fromObj];////////////////david is good is not good   
}

-(void)moveCarViewFromBeginningScrollViewIntoBottomRightScrollView:(CarCellView*)carView{
    //    NSLog(@"moveCarViewFromBeginningScrollViewIntoBottomRightScrollView:carViewTag:%d",carView.tag);
    CarObj *carObj = [self.beginningCarsDic objectForKey:[NSString stringWithFormat:@"%d",carView.posionID]];
    [self.finishedCarsArr insertObject:carObj atIndex:0];
    [self.beginningCarsDic removeObjectForKey:[NSString stringWithFormat:@"%d",carView.posionID]];
    
    CGRect rect = (CGRect){CELL_PADDING,CELL_PADDING,CELL_WIDHT,CELL_HEIGHT};
    for (UIView *subView in [self.bottomLeftScrollView subviews]) {
        [subView removeFromSuperview];
    }
    for (int index = 0; index < [self.finishedCarsArr count]; index++) {
        CarCellView *view = [[CarCellView alloc] init];
        view.frame = (CGRect){CELL_PADDING+(CELL_WIDHT+CELL_PADDING)*(index-1),CELL_PADDING,CELL_WIDHT,CELL_HEIGHT};
        view.tag = index;
        CarObj *obj = [self.finishedCarsArr objectAtIndex:index];
        view.carNumber = obj.carPlateNumber;
        view.state = CARPAYING;
        view.delegate = self;
        if (index == 0) {
            [view setHidden:YES];
        }
        [self.bottomLeftScrollView addSubview:view];
    }
    
    self.bottomLeftScrollView.tag = -1;
    [UIView animateWithDuration:0.5 animations:^{
        for (int index = 0; index < [self.finishedCarsArr count]; index++) {
            CarCellView *view = (CarCellView*)[self.bottomLeftScrollView viewWithTag:index];
            view.frame = (CGRect){CELL_PADDING+(CELL_WIDHT+CELL_PADDING)*index,CELL_PADDING,CELL_WIDHT,CELL_HEIGHT};
        }
        carView.frame = [self.bottomLeftScrollView convertRect:rect toView:self.leftBackgroundView];
    } completion:^(BOOL finished) {
        CarCellView *view = (CarCellView*)[self.bottomLeftScrollView viewWithTag:0];
        [view setHidden:NO];
        [carView removeFromSuperview];
        self.bottomLeftScrollView.contentSize = (CGSize){(CELL_WIDHT+CELL_PADDING)*[self.finishedCarsArr count]+CELL_PADDING,CGRectGetHeight(self.bottomLeftScrollView.frame)};
        [self didMoveCarCellFromBeginningScrollViewToBottomLeftScrollViewCellPosionFromIndex:carView.posionID toIndex:0 orCarObj:carObj];
    }];
}

-(void)failureMoveCarCellFromBeginningScrollViewToBottomLeftScrollViewCellPosionFromIndex:(int)from toIndex:(int)to orCarObj:(CarObj*)fromObj{
    CarPosionView *posion1 = [self.posionItemArr objectAtIndex:[self.stationArray indexOfObject:[NSString stringWithFormat:@"%d",from]]];
    [posion1 setCarObj:fromObj];
    [self.beginningCarsDic setValue:fromObj forKey:[NSString stringWithFormat:@"%d",from]];
    [UIView animateWithDuration:0.5 animations:^{
        for (UIView *subView in [self.bottomLeftScrollView subviews]) {
            if ([subView isKindOfClass:[CarCellView class]]) {
                subView.center = (CGPoint){subView.center.x - CGRectGetWidth(subView.frame),subView.center.y};
            }
        }
    } completion:^(BOOL finished) {
        if ([self.finishedCarsArr count] > 0) {
            [self.finishedCarsArr removeObjectAtIndex:0];
            [self setFinishedScrollViewContext];
        }
    }];
}

#if DEBUG
-(void)testController{
    for (int index = 0; index < 6; index++) {
        [self.stationArray addObject:[NSString stringWithFormat:@"%d",index]];
    }
    for (int index = 0; index < 20; index++) {
        CarObj *obj = [[CarObj alloc] init];
        obj.carPlateNumber = [NSString stringWithFormat:@"EG%d",index];
        obj.carID = [NSString stringWithFormat:@"%d",index];
        [self.waittingCarsArr addObject:obj];
    }
    for (int index = 0; index < 6; index++) {
        CarObj *obj = [[CarObj alloc] init];
        obj.carPlateNumber = [NSString stringWithFormat:@"EG%d",index];
        obj.carID = [NSString stringWithFormat:@"%d",index];
        [self.beginningCarsDic setValue:obj forKey:[self.stationArray objectAtIndex:index]];
    }
    for (int index = 0; index < 20; index++) {
        CarObj *obj = [[CarObj alloc] init];
        obj.carPlateNumber = [NSString stringWithFormat:@"EG%d",index];
        obj.carID = [NSString stringWithFormat:@"%d",index];
        [self.finishedCarsArr addObject:obj];
    }
    
    for (int index = 0; index < 20; index++) {
        [self.serveItemsArr addObject:@"便捷洗车"];
    }
}
#else

#endif

#if DEBUG
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.leftTopScrollView.tag = -1;
    self.bottomLeftScrollView.tag = -1;
    [self testController];
    [self setBegningScrollViewContextWithPosionCount:self.stationArray];
    [self setWaittingScrollViewContext];
    [self setFinishedScrollViewContext];
    [self moveCarIntoCarPosion];
	// Do any additional setup after loading the view.
}
#else
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.leftTopScrollView.tag = -1;
    self.bottomLeftScrollView.tag = -1;
//    [self testController];
    
//    [self setWaittingScrollViewContext];
//    [self setFinishedScrollViewContext];
//    [self moveCarIntoCarPosion];
	
    //退出登录
    self.navigationItem.rightBarButtonItems = nil;
    [self addRightnaviItemsWithImage:@"back"];
    
    self.carNumberTextField.textField.placeholder = @"请输入车牌号码";
    __weak LanTaiMenuMainController *weakSelf = self;
    [self.carNumberTextField setTextValidationBlock:^BOOL(NSString *text) {
        NSString *emailRegex = @"1[0-9]{10}|[\u4E00-\u9FFF]+[A-Z0-9a-z]{6}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if (![emailTest evaluateWithObject:text]) {
            weakSelf.carNumberTextField.alertView.title = @"输入正确的车牌号码或手机号码";
            return NO;
        }else {
            return YES;
        }
    }];
    self.carNumberTextField.delegate = self;
    
    //字母数组
    self.letterArray = [[NSMutableArray alloc]initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    //筛选车牌
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sure:) name:@"sure" object:nil];
    //有多个车牌
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(palteSelect:) name:@"palteSelect" object:nil];
    //输入框添加观察者
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.carNumberTextField.textField];
    
    //下拉刷新
    __block LanTaiMenuMainController *manView = self;
    __block UITableView *orderTable_temp = self.orderTable;
    __block BZGFormField *carNumTxt = self.carNumberTextField;
    [_orderTable addPullToRefreshWithActionHandler:^{
        if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"]) {
            [Utils errorAlert:@"暂无网络!"];
        }else {
            [carNumTxt.textField resignFirstResponder];
            [manView getData];
        }
        [orderTable_temp.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:2];
    }];
    
}
#endif

- (void)sure:(NSNotification *)notification {
    NSDictionary *dic = [notification object];
    NSString *str = [dic objectForKey:@"name"];
    self.carNumberTextField.textField.text = str;
    [UIView animateWithDuration:0.35 animations:^{
        self.sxView.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.sxView.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.sxView.view removeFromSuperview];
            self.sxView = nil;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark CarCellViewDelegate
-(void)carCellViewDidSelected:(CarCellView *)view{
    NSLog(@"%@",view.carNumber);
}
#pragma mark --

#pragma mark property
-(NSMutableArray *)waittingCarsArr{
    if (!_waittingCarsArr) {
        _waittingCarsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _waittingCarsArr;
}

-(NSMutableDictionary *)beginningCarsDic{
    if (!_beginningCarsDic) {
        _beginningCarsDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _beginningCarsDic;
}

-(NSMutableArray *)finishedCarsArr{
    if (!_finishedCarsArr) {
        _finishedCarsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _finishedCarsArr;
}

-(NSMutableArray *)serveItemsArr{
    if (!_serveItemsArr) {
        _serveItemsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _serveItemsArr;
}

-(NSMutableArray *)posionItemArr{
    if (!_posionItemArr) {
        _posionItemArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _posionItemArr;
}

-(NSMutableArray *)stationArray{
    if (!_stationArray) {
        _stationArray = [NSMutableArray array];
    }
    return _stationArray;
}
#pragma mark --

- (IBAction)touchDragGesture:(UIPanGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.leftBackgroundView];
    //    NSLog(@"%@",NSStringFromCGPoint(point));
    if (sender.state == UIGestureRecognizerStateBegan) {
        for (UIView *subView in [self.leftBackgroundView subviews]) {
            if ([subView isKindOfClass:[CarPosionView class]] && CGRectContainsPoint(subView.frame, point) && ![((CarPosionView*)subView) isEmpty]) {
                CarCellView *cellView = [[((CarPosionView*)subView) carView] copyCarCellView];
                self.moviedView = cellView;
                self.moviePosionView = (CarPosionView*)subView;
                [self.leftBackgroundView addSubview:self.moviedView];
                CGRect startRect = [subView convertRect:cellView.frame fromView:self.leftBackgroundView];
                self.moviedView.beforeMoiveRect = startRect;
                self.moviedView.parentViewRect = subView.frame;
                self.moviedView.posionID = [(CarPosionView*)subView posionID];
                [self.moviedView setHidden:YES];
                self.moviePosionView.isEmpty = YES;
                break;
            }
        }
    }else
        if (sender.state == UIGestureRecognizerStateEnded) {
            if (self.moviedView) {
                //drag down
                if (CGRectGetMaxY(self.moviedView.frame) - CGRectGetMinY(self.bottomLeftScrollView.frame) > 20) {
                    [self moveCarViewFromBeginningScrollViewIntoBottomRightScrollView:self.moviedView];
                    //                [self moveCarViewFromTopRightScrollViewIntoBeginningScrollView:self.moviedView];
                }else{
                    //drag exchang
                    [self exchangeBeginningCarCellViewPositionWithTouchView:self.moviedView];
                }
                
                self.moviedView.frame = self.moviedView.beforeMoiveRect;
                [self.moviedView removeFromSuperview];
                self.moviedView = nil;
                self.moviePosionView = nil;
            }
            
        }else{
            if (self.moviedView) {
                self.moviedView.center = point;
                [self.moviedView setHidden:NO];
            }
        }
    
}

#pragma mark network
////////////////////////////fklhmghm mgc
//调整工位
static NSString *work_order_id_station_id = nil;
#if DEBUG
-(void)didExchangeBeginningCarCellPosionFromIndex:(int)from toIndex:(int)to orFromCarObj:(CarObj*)fromObj toCarObj:(CarObj*)toObj{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self failureExchangeBeginningCarCellPosionFromIndex:from toIndex:to orFromCarObj:fromObj toCarObj:toObj];
    });
}
#else
-(void)didExchangeBeginningCarCellPosionFromIndex:(int)from toIndex:(int)to orFromCarObj:(CarObj*)fromObj toCarObj:(CarObj*)toObj{
    if (toObj) {
        work_order_id_station_id = [NSString stringWithFormat:@"%@_%@,%@_%@",toObj.workOrderId,fromObj.stationId,fromObj.workOrderId,toObj.stationId];
    }else {
        work_order_id_station_id = [NSString stringWithFormat:@"%@_%@,%@_%d",fromObj.workOrderId,fromObj.stationId,fromObj.workOrderId,to];
    }
    NSArray
    if (work_order_id_station_id) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = @"正在玩命加载...";
        NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
        [params setObject:[DataService sharedService].store_id forKey:@"store_id"];
        [params setObject:[DataService sharedService].user_id forKey:@"user_id"];
        [params setObject:work_order_id_station_id forKey:@"work_order_id_station_id"];
        DLog(@"params = %@",params);
        NSMutableURLRequest *request=[Utils getRequest:params string:[NSString stringWithFormat:@"%@%@",kHost,kStation]];
        NSOperationQueue *queue=[[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *respone,
                                                                                         NSData *data,
                                                                                         NSError *error)
         {
             if ([data length]>0 && error==nil) {
                 [self performSelectorOnMainThread:@selector(selectStation:) withObject:data waitUntilDone:NO];
                 
             }
         }
         ];
    }
}

#endif
-(void)selectStation:(NSData *)data {
    id jsonObject=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if (jsonObject !=nil) {
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonData=(NSDictionary *)jsonObject;
            DLog(@"jsonData = %@",jsonData);
            if ([[jsonData objectForKey:@"status"]intValue] == 0) {
                NSDictionary *order_dic = [jsonData objectForKey:@"orders"];
                //排队等候
                if (![[order_dic objectForKey:@"0"]isKindOfClass:[NSNull class]] && [order_dic objectForKey:@"0"]!= nil) {
                    NSArray *waiting_array = [order_dic objectForKey:@"0"];
                    if (waiting_array.count>0) {
                        self.waittingCarsArr = [[NSMutableArray alloc]init];
                        for (int i=0; i<waiting_array.count; i++) {
                            NSDictionary *resultt = [waiting_array objectAtIndex:i];
                            CarObj *order = [self setAttributeWithDictionary:resultt];
                            [self.waittingCarsArr addObject:order];
                        }
                        [self setWaittingScrollViewContext];
                    }
                }
                //施工中
                if (![[order_dic objectForKey:@"1"]isKindOfClass:[NSNull class]] && [order_dic objectForKey:@"1"]!= nil) {
                    NSArray *working_array = [order_dic objectForKey:@"1"];
                    if (working_array.count>0) {
                        self.beginningCarsDic = [[NSMutableDictionary alloc]init];
                        for (int i=0; i<working_array.count; i++) {
                            NSDictionary *resultt = [working_array objectAtIndex:i];
                            CarObj *order = [self setAttributeWithDictionary:resultt];
                            [self.beginningCarsDic setObject:order forKey:order.stationId];
                        }
                        [self moveCarIntoCarPosion];
                    }
                }
                //等待付款
                if (![[order_dic objectForKey:@"2"]isKindOfClass:[NSNull class]] && [order_dic objectForKey:@"2"]!= nil) {
                    
                    NSArray *finish_array = [order_dic objectForKey:@"2"];
                    if (finish_array.count>0) {
                        self.finishedCarsArr = [[NSMutableArray alloc]init];
                        for (int i=0; i<finish_array.count; i++) {
                            NSDictionary *resultt = [finish_array objectAtIndex:i];
                            CarObj *order = [self setAttributeWithDictionary:resultt];
                            [self.finishedCarsArr addObject:order];
                        }
                        [self setFinishedScrollViewContext];
                    }
                }
            }
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


//施工完成
static NSString *work_order_id = nil;
#if DEBUG
-(void)didMoveCarCellFromBeginningScrollViewToBottomLeftScrollViewCellPosionFromIndex:(int)from toIndex:(int)to orCarObj:(CarObj*)fromObj{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self failureMoveCarCellFromBeginningScrollViewToBottomLeftScrollViewCellPosionFromIndex:from toIndex:to orCarObj:fromObj];
    });
}
#else
-(void)didMoveCarCellFromBeginningScrollViewToBottomLeftScrollViewCellPosionFromIndex:(int)from toIndex:(int)to orCarObj:(CarObj*)fromObj{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"正在玩命加载...";
    work_order_id = fromObj.workOrderId;
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    [params setObject:[DataService sharedService].store_id forKey:@"store_id"];
    [params setObject:[DataService sharedService].user_id forKey:@"user_id"];
    [params setObject:work_order_id forKey:@"work_order_id"];
    NSMutableURLRequest *request=[Utils getRequest:params string:[NSString stringWithFormat:@"%@%@",kHost,kWaitPay]];
    NSOperationQueue *queue=[[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *respone,
                                                                                     NSData *data,
                                                                                     NSError *error)
     {
         if ([data length]>0 && error==nil) {
             [self performSelectorOnMainThread:@selector(finishOrder:) withObject:data waitUntilDone:NO];
             
         }
     }
     ];
}

#endif
-(void)finishOrder:(NSData *)data {
    id jsonObject=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if (jsonObject !=nil) {
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonData=(NSDictionary *)jsonObject;
            DLog(@"jsonData = %@",jsonData);
            if ([[jsonData objectForKey:@"status"]intValue] == 0) {
                NSDictionary *order_dic = [jsonData objectForKey:@"orders"];
                //排队等候
                if (![[order_dic objectForKey:@"0"]isKindOfClass:[NSNull class]] && [order_dic objectForKey:@"0"]!= nil) {
                    NSArray *waiting_array = [order_dic objectForKey:@"0"];
                    if (waiting_array.count>0) {
                        self.waittingCarsArr = [[NSMutableArray alloc]init];
                        for (int i=0; i<waiting_array.count; i++) {
                            NSDictionary *resultt = [waiting_array objectAtIndex:i];
                            CarObj *order = [self setAttributeWithDictionary:resultt];
                            [self.waittingCarsArr addObject:order];
                        }
                        [self setWaittingScrollViewContext];
                    }
                }
                //施工中
                if (![[order_dic objectForKey:@"1"]isKindOfClass:[NSNull class]] && [order_dic objectForKey:@"1"]!= nil) {
                    NSArray *working_array = [order_dic objectForKey:@"1"];
                    if (working_array.count>0) {
                        self.beginningCarsDic = [[NSMutableDictionary alloc]init];
                        for (int i=0; i<working_array.count; i++) {
                            NSDictionary *resultt = [working_array objectAtIndex:i];
                            CarObj *order = [self setAttributeWithDictionary:resultt];
                            [self.beginningCarsDic setObject:order forKey:order.stationId];
                        }
                        [self moveCarIntoCarPosion];
                    }
                }
                //等待付款
                if (![[order_dic objectForKey:@"2"]isKindOfClass:[NSNull class]] && [order_dic objectForKey:@"2"]!= nil) {
                    
                    NSArray *finish_array = [order_dic objectForKey:@"2"];
                    if (finish_array.count>0) {
                        self.finishedCarsArr = [[NSMutableArray alloc]init];
                        for (int i=0; i<finish_array.count; i++) {
                            NSDictionary *resultt = [finish_array objectAtIndex:i];
                            CarObj *order = [self setAttributeWithDictionary:resultt];
                            [self.finishedCarsArr addObject:order];
                        }
                        [self setFinishedScrollViewContext];
                    }
                }
            }
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
#pragma mark --
#pragma mark -- tableView 
static NSString *service_id = nil;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier =[NSString stringWithFormat:@"Cell%d%d",indexPath.section,indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    ServiceModel *service = (ServiceModel *)[self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = service.name;
    cell.detailTextLabel.text = service.price;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.carNumberTextField.textField resignFirstResponder];
    if (self.carNumberTextField.textField.text.length != 0) {
        ServiceModel *service = (ServiceModel *)[self.dataArray objectAtIndex:indexPath.row];
        service_id = [NSString stringWithFormat:@"%@",service.serviceId];
        if (service_id) {
            if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"]) {
                [Utils errorAlert:@"暂无网络!"];
            }else {
                [self isCarNum];
                if (self.is_car_num) {
                    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
                    hud.dimBackground = NO;
                    [hud showWhileExecuting:@selector(getServiceCar) onTarget:self withObject:nil animated:YES];
                    hud.labelText = @"正在玩命加载...";
                    [self.view addSubview:hud];
                }
            }
        }
    }else {
        [Utils errorAlert:@"请输入车牌号码!"];
    }
}
//判断输入的内容：车牌？电话号码？
-(void)isCarNum {
    NSString *regexCall = @"1[0-9]{10}";
    NSString *regexCall2 = @"[\u4E00-\u9FFF]+[A-Z0-9a-z]{6}";
    NSPredicate *predicateCall = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexCall];
    NSPredicate *predicateCall2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexCall2];
    if ([predicateCall evaluateWithObject:self.carNumberTextField.textField.text]) {
        self.is_car_num = @"0";//电话号码；
    }
    else if ([predicateCall2 evaluateWithObject:self.carNumberTextField.textField.text]) {
        self.is_car_num = @"1";//车牌号码；
    }
    else {
        self.is_car_num = nil;
    }
}
//status:1 有符合工位 2 没工位 3 多个工位 4 工位上暂无技师  5 多个车牌
-(void)getServiceCar {
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",kHost,kMakeOrder]];
    [r setPOSTDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[DataService sharedService].store_id,@"store_id",self.carNumberTextField.textField.text,@"num",[DataService sharedService].user_id,@"user_id",service_id,@"service_id",[NSString stringWithFormat:@"%@",self.is_car_num],@"is_car_num", nil]];
    [r setPostDataEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSString *str = [r startSynchronousWithError:&error];
    NSDictionary * result = [str objectFromJSONString];
    DLog(@"result = %@",result);
    if ([[result objectForKey:@"status"]intValue] == 5) {
        NSArray *array = [result objectForKey:@"car_nums"];
        if (array.count>0 && self.plateView == nil) {
            self.plateView = [[PlateVViewController alloc]initWithNibName:@"PlateVViewController" bundle:nil];
            self.plateView.view.frame = CGRectMake(810, 145, 0, 0);
            self.plateView.dataArray = array;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.35];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            self.plateView.view.frame = CGRectMake(810, 145, 200, 110);
            [self.view addSubview:self.plateView.view];
            [UIView commitAnimations];
        }
        
    }else if ([[result objectForKey:@"status"]intValue] == 2) {
        [Utils errorAlert:@"暂无工位!"];
    }else if ([[result objectForKey:@"status"]intValue] == 4) {
        [Utils errorAlert:@"工位上暂无技师!"];
    }else if ([[result objectForKey:@"status"]intValue] == 1) {
        NSDictionary *order_dic = [result objectForKey:@"orders"];
        //排队等候
        if (![[order_dic objectForKey:@"0"]isKindOfClass:[NSNull class]] && [order_dic objectForKey:@"0"]!= nil) {
            NSArray *waiting_array = [order_dic objectForKey:@"0"];
            if (waiting_array.count>0) {
                self.waittingCarsArr = [[NSMutableArray alloc]init];
                for (int i=0; i<waiting_array.count; i++) {
                    NSDictionary *resultt = [waiting_array objectAtIndex:i];
                    CarObj *order = [self setAttributeWithDictionary:resultt];
                    [self.waittingCarsArr addObject:order];
                }
                [self setWaittingScrollViewContext];
            }
        }
        //施工中
        if (![[order_dic objectForKey:@"1"]isKindOfClass:[NSNull class]] && [order_dic objectForKey:@"1"]!= nil) {
            NSArray *working_array = [order_dic objectForKey:@"1"];
            if (working_array.count>0) {
                self.beginningCarsDic = [[NSMutableDictionary alloc]init];
                for (int i=0; i<working_array.count; i++) {
                    NSDictionary *resultt = [working_array objectAtIndex:i];
                    CarObj *order = [self setAttributeWithDictionary:resultt];
                    [self.beginningCarsDic setObject:order forKey:order.stationId];
                }
                [self moveCarIntoCarPosion];
            }
        }
        //等待付款
        if (![[order_dic objectForKey:@"2"]isKindOfClass:[NSNull class]] && [order_dic objectForKey:@"2"]!= nil) {
            
            NSArray *finish_array = [order_dic objectForKey:@"2"];
            if (finish_array.count>0) {
                self.finishedCarsArr = [[NSMutableArray alloc]init];
                for (int i=0; i<finish_array.count; i++) {
                    NSDictionary *resultt = [finish_array objectAtIndex:i];
                    CarObj *order = [self setAttributeWithDictionary:resultt];
                    [self.finishedCarsArr addObject:order];
                }
                [self setFinishedScrollViewContext];
            }
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
//多个车牌
-(void)palteSelect:(NSNotification *)notification {
    NSDictionary *dic = [notification object];
    NSString *str = [dic objectForKey:@"name"];
    self.carNumberTextField.textField.text = str;
    [UIView animateWithDuration:0.35 animations:^{
        self.plateView.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.plateView.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.plateView.view removeFromSuperview];
            self.plateView = nil;
            
            self.is_car_num = @"1";//车牌号码；
            
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            hud.dimBackground = NO;
            [hud showWhileExecuting:@selector(getServiceCar) onTarget:self withObject:nil animated:YES];
            hud.labelText = @"正在玩命加载...";
            [self.view addSubview:hud];
        }
    }];
    
}
#pragma mark -
#pragma mark - 匹配车牌
-(void)addDataWithString:(NSString *)string  {
    NSMutableArray *tempArray = [NSMutableArray array];
    if ([DataService sharedService].matchArray.count >0) {
        int i=0;
        BOOL exit = NO;
        while (i<[DataService sharedService].matchArray.count) {
            NSString *str = [[DataService sharedService].matchArray objectAtIndex:i];
            if ([str isEqualToString:string]) {
                NSLog(@"在数组里");
                exit = YES;
                break;
            }
            i++;
        }
        if (exit == NO) {
            [tempArray addObject:string];
        }
    }else {
        [tempArray addObject:string];
    }
    if (tempArray.count>0) {
        [[DataService sharedService].matchArray addObjectsFromArray:tempArray];
        [DataService sharedService].sectionArray = [Utils matchArray];
    }
}
-(void)checkData {
    NSString *car = [self.carNumberTextField.textField.text substringToIndex:2];
    NSString *string = [self.carNumberTextField.textField.text substringToIndex:1];
    NSString *regexCall = @"[\u4E00-\u9FFF]+$";
    NSPredicate *predicateCall = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexCall];
    if ([predicateCall evaluateWithObject:string]) {
        NSRange range = NSMakeRange (1, 1);
        NSString *string2 = [self.carNumberTextField.textField.text substringWithRange:range];
        NSString *regexCall2 = @"[a-z A-Z]+$";
        NSPredicate *predicateCall2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexCall2];
        if ([predicateCall2 evaluateWithObject:string2]) {
            [self addDataWithString:car];
        }
    }
}
- (void)keyBoardWillHide:(id)sender{
    [UIView beginAnimations:nil context:nil];
    if (self.carNumberTextField.textField.text.length >2) {
        [self checkData];
    }
    [UIView commitAnimations];
}
-(void)textFieldChanged:(NSNotification *)sender {
    UITextField *txtField = (UITextField *)sender.object;
    
    if (txtField.text.length == 0) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [self.sxView.view removeFromSuperview];
        self.sxView = nil;
        [UIView commitAnimations];
        
    }else if (txtField.text.length == 1) {
        for (int i=0; i<self.letterArray.count; i++) {
            NSString *str = [self.letterArray objectAtIndex:i];
            if ([str isEqualToString:txtField.text] || ([[str lowercaseString] isEqualToString:txtField.text])) {
                NSArray *array = [[DataService sharedService].sectionArray objectAtIndex:i];
                if (array.count>0 && self.sxView == nil) {
                    self.sxView = [[ShaixuanView alloc]initWithNibName:@"ShaixuanView" bundle:nil];
                    self.sxView.view.frame = CGRectMake(810, 145, 0, 0);
                    self.sxView.dataArray = array;
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.35];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                    self.sxView.view.frame = CGRectMake(810, 145, 200, 110);
                    [self.view addSubview:self.sxView.view];
                    [UIView commitAnimations];
                    
                }
            }
        }
    }else if (txtField.text.length > 1) {
        [UIView animateWithDuration:0.35 animations:^{
            self.sxView.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
            self.sxView.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                [self.sxView.view removeFromSuperview];
                self.sxView = nil;
            }
        }];
    }
}
#pragma mark --
#pragma mark -- 付款
static NSString *order_id = nil;
-(void)pay {
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",kHost,kMakeOrder]];
    [r setPOSTDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[DataService sharedService].store_id,@"store_id",[DataService sharedService].user_id,@"user_id",order_id,@"order_code", nil]];
    [r setPostDataEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSString *str = [r startSynchronousWithError:&error];
    NSDictionary * result = [str objectFromJSONString];
    DLog(@"result = %@",result);
    if ([[result objectForKey:@"status"] intValue]==1) {
        PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:nil];
        payView.productList = [[NSMutableArray alloc]init];
        if ([result objectForKey:@"info"]) {
            payView.orderInfo = [result objectForKey:@"info"];
        }
        if ([result objectForKey:@"products"]) {
            [payView.productList addObjectsFromArray:[result objectForKey:@"products"]];
        }
        if ([result objectForKey:@"sales"]) {
            [payView.productList addObjectsFromArray:[result objectForKey:@"sales"]];
        }
        if ([result objectForKey:@"svcards"]) {
            [payView.productList addObjectsFromArray:[result objectForKey:@"svcards"]];
        }
        if ([result objectForKey:@"pcards"]) {
            [payView.productList addObjectsFromArray:[result objectForKey:@"pcards"]];
        }
        payView.total_count = [[result objectForKey:@"total"] floatValue];
        [self.navigationController pushViewController:payView animated:YES];
    }else {
        [Utils errorAlert:@"!"];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
-(void)payWithTag:(int)tag {
    if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"]) {
        [Utils errorAlert:@"暂无网络!"];
    }else {
        OrderModel *order = (OrderModel *)[self.waitPayArray objectAtIndex:tag];
        order_id = [NSString stringWithFormat:@"%@",order.orderId];
        if (order_id) {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            hud.dimBackground = NO;
            [hud showWhileExecuting:@selector(pay) onTarget:self withObject:nil animated:YES];
            hud.labelText = @"正在玩命加载...";
            [self.view addSubview:hud];
        }
    }
}
#pragma mark --
#pragma mark -- 调整工位

-(void)setStationWithTag1:(int)tag1 andTag2:(int)tag2  {
    OrderModel *order1 = (OrderModel *)[self.workingArray objectAtIndex:tag1];
    OrderModel *order2 = (OrderModel *)[self.workingArray objectAtIndex:tag2];
    
    
    
}
#pragma mark --
#pragma mark -- 手动等待付款

-(void)setWaitPay  {
    
}
@end
