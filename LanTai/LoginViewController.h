//
//  LoginViewController.h
//  LanTaiOrder
//
//  Created by Ruby on 13-1-23.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanTaiMenuMainController.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate>{
    IBOutlet UIButton *btnLogin;
}

@property (nonatomic,strong) IBOutlet UITextField *txtName;
@property (nonatomic,strong) IBOutlet UITextField *txtPwd;
@property (nonatomic,strong) IBOutlet UIView *loginView;


- (IBAction)clickLogin:(id)sender;

@end
