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

#import "RoomNameViewController.h"
#import "ChatRoomViewController.h"

#define TAG_ALERTVIEW_ChatroomPwd  9999
#define TAG_ALERTVIEW_ChatroomName 9998

@interface RoomNameViewController ()
{
    NSInteger iVoiceMod;
    NSInteger bAutoDelete;
}
@property (nonatomic,retain)UITextField *nameTextField;
@property (nonatomic,retain)UITextField *pwdTextField;
@end

@implementation RoomNameViewController
@synthesize nameTextField;
@synthesize pwdTextField;
@synthesize backView;
@synthesize myScrollView;

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
    self.title = @"创建房间";
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    int iHeight = 240;
    int iValue = 360;
    if (IPHONE5)
    {
        iValue = 320;
        iHeight = 280;
    }
    
#ifdef Chatroom3_6_3_NewFlow
    iHeight = 240;
    iValue = 360;
    if (IPHONE5)
    {
        iValue = 320;
        iHeight = 280;
    }
#endif
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, iHeight)];
    scrollView.contentSize = CGSizeMake(320, iValue);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.scrollsToTop = NO;
    scrollView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    [self.view addSubview :scrollView];
    self.myScrollView = scrollView;
    self.myScrollView.delegate = self;
    [scrollView release];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 8.0f, 80.0f, 20.0f)];
    label.text = @"房间名称";
    label.textColor = [UIColor grayColor];
    label.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    [self.myScrollView addSubview:label];
    [label release];
    
    UITextField *name = [[UITextField alloc] initWithFrame:CGRectMake(90.0f, 3.0f, 210.0f, 35.0f)];
    name.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    name.backgroundColor = [UIColor whiteColor];
    name.placeholder = @"请输入房间名";
    self.nameTextField = name;
    self.nameTextField.tag = TAG_ALERTVIEW_ChatroomName;
    self.nameTextField.delegate = self;
    [name becomeFirstResponder];
    [self.myScrollView addSubview:name];
    [name release];
    
    UILabel *labelPwd = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 55.0f, 80.0f, 20.0f)];
    labelPwd.text = @"房间密码";
    labelPwd.textColor = [UIColor grayColor];
    labelPwd.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    [self.myScrollView addSubview:labelPwd];
    [labelPwd release];
    
    UITextField *pwd = [[UITextField alloc] initWithFrame:CGRectMake(90.0f, 50.0f, 210.0f, 35.0f)];
    pwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    pwd.backgroundColor = [UIColor whiteColor];
    pwd.placeholder = @"请输入1-8位密码（可选）";
    [pwd setSecureTextEntry:YES];
    pwd.keyboardType = UIKeyboardTypeDefault;
    self.pwdTextField = pwd;
    self.pwdTextField.tag = TAG_ALERTVIEW_ChatroomPwd;
    [pwd becomeFirstResponder];
    self.pwdTextField.delegate = self;
    [self.myScrollView addSubview:pwd];
    [pwd release];
    

    UILabel *labelVoiceMod = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 95.0f, 80.0f, 20.0f)];
    labelVoiceMod.text = @"声音设置";
    labelVoiceMod.textColor = [UIColor grayColor];
    labelVoiceMod.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    [self.myScrollView addSubview:labelVoiceMod];
    [labelVoiceMod release];
    
    NSArray *voiceModArray = [[NSArray alloc]initWithObjects:@"仅有背景音",@"全部提示音",@"无声",nil];
     UISegmentedControl *voiceModSgControl = [[UISegmentedControl alloc]initWithItems:voiceModArray];
    voiceModSgControl.frame = CGRectMake(90.0, 90.0, 220.0, 35.0);
    if (!iOS7)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIFont systemFontOfSize:13],UITextAttributeFont,
                                                 [UIColor whiteColor],UITextAttributeTextColor,
                                                 [UIColor blackColor],UITextAttributeTextShadowColor,
                                                 [NSValue valueWithCGSize:CGSizeMake(1, 1)],UITextAttributeTextShadowOffset,nil];
        [voiceModSgControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    }
    voiceModSgControl.selectedSegmentIndex = 1;//设置默认选择项索引
    voiceModSgControl.segmentedControlStyle = UISegmentedControlStylePlain;
    voiceModSgControl.tag = 1001;
    [self.myScrollView addSubview:voiceModSgControl];
    [voiceModSgControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [voiceModSgControl release];
    [voiceModArray release];
    
    iValue = 35;
#ifdef Chatroom3_6_3_NewFlow
    UILabel *labelAutoDelete = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 135.0f, 80.0f, 20.0f)];
    labelAutoDelete.text = @"房间类型";
    labelAutoDelete.textColor = [UIColor grayColor];
    labelAutoDelete.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    [self.myScrollView addSubview:labelAutoDelete];
    [labelAutoDelete release];
    
    NSArray *autoDeleteSgArray = [[NSArray alloc]initWithObjects:@"自动删除房间",@"不自动删除",nil];
    UISegmentedControl *autoDeleteSgControl = [[UISegmentedControl alloc]initWithItems:autoDeleteSgArray];
    autoDeleteSgControl.frame = CGRectMake(90.0, 130.0, 220.0, 35.0);
    autoDeleteSgControl.selectedSegmentIndex = 0;//设置默认选择项索引
    autoDeleteSgControl.segmentedControlStyle = UISegmentedControlStylePlain;
    autoDeleteSgControl.tag = 1002;
    if (!iOS7)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [UIFont systemFontOfSize:13],UITextAttributeFont,
                             [UIColor whiteColor],UITextAttributeTextColor,
                             [UIColor blackColor],UITextAttributeTextShadowColor,
                             [NSValue valueWithCGSize:CGSizeMake(1, 1)],UITextAttributeTextShadowOffset,nil];
        [autoDeleteSgControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    }
    [self.myScrollView addSubview:autoDeleteSgControl];
    [autoDeleteSgControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [autoDeleteSgControl release];
    [autoDeleteSgArray release];
    iValue = 0;
#endif
    
    UIButton* btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn.frame = CGRectMake(0, 170-iValue, 290, 30);
    UIImage* img = [UIImage imageNamed:@"choose_on.png"];
    btn.tag = 1;
    [btn setImage: img forState:(UIControlStateNormal)];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn setTitle:@"创建人退出时自动解散(单击选择)" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnChooseIsAutoClose:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.myScrollView addSubview:btn];
    
    UIButton* btnIsAutoJoin = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnIsAutoJoin.frame = CGRectMake(0, 205-iValue, 272, 30);
    UIImage* imgIsAutoJoin = [UIImage imageNamed:@"choose_on.png"];
    btnIsAutoJoin.tag = 1;
    [btnIsAutoJoin setImage: imgIsAutoJoin forState:(UIControlStateNormal)];
    btnIsAutoJoin.titleLabel.font = [UIFont systemFontOfSize:17];
    [btnIsAutoJoin setTitle:@"创建后自动加入会议(单击选择)" forState:UIControlStateNormal];
    [btnIsAutoJoin setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnIsAutoJoin addTarget:self action:@selector(btnChooseIsAutoJoin:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.myScrollView addSubview:btnIsAutoJoin];
    
    UIButton *createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    createBtn.frame = CGRectMake(82.0f, 240-iValue, 136.0f, 38.0f);
    createBtn.titleLabel.textColor = [UIColor whiteColor];
    [createBtn setTitle:@"创建" forState:UIControlStateNormal];
    [createBtn setBackgroundImage:[UIImage imageNamed:@"button03_off.png"] forState:UIControlStateNormal];
    [createBtn setBackgroundImage:[UIImage imageNamed:@"button03_on.png"] forState:UIControlStateHighlighted];
    [createBtn addTarget:self action:@selector(createCharRoom:) forControlEvents:UIControlEventTouchUpInside];
    [self.myScrollView addSubview:createBtn];
    iVoiceMod = 1;
    isAutoClose = YES;
    bAutoDelete = YES;
    isAutoJoin = YES;
    square = 30;
}

-(void)segmentAction:(UISegmentedControl *)Seg
{
    switch (Seg.selectedSegmentIndex)
    {
        case 0:
            if(Seg.tag == 1001)
                iVoiceMod = 0;
            else
                bAutoDelete = YES;
            break;
        case 1:
            if(Seg.tag == 1001)
                iVoiceMod = 1;
            else
                bAutoDelete = NO;
            break;
        case 2:
            if(Seg.tag == 1001)
                iVoiceMod = 2;
            break;
        default:
            break;
    }
}

-(void)btnChooseIsAutoJoin:(id)sender
{
    UIButton* btn = sender;
    if (btn.tag == 0)
    {
        btn.tag = 1;
        UIImage* img = [UIImage imageNamed:@"choose_on.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoJoin = YES;
    }
    else
    {
        btn.tag = 0;
        UIImage* img = [UIImage imageNamed:@"choose.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoJoin = NO;
    }
}

-(void)btnChooseIsAutoClose:(id)sender
{
    UIButton* btn = sender;
    if (btn.tag == 0)
    {
        btn.tag = 1;
        UIImage* img = [UIImage imageNamed:@"choose_on.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoClose = YES;
    }
    else
    {
        btn.tag = 0;
        UIImage* img = [UIImage imageNamed:@"choose.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoClose = NO;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length == 1)
    {
        return YES;
    }
    NSMutableString *text = [[textField.text mutableCopy] autorelease];
    [text replaceCharactersInRange:range withString:string];
    if (textField.tag == TAG_ALERTVIEW_ChatroomPwd)
    {
        return [text length] <= 8;
    }
    return [text length] <= 50;
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
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createCharRoom:(id)sender
{
    [nameTextField resignFirstResponder];
    [pwdTextField resignFirstResponder];
    if (nameTextField.text.length > 0 )
    {
        if (isAutoJoin)
        {
            //创建并加入
            ChatRoomViewController *chatroomview = [[ChatRoomViewController alloc] init];
            chatroomview.navigationItem.hidesBackButton = YES;
            chatroomview.curChatroomId = nil;
            chatroomview.roomname = nameTextField.text;
            chatroomview.backView = self.backView;
            chatroomview.isCreator = YES;
            [self.navigationController pushViewController:chatroomview animated:YES];
            [chatroomview createChatroomWithChatroomName:nameTextField.text andPassword:pwdTextField.text andSquare:square andKeywords:@"" inAppId:self.modelEngineVoip.appID andIsAutoClose:isAutoClose andVoiceMod:iVoiceMod andAutoDelete:bAutoDelete andIsAutoJoin:isAutoJoin];
            [chatroomview release];
        }
        else
        {
            [self.modelEngineVoip startChatroomWithName:nameTextField.text andPassword:pwdTextField.text andSquare:square andKeywords:@"" inAppId:self.modelEngineVoip.appID andIsAutoClose:isAutoClose andVoiceMod:iVoiceMod andAutoDelete:bAutoDelete andIsAutoJoin:isAutoJoin];
            [self displayProgressingView];
        }
    }
    else
    {
        [self popPromptViewWithMsg:@"请输入会议名称"];
    }
}
- (void)onChatroomStateWithReason:(CloopenReason *)reason andRoomNo:(NSString *)roomNo
{
    [self dismissProgressingView];
    if (reason.reason == 0)
    {
        [self popToPreView];
    }
    else
    {
        [self popPromptViewWithMsg:@"创建会议失败"];
    }
}
-(void)dealloc
{
    self.nameTextField = nil;
    self.pwdTextField = nil;
    self.myScrollView = nil;
    self.backView = nil;
    [super dealloc];
}
@end
