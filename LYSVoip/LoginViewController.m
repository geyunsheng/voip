//
//  LoginViewController.m
//  CCPVoipDemo
//
//  Created by Ge-Yunsheng on 2014/09/22.
//  Copyright (c) 2014年 hisun. All rights reserved.
//

#import "LoginViewController.h"
#import "ASIFormDataRequest.h"
#import "DemoListViewController.h"
#import "TFHpple.h"
#import "UserBasicInfo.h"
#import "OpenUDID.h"
#import "SYAppStart.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

BOOL _isFirstWillAppear;
BOOL _isFirstDidAppear;


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
    self.title = @"创建账户";
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation.png"] forBarMetrics:0];
    [UIApplication sharedApplication].statusBarStyle =UIStatusBarStyleBlackTranslucent;

    UIImage* bgWhite = [UIImage imageNamed:@"Bg_white"];
    UIImageView* bgView = [[UIImageView alloc]initWithImage:bgWhite];
    bgView.frame = CGRectMake(0, 0, 320.0f, self.view.frame.size.height + 216.0f);//216键盘高度，避免最大值的偏移量
    [self.view addSubview:bgView];
    [bgView release];

    
    UILabel* loginUserID = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 30.0f, 50.0f, 30.0f)];
    loginUserID.text = @"工号:";
    loginUserID.font = [UIFont systemFontOfSize:16.0f];
    loginUserID.backgroundColor = [UIColor clearColor];
    [self.view addSubview:loginUserID];
    [loginUserID release];
    
    UITextField* loginUserIDText = [[UITextField alloc]initWithFrame:CGRectMake(85.0f, 30.0f, 200.0f, 30)];
    loginUserIDText.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    loginUserIDText.placeholder = @"请务必输入真实员工卡号";
    loginUserIDText.font = [UIFont systemFontOfSize:16.0f];
    loginUserIDText.backgroundColor = [UIColor clearColor];
    loginUserIDText.delegate = self;
    loginUserIDText.borderStyle = UITextBorderStyleRoundedRect;
    self.userID = loginUserIDText;
    [self.view addSubview:loginUserIDText];
    [loginUserIDText release];
    
    UILabel* loginUserName = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 70.0f, 50.0f, 30.0f)];
    loginUserName.text = @"姓名:";
    loginUserName.font = [UIFont systemFontOfSize:16.0f];
    loginUserName.backgroundColor = [UIColor clearColor];
    [self.view addSubview:loginUserName];
    [loginUserName release];
    
    UITextField* loginUserNameText = [[UITextField alloc]initWithFrame:CGRectMake(85.0f, 70.0f, 200.0f, 30)];
    loginUserNameText.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    loginUserNameText.placeholder = @"请务必输入真实姓名";
    loginUserNameText.font = [UIFont systemFontOfSize:16.0f];
    loginUserNameText.backgroundColor = [UIColor clearColor];
    loginUserNameText.delegate = self;
    loginUserNameText.borderStyle = UITextBorderStyleRoundedRect;
    self.userName = loginUserNameText;
    [self.view addSubview:loginUserNameText];
    [loginUserNameText release];
    
    UILabel* loginUserMail = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 110.0f, 50.0f, 30.0f)];
    loginUserMail.text = @"邮箱:";
    loginUserMail.font = [UIFont systemFontOfSize:16.0f];
    loginUserMail.backgroundColor = [UIColor clearColor];
    [self.view addSubview:loginUserMail];
    [loginUserMail release];
    
    UITextField* loginUserMailText = [[UITextField alloc]initWithFrame:CGRectMake(85.0f, 110.0f, 200.0f, 30)];
    loginUserMailText.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    loginUserMailText.placeholder = @"请输入邮箱地址";
    loginUserMailText.font = [UIFont systemFontOfSize:16.0f];
    loginUserMailText.backgroundColor = [UIColor clearColor];
    loginUserMailText.delegate = self;
    loginUserMailText.borderStyle = UITextBorderStyleRoundedRect;
    self.userMail = loginUserMailText;
    [self.view addSubview:loginUserMailText];
    [loginUserMailText release];
    
    UILabel* loginUserCompany = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 150.0f, 50.0f, 30.0f)];
    loginUserCompany.text = @"公司:";
    loginUserCompany.font = [UIFont systemFontOfSize:16.0f];
    loginUserCompany.backgroundColor = [UIColor clearColor];
    [self.view addSubview:loginUserCompany];
    [loginUserCompany release];

    RadioButton *rb1 = [[RadioButton alloc] initWithGroupId:@"first group" index:0];
    RadioButton *rb2 = [[RadioButton alloc] initWithGroupId:@"first group" index:1];
    RadioButton *rb3 = [[RadioButton alloc] initWithGroupId:@"first group" index:2];
    
    rb1.frame = CGRectMake(80,154,22,22);
    rb2.frame = CGRectMake(80,189,22,22);
    rb3.frame = CGRectMake(80,224,22,22);
    
    [self.view  addSubview:rb1];
    [self.view  addSubview:rb2];
    [self.view  addSubview:rb3];
    
    [rb1 release];
    [rb2 release];
    [rb3 release];
    
    UILabel *label1 =[[UILabel alloc] initWithFrame:CGRectMake(110, 150, 100, 30)];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"大连六元素";
    [self.view  addSubview:label1];
    [label1 release];
    
    UILabel *label2 =[[UILabel alloc] initWithFrame:CGRectMake(110, 185, 100, 30)];
    label2.backgroundColor = [UIColor clearColor];
    label2.text = @"长春六元素";
    [self.view  addSubview:label2];
    [label2 release];
    
    UILabel *label3 =[[UILabel alloc] initWithFrame:CGRectMake(110, 220, 100, 30)];
    label3.backgroundColor = [UIColor clearColor];
    label3.text = @"日本六元素";
    [self.view  addSubview:label3];
    [label3 release];
    
    [RadioButton addObserverForGroupId:@"first group" observer:self];

    UIButton* loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginButton.frame = CGRectMake(130.0f, 280.0f, 60.0f, 20.0f);
    [loginButton setTitle:@"注册" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [self.view addSubview:loginButton];
    
    UIActivityIndicatorView* loginWait = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loginWait.center = CGPointMake(160.0f, 340.0f);
    self.myAct = loginWait;
    [self.view addSubview:loginWait];
    [loginWait release];
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

-(void)login:(id)sender
{
    if ((self.userID.text.length == 0)||(self.userName.text.length == 0)||(self.userBasic.userCompany.length == 0)||(self.userMail.text.length == 0))
    {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:@"用户信息不完整,请补充" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    [self.myAct startAnimating];
    [self postSubAccountRequest];
}

- (void) postSubAccountRequest
{
    NSString* udid = [OpenUDID value];
    ASIFormDataRequest* _request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://voip.atjava.com/CreateSubAccount.php?type=1&token=voiprgs123"]];
    [_request setDelegate:self];
    [_request setPostValue:self.userID.text forKey:@"userid"];
    [_request setPostValue:self.userName.text forKey:@"username"];
 //   [_request setPostValue:self.userPwd forKey:@"password"];
    [_request setPostValue:self.userMail.text forKey:@"mail"];
    [_request setPostValue:self.userBasic.userCompany forKey:@"company"];
    [_request setPostValue:udid forKey:@"uuid"];
    [_request setDidFinishSelector:@selector(postSucceed:)];
    [_request setDidFailSelector:@selector(fail:)];
    [_request startAsynchronous];

}

- (void) postSucceed:(ASIHTTPRequest *)request
{
    NSData *data =[request responseData];
    
    TFHpple* xpathParser = [[TFHpple alloc] initWithXMLData:data];
    NSArray* ststus  = [xpathParser searchWithXPathQuery:@"//status"];
    NSString* strStatus = [[[[ststus objectAtIndex:0] children] objectAtIndex:0] content];
    
    if ([strStatus isEqual: @"error"])
    {
        //登录失败
        NSArray* ststus  = [xpathParser searchWithXPathQuery:@"//msg"];
        NSString* strMsg = [[[[ststus objectAtIndex:0] children] objectAtIndex:0] content];
        
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
    
    //登录成功
    if ([strStatus isEqual:@"success"])
    {
        //用户信息数据取得
        AccountInfo* info = [[AccountInfo alloc] init];
        
        NSArray* userID = [xpathParser searchWithXPathQuery:@"//userid"];
        NSArray* userName = [xpathParser searchWithXPathQuery:@"//username"];
        NSArray* userCompany = [xpathParser searchWithXPathQuery:@"//company"];
        NSArray* subAccount = [xpathParser searchWithXPathQuery:@"//sub_account"];
        NSArray* subToken = [xpathParser searchWithXPathQuery:@"//sub_token"];
        NSArray* voipAccount = [xpathParser searchWithXPathQuery:@"//voip_account"];
        NSArray* voipPassword = [xpathParser searchWithXPathQuery:@"//voip_password"];
        
        info.userID = [[[[userID objectAtIndex:0] children] objectAtIndex:0] content];
        info.userName = [[[[userName objectAtIndex:0] children] objectAtIndex:0] content];
        info.userCompany = [[[[userCompany objectAtIndex:0] children] objectAtIndex:0] content];
        info.subAccount = [[[[subAccount objectAtIndex:0] children] objectAtIndex:0] content];
        info.subToken = [[[[subToken objectAtIndex:0] children] objectAtIndex:0] content];
        info.voipId = [[[[voipAccount objectAtIndex:0] children] objectAtIndex:0] content];
        info.password = [[[[voipPassword objectAtIndex:0] children] objectAtIndex:0] content];
        
        //画面迁移
        DemoListViewController* pushSelectVC = [[[DemoListViewController alloc]init]autorelease];
        pushSelectVC.userBasic = info;
        [self.navigationController pushViewController:pushSelectVC animated:YES];
        [info release];
    }
    [self.myAct stopAnimating];

}

- (void)fail:(ASIHTTPRequest *)request
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Fail" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
    [self.myAct stopAnimating];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    
    int offset = (frame.origin.y + frame.size.height) - (self.view.frame.size.height - 216.0) + 10;//键盘高度216,空余高度10
 
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    if(offset > 0)
    {
        self.view.frame = CGRectMake(0.0f, 64 - offset, self.view.frame.size.width, self.view.frame.size.height);//64是导航栏和状态栏高度
    }
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame =CGRectMake(0, 64.0f, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!_isFirstWillAppear) {
        _isFirstWillAppear = YES;
        [SYAppStart show];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    if (!_isFirstDidAppear) {
        _isFirstDidAppear = YES;
        [SYAppStart hide:YES];
    }
}

-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId{
    self.userBasic = [[AccountInfo alloc]init];
    if(index == 0){
        self.userBasic.userCompany = @"大连六元素";
    }else if (index == 1){
        self.userBasic.userCompany = @"长春六元素";
    }else{
        self.userBasic.userCompany = @"日本六元素";
    }
    [self.userBasic release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
