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

#import "VoipIncomingViewController.h"
#import "AppDelegate.h"
//#import "UIselectContactsViewController.h"
#import "AccountInfo.h"
//#import "SelectPhoneNOViewController.h"
extern BOOL globalisVoipView;

@interface VoipIncomingViewController ()
{
    BOOL isShowKeyboard;
    BOOL isKickOff;
}

@property (nonatomic,retain) UIView *keyboardView;

- (void)accept;
- (void)refreshView;
- (void)exitView;
- (void)dismissView;
- (void)showKeyboardView;
@end

@implementation VoipIncomingViewController

#define portraitLeft  100
#define portraitTop   120
#define portraitWidth 150
#define portraitHeight 150

@synthesize lblIncoming;
@synthesize lblName;
@synthesize lblPhoneNO;
@synthesize functionAreaView;
@synthesize contactName;
@synthesize contactPhoneNO;
@synthesize contactVoip;
@synthesize callID;
@synthesize hangUpButton;
@synthesize rejectButton;
@synthesize answerButton;
@synthesize handfreeButton;
@synthesize KeyboardButton;
@synthesize contactPortrait;
@synthesize muteButton;
@synthesize status;
@synthesize keyboardView;
@synthesize statusLabel;
@synthesize netStatusLabel;
@synthesize p2pStatusLabel;
@synthesize bgView;
#pragma mark - init初始化
- (id)initWithName:(NSString *)name andPhoneNO:(NSString *)phoneNO andCallID:(NSString*)callid andParent:(id)viewController
{
    self = [super init];
    if (self)
    {
        self.contactName     = name;
        self.callID          = callid;
        self.contactPhoneNO  = phoneNO;
        hhInt = 0;
        mmInt = 0;
        ssInt = 0;
        isLouder = NO;
        isKickOff = NO;
        self.status = IncomingCallStatus_incoming;
        parentView = viewController;
    }
    return self;
}

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
    self.navigationController.navigationBar.hidden = YES;
    
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
#pragma mark - viewDidLoad界面初始化
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *backImage = [UIImage imageNamed:kCallBg02pngVoip];
    UIImageView *backGroupImageView = [[UIImageView alloc] initWithImage:backImage];
    backgroundImg = backGroupImageView;
    backGroupImageView.center = CGPointMake(160.0, self.bgView.frame.size.height*0.5);
    [self.bgView addSubview:backGroupImageView];
    [backGroupImageView release];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    self.lblName = nameLabel;
    [nameLabel release];
    self.lblName.frame = CGRectMake(0, 30, 320, 20);
    self.lblName.textAlignment = UITextAlignmentCenter;
    self.lblName.backgroundColor = [UIColor clearColor];
    self.lblName.textColor = [UIColor whiteColor];
    self.lblName.text = self.contactName.length>0?self.contactName:@"";
    [self.bgView addSubview:lblName];
    
    UILabel *phoneLabel = [[UILabel alloc] init];
    self.lblPhoneNO = phoneLabel;
    [phoneLabel release];
    self.lblPhoneNO.frame = CGRectMake(0, 53, 320, 22);
    self.lblPhoneNO.textAlignment = UITextAlignmentCenter;
    self.lblPhoneNO.backgroundColor = [UIColor clearColor];
    self.lblPhoneNO.textColor = [UIColor whiteColor];
    self.lblPhoneNO.text = self.contactPhoneNO.length>0?self.contactPhoneNO:self.contactVoip;
    [self.bgView addSubview:lblPhoneNO];
    
    UILabel* incomingLabel = [[UILabel alloc] init];
    self.lblIncoming = incomingLabel;
    [incomingLabel release];
    self.lblIncoming.frame = CGRectMake(0, 80, 320, 20);
    self.lblIncoming.textAlignment = UITextAlignmentCenter;
    self.lblIncoming.backgroundColor = [UIColor clearColor];
    self.lblIncoming.textColor = [UIColor whiteColor];
    self.lblIncoming.text = @"";
    [self.bgView addSubview:lblIncoming];
    
    
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
    
    isShowKeyboard = NO;
    //免提和静音背景图
    UIView *tempfunctionAreaView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f-10.0f-43.0f-5.0f-10, 320.0f, 50.0f)];
    [self.bgView addSubview:tempfunctionAreaView];
    tempfunctionAreaView.backgroundColor = [UIColor clearColor];
    self.functionAreaView = tempfunctionAreaView;
    self.functionAreaView.hidden = YES;
    [tempfunctionAreaView release];
    
    //键盘显示按钮
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
    
    
    //拒接
    UIButton *tempRejectButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    tempRejectButton.frame = CGRectMake(24.0f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f, 127, 42);
    [tempRejectButton setImage:[UIImage imageNamed:@"call_refuse_button.png"] forState:UIControlStateNormal];
    [tempRejectButton setImage:[UIImage imageNamed:@"call_refuse_button_on.png"] forState:UIControlStateHighlighted];
    [tempRejectButton setImage:[UIImage imageNamed:@"call_refuse_button_on.png"] forState:UIControlStateSelected];
    [tempRejectButton  addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
    self.rejectButton = tempRejectButton;
    [self.bgView addSubview:self.rejectButton];
    
    //挂机
    UIButton *tempHangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tempHangupButton.frame = CGRectMake(24.0f, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f, 320.0f-24.0f-24.0f, 42.0f);
    [tempHangupButton setImage:[UIImage imageNamed:@"call_hang_up_button.png"] forState:UIControlStateNormal];
    [tempHangupButton setImage:[UIImage imageNamed:@"call_hang_up_button_on.png"] forState:UIControlStateHighlighted];
    [tempHangupButton setImage:[UIImage imageNamed:@"call_hang_up_button_on.png"] forState:UIControlStateSelected];
    [tempHangupButton addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
    tempHangupButton.hidden = YES;
    self.hangUpButton = tempHangupButton;
    [self.bgView addSubview:self.hangUpButton];
    
    //接听
    UIButton *tempAnswerButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    tempAnswerButton.frame = CGRectMake(24.0f+127+14, [UIScreen mainScreen].applicationFrame.size.height-13.0f-42.0f, 127, 42.0f);
    [tempAnswerButton setImage:[UIImage imageNamed:@"call_answer_button.png"] forState:UIControlStateNormal];
    [tempAnswerButton setImage:[UIImage imageNamed:@"call_answer_button_on.png"] forState:UIControlStateHighlighted];
    [tempAnswerButton setImage:[UIImage imageNamed:@"call_answer_button_on.png"] forState:UIControlStateSelected];
    [tempAnswerButton  addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];
    self.answerButton = tempAnswerButton;
    [self.bgView addSubview:self.answerButton];
    
    [self refreshView];
}

//- (void)viewDidUnload
//{    
//    self.lblIncoming = nil;
//    self.functionAreaView = nil;
//    self.lblName = nil;
//    self.lblPhoneNO = nil;
//    self.contactName = nil;
//    self.contactPhoneNO = nil;
//    self.contactPortrait = nil;
//    self.hangUpButton = nil;
//    self.handfreeButton = nil;
//    self.statusLabel = nil;
//    //self.netStatusLabel = nil;
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//}

- (void)dealloc
{
    self.contactVoip = nil;
    self.KeyboardButton = nil;
    self.keyboardView = nil;
    self.lblIncoming = nil;
    self.functionAreaView = nil;
    self.lblName = nil;
    self.lblPhoneNO = nil;
    self.contactName = nil;
    self.contactPhoneNO = nil;
    self.contactPortrait = nil;
    self.hangUpButton = nil;
    self.handfreeButton = nil;
    self.muteButton = nil;
    self.transferCallButton = nil;
    self.statusLabel = nil;
    self.netStatusLabel = nil;
    self.p2pStatusLabel = nil;
    self.bgView = nil;
    self.menuActionSheet = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Appear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.modelEngineVoip setModalEngineDelegate:self];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissView) name:KNOTIFICATION_DISMISSMODALVIEW object:nil];
    globalisVoipView = YES;
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

    [ModelEngineVoip getInstance].UIDelegate = parentView;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_DISMISSMODALVIEW object:nil];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    globalisVoipView = NO;
    [super viewDidDisappear:animated];
}

#pragma mark - 按钮点击
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
        double lost = info.rlFractionLost / 255.f;
        self.statusLabel.text = [NSString stringWithFormat:@"延迟时间%d（毫秒）丢包率%0.2f%%",info.rlRttMs,lost];
        
        NetworkStatistic* networkStatistic = [self.modelEngineVoip.VoipCallService getNetworkStatisticWithCallId:self.callID];
        if (networkStatistic)
        {
            self.netStatusLabel.text = [NSString stringWithFormat:@"发送：%0.2f（kB）接收：%0.2f（kB）",networkStatistic.txBytes / 1024.,networkStatistic.rxBytes / 1024.];
        }
    }
    
    if (hhInt > 0) {
        self.lblIncoming.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hhInt,mmInt,ssInt];
    }
    else
    {
        self.lblIncoming.text = [NSString stringWithFormat:@"%02d:%02d",mmInt,ssInt];
    }
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
        case ECallStatus_Answered:
        {
            self.lblIncoming.text = @"00:00";
            if (![timer isValid])
            {
                timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateRealtimeLabel) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                [timer fire];
            }
            self.rejectButton.enabled = NO;
            self.rejectButton.hidden = YES;
            
            self.answerButton.enabled = NO;
            self.answerButton.hidden = YES;
            
            self.handfreeButton.enabled = YES;
            self.handfreeButton.hidden = NO;
            
            self.transferCallButton.enabled = YES;
            self.transferCallButton.hidden = NO;
            
            self.muteButton.enabled = YES;
            self.muteButton.hidden = NO;
            
            self.hangUpButton.enabled = YES;
            self.hangUpButton.hidden = NO;
            
            self.functionAreaView.hidden = NO;
            backgroundImg.image = [UIImage imageNamed:@"call_bg01.png"];

        }
            break;
        case ECallStatus_Released:
        {
            if ([self.callID isEqualToString:callid])
            {
                if (!isKickOff)
                    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(exitView) userInfo:nil repeats:NO];
            }
        }
            break;
            
        case ECallStatus_Pasused:
        {
            self.lblIncoming.text = @"呼叫保持...";
        }
            break;
        case ECallStatus_PasusedByRemote:
        {
            self.lblIncoming.text = @"呼叫被对方保持...";
        }
            break;
        case ECallStatus_Resumed:
        {
            self.lblIncoming.text = @"呼叫恢复...";
        }
            break;
        case ECallStatus_ResumedByRemote:
        {
            self.lblIncoming.text = @"呼叫被对方恢复...";
        }
            break;
        case ECallStatus_Transfered:
        {
            self.lblPhoneNO.text = data;
        }
            break;
        default:
            break;
    }
}

//#pragma mark - UITextFieldDelegate
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    return NO;
//}

#pragma mark - private
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
        [self.KeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnOnpng] forState:UIControlStateNormal];
        [self.KeyboardButton setTitleColor:[UIColor colorWithRed:46/255.0 green:184/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
        [self.bgView bringSubviewToFront:self.keyboardView];
    }
    else
    {
        [self.KeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnpng] forState:UIControlStateNormal];
        [self.bgView sendSubviewToBack:self.keyboardView];
        [self.KeyboardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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

- (void)answer
{
    NSInteger ret = [self.modelEngineVoip acceptCall:self.callID];
    if (ret == 0)
    {
        self.status = IncomingCallStatus_accepted;
        [self refreshView];
    }
    else
    {
        [self exitView];
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
    if (muteFlag == MuteFlagNotMute1) {
        [self.muteButton setImage:[UIImage imageNamed:kMuteBtnOnpng] forState:UIControlStateNormal];
        [self.modelEngineVoip setMute:MuteFlagIsMute1];
        [self.muteButton setTitleColor:[UIColor colorWithRed:46/255.0 green:184/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
    }
    else
    {
        [self.muteButton setImage:[UIImage imageNamed:kMuteBtnpng] forState:UIControlStateNormal];
        [self.modelEngineVoip setMute:MuteFlagNotMute1];
        [self.muteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)releaseCall
{
    [self.modelEngineVoip releaseCall:self.callID];
}

- (void)hangup
{
    [self.modelEngineVoip releaseCall:self.callID];
    [self exitView];
}

- (void)refreshView
{
    if (self.status == IncomingCallStatus_accepting)
    {
        self.lblIncoming.text = @"正在接听...";
        self.rejectButton.enabled = NO;
        self.rejectButton.hidden = YES;
        
        self.answerButton.enabled = NO;
        self.answerButton.hidden = YES;
        
        self.handfreeButton.enabled = YES;
        self.handfreeButton.hidden = NO;
        
        self.muteButton.enabled = YES;
        self.muteButton.hidden = NO;
        
        self.hangUpButton.enabled = YES;
        self.hangUpButton.hidden = NO;
        
        self.functionAreaView.hidden = NO;
        backgroundImg.image = [UIImage imageNamed:@"call_bg01.png"];

        [self performSelector:@selector(answer) withObject:nil afterDelay:0.1];
    }
    else if (self.status == IncomingCallStatus_incoming)
    {
        
    }
    else if(self.status == IncomingCallStatus_accepted)
    {
    }
    else
    {
        
    }
}
- (void)accept
{
    self.status = IncomingCallStatus_accepting;
    [self refreshView];
}

-(void) exitView
{
    if ([timer isValid]) 
    {
        [timer invalidate];
        timer = nil;
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)process
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if ([timer isValid]) 
    {
        [timer invalidate];
        timer = nil;
    }
    [self dismissModalViewControllerAnimated:YES];
    
	[pool release];
}

- (void)dismissView
{
    [NSThread detachNewThreadSelector:@selector(process) toTarget:self withObject:nil];
}

-(void)onFirewallPolicyEnabled
{
    p2pFlag = YES;
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
        lblPhoneNO.text = accountinfo.voipId;
    }
}
//-(void)goChoosePhoneNumber
//{
//    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
//    {
//        CustomeAlertView *customeAlertView = (CustomeAlertView*)[[utextfield superview] superview];
//        customeAlertView.flag = 0;
//        [customeAlertView dismiss];
//    }
//    else
//    {
//        UIAlertView *alertView = (UIAlertView*)[utextfield superview];
//        [alertView dismissWithClickedButtonIndex:0 animated:NO];
//    }
//    if ([self isContactsAccessGranted])
//    {
////        SelectPhoneNOViewController* view = [[SelectPhoneNOViewController alloc] init];
////        view.delegate = self;
////        UINavigationController *nav = (UINavigationController*) self.presentingViewController;
////        [nav pushViewController:view animated:YES];
////        [view release];
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
