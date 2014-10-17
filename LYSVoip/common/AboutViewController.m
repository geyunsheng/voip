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

#import "AboutViewController.h"
#import "CommonTools.h"

@implementation AboutViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) 
    {
        
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)loadView
{
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    UIView* selfview = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    selfview.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    self.view = selfview;
    [selfview release];
    self.title = @"关于";

    //获取软件的版本号
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* libStr = [self.modelEngineVoip getLIBVersion];
    NSArray * arr = [libStr componentsSeparatedByString:@"#"];
    NSString *libVersion = [arr objectAtIndex:0];
    NSString *appVersion = [infoDict objectForKey:@"CFBundleVersion"];
    NSString *sdkVersion = [self.modelEngineVoip getSDKVersion];
    [self createLabel];
    
    UILabel* appVersionLabel = (UILabel*) [self.view viewWithTag:1000];
    UILabel* sdkVersionLabel = (UILabel*) [self.view viewWithTag:1001];
    UILabel* LibVersionLabel = (UILabel*) [self.view viewWithTag:1002];
    UILabel* createDateLabel = (UILabel*) [self.view viewWithTag:1003];
    UILabel* serverLabel = (UILabel*) [self.view viewWithTag:1004];
    
    appVersionLabel.text = [NSString stringWithFormat:@"六元素通讯平台 V%@",appVersion];
    sdkVersionLabel.text = [NSString stringWithFormat:@"SDK版本:%@",sdkVersion];
    LibVersionLabel.text = [NSString stringWithFormat:@"LIB版本:%@",libVersion];
    createDateLabel.text = [NSString stringWithFormat:@"打包日期：%@",[self.modelEngineVoip getSDKDate]];
    serverLabel.text = [NSString stringWithFormat:@"服务器：%@",self.modelEngineVoip.serverIP];
}

-(void)createLabel
{
    for (int i=0; i<5; i++)
    {
        UILabel *Label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 30.0f+i*40, 300.0f, 40.0f)];
        Label.backgroundColor = [UIColor clearColor];
        if (i == 0)
        {
            Label.textAlignment = UITextAlignmentCenter;
            Label.font = [UIFont systemFontOfSize:20.0f];
        }
        else
        {
            Label.textAlignment = UITextAlignmentLeft;
            Label.font = [UIFont systemFontOfSize:17.0f];
        }
        Label.textColor = [UIColor blackColor];
        
        Label.tag = 1000+i;
        [self.view addSubview:Label];
        [Label release];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    self.modelEngineVoip.UIDelegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.modelEngineVoip.UIDelegate = nil;
}


- (void)dealloc 
{ 
    [super dealloc];
}
@end
