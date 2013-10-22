//
//  PayViewController.m
//  LanTaiOrder
//
//  Created by Ruby on 13-3-3.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import "PayViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "ComplaintViewController.h"
#import "PayStyleViewController.h"
#import "CarObj.h"

#define OPEN 100
#define CLOSE 1000
@interface PayViewController ()<PayStyleViewDelegate>{
    PayStyleViewController *payStyleView;
    
}
@property (nonatomic,strong) NSMutableArray *waittingCarsArr;
@property (nonatomic,strong) NSMutableDictionary *beginningCarsDic;
@property (nonatomic,strong) NSMutableArray *finishedCarsArr;
@end

@implementation PayViewController

@synthesize lblCarNum,lblTotal,lblService;
@synthesize productTable,productList,orderInfo,total_count;
@synthesize segBtn,pleaseView,orderBgView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
- (void)rightTapped:(id)sender{
    [DataService sharedService].refreshing = YES;
    [self.navigationController popViewControllerAnimated:YES];
}
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
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [DataService sharedService].price_id = nil;
    [DataService sharedService].price_id = [NSMutableDictionary dictionary];
    [DataService sharedService].number_id = nil;
    [DataService sharedService].number_id = [NSMutableDictionary dictionary];
    [DataService sharedService].packageCard_dic = nil;
    [DataService sharedService].packageCard_dic = [NSMutableDictionary dictionary];
    //套餐卡
    [DataService sharedService].row_id_countArray = nil;
    [DataService sharedService].row_id_countArray =[NSMutableArray array];
    //活动打折卡
    [DataService sharedService].row_id_numArray = nil;
    [DataService sharedService].row_id_numArray =[NSMutableArray array];
    [DataService sharedService].productList = [NSMutableArray arrayWithArray:self.productList];
    //打折卡
    [DataService sharedService].row = nil;
    [DataService sharedService].row =[NSMutableArray array];
    
    //产品，服务
    [DataService sharedService].id_count_price = nil;
    [DataService sharedService].id_count_price =[NSMutableArray array];
    //活动
    [DataService sharedService].saleArray = nil;
    [DataService sharedService].saleArray =[NSMutableArray array];
    
    if ([DataService sharedService].payNumber == 1) {
        //评价，弹出框
        payStyleView = nil;
        payStyleView = [[PayStyleViewController alloc] initWithNibName:@"PayStyleViewController" bundle:nil];
        payStyleView.delegate = self;
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (![[orderInfo objectForKey:@"order_id"] isKindOfClass:[NSNull class]] && [orderInfo objectForKey:@"order_id"]!= nil) {
            [dic setObject:[orderInfo objectForKey:@"order_id"] forKey:@"order_id"];
        }else {
            [dic setObject:self.lblCarNum.text forKey:@"carNum"];
            [dic setObject:[orderInfo objectForKey:@"order_code"] forKey:@"code"];
        }
        self.payString = [self checkForm];
        [dic setObject:self.payString forKey:@"prods"];
        [dic setObject:[orderInfo objectForKey:@"order_code"] forKey:@"code"];
        [dic setObject:[NSNumber numberWithInt:0] forKey:@"is_please"];
        [dic setObject:[NSString stringWithFormat:@"%.2f",self.total_count] forKey:@"price"];
        
        payStyleView.order = [NSMutableDictionary dictionaryWithDictionary:dic];
        [self presentPopupViewController:payStyleView animationType:MJPopupViewAnimationSlideBottomBottom];
        
        [DataService sharedService].payNumber = 0;
    }
}
- (void)viewDidLoad
{
    self.segBtn.momentary = YES;
    //生成订单，插入正在进行中的订单
    [DataService sharedService].refreshing = YES;
    [DataService sharedService].first = YES;
    
    DLog(@"orderInfo = %@",self.orderInfo);
    self.lblCarNum.text = self.car_num;
    self.lblService.text = self.serviceName;
    self.lblTotal.text = [NSString stringWithFormat:@"总计：%.2f(元)",self.total_count];
    //更新总价
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTotal:) name:@"update_total" object:nil];
    //套餐卡
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:@"reloadTableView" object:nil];
    //活动
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saleReloadTableView:) name:@"saleReloadTableView" object:nil];
    //打折卡
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scardReloadTableView:) name:@"scardReloadTableView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saleReload:) name:@"saleReload" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(packageCardreloadTableView:) name:@"packageCardreloadTableView" object:nil];
    
    [super viewDidLoad];
    if (![self.navigationItem rightBarButtonItem]) {
        [self addRightnaviItemsWithImage:@"back"];
    }
    self.orderBgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"confirm_bg"]];
    
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBord)];
    //    [self.view addGestureRecognizer:tap];
}
-(void)hideKeyBord {
    NSArray *subViews = [self.productTable subviews];
    if (subViews.count >0) {
        for (UIView *v in subViews) {
            if ([v isKindOfClass:[UITableViewCell class]]) {
                UITableViewCell *cell = (UITableViewCell *)v;
                NSArray *subView = [cell.contentView subviews];
                if (subView.count>0) {
                    for (UIView *vv in subView) {
                        if ([vv isKindOfClass:[UITextField class]]) {
                            UITextField *txt = (UITextField *)vv;
                            [txt resignFirstResponder];
                        }
                    }
                }
                
            }
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [DataService sharedService].first = NO;
}
#pragma mark -  tabledelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //根据套餐卡相关产品的数量，设置cell 高度
    NSDictionary *product = [productList objectAtIndex:indexPath.row];
    int count = [[product objectForKey:@"products"] count];
    count = count == 0 ? 1 : count;
    return count * 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.productList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *product = [self.productList objectAtIndex:indexPath.row];
    //产品，服务
    if ([product objectForKey:@"id"] && ![product objectForKey:@"has_p_card"]) {
        if ([product objectForKey:@"count"]) {
            //第一次加载tableView
            if ([DataService sharedService].first == YES) {
                if ([[DataService sharedService].price_id objectForKey:[product objectForKey:@"id"]]) {
                    [[DataService sharedService].price_id removeObjectForKey:[product objectForKey:@"id"]];
                    [[DataService sharedService].number_id removeObjectForKey:[product objectForKey:@"id"]];
                }
                [[DataService sharedService].price_id setObject:[product objectForKey:@"price"] forKey:[product objectForKey:@"id"]];
                
                if ([DataService sharedService].package_product.count > 0) {
                    [[DataService sharedService].number_id setObject:@"0" forKey:[product objectForKey:@"id"]];
                    NSString *str = [NSString stringWithFormat:@"%@_%@_%.2f",[product objectForKey:@"id"],[product objectForKey:@"count"],[[product objectForKey:@"price"]floatValue]*[[product objectForKey:@"count"]intValue]];
                    [[DataService sharedService].id_count_price addObject:str];
                }else {
                    [[DataService sharedService].number_id setObject:[product objectForKey:@"count"] forKey:[product objectForKey:@"id"]];
                    NSString *str = [NSString stringWithFormat:@"%@_%@_%@",[product objectForKey:@"id"],[product objectForKey:@"count"],[product objectForKey:@"price"]];
                    [[DataService sharedService].id_count_price addObject:str];
                }
                
                
            }
        }
        static NSString *CellIdentifier = @"ServiceCell";
        ServiceCell *cell = (ServiceCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ServiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier with:product indexPath:indexPath type:1];
        }
        cell.lblName.text = [product objectForKey:@"name"];
        cell.lblPrice.text = [NSString stringWithFormat:@"%@",[product objectForKey:@"price"]];
        if ([product objectForKey:@"count"]) {
            cell.lblCount.text = [NSString stringWithFormat:@"%@",[product objectForKey:@"count"]];
            cell.stepBtn.value = [[product objectForKey:@"count"] doubleValue];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if([product objectForKey:@"sale_id"]){
        //活动
        NSString *CellIdentifier = [NSString stringWithFormat:@"SVCardCell%d", [indexPath row]];
        
        SVCardCell *cell = (SVCardCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[SVCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier with:product indexPath:indexPath];
        }
        cell.lblName.text = [product objectForKey:@"sale_name"];
        cell.lblPrice.text = [NSString stringWithFormat:@"%@",[product objectForKey:@"show_price"]];
        if ([[product objectForKey:@"selected"] intValue]== 0) {
            cell.switchBtn.tag = OPEN;
            [cell.switchBtn setImage:[UIImage imageNamed:@"cb_mono_on"] forState:UIControlStateNormal];
            
        }else{
            cell.switchBtn.tag = CLOSE;
            [cell.switchBtn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else if([product objectForKey:@"scard_id"]){
        //打折卡
        static NSString *CellIdentifier = @"SVCardCell";
        SVCardCell *cell = (SVCardCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[SVCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier with:product indexPath:indexPath];
        }
        
        if ([[product objectForKey:@"card_type"]intValue] == 0 && [[product objectForKey:@"is_new"]intValue] == 0) {
            cell.lblName.text = [NSString stringWithFormat:@"%@(%@)折",[product objectForKey:@"scard_name"],[product objectForKey:@"scard_discount"]];
            CGFloat xx = [[product objectForKey:@"show_price"]floatValue];
            cell.lblPrice.text = [NSString stringWithFormat:@"%.2f",xx];
            cell.switchBtn.hidden = NO;;
            //纪录打折卡位置
            NSMutableArray *mutableArray = [NSMutableArray array];
            if ([DataService sharedService].row.count>0) {
                BOOL exit = NO;
                int i=0;
                while (i <[DataService sharedService].row.count) {
                    int test = [[[DataService sharedService].row objectAtIndex:i]intValue];
                    if (test == indexPath.row) {
                        exit = YES;
                        break;
                    }
                    i++;
                }
                if (exit == NO) {
                    [mutableArray addObject:[NSString stringWithFormat:@"%d",indexPath.row]];
                }
            }else {
                [mutableArray addObject:[NSString stringWithFormat:@"%d",indexPath.row]];
            }
            if (mutableArray.count>0) {
                [[DataService sharedService].row addObjectsFromArray:mutableArray];
            }
            
            if ([[product objectForKey:@"selected"] intValue]== 0) {
                cell.switchBtn.tag = OPEN;
                [cell.switchBtn setImage:[UIImage imageNamed:@"cb_mono_on"] forState:UIControlStateNormal];
            }else{
                cell.switchBtn.tag = CLOSE;
                [cell.switchBtn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
            }
        }else {
            cell.lblName.text = [NSString stringWithFormat:@"%@",[product objectForKey:@"scard_name"]];
            CGFloat xx = [[product objectForKey:@"price"]floatValue];
            cell.lblPrice.text = [NSString stringWithFormat:@"%.2f",xx];
            cell.switchBtn.hidden = YES;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if([product objectForKey:@"products"]){
        //套餐卡
        NSString *CellIdentifier = [NSString stringWithFormat:@"PackageCardCell%d", [indexPath row]];
        PackageCardCell *cell = (PackageCardCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PackageCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier with:product indexPath:indexPath type:0];
        }
        NSArray *subViews = [cell subviews];
        for (UIView *v in subViews) {
            if ([v isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)v;
                NSString *tagStr = [NSString stringWithFormat:@"%d",btn.tag];
                if (tagStr.length == 3) {
                    int tag_x = btn.tag - OPEN;
                    NSDictionary *dic = [[product objectForKey:@"products"] objectAtIndex:tag_x];
                    if ([[dic objectForKey:@"selected"]intValue] == 1) {
                        [btn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
                        btn.tag = tag_x + CLOSE;
                        
                        UILabel *lab_prod = (UILabel *)[cell viewWithTag:tag_x+OPEN+OPEN];
                        lab_prod.text = [NSString stringWithFormat:@"%@(%@)次",[dic objectForKey:@"name"],[dic objectForKey:@"num"]];
                        lab_prod.tag = tag_x+CLOSE+CLOSE;
                    }else {
                        [btn setImage:[UIImage imageNamed:@"cb_mono_on"] forState:UIControlStateNormal];
                    }
                }
            }
        }
        if ([[product objectForKey:@"has_p_card"] integerValue]==0) {
            
            cell.lblName.text = [NSString stringWithFormat:@"%@",[product objectForKey:@"name"]];
            cell.lblPrice.text = [NSString stringWithFormat:@"%.2f",[[product objectForKey:@"price"] floatValue]];
        }else{
            
            cell.lblName.text = [product objectForKey:@"name"];
            cell.lblPrice.text = [NSString stringWithFormat:@"0.00"];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}
#pragma mark - 更新价格

- (void)updateTotal:(NSNotification *)notification{
    NSDictionary *dic = [notification object];
    //dic套餐卡剩余
    CGFloat f = 0;
    if (self.total_count == 0) {
        f = self.total_count_temp + [[dic objectForKey:@"object"] floatValue];
    }else {
        f = self.total_count + [[dic objectForKey:@"object"] floatValue];
    }
    
    if (f < 0) {
        self.total_count = 0.0;
        self.total_count_temp = f;
    }else {
        self.total_count = f;
        self.total_count_temp = f;
    }
    self.lblTotal.text = [NSString stringWithFormat:@"总计：%.2f(元)",self.total_count];
    NSIndexPath *idx = [dic objectForKey:@"idx"];
    [self.productList replaceObjectAtIndex:idx.row withObject:[dic objectForKey:@"prod"]];
    
    [DataService sharedService].productList = [NSMutableArray arrayWithArray:self.productList];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.productTable reloadData];
    });
}
- (NSString *)checkForm{
    NSMutableString *prod_ids = [NSMutableString string];
    int x=0,y=0,z=0;
    DLog(@"%@",self.productList);
    for (NSDictionary *product in self.productList) {
        if ([product objectForKey:@"id"] && ![product objectForKey:@"has_p_card"]){
            //服务
            NSMutableArray *tempArray = [NSMutableArray array];
            if ([DataService sharedService].id_count_price.count>0) {
                for (int i=0; i<[DataService sharedService].id_count_price.count; i++) {
                    NSMutableString *str = [[DataService sharedService].id_count_price objectAtIndex:i];
                    NSArray *arr = [str componentsSeparatedByString:@"_"];
                    NSString *p_id = [arr objectAtIndex:0];//产品id
                    if ([p_id intValue] == [[product objectForKey:@"id"]intValue]) {
                        if (![tempArray containsObject:p_id]) {
                            [prod_ids appendFormat:@"0_%@,",p_id];///////////////////
                            [tempArray addObject:p_id];
                        }
                    }
                }
            }
        }else if([product objectForKey:@"sale_id"] && [[product objectForKey:@"selected"] intValue] == 0){
            //活动
            x += 1;
            if ([DataService sharedService].saleArray.count>0) {
                for (int i=0; i<[DataService sharedService].saleArray.count; i++) {
                    NSMutableString *str = [[DataService sharedService].saleArray objectAtIndex:i];
                    NSArray *arr = [str componentsSeparatedByString:@"_"];
                    NSString *s_id = [arr objectAtIndex:0];//活动id
                    if ([s_id intValue] == [[product objectForKey:@"sale_id"] intValue]) {
                        [prod_ids appendFormat:@"1_%@_%.2f,",s_id,0-[[product objectForKey:@"show_price"]floatValue]];///////////////////////
                    }
                }
            }
            
        }else if([product objectForKey:@"scard_id"]){
            //打折卡,储值卡
            if ([[product objectForKey:@"is_new"] intValue] == 1) {
                if ([[product objectForKey:@"card_type"]intValue ] == 1) {
                    [prod_ids appendFormat:@"2_%d_%d_%d_%d,",[[product objectForKey:@"scard_id"] intValue],[[product objectForKey:@"card_type"] intValue],[[product objectForKey:@"is_new"] intValue],0];
                }else {
                    if ([[product objectForKey:@"selected"] intValue] == 0) {
                        y +=1;
                        [prod_ids appendFormat:@"2_%d_%d_%d_%.2f,",[[product objectForKey:@"scard_id"] intValue],[[product objectForKey:@"card_type"] intValue],[[product objectForKey:@"is_new"] intValue],0-[[product objectForKey:@"show_price"]floatValue]];
                    }else {
                        [prod_ids appendFormat:@"2_%d_%d_%d_%d,",[[product objectForKey:@"scard_id"] intValue],[[product objectForKey:@"card_type"] intValue],[[product objectForKey:@"is_new"] intValue],0];
                    }
                    
                }
            }else {
                if ([[product objectForKey:@"selected"] intValue] == 0) {
                    y +=1;
                    [prod_ids appendFormat:@"2_%d_%.2f,",[[product objectForKey:@"scard_id"] intValue],0-[[product objectForKey:@"show_price"]floatValue]];///////
                }
            }
            
        }else if([product objectForKey:@"products"]){
            //套餐卡
            //            NSMutableString *p_str = [NSMutableString string];
            //            for (NSDictionary *pro in [product objectForKey:@"products"]) {
            //                if([[pro objectForKey:@"selected"] intValue]==0){
            //
            //                    int num = [[pro objectForKey:@"Total_num"]intValue] - [[pro objectForKey:@"num"]intValue];
            //                    [p_str appendFormat:@"%d=%d-",[[pro objectForKey:@"product_id"] intValue],num];
            //                }
            //            }
            z += 1;
            int has_pcard = [[product objectForKey:@"has_p_card"] intValue];
            if (has_pcard == 0) {
                [prod_ids appendFormat:@"3_%d,",[[product objectForKey:@"id"] intValue]];
            }else {
                [prod_ids appendFormat:@"3_%d",[[product objectForKey:@"id"] intValue]];
            }
        }
    }
    if (x>1 || y>1) {
        return @"";
    }
    return prod_ids;
}


- (IBAction)clickSegBtn:(UISegmentedControl *)sender{
    self.segBtn = (UISegmentedControl *)sender;
    //评价，不满意
    if (sender.selectedSegmentIndex == 0) {
        ComplaintViewController *complaint = [[ComplaintViewController alloc] initWithNibName:@"ComplaintViewController" bundle:nil];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:self.lblCarNum.text forKey:@"carNum"];
        [dic setObject:[orderInfo objectForKey:@"order_code"] forKey:@"code"];
        if (![[orderInfo objectForKey:@"order_id"] isKindOfClass:[NSNull class]] && [orderInfo objectForKey:@"order_id"]!= nil){
            [dic setObject:[orderInfo objectForKey:@"order_id"] forKey:@"order_id"];
        }
        [dic setObject:@"0" forKey:@"from"];
        [dic setObject:self.lblService.text forKey:@"prods"];
        complaint.info = [NSMutableDictionary dictionaryWithDictionary:dic];
        [self.navigationController pushViewController:complaint animated:YES];
    }else if (sender.selectedSegmentIndex == 1 || sender.selectedSegmentIndex == 2 || sender.selectedSegmentIndex == 3){
        self.payString = [self checkForm];
        DLog(@"pay = %@",self.payString);
        //评价，弹出框
        payStyleView = nil;
        payStyleView = [[PayStyleViewController alloc] initWithNibName:@"PayStyleViewController" bundle:nil];
        payStyleView.delegate = self;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[orderInfo objectForKey:@"order_id"] forKey:@"order_id"];
        [dic setObject:self.lblCarNum.text forKey:@"carNum"];
        [dic setObject:self.payString forKey:@"prods"];
        [dic setObject:[NSNumber numberWithInt:sender.selectedSegmentIndex] forKey:@"is_please"];
        [dic setObject:[NSString stringWithFormat:@"%.2f",self.total_count] forKey:@"price"];
        
        payStyleView.order = [NSMutableDictionary dictionaryWithDictionary:dic];
        
        [self presentPopupViewController:payStyleView animationType:MJPopupViewAnimationSlideBottomBottom];
    }else {
        [AHAlertView applyCustomAlertAppearance];
        AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:@"确定取消订单？"];
        __block AHAlertView *alert = alertt;
        [alertt setCancelButtonTitle:@"取消" block:^{
            alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
            alert = nil;
        }];
        [alertt addButtonWithTitle:@"确定" block:^{
            alert.dismissalStyle = AHAlertViewDismissalStyleZoomDown;
            alert = nil;
            //取消订单
            if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"]) {
                [Utils errorAlert:@"暂无网络!"];
            }else {//有网
                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
                hud.dimBackground = NO;
                [hud showWhileExecuting:@selector(cancleOrderr) onTarget:self withObject:nil animated:YES];
                hud.labelText = @"正在努力加载...";
                [self.view addSubview:hud];
            }
        }];
        [alertt show];
    }
}
#pragma mark -取消订单（排队等待中）
-(void)cancleOrderr {
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",kHost,kPayOrder]];
    [r setPOSTDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[orderInfo objectForKey:@"order_id"],@"order_id",@"1",@"opt_type",[DataService sharedService].store_id,@"store_id", nil]];
    [r setPostDataEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *result = [[r startSynchronousWithError:&error] objectFromJSONString];
    if ([[result objectForKey:@"status"] intValue]==1) {
        
        [AHAlertView applyCustomAlertAppearance];
        AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:@"订单已取消"];
        __block AHAlertView *alert = alertt;
        [alertt setCancelButtonTitle:@"确定" block:^{
            alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
            alert = nil;
            NSDictionary *order_dic = [result objectForKey:@"orders"];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
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
                    [dic setObject:self.waittingCarsArr forKey:@"wait"];
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
                    [dic setObject:self.beginningCarsDic forKey:@"work"];
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
                    [dic setObject:self.finishedCarsArr forKey:@"finish"];
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadArray" object:dic];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        [alertt show];
        
    }else{
        [Utils errorAlert:@"订单取消失败"];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)closePopVieww:(PayStyleViewController *)payStyleViewController{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomTop];
    if (payStyleViewController.isSuccess) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        if (payStyleViewController.waittingCarsArr.count>0) {
            [dic setObject:payStyleViewController.waittingCarsArr forKey:@"wait"];
        }
        if (payStyleViewController.beginningCarsDic.allKeys.count>0) {
            [dic setObject:payStyleViewController.beginningCarsDic forKey:@"work"];
        }
        if (payStyleViewController.finishedCarsArr.count>0) {
            [dic setObject:payStyleViewController.finishedCarsArr forKey:@"finish"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadArray" object:dic];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    payStyleView = nil;
}
#pragma mark - 套餐卡通知

- (void)reloadTableView:(NSNotification *)notification{
    NSDictionary *dic = [notification object];
    NSString * product_id = [dic objectForKey:@"id"];//服务／产品的id
    
    NSMutableArray *p_arr = nil;;
    NSMutableDictionary *p_dic;
    
    CGFloat y = 0;
    NSArray *array = [[DataService sharedService].number_id allKeys];
    if ([array containsObject:product_id]) {
        
        int num_count = 0;
        int index_row = 0;
        int num = 0;
        //从找到row_id_countArray数组中找到产品id
        if ([DataService sharedService].row_id_countArray.count >0) {
            NSMutableArray *collection_temp = [NSMutableArray array];//纪录[DataService sharedService].row_id_countArray里面要删除的元素
            for (int i=0; i<[DataService sharedService].row_id_countArray.count; i++) {
                NSString *str = [[DataService sharedService].row_id_countArray objectAtIndex:i];
                NSArray *arr = [str componentsSeparatedByString:@"_"];
                
                int p_id = [[arr objectAtIndex:1]intValue];//放在单列里面消费的服务/产品id
                if (p_id == [product_id intValue]) {//id相同
                    //通过id找到index
                    index_row = [[arr objectAtIndex:0]intValue];
                    //通过index找到cell
                    NSIndexPath *idx = [NSIndexPath indexPathForRow:index_row inSection:0];
                    NSMutableDictionary *product_dic = [NSMutableDictionary dictionaryWithDictionary:[[DataService sharedService].productList objectAtIndex:index_row]];
                    PackageCardCell *cell = (PackageCardCell *)[self.productTable cellForRowAtIndexPath:idx];
                    CGFloat x = [cell.lblPrice.text floatValue];
                    
                    p_arr = [NSMutableArray arrayWithArray:[product_dic objectForKey:@"products"]];
                    //                    DLog(@"p_arr = %@",p_arr);
                    
                    for (int j=0; j<p_arr.count; j++) {
                        
                        p_dic = [[p_arr objectAtIndex:j] mutableCopy];
                        NSString * pro_id = [p_dic objectForKey:@"product_id"];//套餐卡包含的服务/产品id
                        
                        if ([product_id intValue] == [pro_id intValue]) {//id相同  找到服务  产品
                            UIButton *btn = (UIButton *)[cell viewWithTag:OPEN+j];
                            num = [[p_dic objectForKey:@"num"]intValue];//套餐卡剩余次数
                            
                            y = [[dic objectForKey:@"price"] floatValue];//服务／产品的  单价
                            num_count = [[arr objectAtIndex:2]intValue];//放在单列里面此id产品消费次数
                            y = y * num_count;
                            x =x + y ;
                            
                            //重置temp—dic数据
                            int count_num = [[[DataService sharedService].number_id objectForKey:product_id]intValue];//剩余次数
                            [[DataService sharedService].number_id removeObjectForKey:product_id];
                            [[DataService sharedService].number_id setObject:[NSString stringWithFormat:@"%d", num_count+count_num] forKey:product_id];
                            //                            DLog(@"dic = %@",[DataService sharedService].number_id);
                            
                            [p_dic setObject:[NSString stringWithFormat:@"%d",num + num_count] forKey:@"num"];
                            [p_dic setValue:@"1" forKey:@"selected"];
                            [p_arr replaceObjectAtIndex:j withObject:p_dic];
                            
                            int tag = btn.tag;
                            
                            UILabel *lab_prod = (UILabel *)[cell viewWithTag:btn.tag+OPEN];
                            lab_prod.text = [NSString stringWithFormat:@"%@(%@)次",[p_dic objectForKey:@"name"],[p_dic objectForKey:@"num"]];
                            lab_prod.tag = btn.tag- OPEN + CLOSE+ CLOSE;
                            
                            btn.tag = tag - OPEN + CLOSE;
                            [btn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
                            
                            NSString *price = [NSString stringWithFormat:@"%.2f",x];
                            [product_dic setObject:p_arr forKey:@"products"];
                            
                            [product_dic setObject:price forKey:@"show_price"];
                            
                            NSString *p = [NSString stringWithFormat:@"%.2f",y];
                            NSMutableDictionary *dic1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:p,@"object",product_dic,@"prod",idx,@"idx",@"2",@"type", nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"update_total" object:dic1];
                            
                            //删除
                            [collection_temp addObject:[[DataService sharedService].row_id_countArray objectAtIndex:i]];
                        }
                    }
                }
            }
            //删除
            if (collection_temp.count>0) {
                [[DataService sharedService].row_id_countArray removeObjectsInArray:collection_temp];
                DLog(@"删除222 row_id_countArray = %@",[DataService sharedService].row_id_countArray);
            }
        }
    }
}

- (void)packageCardreloadTableView:(NSNotification *)notification{
    NSDictionary *pp_dic = [notification object];
    NSArray *productArray = [pp_dic objectForKey:@"product"];
    if (productArray.count>0) {
        for (int i=0; i<productArray.count; i++) {
            NSDictionary *dic = [productArray objectAtIndex:i];
            NSString * product_id = [dic objectForKey:@"product_id"];//服务／产品的id
            
            NSMutableArray *p_arr = nil;;
            NSMutableDictionary *p_dic;
            
            CGFloat y = 0;
            NSArray *array = [[DataService sharedService].number_id allKeys];
            if ([array containsObject:product_id]) {
                
                y = [[[DataService sharedService].price_id objectForKey:product_id] floatValue];//服务／产品的  单价
                int num_count = 0;
                int index_row = 0;
                int num = 0;
                
                BOOL changeing = NO;
                //从找到row_id_countArray数组中找到产品id
                if ([DataService sharedService].row_id_countArray.count >0) {
                    for (int i=0; i<[DataService sharedService].row_id_countArray.count; i++) {
                        NSString *str = [[DataService sharedService].row_id_countArray objectAtIndex:i];
                        NSArray *arr = [str componentsSeparatedByString:@"_"];
                        
                        int p_id = [[arr objectAtIndex:1]intValue];//放在单列里面消费的服务/产品id
                        if (p_id == [product_id intValue]) {
                            int iddx = [[arr objectAtIndex:0]intValue];
                            NSMutableDictionary *product_dic = [[DataService sharedService].productList objectAtIndex:iddx];
                            NSArray * pp_arr = [product_dic objectForKey:@"products"];
                            for (NSDictionary *pp_dic in pp_arr) {
                                int ppro_id = [[pp_dic objectForKey:@"product_id"]intValue];
                                if ([product_id intValue] == ppro_id) {
                                    int num_package = [[pp_dic objectForKey:@"num"]intValue];//套餐卡剩余次数
                                    int count_num = [[[DataService sharedService].number_id objectForKey:product_id]intValue];//剩余次数
                                    if (count_num>0 && num_package>0) {
                                        changeing = YES;
                                    }
                                }
                            }
                        }
                    }
                }
                
                if (changeing) {
                    NSMutableArray *collection_temp = [NSMutableArray array];//纪录[DataService sharedService].row_id_countArray里面要删除的元素
                    for (int i=0; i<[DataService sharedService].row_id_countArray.count; i++) {
                        NSString *str = [[DataService sharedService].row_id_countArray objectAtIndex:i];
                        NSArray *arr = [str componentsSeparatedByString:@"_"];
                        
                        int p_id = [[arr objectAtIndex:1]intValue];//放在单列里面消费的服务/产品id
                        if (p_id == [product_id intValue]) {//id相同
                            //通过id找到index
                            index_row = [[arr objectAtIndex:0]intValue];
                            //通过index找到cell
                            NSIndexPath *idx = [NSIndexPath indexPathForRow:index_row inSection:0];
                            NSMutableDictionary *product_dic = [[DataService sharedService].productList objectAtIndex:index_row];
                            PackageCardCell *cell = (PackageCardCell *)[self.productTable cellForRowAtIndexPath:idx];
                            CGFloat x = [cell.lblPrice.text floatValue];
                            
                            p_arr = [product_dic objectForKey:@"products"];
                            for (int j=0; j<p_arr.count; j++) {
                                p_dic = [[p_arr objectAtIndex:j] mutableCopy];
                                NSString * pro_id = [p_dic objectForKey:@"product_id"];//套餐卡包含的服务/产品id
                                
                                if ([product_id intValue] == [pro_id intValue]) {//id相同  找到服务  产品
                                    UIButton *btn = (UIButton *)[cell viewWithTag:OPEN+j];
                                    num = [[p_dic objectForKey:@"num"]intValue];//套餐卡剩余次数
                                    
                                    num_count = [[arr objectAtIndex:2]intValue];//放在单列里面此id产品消费次数
                                    y = y * num_count;
                                    x =x + y ;
                                    
                                    //重置temp—dic数据
                                    int count_num = [[[DataService sharedService].number_id objectForKey:product_id]intValue];//剩余次数
                                    [[DataService sharedService].number_id removeObjectForKey:product_id];
                                    [[DataService sharedService].number_id setObject:[NSString stringWithFormat:@"%d", num_count+count_num] forKey:product_id];
                                    //                                    DLog(@"dic = %@",[DataService sharedService].number_id);
                                    
                                    [p_dic setObject:[NSString stringWithFormat:@"%d",num + num_count] forKey:@"num"];
                                    [p_dic setValue:@"1" forKey:@"selected"];
                                    [p_arr replaceObjectAtIndex:j withObject:p_dic];
                                    
                                    int tag = btn.tag;
                                    
                                    UILabel *lab_prod = (UILabel *)[cell viewWithTag:btn.tag+OPEN];
                                    lab_prod.text = [NSString stringWithFormat:@"%@(%@)次",[p_dic objectForKey:@"name"],[p_dic objectForKey:@"num"]];
                                    lab_prod.tag = btn.tag- OPEN + CLOSE+ CLOSE;
                                    
                                    btn.tag = tag - OPEN + CLOSE;
                                    [btn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
                                    
                                    NSString *price = [NSString stringWithFormat:@"%.2f",x];
                                    //                            cell.lblPrice.text = price;
                                    [product_dic setObject:p_arr forKey:@"products"];
                                    
                                    [product_dic setObject:price forKey:@"show_price"];
                                    
                                    NSString *p = [NSString stringWithFormat:@"%.2f",y];
                                    NSMutableDictionary *dic1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:p,@"object",product_dic,@"prod",idx,@"idx",@"2",@"type", nil];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"update_total" object:dic1];
                                    
                                    //删除
                                    [collection_temp addObject:[[DataService sharedService].row_id_countArray objectAtIndex:i]];
                                }
                            }
                        }
                    }
                    //删除
                    if (collection_temp.count>0) {
                        [[DataService sharedService].row_id_countArray removeObjectsInArray:collection_temp];
                    }
                }
            }
        }
    }
}
#pragma mark - 活动通知
- (void)saleReloadTableView:(NSNotification *)notification{
    NSDictionary *dic = [notification object];
    NSString * product_id = [dic objectForKey:@"id"];//服务／产品的id
    
    NSMutableArray *collection_index = [NSMutableArray array];//单个活动消费的产品index集合
    NSMutableArray *collection_id = [NSMutableArray array];//单个活动消费的产品id集合
    NSMutableArray *collection_number = [NSMutableArray array];//单个活动消费的产品number集合
    NSMutableArray *collection = [NSMutableArray array];//纪录位置
    NSMutableArray *collection2 = [NSMutableArray array];//纪录位置
    
    NSMutableArray *p_arr = nil;
    NSMutableDictionary *p_dic=nil;
    
    CGFloat discount_x = 0;
    CGFloat discount_y = 0;
    
    NSArray *array = [[DataService sharedService].number_id allKeys];
    if ([array containsObject:product_id]) {
        discount_x = [[dic objectForKey:@"price"] floatValue];//服务／产品的  单价
        int num_count = 0;//放在单列里面此id产品消费次数
        int index_row = 0;
        int num = 0;//活动里面剩余次数
        if ([DataService sharedService].row_id_numArray.count >0) {
            for (int i=0; i<[DataService sharedService].row_id_numArray.count; i++) {
                NSMutableString *str = [[DataService sharedService].row_id_numArray objectAtIndex:i];
                str = [NSMutableString stringWithString:[str substringToIndex:str.length-1]];
                NSArray *arr = [str componentsSeparatedByString:@"_"];
                [collection_index addObject:[arr objectAtIndex:0]];
                [collection_id addObject:[arr objectAtIndex:1]];
                [collection_number addObject:[arr objectAtIndex:2]];
                
            }
        }
        //遍历 id的集合找到位置
        for (int i=0; i<collection_id.count; i++) {
            NSString *prod_id = [collection_id objectAtIndex:i];
            if ([product_id intValue] == [prod_id intValue]) {
                [collection addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
        NSMutableArray *collection_temp = [NSMutableArray array];//纪录[DataService sharedService].row_id_numArray里面要删除的元素
        NSMutableArray *sale_tempArray = [NSMutableArray array];//纪录活动里面需要删除的数据
        if (collection.count>0) {
            for (int i=0; i<collection.count; i++) {
                int h = [[collection objectAtIndex:i]intValue];//位置
                //根据位置找到index
                index_row = [[collection_index objectAtIndex:h]intValue];
                //通过index找到的活动
                NSMutableDictionary *product_dic = [[DataService sharedService].productList objectAtIndex:index_row];
                
                discount_y = 0-[[product_dic objectForKey:@"show_price"]floatValue];//差价
                //通过index找到cell
                NSIndexPath *idx = [NSIndexPath indexPathForRow:index_row inSection:0];
                SVCardCell *cell = (SVCardCell *)[self.productTable cellForRowAtIndexPath:idx];
                
                p_arr = [product_dic objectForKey:@"sale_products"];//活动里面产品的集合
                for (int k=0; k<p_arr.count; k++) {
                    p_dic = [[p_arr objectAtIndex:k] mutableCopy];
                    NSString * pro_id = [p_dic objectForKey:@"product_id"];//活动包含的服务/产品id
                    /////////////////////////////////////////////////////////////////////////////
                    num = [[p_dic objectForKey:@"prod_num"]intValue];//活动里面剩余次数
                    
                    if ([pro_id intValue] == [product_id intValue]) {//id相同,找到服务,产品
                        num_count = [[collection_number objectAtIndex:h]intValue];//放在单列里面此id产品消费次数
                        if ([DataService sharedService].saleArray.count>0) {
                            for (int i=0; i<[DataService sharedService].saleArray.count; i++) {
                                NSMutableString *str = [[DataService sharedService].saleArray objectAtIndex:i];
                                NSArray *arr = [str componentsSeparatedByString:@"_"];
                                NSString *s_id = [arr objectAtIndex:0];//活动id
                                if ([s_id intValue] == [[product_dic objectForKey:@"sale_id"] intValue]) {
                                    [sale_tempArray addObject:[[DataService sharedService].saleArray objectAtIndex:i]];
                                }
                            }
                        }
                        
                        //重置number_id数据
                        int count_num = [[[DataService sharedService].number_id objectForKey:product_id]intValue];//剩余次数
                        
                        [[DataService sharedService].number_id removeObjectForKey:product_id];
                        [[DataService sharedService].number_id setObject:[NSString stringWithFormat:@"%d", num_count+count_num] forKey:product_id];
                        
                        [p_dic setObject:[NSString stringWithFormat:@"%d",num + num_count] forKey:@"prod_num"];
                        [p_arr replaceObjectAtIndex:k withObject:p_dic];
                        //删除
                        [collection_temp addObject:[[DataService sharedService].row_id_numArray objectAtIndex:h]];
                    }else {
                        //遍历 id的集合找到位置
                        for (int m=0; m<collection_id.count; m++) {
                            NSString *prod_id = [collection_id objectAtIndex:m];
                            if ([prod_id intValue] == [pro_id intValue]) {
                                [collection2 addObject:[NSString stringWithFormat:@"%d",m]];
                            }
                        }
                        if (collection2.count>0) {
                            for (int j=0; j<collection2.count; j++) {
                                int d = [[collection2 objectAtIndex:j]intValue];
                                NSString *sale_index = [collection_index objectAtIndex:d];
                                if ([sale_index intValue] == index_row) {
                                    num_count = [[collection_number objectAtIndex:d]intValue];//放在单列里面此id产品消费次数
                                    
                                    if ([DataService sharedService].saleArray.count>0) {
                                        for (int i=0; i<[DataService sharedService].saleArray.count; i++) {
                                            NSMutableString *str = [[DataService sharedService].saleArray objectAtIndex:i];
                                            NSArray *arr = [str componentsSeparatedByString:@"_"];
                                            NSString *s_id = [arr objectAtIndex:0];//活动id
                                            if ([s_id intValue] == [[product_dic objectForKey:@"sale_id"] intValue]) {
                                                [sale_tempArray addObject:[[DataService sharedService].saleArray objectAtIndex:i]];
                                            }
                                        }
                                    }
                                    
                                    //重置number_id数据
                                    int count_num = [[[DataService sharedService].number_id objectForKey:pro_id]intValue];//剩余次数
                                    [[DataService sharedService].number_id removeObjectForKey:pro_id];
                                    [[DataService sharedService].number_id setObject:[NSString stringWithFormat:@"%d", num_count+count_num] forKey:pro_id];
                                    
                                    [p_dic setObject:[NSString stringWithFormat:@"%d",num + num_count] forKey:@"prod_num"];
                                    [p_arr replaceObjectAtIndex:k withObject:p_dic];
                                    //删除
                                    [collection_temp addObject:[[DataService sharedService].row_id_numArray objectAtIndex:d]];
                                }
                            }
                        }
                    }
                }
                UIButton *btn =(UIButton *)[cell viewWithTag:OPEN];
                int tag = btn.tag;
                btn.tag = tag - OPEN + CLOSE;
                [btn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
                
                CGFloat lbl_price = [cell.lblPrice.text floatValue];
                if ((lbl_price+discount_y) <0.0001f ) {
                    cell.lblPrice.text = @"0";
                }else {
                    cell.lblPrice.text = [NSString stringWithFormat:@"%.2f",discount_y+lbl_price];
                }
                [product_dic setValue:@"1" forKey:@"selected"];
                [product_dic setObject:p_arr forKey:@"sale_products"];
                //////////////////////////////////////////////////////////////////////////////
                [product_dic setObject:@"0" forKey:@"show_price"];
                
                NSString *p = [NSString stringWithFormat:@"%.2f",discount_y];
                NSMutableDictionary *dic1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:p,@"object",product_dic,@"prod",idx,@"idx",@"2",@"type", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"update_total" object:dic1];
            }
        }
        if (collection_temp.count>0) {
            [[DataService sharedService].row_id_numArray removeObjectsInArray:collection_temp];
        }
        if (sale_tempArray.count>0) {
            [[DataService sharedService].saleArray removeObjectsInArray:sale_tempArray];
        }
    }
}
- (void)saleReload:(NSNotification *)notification{
    NSDictionary *dic = [notification object];
    NSString * product_id = [dic objectForKey:@"id"];//服务／产品的id
    
    NSMutableArray *collection_index = [NSMutableArray array];//单个活动消费的产品index集合
    NSMutableArray *collection_id = [NSMutableArray array];//单个活动消费的产品id集合
    NSMutableArray *collection_number = [NSMutableArray array];//单个活动消费的产品number集合
    NSMutableArray *collection = [NSMutableArray array];//纪录位置
    NSMutableArray *collection2 = [NSMutableArray array];//纪录位置
    
    NSMutableArray *p_arr = nil;
    NSMutableDictionary *p_dic=nil;
    
    CGFloat discount_x = 0;
    CGFloat discount_y = 0;
    
    NSArray *array = [[DataService sharedService].number_id allKeys];
    if ([array containsObject:product_id]) {
        discount_x = [[dic objectForKey:@"price"] floatValue];//服务／产品的  单价
        int num_count = 0;//放在单列里面此id产品消费次数
        int index_row = 0;
        int num = 0;//活动里面剩余次数
        if ([DataService sharedService].row_id_numArray.count >0) {
            for (int i=0; i<[DataService sharedService].row_id_numArray.count; i++) {
                NSMutableString *str = [[DataService sharedService].row_id_numArray objectAtIndex:i];
                str = [NSMutableString stringWithString:[str substringToIndex:str.length-1]];
                NSArray *arr = [str componentsSeparatedByString:@"_"];
                [collection_index addObject:[arr objectAtIndex:0]];
                [collection_id addObject:[arr objectAtIndex:1]];
                [collection_number addObject:[arr objectAtIndex:2]];
                
            }
        }
        //遍历 id的集合找到位置
        for (int i=0; i<collection_id.count; i++) {
            NSString *prod_id = [collection_id objectAtIndex:i];
            if ([product_id intValue] == [prod_id intValue]) {
                [collection addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
        NSMutableArray *collection_temp = [NSMutableArray array];//纪录row_id_numArray里面要删除的元素
        NSMutableArray *sale_tempArray = [NSMutableArray array];//纪录活动里面需要删除的数据
        
        BOOL changeing = NO;
        if (collection.count>0) {
            for (int i=0; i<collection.count; i++) {
                int h = [[collection objectAtIndex:i]intValue];//位置
                //根据位置找到index
                int iddx = [[collection_index objectAtIndex:h]intValue];
                //通过index找到的活动
                NSMutableDictionary *product_dic = [[DataService sharedService].productList objectAtIndex:iddx];
                NSArray * pp_arr = [product_dic objectForKey:@"sale_products"];//活动里面产品的集合
                for (NSDictionary *pro_dic in pp_arr) {
                    int pp_id = [[pro_dic objectForKey:@"product_id"]intValue];
                    if ([product_id intValue] == pp_id) {
                        int num_sale = [[pro_dic objectForKey:@"prod_num"]intValue];//活动里面剩余次数
                        int count_num = [[[DataService sharedService].number_id objectForKey:product_id]intValue];//剩余次数
                        if (count_num>0 && num_sale>0) {
                            changeing = YES;
                        }
                    }
                }
            }
        }
        
        if (changeing) {
            for (int i=0; i<collection.count; i++) {
                int h = [[collection objectAtIndex:i]intValue];//位置
                //根据位置找到index
                index_row = [[collection_index objectAtIndex:h]intValue];
                //通过index找到的活动
                NSMutableDictionary *product_dic = [[DataService sharedService].productList objectAtIndex:index_row];
                
                discount_y = 0-[[product_dic objectForKey:@"show_price"]floatValue];//差价
                //通过index找到cell
                NSIndexPath *idx = [NSIndexPath indexPathForRow:index_row inSection:0];
                SVCardCell *cell = (SVCardCell *)[self.productTable cellForRowAtIndexPath:idx];
                
                p_arr = [product_dic objectForKey:@"sale_products"];//活动里面产品的集合
                
                for (int k=0; k<p_arr.count; k++) {
                    p_dic = [[p_arr objectAtIndex:k] mutableCopy];
                    NSString * pro_id = [p_dic objectForKey:@"product_id"];//活动包含的服务/产品id
                    num = [[p_dic objectForKey:@"prod_num"]intValue];//活动里面剩余次数
                    if ([pro_id intValue] == [product_id intValue]) {//id相同,找到服务,产品
                        //重置number_id数据
                        int count_num = [[[DataService sharedService].number_id objectForKey:product_id]intValue];//剩余次数
                        
                        num_count = [[collection_number objectAtIndex:h]intValue];//放在单列里面此id产品消费次数
                        if ([DataService sharedService].saleArray.count>0) {
                            for (int i=0; i<[DataService sharedService].saleArray.count; i++) {
                                NSMutableString *str = [[DataService sharedService].saleArray objectAtIndex:i];
                                NSArray *arr = [str componentsSeparatedByString:@"_"];
                                NSString *s_id = [arr objectAtIndex:0];//活动id
                                if ([s_id intValue] == [[product_dic objectForKey:@"sale_id"] intValue]) {
                                    [sale_tempArray addObject:[[DataService sharedService].saleArray objectAtIndex:i]];
                                }
                            }
                        }
                        
                        [[DataService sharedService].number_id removeObjectForKey:product_id];
                        [[DataService sharedService].number_id setObject:[NSString stringWithFormat:@"%d", num_count+count_num] forKey:product_id];
                        
                        [p_dic setObject:[NSString stringWithFormat:@"%d",num + num_count] forKey:@"prod_num"];
                        [p_arr replaceObjectAtIndex:k withObject:p_dic];
                        //删除
                        [collection_temp addObject:[[DataService sharedService].row_id_numArray objectAtIndex:h]];
                    }else {
                        //遍历 id的集合找到位置
                        for (int m=0; m<collection_id.count; m++) {
                            NSString *prod_id = [collection_id objectAtIndex:m];
                            if ([prod_id intValue] == [pro_id intValue]) {
                                [collection2 addObject:[NSString stringWithFormat:@"%d",m]];
                            }
                        }
                        if (collection2.count>0) {
                            for (int j=0; j<collection2.count; j++) {
                                int d = [[collection2 objectAtIndex:j]intValue];
                                NSString *sale_index = [collection_index objectAtIndex:d];
                                if ([sale_index intValue] == index_row) {
                                    num_count = [[collection_number objectAtIndex:d]intValue];//放在单列里面此id产品消费次数
                                    
                                    if ([DataService sharedService].saleArray.count>0) {
                                        for (int i=0; i<[DataService sharedService].saleArray.count; i++) {
                                            NSMutableString *str = [[DataService sharedService].saleArray objectAtIndex:i];
                                            NSArray *arr = [str componentsSeparatedByString:@"_"];
                                            NSString *s_id = [arr objectAtIndex:0];//活动id
                                            if ([s_id intValue] == [[product_dic objectForKey:@"sale_id"] intValue]) {
                                                [sale_tempArray addObject:[[DataService sharedService].saleArray objectAtIndex:i]];
                                            }
                                        }
                                    }
                                    
                                    //重置number_id数据
                                    int count_num = [[[DataService sharedService].number_id objectForKey:pro_id]intValue];//剩余次数
                                    [[DataService sharedService].number_id removeObjectForKey:pro_id];
                                    [[DataService sharedService].number_id setObject:[NSString stringWithFormat:@"%d", num_count+count_num] forKey:pro_id];
                                    
                                    [p_dic setObject:[NSString stringWithFormat:@"%d",num + num_count] forKey:@"prod_num"];
                                    [p_arr replaceObjectAtIndex:k withObject:p_dic];
                                    //删除
                                    [collection_temp addObject:[[DataService sharedService].row_id_numArray objectAtIndex:d]];
                                }
                            }
                        }
                    }
                }
                UIButton *btn =(UIButton *)[cell viewWithTag:OPEN];
                int tag = btn.tag;
                btn.tag = tag - OPEN + CLOSE;
                [btn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
                
                CGFloat lbl_price = [cell.lblPrice.text floatValue];
                if ((lbl_price+discount_y) <0.0001f ) {
                    cell.lblPrice.text = @"0";
                }else {
                    cell.lblPrice.text = [NSString stringWithFormat:@"%.2f",discount_y+lbl_price];
                }
                [product_dic setValue:@"1" forKey:@"selected"];
                [product_dic setObject:p_arr forKey:@"sale_products"];
                //////////////////////////////////////////////////////////////////////////////
                [product_dic setObject:@"0" forKey:@"show_price"];
                
                NSString *p = [NSString stringWithFormat:@"%.2f",discount_y];
                NSMutableDictionary *dic1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:p,@"object",product_dic,@"prod",idx,@"idx",@"2",@"type", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"update_total" object:dic1];
            }
        }
        if (collection_temp.count>0) {
            [[DataService sharedService].row_id_numArray removeObjectsInArray:collection_temp];
        }
        if (sale_tempArray.count>0) {
            [[DataService sharedService].saleArray removeObjectsInArray:sale_tempArray];
        }
    }
}

#pragma mark - 打折卡通知
- (void)scardReloadTableView:(NSNotification *)notification {
    if ([DataService sharedService].row.count>0) {
        CGFloat price_x =0;
        for (int i=0; i<[DataService sharedService].row.count; i++) {
            
            int idx_r = [[[DataService sharedService].row objectAtIndex:i]intValue];
            NSIndexPath *idxx = [NSIndexPath indexPathForRow:idx_r inSection:0];
            SVCardCell *cell = (SVCardCell *)[self.productTable cellForRowAtIndexPath:idxx];
            //找到打折卡
            NSMutableDictionary *product_dic =[[[DataService sharedService].productList objectAtIndex:idx_r]mutableCopy];
            if ([[product_dic objectForKey:@"selected"]intValue] == 0) {
                price_x =0- [[product_dic objectForKey:@"show_price"]floatValue];
                [product_dic setValue:@"1" forKey:@"selected"];
                [product_dic setValue:@"0" forKey:@"show_price"];
                cell.lblPrice.text = @"0";
                
                UIButton *btn =(UIButton *)[cell viewWithTag:OPEN];
                int tag = btn.tag;
                btn.tag = tag - OPEN + CLOSE;
                [btn setImage:[UIImage imageNamed:@"cb_mono_off"] forState:UIControlStateNormal];
                
                NSString *price = [NSString stringWithFormat:@"%.2f",price_x];
                NSDictionary *dic_scard = [NSDictionary dictionaryWithObjectsAndKeys:price,@"object",product_dic,@"prod",idxx,@"idx",@"1",@"type", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"update_total" object:dic_scard];
            }
        }
    }
}

@end
