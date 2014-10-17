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

#import "VideoConfViewController.h"
#import "UICustomView.h"
#import <QuartzCore/QuartzCore.h>

#define VideoConfVIEW_BACKGROUND_COLOR [UIColor colorWithRed:35.0f/255.0f green:47.0f/255.0f blue:60.0f/255.0f alpha:1.0f]

#define VideoConfVIEW_addmember 9998
#define VideoConfVIEW_ConfDisslove 9997
#define VideoConfVIEW_kickOff 9996

#define VideoConfVIEW_exitAlert 9995
#define VideoConfVIEW_dissolve 9999

#define VideoConfVIEW_BtnChangeCam 8001
#define VideoConfVIEW_BtnMic    8002
#define VideoConfVIEW_BtnSwitchCam 8003
#define VideoConfVIEW_BtnExit 8004

#define VideoConfVIEW_ViewMain     7000
#define VideoConfVIEW_View1        7001
#define VideoConfVIEW_View2        7002
#define VideoConfVIEW_View3        7003
#define VideoConfVIEW_View4        7004
#define VideoConfVIEW_View5        7005

#define VideoConfVIEW_ViewPrompt   6001

#define VideoConfJoinErrAlert      4001

#define VideoConfQueryMemberAlert  4002

#define VideoConfSendTime          10
@interface VideoConfViewController ()
{
    UILabel *statusView;
    UILabel *tipsLabel;
    BOOL isMute;
}
@property (nonatomic, retain) NSMutableArray *membersArray;
@end

@implementation VideoConfViewController
@synthesize backView;
@synthesize curVideoConfId;
@synthesize Confname;
@synthesize membersArray;
@synthesize isCreator;
@synthesize isCreatorExit;
@synthesize mainView,view1,view2,view3,view4,view5;
@synthesize sendPortraitTimer;
@synthesize pointImg;
@synthesize myAlertView;
@synthesize bgView;
- (id)init
{
    self = [super init];
    if (self)
    {
        [self.modelEngineVoip enableLoudsSpeaker:YES];
        self.isCreatorExit = NO;
        self.cameraInfoArr = [self.modelEngineVoip getCameraInfo];
        
        //默认使用前置摄像头
        curCameraIndex = self.cameraInfoArr.count-1;
        if (curCameraIndex >= 0)
        {
            CameraDeviceInfo *camera = [self.cameraInfoArr objectAtIndex:curCameraIndex];
            CameraCapabilityInfo *capability = [camera.capabilityArray objectAtIndex:0];
            [self.modelEngineVoip selectCamera:camera.index capability:0 fps:capability.maxfps rotate:Rotate_Auto];
        }
        // Custom initialization
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    @try
    {
        if (alertView.tag == VideoConfVIEW_ConfDisslove|| alertView.tag == VideoConfVIEW_kickOff)
        {
            if (self.myAlertView)
            {
                [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
            }
            [self exitCurVideoConf];
        }
        else if (alertView.tag ==  VideoConfVIEW_dissolve)
        {
            if (buttonIndex == 0)
            {
                [self displayProgressingView];
                [self.modelEngineVoip dismissVideoConferenceWithAppId:self.modelEngineVoip.appID andVideoConference:self.curVideoConfId];
            }
        }
        else if(alertView.tag ==  VideoConfVIEW_addmember)
        {
            
        }
        else if(alertView.tag == VideoConfVIEW_exitAlert)
        {
            if (buttonIndex == 0)
            {
                 [self exitCurVideoConf];
            }
        }
        else if(alertView.tag == VideoConfJoinErrAlert)
        {
            [self backToView];
        }
        else if(alertView.tag == VideoConfQueryMemberAlert)
        {
            if (isCreator)
            {
                isCreatorExit = YES;
                [self displayProgressingView];
                [self.modelEngineVoip dismissVideoConferenceWithAppId:self.modelEngineVoip.appID andVideoConference:self.curVideoConfId];
            }
            else
                [self exitCurVideoConf];
        }
        else if (alertView.tag == kKickedOff)
        {
            if (buttonIndex == 1)
            {
                exit(0);
            }
            else
            {
                [self dismissProgressingView];
                [theAppDelegate logout];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
    }
}

-(void)dissolve
{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"退出视频会议" message:@"真的要结束会议吗？" delegate:self cancelButtonTitle:@"结束" otherButtonTitles:@"取消", nil];
    if (self.myAlertView)
    {
         [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    self.myAlertView = alertview;
    alertview.tag = VideoConfVIEW_dissolve;
    [alertview show];
    [alertview release];
   
}


- (void)loadView
{
    self.title = Confname;
    
    UIView *tmpView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.bgView = tmpView;
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
    self.bgView.backgroundColor = VideoConfVIEW_BACKGROUND_COLOR;
    
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
    [self.bgView addSubview:ivBg];
    [ivBg release];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_Tips.png"]];
    NSMutableArray *  images = [[NSMutableArray alloc] init];
    [images addObject:[UIImage imageNamed:@"video_Tips.png"]];
    [images addObject:[UIImage imageNamed:@"video_new_tips.png"]];
    imgView.animationImages = images;
    [images release];
    imgView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 22);
    [self.bgView addSubview:imgView];
    self.pointImg = imgView;
    self.pointImg.animationDuration = 0.5;//设置动画时间
    self.pointImg.animationRepeatCount = 6;//设置动画次数 0 表示无限
    [imgView release];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.0f, 0.0f, 265.0f, 22)];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont systemFontOfSize:13.0f];
    statusView = statusLabel;
    statusLabel.text = [NSString stringWithFormat:@"正在加入会议..."];
    [self.bgView addSubview:statusLabel];
    [statusLabel release];
    
   
    VideoView* _mainView = [[VideoView alloc] initWithFrame:CGRectMake(11, 33, 195, 195)];
    _mainView.myDelegate = self;
    _mainView.voipLabel.text = @"";
    _mainView.tag = VideoConfVIEW_ViewMain;
    _mainView.icon.hidden = YES;
    [self.bgView addSubview:_mainView];
    self.mainView = _mainView;
    [_mainView release];
    
    VideoView* _view1 = [[VideoView alloc] initWithFrame:CGRectMake(mainView.frame.origin.x+mainView.frame.size.width+11, 33, 92, 92)];
    _view1.tag = VideoConfVIEW_View1;
    _view1.videoLabel.text  = @"";
    _view1.myDelegate = self;
    [self.bgView addSubview:_view1];
    self.view1 = _view1;
    [_view1 release];
    
    VideoView* _view2 = [[VideoView alloc] initWithFrame:CGRectMake(view1.frame.origin.x, view1.frame.origin.y+92+11, 92, 92)];
    _view2.tag = VideoConfVIEW_View2;
    _view2.myDelegate = self;
    [self.bgView addSubview:_view2];
    self.view2 = _view2;
    [_view2 release];
    
    VideoView* _view3 = [[VideoView alloc] initWithFrame:CGRectMake(mainView.frame.origin.x, mainView.frame.origin.y+195+11, 92, 92)];
    _view3.tag = VideoConfVIEW_View3;
    _view3.myDelegate = self;
    [self.bgView addSubview:_view3];
    self.view3 = _view3;
    [_view3 release];
    
    VideoView* _view4 = [[VideoView alloc] initWithFrame:CGRectMake(mainView.frame.origin.x+92+11, mainView.frame.origin.y+195+11, 92, 92)];
    _view4.tag = VideoConfVIEW_View4;
    _view4.myDelegate = self;
    [self.bgView addSubview:_view4];
    self.view4 = _view4;
    [_view4 release];
    
    VideoView* _view5 = [[VideoView alloc] initWithFrame:CGRectMake(mainView.frame.origin.x+92+11+92+11, mainView.frame.origin.y+195+11, 92, 92)];
    _view5.tag = VideoConfVIEW_View5;
    _view5.myDelegate = self;
    [self.bgView addSubview:_view5];
    self.view5 = _view5;
    [_view5 release];
    
    [self createButtonWithRect:CGRectMake(45-11, range.size.height - 122-11, 44, 44) andTag:VideoConfVIEW_BtnChangeCam andImageName:@"videoConf05"];
    [self createButtonWithRect:CGRectMake(147-11, range.size.height - 122-11, 44, 44) andTag:VideoConfVIEW_BtnMic andImageName:@"videoConf07"];
    //[self createButtonWithRect:CGRectMake(250, range.size.height - 122, 22, 22) andTag:VideoConfVIEW_BtnSwitchCam andImageName:@"videoConf09"];
    [self createButtonWithRect:CGRectMake(11, range.size.height-11-44-20, 298, 44) andTag:VideoConfVIEW_BtnExit andImageName:@"videoConf58"];
    
    
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
    
    BOOL notFirst = [userDefaults boolForKey:@"notFirstVideoConf"];
    if (!notFirst)
    {
        [userDefaults setBool:YES forKey:@"notFirstVideoConf"];
        [userDefaults synchronize];
        //创建提示view
        UIView* viewPrompt = [[UIView alloc] initWithFrame:range];
        viewPrompt.backgroundColor = [UIColor clearColor];
        
        //创建提示view的底色
        UIView* viewPromptBg = [[UIView alloc] initWithFrame:range];
        viewPromptBg.backgroundColor = [UIColor blackColor];
        viewPromptBg.alpha = 0.3;
        [viewPrompt addSubview:viewPromptBg];
        [viewPromptBg release];
        
        UIImageView* iv1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoConf32.png"]];
        iv1.frame = CGRectMake(40, 206, 21, 21);
        [viewPrompt addSubview:iv1];
        [iv1 release];
        
        UILabel* lb1 = [[UILabel alloc] initWithFrame:CGRectMake(69, 208, 220, 20)];
        lb1.backgroundColor = [UIColor clearColor];
        [viewPrompt addSubview:lb1];
        lb1.textColor = [UIColor whiteColor];
        lb1.font = [UIFont systemFontOfSize:15];
        lb1.text = @"点击“  ”可对会议成员进行管理";
        [lb1 release];
        
        UIImageView* iv2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoConf43.png"]];
        iv2.frame = CGRectMake(110, 213, 2, 10);
        [viewPrompt addSubview:iv2];
        [iv2 release];
        
        UIButton* btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [btn setBackgroundImage:[UIImage imageNamed:@"videoConf56.png"] forState:(UIControlStateNormal)];
        [btn setBackgroundImage:[UIImage imageNamed:@"videoConf56_on.png"] forState:(UIControlStateSelected)];
        [btn addTarget:self action:@selector(hidePrompt) forControlEvents:(UIControlEventTouchUpInside)];
        btn.frame = CGRectMake(11, range.size.height-11-44-20, 298, 44);
        [viewPrompt addSubview:btn];
        viewPrompt.tag = VideoConfVIEW_ViewPrompt;
        [self.bgView addSubview:viewPrompt];
        [viewPrompt release];
    }
}


-(void)hidePrompt
{
    for (UIView* view in self.bgView.subviews)
    {
        if (view.tag == VideoConfVIEW_ViewPrompt)
            [view removeFromSuperview];
    }
}
- (void)createButtonWithRect:(CGRect) frame andTag:(NSInteger) tag andImageName:(NSString*) imgName
{
    UIButton* btn= [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn.frame = frame;
    btn.tag = tag;
    [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",imgName]] forState:(UIControlStateNormal)];
    [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_on.png",imgName]] forState:(UIControlStateSelected)];
    if (btn.tag == VideoConfVIEW_BtnChangeCam)
    {
        [btn addTarget:self action:@selector(changeCam:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    else if (btn.tag == VideoConfVIEW_BtnMic)
    {
        [btn addTarget:self action:@selector(muteMic:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    else if (btn.tag == VideoConfVIEW_BtnSwitchCam)
    {
        [btn addTarget:self action:@selector(switchCam:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    else if (btn.tag == VideoConfVIEW_BtnExit)
    {
        [btn addTarget:self action:@selector(showExitAlert:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    [self.bgView addSubview:btn];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setFullScreen:YES];
    [self.modelEngineVoip setUIDelegate:self];
    [self.modelEngineVoip setVideoView:mainView.bgView andLocalView:view1.bgView];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self setFullScreen:NO];
    if(self.sendPortraitTimer)
        [self.sendPortraitTimer invalidate];
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self.modelEngineVoip setMute:NO];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [self.modelEngineVoip enableLoudsSpeaker:NO];
    [super viewDidDisappear:animated];
}

- (void)setFullScreen:(BOOL)fullScreen
{
    // 导航条
    [self.navigationController setNavigationBarHidden:fullScreen];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    [self.pointImg stopAnimating];
    self.pointImg = nil;
    self.membersArray = nil;
    self.curVideoConfId = nil;
    self.cameraInfoArr = nil;
    self.Confname = nil;
    self.sendPortraitTimer = nil;
    self.mainView = nil;
    self.view1 = nil;
    self.view2 = nil;
    self.view3 = nil;
    self.view4 = nil;
    self.view5 = nil;
    self.backView = nil;
    self.curMain = nil;
    self.curMember = nil;
    self.myAlertView = nil;
    self.bgView = nil;
    [super dealloc];
}


- (void)muteMic:(id)sender
{
    isMute = !isMute;
    UIButton *btn = (UIButton*) sender;
    [self.modelEngineVoip setMute:isMute];
    if (isMute)
    {
        [btn setImage:[UIImage imageNamed:@"videoConf13_on.png"] forState:(UIControlStateSelected)];
        [btn setImage:[UIImage imageNamed:@"videoConf13.png"] forState:(UIControlStateNormal)];
    }
    else
    {
        [btn setImage:[UIImage imageNamed:@"videoConf07_on.png"] forState:(UIControlStateSelected)];
        [btn setImage:[UIImage imageNamed:@"videoConf07.png"] forState:(UIControlStateNormal)];
        [self.modelEngineVoip enableLoudsSpeaker:YES];
    }
}

-(void)changeCam:(id)sender
{
    curCameraIndex ++;
    if (curCameraIndex >= self.cameraInfoArr.count)
    {
        curCameraIndex = 0;
    }
    CameraDeviceInfo *camera = [self.cameraInfoArr objectAtIndex:curCameraIndex];
    CameraCapabilityInfo *capability = [camera.capabilityArray objectAtIndex:0];
    [self.modelEngineVoip selectCamera:camera.index capability:0 fps:capability.maxfps rotate:Rotate_Auto];
}

-(void)onChooseIndex:(NSInteger)index andVoipAccount:(NSString*) voip
{
    if (!isCreator)
    {
        return;
    }
    
    if (index == VideoConfVIEW_ViewMain) {
        
    }
    else
    {
        self.curMember = voip;
        int i = 0;
        UIActionSheet *menu = nil;
        //群组类型
        menu = [[UIActionSheet alloc]
                initWithTitle: @"选择"
                delegate:self
                cancelButtonTitle:nil
                destructiveButtonTitle:nil
                otherButtonTitles:nil];
        menu.tag = 100;
        if (![mainView.strVoip isEqualToString:voip]) {
            [menu addButtonWithTitle:@"设为主屏幕"];
            i++;
        }
        
        if ([self.modelEngineVoip.voipAccount isEqualToString:voip]) {
            [menu addButtonWithTitle:@"解散会议"];
            i++;
            if (i == 2)
            {
                menu.tag = 101;
            }
            else
                menu.tag = 102;
        }
        else
        {
            [menu addButtonWithTitle:@"请出会议"];
            i++;
            if (i == 2)
            {
                menu.tag = 103;
            }
            else
                menu.tag = 104;
        }
        
        if (menu != nil)
        {
            if (i > 0)
            {
                [menu addButtonWithTitle:@"取消"];
                [menu setCancelButtonIndex:i];
                [menu showInView:self.view.window];
            }
            [menu release];
        }
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 100) {
        if (buttonIndex == 0)
        {//只有设为主屏幕
            [self displayProgressingView];
            [self.modelEngineVoip switchRealScreenToVoip:self.curMember ofVideoConference:self.curVideoConfId inAppId:self.modelEngineVoip.appID];
        }
    }
    else if (actionSheet.tag == 101)
    {
        if (buttonIndex == 0)//设为主屏幕、解散会议
        {
            [self displayProgressingView];
            [self.modelEngineVoip switchRealScreenToVoip:self.curMember ofVideoConference:self.curVideoConfId inAppId:self.modelEngineVoip.appID];
        }
        else if (buttonIndex == 1)
        {
            [self displayProgressingView];
            [self.modelEngineVoip  dismissVideoConferenceWithAppId:self.modelEngineVoip.appID andVideoConference:self.curVideoConfId];
        }
    }
    else if (actionSheet.tag == 102)
    {
        if (buttonIndex == 0)
        {//解散会议
            [self displayProgressingView];
            [self.modelEngineVoip  dismissVideoConferenceWithAppId:self.modelEngineVoip.appID andVideoConference:self.curVideoConfId];
        }
    }
    else if (actionSheet.tag == 103)
    {//设为主屏幕，踢出会议
        if (buttonIndex == 0)
        {
            [self displayProgressingView];
            [self.modelEngineVoip switchRealScreenToVoip:self.curMember ofVideoConference:self.curVideoConfId inAppId:self.modelEngineVoip.appID];
        }
        else if (buttonIndex == 1)
        {
            [self displayProgressingView];
            [self.modelEngineVoip removeMemberFromVideoConferenceWithAppId:self.modelEngineVoip.appID andVideoConference:self.curVideoConfId andMember:self.curMember];
        }
    }
    else if (actionSheet.tag == 104) {//踢出会议
        if (buttonIndex == 0)
        {
            [self displayProgressingView];
            [self.modelEngineVoip removeMemberFromVideoConferenceWithAppId:self.modelEngineVoip.appID andVideoConference:self.curVideoConfId andMember:self.curMember];
        }
    }
}


- (void)backToView
{
    [self dismissProgressingView];
    [self.navigationController popToViewController:self.backView animated:YES];
}

- (void)reloadMembersData
{
    for (int i = VideoConfVIEW_View1; i<VideoConfVIEW_View1+5; i++)
    {
        VideoConferenceMember* member = nil;
        NSInteger index = i-VideoConfVIEW_View1;
        VideoView* tmpView = (VideoView*)[self.bgView viewWithTag:i];
        if (tmpView)
        {
            if (index < [self.membersArray count])
            {
                member = [self.membersArray objectAtIndex:index];
                if (member)
                {
                    NSLog(@"111111111111 voip is %@ type is %@ screen is %d count is %d",member.number,member.type,member.screenType,self.membersArray.count);
                    tmpView.strVoip = member.number;
                    tmpView.voipLabel.text = [member.number substringFromIndex:[member.number length]-4];
                    tmpView.videoLabel.text = @"";
                    if (isCreator)
                    {
                        tmpView.icon.hidden = NO;
                    }
                    else
                        tmpView.icon.hidden = YES;
                    if (member.screenType == 1)
                    {
                        mainView.strVoip = member.number;
                        mainView.voipLabel.text = [member.number substringFromIndex:[member.number length]-4];
                        mainView.videoLabel.text = @"";
                        tmpView.ivChoose.hidden = NO;
                    }
                    continue;
                }
            }
            tmpView.ivChoose.hidden = YES;
            tmpView.bgView.backgroundColor = [UIColor clearColor];
            tmpView.bgView.layer.contents = nil;
            tmpView.strVoip = nil;
            tmpView.videoLabel.text = @"待加入";
            tmpView.voipLabel.text = @"";
            tmpView.icon.hidden = YES;
        }
    }
}


-(void)showExitAlert:(id)sender
{
    isCreatorExit = YES;//退出不接受通知消息
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"退出视频会议" message:@"真的要退出吗？" delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"取消", nil];
    if (self.myAlertView)
    {
        [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    self.myAlertView = alertview;
    alertview.tag = VideoConfVIEW_exitAlert;
    [alertview show];
    [alertview release];
}
//退出当前的会议
-(void)exitCurVideoConf
{
    if (self.sendPortraitTimer)
    {
        [self.sendPortraitTimer invalidate];
    }
    [self displayProgressingView];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(exitVideoConf) userInfo:nil repeats:NO];
}

-(void)exitVideoConf
{
    [self.modelEngineVoip exitVideoConference];
    [self backToView];
}


/********************会议的方法********************/

//通知客户端收到新的会议信息
- (void)onReceiveVideoConferenceMsg:(VideoConferenceMsg*) msg;
{
    if([msg isKindOfClass:[VideoConferenceJoinMsg class]])
    {
        //有人加入
        VideoConferenceJoinMsg *joinMsg = (VideoConferenceJoinMsg*)msg;
        
        if ([self.curVideoConfId isEqualToString:msg.conferenceId])
        {
            NSInteger joinCount = 0;
            for (NSString *who in joinMsg.joinArr)
            {
                BOOL isJoin = NO;
                for (VideoConferenceMember  *m in self.membersArray )
                {
                    if ([m.number isEqualToString:who])
                    {
                        isJoin = YES;
                        break;
                    }
                }
                if (isJoin)
                {
                    continue;
                }
                
                VideoConferenceMember *member = [[VideoConferenceMember alloc] init];
                member.number = who;
                member.type = @"0";
                member.screenType = 0;
                [self.membersArray addObject:member];
                [member release];
                joinCount++;
            }
            if (joinCount > 0)
            {
                [self.pointImg stopAnimating];
                [self.pointImg startAnimating];
                statusView.text = @"有人加入会议";
                [self reloadMembersData];
            }
        }
    }
    else if([msg isKindOfClass:[VideoConferenceExitMsg class]])
    {
        //有人退出
        VideoConferenceExitMsg *exitMsg = (VideoConferenceExitMsg*)msg;
        if ([self.curVideoConfId isEqualToString:exitMsg.conferenceId])
        {
            NSMutableArray *exitArr = [[NSMutableArray alloc] init];
            for (NSString *who in exitMsg.exitArr)
            {
                for (VideoConferenceMember *member in self.membersArray)
                {
                    if ([who isEqualToString:member.number])
                    {
                        [exitArr addObject:member];
                    }
                }
            }
            if (exitArr.count > 0)
            {
                [self.membersArray removeObjectsInArray:exitArr];
                [self.pointImg stopAnimating];
                [self.pointImg startAnimating];
                statusView.text = @"有人退出会议";
                [self reloadMembersData];
            }
            [exitArr release];
        }
    }
    else if([msg isKindOfClass:[VideoConferenceDismissMsg class]])
    {
        if ([msg.conferenceId isEqualToString:self.curVideoConfId])
        {
            if (isCreatorExit)//创建者退出时解散会议则不提示
            {
                if (self.myAlertView)
                {
                    [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
                }
                [self backToView];
            }
            else
            {
                if(self.sendPortraitTimer)
                {
                    [self.sendPortraitTimer invalidate];
                }

                UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"会议被解散" message:@"抱歉，该会议已经被创建者解散，点击确定可以退出！"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                if (self.myAlertView)
                {
                    [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
                }
                self.myAlertView = alertview;
                alertview.tag = VideoConfVIEW_ConfDisslove;
                [alertview show];
                [alertview release];
            }
        };
    }
    else if([msg isKindOfClass:[VideoConferenceRemoveMemberMsg class]])
    {
        if ([msg.conferenceId isEqualToString: self.curVideoConfId])
        {
            VideoConferenceRemoveMemberMsg* removeMsg = (VideoConferenceRemoveMemberMsg*)msg;
            if ([removeMsg.who isEqualToString:self.modelEngineVoip.voipAccount])//自己被踢出
            {
                if(self.sendPortraitTimer)
                {
                    [self.sendPortraitTimer invalidate];
                }

                UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"您已被请出会议" message:@"抱歉，您被创建者请出会议了，点击确定以退出"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                if (self.myAlertView)
                {
                    [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
                }
                self.myAlertView = alertview;
                
                alertview.tag = VideoConfVIEW_kickOff;
                [alertview show];
                [alertview release];
                return;
            }
            NSInteger* exitCount = 0;
            for (VideoConferenceMember *member in self.membersArray)
            {
                if ([removeMsg.who isEqualToString:member.number])
                {
                    [self.membersArray removeObject:member];
                    exitCount++;
                }
            }
            if (exitCount > 0)
            {
                [self.pointImg stopAnimating];
                [self.pointImg startAnimating];
                statusView.text = @"有人被踢出会议";
                [self reloadMembersData];
            }
        }
    }
    else if([msg isKindOfClass:[VideoConferenceSwitchScreenMsg class]])
    {
        if ([msg.conferenceId isEqualToString: self.curVideoConfId])
        {
            VideoConferenceSwitchScreenMsg* swittchMsg = (VideoConferenceSwitchScreenMsg*)msg;
            for (VideoConferenceMember *member in self.membersArray)
            {
                if ([swittchMsg.displayVoip isEqualToString:member.number])
                {
                    member.screenType = 1;
                }
                else
                {
                    member.screenType = 0;
                }
            }
            [self reloadMembersData];
        }
    }
}


//获取会议的成员
- (void)onVideoConferenceMembersWithReason:(CloopenReason *) reason andData:(NSArray*)members
{
    [self dismissProgressingView];
    if (reason.reason == 0)
    {
        self.membersArray = [[[NSMutableArray alloc] initWithArray:members] autorelease];
        VideoConferenceMember *meInfo = nil;
        for (VideoConferenceMember *member in self.membersArray)
        {
            if ([self.modelEngineVoip.voipAccount isEqualToString:member.number])
            {
                meInfo = member;
                [meInfo retain];
                [self.membersArray removeObject:member];
                break;
            }
        }
        
        if (meInfo)
        {
            [self.membersArray insertObject:meInfo atIndex:0];
            [meInfo release];
        }
        
        [self reloadMembersData];
    }
    else
    {
        UIAlertView *alertview = nil;
        if (isCreator)
        {
             alertview = [[UIAlertView alloc]  initWithTitle:@"提示" message:@"获取成员失败，点击确定后将解散会议，请重新创建！"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        }
        else
        {
            alertview = [[UIAlertView alloc]  initWithTitle:@"提示" message:@"获取成员失败，点击确定后将退出会议，请重新加入！"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        }
        alertview.tag = VideoConfQueryMemberAlert;
        if (self.myAlertView)
        {
            [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
        }
        self.myAlertView = alertview;
        [alertview show];
        [alertview release];
    }
}

- (void) onSwitchRealScreenToVoipWithReason:(CloopenReason *) reason;
{
    [self dismissProgressingView];
}
- (void) onVideoConferenceRemoveMemberWithReason:(CloopenReason *) reason andMember:(NSString*) member
{
    [self dismissProgressingView];
}

-(void)onVideoConferenceDismissWithReason:(CloopenReason *)reason andConferenceId:(NSString *)conferenceId
{
    if (reason.reason == 0)
    {
        //可以等收到解散通知再退出界面
        if(self.sendPortraitTimer)
        {
            [self.sendPortraitTimer invalidate];
        }
        isCreatorExit = YES;//创建者解散不响应解散的通知消息，收到通知后直接退出页面
        [self performSelector:@selector(exitVideoConf) withObject:nil afterDelay:30];
    }
    else if (reason.reason == 101020 || reason.reason == 111805)
    {
        [self backToView];
    }
    else if (reason.reason == 111806)
    {
        [self dismissProgressingView];
        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"提示" message:@"解散会议失败，权限验证失败，只有创建者才能解散"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        if (self.myAlertView)
        {
            [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
        }
        self.myAlertView = alertview;
        [alertview show];
        [alertview release];
    }
    else if (reason.reason == 170005)//网络错误，直接挂机
    {
        [self dismissProgressingView];
        if(self.sendPortraitTimer)
        {
            [self.sendPortraitTimer invalidate];
        }
        [self exitCurVideoConf];
    }
    else
    {
        [self dismissProgressingView];
        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"提示" message:@"解散会议失败，请稍后再试..."  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        if (self.myAlertView)
        {
            [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
        }
        self.myAlertView = alertview;
        [alertview show];
        [alertview release];
    }
}

- (void)onVideoConferenceStateWithReason:(CloopenReason *) reason andConferenceId:(NSString*)conferenceId
{
    [self dismissProgressingView];
    if (reason.reason == 0 && conferenceId.length > 0)
    {
        self.curVideoConfId = conferenceId;
        self.sendPortraitTimer = [NSTimer scheduledTimerWithTimeInterval:VideoConfSendTime target:self selector:@selector(sendLocalPortrait) userInfo:nil repeats:YES];
        statusView.text = [NSString stringWithFormat:@"正在%@会议",self.curVideoConfId];
        if (isCreator)
        {
            [self displayProgressingView];
            [self.modelEngineVoip switchRealScreenToVoip:self.modelEngineVoip.voipAccount ofVideoConference:conferenceId inAppId:self.modelEngineVoip.appID];
        }
        if ([self.curVideoConfId length]>0)
        {
            [self displayProgressingView];
            [self.modelEngineVoip queryMembersInVideoConference:curVideoConfId];
        }
    }
    else if(reason.reason == 121002)
    {
        statusView.text = [NSString stringWithFormat:@"计费鉴权失败，余额不足，请充值后再使用..."];
        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"提示" message:@"计费鉴权失败，余额不足，请充值后再使用..."  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        if (self.myAlertView)
        {
            [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
        }
        self.myAlertView = alertview;
        alertview.tag = VideoConfJoinErrAlert;
        [alertview show];
        [alertview release];
    }
    else if(reason.reason == 701)
    {
        statusView.text = [NSString stringWithFormat:@"账号欠费，请充值后再使用..."];
        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"提示" message:@"账号欠费，请充值后再使用..."  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        if (self.myAlertView)
        {
            [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
        }
        self.myAlertView = alertview;
        alertview.tag = VideoConfJoinErrAlert;
        [alertview show];
        [alertview release];
    }
    else if( reason.reason == 702 )
    {
        statusView.text = [NSString stringWithFormat:@"主账号无效（未找到应用信息）..."];
        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"提示" message:@"主账号无效（未找到应用信息）..."  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        if (self.myAlertView)
        {
            [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
        }
        self.myAlertView = alertview;
        alertview.tag = VideoConfJoinErrAlert;
        [alertview show];
        [alertview release];
    }
    else if( reason.reason == 705 )
    {        
        statusView.text = [NSString stringWithFormat:@"第三方鉴权失败，子账号余额不足..."];
        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"提示" message:@"第三方鉴权失败，子账号余额不足..."  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        if (self.myAlertView)
        {
            [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
        }
        self.myAlertView = alertview;
        alertview.tag = VideoConfJoinErrAlert;
        [alertview show];
        [alertview release];
    }
    else
    {
        [self.pointImg stopAnimating];
        [self.pointImg startAnimating];
        statusView.text = [NSString stringWithFormat:@"加入会议失败，请稍后再试"];
        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"提示" message:@"加入会议失败，请稍后再试..."  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        if (self.myAlertView)
        {
            [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
        }
        self.myAlertView = alertview;
        alertview.tag = VideoConfJoinErrAlert;
        [alertview show];
        [alertview release];
    }
}

-(void)createConfWithAutoClose:(BOOL) isAutoClose andiVoiceMod:(NSInteger)voiceMod andAutoDelete:(BOOL) autoDelete andIsAutoJoin:(BOOL) isAutoJoin
{
    [self displayProgressingView];
    [self.modelEngineVoip setUIDelegate:self];
    [self.modelEngineVoip startVideoConferenceInAppId:self.modelEngineVoip.appID withName:Confname andSquare:5 andKeywords:@"" andPassword:@"" andIsAutoClose:isAutoClose andVoiceMod:voiceMod andAutoDelete:autoDelete andIsAutoJoin:isAutoJoin];
}
-(void)joinInVideoConf
{
    [self displayProgressingView];
    [self.modelEngineVoip setUIDelegate:self];
    [self.modelEngineVoip joinInVideoConference:self.curVideoConfId];
}
-(void)getLocalPortrait
{
    [self.modelEngineVoip getLocalPortrait];
}
-(void)sendLocalPortrait
{
    if (self.modelEngineVoip.appIsActive)
    {
        [NSThread detachNewThreadSelector:@selector(getLocalPortrait) toTarget:self withObject:nil];
        [self.modelEngineVoip getPortraitsFromVideoConference:self.curVideoConfId];
    }
}

-(void)onGetLocalPortrait:(NSString *)portraitPath
{
    NSLog(@"onGetLocalPortrait portraitPath=%@", portraitPath);
    [self.modelEngineVoip sendLocalPortrait:portraitPath toVideoConference:self.curVideoConfId];
}

-(void)onGetPortraitsFromVideoConferenceWithReason:(CloopenReason *)reason andPortraitList:(NSArray *)portraitlist
{
    if (reason.reason == 0)
    {
        if ([portraitlist count]>0)
        {
            for (VideoPartnerPortrait* portrait in portraitlist)
            {
                portrait.fileName  = [NSString stringWithFormat:@"%@%@%@%@.png",
                                      NSTemporaryDirectory(),
                                      self.curVideoConfId,
                                      portrait.voip,portrait.dateUpdate];
                
                NSFileManager* fm = [NSFileManager defaultManager];
                if ([fm fileExistsAtPath:portrait.fileName])
                {
                    portrait.fileName = @"";
                }
                NSLog(@"onGetPortraitsFromVideoConferenceWithReason is %@",portrait.fileUrl);
                NSLog(@"portrait.fileName  is  %@",portrait.fileName);
            }
            [self.modelEngineVoip downloadVideoConferencePortraits: portraitlist];
        }
    }
}

-(void)onDownloadVideoConferencePortraitsWithReason:(CloopenReason *)reason andPortrait:(VideoPartnerPortrait*)portrait
{
    NSLog(@"onDownloadVideoConferencePortraitsWithReason portrait.voip=%@", portrait.voip);
    if (reason.reason == 0 && portrait)
    {
        if ([view2.strVoip isEqualToString:portrait.voip])
        {
            [view2 setBgViewImagePath:portrait.fileName];
        }
        else if ([view3.strVoip isEqualToString:portrait.voip])
        {
            [view3 setBgViewImagePath:portrait.fileName];
        }
        else if ([view4.strVoip isEqualToString:portrait.voip])
        {
            [view4 setBgViewImagePath:portrait.fileName];
        }
        else if ([view5.strVoip isEqualToString:portrait.voip])
        {
            [view5 setBgViewImagePath:portrait.fileName];
        }
    }
}


@end
