//
//  ComplaintViewController.m
//  LanTaiOrder
//
//  Created by Ruby on 13-3-3.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import "ComplaintViewController.h"
#import "PayViewController.h"

@implementation ComplaintViewController

@synthesize lblCarNum,lblCode,lblName,lblProduct;
@synthesize reasonView,requestView;
@synthesize info,infoBgView,scView;
@synthesize resonLab,requestLab;
@synthesize sureBtn,cancleBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.scView setScrollEnabled:NO];
    
    self.scView.contentSize = CGSizeMake(320, 868);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![self.navigationItem rightBarButtonItem]) {
//        [self addRightnaviItemsWithImage:@"back" andImage:nil];
    }
    if (info) {
        self.lblCarNum.text = [info objectForKey:@"carNum"];
        self.lblProduct.text = [info objectForKey:@"prods"];
    }
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg"]];
     self.infoBgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_1_bg"]];
}

//提交
-(void)submit {
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@%@",kHost,kComplaint]];
    [r setPOSTDictionary:[NSDictionary dictionaryWithObjectsAndKeys:self.reasonView.text,@"reason",self.requestView.text,@"request",[DataService sharedService].store_id,@"store_id",[info objectForKey:@"order_id"],@"order_id", nil]];
    [r setPostDataEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *result = [[r startSynchronousWithError:&error] objectFromJSONString];
    DLog(@"%@",result);
    if ([[result objectForKey:@"status"] intValue] == 1) {
        if([[info objectForKey:@"from"] intValue]==1){
            [DataService sharedService].payNumber = 1;
            
            NSString *btnTag = [NSString stringWithFormat:@"%@",[info objectForKey:@"tag"]];
            NSMutableArray *array = [NSMutableArray arrayWithArray:[DataService sharedService].doneArray];
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];//临时数组
            if (array.count > 0) {
                int i = 0;
                BOOL exit = NO;
                while (i<array.count) {
                    NSString *str = [array objectAtIndex:i];
                    if ([str isEqualToString:btnTag]) {
                        exit = YES;
                        break;
                    }
                    i++;
                }
                if (exit == NO) {
                    [tempArray addObject:btnTag];
                }
            }else {
                [tempArray addObject:btnTag];
            }
            
            if (tempArray.count>0) {
                [[DataService sharedService].doneArray addObjectsFromArray:tempArray];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            [DataService sharedService].payNumber = 1;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (IBAction)clickSubmit:(id)sender{
    [reasonView resignFirstResponder];
    [requestView resignFirstResponder];
    if (self.reasonView.text.length==0 || self.requestView.text.length==0) {
        [Utils errorAlert:@"请输入投诉理由和要求"];
    }else{
        if ([[Utils isExistenceNetwork] isEqualToString:@"NotReachable"] ) {
            [Utils errorAlert:@"暂无网络!"];
        }else {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            hud.dimBackground = NO;
            [hud showWhileExecuting:@selector(submit) onTarget:self withObject:nil animated:YES];
            hud.labelText = @"正在努力加载...";
            [self.view addSubview:hud];
        }
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.scView setScrollEnabled:YES];
    
    if (textView.tag == 1888) {
        [self.scView setContentOffset:CGPointMake(0, 0)];
    }else {
        [self.scView setContentOffset:CGPointMake(0, 236)];
    }
    
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.scView setScrollEnabled:NO];
    [self.scView setContentOffset:CGPointMake(0, 0)];
}
-(IBAction)clickCancle:(id)sender {
    [reasonView resignFirstResponder];
    [requestView resignFirstResponder];
    [DataService sharedService].payNumber = 0;
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
