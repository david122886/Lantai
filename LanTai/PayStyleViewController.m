//
//  PayStyleViewController.m
//  LanTaiOrder
//
//  Created by Ruby on 13-3-13.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import "PayStyleViewController.h"
#import <CommonCrypto/CommonCrypto.h>
#import "UIViewController+MJPopupViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CarObj.h"

@interface PayStyleViewController ()

@end

@implementation PayStyleViewController

@synthesize delegate;
@synthesize order;
@synthesize billingBtn;
@synthesize isSuccess,codeStr;
@synthesize payStyle,phoneView,codeView,txtCode,txtPhone;
@synthesize payType;
@synthesize segBtn;
@synthesize posView,txtPos;
@synthesize posBtn,posLab,sureBtn;

-(CarObj *)setAttributeWithDictionary:(NSDictionary *)result {
    CarObj *carobject = [[CarObj alloc]init];
    carobject.carID = [NSString stringWithFormat:@"%@",[result objectForKey:@"car_num_id"]];
    carobject.carPlateNumber = [NSString stringWithFormat:@"%@",[result objectForKey:@"num"]];
    carobject.orderId = [NSString stringWithFormat:@"%@",[result objectForKey:@"id"]];
    if (![[result objectForKey:@"station_id"]isKindOfClass:[NSNull class]] && [result objectForKey:@"station_id"]!=nil) {
        carobject.stationId =[NSString stringWithFormat:@"%@",[result objectForKey:@"station_id"]];
    }
    carobject.serviceName = [NSString stringWithFormat:@"%@",[result objectForKey:@"service_name"]];
    carobject.lastTime = [NSString stringWithFormat:@"%@",[result objectForKey:@"cost_time"]];
    carobject.workOrderId = [NSString stringWithFormat:@"%@",[result objectForKey:@"wo_id"]];
    if (![[result objectForKey:@"wo_started_at"]isKindOfClass:[NSNull class]] && [result objectForKey:@"wo_started_at"]!=nil) {
        carobject.serviceStartTime = [NSString stringWithFormat:@"%@",[result objectForKey:@"wo_started_at"]];
    }
    if (![[result objectForKey:@"wo_ended_at"]isKindOfClass:[NSNull class]] && [result objectForKey:@"wo_ended_at"]!=nil) {
        carobject.serviceEndTime = [NSString stringWithFormat:@"%@",[result objectForKey:@"wo_ended_at"]];
    }
    return carobject;
}

#pragma mark - 支付
-(void)payWithType:(NSData *)data {
    id jsonObject=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if (jsonObject !=nil) {
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonData=(NSDictionary *)jsonObject;
            DLog(@"jsonData = %@",jsonData);
            if ([[jsonData objectForKey:@"status"]intValue] == 1) {
                [Utils errorAlert:@"交易成功!"];
                NSDictionary *order_dic = [jsonData objectForKey:@"orders"];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                //排队等候
                if (![[order_dic objectForKey:@"0"]isKindOfClass:[NSNull class]] && [order_dic objectForKey:@"0"]!= nil) {
                    NSArray *waiting_array = [order_dic objectForKey:@"0"];
                    if (waiting_array.count>0) {
                        self.waittingCarsArr = [[NSMutableArray alloc]init];
                        for (int i=0; i<waiting_array.count; i++) {
                            NSDictionary *resultt = [waiting_array objectAtIndex:i];
                            CarObj *carobject = [self setAttributeWithDictionary:resultt];
                            [self.waittingCarsArr addObject:carobject];
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
                            CarObj *carobject = [self setAttributeWithDictionary:resultt];
                            [self.beginningCarsDic setObject:carobject forKey:carobject.stationId];
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
                            CarObj *carobject = [self setAttributeWithDictionary:resultt];
                            [self.finishedCarsArr addObject:carobject];
                        }
                        [dic setObject:self.finishedCarsArr forKey:@"finish"];
                    }
                }
                
                isSuccess = TRUE;
            }else {
                [Utils errorAlert:[NSString stringWithFormat:@"交易失败!"]];
                isSuccess = FALSE;
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(closePopVieww:)]) {
                [self.delegate closePopVieww:self];
            }
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (void)pay:(int)type{
    self.payType = type;
    if (self.order) {
        if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"]) {
            [Utils errorAlert:@"暂无网络!"];
        }else {
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.labelText = @"正在玩命加载...";
            
            NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
            NSString *billing = @"1";
            if (self.billingBtn.isOn) {
                billing = @"1";
            }else{
                billing = @"0";
            }
            DLog(@"order = %@",order);
            [params setObject:[DataService sharedService].store_id forKey:@"store_id"];
            [params setObject:[order objectForKey:@"order_id"] forKey:@"order_id"];
            [params setObject:[order objectForKey:@"is_please"] forKey:@"please"];
            [params setObject:billing forKey:@"billing"];
            [params setObject:[NSNumber numberWithInt:self.payType] forKey:@"pay_type"];
            [params setObject:[order objectForKey:@"prods"] forKey:@"prods"];
            [params setObject:[order objectForKey:@"price"] forKey:@"price"];
            
            if (self.payType == 5) {
                [params setObject:[NSNumber numberWithInt:1] forKey:@"is_free"];
            }else if (self.payType == 1) {
                [params setObject:[NSNumber numberWithInt:0] forKey:@"is_free"];
                [params setObject:[DataService sharedService].kPosAppId forKey:@"appid"];
            }else if (self.payType == 0){
                [params setObject:[NSNumber numberWithInt:0] forKey:@"is_free"];
            }else {
                [params setObject:[NSNumber numberWithInt:0] forKey:@"is_free"];
                [params setObject:self.txtCode.text forKey:@"code"];
            }
            
            NSMutableURLRequest *request=[Utils getRequest:params string:[NSString stringWithFormat:@"%@%@",kHost,kNewPay]];
            NSOperationQueue *queue=[[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *respone,
                                                                                             NSData *data,
                                                                                             NSError *error)
             {
                 if ([data length]>0 && error==nil) {
                     [self performSelectorOnMainThread:@selector(payWithType:) withObject:data waitUntilDone:NO];
                     
                 }
             }
             ];
        }
    }
}

#pragma mark - 刷卡支付，调用钱方
- (BOOL)payPal{
    NSString *callback = @"pospal";
    NSString *appname = @"澜泰客户订单";
    float account = [[self.order objectForKey:@"price"]floatValue];
    NSString *pricr = [NSString stringWithFormat:@"%2f",account*100];
    NSString *params = [NSString stringWithFormat:@"appid=%@&amount=%@&tradetype=%@&callback=%@&appname=%@&arg=lantan",[DataService sharedService].kPosAppId,pricr,@"0",callback,appname,nil];
    NSString *strKey = [NSString stringWithFormat:@"%@qpos",params];
    NSString *md5Key = [Utils MD5:strKey];
    NSString *stringParams = [NSString stringWithFormat:@"%@&sign=%@",params,md5Key];
    NSString *unicodeText = [stringParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    UIApplication *applicaion = [UIApplication sharedApplication];
    NSString *posPath = [NSString stringWithFormat:@"QFPayPlug://%@",unicodeText];
    NSURL *url = [NSURL URLWithString:posPath];
    if ([applicaion canOpenURL:url]) {
        [applicaion openURL:url];
        return YES;
    }else{
        [Utils errorAlert:@"你还没安装QFPOS安全支付插件，建议你先安装再发起交易!"];
        return NO;
    }
}

#pragma mark - 钱方支付
-(IBAction)qfPay:(id)sender {
    [self.txtPos resignFirstResponder];
    [self.txtPhone resignFirstResponder];
    [self.txtCode resignFirstResponder];
    if (self.txtPos.hidden == YES) {
        [self payPal];
    }else {
        NSString *regexCall = @"1[0-9]{10}";
        NSPredicate *predicateCall = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexCall];
        if ([predicateCall evaluateWithObject:txtPos.text]) {
            [DataService sharedService].kPosAppId = [NSString stringWithFormat:@"%@",self.txtPos.text];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:self.txtPos.text forKey:@"qfpay"];
            [defaults synchronize];
            
            [self payPal];
        }else {
            
        }
    }
}

-(IBAction)editPressed:(id)sender {
    self.txtPos.hidden = NO;
    self.posLab.hidden = YES;
    self.posBtn.hidden = YES;
    self.posLab.text = @"";
    self.sureBtn.frame = CGRectMake(129, 77, 60, 30);
    [DataService sharedService].kPosAppId = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"qfpay"];
    [defaults synchronize];
}
#pragma mark - 根据不同的支付方式
- (IBAction)closePopup:(UISegmentedControl *)sender
{
    if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"]) {
        [Utils errorAlert:@"暂无网络!"];
    }else {
        if (sender.selectedSegmentIndex == 0) {
            [self pay:0];
        }else if (sender.selectedSegmentIndex == 1 && order){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *qfPay = [defaults objectForKey:@"qfpay"];
            if (qfPay != nil) {
                self.txtPos.hidden = YES;
                self.posLab.hidden = NO;
                self.posBtn.hidden = NO;
                self.sureBtn.frame = CGRectMake(173, 77, 60, 30);
                self.posLab.text = qfPay;
                [DataService sharedService].kPosAppId = [NSString stringWithFormat:@"%@",qfPay];
            }else {
                self.txtPos.hidden = NO;
                self.posLab.hidden = YES;
                self.posBtn.hidden = YES;
                self.sureBtn.frame = CGRectMake(129, 77, 60, 30);
            }
            self.posView.hidden = NO;
            self.phoneView.hidden = YES;
            self.codeView.hidden = YES;
            self.payStyle.hidden = YES;
            //            [self payPal];
        }else if (sender.selectedSegmentIndex == 2){
            self.phoneView.hidden = NO;
            self.codeView.hidden = YES;
            self.payStyle.hidden = YES;
            self.posView.hidden = YES;
        }else if (sender.selectedSegmentIndex == 3) {
            [AHAlertView applyCustomAlertAppearance];
            AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:@"确定免单?"];
            __block AHAlertView *alert = alertt;
            [alertt setCancelButtonTitle:@"取消" block:^{
                alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
                alert = nil;
            }];
            [alertt addButtonWithTitle:@"确定" block:^{
                alert.dismissalStyle = AHAlertViewDismissalStyleZoomDown;
                alert = nil;
                [self pay:5];
            }];
            [alertt show];
        }
    }
    
}

- (void)payResult:(NSNotification *)notification{
    NSString *result = [notification object];
    if ([result isEqualToString:@"success"]) {
        [self pay:1];
    }else if ([result isEqualToString:@"fail"]){
        [Utils errorAlert:@"交易失败!"];
    }
}

#pragma mark - 提交输入的验证码
-(void)code {
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",kHost,kSendVerifyCode]];
    [r setPOSTDictionary:[NSDictionary dictionaryWithObjectsAndKeys:self.txtPhone.text,@"mobilephone",[order objectForKey:@"price"],@"price",self.txtCode.text,@"verify_code",[order objectForKey:@"content"],@"content",[DataService sharedService].store_id,@"store_id", nil]];
    [r setPostDataEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *result = [[r startSynchronousWithError:&error] objectFromJSONString];
    DLog(@"%@",result);
    if ([[result objectForKey:@"status"] integerValue] == 1) {
        [self pay:2];
    }else{
        [AHAlertView applyCustomAlertAppearance];
        AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:[result objectForKey:@"content"]];
        __block AHAlertView *alert = alertt;
        [alertt setCancelButtonTitle:@"确定" block:^{
            alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
            alert = nil;
        }];
        [alertt show];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (IBAction)clickCodeBtn:(id)sender{
    [self.txtPos resignFirstResponder];
    [self.txtPhone resignFirstResponder];
    [self.txtCode resignFirstResponder];
    if (self.txtCode.text.length == 0) {
        [Utils errorAlert:@"请输入验证码!"];
    }else{
        if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"]) {
            [Utils errorAlert:@"暂无网络!"];
        }else{
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            hud.dimBackground = NO;
            [hud showWhileExecuting:@selector(code) onTarget:self withObject:nil animated:YES];
            hud.labelText = @"正在玩命加载...";
            [self.view addSubview:hud];
        }
    }
}

#pragma mark - 发送验证码
-(void)sendCode {
    if (self.txtPhone.text.length == 0) {
        [Utils errorAlert:@"请输入手机号!"];
    }else{
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",kHost,kSendMeg]];
        [r setPOSTDictionary:[NSDictionary dictionaryWithObjectsAndKeys:self.txtPhone.text,@"mobilephone",[order objectForKey:@"price"],@"price",[DataService sharedService].store_id,@"store_id", nil]];
        [r setPostDataEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *result = [[r startSynchronousWithError:&error] objectFromJSONString];
        DLog(@"%@",result);
        if ([[result objectForKey:@"status"] integerValue] == 1) {
            self.codeView.hidden = NO;
            self.phoneView.hidden = YES;
            self.payStyle.hidden = YES;
            self.posView.hidden = YES;
        }else{
            [Utils errorAlert:@"当前号码未购买储值卡或余额不足!"];
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (IBAction)clickSendCode:(id)sender{
    [self.txtPos resignFirstResponder];
    [self.txtPhone resignFirstResponder];
    [self.txtCode resignFirstResponder];
    if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"]) {
        [Utils errorAlert:@"暂无网络!"];
    }else {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.dimBackground = NO;
        [hud showWhileExecuting:@selector(sendCode) onTarget:self withObject:nil animated:YES];
        hud.labelText = @"正在努力加载...";
        [self.view addSubview:hud];
    }
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)setsetTotal:(NSNotification *)notification {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.payType = -1;
    
    if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"]) {
        [Utils errorAlert:@"暂无网络!"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payResult:) name:@"payQFPOS" object:nil];
    self.payStyle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"alert_bg"]];
    self.phoneView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"alert_bg"]];
    self.codeView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"alert_bg"]];
    self.posView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"alert_bg"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
