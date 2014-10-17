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

#import "VideoConfIntroduction.h"
#import "VideoConfListViewController.h"

@interface VideoConfIntroduction ()

@end

@implementation VideoConfIntroduction
-(void)dealloc
{
    self.backView = nil;
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setFullScreen:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
      [self setFullScreen:NO];
}

- (void)setFullScreen:(BOOL)fullScreen
{
      // 导航条
     [self.navigationController setNavigationBarHidden:fullScreen];
}

- (void)loadView
{
   
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    self.title  = @"视频会议";
    NSString* fileStr = Nil;
    CGRect range;
    
    if (IPHONE5)
    {
        fileStr = @"videoConfInfo_1136.jpg";
        range = CGRectMake(0, 0, 320, 576);
    }
    else
    {
        fileStr = @"videoConfInfo.jpg";
        range = CGRectMake(0, 0, 320, 480);
    }
    int value = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
#if __IPHONE_7_0
        value = 20;
#else
        value = 0;
#endif
    }
    
    UIImage* imBg = [UIImage imageNamed:fileStr];
    UIImageView* ivBg = [[UIImageView alloc] initWithImage:imBg];
    ivBg.frame = range;
    [self.view addSubview:ivBg];
    [ivBg release];
    
    UILabel* lab1;
    lab1 = [[UILabel alloc] init];
    lab1.frame = CGRectMake(11, range.size.height - 11 - 44 - 26 -11 - 26 - 11 - 46 - value, 298, 46);
    lab1.text = @"能力介绍：云通讯视频会议能力提供多路交叉视频及一对多视频（可手动切换或自动切到发言方）并支持电话用户语音加入，同时提供丰富的会议管理能力以满足不同应用场景。";
    lab1.textColor = [UIColor whiteColor];
    lab1.font = [UIFont boldSystemFontOfSize:11];
    lab1.backgroundColor = [UIColor clearColor];
    lab1.tag = 1001;
    [self.view addSubview:lab1];
    lab1.lineBreakMode = UILineBreakModeWordWrap;
    lab1.numberOfLines = 0;
    [lab1 release];
    
    UILabel* lab2;
    lab2 = [[UILabel alloc] initWithFrame:CGRectMake(11, range.size.height - 11 - 44 - 26- 11 - 26 - value, 298, 31)];
    lab2.textColor = [UIColor whiteColor];
    lab2.text = @"Demo演示一对多视频会议，即多方查看一方视频、可手动切换，语音为多方实时参与。";
    lab2.font = [UIFont systemFontOfSize:11];
    lab2.backgroundColor = [UIColor clearColor];
    lab2.tag = 1001;
    lab2.lineBreakMode = UILineBreakModeWordWrap;
    lab2.numberOfLines = 0;
    [self.view addSubview:lab2];
    [lab2 release];
    
    UIButton* btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [btn setBackgroundImage:[UIImage imageNamed:@"videoConf60.png"] forState:(UIControlStateNormal)];
    [btn setBackgroundImage:[UIImage imageNamed:@"videoConf60_on.png"] forState:(UIControlStateSelected)];
    btn.frame = CGRectMake(11, range.size.height - 11 - 44 - 31 + value, 298, 44);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(goNext) forControlEvents:(UIControlEventTouchUpInside)];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)goNext
{
    VideoConfListViewController* view = [[VideoConfListViewController alloc] init];
    view.backView = self.backView;
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end