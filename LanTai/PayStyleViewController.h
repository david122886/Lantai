//
//  PayStyleViewController.h
//  LanTaiOrder
//
//  Created by Ruby on 13-3-13.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PayStyleViewDelegate;

@interface PayStyleViewController : UIViewController

@property (nonatomic,assign) id<PayStyleViewDelegate> delegate;
@property (nonatomic,strong) NSMutableDictionary *order;
@property (nonatomic,strong) IBOutlet UISwitch *billingBtn;
@property (nonatomic,assign) BOOL isSuccess;
@property (nonatomic,strong) IBOutlet UIView *payStyle,*phoneView,*codeView,*posView;
@property (nonatomic,strong) IBOutlet UITextField *txtPhone,*txtCode,*txtPos;
@property (nonatomic,strong) IBOutlet UISegmentedControl *segBtn;
@property (nonatomic,strong) NSString *codeStr;
@property (nonatomic,assign) int payType;

@property (nonatomic,strong) IBOutlet UILabel *posLab;
@property (nonatomic,strong) IBOutlet UIButton *posBtn,*sureBtn;

- (IBAction)clickSendCode:(id)sender;
- (IBAction)clickCodeBtn:(id)sender;

@end

@protocol PayStyleViewDelegate <NSObject>
@optional
- (void)closePopVieww:(PayStyleViewController *)payStyleViewController;
@end
