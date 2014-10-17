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

#import "ChatRoomViewController.h"
#import "UICustomView.h"
#import "RoomMemberViewController.h"
#define ChatRoomVIEW_BACKGROUND_COLOR [UIColor colorWithRed:35.0f/255.0f green:47.0f/255.0f blue:60.0f/255.0f alpha:1.0f]
#define ChatRoomVIEW_dissolve 9999
#define ChatRoomVIEW_addmember 9998
#define ChatRoomVIEW_RoomDisslove 9997
#define ChatRoomVIEW_kickOff 9996
#define ChatRoomVIEW_exitAlert 9995
#define ChatRoomVIEW_joinChatroomErr 9994
#define ChatRoomVIEW_addNullNumber 9993

@interface ChatRoomViewController ()
{
    UILabel *statusView;
    UIView *membersListView;
    UILabel *tipsLabel;
    UILabel *netStatusLabel;
    UIView *amplitudeView;
    BOOL isMute;
    NSTimer *animationBoxTimer;
    NSInteger animationBoxCount;
    UIImageView *animBackview;
    BOOL isLoud;
}
@property (nonatomic, retain) NSMutableArray *membersArray;
@end

@implementation ChatRoomViewController
@synthesize backView;
@synthesize curChatroomId;
@synthesize roomname;
@synthesize membersArray;
@synthesize timer;
@synthesize isCreator;
@synthesize isCreatorExit;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (range.length == 1) {
        return YES;
    }
    NSMutableString *text = [[utextfield.text mutableCopy] autorelease];
    [text replaceCharactersInRange:range withString:string];
    return [text length] <= 15;
}

-(void)createAlert:(NSString*) phone
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        CustomeAlertView *customeAlertView = [[CustomeAlertView alloc]init];
        customeAlertView.delegate = self;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 15.0f, 180.0f, 25.0f)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont systemFontOfSize:14.0f];
        titleLabel.text = @"接听电话加入群聊";
        [customeAlertView.myView addSubview:titleLabel];
        [titleLabel release];
        
        UILabel *ulbl=[[UILabel alloc]initWithFrame:CGRectMake(10,45,250,50)];
        [ulbl setText:@"    请输入要邀请加入聊天室的号码（固号需加区号），对方接听免费电话后即可加入聊天输入框。"];
        ulbl.numberOfLines = 0;
        ulbl.lineBreakMode = UILineBreakModeCharacterWrap;
        ulbl.font = [UIFont systemFontOfSize:14];
        [ulbl setBackgroundColor:[UIColor clearColor]];
        [ulbl setTextColor:[UIColor blackColor]];
        [customeAlertView.myView addSubview:ulbl];
        [ulbl release];
        
        utextfield = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 110.0, 210.0, 25.0)];
        utextfield.font = [UIFont systemFontOfSize:14];
        utextfield.placeholder = @"请输入号码，固话需加拨区号";
        if ([phone length] > 0)
        {
            utextfield.text = phone;
        }
        [utextfield setBackgroundColor:[UIColor whiteColor]];
        utextfield.delegate = self;
        utextfield.keyboardType =UIKeyboardTypeNumbersAndPunctuation;
        utextfield.borderStyle = UITextBorderStyleRoundedRect;
        
        UIButton *chooseContactsBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        chooseContactsBtn.frame = CGRectMake(230.f, 110, 25.f, 25.f);
        [chooseContactsBtn addTarget:self action:@selector(goChoosePhoneNumber) forControlEvents:UIControlEventTouchUpInside];
        [chooseContactsBtn setBackgroundImage:[UIImage imageNamed:@"ios_contact.png"] forState:UIControlStateNormal];
        [chooseContactsBtn setBackgroundImage:[UIImage imageNamed:@"ios_contact.png"] forState:UIControlStateHighlighted];
        [customeAlertView.myView  addSubview:chooseContactsBtn];
        
        [customeAlertView.myView addSubview:utextfield];
        customeAlertView.tag = ChatRoomVIEW_addmember;
        
        CGRect frame = customeAlertView.myView.frame;
        frame.origin.y -= 80;
        customeAlertView.myView.frame = frame;
        
        [customeAlertView show];
        [utextfield becomeFirstResponder];
        [utextfield release];
    }
    else
    {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"接听电话加入群聊" message:@"        请输入要邀请加入聊天室的号码（固号需加区号），对方接听免费电话后即可加入聊天输入框。         \0 \n \n" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        utextfield = [[UITextField alloc] initWithFrame:CGRectMake(22.0, 115.0, 210.0, 25.0)];
        utextfield.placeholder = @"请输入号码，固话需加拨区号";
        utextfield.font = [UIFont systemFontOfSize:14];
        [utextfield setBackgroundColor:[UIColor whiteColor]];
        utextfield.delegate = self;
        utextfield.keyboardType =UIKeyboardTypeNumbersAndPunctuation;
        utextfield.borderStyle = UITextBorderStyleRoundedRect;
        [alertview addSubview:utextfield];
        
        UIButton *chooseContactsBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        chooseContactsBtn.frame = CGRectMake(235.f, 115, 25.f, 25.f);
        [chooseContactsBtn addTarget:self action:@selector(goChoosePhoneNumber) forControlEvents:UIControlEventTouchUpInside];
        [chooseContactsBtn setBackgroundImage:[UIImage imageNamed:@"ios_contact.png"] forState:UIControlStateNormal];
        [chooseContactsBtn setBackgroundImage:[UIImage imageNamed:@"ios_contact.png"] forState:UIControlStateHighlighted];
        [alertview addSubview:chooseContactsBtn];
        
        alertview.tag = ChatRoomVIEW_addmember;
        [alertview show];
        [alertview release];
        [utextfield becomeFirstResponder];
        [utextfield release];
        if ([phone length] > 0)
        {
            utextfield.text = phone;
        }
    }
}

-(void)addMember
{
    [self createAlert:nil];
}

-(void)goChoosePhoneNumber
{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        CustomeAlertView *customeAlertView = (CustomeAlertView*)[[utextfield superview] superview];
        customeAlertView.flag = 0;
        [customeAlertView dismiss];
    }
    else
    {
        UIAlertView *alertView = (UIAlertView*)[utextfield superview];
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    [super goChoosePhoneNumber];
}

-(void)getPhoneNumber:(NSString *)phoneNumber
{
    [self createAlert:phoneNumber];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    @try
    {
        if (alertView.tag == ChatRoomVIEW_RoomDisslove|| alertView.tag == ChatRoomVIEW_kickOff)
        {
            [self backToView];
        }
        else if (alertView.tag ==  ChatRoomVIEW_dissolve)
        {
            if (buttonIndex == 1)
            {
                [self displayProgressingView];
                [self.modelEngineVoip dismissChatroomWithAppId:self.modelEngineVoip.appID andRoomNo:self.curChatroomId];
            }
        }
        else if(alertView.tag ==  ChatRoomVIEW_addmember)
        {
            [utextfield resignFirstResponder];
            if (buttonIndex == 1)
            {
                if ([utextfield.text length]==0) {
                    UIAlertView* alert;
                    alert.tag = ChatRoomVIEW_addNullNumber;
                    alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"邀请的号码不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                    return;
                }
                else
                {
                    [self.modelEngineVoip inviteMembers:([NSArray arrayWithObject:utextfield.text]) joinChatroom:self.curChatroomId ofAppId:self.modelEngineVoip.appID];
                }
            }
        }
        else if (alertView.tag == ChatRoomVIEW_addNullNumber)
        {
            [self createAlert:nil];
        }
        else if(alertView.tag == ChatRoomVIEW_exitAlert)
        {
            if (buttonIndex == 1)
            {
                [self exitCurChatroom];
            }
        }
        else if(alertView.tag == ChatRoomVIEW_joinChatroomErr)
        {
            [self exitCurChatroom];
        }
        else if (alertView.tag == kKickedOff)
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
    @catch (NSException *exception) {
        
    }
    @finally {
    }
}

-(void)CustomeAlertViewDismiss:(CustomeAlertView *) alertView{
    if (alertView.flag == 0)
    {
        //取消操作
        NSLog(@"CustomeAlertViewDismiss 取消操作");
    }
    else if (alertView.flag == 1)
    {
        //确认操作
        NSLog(@"CustomeAlertViewDismiss 确认操作");
        if(alertView.tag ==  ChatRoomVIEW_addmember)
        {
            [utextfield resignFirstResponder];
            if ([utextfield.text length]==0) {
                UIAlertView* alert;
                alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"邀请的号码不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                [alert release];
                return;
            }
            else
            {
                [self.modelEngineVoip inviteMembers:([NSArray arrayWithObject:utextfield.text]) joinChatroom:self.curChatroomId ofAppId:self.modelEngineVoip.appID];
            }
        }
    }
    [alertView release];
    
    NSLog(@"CustomeAlertViewDismiss");
}

- (void) CreateClearBackBtn:(CGFloat)alpha :(UIColor*) backColor
{
    int height = 480;
    if (IPHONE5)
        height = 568;
    UIButton* backgroundBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    [backgroundBtn addTarget:self action:@selector(removeMenu) forControlEvents:UIControlEventTouchUpInside];
    backgroundBtn.backgroundColor = backColor;
    backgroundBtn.alpha  = alpha;
    backgroundBtn.tag = MENUVIEW_TAG;
    [self.navigationController.view addSubview:backgroundBtn];
    [backgroundBtn release];
}

- (void) removeMenu
{
    for(UIView* u in self.navigationController.view.subviews)
    {
        if (u.tag == MENUVIEW_TAG)
        {
            [u removeFromSuperview];
        }
    }
}

-(void)management
{
    [self CreateClearBackBtn:1 :[UIColor clearColor]];
    UICustomView* MenuView;

    MenuView = [[UICustomView alloc] initWithFrame:CGRectMake(170, 14, 135, 167)
                                     andLabel1Text:@"邀请电话用户加入"
                                     andLabel2Text:@"管理成员"
                                     andLabel3Text:@"解散房间"
                                     andLabel4Text:isLoud?@"听筒":@"扬声器"];
    MenuView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, 0.01), 0, 0);
    [self.navigationController.view addSubview:MenuView];
    MenuView.tag = MENUVIEW_TAG;
    [MenuView set_Delegate:self];
    [MenuView release];    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    MenuView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, 1), 0, 48);
    [UIView commitAnimations];
}

-(void) ChooseWithFlag:(NSInteger)Flag{
    [self removeMenu];
    switch (Flag)
    {
        case 1:
            [self addMember];
            break;
        case 2:
            [self kickOff];
            break;
        case 3:
            [self dissolve];
            break;
        case 4:
            [self loudSperker:nil];
            break;
        default:
            break;
    }
}

-(void)kickOff
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:self.membersArray];
    for (ChatroomMember* member in array) {
        if ([member.number isEqualToString:self.modelEngineVoip.voipAccount])//把自己过滤出来
        {
            [array removeObject:member];
            break;
        }
    }
    if ([array count] > 0)
    {
        RoomMemberViewController* view = [[RoomMemberViewController alloc] initWithRoomNo:self.curChatroomId Members:array];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else
    {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有可以管理的成员" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertview show];
        [alertview release];
    }
}

-(void)dissolve
{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"解散确认" message:@"你确定要解散房间吗？解散后不可恢复。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"解散", nil];
    alertview.tag = ChatRoomVIEW_dissolve;
    [alertview show];
    [alertview release];
}

-(void)onChatroomDismissWithReason:(CloopenReason *)reason andRoomNo:(NSString *)roomNo
{
    if (reason.reason == 0)
    {
        isCreatorExit = YES;        
        //可以等收到解散通知再退出界面
    }
    else if (reason.reason == 101020 || reason.reason == 110183)//101020或者110183会议不存在这时候可以直接退出
    {
        [self backToView];
    }
    else if (reason.reason == 110095)
    {
        [self dismissProgressingView];
        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"提示" message:@"解散会议失败，权限验证失败，只有创建者才能解散"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertview show];
        [alertview release];
    }
    else if (reason.reason == 170005)//网络错误，直接挂机
    {
        [self exitCurChatroom];
    }
    else
    {
        [self dismissProgressingView];
        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"提示" message:@"解散会议失败，请稍后再试..."  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertview show];
        [alertview release];
    }
}

- (void)loadView
{
    isLoud = YES;
    self.title = roomname;
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    self.view.backgroundColor = ChatRoomVIEW_BACKGROUND_COLOR;
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"退出" target:self action:@selector(showExitAlert)]];
    self.navigationItem.leftBarButtonItem = left;
    [left release];
    
    if (isCreator)
    {
        UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"管理" target:self action:@selector(management)]];
        self.navigationItem.rightBarButtonItem = rightBar;
        [rightBar release];
    }
    else
    {
        UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:isLoud?@" 听筒 ":@"扬声器" target:self action:@selector(loudSperker:)]];
        self.navigationItem.rightBarButtonItem = rightBar;
        [rightBar release];
    }
    
    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point_bg.png"]];
    pointImg.frame = CGRectMake(0.0f, 0.0f, 320.0f, 29.0f);
    [self.view addSubview:pointImg];
    [pointImg release];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 265.0f, 29.0f)];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont systemFontOfSize:13.0f];
    statusView = statusLabel;
    statusLabel.text = [NSString stringWithFormat:@"正在%@房间",self.curChatroomId];
    [self.view addSubview:statusLabel];
    [statusLabel release];
    
    UILabel *memberlistLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 40.0f, 100.0f, 15.0f)];
    memberlistLabel.backgroundColor = ChatRoomVIEW_BACKGROUND_COLOR;
    memberlistLabel.textColor = [UIColor whiteColor];
    memberlistLabel.text = @"成员列表";
    [self.view addSubview:memberlistLabel];
    [memberlistLabel release];
    
    UIView *listView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 55.0f, 320.0f, 80.0f)];
    [self.view addSubview:listView];
    membersListView = listView;
    [listView release];
    


    animBackview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"animation_bg.png"]];
    animBackview.center = CGPointMake(160.0f, self.view.frame.size.height*0.5);
    animBackview.clipsToBounds = YES;
    animationBoxCount = 320.0f/13.0f;   
    for (NSInteger i=0; i<animationBoxCount; i++)
    {
        NSInteger index = arc4random() % 4 + 1;
        NSString *fileName = [NSString stringWithFormat:@"animation_box0%d.png",index];
        UIImageView *tmpImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
        tmpImg.frame = CGRectMake(2.0f+13.0f*i, 58.0f-tmpImg.frame.size.height-3.0f, 9.0f, tmpImg.frame.size.height);
        [animBackview addSubview:tmpImg];
        tmpImg.tag = 500;
        [tmpImg release];
    }
    
    animationBoxTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateAnimationBox) userInfo:nil repeats:YES];
    
    UIImageView *tmpImg2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice_icon.png"]];
    tmpImg2.center = CGPointMake(160.0f, animBackview.frame.size.height*0.5);
    tmpImg2.clipsToBounds = YES;
    [animBackview addSubview:tmpImg2];
    [tmpImg2 release];
    
    [self.view addSubview:animBackview];
    [animBackview release];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 150.0f-44, 320.0f, 28.0f)];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:10];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"";
    netStatusLabel = label;
    [self.view addSubview:label];
    [label release];
    
    CGFloat buttom_Y = self.view.frame.size.height - 150.0f-44+30;
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, buttom_Y, 320.0f, 20.0f)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    label1.font = [UIFont systemFontOfSize:20];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"您的发言能让成员都听到";
    [self.view addSubview:label1];
    [label1 release];
    
    buttom_Y = buttom_Y + 30.0f;
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, buttom_Y, 320.0f, 14.0f)];
    label2.textColor = [UIColor grayColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.font = [UIFont systemFontOfSize:13];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"点击下方麦克风静音";
    [self.view addSubview:label2];
    tipsLabel = label2;
    [label2 release];
    
    UIView* view1 = [[UIView alloc] init];
    view1.frame = CGRectMake(0, self.view.frame.size.height-74, 320, 30);
    view1.backgroundColor = ChatRoomVIEW_BACKGROUND_COLOR;
    [self.view addSubview:view1];
    amplitudeView = view1;
    [view1 release];
    
    isMute = NO;
    UIButton *micBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    micBtn.frame = CGRectMake(115.0f, self.view.frame.size.height-105.0f, 89.0f, 61.0f);
    [micBtn addTarget:self action:@selector(muteMic:) forControlEvents:UIControlEventTouchUpInside];
    [micBtn setImage:[UIImage imageNamed:@"mike_icon.png"] forState:UIControlStateNormal];
    [self.view addSubview:micBtn];
//    [self showAmplitude];
    for (int i = 0; i<=13; i++)
    {
        UIImageView* iv1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status01_icon_off.png"]];
        int left1 = 7+(16*i);
        if (i>=7)
            left1 = left1+95;
        iv1.frame = CGRectMake(left1,12, 9, 9);
        iv1.tag = 1007;
        [amplitudeView addSubview:iv1];
        [iv1 release];
        
        UIImageView* iv2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status01_icon_on.png"]];
        int left2 = 7+(16*i);
        if (i>=7)
            left2 = left2+95;
        iv2.frame = CGRectMake(left2,12, 9, 9);
        iv2.tag = 2000+i;
        iv2.hidden = YES;
        [amplitudeView addSubview:iv2];
        [iv2 release];
    }
    [self playAmplitude];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.modelEngineVoip setUIDelegate:self];
    if ([curChatroomId length] > 0)
    {
        [self displayProgressingView];
        [self.modelEngineVoip queryMembersWithChatroom:curChatroomId];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    [animationBoxTimer invalidate];
    animationBoxTimer = nil;
    self.membersArray = nil;
    self.curChatroomId = nil;
    self.roomname = nil;
    [super dealloc];
}

- (void)updateAnimationBox
{
    NSInteger originX_i = arc4random() % animationBoxCount;
    for (UIView *view in animBackview.subviews)
    {
        if (view.tag == 500)
        {
            originX_i++;
            if (originX_i == animationBoxCount)
            {
                originX_i = 0;
            }
            view.frame = CGRectMake(2.0f+13.0f*originX_i, 58.0f-view.frame.size.height-3.0f, 9.0f, view.frame.size.height);
        }
    }
}
-(void)startNetworkStatistic
{
    self.timerNetworkStatistic = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(networkStatistic) userInfo:nil repeats:YES];
}

-(void)networkStatistic
{
    NetworkStatistic* networkStatistic = [self.modelEngineVoip.VoipCallService getNetworkStatisticWithCallId:self.curChatroomId];
    if (networkStatistic)
    {
        netStatusLabel.text = [NSString stringWithFormat:@"统计时长%qi秒，发送：%0.2f（kB）接收：%0.2f（kB）",networkStatistic.duration,networkStatistic.txBytes / 1024.,networkStatistic.rxBytes / 1024.];
    }
}

-(void)stopNetworkStatistic
{
    [self.timerNetworkStatistic invalidate];
    self.timerNetworkStatistic = nil;
}

-(void)playAmplitude
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(showAmplitude) userInfo:nil repeats:YES];
}

-(void)stopAmplitude
{
    [self.timer invalidate];
    self.timer = nil;
    for (UIView *view in amplitudeView.subviews)
    {
        if (view.tag >=2000)
            [view setHidden:YES];
    }
}

-(void)showAmplitude
{
    int i = arc4random() % 3;
    for (UIView *view in amplitudeView.subviews)
    {
        if (view.tag >= 2000 && view.tag < 2007)
        {
            int itag = 2000+i+1;
            if (view.tag > itag)
                view.hidden = NO;
            else
                view.hidden = YES;
        }
        else if (view.tag >= 2007 && view.tag <= 2013)
        {
            int itag = 2007+(7-i-2);
            if (view.tag < itag)
                view.hidden = NO;
            else
                view.hidden = YES;
        }
    }
}
- (void)muteMic:(id)sender
{
    isMute = !isMute;
    [self.modelEngineVoip setMute:isMute];
    if (isMute)
    {
        tipsLabel.text = @"麦克风已关闭，可点击开启";
        [self stopAmplitude];
    }
    else
    {
        tipsLabel.text = @"可点击下方麦克风静音";
        [self playAmplitude];
    }
}

- (void)loudSperker:(id)sender
{
    isLoud = !isLoud;
    [self.modelEngineVoip enableLoudsSpeaker:isLoud];

    if (sender != nil)
    {
        UIButton* btn = (UIButton*)sender;
        [btn setTitle:isLoud?@" 听筒 ":@"扬声器" forState:UIControlStateNormal];
    }
}
- (void)backToView
{
    [self dismissProgressingView];
    [self.navigationController popToViewController:self.backView animated:YES];
}

- (void)reloadMembersData
{
    for (UIView* view in membersListView.subviews)
    {
        if (view.tag >= 1001 && view.tag < 1005)
        {
            [view removeFromSuperview];
        }
    }
    int i = 0;
    for (ChatroomMember* member in membersArray)
    {
        NSString* strImg = nil;
        if (i == 0)
        {
            strImg = @"touxiang.png";
        }
        else
            strImg = @"status01_icon.png";
        UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:strImg]];
        int j = i % 2;
        int left = 30+150*j;
        int row = i/2;
        int top  = 20+(20*row);
        iv.frame = CGRectMake(left,top, 9, 9);
        iv.tag = 1001;
        [membersListView addSubview:iv];
        [iv release];
        
        UILabel *lbMember = [[UILabel alloc] initWithFrame:CGRectMake(left+12, top-1, 100.0f, 13.0f)] ;
        lbMember.backgroundColor = [UIColor clearColor];
        lbMember.textColor = [UIColor whiteColor];
        lbMember.textAlignment = UITextAlignmentLeft;
        lbMember.tag = 1002;
        lbMember.font = [UIFont systemFontOfSize:12.0f];
        lbMember.text = member.number;
        [membersListView addSubview:lbMember];
        [lbMember release];        
        i++;
    }
}

-(void)createChatroomWithChatroomName:(NSString*)chatroomName andPassword:(NSString *)roomPwd andSquare:(NSInteger)square andKeywords:(NSString *)keywords inAppId:(NSString*)appid andIsAutoClose:(BOOL)isAutoClose andVoiceMod:(NSInteger) voiceMod andAutoDelete:(BOOL) autoDelete andIsAutoJoin:(BOOL) isAutoJoin;
{
    statusView.text =@"连接中，请稍后....";
    [self.modelEngineVoip startChatroomWithName:chatroomName andPassword:roomPwd andSquare:square andKeywords:keywords inAppId:appid andIsAutoClose:isAutoClose andVoiceMod:voiceMod andAutoDelete:autoDelete andIsAutoJoin:isAutoJoin];
    [self displayProgressingView];
}

- (void) joinChatroomInRoom:(NSString *)roomNo andPwd:(NSString *)pwd
{
    statusView.text =@"连接中，请稍后....";
    [self.modelEngineVoip joinChatroomInRoom:roomNo andPwd:pwd];
    [self displayProgressingView];
}

/********************聊天室的方法********************/
//聊天室状态
- (void)onChatroomStateWithReason:(CloopenReason *) reason andRoomNo:(NSString*)roomNo
{
    [self dismissProgressingView];
    if (reason.reason == 0 && roomNo.length > 0)
    {
        self.curChatroomId = roomNo;
        if ([curChatroomId length] > 0)
        {
            [self displayProgressingView];
            [self.modelEngineVoip queryMembersWithChatroom:curChatroomId];
        }
        statusView.text = [NSString stringWithFormat:@"正在%@房间",self.curChatroomId];
        [self startNetworkStatistic];
    }
    else
    {
        if (reason.reason == 707)
        {
            reason.msg = [NSString stringWithFormat: @"房间%@已解散或者不存在！",roomNo];
        }
        else if (reason.reason == 708)
        {
            reason.msg = @"密码验证失败！";
        }
        NSString *msg = [NSString stringWithFormat:@"错误码:%d\r\n错误详情:%@", reason.reason, reason.msg.length>0?reason.msg:@"未知"];
        UIAlertView *alertView=nil;
        alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alertView.tag = ChatRoomVIEW_joinChatroomErr;
        [alertView show];
        [alertView release];
    }
}
-(void)showExitAlert
{
    if (isCreator)
    {        
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"退出选项" message:@"真的要退出吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
        alertview.tag = ChatRoomVIEW_exitAlert;
        [alertview show];
        [alertview release];
    }
    else
        [self exitCurChatroom];
}
//退出当前的房间
-(void)exitCurChatroom
{
    [self stopAmplitude];
    [self stopNetworkStatistic];
    [self.modelEngineVoip exitChatroom];
    [self backToView];
}

/********************聊天室的方法********************/

//通知客户端收到新的聊天室信息
- (void)onReceiveChatroomMsg:(ChatroomMsg*) receiveMsgInfo
{
    if([receiveMsgInfo isKindOfClass:[ChatroomJoinMsg class]])
    {
        //有人加入
        ChatroomJoinMsg *msg = (ChatroomJoinMsg*)receiveMsgInfo;
        
        if ([self.curChatroomId isEqualToString:msg.roomNo])
        {
            statusView.text = @"有人加入房间";
            for (NSString *who in msg.joinArr)
            {
                BOOL isHave = NO;
                for (ChatroomMember* tmp in self.membersArray)
                {
                    if ([tmp.number isEqualToString:who])
                    {
                        isHave = YES;
                        break;
                    }
                }
                if (isHave)
                {
                    continue;
                }
                ChatroomMember *member = [[ChatroomMember alloc] init];
                member.number = who;
                member.type = @"0";
                [self.membersArray addObject:member];
                [member release];
            }
            [self reloadMembersData];
        }
    }
    else if([receiveMsgInfo isKindOfClass:[ChatroomExitMsg class]])
    {
        //有人退出
        ChatroomExitMsg *msg = (ChatroomExitMsg*)receiveMsgInfo;
        if ([self.curChatroomId isEqualToString:msg.roomNo])
        {
            statusView.text = @"有人退出房间";
            NSMutableArray *exitArr = [[NSMutableArray alloc] init];
            for (NSString *who in msg.exitArr)
            {
                for (ChatroomMember *member in self.membersArray)
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
            }
            [exitArr release];
            
            [self reloadMembersData];
        }
    }
    else if([receiveMsgInfo isKindOfClass:[ChatroomDismissMsg class]])
    {
        if ([receiveMsgInfo.roomNo isEqualToString:self.curChatroomId])
        {
            if (isCreatorExit)//创建者自己主动解散会议自己不再提示
            {
                [self backToView];
            }
            else
            {
                UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"房间被解散" message:@"抱歉，该房间已经被创建者解散，点击确定可以退出！"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertview.tag = ChatRoomVIEW_RoomDisslove;
                [alertview show];
                [alertview release];
            }
        };
    }
    else if([receiveMsgInfo isKindOfClass:[ChatroomRemoveMemberMsg class]])
    {
        if ([receiveMsgInfo.roomNo isEqualToString: self.curChatroomId])
        {
            ChatroomRemoveMemberMsg* msg = (ChatroomRemoveMemberMsg*)receiveMsgInfo;
            if ([msg.who isEqualToString:self.modelEngineVoip.voipAccount])//自己被踢出
            {
                UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"您已被请出房间" message:@"抱歉，您被创建者请出房间了，点击确定以退出"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertview.tag = ChatRoomVIEW_kickOff;
                [alertview show];
                [alertview release];
                return;
            }
            statusView.text = @"有人被踢出房间";            
            NSMutableArray *delArr = [[NSMutableArray alloc] init];
            for (ChatroomMember *member in self.membersArray)
            {
                if ([msg.who isEqualToString:member.number])
                {
                    [delArr addObject:member];
                }
            }
            if (delArr.count > 0)
            {
                [self.membersArray removeObjectsInArray:delArr];
            }
            [delArr release];
            [self reloadMembersData];
        }
    }
}


//获取聊天室的成员
- (void)onChatroomMembersWithReason:(CloopenReason *) reason andData:(NSArray*)members
{
    [self dismissProgressingView];
    if (reason.reason == 0)
    {
        self.membersArray = [[[NSMutableArray alloc] initWithArray:members] autorelease];
        ChatroomMember *meInfo = nil;
        for (ChatroomMember *member in self.membersArray)
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
