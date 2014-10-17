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
#import "RoomListViewController.h"
#import "RoomNameViewController.h"
#import "ChatRoomViewController.h"
#import "RoomMemberViewController.h"

#define TAG_ALERTVIEW_ChatroomPwd 9999
@interface RoomListViewController ()
{
    UITableView *roomListView;
    NSMutableArray *chatroomsArray;
    UIView * noneView;
}
@end

@implementation RoomListViewController

@synthesize myTextField,curSelectRoom;

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
    self.title = @"语音群聊列表";
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"创建房间" target:self action:@selector(startCharRoom:)]];
    self.navigationItem.rightBarButtonItem = right;
    [right release];
    
    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"point_bg.png"]];
    pointImg.frame = CGRectMake(0.0f, 0.0f, 320.0f, 29.0f);
    [self.view addSubview:pointImg];
    [pointImg release];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:pointImg.frame];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont systemFontOfSize:13.0f];
    statusLabel.text = @"点击即可加入语音群聊";
    statusLabel.contentMode = UIViewContentModeCenter;
    statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:statusLabel];
    [statusLabel release];
    
    chatroomsArray = self.modelEngineVoip.chatroomListArray;
    
    UIView *noneDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 29.0f, 320.0f, 480.0f)];
    noneDataView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    noneView = noneDataView;
    [self.view addSubview:noneDataView];
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 30.0f, 320.0f, 25.0f)];
    text.text = @"还没有群聊房间，请先创建一个";
    text.font = [UIFont systemFontOfSize:15.0f];
    text.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    text.textAlignment = NSTextAlignmentCenter;
    text.textColor = [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f];
    [noneDataView addSubview:text];
    [text release];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake(82.0f, 70.0f, 136.0f, 38.0f);
    startBtn.titleLabel.textColor = [UIColor whiteColor];
    [startBtn setTitle:@"创建语音房间" forState:UIControlStateNormal];
    [startBtn setBackgroundImage:[UIImage imageNamed:@"button03_off.png"] forState:UIControlStateNormal];
    [startBtn setBackgroundImage:[UIImage imageNamed:@"button03_on.png"] forState:UIControlStateHighlighted];
    [startBtn addTarget:self action:@selector(startCharRoom:) forControlEvents:UIControlEventTouchUpInside];
    [noneDataView addSubview:startBtn];
    
    [self.view addSubview:noneDataView];
    [noneDataView release];
    
    UITableView *tableView = nil;
    if (IPHONE5)
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 29.0f, 320.0f, 548.0f-29.0f)
                                                 style:UITableViewStylePlain];;
    }
    else
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 29.0f, 320.0f, 460.0f-29.0f)
                                                 style:UITableViewStylePlain];
    }
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
	tableView.delegate = self;
	tableView.dataSource = self;
    tableView.tableFooterView = [[[UIView alloc] init] autorelease];
    roomListView = tableView;
	[self.view addSubview:tableView];
	[tableView release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.modelEngineVoip setUIDelegate:self];
    
    //获取聊天室列表
    [self.modelEngineVoip queryChatroomsOfAppId:self.modelEngineVoip.appID withKeywords:@""];
    [self viewRefresh];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewRefresh
{
    if (chatroomsArray.count > 0)
    {
        roomListView.alpha = 1.0f;
        noneView.alpha = 0.0f;
    }
    else
    {
        roomListView.alpha = 0.0f;
        noneView.alpha = 1.0f;
    }
    [roomListView reloadData];
}

#pragma mark - table DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [chatroomsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *nameLabel = nil;
    UILabel *infoLabel = nil;
    UIImageView *lock_closedImage = nil;
    Chatroom *roomInfo = [chatroomsArray objectAtIndex:indexPath.row];
    static NSString* cellid = @"chatroom_cellid";
    UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid] autorelease];
        cell.contentView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        UILabel *Label1 = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 0.0f, 320.0f-88.0f, 24.0f)];
        Label1.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        Label1.font = [UIFont systemFontOfSize:17.0f];
        Label1.tag = 1001;
        nameLabel = Label1;
        [cell.contentView addSubview:Label1];
        [Label1 release];
        
        UILabel *Label2 = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 24.0f, 320.0f-88.0f, 15.0f)];
        Label2.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        Label2.font = [UIFont systemFontOfSize:14.0f];
        Label2.textColor = [UIColor grayColor];
        Label2.tag = 1002;
        infoLabel = Label2;
        [cell.contentView addSubview:Label2];
        [Label2 release];
        
        
        lock_closedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock_closed.png"]];
        lock_closedImage.center = CGPointMake(320.0f-44.0f, 20.0f);
        lock_closedImage.tag = 1003;
        [cell.contentView addSubview:lock_closedImage];
        [lock_closedImage release];
        
        UIImageView *accessImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon02.png"]];
        accessImage.center = CGPointMake(320.0f-22.0f, 22.0f);
        [cell.contentView addSubview:accessImage];
        [accessImage release];
    }
    else
    {
        nameLabel = (UILabel*)[cell viewWithTag:1001];
        infoLabel = (UILabel*)[cell viewWithTag:1002];
        lock_closedImage = (UIImageView*)[cell viewWithTag:1003];
    }
    
    
    NSString *name = nil;
    if (roomInfo.roomName.length>0)
    {
        name = roomInfo.roomName;
    }
    else
    {
        name = [NSString stringWithFormat:@"%@房间", (roomInfo.roomNo.length>4?[roomInfo.roomNo substringFromIndex:(roomInfo.roomNo.length-4)]:roomInfo.roomNo)];
    }
    nameLabel.text = name;
    
    NSString *info = nil;
    if (roomInfo.square == roomInfo.joinNum)
    {
        info = [NSString stringWithFormat:@"%d人加入(已满)", roomInfo.joinNum];
    }
    else
    {
        info = [NSString stringWithFormat:@"%d人加入", roomInfo.joinNum];
    }
    
    NSUInteger fromIndex = roomInfo.creator.length>4?(roomInfo.creator.length-4):0;
    infoLabel.text = [NSString stringWithFormat:@"%@,由%@创建", info, [roomInfo.creator substringFromIndex:fromIndex]];
    
    if (roomInfo.validate == 1)
    {
        lock_closedImage.hidden = NO;
    }
    else
        lock_closedImage.hidden = YES;
    return cell;
}

#pragma mark - tabl Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Chatroom *selectRoom = [chatroomsArray objectAtIndex:indexPath.row];
    self.curSelectRoom = selectRoom;
    if(selectRoom.roomNo.length > 0  && selectRoom.square > selectRoom.joinNum)
    {
        BOOL iscreator = NO;
        if ([selectRoom.creator isEqualToString:self.modelEngineVoip.voipAccount])
        {
            iscreator = YES;
        }
        if (iscreator)
        {            
            UIActionSheet *menu = [[UIActionSheet alloc]
                                   initWithTitle: @"选择"
                                   delegate:self
                                   cancelButtonTitle:nil
                                   destructiveButtonTitle:nil
                                   otherButtonTitles:@"加入会议",@"解散会议",@"成员管理",@"取消",nil];
            [menu setCancelButtonIndex:3];
            menu.tag = 1000;
            [menu showInView:self.view.window];
            [menu release];
        }
        else
        {
            if (selectRoom.validate == 1)
            {
                [self showIpuntPassWord];
            }
            else
            {
                [self joinChatroomInRoomWithSelectRoom:selectRoom andPwd:nil];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showIpuntPassWord
{
    CustomeAlertView *customeAlertView = [[CustomeAlertView alloc]init];
    customeAlertView.delegate = self;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 15.0f, 180.0f, 35.0f)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    titleLabel.text = @"该聊天室设置了身份验证, 请输入密码";
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    [customeAlertView.myView addSubview:titleLabel];
    [titleLabel release];
    
    self.myTextField = [[[UITextField alloc] initWithFrame:CGRectMake(20.0, 65.0, 220.0, 25.0)] autorelease];
    self.myTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.myTextField.tag = TAG_ALERTVIEW_ChatroomPwd;
    [self.myTextField setBackgroundColor:[UIColor whiteColor]];
    self.myTextField.delegate = self;
    self.myTextField.keyboardType = UIKeyboardTypeDefault;
    self.myTextField.placeholder = @"请输入密码";
    [self.myTextField setSecureTextEntry:YES];
    
    [customeAlertView.myView addSubview:self.myTextField];
    
    CGRect frame = customeAlertView.myView.frame;
    frame.origin.y -= 60;
    frame.size.height -= 40;
    [customeAlertView setViewFrame:frame];
    
    [customeAlertView show];
    [self.myTextField becomeFirstResponder];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1000)
    {
        switch (buttonIndex)
        {
            case 0:
                if (self.curSelectRoom.validate == 1)
                {
                    [self showIpuntPassWord];
                }
                else
                {
                    [self joinChatroomInRoomWithSelectRoom:self.curSelectRoom andPwd:nil];
                }
                break;
            case 1:
                [self displayProgressingView];
                [self.modelEngineVoip dismissChatroomWithAppId:self.modelEngineVoip.appID andRoomNo:self.curSelectRoom.roomNo];
                break;
            case 2:
            {
                [self displayProgressingView];
                [self.modelEngineVoip queryMembersWithChatroom:self.curSelectRoom.roomNo];
            }
                break;
            default:
                break;
        }
    }
}

//获取聊天室的成员
- (void)onChatroomMembersWithReason:(CloopenReason *) reason andData:(NSArray*)members
{
    [self dismissProgressingView];
    if (reason.reason == 0)
    {
        [self goMangerRoomMembersWithArray:members];
    }
    else
    {
        NSString *msg = [NSString stringWithFormat:@"错误码:%d\r\n错误详情:%@", reason.reason, reason.msg.length>0?reason.msg:@"未知"];
       [self popPromptViewWithMsg:msg];
    }
}


-(void)goMangerRoomMembersWithArray:(NSArray*) members
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:members];
    for (ChatroomMember* member in array)
    {
        if ([member.number isEqualToString:self.modelEngineVoip.voipAccount])//把自己过滤出来
        {
            [array removeObject:member];
            break;
        }
    }
    if ([array count] > 0)
    {
        RoomMemberViewController* view = [[RoomMemberViewController alloc] initWithRoomNo:self.curSelectRoom.roomNo Members:array];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    else
    {
        [self popPromptViewWithMsg:@"没有可以管理的成员！"];
    }
}
-(void)onChatroomDismissWithReason:(CloopenReason *)reason andRoomNo:(NSString *)roomNo
{
     [self dismissProgressingView];
    if (reason.reason == 0 || reason.reason == 101020 || reason.reason == 110183)
    {
        [self.modelEngineVoip queryChatroomsOfAppId:self.modelEngineVoip.appID withKeywords:@""];
        [self viewRefresh];
    }
    else if (reason.reason == 110095)
    {
        [self popPromptViewWithMsg:@"解散会议失败，权限验证失败，只有创建者才能解散"];
    }
    else if (reason.reason == 170005)
    {
        [self popPromptViewWithMsg:@"网络连接错误，解散会议失败，请稍后再试..."];
    }
    else
    {
        [self popPromptViewWithMsg:@"解散会议失败，请稍后再试..."];
    }
}

-(void)joinChatroomInRoomWithSelectRoom:(Chatroom*) selectRoom andPwd:(NSString*) pwd
{
    [self.myTextField resignFirstResponder];
    BOOL iscreator = NO;
    if ([selectRoom.creator isEqualToString:self.modelEngineVoip.voipAccount])
    {
        iscreator = YES;
    }
    
    ChatRoomViewController *chatroomview = [[ChatRoomViewController alloc] init];
    chatroomview.navigationItem.hidesBackButton = YES;
    chatroomview.roomname = selectRoom.roomName;
    chatroomview.backView = self;
    chatroomview.isCreator = iscreator;
    [self.navigationController pushViewController:chatroomview animated:YES];
    [chatroomview joinChatroomInRoom:selectRoom.roomNo andPwd:pwd];
    [chatroomview release];
}
#pragma mark - chatroom method
- (void)startCharRoom:(id)sender
{
    RoomNameViewController* roomNameView = [[RoomNameViewController alloc] init];
    roomNameView.backView = self;
    [self.navigationController pushViewController:roomNameView animated:YES];
    [roomNameView release];
}

- (void)onChatroomsInAppWithReason:(CloopenReason *) reason andRooms:(NSArray*)chatrooms
{
    [self viewRefresh];
}

#pragma mark - CustomeAlertViewDelegate

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
        if ([self.myTextField.text length] > 0)
        {
            [self joinChatroomInRoomWithSelectRoom:self.curSelectRoom andPwd:self.myTextField.text];
        }
    }
    [alertView release];
    
    NSLog(@"CustomeAlertViewDismiss");
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length == 1)
    {
        return YES;
    }
    NSMutableString *text = [[self.myTextField.text mutableCopy] autorelease];
    [text replaceCharactersInRange:range withString:string];
    if (textField.tag == TAG_ALERTVIEW_ChatroomPwd)
    {
        return [text length] <= 8;
    }
    return [text length] <= 30;
}

//通知客户端收到新的聊天室信息
- (void)onReceiveChatroomMsg:(ChatroomMsg*) receiveMsgInfo
{
    if([receiveMsgInfo isKindOfClass:[ChatroomMsg class]])
    {
        [self.modelEngineVoip queryChatroomsOfAppId:self.modelEngineVoip.appID withKeywords:@""];
        [self viewRefresh];
    }
}


-(void)dealloc
{
    self.curSelectRoom = nil;
    self.myTextField = nil;
    [super dealloc];
}
@end
