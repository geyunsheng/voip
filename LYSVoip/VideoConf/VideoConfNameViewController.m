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

#import "VideoConfNameViewController.h"
#import "VideoConfViewController.h"

@interface VideoConfNameViewController ()
{
    NSInteger iVoiceMod;
    BOOL bAutoDelete;
}
@property (nonatomic,retain)UITextField *nameTextField;
@end

@implementation VideoConfNameViewController

@synthesize backView;
@synthesize myScrollView;
@synthesize nameTextField;
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
    isAutoClose = YES;
    iVoiceMod = 0;
    bAutoDelete = YES;
    isAutoJoin = YES;
    self.title = @"创建视频会议房间";
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    
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
    [self.view addSubview:ivBg];
    [ivBg release];

    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    int iHeight = 240;
    int iValue = 360;
    if (IPHONE5)
    {
        iValue  = 320;
        iHeight = 280;
    }
    
#ifdef Chatroom3_6_3_NewFlow
    iHeight = 240;
    iValue = 360;
    if (IPHONE5)
    {
        iValue  = 320;
        iHeight = 280;
    }
#endif
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, iHeight)];
    scrollView.contentSize = CGSizeMake(320, iValue);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.scrollsToTop = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview :scrollView];
    self.myScrollView = scrollView;
    self.myScrollView.delegate = self;
    [scrollView release];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(11.0f, 5.0f, 200.0f, 18.0f)];
    label.text = @"房间名称:";
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [self.myScrollView addSubview:label];
    [label release];
    
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoConfPortrait.png"]];
    imageview.center = CGPointMake(33.0f, 52.0f);
    [self.myScrollView addSubview:imageview];
    [imageview release];
    
    UITextField *name = [[UITextField alloc] initWithFrame:CGRectMake(55.0f, 30.0f, 320.0f-66.0f, 44.0f)];
    name.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    name.keyboardAppearance = UIKeyboardAppearanceAlert;
    name.background = [UIImage imageNamed:@"videoConfInput.png"];
    name.delegate = self;
    name.textColor = [UIColor whiteColor];
    name.placeholder = @"请输入房间名称";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        [name setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.nameTextField = name;
    name.textColor = [UIColor whiteColor];
    [name becomeFirstResponder];
    [self.myScrollView addSubview:name];
    [name release];
    
    UILabel *labelVoiceMod = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 85.0f, 80.0f, 20.0f)];
    labelVoiceMod.text = @"声音设置";
    labelVoiceMod.textColor = [UIColor whiteColor];
    labelVoiceMod.backgroundColor = [UIColor clearColor];
    [self.myScrollView addSubview:labelVoiceMod];
    [labelVoiceMod release];
    
    NSArray *voiceModArray = [[NSArray alloc]initWithObjects:@"仅有背景音",@"全部提示音",@"无声",nil];
    UISegmentedControl *voiceModSgControl = [[UISegmentedControl alloc]initWithItems:voiceModArray];
    if (!iOS7)
    {
         NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [UIFont systemFontOfSize:13],UITextAttributeFont,
                             [UIColor whiteColor],UITextAttributeTextColor,
                             [UIColor blackColor],UITextAttributeTextShadowColor,
                             [NSValue valueWithCGSize:CGSizeMake(1, 1)],UITextAttributeTextShadowOffset,nil];
        [voiceModSgControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    }
    voiceModSgControl.frame = CGRectMake(90.0, 80, 220.0, 35.0);
    voiceModSgControl.selectedSegmentIndex = 0;//设置默认选择项索引
    voiceModSgControl.segmentedControlStyle = UISegmentedControlStylePlain;
    voiceModSgControl.tintColor = [UIColor whiteColor];
    voiceModSgControl.tag = 1001;
    [self.myScrollView addSubview:voiceModSgControl];
    [voiceModSgControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [voiceModSgControl release];
    [voiceModArray release];

    iValue = -30;
#ifdef Chatroom3_6_3_NewFlow
    iValue = 10;
    UILabel *labelAutoDelete = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 115.0f+iValue, 80.0f, 20.0f)];
    labelAutoDelete.text = @"房间类型";
    labelAutoDelete.textColor = [UIColor whiteColor];
    labelAutoDelete.backgroundColor = [UIColor clearColor];
    [self.myScrollView addSubview:labelAutoDelete];
    [labelAutoDelete release];
    
    NSArray *autoDeleteSgArray = [[NSArray alloc]initWithObjects:@"自动删除房间",@"不自动删除",nil];
    UISegmentedControl *autoDeleteSgControl = [[UISegmentedControl alloc]initWithItems:autoDeleteSgArray];
    if (!iOS7)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [UIFont systemFontOfSize:13],UITextAttributeFont,
                             [UIColor whiteColor],UITextAttributeTextColor,
                             [UIColor blackColor],UITextAttributeTextShadowColor,
                             [NSValue valueWithCGSize:CGSizeMake(1, 1)],UITextAttributeTextShadowOffset,nil];
        [autoDeleteSgControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    }
    autoDeleteSgControl.frame = CGRectMake(90.0, 110.0+iValue, 220.0, 35.0);
    autoDeleteSgControl.selectedSegmentIndex = 0;//设置默认选择项索引
    autoDeleteSgControl.segmentedControlStyle = UISegmentedControlStylePlain;
    autoDeleteSgControl.tintColor = [UIColor whiteColor];
    autoDeleteSgControl.tag = 1002;
    [self.myScrollView addSubview:autoDeleteSgControl];
    [autoDeleteSgControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [autoDeleteSgControl release];
    [autoDeleteSgArray release];
#endif
    
    
    UIButton* btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn.frame = CGRectMake(0, 150+iValue, 294, 30);
    UIImage* img = [UIImage imageNamed:@"choose_on.png"];
    btn.tag = 1;
    [btn setImage: img forState:(UIControlStateNormal)];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn setTitle:@"创建人退出时自动解散(单击选择)" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnChooseIsAutoClose:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.myScrollView addSubview:btn];
    
    UIButton* btnIsAutoJoin = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnIsAutoJoin.frame = CGRectMake(0, 150+iValue+35, 276, 30);
    UIImage* imgIsAutoJoin = [UIImage imageNamed:@"choose_on.png"];
    btnIsAutoJoin.tag = 1;
    [btnIsAutoJoin setImage: imgIsAutoJoin forState:(UIControlStateNormal)];
    btnIsAutoJoin.titleLabel.font = [UIFont systemFontOfSize:17];
    [btnIsAutoJoin setTitle:@"创建后自动加入会议(单击选择)" forState:UIControlStateNormal];
    [btnIsAutoJoin setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnIsAutoJoin addTarget:self action:@selector(btnChooseIsAutoJoin:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.myScrollView addSubview:btnIsAutoJoin];
    
    UIButton *createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    createBtn.frame = CGRectMake(11.0f, 185.0f+iValue+35, 298.0f, 44.0f);
    [createBtn setImage:[UIImage imageNamed:@"videoConfCreate2.png"] forState:UIControlStateNormal];
    [createBtn setImage:[UIImage imageNamed:@"videoConfCreate2_on.png"] forState:UIControlStateHighlighted];
    [createBtn addTarget:self action:@selector(createVideoConference:) forControlEvents:UIControlEventTouchUpInside];
    [self.myScrollView addSubview:createBtn];
    
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

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.background = [UIImage imageNamed:@"videoConfInput_on.png"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.background = [UIImage imageNamed:@"videoConfInput.png"];
}

#pragma mark - private method
- (void)createVideoConference:(id)sender
{
    [nameTextField resignFirstResponder];
    if (nameTextField.text.length > 0 )
    {
        if (isAutoJoin)
        {
            VideoConfViewController *VideoConfview = [[VideoConfViewController alloc] init];
            VideoConfview.navigationItem.hidesBackButton = YES;
            VideoConfview.curVideoConfId = nil;
            VideoConfview.Confname = nameTextField.text;
            VideoConfview.backView = self.backView;
            VideoConfview.isCreator = YES;
            [self.navigationController pushViewController:VideoConfview animated:YES];
            [VideoConfview createConfWithAutoClose:isAutoClose andiVoiceMod:iVoiceMod andAutoDelete:bAutoDelete andIsAutoJoin:isAutoJoin];
            [VideoConfview release];
        }
        else
        {
            [self.modelEngineVoip startVideoConferenceInAppId:self.modelEngineVoip.appID withName:nameTextField.text andSquare:5 andKeywords:@"" andPassword:@"" andIsAutoClose:isAutoClose andVoiceMod:iVoiceMod andAutoDelete:bAutoDelete andIsAutoJoin:isAutoJoin];
        }
    }
    else
    {
        [self popPromptViewWithMsg:@"请输入会议名称"];
    }
}

- (void)onVideoConferenceStateWithReason:(CloopenReason *) reason andConferenceId:(NSString*)conferenceId
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
    self.myScrollView = nil;
    self.backView = nil;
    [super dealloc];
}

@end
