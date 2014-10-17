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


#import "VoiceCodeStateViewController.h"

@interface VoiceCodeStateViewController ()

@end



@implementation VoiceCodeStateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//参数flag ：语音验证是否成功
- (id)initWithVoiceCodeFlag:(BOOL)_flag;
{
    self = [super init];
    if (self) {
        flag = _flag;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =@"验证状态";
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    if (flag)
    {
        UILabel *lbhead = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 40.0f, 320.0f, 22.0f)] ;
        lbhead.backgroundColor = [UIColor clearColor];
        lbhead.textColor = [UIColor blackColor];
        lbhead.textAlignment = UITextAlignmentCenter;
        lbhead.font = [UIFont systemFontOfSize:20.0f];
        lbhead.text = @"验证成功";
        [self.view addSubview:lbhead];
        [lbhead release];
        
        UILabel *lbText = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 80.0f, 320.0f, 38.0f)] ;
        lbText.backgroundColor = [UIColor clearColor];
        lbText.textColor = [UIColor grayColor];
        lbText.textAlignment = UITextAlignmentCenter;
        lbText.font = [UIFont systemFontOfSize:13.0f];
        lbText.text = @"您输入的验证码与系统生成的一致，完成验证";
        [self.view addSubview:lbText];
        [lbText release];
        
        UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        btn.frame = CGRectMake((320-136)/2, 130, 136.f, 37.0f);
        [btn setBackgroundImage:[UIImage imageNamed:@"botton_off@2x.png"] forState:(UIControlStateNormal)];
        [btn setBackgroundImage:[UIImage imageNamed:@"botton_on@2x.png"] forState:(UIControlStateSelected)];
        [btn setTitle:@"完成" forState:(UIControlStateNormal)];
        [btn setTitle:@"完成" forState:(UIControlStateSelected)];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(popToPreView) forControlEvents:(UIControlEventTouchDown)];
        [self.view addSubview:btn];
    }
    else
    {
        UILabel *lbhead = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 40.0f, 320.0f, 22.0f)] ;
        lbhead.backgroundColor = [UIColor clearColor];
        lbhead.textColor = [UIColor blackColor];
        lbhead.textAlignment = UITextAlignmentCenter;
        lbhead.font = [UIFont systemFontOfSize:20.0f];
        lbhead.text = @"验证失败";
        [self.view addSubview:lbhead];
        [lbhead release];
        
        UILabel *lbText = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 80.0f, 320.0f, 38.0f)] ;
        lbText.backgroundColor = [UIColor clearColor];
        lbText.textColor = [UIColor grayColor];
        lbText.textAlignment = UITextAlignmentCenter;
        lbText.font = [UIFont systemFontOfSize:13.0f];
        lbText.text = @"验证码不正确，请按以下提示操作：";
        [self.view addSubview:lbText];
        [lbText release];
        
        UIButton *btnAgain = [UIButton buttonWithType:(UIButtonTypeCustom)];
        btnAgain.frame = CGRectMake((320-136)/2, 130, 136.f, 37.0f);
        [btnAgain setBackgroundImage:[UIImage imageNamed:@"botton_off@2x.png"] forState:(UIControlStateNormal)];
        [btnAgain setBackgroundImage:[UIImage imageNamed:@"botton_on@2x.png"] forState:(UIControlStateSelected)];
        [btnAgain setTitle:@"返回重新输入" forState:(UIControlStateNormal)];
        [btnAgain setTitle:@"返回重新输入" forState:(UIControlStateSelected)];
        [btnAgain setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnAgain setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btnAgain addTarget:self action:@selector(popToPreView) forControlEvents:(UIControlEventTouchDown)];
        [self.view addSubview:btnAgain];
        
        UIButton *btnGetNewVerifyCode = [UIButton buttonWithType:(UIButtonTypeCustom)];
        btnGetNewVerifyCode.frame = CGRectMake((320-136)/2, 185, 136.f, 37.0f);
        [btnGetNewVerifyCode setBackgroundImage:[UIImage imageNamed:@"yz_botton1_off@2x.png"] forState:(UIControlStateNormal)];
        [btnGetNewVerifyCode setBackgroundImage:[UIImage imageNamed:@"yz_botton1_on@2x.png"] forState:(UIControlStateSelected)];
        [btnGetNewVerifyCode addTarget:self action:@selector(popToPreView) forControlEvents:(UIControlEventTouchDown)];
        [self.view addSubview:btnGetNewVerifyCode];
        
        UIButton *btnEnd = [UIButton buttonWithType:(UIButtonTypeCustom)];
        btnEnd.frame = CGRectMake((320-136)/2, 240, 136.f, 37.0f);
        [btnEnd setBackgroundImage:[UIImage imageNamed:@"yz_botton_on@2x.png"] forState:(UIControlStateNormal)];
        [btnEnd setBackgroundImage:[UIImage imageNamed:@"yz_botton_off@2x.png"] forState:(UIControlStateSelected)];
        [btnEnd setTitle:@"结束演示" forState:(UIControlStateNormal)];
        [btnEnd setTitle:@"结束演示" forState:(UIControlStateSelected)];
        [btnEnd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnEnd setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btnEnd addTarget:self action:@selector(goRootView) forControlEvents:(UIControlEventTouchDown)];
        [self.view addSubview:btnEnd];
    }
}
-(void)goRootView
{
    UIViewController* viewController = [self.navigationController.childViewControllers objectAtIndex:1];
    [self.navigationController popToViewController:viewController animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.modelEngineVoip setUIDelegate:self];
}
@end
