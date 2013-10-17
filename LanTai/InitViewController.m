//
//  InitViewController.m
//  LanTaiOrder
//
//  Created by comdosoft on 13-3-29.
//  Copyright (c) 2013年 LanTai. All rights reserved.
//

#import "InitViewController.h"
#import "AppDelegate.h"

@implementation InitViewController
@synthesize activityView,view2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.activityView stopAnimating];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(showMainView) withObject:nil afterDelay:1];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
- (void)errorAlert:(NSString *)message
{
    [AHAlertView applyCustomAlertAppearance];
    AHAlertView *alertt = [[AHAlertView alloc] initWithTitle:kTip message:message];
    __block AHAlertView *alert = alertt;
    [alertt setCancelButtonTitle:@"确定" block:^{
        alert.dismissalStyle = AHAlertViewDismissalStyleTumble;
        alert = nil;
    }];
    [alertt show];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showMainView {
    [(AppDelegate *)[UIApplication sharedApplication].delegate showRootView];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation==UIInterfaceOrientationLandscapeRight);
}
@end
