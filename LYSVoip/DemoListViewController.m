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

#import "DemoListViewController.h"
#import "VoIPCallViewController.h"
#import "InterphoneViewController.h"
#import "UIselectContactsViewController.h"
#import "RoomListViewController.h"
#import "IMListViewController.h"
#import "SettingViewController.h"
//#import "LandingCallsViewController.h"
//#import "VoiceCodeViewController.h"
//#import "counselorViewController.h"
//#import "ContactsViewController.h"
#import "VideoConfIntroduction.h"
#import "ASIFormDataRequest.h"
#import "TFHpple.h"
#import "BalanceViewController.h"

#define TAG_DEMO_GOTO_VOIP          100
#define TAG_DEMO_GOTO_INTERCOME     101
#define TAG_DEMO_GOTO_CHAT_ROOM     102
#define TAG_DEMO_GOTO_VIDEO         103
#define TAG_DEMO_GOTO_VideoConf     104
#define TAG_DEMO_GOTO_XX_Message    105
#define TAG_DEMO_GOTO_BALANCE       106
#define TAG_DEMO_GOTO_RECHARGE      107
#define TAG_DEMO_GOTO_SETTING       108


@interface DemoListViewController ()

@end

@implementation DemoListViewController
@synthesize serverip;
@synthesize serverport;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    self.title = @"功能列表";
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIApplication sharedApplication].statusBarStyle =UIStatusBarStyleBlackTranslucent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation.png"] forBarMetrics:0];
    
    int value = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        value = 20;
    }
    
    NSString* fileStr = Nil;
    CGRect range;
    if (IPHONE5)
    {
        fileStr = @"videoConfBg_1136.png";
        range = CGRectMake(0, 0, 320, 576);
    }
    else
    {
        fileStr = @"videoConfBg.png";
        range = CGRectMake(0, 0, 320, 480);
    }
    
    UIImage* imBg = [UIImage imageNamed:fileStr];
    UIImageView* ivBg = [[UIImageView alloc] initWithImage:imBg];
    ivBg.frame = range;
    [self.view addSubview:ivBg];
    [ivBg release];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 80.0f+value)];
    topView.backgroundColor = [UIColor colorWithRed:34.0f/255.0f green:34.0f/255.0f blue:34.0f/255.0f alpha:1.0f];
    
    UIImageView *logoImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logoDemo.png"]];
    logoImg.center = CGPointMake(100.0f, 50.0f+value/2);
    [topView addSubview:logoImg];
    [logoImg release];
    
    UILabel *topLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(210.0f, 25.0f, 100.0f, 20.0f)];
    topLabel1.backgroundColor = [UIColor clearColor];
    topLabel1.font = [UIFont systemFontOfSize:16.0f];
    topLabel1.text = self.userBasic.userID;
    topLabel1.textColor = [UIColor whiteColor];
    topLabel1.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:topLabel1];
    [topLabel1 release];
    
    UILabel *topLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(210.0f, 50.0f, 100.0f, 20.0f)];
    topLabel2.backgroundColor = [UIColor clearColor];
    topLabel2.font = [UIFont systemFontOfSize:16.0f];
    topLabel2.text = self.userBasic.userName;
    topLabel2.textColor = [UIColor whiteColor];
    topLabel2.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:topLabel2];
    [topLabel2 release];
    
    UILabel *topLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(210.0f, 75.0f, 100.0f, 20.0f)];
    topLabel3.backgroundColor = [UIColor clearColor];
    topLabel3.font = [UIFont systemFontOfSize:16.0f];
    topLabel3.text = self.userBasic.userCompany;
    topLabel3.textColor = [UIColor whiteColor];
    topLabel3.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:topLabel3];
    [topLabel3 release];
    
    [self.view addSubview:topView];
    [topView release];

    for (int i=0;i<9;i++)
    {
        int x = 0;
        int y = 20+80.0f+value;
       
        if (i%3 == 0)
        {
            x = 10;
        }
        else if (i%3 == 1)
        {
            x = 114;
        }
        else
        {
            x = 217;
        }
            
        y += (i/3) * 114;
        
        [self createButtonWithRect:CGRectMake(x, y, 92, 92) andTag:TAG_DEMO_GOTO_VOIP+i];
        
    }
    if (self.modelEngineVoip.addressBookContactList == nil)
    {
        self.modelEngineVoip.addressBookContactList = [[AddressBookContactList alloc] init];
    }
}

- (void)createButtonWithRect:(CGRect) frame andTag:(NSInteger) tag
{
    UIButton* button= [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = frame;
    button.tag = tag;
    [button addTarget:self action:@selector(goToDemo:)forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    if (button.tag == TAG_DEMO_GOTO_VOIP)
    {
        //进入VoIP演示
        [button setImage:[UIImage imageNamed:@"new201.png"] forState:(UIControlStateNormal)];
        [button setImage:[UIImage imageNamed:@"new201_on.png"] forState:(UIControlStateSelected)];
    }
    else if (button.tag == TAG_DEMO_GOTO_VIDEO)
    {
        //进入视频演示
        [button setImage:[UIImage imageNamed:@"new190.png"] forState:(UIControlStateNormal)];
        [button setImage:[UIImage imageNamed:@"new190_on.png"] forState:(UIControlStateSelected)];
    }
    else if (button.tag == TAG_DEMO_GOTO_INTERCOME)
    {
        //进入实时对讲演示
        [button setImage:[UIImage imageNamed:@"new188.png"] forState:(UIControlStateNormal)];
        [button setImage:[UIImage imageNamed:@"new188_on.png"] forState:(UIControlStateSelected)];
    }
    else if (button.tag == TAG_DEMO_GOTO_CHAT_ROOM)
    {
        //进入多人聊天室演示
        [button setImage:[UIImage imageNamed:@"new200.png"] forState:(UIControlStateNormal)];
        [button setImage:[UIImage imageNamed:@"new200_on.png"] forState:(UIControlStateSelected)];
    }
    else if (button.tag == TAG_DEMO_GOTO_XX_Message)
    {
        //进入IM演示
        [button setImage:[UIImage imageNamed:@"new186.png"] forState:(UIControlStateNormal)];
        [button setImage:[UIImage imageNamed:@"new186_on.png"] forState:(UIControlStateSelected)];
    }
    else if (button.tag == TAG_DEMO_GOTO_SETTING)
    {
        //进入设置页面
        [button setImage:[UIImage imageNamed:@"new184.png"] forState:(UIControlStateNormal)];
        [button setImage:[UIImage imageNamed:@"new184_on.png"] forState:(UIControlStateSelected)];
    }
    else if (button.tag == TAG_DEMO_GOTO_VideoConf)
    {
        //视频会议
        [button setImage:[UIImage imageNamed:@"new202.png"] forState:(UIControlStateNormal)];
        [button setImage:[UIImage imageNamed:@"new202_on.png"] forState:(UIControlStateSelected)];
    }
    else if (button.tag == TAG_DEMO_GOTO_BALANCE)
    {
        //余额
        [button setImage:[UIImage imageNamed:@"new197.png"] forState:(UIControlStateNormal)];
        [button setImage:[UIImage imageNamed:@"new197_on.png"] forState:(UIControlStateSelected)];
    }
    else if (button.tag == TAG_DEMO_GOTO_RECHARGE)
    {
        //充值
        [button setImage:[UIImage imageNamed:@"new199.png"] forState:(UIControlStateNormal)];
        [button setImage:[UIImage imageNamed:@"new199_on.png"] forState:(UIControlStateSelected)];
    }
//    else if (button.tag == TAG_DEMO_GOTO_MARKET_CALL)
//    {
//        //进入外呼通知演示
//        [button setImage:[UIImage imageNamed:@"new197.png"] forState:(UIControlStateNormal)];
//        [button setImage:[UIImage imageNamed:@"new197_on.png"] forState:(UIControlStateSelected)];
//    }
//    else if (button.tag == TAG_DEMO_GOTO_VOICE_VERIFY)
//    {
//        //进入语音验证演示
//        [button setImage:[UIImage imageNamed:@"new182.png"] forState:(UIControlStateNormal)];
//        [button setImage:[UIImage imageNamed:@"new182_on.png"] forState:(UIControlStateSelected)];
//    }
//    else if (button.tag == TAG_DEMO_GOTO_counselorView)
//    {
//        //咨询呼叫
//        [button setImage:[UIImage imageNamed:@"new199.png"] forState:(UIControlStateNormal)];
//        [button setImage:[UIImage imageNamed:@"new199_on.png"] forState:(UIControlStateSelected)];
//    }
//    else if (button.tag == TAG_DEMO_GOTO_Contacts)
//    {
//        //通讯录
//        [button setImage:[UIImage imageNamed:@"contact_management.png"] forState:(UIControlStateNormal)];
//        [button setImage:[UIImage imageNamed:@"contact_management_on.png"] forState:(UIControlStateSelected)];
//    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.modelEngineVoip.accountArray)
    {
        self.modelEngineVoip.accountArray = [[[NSMutableArray alloc] init] autorelease];
        
    } else {
        [self.modelEngineVoip.accountArray removeAllObjects];
    }
    
    [self getRequest];
    
	// Do any additional setup after loading the view.
}

- (void)getRequest
{
    ASIFormDataRequest* _request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://voip.atjava.com/voip_request.php?type=2&token=voiprgs123"]];
    [_request setDelegate:self];
    [_request setDidFinishSelector:@selector(getSucceed:)];
    [_request setDidFailSelector:@selector(fail:)];
    [_request startAsynchronous];
}

- (void) getSucceed:(ASIHTTPRequest *)request
{
    NSData *data =[request responseData];
    
    TFHpple* xpathParser = [[TFHpple alloc] initWithXMLData:data];
    //取得用户数目
    NSArray* item = [xpathParser searchWithXPathQuery:@"//item"];
//    NSLog(@"count = %i",[item count]);
    
    for (int i = 1; i <= [item count]; i++)
    {
        //用户信息数据取得
        AccountInfo* info = [[AccountInfo alloc]init];
        
        NSString* str = [[[NSString alloc] initWithFormat:@"/result/data/item[%d]/userid",i ]autorelease];
        NSArray* userID = [xpathParser searchWithXPathQuery:str];
        info.userID = [[[[userID objectAtIndex:0] children] objectAtIndex:0] content];
//        NSLog(@"%@",info.userID);
        
        NSString* str2 = [[[NSString alloc] initWithFormat:@"/result/data/item[%d]/username",i ]autorelease];
        NSArray* userName = [xpathParser searchWithXPathQuery:str2];
        info.userName = [[[[userName objectAtIndex:0] children] objectAtIndex:0] content];
//        NSLog(@"%@",info.userName);
        
        NSString* str3 = [[[NSString alloc] initWithFormat:@"/result/data/item[%d]/company",i]autorelease];
        NSArray* company = [xpathParser searchWithXPathQuery:str3];
        info.userCompany = [[[[company objectAtIndex:0] children] objectAtIndex:0] content];
//        NSLog(@"%@",info.userCompany);
        
        NSString* str4 = [[[NSString alloc] initWithFormat:@"/result/data/item[%d]/sub_account",i]autorelease];
        NSArray* subAccount = [xpathParser searchWithXPathQuery:str4];
        info.subAccount = [[[[subAccount objectAtIndex:0] children] objectAtIndex:0] content];
//        NSLog(@"%@",info.subAccount);
        
        NSString* str5 = [[[NSString alloc] initWithFormat:@"/result/data/item[%d]/sub_token",i]autorelease];
        NSArray* subToken = [xpathParser searchWithXPathQuery:str5];
        info.subToken = [[[[subToken objectAtIndex:0] children] objectAtIndex:0] content];
//        NSLog(@"%@",info.subToken);
        
        NSString* str6 = [[[NSString alloc] initWithFormat:@"/result/data/item[%d]/voip_account",i]autorelease];
        NSArray* voipAccount = [xpathParser searchWithXPathQuery:str6];
        info.voipId = [[[[voipAccount objectAtIndex:0] children] objectAtIndex:0] content];
//        NSLog(@"%@",info.voipId);
        
        NSString* str7 = [[[NSString alloc] initWithFormat:@"/result/data/item[%d]/voip_password",i]autorelease];
        NSArray* voipPassword = [xpathParser searchWithXPathQuery:str7];
        info.password = [[[[voipPassword objectAtIndex:0] children] objectAtIndex:0] content];
//        NSLog(@"%@",info.password);
        
        [self.modelEngineVoip.accountArray addObject:info];
        
        [info release];
    }
    
    [self readConfig];
    
}

- (void)fail:(ASIHTTPRequest *)request
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Failed To Get User Infomation" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
}

-(void)readConfig
{
    NSString *defaultFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:CONFIG_FILE_NAME];
    NSString *filePath = defaultFilePath;
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:CONFIG_FILE_NAME];
    BOOL success = [fileManager fileExistsAtPath:writablePath];
    
    if (!success)
    {
        success = [fileManager copyItemAtPath:defaultFilePath toPath:writablePath error:&error];
        if (!success)
        {
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
    }
    filePath = writablePath;
    
    //读取配置文件
    NSDictionary *configDic = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    NSArray *keysArr = [configDic allKeys];
    for (NSString *key in keysArr)
    {
        if ([key isEqualToString:CONFIG_KEY_SERVERIP]) {
            self.serverip = [configDic objectForKey:key];
        }
        else if ([key isEqualToString:CONFIG_KEY_SERVERPORT]) {
            self.serverport = [configDic objectForKey:key];
        }
        else if ([key isEqualToString:CONFIG_KEY_APPID]) {
            self.modelEngineVoip.appID = [configDic objectForKey:key];
        }
        else{
        }
    }
    
    //如果在配置文件里没有配置IP则设置默认REST服务器地址
    if ([self.serverip length]<=0)
    {
        self.serverip = VOIP_SERVICEIP;
    }
    //如果在配置文件里没有配置REST端口号则设置默认REST服务器端口号
    if ([self.serverport length]<=0)
    {
        self.serverport = VOIP_SERVICEPORT;
    }
    
    [configDic release];
    
    [self demoLogin];
}

- (void)demoLogin
{
    if (self.modelEngineVoip)
    {
        [self displayProgressingView];
        [self.modelEngineVoip connectToCCP:self.serverip onPort:[self.serverport integerValue] withAccount:self.userBasic.voipId withPsw:self.userBasic.password withAccountSid:self.userBasic.subAccount withAuthToken:self.userBasic.subToken];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    //用于设置消息返回的代理
    [self.modelEngineVoip setModalEngineDelegate:self];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)goToDemo:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
    if (button.tag == TAG_DEMO_GOTO_VOIP)
    {
        //进入VoIP演示
        VoIPCallViewController *voipDemo = [[VoIPCallViewController alloc] init];
        [self.navigationController pushViewController:voipDemo animated:YES];
        [voipDemo release];
    }
    else if (button.tag == TAG_DEMO_GOTO_VIDEO)
    {
        //进入视频演示
        UIselectContactsViewController* view = [[UIselectContactsViewController alloc] initWithAccountList:self.modelEngineVoip.accountArray andSelectType:ESelectViewType_Video];
        view.backView = self;
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (button.tag == TAG_DEMO_GOTO_INTERCOME)
    {
        //进入实时对讲演示
        InterphoneViewController *interphoneDemo = [[InterphoneViewController alloc] init];
        [self.navigationController pushViewController:interphoneDemo animated:YES];
        [interphoneDemo release];
    }
    else if (button.tag == TAG_DEMO_GOTO_CHAT_ROOM)
    {
        //进入多人聊天室演示
        RoomListViewController* view = [[RoomListViewController alloc] init];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (button.tag == TAG_DEMO_GOTO_XX_Message)
    {
        //进入IM演示
        IMListViewController* view = [[IMListViewController alloc] init];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (button.tag == TAG_DEMO_GOTO_SETTING)
    {
        //进入设置页面
        SettingViewController *view = [[SettingViewController alloc] init];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (button.tag == TAG_DEMO_GOTO_VideoConf)
    {
        VideoConfIntroduction* view = [[VideoConfIntroduction alloc] init];
        view.backView = self;
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (button.tag == TAG_DEMO_GOTO_BALANCE)
    {
        BalanceViewController *view = [[BalanceViewController alloc]init];
        view.userBasic = self.userBasic;
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else if (button.tag == TAG_DEMO_GOTO_RECHARGE)
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"待开发" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
//    else if (button.tag == TAG_DEMO_GOTO_MARKET_CALL)
//    {
//        //进入外呼通知演示
//        LandingCallsViewController *view = [[LandingCallsViewController alloc] init];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
//    }
//    else if (button.tag == TAG_DEMO_GOTO_VOICE_VERIFY)
//    {        
//        //进入语音验证演示
//        VoiceCodeViewController* view = [[VoiceCodeViewController alloc] init];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
//    }
//     else if (button.tag == TAG_DEMO_GOTO_counselorView)
//    {
//        counselorViewController* view = [[counselorViewController alloc] init];
//        [self.navigationController setNavigationBarHidden:NO animated:NO];
//        [self.navigationController pushViewController:view animated:YES];
//        [view release];
//    }
//    else if (button.tag == TAG_DEMO_GOTO_Contacts)
//    {
//        if ([self isContactsAccessGranted])
//        {
//            ContactsViewController* view = [[ContactsViewController alloc] init];
//            [self.navigationController pushViewController:view animated:YES];
//            [view release];
//        }
//    }
}

- (void)responseVoipRegister:(ERegisterResult)event data:(NSString *)data
{
    if (event == ERegisterSuccess)
    {
        // 登录成功
        [self dismissProgressingView];
        //把自己从列表中去除
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString* str =  [defaults objectForKey:@"myPhoneNO"];
        if ([str length]>0)
        {
            [self.modelEngineVoip setVoipPhone:str];
        }
        NSMutableArray *rmArray = [[NSMutableArray alloc] init];

        for (AccountInfo* accountinf in self.modelEngineVoip.accountArray)
        {
            if ([accountinf.voipId isEqualToString:self.userBasic.voipId])
            {
                [rmArray addObject:accountinf];
            }
        }
        [self.modelEngineVoip.accountArray removeObjectsInArray:rmArray];
        [rmArray release];
        

        NSString* strVersion = [self.modelEngineVoip getLIBVersion];
        NSLog(@"%@",strVersion);
    }
    if (event == ERegistering)
    {
    }
    else if (event == ERegisterFail)
    {
        [self dismissProgressingView];
        [self  popPromptViewWithMsg:@"登录失败，请稍后重试！" AndFrame:CGRectMake(0, 160, 320, 30)];
    }
    else if (event == ERegisterNot)
    {
        [self dismissProgressingView];
    }
}

@end
