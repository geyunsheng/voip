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


#import "LandingCallsStateViewController.h"
#import "ModelEngineVoip.h"
@interface LandingCallsStateViewController ()

@end

@implementation LandingCallsStateViewController

@synthesize phoneArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithPhoneArray:(NSMutableArray*) phones
{
    self = [super init];
    if (self)
    {
        self.phoneArray = phones;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =@"外呼通知结果";
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];    
    
    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point_bg.png"]];
    pointImg.frame = CGRectMake(0.0f, 0.0f, 320.0f, 29.0f);
    [self.view addSubview:pointImg];
    [pointImg release];
    
    UILabel *lbhead = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 29.0f)] ;
    lbhead.backgroundColor = [UIColor clearColor];
    lbhead.textColor = [UIColor whiteColor];
    lbhead.textAlignment = UITextAlignmentLeft;
    lbhead.font = [UIFont systemFontOfSize:13.0f];
    lbhead.text = [NSString stringWithFormat: @"    正在处理您提交的%d个号码",phoneArray.count];
    [self.view addSubview:lbhead];
    [lbhead release];
    
    int top = 0;
    for (int i = 0; i< phoneArray.count; i++)
    {
        top = 47.0f+(47)*i;
        UILabel *Label = [[UILabel alloc] initWithFrame:CGRectMake(23.0f, top, 276.0f, 42.0f)];
        Label.backgroundColor = [UIColor clearColor];
        Label.font = [UIFont systemFontOfSize:15];
        Label.textAlignment = UITextAlignmentLeft;
        Label.tag = 700+i;
        Label.text = [self.phoneArray objectAtIndex:i];
        [self.view addSubview:Label];
        [Label release];
        
        UILabel *LabelState = [[UILabel alloc] initWithFrame:CGRectMake(150.0f, top, 160.0f, 42.0f)];
        LabelState.backgroundColor = [UIColor clearColor];
        LabelState.font = [UIFont systemFontOfSize:15];
        LabelState.textAlignment = UITextAlignmentLeft;
        LabelState.tag = 800+i;
        LabelState.lineBreakMode = UILineBreakModeWordWrap;
        LabelState.numberOfLines = 0;
        [self.view addSubview:LabelState];
        [LabelState release];
                
        UIImageView* iv = [[UIImageView alloc] init];
        if (i==0)
        {
            LabelState.text = @"";
            iv.image = [UIImage imageNamed:@"status_icon03.png"];
        }
        else if (i==1)
        {
            LabelState.text = @"";
            iv.image = [UIImage imageNamed:@"status_icon04.png"];
        }
        else if (i==2)
        {
            LabelState.text = @"";
            iv.image = [UIImage imageNamed:@"status_icon03.png"];
        }
        else 
        {
            LabelState.text = @"";            
            iv.image = [UIImage imageNamed:@"status_icon01.png"];
        }
        
        iv.frame = CGRectMake(10.0f, top+16, 9.f, 9.f);
        iv.tag = 900+i;
        [self.view addSubview:iv];
        [iv release];
    }
    top += 50;
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn.frame = CGRectMake(114.5f, top, 91.f, 37.0f);
    
    [btn setBackgroundImage:[UIImage imageNamed:@"botton_off@2x.png"] forState:(UIControlStateNormal)];
    [btn setBackgroundImage:[UIImage imageNamed:@"botton_on@2x.png"] forState:(UIControlStateSelected)];
    [btn setTitle:@"完成" forState:(UIControlStateNormal)];
    [btn setTitle:@"完成" forState:(UIControlStateSelected)];
    [btn addTarget:self action:@selector(popToPreView) forControlEvents:(UIControlEventTouchDown)];
    [self.view addSubview:btn];
}


-(void)dealloc
{
    self.phoneArray = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//外呼通知回调
- (void)onLandingCAllsStatus:(CloopenReason*)reason  andCallSid:(NSString*)callSid  andToPhoneNumber:(NSString*)phoneNumber andDateCreated:(NSString*)dateCreated
{
    [self dismissProgressingView];
    UILabel* lblStatus = nil;
    for (UIView *view in self.view.subviews)
    {
        if (view.tag >= 700 && view.tag < 800)
        {
            if ([view isKindOfClass:[UILabel class]])
            {
                if([((UILabel*)view).text isEqualToString:phoneNumber])
                {
                    UIView* status = [self.view viewWithTag:view.tag + 100];
                    if ([status isKindOfClass:[UILabel class]])
                    {
                        lblStatus = (UILabel*)status;
                    }
                }
            }
        }
    }
    
    if (reason.reason == 0)
    {
        
        [theAppDelegate printLog:([NSString stringWithFormat:@"%@调用外呼通知接口成功",phoneNumber])];
        lblStatus.text = @"呼叫成功";
    }
    else
    {
        NSString* str = @"";
        if ([reason.msg length]>0)
        {
            str = reason.msg;
        }
        else if (reason.reason == 121002)
        {
            str = @"计费鉴权失败,余额不足";
        }
        lblStatus.text = [NSString stringWithFormat:@"呼叫失败,错误码：%d %@",reason.reason, str];
        [theAppDelegate printLog:([NSString stringWithFormat:@"%@调用外呼通知接口失败！%@",phoneNumber,reason.msg])];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.modelEngineVoip setUIDelegate:self];
    for (NSString* str in self.phoneArray)
    {
        [self displayProgressingView];
        [self.modelEngineVoip LandingCall:str];
    }
}

@end
