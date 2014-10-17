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

#import "CallViewController.h"
#import "VoipCallController.h"
@interface CallViewController ()

@end

@implementation CallViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)keyboardHide
{
    [tfPhoneNO resignFirstResponder];
    [tfMyPhoneNO resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:textField.text forKey:@"myPhoneNO"];
    [defaults synchronize];
    [self.modelEngineVoip setVoipPhone:textField.text];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"落地电话";
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    UIButton *bgBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320.0, self.view.frame.size.height)];
    bgBtn.backgroundColor = [UIColor clearColor];
    [bgBtn addTarget:self action:@selector(keyboardHide) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bgBtn];
    [bgBtn release];
    
    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point_bg.png"]];
    pointImg.frame = CGRectMake(0.0f, 0.0f, 320.0f, 29.0f);
    [self.view addSubview:pointImg];
    [pointImg release];
    
    UILabel *lbhead = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 29.0f)] ;
    lbhead.backgroundColor = [UIColor clearColor];
    lbhead.textColor = [UIColor whiteColor];
    lbhead.textAlignment = UITextAlignmentLeft;
    lbhead.font = [UIFont systemFontOfSize:13.0f];
    lbhead.text =  @"    请输入被叫号码并选择落地呼叫方式";
    [self.view addSubview:lbhead];
    [lbhead release];
    
    int top1 = 47;
    int top2 = 54;
    int top3 = 90;
    int top4 = 115;
    int top5 = 119;
    int top6 = 156;
    int top7 = 230;
    int top8 = 350;
    int top9 = 344;
    if (IPHONE5)
    {
        top1 = 57;
        top2 = 64;
        top3 = 110;
        top4 = 135;
        top5 = 139;
        top6 = 186;
        top7 = 250;
        top8 = 380;
        top9 = 374;
    }
    
    UIImageView *inputVoipImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"internet_box.png"]];
    inputVoipImg.frame = CGRectMake(20.0f, top1, 283.5f, 30.0f);
    [self.view addSubview:inputVoipImg];
    [inputVoipImg release];
    
    tfMyPhoneNO = [[UITextField alloc] initWithFrame:CGRectMake(135.0f, top2, 161.0f, 20.0f)] ;
    tfMyPhoneNO.backgroundColor = [UIColor clearColor];
    tfMyPhoneNO.delegate = self;
    tfMyPhoneNO.keyboardType = UIKeyboardTypePhonePad;
    tfMyPhoneNO.textAlignment = UITextAlignmentRight;
    tfMyPhoneNO.font = [UIFont systemFontOfSize:13];
    if ([self.modelEngineVoip.voipPhone length]>0)
    {
        tfMyPhoneNO.text = self.modelEngineVoip.voipPhone;
    }
    else
        tfMyPhoneNO.placeholder = @"请工作人员先设置本机号码";
    [self.view addSubview:tfMyPhoneNO];
    [tfMyPhoneNO release];
    
    UILabel *lbTitle1 = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, top3, 200.0f, 20.0f)] ;
    lbTitle1.backgroundColor = [UIColor clearColor];
    lbTitle1.textColor = [UIColor blackColor];
    lbTitle1.textAlignment = UITextAlignmentLeft;
    lbTitle1.font = [UIFont systemFontOfSize:18.0f];
    lbTitle1.text =  @"请输入被叫号码：";
    [self.view addSubview:lbTitle1];
    [lbTitle1 release];
    
    UIImageView *inputImg1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"input_box.png"]];
    inputImg1.frame = CGRectMake(20.0f, top4, 250.f, 29);
    [self.view addSubview:inputImg1];
    [inputImg1 release];
    
    tfPhoneNO = [[UITextField alloc] initWithFrame:CGRectMake(26.0f, top5, 244.f, 20.0f)] ;
    tfPhoneNO.backgroundColor = [UIColor clearColor];
    tfPhoneNO.textAlignment = UITextAlignmentLeft;
    tfPhoneNO.keyboardType = UIKeyboardTypePhonePad;
    tfPhoneNO.font = [UIFont systemFontOfSize:16.0f];
    tfPhoneNO.placeholder =  @"固话需加拨区号";
    [self.view addSubview:tfPhoneNO];
    [tfPhoneNO release];     
    
    UIButton *chooseContactsBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    chooseContactsBtn.frame = CGRectMake(272.f, top5-11, 45, 45);
    chooseContactsBtn.backgroundColor = [UIColor clearColor];
    [chooseContactsBtn addTarget:self action:@selector(goChoosePhoneNumber) forControlEvents:UIControlEventTouchUpInside];
    [chooseContactsBtn setImage:[UIImage imageNamed:@"ios_contact.png"] forState:UIControlStateNormal];
    [chooseContactsBtn setImage:[UIImage imageNamed:@"ios_contact.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:chooseContactsBtn];
    
    
     UIButton *voipDirectCallBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
     voipDirectCallBtn.frame = CGRectMake(36.f, top6, 111.f, 37.f);
     [voipDirectCallBtn addTarget:self action:@selector(voipDirectCall) forControlEvents:UIControlEventTouchUpInside];
     [voipDirectCallBtn setTitle:@"网络直拨" forState:UIControlStateNormal];
     [voipDirectCallBtn setBackgroundImage:[UIImage imageNamed:@"internet_phone_button1_off.png"] forState:UIControlStateNormal];
     [voipDirectCallBtn setBackgroundImage:[UIImage imageNamed:@"internet_phone_button1_on.png"] forState:UIControlStateHighlighted];
     [self.view addSubview:voipDirectCallBtn];
     
     UIButton *voipFreeCallBtn = [UIButton buttonWithType:UIButtonTypeCustom];
     voipFreeCallBtn.frame = CGRectMake(173.0f, top6, 111.f, 37.0f);
     [voipFreeCallBtn addTarget:self 	action:@selector(voipBackCall) forControlEvents:UIControlEventTouchUpInside];
     [voipFreeCallBtn setTitle:@"网络回拨" forState:UIControlStateNormal];
     [voipFreeCallBtn setBackgroundImage:[UIImage imageNamed:@"internet_phone_button2_off.png"] forState:UIControlStateNormal];
     [voipFreeCallBtn setBackgroundImage:[UIImage imageNamed:@"internet_phone_button2_on.png"] forState:UIControlStateHighlighted];
     [self.view addSubview:voipFreeCallBtn];
     
    UILabel *lbTips1 = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, top7, 240.0f, 100.0f)] ;
    lbTips1.backgroundColor = [UIColor clearColor];
    lbTips1.textColor = [UIColor grayColor];
    lbTips1.numberOfLines = 7;
    lbTips1.textAlignment = UITextAlignmentLeft;
    lbTips1.font = [UIFont systemFontOfSize:12.0f];
    lbTips1.text =  @"网络直拨：对本地网络质量有要求，建议使用WIFI/3G网络呼出，对被叫网络没有要求\n\n网络回拨：通话不依赖网络，成功发起呼叫请求后会先有一个来电，接听后即可呼叫对方";
    [self.view addSubview:lbTips1];
    [lbTips1 release];
    
    
    UIImageView *imgTips = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voip_status_icon.png"]];
    imgTips.frame = CGRectMake(25.0f, top8, 9.5f, 9.5f);
    [self.view addSubview:imgTips];
    [imgTips release];
    
    UILabel *lbTips2 = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, top9, 270.0f, 20.0f)] ;
    lbTips2.backgroundColor = [UIColor clearColor];
    lbTips2.textColor = [UIColor grayColor];
    lbTips2.textAlignment = UITextAlignmentLeft;
    lbTips2.font = [UIFont systemFontOfSize:12.0f];
    lbTips2.text =  @"连接已准备就绪，可以呼出或接听电话";
    [self.view addSubview:lbTips2];
    [lbTips2 release];

}
-(BOOL)checkPhoneNO
{
    if ([tfPhoneNO.text length] <= 3)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入正确的电话号码。" delegate:self
                                              cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return NO;
    }
    return YES;
}
-(void)voipBackCall
{
    if (![self checkPhoneNO]) {
        return;
    }
    [self keyboardHide];
    //电话回拨
    VoipCallController *myVoipCallController = [[VoipCallController alloc]
                                                initWithCallerName:@""
                                                andCallerNo:tfPhoneNO.text
                                                andVoipNo:@""
                                                andCallType:2];
    [self presentModalViewController:myVoipCallController animated:YES];
    [myVoipCallController release];
}
     
-(void)voipDirectCall
{
    if (![self checkPhoneNO]) {
        return;
    }
    [self keyboardHide];
    //电话直拨
    VoipCallController *myVoipCallController = [[VoipCallController alloc]
                                                initWithCallerName:@""
                                                andCallerNo:tfPhoneNO.text
                                                andVoipNo:@""
                                                andCallType:1];
    [self presentModalViewController:myVoipCallController animated:YES];
    [myVoipCallController release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self.modelEngineVoip setUIDelegate:self];
}

-(void)getPhoneNumber:(NSString *)phoneNumber
{
    tfPhoneNO.text = phoneNumber;
}
@end
