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

#import "ViewController.h"
#import "AppDelegate.h"
#import "VoipCallController.h"
#import "UIselectContactsViewController.h"

#define MAKE_VOIP_FREE_CALL_BUTTON_TAG 200
#define MAKE_VOIP_DIRECT_DIAL_CALL_TAG 201
#define MAKE_VOIP_CALL_BACK_CALL_TAG   202
#define BACKBTN_TAG                    999
@interface ViewController ()

@end

@implementation ViewController
@synthesize voipAccount;
@synthesize tf_Account;
@synthesize scrollView;

-(id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

-(void)selectVoIPAccount
{
    UIselectContactsViewController* selectView = [[UIselectContactsViewController alloc] initWithAccountList:self.modelEngineVoip.accountArray andSelectType:ESelectViewType_VoipView];
    selectView.backView = self;
    [self.navigationController pushViewController:selectView animated:YES];
    [selectView release];
    return;
}

- (void)popToPreView
{
 //   [self hideKeyboard];
    [super popToPreView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"VoIP网络语音电话";
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    UIScrollView* tmpScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    tmpScrollView.contentSize = CGSizeMake(self.view.frame.size.width,self.view.frame.size.height);
    self.scrollView = tmpScrollView;
    [self.view addSubview:tmpScrollView];
    [tmpScrollView release];
    
    UILabel *lbTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 60.0f, 320.0f, 20.0f)] ;
    lbTitle2.backgroundColor = [UIColor clearColor];
    lbTitle2.textColor = [UIColor blackColor];
    lbTitle2.textAlignment = UITextAlignmentLeft;
    lbTitle2.font = [UIFont systemFontOfSize:20.0f];
    lbTitle2.text =  @"拨打VoIP电话";
    [self.scrollView addSubview:lbTitle2];
    [lbTitle2 release];
    
    UIButton *selectCallerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectCallerBtn.frame = CGRectMake(24.0f, 100.0f, 273.0f, 37.0f);
    [selectCallerBtn addTarget:self action:@selector(selectVoIPAccount) forControlEvents:UIControlEventTouchUpInside];
    [selectCallerBtn setTitle:@"请先选择联系人" forState:UIControlStateNormal];
    [selectCallerBtn setBackgroundImage:[UIImage imageNamed:@"voip_button_off.png"] forState:UIControlStateNormal];
    [selectCallerBtn setBackgroundImage:[UIImage imageNamed:@"voip_button_on.png"] forState:UIControlStateHighlighted];
    [self.scrollView addSubview:selectCallerBtn];

    UIImageView *inputImg2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"input_box.png"]];
    inputImg2.frame = CGRectMake(24.0f, 150.0f, 273.0f, 30.0f);
    [self.scrollView addSubview:inputImg2];
    [inputImg2 release];

    UILabel* tfTmp = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 150.0f, 200.0f, 30.0f)] ;
    tfTmp.textAlignment = UITextAlignmentCenter;
    [self.scrollView addSubview:tfTmp];
    self.tf_Account = tfTmp;
    [tfTmp release];
    
    UIButton *voipFreeCallBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voipFreeCallBtn.frame = CGRectMake(24.0f, 220.0f, 273.0f, 37.0f);
    [voipFreeCallBtn addTarget:self action:@selector(makeVoipCall:) forControlEvents:UIControlEventTouchUpInside];
    [voipFreeCallBtn setTitle:@"VoIP呼叫" forState:UIControlStateNormal];
    [voipFreeCallBtn setBackgroundImage:[UIImage imageNamed:@"voip_button_off.png"] forState:UIControlStateNormal];
    [voipFreeCallBtn setBackgroundImage:[UIImage imageNamed:@"voip_button_on.png"] forState:UIControlStateHighlighted];
    [self.scrollView addSubview:voipFreeCallBtn];
    
    UIImageView *imgTips3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voip_status_icon.png"]];
    imgTips3.frame = CGRectMake(25.0f, 320.0f, 9.5f, 9.5f);
    [self.scrollView addSubview:imgTips3];
    [imgTips3 release];
    
    UILabel *lbTips3 = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 320.0f, 270.0f, 20.0f)] ;
    lbTips3.backgroundColor = [UIColor clearColor];
    lbTips3.textColor = [UIColor grayColor];
    lbTips3.textAlignment = UITextAlignmentLeft;
    lbTips3.font = [UIFont systemFontOfSize:13.0f];
    lbTips3.text =  @"连接已准备就绪，可以呼出或接听电话";
    [self.scrollView addSubview:lbTips3];
    [lbTips3 release];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    [self.modelEngineVoip setModalEngineDelegate:self];
}
-(void)viewWillDisappear:(BOOL)animated
{
 //   [self hideKeyboard];
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    self.tf_Account = nil;
    self.voipAccount = nil;
    self.scrollView = nil;
    [super dealloc];
}

//拨打电话
- (void)makeVoipCall:(id)sender
{

    if (tf_Account.text.length > 0 )
    {
        VoipCallController *myVoipCallController = [[VoipCallController alloc]
                                                    initWithCallerName:tf_Account.text
                                                    andCallerNo:self.voipAccount
                                                    andVoipNo:self.voipAccount
                                                    andCallType:0];
        [self presentModalViewController:myVoipCallController animated:YES];
        [myVoipCallController release];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择被叫VoIP账号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    return; 
}

@end
