//
//  AppDelegate.m
//  LanTai
//
//  Created by david on 13-10-15.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "AppDelegate.h"
#import "LanTaiMenuMainController.h"
#import "LoginViewController.h"
#import "pinyin.h"

@implementation AppDelegate
+ (AppDelegate *)shareInstance {
    return (AppDelegate *)([UIApplication sharedApplication].delegate);
}
-(void)showView {
    self.window.rootViewController = self.navigationView;
    self.navigationView = nil;
}
- (void)showRootView{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userInfo = [defaults objectForKey:@"userId"];
    if (userInfo != nil) {
        [DataService sharedService].store_id = [defaults objectForKey:@"storeId"];
        [DataService sharedService].user_id = userInfo;
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        
        LanTaiMenuMainController *messageView = [story instantiateViewControllerWithIdentifier:@"LanTaiMenuMainController"];
        self.navigationView = [[UINavigationController alloc] initWithRootViewController:messageView];
        //设置导航条背景
        if ([self.navigationView.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
            [self.navigationView.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
        }
        [self performSelectorOnMainThread:@selector(showView) withObject:nil waitUntilDone:NO];
        
    }else{
        LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        self.navigationView = [[UINavigationController alloc] initWithRootViewController:loginView];
        [self performSelectorOnMainThread:@selector(showView) withObject:nil waitUntilDone:NO];
    }
}
-(void)getmatchArray {
    NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [Path stringByAppendingPathComponent:@"match.plist"];
    [DataService sharedService].matchArray = [NSKeyedUnarchiver unarchiveObjectWithFile: filename];
    if ([DataService sharedService].matchArray.count == 0) {
        [DataService sharedService].matchArray = [NSMutableArray array];
    }else {
        [DataService sharedService].sectionArray=[Utils matchArray];
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DataService sharedService].firstTime = YES;
    [DataService sharedService].doneArray = [NSMutableArray array];
   
    [self getmatchArray];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [Path stringByAppendingPathComponent:@"match.plist"];
    if ([fileManage fileExistsAtPath:filename]) {
        [fileManage removeItemAtPath:filename error:nil];
    }
    [NSKeyedArchiver archiveRootObject:[DataService sharedService].matchArray toFile:filename];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (BOOL)decode:(NSString *)urlStr{
    NSArray *params = [urlStr componentsSeparatedByString:@"//"];
    NSArray *dic = [[params objectAtIndex:1] componentsSeparatedByString:@"&"];
    int x = 0;
    for (NSString *item in dic) {
        if([item isEqualToString:[NSString stringWithFormat:@"appid=%@",[DataService sharedService].kPosAppId]]){
            x++;
        }
        if ([item isEqualToString:[NSString stringWithFormat:@"result=0"]]) {
            x++;
        }
        if (x==2) {
            break;
        }
    }
    if (x==2) {
        return YES;
    }
    return NO;
}
//回调钱方的反馈信息
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    NSString *urlString = [url absoluteString];
    if ([self decode:urlString]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"payQFPOS" object:@"success"];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"payQFPOS" object:@"fail"];
    }
    return YES;
}
@end
