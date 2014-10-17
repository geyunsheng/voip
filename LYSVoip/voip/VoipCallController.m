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

NSString * const kCallBg01pngVoip           = @"call_bg01.png";
NSString * const kCallHangUpButtonpng       = @"call_hang_up_button.png";
NSString * const kCallHangUpButtonOnpng     = @"call_hang_up_button_on.png";

#import "VoipCallController.h"
#import "ModelEngineVoip.h"
#import "AppDelegate.h"
#import "AccountInfo.h"
//#import "SelectPhoneNOViewController.h"
extern BOOL globalisVoipView;

@interface VoipCallController ()
{
    BOOL isShowKeyboard;
    BOOL isKickOff;
}
@property (nonatomic,retain) UIView *keyboardView;

- (void)handfree;
- (void)mute;
- (void)hangup;
- (void)backFront;
- (void)releaseCall;
- (void)showKeyboardView;
@end

@implementation VoipCallController
@synthesize callID;
@synthesize callDirection;
@synthesize callerName;
@synthesize callerNo;
@synthesize voipNo;
@synthesize topLabel;
@synthesize callerNameLabel;
@synthesize callerNoLabel;
@synthesize realTimeStatusLabel;
@synthesize statusLabel;
@synthesize netStatusLabel;
@synthesize hangUpButton;
@synthesize handfreeButton;
@synthesize KeyboardButton;
@synthesize muteButton;
@synthesize transferCallButton;
@synthesize functionAreaView;
@synthesize keyboardView;
@synthesize p2pStatusLabel;
@synthesize bgView;
- (VoipCallController *)initWithCallerName:(NSString *)name andCallerNo:(NSString *)phoneNo andVoipNo:(NSString *)voipNop andCallType:(NSInteger)type
{
    if (self = [super init])
    {
        self.callerName = name;
        self.callerNo = phoneNo;
        self.voipNo = voipNop;
        hhInt = 0;
        mmInt = 0;
        ssInt = 0;
        isLouder = NO;
        isKickOff = NO;
        voipCallType = type;
        [self.modelEngineVoip enableLoudsSpeaker:isLouder];
        return self;
    }
    
    return nil;
}

- (void)loadView
{
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
    self.bgView.backgroundColor = [UIColor colorWithRed:24/255.0 green:24/255.0 blue:24/255.0 alpha:1.0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    UIImage *backImage = [UIImage imageNamed:kCallBg01pngVoip];
    UIImageView *backGroupImageView = [[UIImageView alloc] initWithImage:backImage];
    backGroupImageView.center = CGPointMake(160.0, self.bgView.frame.size.height*0.5);
    [self.bgView addSubview:backGroupImageView];
    [backGroupImageView release];
    
    //名字
    UILabel *tempCallerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-100.0f, 28.0f, 200.0f, 22.0f)];
    tempCallerNameLabel.text = self.callerName;
    tempCallerNameLabel.font = [UIFont systemFontOfSize:20.0f];
    tempCallerNameLabel.textColor = [UIColor whiteColor];
    tempCallerNameLabel.backgroundColor = [UIColor clearColor];
    tempCallerNameLabel.textAlignment = UITextAlignmentCenter;
    self.callerNameLabel = tempCallerNameLabel;
    [self.bgView addSubview:self.callerNameLabel];
    [tempCallerNameLabel release];
    
    //电话
    UILabel *tempCallerNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-100.0f, 54.0f, 200.0f, 20.0f)];
    tempCallerNoLabel.text = self.callerNo;
    tempCallerNoLabel.font = [UIFont systemFontOfSize:18.0f];
    tempCallerNoLabel.textColor = [UIColor whiteColor];
    tempCallerNoLabel.backgroundColor = [UIColor clearColor];
    tempCallerNoLabel.textAlignment = UITextAlignmentCenter;
    self.callerNoLabel = tempCallerNoLabel;
    [self.bgView addSubview:self.callerNoLabel];
    [tempCallerNoLabel release];
    
    //连接状态提示
    UILabel *tempRealTimeStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80.0f, 320.0f, 32.0f)];
    tempRealTimeStatusLabel.numberOfLines = 2;
    tempRealTimeStatusLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tempRealTimeStatusLabel.text = @"网络正在连接请稍后...";
    tempRealTimeStatusLabel.textColor = [UIColor whiteColor];
    tempRealTimeStatusLabel.backgroundColor = [UIColor clearColor];
    tempRealTimeStatusLabel.textAlignment = UITextAlignmentCenter;
    tempRealTimeStatusLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    self.realTimeStatusLabel = tempRealTimeStatusLabel;
    [self.bgView addSubview:self.realTimeStatusLabel];
    [tempRealTimeStatusLabel release];
    
    UILabel *tempStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-150.0f, 106.0f, 300.0f, 16.0f)];
    tempStatusLabel.text = @"";
    tempStatusLabel.textColor = [UIColor whiteColor];
    tempStatusLabel.backgroundColor = [UIColor clearColor];
    tempStatusLabel.textAlignment = UITextAlignmentCenter;
    self.statusLabel = tempStatusLabel;
    [self.bgView addSubview:self.statusLabel];
    [tempStatusLabel release];
    
    UILabel *tempNetStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-150.0f, 126.0f, 300.0f, 16.0f)];
    tempNetStatusLabel.text = @"";
    tempNetStatusLabel.textColor = [UIColor whiteColor];
    tempNetStatusLabel.backgroundColor = [UIColor clearColor];
    tempNetStatusLabel.textAlignment = UITextAlignmentCenter;
    self.netStatusLabel = tempNetStatusLabel;
    [self.bgView addSubview:self.netStatusLabel];
    [tempNetStatusLabel release];
    
    
    UILabel *tempp2pstatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0f/2-150.0f, 146.0f, 300.0f, 16.0f)];
    tempp2pstatusLabel.text = @"";
    tempp2pstatusLabel.textColor = [UIColor whiteColor];
    tempp2pstatusLabel.backgroundColor = [UIColor clearColor];
    tempp2pstatusLabel.textAlignment = UITextAlignmentCenter;
    self.p2pStatusLabel = tempp2pstatusLabel;
    [self.bgView addSubview:self.p2pStatusLabel];
    [tempp2pstatusLabel release];
    
    //免提和静音背景图
    UIView *tempfunctionAreaView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f-10.0f-50.0f-5.0f-10, 320.0f, 50.0f)];
    self.functionAreaView = tempfunctionAreaView;
    tempfunctionAreaView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:tempfunctionAreaView];
    [tempfunctionAreaView release];
    
    isShowKeyboard = NO;
    //键盘显示按钮
    UIButton *tempKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.KeyboardButton = tempKeyboardButton;
    tempKeyboardButton.frame = CGRectMake(1, 0.0f, 79, 50);
    [tempKeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnpng] forState:UIControlStateNormal];
    tempKeyboardButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [tempKeyboardButton setTitle:@"键盘" forState:UIControlStateNormal];
    tempKeyboardButton.titleEdgeInsets  = UIEdgeInsetsMake(50,-29, 0, 0);
    tempKeyboardButton.imageEdgeInsets = UIEdgeInsetsMake(-10,22, 0, 0);
    [tempKeyboardButton addTarget:self action:@selector(showKeyboardView) forControlEvents:UIControlEventTouchUpInside];
    [self.functionAreaView addSubview:tempKeyboardButton];
    
    //静音按钮
    UIButton *tempMuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempMuteButton.frame = CGRectMake(81, 0.0f, 79, 50);
    [tempMuteButton setImage:[UIImage imageNamed:kMuteBtnpng] forState:UIControlStateNormal];
    tempMuteButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [tempMuteButton setTitle:@"静音" forState:UIControlStateNormal];
    tempMuteButton.titleEdgeInsets  = UIEdgeInsetsMake(50,-29, 0, 0);
    tempMuteButton.imageEdgeInsets = UIEdgeInsetsMake(-10,21, 0, 0);
    [tempMuteButton addTarget:self action:@selector(mute) forControlEvents:UIControlEventTouchUpInside];
    self.muteButton = tempMuteButton;
    tempMuteButton.enabled = NO;
    [self.functionAreaView addSubview:tempMuteButton];
    
    //免提按钮
    UIButton *tempHandFreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempHandFreeButton.frame = CGRectMake(161, 0.0f, 79, 50);
    [tempHandFreeButton setImage:[UIImage imageNamed:kHandsfreeBtnpng] forState:UIControlStateNormal];
    tempHandFreeButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [tempHandFreeButton setTitle:@"免提" forState:UIControlStateNormal];
    tempHandFreeButton.titleEdgeInsets  = UIEdgeInsetsMake(50,-29, 0, 0);
    tempHandFreeButton.imageEdgeInsets = UIEdgeInsetsMake(-10,22, 0, 0);
    self.handfreeButton = tempHandFreeButton;   
    tempHandFreeButton.enabled = NO;
    [tempHandFreeButton addTarget:self action:@selector(handfree) forControlEvents:UIControlEventTouchUpInside];
    [self.functionAreaView addSubview:tempHandFreeButton];
    
    UIButton *tempTransferCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempTransferCallButton.frame = CGRectMake(241, 0, 79, 50);
    [tempTransferCallButton setImage:[UIImage imageNamed:kTransferCallBtnpng] forState:UIControlStateNormal];
    [tempTransferCallButton setImage:[UIImage imageNamed:kTransferCallBtnOnpng] forState:UIControlStateHighlighted];
    tempTransferCallButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [tempTransferCallButton setTitle:@"呼转" forState:UIControlStateNormal];
    [tempTransferCallButton addTarget:self action:@selector(transferCall:) forControlEvents:UIControlEventTouchUpInside];
    tempTransferCallButton.titleEdgeInsets  = UIEdgeInsetsMake(50,-29, 0, 0);
    tempTransferCallButton.imageEdgeInsets = UIEdgeInsetsMake(-10,21, 0, 0);
    tempTransferCallButton.enabled = NO;
    [self.functionAreaView addSubview:tempTransferCallButton];
    self.transferCallButton = tempTransferCallButton;
    
    //挂机
    UIButton *tempHangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempHangupButton.frame = CGRectMake(24.0f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f, 320.0f-24.0f-24.0f, 42.0f);
    
    [tempHangupButton setImage:[UIImage imageNamed:kCallHangUpButtonpng] forState:UIControlStateNormal];
    [tempHangupButton setImage:[UIImage imageNamed:kCallHangUpButtonOnpng] forState:UIControlStateHighlighted];
    
    [tempHangupButton addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
    self.hangUpButton = tempHangupButton;
    [self.bgView addSubview:self.hangUpButton];
    
    //进来之后先拨号
    if (voipCallType==0)
    {
        self.callID = [self.modelEngineVoip makeCall:self.voipNo withPhone:self.callerNo withType:EVoipCallType_Voice withVoipType:1];
    }
    else if(voipCallType==1)
    {
        //等待调用SDK中网络直拨接口
        self.callID = [self.modelEngineVoip makeCall:self.voipNo withPhone:self.callerNo withType:EVoipCallType_Voice withVoipType:0];
    }
    else
    {
        [[ModelEngineVoip getInstance] callback:[ModelEngineVoip getInstance].voipPhone withTOCall:self.callerNo];
        self.callID = @"callback";
    }
    
    if (voipCallType==2)
    {
        self.realTimeStatusLabel.text = @"正在回拨...";
        self.handfreeButton.hidden = YES;
        self.handfreeButton.enabled = NO;
        self.transferCallButton.hidden = YES;
        self.transferCallButton.enabled = NO;
        self.muteButton.hidden = YES;
        self.muteButton.enabled = NO;
        self.hangUpButton.hidden = NO;
        self.hangUpButton.enabled = YES;
        self.functionAreaView.hidden = YES;
        isShowKeyboard = YES;
        [self showKeyboardView];
    }
    else if (self.callID.length <= 0)//获取CallID失败，即拨打失败
    {
        self.realTimeStatusLabel.text = @"对方不在线或网络不给力";
        self.handfreeButton.hidden = YES;
        self.handfreeButton.enabled = NO;
        self.transferCallButton.hidden = YES;
        self.transferCallButton.enabled = NO;
        self.muteButton.hidden = YES;
        self.muteButton.enabled = NO;
        self.hangUpButton.hidden = NO;
        self.hangUpButton.enabled = YES;
        self.functionAreaView.hidden = YES;
        isShowKeyboard = YES;
        [self showKeyboardView];
    }
}

-(void)transferCall:(id)sender
{
    UIActionSheet *menu = [[UIActionSheet alloc]
                           initWithTitle: @"选择接听方"
                           delegate:self
                           cancelButtonTitle:nil
                           destructiveButtonTitle:nil
                           otherButtonTitles:nil];
    int i = 0;
    for (AccountInfo* accountinfo in self.modelEngineVoip.accountArray)
    {
        [menu addButtonWithTitle:accountinfo.voipId];
        i++;
    }
    [menu addButtonWithTitle:@"取消"];
    [menu setCancelButtonIndex: [self.modelEngineVoip.accountArray count]];
    UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        tempButton.frame = CGRectMake(230.0,0, 90.0, 44.0);
    else
        tempButton.frame = CGRectMake(220.0,5, 95.0, 30.0);
    [tempButton setTitle:@"落地呼转" forState:UIControlStateNormal];
    [tempButton addTarget:self action:@selector(transferCallPhone) forControlEvents:UIControlEventTouchUpInside];
    [menu addSubview:tempButton];
    
    [menu showInView:self.view.window];
    self.menuActionSheet = menu;
    [menu release];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == actionSheet.cancelButtonIndex)
    {
        return;
    }
    AccountInfo* accountinfo = [self.modelEngineVoip.accountArray objectAtIndex:buttonIndex];
    if ([self.modelEngineVoip transferCall:self.callID withTransferID:accountinfo.voipId]==0)
    {
        callerNoLabel.text = accountinfo.voipId;
    }
}
//-(void)goChoosePhoneNumber
//{
//    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
//    {
//        CustomeAlertView *customeAlertView = (CustomeAlertView*)[[utextfield superview] superview];
//        customeAlertView.flag = 1;
//        [customeAlertView dismiss];
//    }
//    else
//    {
//        UIAlertView *alertView = (UIAlertView*)[utextfield superview];
//        [alertView dismissWithClickedButtonIndex:1 animated:NO];
//    }
//    if ([self isContactsAccessGranted])
//    {
//        SelectPhoneNOViewController* view = [[SelectPhoneNOViewController alloc] init];
//        view.delegate = self;
//        [self presentModalViewController:view animated:YES];
//        [view release];
//    }
//}

-(void)transferCallPhone
{
    int index = [self.menuActionSheet cancelButtonIndex];
    [self.menuActionSheet dismissWithClickedButtonIndex:index animated:NO];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        CustomeAlertView *customeAlertView = [[CustomeAlertView alloc]initWithBtnTitle1:@"确定呼转" andBtnTitle2:@"取消"];
        customeAlertView.delegate = self;
        customeAlertView.tag = 9911;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 15.0f, 180.0f, 25.0f)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont systemFontOfSize:14.0f];
        titleLabel.text = @"请输入电话号码";
        [customeAlertView.myView addSubview:titleLabel];
        [titleLabel release];
        
        utextfield = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 60.0, 220.0, 25.0)];
        utextfield.placeholder = @"请输入电话号码";
        [utextfield setBackgroundColor:[UIColor whiteColor]];
        utextfield.delegate = self;
        utextfield.keyboardType =UIKeyboardTypePhonePad;
        utextfield.borderStyle = UITextBorderStyleRoundedRect;
        [customeAlertView.myView addSubview:utextfield];
        
//        UIButton *chooseContactsBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
//        chooseContactsBtn.frame = CGRectMake(230.f, 60, 25.f, 25.f);
//        [chooseContactsBtn addTarget:self action:@selector(goChoosePhoneNumber) forControlEvents:UIControlEventTouchUpInside];
//        [chooseContactsBtn setBackgroundImage:[UIImage imageNamed:@"ios_contact.png"] forState:UIControlStateNormal];
//        [chooseContactsBtn setBackgroundImage:[UIImage imageNamed:@"ios_contact.png"] forState:UIControlStateHighlighted];
//        [customeAlertView.myView  addSubview:chooseContactsBtn];
        
        CGRect frame = customeAlertView.myView.frame;
        frame.origin.y -= 60;
        frame.size.height -= 40;
        [customeAlertView setViewFrame:frame];
        [customeAlertView show];
        [utextfield becomeFirstResponder];
        [utextfield release];
    }
    else
    {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"请输入电话号码" message:@"   \0 \n \n" delegate:self cancelButtonTitle:@"确定呼转" otherButtonTitles:@"取消", nil];
        alertview.tag = 9911;
        
        utextfield = [[UITextField alloc] initWithFrame:CGRectMake(22.0, 60.0, 210.0, 25.0)];
        
//        UIButton *chooseContactsBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
//        chooseContactsBtn.frame = CGRectMake(235.f, 60, 25.f, 25.f);
//        [chooseContactsBtn addTarget:self action:@selector(goChoosePhoneNumber) forControlEvents:UIControlEventTouchUpInside];
//        [chooseContactsBtn setBackgroundImage:[UIImage imageNamed:@"ios_contact.png"] forState:UIControlStateNormal];
//        [chooseContactsBtn setBackgroundImage:[UIImage imageNamed:@"ios_contact.png"] forState:UIControlStateHighlighted];
//        [alertview addSubview:chooseContactsBtn];
        
        utextfield.placeholder = @"请输入电话号码";
        [utextfield setBackgroundColor:[UIColor whiteColor]];
        utextfield.delegate = self;
        utextfield.keyboardType =UIKeyboardTypePhonePad;
        utextfield.borderStyle = UITextBorderStyleRoundedRect;
        [alertview addSubview:utextfield];
        [alertview show];
        [alertview release];
        [utextfield becomeFirstResponder];
        [utextfield release];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    globalisVoipView = YES;
    
    [self.modelEngineVoip setModalEngineDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7 && utextfield)
    {
        UIView* view = [utextfield superview];
        if (view)
        {
            CustomeAlertView *customeAlertView = (CustomeAlertView*)[view superview];
            if (customeAlertView)
            {
                customeAlertView.flag = 1;
                [customeAlertView dismiss];
            }
        }
    }
    else if(utextfield)
    {
        UIAlertView *alertView = (UIAlertView*)[utextfield superview];
        if (alertView)
        {
            [alertView dismissWithClickedButtonIndex:1 animated:NO];
        }
    }
    if (self.menuActionSheet)
    {
        int index = [self.menuActionSheet cancelButtonIndex];
        [self.menuActionSheet dismissWithClickedButtonIndex:index animated:NO];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    globalisVoipView = NO;
    [super viewDidDisappear:animated];
}


- (void)showKeyboardView
{
    isShowKeyboard = !isShowKeyboard;
    
    if (self.keyboardView == nil)
    {
        CGFloat viewWidth = 86.0f*3;
        CGFloat viewHeight = 46.0*4;
        UIView *tmpKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(160.0f-viewWidth*0.5f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f-10.0f-80.0f-viewHeight, viewWidth, viewHeight)];
        tmpKeyboardView.backgroundColor = [UIColor clearColor];
        self.keyboardView = tmpKeyboardView;
        [self.bgView addSubview:tmpKeyboardView];
        [tmpKeyboardView release];
        for (NSInteger i = 0; i<4; i++)
        {
            for (NSInteger j = 0; j<3; j++)
            {
                //Button alloc
                UIButton* numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
                numberButton.frame = CGRectMake(86.0f*j, 46.0f*i, 86.0f, 46.0f);
                [numberButton addTarget:self action:@selector(dtmfNumber:) forControlEvents:UIControlEventTouchUpInside];
                
                //设置数字图片
                NSInteger numberNum = i*3+j+1;
                if (numberNum == 11)
                {
                    numberNum = 0;
                }
                else if (numberNum == 12)
                {
                    numberNum = 11;
                }
                NSString * numberImgName = [NSString stringWithFormat:@"keyboard_%0.2d.png",numberNum];
                NSString * numberImgOnName = [NSString stringWithFormat:@"keyboard_%0.2d_on.png",numberNum];
                numberButton.tag = 1000 + numberNum;
                
                [numberButton setImage:[UIImage imageNamed:numberImgName] forState:UIControlStateNormal];
                [numberButton setImage:[UIImage imageNamed:numberImgOnName] forState:UIControlStateHighlighted];
                
                [self.keyboardView addSubview:numberButton];
            }
        }
    }
    
    if (isShowKeyboard)
    {
        [self.bgView bringSubviewToFront:self.keyboardView];
        [self.KeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnOnpng] forState:UIControlStateNormal];
        [self.KeyboardButton setTitleColor:[UIColor colorWithRed:46/255.0 green:184/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
    }
    else
    {
        [self.KeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnpng] forState:UIControlStateNormal];
        [self.KeyboardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.bgView sendSubviewToBack:self.keyboardView];
    }
}

- (void)dtmfNumber:(id)sender
{
    NSString *numberString = nil;
    UIButton *button = (UIButton *)sender;
    switch (button.tag)
    {
        case 1000:
            numberString = @"0";
            break;
        case 1001:
            numberString = @"1";
            break;
        case 1002:
            numberString = @"2";
            break;
        case 1003:
            numberString = @"3";
            break;
        case 1004:
            numberString = @"4";
            break;
        case 1005:
            numberString = @"5";
            break;
        case 1006:
            numberString = @"6";
            break;
        case 1007:
            numberString = @"7";
            break;
        case 1008:
            numberString = @"8";
            break;
        case 1009:
            numberString = @"9";
            break;
        case 1010:
            numberString = @"*";
            break;
        case 1011:
            numberString = @"#";
            break;
        default:
            numberString = @"#";
            break;
    }
    [self.modelEngineVoip sendDTMF:callID dtmf:numberString];
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
        self.p2pStatusLabel.text = @"p2p方式通话中...";
    }
    if(ssInt > 0 && ssInt % 4 == 0 )
    {
        StatisticsInfo * info =[self.modelEngineVoip getCallStatistics];
        if (info)
        {
            double lost = info.rlFractionLost / 255.f;
            self.statusLabel.text = [NSString stringWithFormat:@"延迟时间%d（毫秒）丢包率%0.2f%%",info.rlRttMs,lost];
        }
        
        NetworkStatistic* networkStatistic = [self.modelEngineVoip.VoipCallService getNetworkStatisticWithCallId:self.callID];
        if (networkStatistic)
        {
            self.netStatusLabel.text = [NSString stringWithFormat:@"发送：%0.2f（kB）接收：%0.2f（kB）",networkStatistic.txBytes / 1024.,networkStatistic.rxBytes / 1024.];
        }
    }
    if (hhInt > 0) {
        self.realTimeStatusLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hhInt,mmInt,ssInt];
    }
    else
    {
        self.realTimeStatusLabel.text = [NSString stringWithFormat:@"%02d:%02d",mmInt,ssInt];
    }
}

- (void)updateRealTimeStatusLabel
{
    self.realTimeStatusLabel.text = @"正在挂机...";
}

- (void)backFront
{
    if ([timer isValid]) 
    {
        [timer invalidate];
        timer = nil;
    }
//    {
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7 && utextfield)
//        {
//            CustomeAlertView *customeAlertView = (CustomeAlertView*)[[utextfield superview] superview];
//            if (customeAlertView)
//            {
//                customeAlertView.flag = 1;
//                [customeAlertView dismiss];
//            }
//        }
//        else if(utextfield)
//        {
//            UIAlertView *alertView = (UIAlertView*)[utextfield superview];
//            if (alertView)
//            {
//                [alertView dismissWithClickedButtonIndex:1 animated:NO];
//            }
//        }
//    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    self.callID = nil;
    self.callerName = nil;
    self.callerNo = nil;
    self.voipNo = nil;
    self.topLabel = nil;
    self.callerNameLabel = nil;
    self.callerNoLabel = nil;
    self.realTimeStatusLabel = nil;
    self.statusLabel = nil;
    self.netStatusLabel = nil;
    self.hangUpButton = nil;
    self.KeyboardButton = nil;
    self.keyboardView = nil;
    self.handfreeButton = nil;
    self.muteButton = nil;
    self.transferCallButton = nil;
    self.functionAreaView = nil;
    self.p2pStatusLabel = nil;
    self.bgView = nil;
    self.menuActionSheet = nil;
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
            self.realTimeStatusLabel.text = @"呼叫中...";
            self.handfreeButton.enabled = YES;
            self.handfreeButton.hidden = NO;
            self.muteButton.enabled = YES;
            self.muteButton.hidden = NO;
            self.hangUpButton.enabled = YES;
            self.hangUpButton.hidden =NO;
            self.transferCallButton.enabled = NO;
            self.transferCallButton.hidden = NO;
        }
            break;
        case ECallStatus_Alerting:
        {
            self.realTimeStatusLabel.text = @"等待对方接听";
            self.handfreeButton.enabled = YES;
            self.handfreeButton.hidden = NO;
            self.muteButton.enabled = YES;
            self.muteButton.hidden = NO;
            self.hangUpButton.enabled = YES;
            self.hangUpButton.hidden =NO;
            self.transferCallButton.enabled = NO;
            self.transferCallButton.hidden = NO;
        }
            break;
            
        case ECallStatus_Answered:
        {
            self.realTimeStatusLabel.text = @"00:00";
            if (![timer isValid])
            {
                timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateRealtimeLabel) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                [timer fire];
            }
            self.handfreeButton.enabled = YES;
            self.handfreeButton.hidden = NO;
            self.muteButton.enabled = YES;
            self.muteButton.hidden = NO;
            self.hangUpButton.enabled = YES;
            self.hangUpButton.hidden = NO;
            self.transferCallButton.enabled = YES;
            self.transferCallButton.hidden = NO;
        }
            break;
        case ECallStatus_Failed:
        {
            self.realTimeStatusLabel.text = data;
            if( data.intValue == EReasonNoResponse)
            {
                self.realTimeStatusLabel.text = @"网络不给力";
            }
            else if( data.intValue == EReasonBadCredentials )
            {
                self.realTimeStatusLabel.text = @"鉴权失败";
            }
            else if ( data.intValue == EReasonBusy || data.intValue == EReasonDeclined )
            {
                self.realTimeStatusLabel.text = @"您拨叫的用户正忙，请稍后再拨";
            }
            else if( data.intValue == EReasonNotFound)
            {
                self.realTimeStatusLabel.text = @"对方不在线";
            }
            else if( data.intValue == EReasonCallMissed )
            {
                self.realTimeStatusLabel.text = @"呼叫超时";
            }
            else if( data.intValue == EReasonNoNetwork )
            {
                self.realTimeStatusLabel.text = @"当前无网络";
            }
            else if( data.intValue == 170007)
            {
                self.realTimeStatusLabel.text = @"该版本不支持此功能";
            }
            else if( data.intValue == EReasonCalleeNoVoip )
            {
                self.realTimeStatusLabel.text = @"对方版本不支持音频";
            }
            else if( data.intValue == 700 )
            {
                self.realTimeStatusLabel.text = @"第三方鉴权地址连接失败";
            }            
            else if( data.intValue == 701 )
            {
                self.realTimeStatusLabel.text = @"主账号余额不足";
            }
            else if( data.intValue == 702 )
            {
                self.realTimeStatusLabel.text = @"主账号无效（未找到应用信息）";
            }
            else if( data.intValue == 703 )
            {
                self.realTimeStatusLabel.text = @"呼叫受限，外呼号码限制呼叫";
            }
            else if( data.intValue == 704 )
            {
                self.realTimeStatusLabel.text = @"未上线应用仅限呼叫已配置号码";
            }
            else if( data.intValue == 705 )
            {
                self.realTimeStatusLabel.text = @"第三方鉴权失败，子账号余额不足";
            }
            else if( data.intValue == 706 )
            {
                self.realTimeStatusLabel.text = @"无被叫号码";
            }
            else if( data.intValue == 710 )
            {
                self.realTimeStatusLabel.text = @"第三方主账号余额不足";
            }
            else if( data.intValue == 488 )
            {
                self.realTimeStatusLabel.text = @"媒体协商失败";
            }
            else if( data.intValue == 408 )
            {
                self.realTimeStatusLabel.text = @"呼叫超时";
            }
            else
            {
                self.realTimeStatusLabel.text = @"呼叫失败";
            }
            
            self.functionAreaView.hidden = YES;
            isShowKeyboard = YES;
            [self showKeyboardView];
            
            self.handfreeButton.enabled = NO;
            [self.handfreeButton setHidden:YES];
            self.muteButton.enabled = NO;
            [self.muteButton setHidden:YES];
            self.transferCallButton.enabled = NO;
            self.transferCallButton.hidden = YES;
            if ( data.intValue == EReasonBusy || data.intValue == EReasonDeclined )
            {
                [NSTimer scheduledTimerWithTimeInterval:8.5f target:self selector:@selector(releaseCall) userInfo:nil repeats:NO];
            }
            else
            {
                [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
            }
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
                
                self.realTimeStatusLabel.text = @"正在挂机...";
                if (!isKickOff) {
                    [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
                }
            }
        }
            break;
        case ECallStatus_CallBack:
        {
            self.realTimeStatusLabel.text = @"回拨呼叫成功,请注意接听系统来电";
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
        }
            break;
        case ECallStatus_CallBackFailed:
        {
            self.realTimeStatusLabel.font = [UIFont systemFontOfSize:14.0f];
            self.realTimeStatusLabel.text = data;
            [self.bgView bringSubviewToFront:self.realTimeStatusLabel];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
        }
            break;
        case ECallStatus_Transfered:
        {
            self.callerNoLabel.text = data;
        }
            break;
        default:
            break;
    }
}

- (void)handfree
{
    //成功时返回0，失败时返回-1
    int returnValue = [self.modelEngineVoip enableLoudsSpeaker:!isLouder];
    if (0 == returnValue)
    {
        isLouder = !isLouder;
    }
    if (isLouder) 
    {
        [self.handfreeButton setImage:[UIImage imageNamed:kHandsfreeBtnOnpng] forState:UIControlStateNormal];
        [self.handfreeButton setTitleColor:[UIColor colorWithRed:46/255.0 green:184/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
    }
    else
    {
        [self.handfreeButton setImage:[UIImage imageNamed:kHandsfreeBtnpng] forState:UIControlStateNormal];
        [self.handfreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)mute
{
    int muteFlag = [self.modelEngineVoip getMuteStatus];
    if (muteFlag == MuteFlagNotMute) {
        [self.muteButton setImage:[UIImage imageNamed:kMuteBtnOnpng] forState:UIControlStateNormal];
        [self.modelEngineVoip setMute:MuteFlagIsMute];
        [self.muteButton setTitleColor:[UIColor colorWithRed:46/255.0 green:184/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
    }
    else
    {
        [self.muteButton setImage:[UIImage imageNamed:kMuteBtnpng] forState:UIControlStateNormal];
        [self.modelEngineVoip setMute:MuteFlagNotMute];
        [self.muteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
    else if (alertView.tag == 9911)
    {
        if (buttonIndex == 0)
        {
            if([utextfield.text length]>0)
            {
                if ([self.modelEngineVoip.VoipCallService transferCall:self.callID withTransferID:utextfield.text] == 0)
                {
                    NSLog(@"呼转成功！");
                }
                else
                    NSLog(@"呼转失败");
            }
        }
        utextfield = nil;
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

- (void)hangup
{
    if (voipCallType == 2)
    {
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
    }
    else
    {
        if ([timer isValid]) {
            [timer invalidate];
            timer = nil;
        }
        self.realTimeStatusLabel.text = @"正在挂机...";
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(releaseCall) userInfo:nil repeats:NO];
    }
}

- (void)releaseCall
{
    [self.modelEngineVoip releaseCall:self.callID];
}

-(void)onFirewallPolicyEnabled
{
    p2pFlag = YES;
}

-(void)CustomeAlertViewDismiss:(CustomeAlertView *) alertView
{
    if (alertView.flag == 0)
    {
        if (alertView.tag == 9911)
        {
            if([utextfield.text length]>0)
            {
                if ([self.modelEngineVoip.VoipCallService transferCall:self.callID withTransferID:utextfield.text] == 0)
                {
                    NSLog(@"呼转成功！");
                }
                else
                    NSLog(@"呼转失败");
            }
        }
    }
    else if (alertView.flag == 1)
    {
        
    }
    [alertView release];
    utextfield = nil;
    NSLog(@"CustomeAlertViewDismiss");
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length == 1)
    {
        return YES;
    }
    NSMutableString *text = [[utextfield.text mutableCopy] autorelease];
    [text replaceCharactersInRange:range withString:string];
    return [text length] <= 15;
}
@end
