//
//  AppDelegate.h
//  LanTai
//
//  Created by david on 13-10-15.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, strong) UINavigationController *navigationView;
- (void)showRootView;
+ (AppDelegate *)shareInstance;
@end
