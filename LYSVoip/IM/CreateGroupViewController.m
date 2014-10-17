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

#import "CreateGroupViewController.h"
#import "UIselectContactsViewController.h"
#import "UISelectCell.h"

@interface CreateGroupViewController ()
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *declardField;
@property (nonatomic, assign) NSInteger groupType;
@property (nonatomic, retain) NSString *permission;
@property (nonatomic, retain) UIButton *groupTypeBtn;
@property (nonatomic, retain) UIButton *permissionTypeBtn;
@end

@implementation CreateGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
    
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)loadView
{
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    self.title = @"建立新群组";
    
    UIBarButtonItem *creatGroup=[[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"创建" target:self action:@selector(creatNewGroup)]];
    self.navigationItem.rightBarButtonItem = creatGroup;
    [creatGroup release];
    
    UIView* selfview = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    selfview.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    self.view = selfview;
    [selfview release];
    
    UIButton *backgroundBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    backgroundBtn.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    [backgroundBtn addTarget:self action:@selector(keyboardHid) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backgroundBtn];
    [backgroundBtn release];
    
    [self createHeadView];
    [self createInputTextField];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.nameField = nil;
    self.declardField = nil;
    self.permission = nil;
    self.groupTypeBtn = nil;
    self.permissionTypeBtn = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.modelEngineVoip.UIDelegate = self;
}
#pragma mark - private method

//创建新群组
- (void)creatNewGroup
{
    [self keyboardHid];
    [self displayProgressingView];
    [self.modelEngineVoip createGroupWithName:self.nameField.text andType:self.groupType andDeclared:self.declardField.text andPermission:self.permission.integerValue];
}

- (void)keyboardHid
{
    [self.nameField resignFirstResponder];
    [self.declardField resignFirstResponder];
}

//创建显示页头
- (void)createHeadView
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 23.0f)];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_bg.png"]];
    [headView addSubview:image];
    [image release];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, 300, 23.0f)];
    [headView addSubview:label];
    label.font = [UIFont systemFontOfSize:13.0f];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"群基本信息";
    label.textColor = [UIColor whiteColor];
    [label release];
    
    [self.view addSubview:headView];
    [headView release];
}

//创建群组属性内容控件
- (void)createInputTextField
{
    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 30.0, 300.0, 30.0)];
    self.nameField = myTextField;
    myTextField.borderStyle = UITextBorderStyleRoundedRect;
    myTextField.placeholder = @"群组名称";
    [self.view addSubview:myTextField];
    [myTextField release];
    
    myTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 65.0, 300.0, 30.0)];
    self.declardField = myTextField;
    myTextField.borderStyle = UITextBorderStyleRoundedRect;
    myTextField.placeholder = @"群公告（选填）";
    [self.view addSubview:myTextField];
    [myTextField release];
    
    
    self.groupType = 0;
    UIButton *typeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.groupTypeBtn = typeBtn;
    typeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [typeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [typeBtn setTitle:@"临时组(上限100人)[点击进行选择]" forState:UIControlStateNormal];
    [typeBtn setBackgroundImage:[[UIImage imageNamed:@"input_box_button_off.png"] stretchableImageWithLeftCapWidth:130.0f topCapHeight:30.0f] forState:UIControlStateNormal];
    [typeBtn setBackgroundImage:[[UIImage imageNamed:@"input_box_button_on.png"] stretchableImageWithLeftCapWidth:130.0f topCapHeight:30.0f] forState:UIControlStateHighlighted];
    typeBtn.tag = 100;
    [typeBtn addTarget:self action:@selector(selectGroupInfo:) forControlEvents:UIControlEventTouchUpInside];
    typeBtn.frame = CGRectMake(10, 100, 300, 30);
    [self.view addSubview:typeBtn];
    
    self.permission = @"0";
    UIButton *permissionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.permissionTypeBtn = permissionBtn;
    [permissionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [permissionBtn setTitle:@"默认直接加入[点击进行选择]" forState:UIControlStateNormal];
    [permissionBtn setBackgroundImage:[[UIImage imageNamed:@"input_box_button_off.png"] stretchableImageWithLeftCapWidth:130.0f topCapHeight:30.0f] forState:UIControlStateNormal];
    [permissionBtn setBackgroundImage:[[UIImage imageNamed:@"input_box_button_on.png"] stretchableImageWithLeftCapWidth:130.0f topCapHeight:30.0f] forState:UIControlStateHighlighted];
    permissionBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    permissionBtn.tag = 101;
    [permissionBtn addTarget:self action:@selector(selectGroupInfo:) forControlEvents:UIControlEventTouchUpInside];
    permissionBtn.frame = CGRectMake(10, 135, 300, 30);
    [self.view addSubview:permissionBtn];
}

//群组属性按钮事件
- (void)selectGroupInfo:(id)sender
{
    [self keyboardHid];
    UIButton *typebtn = (UIButton*)sender;
    UIActionSheet *menu = nil;
    if (typebtn.tag == 100)
    {
        //群组类型
        menu = [[UIActionSheet alloc]
                initWithTitle: @"群组类型"
                delegate:self
                cancelButtonTitle:nil
                destructiveButtonTitle:nil
                otherButtonTitles:nil];
        menu.tag = 100;
        [menu addButtonWithTitle:@"临时组(上限100人)"]; 
        [menu addButtonWithTitle:@"普通组(上限300人)"];
        [menu addButtonWithTitle:@"VIP组(上限500人)"];
        
    }
    else if (typebtn.tag == 101)
    {
        //群组权限
        menu = [[UIActionSheet alloc]
                initWithTitle: @"群组模式"
                delegate:self
                cancelButtonTitle:nil
                destructiveButtonTitle:nil
                otherButtonTitles:nil];
        menu.tag = 101;
        [menu addButtonWithTitle:@"默认直接加入"];
        [menu addButtonWithTitle:@"需要身份验证"];
        [menu addButtonWithTitle:@"私有群组"];
    }
    
    if (menu != nil)
    {
        [menu addButtonWithTitle:@"取消"];
        [menu setCancelButtonIndex:3];
        [menu showInView:self.view.window];
        [menu release];
    }
}

//创建群组成功跳转选择联系人页面
- (void)goToSelectMembersViewWithGroupId:(NSString*)groupId
{
    UIselectContactsViewController* selectView = [[UIselectContactsViewController alloc] initWithAccountList:self.modelEngineVoip.accountArray andSelectType:ESelectViewType_GroupMemberView];
    selectView.backView = self.backView;
    selectView.groupId = groupId;
    [self.navigationController pushViewController:selectView animated:YES];
    [selectView release];
}

#pragma mark - actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == actionSheet.cancelButtonIndex)
    {
        return;
    }
    NSString *selectStr = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (actionSheet.tag == 100)
    {
        //群组类型
        self.groupType = buttonIndex;
        [self.groupTypeBtn setTitle:[NSString stringWithFormat:@"%@[点击进行选择]", selectStr] forState:UIControlStateNormal];
    }
    else if (actionSheet.tag == 101)
    {
        //申请加入模式
        self.permission = [NSString stringWithFormat:@"%d", buttonIndex];
        [self.permissionTypeBtn setTitle:[NSString stringWithFormat:@"%@[点击进行选择]", selectStr] forState:UIControlStateNormal];
    }
}

-(void)onGroupCreateGroupWithReason:(CloopenReason*)reason andGroupId:(NSString *)groupId
{
    [self dismissProgressingView];
    if (reason.reason == 0)
    {
        [self goToSelectMembersViewWithGroupId:groupId];
    }
    else
    {
        [self  popPromptViewWithMsg:@"创建群组失败，请稍后再试！" AndFrame:CGRectMake(0, 160, 320, 30)];
    }
}
@end
