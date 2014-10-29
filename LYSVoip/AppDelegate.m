/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.yuntongxun.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "AppDelegate.h"

#import "ModelEngineVoip.h"
#import "VoipIncomingViewController.h"
#import "LoginViewController.h"
#import "ASIFormDataRequest.h"
#import "TFHpple.h"
#import "DemoListViewController.h"
#import "AccountInfo.h"
#import "OpenUDID.h"
#import "SYAppStart.h"

//#import "RegisterViewController.h"


@implementation AppDelegate
@synthesize modeEngineVoip;


- (void)dealloc
{
    [_window release];
    self.modeEngineVoip = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addressbookChanged" object:nil];
    [super dealloc];
}

//-(void) redirectConsoleLogToDocumentFolder
//{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console_log.txt"];
//    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    //初始化Voip SDK接口，分配资源
    self.modeEngineVoip = [ModelEngineVoip getInstance];
   
    //UUID取得
    NSString* udid = [OpenUDID value];
    
    //用户信息取得
    [self getUserInfo:udid];

    return YES;
}

- (void)getUserInfo:(NSString*)userUuid
{
    NSString* urlString = [[NSString alloc]initWithFormat:@"http:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX%@",userUuid];
    ASIFormDataRequest* _request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    [_request setDelegate:self];
    [_request setDidFinishSelector:@selector(getSucceed:)];
    [_request setDidFailSelector:@selector(fail:)];
    [_request startAsynchronous];
}

- (void) getSucceed:(ASIHTTPRequest *)request
{
    NSData *data =[request responseData];
    TFHpple* xpathParser = [[TFHpple alloc] initWithXMLData:data];
    NSArray* ststus  = [xpathParser searchWithXPathQuery:@"//status"];
    NSString* strStatus = [[[[ststus objectAtIndex:0] children] objectAtIndex:0] content];
    
//    NSLog(@"是否首次登录,error首次,success非首次 %@",strStatus);
    
    if ([strStatus isEqual: @"error"])
    {
        //首先启动用户登录页面
        LoginViewController *loginViewController = [[[LoginViewController alloc] init] autorelease];
        
        UINavigationController *navigationBar = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        self.window.rootViewController = navigationBar;
        
        [navigationBar release];
        [self.window makeKeyAndVisible];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addressbookChangeCallback:)
                                                     name:@"addressbookChanged"
                                                   object:nil];
//        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:@"您的设备没有经过认证，程序装退出，请联系管理员:wang-hb@rgsis.com" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alertView show];
//        [alertView release];
        
    }
    
    if ([strStatus isEqual:@"success"])
    {
        //用户信息数据取得
        AccountInfo* info = [[[AccountInfo alloc] init]autorelease];
        NSArray* userID = [xpathParser searchWithXPathQuery:@"//userid"];
        NSArray* userName = [xpathParser searchWithXPathQuery:@"//username"];
        NSArray* userCompany = [xpathParser searchWithXPathQuery:@"//company"];
        NSArray* subAccount = [xpathParser searchWithXPathQuery:@"//sub_account"];
        NSArray* subToken = [xpathParser searchWithXPathQuery:@"//sub_token"];
        NSArray* voipAccount = [xpathParser searchWithXPathQuery:@"//voip_account"];
        NSArray* voipPassword = [xpathParser searchWithXPathQuery:@"//voip_password"];
        
        info.userID = [[[[userID objectAtIndex:0] children] objectAtIndex:0] content];
        info.userName = [[[[userName objectAtIndex:0] children] objectAtIndex:0] content];
        info.userCompany = [[[[userCompany objectAtIndex:0] children] objectAtIndex:0] content];
        info.subAccount = [[[[subAccount objectAtIndex:0] children] objectAtIndex:0] content];
        info.subToken = [[[[subToken objectAtIndex:0] children] objectAtIndex:0] content];
        info.voipId = [[[[voipAccount objectAtIndex:0] children] objectAtIndex:0] content];
        info.password = [[[[voipPassword objectAtIndex:0] children] objectAtIndex:0] content];
        
        //启动平台登录页面
        DemoListViewController *resgisterViewController = [[[DemoListViewController alloc] init] autorelease];
        UINavigationController *navigationBar = [[UINavigationController alloc] initWithRootViewController:resgisterViewController];
        resgisterViewController.userBasic = info;
        self.window.rootViewController = navigationBar;
        [navigationBar release];
        [self.window makeKeyAndVisible];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addressbookChangeCallback:)
                                                     name:@"addressbookChanged"
                                                   object:nil];

    }
}

- (void)fail:(ASIHTTPRequest *)request
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    contactOptState = -1;//通讯录如果改变则重新建立拼音索引
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

-(void)logout
{
    UINavigationController *navigationBar = (UINavigationController *)self.window.rootViewController;
    [navigationBar setNavigationBarHidden:YES animated:NO];
    [navigationBar popToRootViewControllerAnimated:YES];
    [navigationBar setNavigationBarHidden:YES animated:NO];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.modeEngineVoip stopUdpTest];
    [self.modeEngineVoip stopCurRecording];
    self.modeEngineVoip.appIsActive = NO;
    // Sent when the application is about to move ·from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    self.modeEngineVoip.appIsActive = YES;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSString *callID = [notification.userInfo objectForKey:KEY_CALLID];
    NSString *type = [notification.userInfo objectForKey:KEY_TYPE];
    NSString *call = [notification.userInfo objectForKey:KEY_CALL_TYPE];
    NSString *caller = [notification.userInfo objectForKey:KEY_CALLNUMBER];
    NSInteger calltype = call.integerValue;
    if ([type isEqualToString:@"comingCall"])
    {
        UIApplication *uiapp = [UIApplication sharedApplication];
        NSArray *localNotiArray = [uiapp scheduledLocalNotifications];
        for (UILocalNotification *notification in localNotiArray)
        {
            NSDictionary *dic = [notification userInfo];
            NSString *value = [dic objectForKey:KEY_TYPE];
            if ([value isEqualToString:@"comingCall"] || [value isEqualToString:@"releaseCall"])
            {
                [uiapp cancelLocalNotification:notification];
            }
        }
        if (self.modeEngineVoip.UIDelegate && [self.modeEngineVoip.UIDelegate respondsToSelector:@selector(incomingCallID:caller:phone:name:callStatus:callType:)])
        {
            [self.modeEngineVoip.UIDelegate incomingCallID:callID caller:caller phone:[notification.userInfo objectForKey:KEY_CALLERPHONE] name:[notification.userInfo objectForKey:KEY_CALLERNAME] callStatus:IncomingCallStatus_accepting callType:calltype];
        }
    }
}

- (void)addressbookChangeCallback:(NSNotification *)_notification
{
    globalcontactsChanged = 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"contactsChanged" object:nil userInfo:nil];
}

-(void)printLog:(NSString*)log
{
    NSLog(@"%@",log); //用于xcode日志输出
}
@end
