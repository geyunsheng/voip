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

#import "IMGroupNotifyViewController.h"

#define DEFAULT_CELL_HEIGTH 95.0f

@interface IMGroupNotifyViewController ()
{
    NSInteger btnEventConfirm;
    NSInteger btnEventIndex;
}
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) NSArray *notifyMsgArr;
@end

@implementation IMGroupNotifyViewController

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
    UIView* selfview = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    selfview.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    self.view = selfview;
    [selfview release];
    
    self.title = @"系统消息";
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    UIBarButtonItem *rightBarItem=[[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"清除" target:self action:@selector(clearNotifyMessages)]];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    [rightBarItem release];
    
    UIView* headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, 320, 29);
    UIImageView *imgHeader = [[UIImageView alloc] initWithFrame:headerView.frame];
    imgHeader.image = [UIImage imageNamed:@"point_bg.png"];
    [headerView addSubview:imgHeader];
    [imgHeader release];
    UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 300.0f, 29.0f)] ;
    lbHeader.backgroundColor = [UIColor clearColor];
    lbHeader.font = [UIFont systemFontOfSize:13.0f];
    lbHeader.textColor = [UIColor whiteColor];
    lbHeader.text = @"显示所有收到的系统通知";
    [headerView addSubview:lbHeader];
    [lbHeader release];
    [self.view addSubview:headerView];
    [headerView release];

    
    UITableView* tableView = nil;
    if (IPHONE5)
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 29, 320, 578.f-64.0f-29.0f) style:UITableViewStylePlain];
    }
    else
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 29.0f, 320, 416.0f-29.0f) style:UITableViewStylePlain];
    }
    
    self.table = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    tableView.tableFooterView = [[[UIView alloc] init] autorelease];
    [self.view addSubview:tableView];
    [tableView release];
}

- (void)dealloc
{
    self.notifyMsgArr = nil;
    self.table = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.modelEngineVoip.UIDelegate = self;
    [self.modelEngineVoip.imDBAccess updateUnreadGroupNotice];
    self.notifyMsgArr = [self.modelEngineVoip.imDBAccess getAllGroupNotices];
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

#pragma mark - private methods
//清除数据库中系统消息
- (void)clearNotifyMessages
{
    [self.modelEngineVoip.imDBAccess deleteAllGroupNotice];
    [self reloadTableView];
}

- (void)reloadTableView
{
    self.notifyMsgArr = [self.modelEngineVoip.imDBAccess getAllGroupNotices];
    [self.modelEngineVoip.imDBAccess updateUnreadGroupNotice];
    [self.table reloadData];
}

- (void)inviteOrJoinYesBtnEvent:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    [self confirmJoinOrInviteGroupId:btn.tag-2000 andConfirm:0];
}

- (void)inviteOrJoinNoBtnEvent:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    [self confirmJoinOrInviteGroupId:btn.tag-2000 andConfirm:1];
}

- (void)confirmJoinOrInviteGroupId:(NSInteger)index andConfirm:(NSInteger)confirm
{
    btnEventConfirm = confirm;
    btnEventIndex = index;
    IMGroupNotice *msg = [self.notifyMsgArr objectAtIndex:btnEventIndex];
    [self displayProgressingView];
    if (msg.msgType == EGroupNoticeType_InviteJoin)
    {
        //邀请加入的验证
        [self.modelEngineVoip inviteGroupWithGroupId:msg.groupId andConfirm:btnEventConfirm];
    }
    else if(msg.msgType == EGroupNoticeType_ApplyJoin)
    {
        //申请加入的验证
        [self.modelEngineVoip askJoinWithGroupId:msg.groupId andAsker:msg.who andConfirm:btnEventConfirm];
    }
    else
    {
        [self dismissProgressingView];
    }
}

- (void)updateIMDatabase
{
    IMGroupNotice *msg = [self.notifyMsgArr objectAtIndex:btnEventIndex];
    if (btnEventConfirm == 0)
    {
        //通过
        [self.modelEngineVoip.imDBAccess updateGroupNoticeState:EGroupNoticeOperation_Access OfGroupId:msg.groupId andPushMsgType:msg.msgType andWho:msg.who];
    }
    else
    {
        //拒绝
        [self.modelEngineVoip.imDBAccess updateGroupNoticeState:EGroupNoticeOperation_Reject OfGroupId:msg.groupId andPushMsgType:msg.msgType andWho:msg.who];
    }
    [self reloadTableView];
}

#pragma mark - UIDelegate
- (void)onMemberInviteGroupWithReason:(CloopenReason*)reason
{
    [self dismissProgressingView];
    if (reason.reason == 0)
    {
        [self updateIMDatabase];
    }
    else
    {
        [self popPromptViewWithMsg:[NSString stringWithFormat:@"错误码：%d,错误详情：%@",reason.reason,reason.msg]];
    }
}

//管理员验证用户申请加入群组
- (void) onMemberAskJoinWithReason: (CloopenReason*) reason
{
    [self dismissProgressingView];
    if (reason.reason == 0)
    {
        [self updateIMDatabase];
    }
    else
    {
        [self popPromptViewWithMsg:[NSString stringWithFormat:@"错误码：%d,错误详情：%@",reason.reason,reason.msg]];
    }
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DEFAULT_CELL_HEIGTH;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notifyMsgArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *dateLabel = nil;
    UILabel *voipLabel = nil;
    UILabel *declaredLabel = nil;
    UILabel *groupIdLabel = nil;
    UILabel *typeLabel = nil;
    
    static NSString* cellid = @"im_notify_message_cell_id";
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        CGFloat margin_X = 10.0f;
        CGFloat margin_Top = 5.0f;
        CGFloat label_Y = 10.0f;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(margin_X, label_Y, 150.0f, 15.0f)];
        label.font = [UIFont systemFontOfSize:11.0f];
        label.tag = 1000;
        label.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        label.textColor = [UIColor grayColor];
        typeLabel = label;
        [cell.contentView addSubview:label];
        [label release];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(150, label_Y, 150, 15)];
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:11.0f];
        label.textColor = [UIColor grayColor];
        label.tag = 1001;
        label.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        dateLabel = label;
        [cell.contentView addSubview:label];
        [label release];
        
        
        label_Y = label.frame.size.height+label.frame.origin.y + margin_Top;
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_icon02.png"]];
        image.frame = CGRectMake(margin_X, label_Y, 32.0f, 32.0f);
        [cell.contentView addSubview:image];
        [image release];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(margin_X+40.0f, label_Y, 160.0f, 15)];
        label.font = [UIFont systemFontOfSize:13.0f];
        label.tag = 1002;
        voipLabel = label;
        label.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        [cell.contentView addSubview:label];
        [label release];
        
        label_Y = label.frame.size.height+label.frame.origin.y + margin_Top;
        label = [[UILabel alloc] initWithFrame:CGRectMake(margin_X+40.0f, label_Y, 160.0f, 15)];
        label.font = [UIFont systemFontOfSize:13.0f];
        label.tag = 1003;
        declaredLabel = label;
        label.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        [cell.contentView addSubview:label];
        [label release];
        
        label_Y = label.frame.size.height+label.frame.origin.y + margin_Top;
        label = [[UILabel alloc] initWithFrame:CGRectMake(margin_X, label_Y, 300.0f, 15)];
        label.font = [UIFont systemFontOfSize:11.0f];
        label.tag = 1004;
        label.textColor = [UIColor grayColor];
        groupIdLabel = label;
        label.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        [cell.contentView addSubview:label];
        [label release];
        
        UIImageView *lineImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice_mail_line.png"]];
        lineImg.frame = CGRectMake(0.0f, DEFAULT_CELL_HEIGTH-1.0f, 320.0f, 1.0f);
        [cell.contentView addSubview:lineImg];
        [lineImg release];
    }
    else
    {
        typeLabel = (UILabel *)[cell viewWithTag:1000];
        dateLabel = (UILabel *)[cell viewWithTag:1001];
        voipLabel = (UILabel *)[cell viewWithTag:1002];
        declaredLabel = (UILabel *)[cell viewWithTag:1003];
        groupIdLabel = (UILabel *)[cell viewWithTag:1004];
    }
    
    IMGroupNotice *msg = [self.notifyMsgArr objectAtIndex:indexPath.row];
    for (UIView *view in cell.contentView.subviews)
    {
        if (view.tag >= 2000)
        {
            [view removeFromSuperview];
        }
    }
    
    //0 申请加入   1 回复加入  2邀请加入  3移除成员 4退出 5解散 6有人加入
    if (msg.msgType == EGroupNoticeType_ApplyJoin || msg.msgType == EGroupNoticeType_InviteJoin)
    {
        if (msg.state == EGroupNoticeOperation_NeedAuth)
        {
            UIButton* yesBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [yesBtn setTitle:@"同意" forState:UIControlStateNormal];
            yesBtn.frame = CGRectMake(210.0f, dateLabel.frame.origin.y+dateLabel.frame.size.height+5.0f, 100.0f, 20.0f);
            yesBtn.tag = 2000+indexPath.row;
            [yesBtn addTarget:self action:@selector(inviteOrJoinYesBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:yesBtn];
            
            UIButton* noBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [noBtn setTitle:@"拒绝" forState:UIControlStateNormal];
            noBtn.frame = CGRectMake(210.0f, yesBtn.frame.origin.y+yesBtn.frame.size.height+5.0f, 100.0f, 20.0f);
            noBtn.tag = 2000+indexPath.row;
            [noBtn addTarget:self action:@selector(inviteOrJoinNoBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:noBtn];
        }
        else if (msg.state==EGroupNoticeOperation_UnneedAuth)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(210.0f, dateLabel.frame.origin.y+dateLabel.frame.size.height+5.0f, 100.0f, 40.0f)];
            label.textColor = [UIColor grayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            label.text = @"已在群组";
            label.tag = 2000;
            [cell.contentView addSubview:label];
            [label release];
        }
        else if (msg.state == EGroupNoticeOperation_Access)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(210.0f, dateLabel.frame.origin.y+dateLabel.frame.size.height+5.0f, 100.0f, 40.0f)];
            label.textColor = [UIColor grayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            label.text = @"已通过";
            label.tag = 2000;
            [cell.contentView addSubview:label];
            [label release];
        }
        else if (msg.state == EGroupNoticeOperation_Reject)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(210.0f, dateLabel.frame.origin.y+dateLabel.frame.size.height+5.0f, 100.0f, 40.0f)];
            label.textColor = [UIColor grayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            label.text = @"已拒绝";
            label.tag = 2000;
            [cell.contentView addSubview:label];
            [label release];
        }
    }

    NSString *typeStr = nil;
    switch (msg.msgType)
    {
        case EGroupNoticeType_ApplyJoin:
            typeStr = @"有人申请加入群组";
            break;
        case EGroupNoticeType_ReplyJoin:
            typeStr = @"加入群组答复消息";
            break;
        case EGroupNoticeType_InviteJoin:
            typeStr = @"被邀请加入群组消息";
            break;
        case EGroupNoticeType_RemoveMember:
            typeStr = @"被移除群组消息";
            break;
        case EGroupNoticeType_QuitGroup:
            typeStr = @"退出群组消息";
            break;
        case EGroupNoticeType_DismissGroup:
            typeStr = @"群组解散消息";
            break;
        case EGroupNoticeType_JoinedGroup:
            typeStr = @"有人加入消息";
            break;
        default:
            typeStr = @"群组消息";
            break;
    }
    typeLabel.text = typeStr;
    dateLabel.text = msg.curDate;
    voipLabel.text = msg.who;
    declaredLabel.text = msg.verifyMsg;
    groupIdLabel.text = [NSString stringWithFormat:@"群组:%@",msg.groupId];
    
    return cell;
}

-(void)responseIMGroupNotice:(NSString*)groupId data:(NSString *)data
{
    NSLog(@"responseIMGroupNotice:groupid=%@,data=%@",groupId,data);
    [self reloadTableView];
}
@end
