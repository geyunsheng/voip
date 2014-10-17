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
#import "VideoViewController.h"
@interface VideoViewController ()
{
    UILabel *statusLabel;
    UIImageView *imgViewStatus;
    UILabel *timeLabel;
    UILabel *callStatusLabel;
    UIView *localVideoView;
    UIView *remoteVideoView;
    
    NSInteger curCameraIndex;
    BOOL isKickOff;
    
    NSInteger deviceRotate;
    NSInteger remoteRotate;
}
@property (nonatomic, retain) UIView *makeCallView;
@property (nonatomic, retain) UIView *incomingCallView;
@property (nonatomic, retain) UIView *callingView;
@property (nonatomic, retain) NSArray *cameraInfoArr;
-(void)makeCallViewLayout;
-(void)incomingCallViewLayout;
-(void)callingViewLayout;
-(void)switchCamera;
@end


#define ACTION_CALL_VIEW_FRAME CGRectMake(0.0f, self.bgView.frame.size.height-54.0f, 320.0f, 54.0f)
#define ACTION_CALL_VIEW_BACKGROUNTCOLOR [UIColor colorWithRed:75.0f/255.0f green:85.0f/255.0f blue:150.0f/255.0f alpha:1.0f]
extern BOOL globalisVoipView;
@implementation VideoViewController
@synthesize bgView;
@synthesize callID;
@synthesize callerName;
@synthesize voipNo;
@synthesize hangUpButton;
@synthesize acceptButton;
@synthesize makeCallView;
@synthesize incomingCallView;
@synthesize callingView;
@synthesize netStatusLabel;
@synthesize p2pStatusLabel;
@synthesize tipsLabel;
- (id)initWithCallerName:(NSString *)name andVoipNo:(NSString *)voipNop andCallstatus:(NSInteger)status
{
    if (self = [super init])
    {
        self.callerName = name;
        self.voipNo = voipNop;
        hhInt = 0;
        mmInt = 0;
        ssInt = 0;
        callStatus = status;
        isKickOff = NO;
        [self.modelEngineVoip enableLoudsSpeaker:YES];
        
        self.cameraInfoArr = [self.modelEngineVoip getCameraInfo];
        
        //默认使用前置摄像头
        curCameraIndex = self.cameraInfoArr.count-1;
        if (curCameraIndex >= 0)
        {
            CameraDeviceInfo *camera = [self.cameraInfoArr objectAtIndex:curCameraIndex];
            CameraCapabilityInfo *capability = [camera.capabilityArray objectAtIndex:0];
            [self.modelEngineVoip selectCamera:camera.index capability:0 fps:capability.maxfps rotate:Rotate_0];
        }
        
        return self;
    }
    return nil;
}

- (void)loadView
{
    self.navigationController.navigationBar.hidden = YES;
    UIView *tmpView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.bgView = tmpView;
    remoteRotate = 0;
    deviceRotate = 0;
    [tmpView release];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
#if __IPHONE_7_0
        self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
        [self.view addSubview:self.bgView];
#else
        self.view = self.bgView;
#endif
    }
    else
    {
        self.view = self.bgView;
    }
    
    self.bgView.backgroundColor = VIEW_BACKGROUND_COLOR_VIDEO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point_bg.png"]];
    pointImg.frame = CGRectMake(0.0f, 0.0f, 320.0f, 29.0f);
    [self.bgView addSubview:pointImg];
    imgViewStatus = pointImg;
    [pointImg release];
    
    UIImageView *videoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_icon.png"]];
    videoIcon.center = CGPointMake(160.0f, 213.0f);
    [self.bgView addSubview:videoIcon];
    [videoIcon release];
    
    UILabel *statusLabeltmp = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 265.0f, 29.0f)];
    statusLabeltmp.backgroundColor = [UIColor clearColor];
    statusLabeltmp.textColor = [UIColor whiteColor];
    statusLabeltmp.font = [UIFont systemFontOfSize:13.0f];
    statusLabel = statusLabeltmp;
    [self.bgView addSubview:statusLabeltmp];
    [statusLabeltmp release];
    
    UIView *tmpView1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, self.bgView.frame.size.height - 54.0f)];
    remoteVideoView = tmpView1;
    tmpView1.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:tmpView1];
    [tmpView1 release];
    myFrame = remoteVideoView.frame;
    
    UIView *tmpView2 = [[UIView alloc] initWithFrame:CGRectMake(15.0f, self.bgView.frame.size.height>480.0f?330.0f:283.0f, 80.0f, 107.0f)];
    tmpView1.backgroundColor = [UIColor clearColor];
    localVideoView = tmpView2;
    [self.bgView addSubview:tmpView2];
    [tmpView2 release];

    if (callStatus == 0)
    {
        //进来之后先拨号
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString* videoBitRates = [userDefaults objectForKey:VIDEOSTREAM_CONTENT_KEY];//获取当前视频码率
        int videoStreamKey = [userDefaults integerForKey:VIDEOSTREAM_KEY];
        int rates= 150;
        if (videoStreamKey == 1)//如果没有取到视频码率或者码率或者关闭状态默认取150
        {
            if (videoBitRates.length > 0)
                rates = videoBitRates.integerValue;
        }
        
        [self.modelEngineVoip setVideoBitRates:rates];
        self.callID = [self.modelEngineVoip makeCall:self.voipNo withPhone:nil withType:EVoipCallType_Video withVoipType:1];
        
        if (self.callID.length <= 0)//获取CallID失败，即拨打失败
        {
            statusLabel.text = @"对方不在线或网络不给力";
        }
        [self makeCallViewLayout];
    }
    else if(callStatus == 1)
    {
        statusLabel.text = [NSString stringWithFormat:@"%@邀请您进行视频通话", self.voipNo];
        [self incomingCallViewLayout];
    }

}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kKickedOff)
    {
        if (buttonIndex == 1)
        {
            exit(0);
        }
        else
        {
            [self dismissModalViewControllerAnimated:YES];
            [theAppDelegate logout];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    globalisVoipView = YES;
    
    [self.modelEngineVoip setModalEngineDelegate:self];
    
    //视频
    [self.modelEngineVoip setVideoView:remoteVideoView andLocalView:localVideoView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    globalisVoipView = NO;
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [self.modelEngineVoip enableLoudsSpeaker:NO];
    [super viewDidDisappear:animated];
}

- (void)updateRealtimeLabel
{
    ssInt +=1;
    if (ssInt >= 60) {
        mmInt += 1;
        ssInt -= 60;
        if (mmInt >=  60) {
            hhInt += 1;
            mmInt -= 60;
            if (hhInt >= 24) {
                hhInt = 0;
            }
        }
    }
    if (p2pFlag)
    {
        p2pStatusLabel.text = @"p2p服务器设置已启用...";
    }
    if(ssInt > 0 && ssInt % 4 == 0 )
    {
        StatisticsInfo * info =[self.modelEngineVoip getCallStatistics];
        double lost = info.rlFractionLost / 255.f;
        callStatusLabel.text = [NSString stringWithFormat:@"丢包率%0.2f%%",lost];
        
        NetworkStatistic* networkStatistic = [self.modelEngineVoip.VoipCallService getNetworkStatisticWithCallId:self.callID];
        if (networkStatistic)
        {
            self.netStatusLabel.text = [NSString stringWithFormat:@"发送：%0.2f（kB）接收：%0.2f（kB）",networkStatistic.txBytes / 1024.,networkStatistic.rxBytes / 1024.];
        }
    }
    if (hhInt > 0) {
        timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hhInt,mmInt,ssInt];
    }
    else
    {
        timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",mmInt,ssInt];
    }
}

- (void)updateRealTimeStatusLabel
{
    statusLabel.text = @"正在挂机..."; 
}

- (void)backFront
{
    if ([timer isValid])
    {
        [timer invalidate];
        timer = nil;
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    self.callID = nil;
    self.callerName = nil;
    self.voipNo = nil;
    self.hangUpButton = nil;
    self.acceptButton = nil;
    self.incomingCallView = nil;
    self.callingView = nil;
    self.makeCallView =nil;
    self.netStatusLabel = nil;
    self.p2pStatusLabel = nil;
    self.cameraInfoArr = nil;
    self.bgView = nil;
    self.tipsLabel = nil;
    [super dealloc];
}

#pragma mark - ModelEngineUIDelegate
-(void)responseVoipManagerStatus:(ECallStatusResult)event callID:(NSString*)callid data:(NSString *)data
{
    if (![self.callID isEqualToString:callID])
    {
        return;
    }
    switch (event)
    {
        case ECallStatus_Proceeding:
        {
            statusLabel.text = @"呼叫中...";
        }
            break;
        case ECallStatus_Alerting:
        {
            statusLabel.text = @"等待对方接听";
        }
            break;
            
        case ECallStatus_Answered:
        {
            [self callingViewLayout];
            statusLabel.text = @"通话中...";
            timeLabel.text = @"00:00";
            if (![timer isValid])
            {
                timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateRealtimeLabel) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                [timer fire];
            }
            [self.modelEngineVoip enableLoudsSpeaker:YES];
            [self onDeviceOrientationChange];
        }
            break;
        case ECallStatus_Failed:
        {
            statusLabel.text = data;
            if( data.intValue == EReasonNoResponse)
            {
                statusLabel.text = @"网络不给力";
            }
            else if( data.intValue == EReasonBadCredentials )
            {
                statusLabel.text = @"鉴权失败";
            }
            else if ( data.intValue == EReasonBusy || data.intValue == EReasonDeclined )
            {
                statusLabel.text = @"您拨叫的用户正忙，请稍后再拨";
            }
            else if( data.intValue == EReasonNotFound)
            {
                statusLabel.text = @"对方不在线";
            }
            else if( data.intValue == EReasonCallMissed )
            {
                statusLabel.text = @"呼叫超时";
            }
            else if( data.intValue == EReasonNoNetwork )
            {
                statusLabel.text = @"当前无网络";
            }
            else if( data.intValue == 170007)
            {
                statusLabel.text = @"该版本不支持此功能";
            }
            else if( data.intValue == EReasonCalleeNoVoip )
            {
                statusLabel.text = @"对方版本不支持视频";
            }
            else if( data.intValue == 700 )
            {
                statusLabel.text = @"第三方鉴权地址连接失败";
            }
            else if( data.intValue == 701 )
            {
                statusLabel.text = @"主账号余额不足";
            }
            else if( data.intValue == 702 )
            {
                statusLabel.text = @"主账号无效（未找到应用信息）";
            }
            else if( data.intValue == 703 )
            {
                statusLabel.text = @"呼叫受限，外呼号码限制呼叫";
            }
            else if( data.intValue == 704 )
            {
                statusLabel.text = @"未上线应用仅限呼叫已配置号码";
            }
            else if( data.intValue == 705 )
            {
                statusLabel.text = @"第三方鉴权失败，子账号余额不足";
            }
            else if( data.intValue == 706 )
            {
                statusLabel.text = @"无被叫号码";
            }
            else if( data.intValue == 710 )
            {
                statusLabel.text = @"第三方主账号余额不足";
            }
            else if( data.intValue == 488 )
            {
                statusLabel.text = @"媒体协商失败";
            }
            else if( data.intValue == 408 )
            {
                statusLabel.text = @"呼叫超时";
            }
            else
            {
                statusLabel.text = @"呼叫失败";
            }
            [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(hangup) userInfo:nil repeats:NO];
        }
            break;
            
        case ECallStatus_Released:
        {
            if ([self.callID isEqualToString:callid])
            {
                if ([timer isValid])
                {
                    [timer invalidate];
                    timer = nil;
                }
                
                statusLabel.text = @"正在挂机...";
                if (!isKickOff)
                    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
            }
        }
            break;
        default:
            break;
    }
}

- (void)hangup
{
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    statusLabel.text = @"正在挂机...";
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(releaseCall) userInfo:nil repeats:NO];
}

- (void)accept
{
    [self performSelector:@selector(answer) withObject:nil afterDelay:0.1];
}
- (void)answer
{
    NSInteger ret = [self.modelEngineVoip acceptCall:self.callID withType:EVoipCallType_Video];
    if (ret == 0)
    {
        [self callingViewLayout];
    }
    else
    {
        [self backFront];
    }
    [self onDeviceOrientationChange];
}

- (void)releaseCall
{
    [self.modelEngineVoip releaseCall:self.callID];
}

-(void)makeCallViewLayout
{
    statusLabel.text = @"正在等待对方接受邀请......";
    if (self.makeCallView == nil)
    {
        self.makeCallView = [[[UIView alloc] initWithFrame:ACTION_CALL_VIEW_FRAME] autorelease];
        [self.bgView addSubview:self.makeCallView];
        self.makeCallView.backgroundColor = ACTION_CALL_VIEW_BACKGROUNTCOLOR;
        UIButton* hangupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.makeCallView addSubview:hangupBtn];
        hangupBtn.frame = CGRectMake(15.0f, 6.0f, 291.0f, 42.0f);
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button2_on.png"] forState:UIControlStateHighlighted];
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button2_off.png"] forState:UIControlStateNormal];
        [hangupBtn setTitle:@"结束视频通话" forState:UIControlStateNormal];
        hangupBtn.titleLabel.textColor = [UIColor whiteColor];
        [hangupBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [self.bgView bringSubviewToFront:self.makeCallView];
    }
}

-(void)incomingCallViewLayout
{
    if (self.incomingCallView == nil)
    {
        self.incomingCallView = [[[UIView alloc] initWithFrame:ACTION_CALL_VIEW_FRAME] autorelease];
        [self.bgView addSubview:self.incomingCallView];
        self.incomingCallView.backgroundColor = ACTION_CALL_VIEW_BACKGROUNTCOLOR;
        UIButton* answerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.incomingCallView addSubview:answerBtn];
        answerBtn.frame = CGRectMake(15.0f, 6.0f, 201.0f, 42.0f);
        [answerBtn setBackgroundImage:[UIImage imageNamed:@"video_button_on.png"] forState:UIControlStateHighlighted];
        [answerBtn setBackgroundImage:[UIImage imageNamed:@"video_button_off.png"] forState:UIControlStateNormal];
        [answerBtn setTitle:@"开始视频通话" forState:UIControlStateNormal];
        answerBtn.titleLabel.textColor = [UIColor whiteColor];
        [answerBtn addTarget:self action:@selector(answer) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* hangupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.incomingCallView addSubview:hangupBtn];
        hangupBtn.frame = CGRectMake(15.0f+210.0f+13.0f, 6.0f, 76.0f, 42.0f);
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button1_on.png"] forState:UIControlStateHighlighted];
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button1_off.png"] forState:UIControlStateNormal];
        [hangupBtn setTitle:@"结束" forState:UIControlStateNormal];
        hangupBtn.titleLabel.textColor = [UIColor whiteColor];
        [hangupBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
        
    }
    else
    {
        [self.bgView bringSubviewToFront:self.incomingCallView];
    }
}

-(void)callingViewLayout
{
    callStatus = 1;
    statusLabel.hidden = YES;
    imgViewStatus.hidden = YES;
    if (self.callingView == nil)
    {
        self.callingView = [[[UIView alloc] initWithFrame:ACTION_CALL_VIEW_FRAME] autorelease];
        [self.bgView addSubview:self.callingView];
        self.callingView.backgroundColor = ACTION_CALL_VIEW_BACKGROUNTCOLOR;

        UILabel *labeltmp = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 15.0f, 140.0f, 24.0f)];
        labeltmp.backgroundColor =  [UIColor clearColor];
        [self.callingView addSubview:labeltmp];
        labeltmp.textColor = [UIColor whiteColor];
        labeltmp.text = [NSString stringWithFormat:@"与%@视频通话中", (self.voipNo.length>3?[self.voipNo substringFromIndex:(self.voipNo.length-3)]:@"")];
        self.tipsLabel = labeltmp;
        [labeltmp release];
        
        UILabel *timeLabeltmp = [[UILabel alloc] initWithFrame:CGRectMake(155.0f, 15.0f, 60.0f, 24.0f)];
        timeLabel = timeLabeltmp;
        timeLabeltmp.backgroundColor =  [UIColor clearColor];
        [self.callingView addSubview:timeLabeltmp];
        timeLabeltmp.textColor = [UIColor whiteColor];
        timeLabeltmp.textAlignment = NSTextAlignmentRight;
        [timeLabeltmp release];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 2.0f, 200.0f, 13.0f)];
        label.backgroundColor =  [UIColor clearColor];
        callStatusLabel = label;
        [self.callingView addSubview:callStatusLabel];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:11];
        [label release];
        
        
        UILabel *tmplabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 40.0f, 300.0f, 13.0f)];
        tmplabel.backgroundColor =  [UIColor clearColor];
        self.netStatusLabel = tmplabel;
        [self.callingView addSubview:self.netStatusLabel];
        tmplabel.textColor = [UIColor whiteColor];
        tmplabel.font = [UIFont systemFontOfSize:11];
        [tmplabel release];
        
        UILabel *tempp2pstatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 2.0f, 130.0f, 13.0f)];
        tempp2pstatusLabel.textColor = [UIColor whiteColor];
        tempp2pstatusLabel.backgroundColor = [UIColor clearColor];
        self.p2pStatusLabel = tempp2pstatusLabel;
        [self.callingView addSubview:self.p2pStatusLabel];
        tempp2pstatusLabel.font = [UIFont systemFontOfSize:11];
        [tempp2pstatusLabel release];
        
        
        UIButton* hangupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.callingView addSubview:hangupBtn];
        hangupBtn.frame = CGRectMake(15.0f+210.0f+13.0f, 6.0f, 76.0f, 42.0f);
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button1_on.png"] forState:UIControlStateHighlighted];
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"video_button1_off.png"] forState:UIControlStateNormal];
        [hangupBtn setTitle:@"结束" forState:UIControlStateNormal];
        hangupBtn.titleLabel.textColor = [UIColor whiteColor];
        [hangupBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.cameraInfoArr.count>1)
        {
            UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [switchBtn setImage:[UIImage imageNamed:@"camera_switch.png"] forState:UIControlStateNormal];
            switchBtn.frame = CGRectMake(230.0f, 35.0f, 70.0f, 35.0f);
            [self.bgView addSubview:switchBtn];
            [switchBtn addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
        }
        
        UIButton *screenshotBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        screenshotBtn.frame = CGRectMake(230.0f, 80, 70.0f, 35.0f);
        [screenshotBtn setTitle:@"远端截图" forState:(UIControlStateNormal)];
        [self.bgView addSubview:screenshotBtn];
        [screenshotBtn addTarget:self action:@selector(screenshotRemote) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *switchMediaTypeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        switchMediaTypeBtn.frame = CGRectMake(220.0f, 120.0f, 90.0f, 35.0f);
        [switchMediaTypeBtn setTitle:@"切换音视频" forState:(UIControlStateNormal)];
        [self.bgView addSubview:switchMediaTypeBtn];
        [switchMediaTypeBtn addTarget:self action:@selector(switchMediaType:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [self.bgView bringSubviewToFront:self.callingView];
    }
    
}
//账号在其他客户端登录消息提示
-(void)responseKickedOff
{
    isKickOff = YES;
    if ([timer isValid])
    {
        [timer invalidate];
        timer = nil;
    }
    [self.modelEngineVoip releaseCall:self.callID];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"下线提示" message:@"该账号在其他设备登录，你已经下线。" delegate:nil cancelButtonTitle:@"重新登录" otherButtonTitles: @"退出",nil];
    alertView.delegate = self;
    alertView.tag = kKickedOff;
    [alertView show];
    [alertView release];
}

-(void)screenshotRemote
{
    [NSThread detachNewThreadSelector:@selector(screenshot) toTarget:self withObject:nil];
}

-(void)screenshot
{
    if ([self.modelEngineVoip getRemoteVideoSnapshotWithCallid:self.callID] == 0)
    {
        NSLog(@"截图成功，请前往相册查看!");
        self.tipsLabel.font = [UIFont systemFontOfSize:11];
        self.tipsLabel.text = @"截图成功，请前往相册查看!";
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        for (int i=1; i<=11; i++)
        {
            [self performSelector:@selector(changeTextColor) withObject:self afterDelay:.3 * i];
        }
        [self performSelector:@selector(showTipsLabel) withObject:self afterDelay:4];
    }
}

-(void)changeTextColor
{
    if (self.tipsLabel.textColor == [UIColor orangeColor])
    {
        self.tipsLabel.textColor = [UIColor whiteColor];
    }
    else
        self.tipsLabel.textColor = [UIColor orangeColor];
}

-(void)showTipsLabel
{
    self.tipsLabel.textColor = [UIColor whiteColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:17];
    self.tipsLabel.text = [NSString stringWithFormat:@"与%@视频通话中", (self.voipNo.length>3?[self.voipNo substringFromIndex:(self.voipNo.length-3)]:@"")];
}


-(void)switchMediaType:(id)sender
{
    NSInteger type = [self.modelEngineVoip.VoipCallService getCallMediaType:self.callID];
    NSLog(@"current media type = %d",type);
    
    if (type == EVoipCallType_Video)
    {
        type = EVoipCallType_Voice;
    }
    else
    {
        type = EVoipCallType_Video;
    }
    [self.modelEngineVoip.VoipCallService updateCallMedia:self.callID withType:type];
}


-(void)switchCamera
{
    curCameraIndex ++;
    if (curCameraIndex >= self.cameraInfoArr.count)
    {
        curCameraIndex = 0;
    }
    CameraDeviceInfo *camera = [self.cameraInfoArr objectAtIndex:curCameraIndex];
    CameraCapabilityInfo *capability = [camera.capabilityArray objectAtIndex:0];
    [self.modelEngineVoip selectCamera:camera.index capability:0 fps:capability.maxfps rotate:Rotate_0];
}


-(void)onFirewallPolicyEnabled
{
    p2pFlag = YES;
}


-(void)onDeviceOrientationChange
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    NSInteger value = 1;
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:
        {
            deviceRotate = 0;
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
        {
            deviceRotate = 180;
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
            if (curCameraIndex == 0 && self.cameraInfoArr.count > 1)
            {
                value = -1;
            }
            deviceRotate = 270;
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            if (curCameraIndex == 0 && self.cameraInfoArr.count > 1)
            {
                value = -1;
            }
            deviceRotate = 90;
        }
            break;
        default:
            return;
    }
    [self transformRemoteView];
    NSLog(@"[VideoViewController notifyTo sendRotate %d]",deviceRotate*value);
    [self.modelEngineVoip.VoipCallService notifyTo:self.voipNo AndVideoRotate:deviceRotate*value];
}

- (void)onMessageRemoteVideoRotate:(NSString*)degree
{
    NSLog(@"[VideoViewController onMessageRemoteVideoRotate degree %@]",degree);
    remoteRotate = [degree integerValue];
    [self transformRemoteView];
}

- (void)transformRemoteView
{
    if ((deviceRotate==0 && remoteRotate==0)
        || (deviceRotate==90 && abs(remoteRotate)==270)
        || (deviceRotate==180 && remoteRotate==180)
        || (deviceRotate==270 && abs(remoteRotate)==90)
        )
    {
        int value = 0;
        if (remoteRotate < 0)
        {
                value = 1;
        }
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI*value);
        remoteVideoView.transform = CGAffineTransformScale(transform, 1.0,1.0);
    }
    else if ((deviceRotate==0 && abs(remoteRotate)==90)
             || (deviceRotate==90 && remoteRotate==0)
             || (deviceRotate==180 && abs(remoteRotate)==270)
             || (deviceRotate==270 && remoteRotate==180))
    {
        int value = 1;
        if (remoteRotate < 0)
        {
                value = -1;
        }
        CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI/2*value);
        if (IPHONE5)
        {
            remoteVideoView.transform = CGAffineTransformScale(transform, 0.75,0.75);
        }
        else
        {
            remoteVideoView.transform = CGAffineTransformScale(transform, 0.95,0.95);
        }
    }
    else if ((deviceRotate==0 && remoteRotate==180)
             || (deviceRotate==90 && abs(remoteRotate)==90)
             || (deviceRotate==180 && remoteRotate==0)
             || (deviceRotate==270 && abs(remoteRotate)==270))
    {
        int value = 1;
        if (remoteRotate < 0)
        {
                value = 0;
        }
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI*value);
        remoteVideoView.transform = CGAffineTransformScale(transform, 1.0,1.0);
    }
    else if ((deviceRotate==0 && abs(remoteRotate)==270)
             || (deviceRotate==90 && remoteRotate==180)
             || (deviceRotate==180 && abs(remoteRotate)==90)
             || (deviceRotate==270 && remoteRotate==0))
    {
        int value = 1;
        if (remoteRotate < 0)
        {
                value = -1;
        }
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2 * value);
        if (IPHONE5)
        {
            remoteVideoView.transform = CGAffineTransformScale(transform, 0.75,0.75);
        }
        else
        {
            remoteVideoView.transform = CGAffineTransformScale(transform, 0.95,0.95);
        }
    }
    
    UIView *displayView = nil;
    for (UIView * view in remoteVideoView.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"IOSDisplay")]) {
            displayView = view;
            NSLog(@"IOSDisplay= %@", view);
        }
    }
    displayView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 494.0f);
}
@end
