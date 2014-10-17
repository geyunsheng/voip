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


#import "IntercomingViewController.h"
#import "AppDefine.h"
#import <AudioToolbox/AudioToolbox.h>
@interface IntercomingViewController ()
{
    UILabel *statusView;
    UITableView *memberListView;
    UIButton *controlMicButton;
    NSInteger controlMicBtnStatus; //0:未控麦状态 1:控麦中 2:控麦成功
    UILabel *inlineNumLabel;
    UILabel *timeLabel;
    NSInteger speakTimeInterval;
}

@property (nonatomic, retain) NSMutableArray *membersArray;
@end

@implementation IntercomingViewController
@synthesize curInterphoneId;
@synthesize speakTimer;
@synthesize controlMicTimer;

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
    NSString *title = self.curInterphoneId.length>3?[self.curInterphoneId substringFromIndex:(self.curInterphoneId.length-3)]:@"";
    self.title = [NSString stringWithFormat:@"在%@对讲", title];
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"退出" target:self action:@selector(exitCurInterphon)]];
    self.navigationItem.rightBarButtonItem = right;
    [right release];
    
    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point_bg.png"]];
    pointImg.frame = CGRectMake(0.0f, 0.0f, 320.0f, 29.0f);
    [self.view addSubview:pointImg];
    [pointImg release];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 265.0f, 29.0f)];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont systemFontOfSize:13.0f];
    statusView = statusLabel;
    statusLabel.text = [NSString stringWithFormat:@"正在%@对讲",self.curInterphoneId];
    [self.view addSubview:statusLabel];
    [statusLabel release];
    
    UIImageView *tmpImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inter_phone_persons_ic.png"]];
    tmpImg.frame = CGRectMake(270.0f, 5.0f, 20.0f, 20.0f);
    [self.view addSubview:tmpImg];
    [tmpImg release];
    
    UILabel *numlabel = [[UILabel alloc] initWithFrame:CGRectMake(290.0f, 0.0f, 30.0f, 29.0f)];
    numlabel.backgroundColor = [UIColor clearColor];
    numlabel.textColor = [UIColor whiteColor];
    numlabel.font = [UIFont systemFontOfSize:13.0f];
    inlineNumLabel = numlabel;
    numlabel.text = @"";
    [self.view addSubview:numlabel];
    [numlabel release];
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 29.0f, 320.0f, 184.0f)
                                                 style:UITableViewStylePlain];;
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
	tableView.delegate = self;
	tableView.dataSource = self;
    tableView.allowsSelection = NO;
//    tableView.showsVerticalScrollIndicator = YES;
    memberListView = tableView;
	[self.view addSubview:tableView];
	[tableView release];
    
    UIView *micView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 169.0f, 320.0f, 145.0f)];
    micView.backgroundColor = VIEW_BACKGROUND_COLOR_GRAY;
    [self.view addSubview:micView];
    [micView release];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(260, 5, 50, 30)];
    timeLabel = label;
    speakTimeInterval = 0;
    label.backgroundColor = VIEW_BACKGROUND_COLOR_GRAY;
    label.textColor = [UIColor blueColor];
    label.font = [UIFont systemFontOfSize:13.0f];
    [micView addSubview:label];
    [label release];
    
    UIButton *micButton = [UIButton buttonWithType:UIButtonTypeCustom];
    micButton.frame = CGRectMake(94.0f, 7.0f, 132.0f, 132.0f);
    [micView addSubview:micButton];
    controlMicButton = micButton;
    [micButton setImage:[UIImage imageNamed:@"voice_button01.png"] forState:UIControlStateNormal];
    //[micButton setImage:[UIImage imageNamed:@"voice_button01.png"] forState:UIControlStateHighlighted];
    [micButton addTarget:self action:@selector(releaseMic:) forControlEvents:UIControlEventTouchUpInside];
    [micButton addTarget:self action:@selector(releaseMic:) forControlEvents:UIControlEventTouchUpOutside];
    [micButton addTarget:self action:@selector(releaseMic:) forControlEvents:UIControlEventTouchCancel];
    [micButton addTarget:self action:@selector(controlMic:) forControlEvents:UIControlEventTouchDown];
    
    UILabel *text_a = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 320.0f, 320.0f, 25.0f)];
    text_a.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    text_a.textColor = [UIColor blackColor];
    text_a.font = [UIFont systemFontOfSize:15.0f];
    text_a.textAlignment = NSTextAlignmentCenter;
    text_a.text = @"长按麦克风开始抢麦";
    [self.view addSubview:text_a];
    [text_a release];
    
    UILabel *text_b = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 345.0f, 320.0f, 20.0f)];
    text_b.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    text_b.textColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    text_b.font = [UIFont systemFontOfSize:13.0f];
    text_b.textAlignment = NSTextAlignmentCenter;
    text_b.text = @"抢麦成功会有震动反馈即可开始说话";
    [self.view addSubview:text_b];
    [text_b release];
    
    UILabel *text_c = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 365.0f, 320.0f, 20.0f)];
    text_c.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    text_c.textColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    text_c.font = [UIFont systemFontOfSize:13.0f];
    text_c.textAlignment = NSTextAlignmentCenter;
    text_c.text = @"失败则需要重新抢";
    [self.view addSubview:text_c];
    [text_c release];
    
    UILabel *text_d = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 385.0f, 320.0f, 20.0f)];
    text_d.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    text_d.textColor = [UIColor blackColor];
    text_d.font = [UIFont systemFontOfSize:10.0f];
    text_d.textAlignment = NSTextAlignmentCenter;
    text_d.text = @"其实...等TA说完再按就不用抢了吗...";
    [self.view addSubview:text_d];
    [text_d release];
    
    controlMicBtnStatus = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.modelEngineVoip setUIDelegate:self];
    [self.modelEngineVoip getMemberListInConfNo:self.curInterphoneId];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    self.curInterphoneId = nil;
    self.membersArray = nil;
    self.controlMicTimer = nil;
    self.speakTimer = nil;
    [super dealloc];
}

#pragma mark - table DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.membersArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *statusImgView = nil;
    UILabel *memberLabel = nil;
    UILabel *statusLabel = nil;
    
    static NSString* cellid = @"interphonemember_cellid";
    UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.contentView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_icon01.png"]];
        image.center = CGPointMake(15.0f, 10.0f);
        image.tag = 1000;
        statusImgView = image;
        [cell.contentView addSubview:image];
        [image release];
        
        UILabel *voipLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 0.0f, 110.0f, 20.0f)];
        voipLabel.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        voipLabel.font = [UIFont systemFontOfSize:13];
        voipLabel.tag = 1001;
        memberLabel = voipLabel;
        [cell.contentView addSubview:voipLabel];
        [voipLabel release];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(150.0f, 0.0f, 170.0f, 20.0f)];
        textLabel.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        textLabel.textColor = [UIColor colorWithRed:112.0f/255.0f green:112.0f/255.0f blue:112.0f/255.0f alpha:1.0f];
        textLabel.font = [UIFont systemFontOfSize:13];
        textLabel.tag = 1002;
        statusLabel = textLabel;
        [cell.contentView addSubview:textLabel];
        [textLabel release];
    }
    else
    {
        statusImgView = (UIImageView *)[cell viewWithTag:1000];
        memberLabel = (UILabel*)[cell viewWithTag:1001];
        statusLabel = (UILabel*)[cell viewWithTag:1002];
    }
    
    InterphoneMember *member = [self.membersArray objectAtIndex:indexPath.row];
    memberLabel.text = member.voipId;
    statusImgView.image = [UIImage imageNamed:@"status_icon01.png"];
    
    NSString *text_a = @"等待加入";
    NSString *text_b = @"";
    if ([member.online isEqualToString:@"1"])
    {
        statusImgView.image = [UIImage imageNamed:@"status_icon02.png"];
        text_a = @"已加入";
        
        if ([member.mic isEqualToString:@"1"])
        {
            statusImgView.image = [UIImage imageNamed:@"status_icon03.png"];
            text_b = @",正在讲话中...";
        }
    }
    else if ([member.online isEqualToString:@"2"])
    {
        statusImgView.image = [UIImage imageNamed:@"status_icon03.png"];
        text_a = @"已退出";
    }
    
    if ([self.modelEngineVoip.voipAccount isEqualToString:member.voipId])
    {
        statusImgView.image = [UIImage imageNamed:@"status_icon_me.png"];
    }

    statusLabel.text = [NSString stringWithFormat:@"%@%@", text_a, text_b];
    return cell;
}

#pragma mark - tabl Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20.0f;
}

- (void)speakTimeIntervalGrow
{
    speakTimeInterval ++ ;
    NSInteger mm = 0;
    NSInteger ss = 0;
    if (speakTimeInterval > 60)
    {
        mm = speakTimeInterval/60;
    }
    ss = speakTimeInterval % 60;
    timeLabel.text = [NSString stringWithFormat:@"%0.2d:%0.2d", mm, ss];
    
}

- (void)updateNumLabel
{
    NSInteger i = 0;
    for (InterphoneMember *member in self.membersArray)
    {
        if ([member.online isEqualToString:@"1"])
        {
            i++;
        }
    }
    inlineNumLabel.text = [NSString stringWithFormat:@"%d/%d",i,self.membersArray.count];
}

- (void)backToView
{
    [self dismissProgressingView];
    [self.navigationController popToViewController:self.backView animated:YES];
}

//退出当前的对讲场景
-(void)exitCurInterphon
{
    [self displayProgressingView];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(exitInterphone) userInfo:nil repeats:NO];
}

-(void)exitInterphone
{
    [self.modelEngineVoip exitInterphone];
    [self backToView];
}

-(void)controlMic
{
    controlMicBtnStatus = 1;
    if (controlMicButton)
    {
        [controlMicButton setImage:[UIImage imageNamed:@"voice_button02.png"] forState:UIControlStateNormal];
        [controlMicButton setImage:[UIImage imageNamed:@"voice_button02.png"] forState:UIControlStateHighlighted];
    }
    [self.modelEngineVoip controlMicInConfNo:self.curInterphoneId];
}
//控麦
-(void)controlMic:(id)sender
{
    if(self.controlMicTimer)
    {
        [self.controlMicTimer invalidate];
        self.controlMicTimer = nil;
    }
    else
        self.controlMicTimer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(controlMic) userInfo:nil repeats:NO];
}

- (void)releaseMic
{
    if(self.controlMicTimer)
    {
        [self.controlMicTimer invalidate];
        self.controlMicTimer = nil;
    }
    if (controlMicBtnStatus == 2)
        [self.modelEngineVoip releaseMicInConfNo:self.curInterphoneId];
    [controlMicButton setImage:[UIImage imageNamed:@"voice_button01.png"] forState:UIControlStateNormal];
    [controlMicButton setImage:nil forState:UIControlStateHighlighted];
    controlMicBtnStatus = 0;
}

//放麦
-(void)releaseMic:(id)sender
{
    [self releaseMic];
}
/********************实时语音的方法********************/

//通知客户端收到新的实时语音信息
- (void)onReceiveInterphoneMsg:(InterphoneMsg*) receiveMsgInfo
{
    if ([receiveMsgInfo isKindOfClass:[InterphoneInviteMsg class]])
    {
        //收到邀请
        InterphoneInviteMsg *msg = (InterphoneInviteMsg*)receiveMsgInfo;
        statusView.text = [NSString stringWithFormat:@"%@邀请您加入对讲%@", msg.fromVoip, msg.interphoneId];
    }
    else if([receiveMsgInfo isKindOfClass:[InterphoneJoinMsg class]])
    {
        //有人加入
        InterphoneJoinMsg *msg = (InterphoneJoinMsg*)receiveMsgInfo;
        
        if ([self.curInterphoneId isEqualToString:msg.interphoneId])
        {
            statusView.text = @"有人加入对讲";
            for (NSString *who in msg.joinArr)
            {
                for (InterphoneMember *member in self.membersArray)
                {
                    if ([who isEqualToString:member.voipId])
                    {
                        member.online = @"1";
                    }
                }
            }
            [memberListView reloadData];
            [self updateNumLabel];
        }
    }
    else if([receiveMsgInfo isKindOfClass:[InterphoneExitMsg class]])
    {
        //有人退出
        InterphoneExitMsg *msg = (InterphoneExitMsg*)receiveMsgInfo;
        if ([self.curInterphoneId isEqualToString:msg.interphoneId])
        {
            statusView.text = @"有人退出对讲";
            for (NSString *who in msg.exitArr)
            {
                for (InterphoneMember *member in self.membersArray)
                {
                    if ([who isEqualToString:member.voipId])
                    {
                        member.online = @"2";
                        member.mic = @"0";
                    }
                }
            }
            [memberListView reloadData];
            [self updateNumLabel];
        }
    }
    else if([receiveMsgInfo isKindOfClass:[InterphoneControlMicMsg class]])
    {
        //有人控麦
        InterphoneControlMicMsg *msg = (InterphoneControlMicMsg*)receiveMsgInfo;
        if (msg.voip.length > 0)
        {
            statusView.text = [NSString stringWithFormat:@"%@控麦", msg.voip];
            for (InterphoneMember *member in self.membersArray)
            {
                member.mic = @"0";
                if ([msg.voip isEqualToString:member.voipId])
                {
                    member.mic = @"1";
                }
            }
            [memberListView reloadData];
        }
        [self.speakTimer invalidate];
        self.speakTimer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(speakTimeIntervalGrow) userInfo:nil repeats:YES];
    }
    else if([receiveMsgInfo isKindOfClass:[InterphoneReleaseMicMsg class]])
    {
        //有人放麦
        InterphoneReleaseMicMsg *msg = (InterphoneReleaseMicMsg*)receiveMsgInfo;
        if (msg.voip.length > 0)
        {
            statusView.text = [NSString stringWithFormat:@"%@放麦", msg.voip];
            for (InterphoneMember *member in self.membersArray)
            {
                if ([msg.voip isEqualToString:member.voipId])
                {
                    member.mic = @"0";
                    break;
                }
            }
            [memberListView reloadData];
        }
        if (self.speakTimer)
        {
            speakTimeInterval = 0;
            timeLabel.text = @"";
            [self.speakTimer invalidate];
            self.speakTimer = nil;
        }
    }
}

//发起对讲——抢麦
- (void)onControlMicStateWithReason:(CloopenReason *) reason andSpeaker:(NSString *)voip
{
    if (reason.reason == 0)
    {
        [theAppDelegate printLog:(@"onControlMicState__________end")];
        if (controlMicBtnStatus == 0)
        {
            [theAppDelegate printLog:(@"onControlMicState__________end0")];
            controlMicBtnStatus = 2;
            [self releaseMic];
        }
        else
        {
            for (InterphoneMember *member in self.membersArray)
            {
                if ([self.modelEngineVoip.voipAccount isEqualToString:member.voipId])
                {
                    member.mic = @"1";
                    break;
                }
            }
            [memberListView reloadData];
            controlMicBtnStatus = 2;
            statusView.text = @"控麦成功，请讲话";
            [self.speakTimer invalidate];
            self.speakTimer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(speakTimeIntervalGrow) userInfo:nil repeats:YES];
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
    else
    {
        if (controlMicBtnStatus == 1)
        {
            statusView.text = @"控麦失败，稍后重试";
            [controlMicButton setImage:[UIImage imageNamed:@"voice_button03.png"] forState:UIControlStateNormal];
            [controlMicButton setImage:[UIImage imageNamed:@"voice_button03.png"] forState:UIControlStateHighlighted];
        }

        controlMicBtnStatus = 0;
        
        if (voip.length > 0)
        {
            for (InterphoneMember *member in self.membersArray)
            {
                member.mic = @"0";
                if ([voip isEqualToString:member.voipId])
                {
                    member.mic = @"1";                    
                }
            }
            [memberListView reloadData];
        }
        
        NSString *msg = [NSString stringWithFormat:@"错误码:%d\r\n错误详情:%@",
                         reason.reason,
                         reason.msg.length>0?reason.msg:@"未知"];
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                       message:msg
                                                      delegate:nil
                                             cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [view show];;
        [view release];
    }
}

//结束对讲——放麦
- (void)onReleaseMicStateWithReason:(CloopenReason *) reason
{
    if (reason.reason == 0)
    {
        statusView.text = [NSString stringWithFormat:@"正在%@对讲",self.curInterphoneId];
        for (InterphoneMember *member in self.membersArray)
        {
            if ([self.modelEngineVoip.voipAccount isEqualToString:member.voipId])
            {
                member.mic = @"0";
                break;
            }
        }
        [memberListView reloadData];
    }
    else
    {
        NSString *msg = [NSString stringWithFormat:@"错误码:%d\r\n错误详情:%@",
                         reason.reason,
                         reason.msg.length>0?reason.msg:@"未知"];
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                       message:msg
                                                      delegate:nil
                                             cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [view show];;
        [view release];
    }
    
    if (self.speakTimer)
    {
        speakTimeInterval = 0;
        timeLabel.text = @"";
        [self.speakTimer invalidate];
        self.speakTimer  = nil;
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
            [theAppDelegate logout];
        }
    }
}
//获取对讲场景的成员
- (void)onInterphoneMembersWithReason:(CloopenReason *) reason andData:(NSArray*)members
{
    if (reason.reason == 0)
    {
        self.membersArray = [[[NSMutableArray alloc] initWithArray:members] autorelease];
        InterphoneMember *meInfo = nil;
        for (InterphoneMember *member in self.membersArray)
        {
            if ([self.modelEngineVoip.voipAccount isEqualToString:member.voipId])
            {
                member.online = @"1";
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
        
        [memberListView reloadData];
        [self updateNumLabel];
    }
    else
    {
        NSString *msg = [NSString stringWithFormat:@"错误码:%d\r\n错误详情:%@", reason.reason, reason.msg.length>0?reason.msg:@"未知"];
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                       message:msg
                                                      delegate:nil
                                             cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [view show];;
        [view release];
    }
}
@end
