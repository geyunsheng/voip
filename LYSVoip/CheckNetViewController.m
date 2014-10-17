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

#import "CheckNetViewController.h"
#import "AsyncUdpSocket.h"
@interface CheckNetViewController ()

@end

@implementation CheckNetViewController

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
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    self.title = @"网络检测";
    
    UIView* selfview = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    selfview.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    self.view = selfview;
    [selfview release];
    
    lbSend = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 180.f, 20.0f)] ;
    lbSend.backgroundColor = [UIColor clearColor];
    lbSend.textColor = [UIColor blackColor];
    lbSend.textAlignment = UITextAlignmentLeft;
    lbSend.font = [UIFont systemFontOfSize:15.0f];
    lbSend.text =  @"总发包数（包）：0";
    [self.view addSubview:lbSend];
        
    lbReceived = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 50.0f, 180.f, 20.0f)] ;
    lbReceived.backgroundColor = [UIColor clearColor];
    lbReceived.textColor = [UIColor blackColor];
    lbReceived.textAlignment = UITextAlignmentLeft;
    lbReceived.font = [UIFont systemFontOfSize:15.0f];
    lbReceived.text =  @"总收报数（包）：0";
    [self.view addSubview:lbReceived];
    
    lbLostRate = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 80.0f, 180.f, 20.0f)] ;
    lbLostRate.backgroundColor = [UIColor clearColor];
    lbLostRate.textColor = [UIColor blackColor];
    lbLostRate.textAlignment = UITextAlignmentLeft;
    lbLostRate.font = [UIFont systemFontOfSize:15.0f];
    lbLostRate.text =  @"丢包率（%）：0";
    [self.view addSubview:lbLostRate];
    
    lbMinRevTime = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 110.0f, 180.f, 20.0f)] ;
    lbMinRevTime.backgroundColor = [UIColor clearColor];
    lbMinRevTime.textColor = [UIColor blackColor];
    lbMinRevTime.textAlignment = UITextAlignmentLeft;
    lbMinRevTime.font = [UIFont systemFontOfSize:15.0f];
    lbMinRevTime.text =  @"最小延时（ms）：0";
    [self.view addSubview:lbMinRevTime];
    
    lbMaxRevTime = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 140.0f, 180.f, 20.0f)] ;
    lbMaxRevTime.backgroundColor = [UIColor clearColor];
    lbMaxRevTime.textColor = [UIColor blackColor];
    lbMaxRevTime.textAlignment = UITextAlignmentLeft;
    lbMaxRevTime.font = [UIFont systemFontOfSize:15.0f];
    lbMaxRevTime.text =  @"最大延时（ms）：0";
    [self.view addSubview:lbMaxRevTime];
    
    lbAvgRevTime = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 170.0f, 180.f, 20.0f)] ;
    lbAvgRevTime.backgroundColor = [UIColor clearColor];
    lbAvgRevTime.textColor = [UIColor blackColor];
    lbAvgRevTime.textAlignment = UITextAlignmentLeft;
    lbAvgRevTime.font = [UIFont systemFontOfSize:15.0f];
    lbAvgRevTime.text =  @"平均延时（ms）：0";
    [self.view addSubview:lbAvgRevTime];
    
    UIView* footerView = [[UIView alloc] init];
    footerView.frame = CGRectMake(0, 460-44.0f-44.0f, 320, 44);
    if (IPHONE5)
    {
        footerView.frame = CGRectMake(0, 548-44.0f-44.0f, 320, 44);
    }
    
    UIImageView *imgfooter = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    imgfooter.image = [UIImage imageNamed:@"navigation.png"];
    [footerView addSubview:imgfooter];
    [imgfooter release];
    
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setBackgroundImage:[UIImage imageNamed:@"button02_on.png"] forState:UIControlStateNormal];
    [btnClear setBackgroundImage:[UIImage imageNamed:@"button02_off.png"] forState:UIControlStateHighlighted];
    [btnClear setTitle:@"清空" forState:UIControlStateNormal];
    [btnClear setTitle:@"清空" forState:UIControlStateHighlighted];
    btnClear.frame = CGRectMake(20, 3.5f, 91, 37);
    [btnClear addTarget:self action:@selector(clearLabel) forControlEvents:(UIControlEventTouchUpInside)];
    [footerView addSubview:btnClear];    
    
    UIButton *btnRetry = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRetry setBackgroundImage:[UIImage imageNamed:@"button02_on.png"] forState:UIControlStateNormal];
    [btnRetry setBackgroundImage:[UIImage imageNamed:@"button02_off.png"] forState:UIControlStateHighlighted];
    [btnRetry setTitle:@"重试" forState:UIControlStateNormal];
    [btnRetry setTitle:@"重试" forState:UIControlStateHighlighted];
    btnRetry.frame = CGRectMake(210, 3.5f, 91, 37);
    [btnRetry addTarget:self action:@selector(retryTest) forControlEvents:(UIControlEventTouchUpInside)];
    [footerView addSubview:btnRetry];
    
    [self.view addSubview:footerView];
    [footerView release];
    minRevTime = 60000;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.modelEngineVoip testUdpNet];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    [lbSend release];
    [lbReceived release];
    [lbLostRate release];
    [lbMinRevTime release];
    [lbMaxRevTime release];
    [lbAvgRevTime release];
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated{
    self.modelEngineVoip.UIDelegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.modelEngineVoip.UIDelegate = nil;
}

-(void)clearLabel{
    [self.modelEngineVoip stopUdpTest];
    send = 0;
    notSend = 0;
    received = 0;
    lost = 0;
    minRevTime = 60000;
    maxRevTime = 0;
    sumRevTime = 0;

    [lbSend setText:@"总发包数（包）：0"];
    [lbReceived setText:@"总收报数（包）：0"];
    [lbLostRate setText:@"丢包率（%）：0"];
    [lbMinRevTime setText:@"最小延时（ms）：0"];
    [lbMaxRevTime setText:@"最大延时（ms）：0"];
    [lbAvgRevTime setText:@"平均延时（ms）：0"];    
}

-(void)retryTest{
    [self clearLabel];
    [self.modelEngineVoip testUdpNet];
}

-(void)onTestUdpNetStatus:(int)event andReceivedTime:(NSInteger)ms{
    switch (event)
	{
        case 1:
        {
            send++;
            lbSend.text = [NSString stringWithFormat: @"总发包数（包）：%d",send];
        }
            break;
        case 0:
        {
            ++received;
            lbReceived.text = [NSString stringWithFormat: @"总收报数（包）：%d",received];
            if (ms > maxRevTime) {
                maxRevTime = ms;
            }
            
            if (ms < minRevTime) {
                minRevTime = ms;
            }
            
            sumRevTime+=ms;
            int avgRevTime = sumRevTime / received;
            [lbMinRevTime setText:[NSString stringWithFormat: @"最小延时（ms）：%d",minRevTime]];
            [lbMaxRevTime setText:[NSString stringWithFormat: @"最大延时（ms）：%d",maxRevTime]];
            [lbAvgRevTime setText:[NSString stringWithFormat: @"平均延时（ms）：%d",avgRevTime]];
            float lostRate = (((float)(send - received)* 100) /send);
           // NSLog(@"send is %d, received is %d, %f",send,received,lostRate);
            lbLostRate.text = [NSString stringWithFormat: @"丢包率（%%）：%0.2f",lostRate];
        }
            break;
        case -1:
        {
            notSend++;
            //NSLog(@"noSend count %d",notSend);
        }
            break;
        case -2:
        {
            lost++;
        }
            break;
        default:
            break;
    }
}

@end
