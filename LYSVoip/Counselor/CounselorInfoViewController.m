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

#import "counselorInfoViewController.h"
#import "orderConsultViewController.h"
#import "ConsultView.h"
#import "VoipCallController.h"
#import "AppDelegate.h"
#import "ASIHTTPRequest.h"
#import "Demo_GDataXMLParser.h"

@interface counselorInfoViewController ()

@end

@implementation counselorInfoViewController
-(void)dealloc
{
    self.IDStr = nil;
    self.NameStr = nil;
    self.detail = nil;
    self.path = nil;
    self.personInfo = nil;
    self.gradeStr = nil;
    self.textPhone = nil;
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
-(id)initWithID:(NSString*) strID andName:(NSString*)strName
{
    if (self = [super init])
    {
        self.IDStr = strID;
        self.NameStr = strName;
        return self;
    }
    return nil;
}
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(back)]];
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];
        
    {
        UILabel* lab1;
        lab1 = [[UILabel alloc] init];
        lab1.frame = CGRectMake(85, 12, 100, 20);
        lab1.text = self.NameStr;
        lab1.textColor = [UIColor blackColor];
        lab1.font = [UIFont boldSystemFontOfSize:16];
        lab1.highlightedTextColor = [UIColor whiteColor];
        lab1.backgroundColor = [UIColor clearColor];
        lab1.tag = 1001;
        [self.view addSubview:lab1];
        [lab1 release];
        
        UILabel* lab2;
        lab2 = [[UILabel alloc] initWithFrame:CGRectMake(170, 12, 230, 20)];
        lab2.textColor = [UIColor colorWithRed:(130.0/255) green:(130.0/255) blue:130.0/255 alpha:1.0];
        lab2.highlightedTextColor = [UIColor whiteColor];
        lab2.text = self.gradeStr;
        lab2.font = [UIFont systemFontOfSize:13];
        lab2.backgroundColor = [UIColor clearColor];
        lab2.tag = 1001;
        [self.view addSubview:lab2];
        [lab2 release];
        
        for (int i = 0; i<=4; i++)
        {
            UIImageView * img1;
            img1 = [[UIImageView alloc] init];
            img1.frame = CGRectMake(85+14*i, 37, 10, 14);
            if (self.grade >= i+1)
            {
                img1.image = [UIImage imageNamed:@"star_01.png"];
            }
            else
                img1.image = [UIImage imageNamed:@"star_02.png"];
            img1.tag = 1001;
            [self.view addSubview:img1];
            [img1 release];
        }
        
        UILabel* lab3;
        lab3 = [[UILabel alloc] initWithFrame:CGRectMake(85, 55, 230, 15)];
        lab3.textColor = [UIColor colorWithRed:(130.0/255) green:(130.0/255) blue:130.0/255 alpha:1.0];
        lab3.highlightedTextColor = [UIColor whiteColor];
        lab3.text = [NSString stringWithFormat:@"专长：%@",self.detail];
        lab3.font = [UIFont systemFontOfSize:13];
        lab3.backgroundColor = [UIColor clearColor];
        lab3.tag = 1001;
        [self.view addSubview:lab3];
        [lab3 release];
        
        UIImageView * img1;
        img1 = [[UIImageView alloc] init];
        img1.frame = CGRectMake(12, 12, 59, 59);
        
        img1.image = [UIImage imageNamed:@"head_portrait_01.png"];
        img1.tag = 1001;
        [self.view addSubview:img1];
        [img1 release];
        
        UIImageView * img2;
        img2 = [[UIImageView alloc] init];
        img2.frame = CGRectMake(15, 15, 53, 53);
        img2.image = [UIImage imageNamed:self.path];
        img2.tag = 1001;
        [self.view addSubview:img2];
        [img2 release];
        
    }
    
    
    UIImageView * img1;
    img1 = [[UIImageView alloc] init];
    img1.frame = CGRectMake(16, 91, 287, 251);
    img1.image = [UIImage imageNamed:@"detail_img.png"];
    img1.tag = 1001;
    [self.view addSubview:img1];
    [img1 release];

    
    {
        UILabel* iv =  [[UILabel alloc] initWithFrame:CGRectMake(22, 160-64, 100, 20)];
        iv.tag = 1009;
        iv.font = [UIFont systemFontOfSize:15];
        iv.textColor =[UIColor blackColor];
        iv.backgroundColor = [UIColor clearColor];
        iv.text = @"专业领域：";
        [self.view addSubview:iv];
        [iv release];
    }
    
    {
        
        UILabel* iv =  [[UILabel alloc] initWithFrame:CGRectMake(22, 159-64, 280, 60)];
        iv.tag = 1009;
        iv.font = [UIFont systemFontOfSize:13];
        iv.numberOfLines = 4;
        iv.textColor =[UIColor grayColor];
        iv.backgroundColor = [UIColor clearColor];
        iv.text = @"                     中西医结合 | 各种疑难杂症 | 疾病防治 | 急救处理 | 养生保健 | 健康咨询 | 用药建议  | 专业精湛 | 医术高超 | 包治百病 | 华佗再世";
        [self.view addSubview:iv];
        [iv release];
    }
    
    {
        UILabel* iv =  [[UILabel alloc] initWithFrame:CGRectMake(22, 220-44, 100, 20)];
        iv.tag = 1009;
        iv.font = [UIFont systemFontOfSize:15];
        iv.textColor =[UIColor blackColor];
        iv.backgroundColor = [UIColor clearColor];
        iv.text = @"个人信息：";
        [self.view addSubview:iv];
        [iv release];
    }
 
    {
        
        UILabel* iv =  [[UILabel alloc] initWithFrame:CGRectMake(22, 226-44, 280, 80)];
        iv.tag = 1009;
        iv.font = [UIFont systemFontOfSize:13];
        iv.numberOfLines = 7;
        iv.textColor =[UIColor grayColor];
        iv.backgroundColor = [UIColor clearColor];
        iv.text = @"                     主治医师（attending physician）是医院的职称之名，医生职称的一种，比住院医师高一级，比副主任医师低一级，属于中级职称。 不同与主治医生或“主治大夫”。医院的住院部各科室，将床位分配给各医生，每一床位的主要负责的医生，就被患者和同行称为主治医生或主治大夫，他们可由住院医师、主治医师和副主任医师担任。是一种责任人称呼。";
        [self.view addSubview:iv];
        [iv release];
    }
    
    
    self.title  = @"医师详情";
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255. alpha:1];
    
    {
        UIButton *ImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        ImgButton.frame = CGRectMake(26, 361, 114, 40);
        [ImgButton setBackgroundImage:[UIImage imageNamed:@"immediately_consult.png"] forState:UIControlStateNormal];
        [ImgButton setBackgroundImage:[UIImage imageNamed:@"immediately_consult_on.png"] forState:UIControlStateHighlighted];
        [ImgButton addTarget:self action:@selector(goConsult) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:ImgButton];
    }
    
    
    {
        UIButton *ImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        ImgButton.frame = CGRectMake(178, 361, 114, 40);
        
        [ImgButton setBackgroundImage:[UIImage imageNamed:@"reservation_inquiries.png"] forState:UIControlStateNormal];
        [ImgButton setBackgroundImage:[UIImage imageNamed:@"reservation_inquiries_on.png"] forState:UIControlStateHighlighted];
        [ImgButton addTarget:self action:@selector(orderConsult) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:ImgButton];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.modelEngineVoip.UIDelegate = self;
}

-(void)goConsult
{
    CGRect frame = CGRectMake(0, 0, 320, 480);
    if (IPHONE5)
    {
        frame.size.height = 576;
    }
    ConsultView* view = [[ConsultView alloc] initWithFrame:frame];
    
    [self.navigationController.view addSubview:view];
    view.tag = 1009;
    view.myDelegate = self;
    [view release];
    
    {
        UIImageView* iv =  [[UIImageView alloc] initWithFrame:CGRectMake(25, 80+44-25	, 272, 306)];
        iv.tag = 1009;
        iv.image = [UIImage imageNamed:@"liji_bg.png"];
        [self.navigationController.view addSubview:iv];
        [iv release];
    }
    
    
    {
        UIImageView* iv =  [[UIImageView alloc] initWithFrame:CGRectMake(272, 108, 16, 16)];
        iv.tag = 1009;
        iv.image = [UIImage imageNamed:@"quxiao.png"];
        [self.navigationController.view addSubview:iv];
        [iv release];
    }
    
{
    UILabel* iv =  [[UILabel alloc] initWithFrame:CGRectMake(37, 106, 200, 20)];
    iv.tag = 1009;
    iv.font = [UIFont systemFontOfSize:14];
    iv.textColor =[UIColor whiteColor];
    iv.backgroundColor = [UIColor clearColor];
    iv.text = [NSString stringWithFormat:@"与%@医师通话" ,self.NameStr];
    [self.navigationController.view addSubview:iv];
    [iv release];
}

    
{
    UILabel* iv =  [[UILabel alloc] initWithFrame:CGRectMake(37, 350/2-25, 100, 20)];
    iv.tag = 1009;
    iv.font = [UIFont systemFontOfSize:14];
    iv.textColor =[UIColor blackColor];
    iv.backgroundColor = [UIColor clearColor];
    iv.text =  @"咨询医师费：";
    [self.navigationController.view addSubview:iv];
    [iv release];
}
{
    UILabel* iv =  [[UILabel alloc] initWithFrame:CGRectMake(125, 350/2-25, 100, 20)];
    iv.tag = 1009;
    iv.font = [UIFont systemFontOfSize:14];
    iv.textColor =[UIColor orangeColor];
    iv.backgroundColor = [UIColor clearColor];
    iv.text = @"60";
    [self.navigationController.view addSubview:iv];
    [iv release];
}

{
    UILabel* iv =  [[UILabel alloc] initWithFrame:CGRectMake(150, 350/2-25, 100, 20)];
    iv.tag = 1009;
    iv.font = [UIFont systemFontOfSize:14];
    iv.textColor =[UIColor grayColor];
    iv.backgroundColor = [UIColor clearColor];
    iv.text = @"元 / 15分钟";
    [self.navigationController.view addSubview:iv];
    [iv release];
}



{    
    UILabel* iv =  [[UILabel alloc] initWithFrame:CGRectMake(37, 414/2-25, 100, 20)];
    iv.tag = 1009;
    iv.font = [UIFont systemFontOfSize:14];
    iv.textColor =[UIColor blackColor];
    iv.backgroundColor = [UIColor clearColor];
    iv.text = @"本机手机号：";
    [self.navigationController.view addSubview:iv];
    [iv release];
}
    {
        UIImageView* iv =  [[UIImageView alloc] initWithFrame:CGRectMake(122, 203-25,151, 23)];
        iv.tag = 1009;
        iv.image = [UIImage imageNamed:@"liji_box.png"];
        [self.navigationController.view addSubview:iv];
        [iv release];
    }
    
    {
        UITextField* iv =  [[UITextField alloc] initWithFrame:CGRectMake(122, 206-25, 151, 23)];
        iv.tag = 1009;
        iv.font = [UIFont systemFontOfSize:14];
        iv.textColor =[UIColor blackColor];
        iv.keyboardType = UIKeyboardTypePhonePad;
        iv.backgroundColor = [UIColor clearColor];
        iv.text = self.modelEngineVoip.voipPhone;
        self.textPhone = iv;
        [self.navigationController.view addSubview:iv];
        [iv release];
    }
{
    UILabel* iv =  [[UILabel alloc] initWithFrame:CGRectMake(37, 588/2-25, 200, 20)];
    iv.tag = 1009;
    iv.font = [UIFont systemFontOfSize:14];
    iv.textColor =[UIColor blackColor];
    iv.backgroundColor = [UIColor clearColor];
    iv.text = @"温馨提示：";
    [self.navigationController.view addSubview:iv];
    [iv release];
}


{
    
    UILabel* iv =  [[UILabel alloc] initWithFrame:CGRectMake(60, 638/2-25, 200, 50)];
    iv.tag = 1009;
    iv.font = [UIFont systemFontOfSize:14];
    iv.numberOfLines = 3;
    iv.textColor =[UIColor grayColor];
    iv.backgroundColor = [UIColor clearColor];
    iv.text = @"网络电话拨打可不扣手机通话费\n您的账户余额为300元，可咨询7\n5分钟，为避免通话中断，";
    [self.navigationController.view addSubview:iv];
    [iv release];
}

{
    UILabel* iv =  [[UILabel alloc] initWithFrame:CGRectMake(60, 740/2-25, 200, 20)];
    iv.tag = 1009;
    iv.font = [UIFont systemFontOfSize:14];
    iv.textColor =[UIColor blueColor];
    iv.backgroundColor = [UIColor clearColor];
    iv.text = @"请充值>>";
    [self.navigationController.view addSubview:iv];
    [iv release];
}

{
    UIButton *ImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    ImgButton.frame = CGRectMake(40, 250-25, 114, 41);
    ImgButton.tag = 1009;
    [ImgButton setBackgroundImage:[UIImage imageNamed:@"telephone_counseling.png"] forState:UIControlStateNormal];
    [ImgButton setBackgroundImage:[UIImage imageNamed:@"telephone_counseling_on.png"] forState:UIControlStateHighlighted];
    [ImgButton addTarget:self action:@selector(go400Call) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:ImgButton];
}


{
    UIButton *ImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    ImgButton.frame = CGRectMake(40+114+13, 250-25, 114, 41);
    ImgButton.tag = 1009;
    [ImgButton setBackgroundImage:[UIImage imageNamed:@"network_consulting.png"] forState:UIControlStateNormal];
    [ImgButton setBackgroundImage:[UIImage imageNamed:@"network_consulting_on.png"] forState:UIControlStateHighlighted];
    [ImgButton addTarget:self action:@selector(NetCall) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:ImgButton];
}

}
-(void)go400Call
{
    if (![self checkValueInput])
    {
        return;
    }
    if (![self callcounselor:1])
    {
        return;
    }
}

-(void)call400
{
    if ([self.modelEngineVoip.ivrPhone length] <= 0)
    {
        UIAlertView *tmpalert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务号码未配置，请联系云通讯商务人员！"
                                                          delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [tmpalert show];
        [tmpalert release];
        [self dismissProgressingView];
        return;
    }
    dialState = EDialAction;
    NSString *callUrl = [[NSString alloc]  initWithFormat:@"telprompt://%@",self.modelEngineVoip.ivrPhone];
    BOOL isCall = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callUrl]];
    [callUrl release];
    if (!isCall)
    {
        UIAlertView *tmpalert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该设备不支持电话功能"
                                                          delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [tmpalert show];
        tmpalert.tag = 100;
        [tmpalert release];
        [self dismissProgressingView];
        return;
    }
    [self dismissProgressingView];
}
-(void)callNetPhone
{
    [self dismissProgressingView];    
    VoipCallController *myVoipCallController = [[VoipCallController alloc]
                                                initWithCallerName:self.modelEngineVoip.myVoipPhone
                                                andCallerNo:@""
                                                andVoipNo:self.modelEngineVoip.myVoipPhone
                                                andCallType:0];
    [self presentModalViewController:myVoipCallController animated:YES];
    [myVoipCallController release];
}
-(void)NetCall
{
    if (![self callcounselor:2])
    {
        return;
    }
}
-(void)hideKey
{
    for (UIView *view in self.navigationController.view.subviews)
    {
        if (view.tag == 1009)
        {
            if ([view isKindOfClass:[UITextField class]])
            {
                [(UITextField*)view resignFirstResponder];
            }
        }
    }
}
-(void)closeMyPopView
{
    for (UIView *view in self.navigationController.view.subviews)
    {
        if (view.tag == 1009)
            [view removeFromSuperview];
    }
}
-(BOOL)checkValueInput
{
    for (UIView *view in self.navigationController.view.subviews)
    {
        if (view.tag == 1009)
        {
            if ([view isKindOfClass:[UITextField class]])
            {
                UITextField* tf = (UITextField*)view;
                [tf resignFirstResponder];
                
                if ( [tf.text isEqualToString:@""] )
                {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"手机号码输入错误" message:@"请检查您的手机号码是否输入正确!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    
                    [alertView show];
                    [alertView release];
                    return NO;
                }
                return YES;
            }
        }
    }
    return NO;
}
-(void)orderConsult
{
    [self hideKey];
    orderConsultViewController * view = [[orderConsultViewController alloc] init];
    view.grade = self.grade;
    view.gradeStr = self.gradeStr;
    view.IDStr = self.IDStr;
    view.NameStr = self.NameStr;
    view.detail = self.detail;
    view.path = self.path;
    [self .navigationController pushViewController:view animated:YES];
    [view release];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)callcounselor:(NSInteger)type
{
    [self displayProgressingView];
    self.callType = type;
    [self grabURLInBackgroundWithType:type];
    return YES;
}

- (void)grabURLInBackgroundWithType :(NSInteger)type
{
    NSString* strPhoneNum = self.modelEngineVoip.voipAccount;
    if (type == 1)
    {
        strPhoneNum = self.textPhone.text;
    }
    if ([strPhoneNum length] <=0)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"服务号码为配置" message:@"请配置服务号码!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }
    [self.modelEngineVoip lockExpertId:self.IDStr andSrcPhone:strPhoneNum];
}

- (void)onLoceExpertWithReason:(CloopenReason*)reason
{
    if (reason.reason == 0)
    {
        if (self.callType == 1)
        {
            [self performSelector:@selector(call400) withObject:nil afterDelay:0.1];
        }
        else if(self.callType == 2)
        {
            [self performSelector:@selector(callNetPhone) withObject:nil afterDelay:0.1];
        }
    }
    else
    {
        [self dismissProgressingView];
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
