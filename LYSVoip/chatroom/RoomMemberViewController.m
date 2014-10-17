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


#import "RoomMemberViewController.h"
#import "ChatRoomViewController.h"

@interface RoomMemberViewController ()

@end

@implementation RoomMemberViewController

-(id)initWithRoomNo:(NSString*)roomNo Members:(NSArray*) members;
{
    self = [super init];
    if (self)
    {
        chatMemberArray = [[NSMutableArray alloc] initWithArray:members];
        curRoomNo = roomNo;
    }
    return self;
}

- (void)loadView
{
    self.title = @"成员管理";
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 35.0f, 200.0f, 20.0f)];
    label.text = @"可将指定成员踢出房间";
    label.textColor = [UIColor grayColor];
    label.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    [self.view addSubview:label];
    [label release];
    
    
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
    memberTable = tableView;
	[self.view addSubview:tableView];
	[tableView release];
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

- (void)kickOff:(id) sender
{
    UIView *cell = [sender superview];
    while (![cell isKindOfClass:[UITableViewCell class]]) {
        cell = [cell superview];
    };
    NSIndexPath * indexPath = [memberTable indexPathForCell:(UITableViewCell*)cell];
    if (indexPath.row >= [chatMemberArray count])
    {
        return;
    }
    curIndex = indexPath.row;
    ChatroomMember* member = [chatMemberArray objectAtIndex:curIndex];
    [self displayProgressingView];
    [self.modelEngineVoip removeMemberFromChatroomWithAppId:self.modelEngineVoip.appID andRoomNo:curRoomNo andMember:member.number];
}

-(void)reloadTable
{
    [memberTable reloadData];
}

#pragma mark - table DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [chatMemberArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellid = @"chatroom_cellid";
    UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for (UIView *view in cell.contentView.subviews)
    {
        if (view.tag == 2001)
        {
            [view removeFromSuperview];
        }
    }
    ChatroomMember *member = [chatMemberArray objectAtIndex:indexPath.row];
    cell.textLabel.text = member.number;
    
    UIButton* btnKickOff = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnKickOff.frame = CGRectMake(240, 8, 60, 28);
    [btnKickOff setTitle:@"踢出" forState:(UIControlStateNormal)];
    btnKickOff.tag = 2001;
    [btnKickOff addTarget:self action:@selector(kickOff:) forControlEvents:UIControlEventTouchDown];
    [cell.contentView addSubview:btnKickOff];
    return cell;
}

#pragma mark - tabl Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(void)dealloc
{
    [chatMemberArray release];
    [super dealloc];
}


/********************聊天室的方法********************/
//踢出聊天室
- (void)onChatroomRemoveMemberWithReason:(CloopenReason *)reason andMember:(NSString *)member
{
    if (reason.reason == 0)
    {
        [self performSelector:@selector(dismissProgressingView) withObject:self afterDelay:10];
        if (curIndex >= [chatMemberArray count])
        {
            return;
        }
        ChatroomMember * chatMember = [chatMemberArray objectAtIndex:curIndex];
        
        if (chatMember.type.integerValue == 1 && [member isEqualToString:self.modelEngineVoip.voipAccount])//创建人踢出自己
        {
            [self.modelEngineVoip dismissChatroomWithAppId:self.modelEngineVoip.appID andRoomNo:curRoomNo];
            return;
        }
        
        [chatMemberArray removeObjectAtIndex:curIndex];
        [self reloadTable];
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

-(void)onChatroomDismissWithReason:(CloopenReason *)reason andRoomNo:(NSString *)roomNo
{
    [self dismissProgressingView];
    if (reason.reason == 0)
    {
        [self.navigationController popToViewController: [self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
}


//通知客户端收到新的聊天室信息
- (void)onReceiveChatroomMsg:(ChatroomMsg*) receiveMsgInfo
{
    if([receiveMsgInfo isKindOfClass:[ChatroomRemoveMemberMsg class]])
    {
        [self dismissProgressingView];
    }
}

@end

