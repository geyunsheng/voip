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

#import "IMListViewController.h"
#import "UIselectContactsViewController.h"
#import "SendIMViewController.h"
#import "IMMsgDBAccess.h"
#import "GroupListViewController.h"
#import "IMGroupNotifyViewController.h"

@interface IMListViewController ()
@property (nonatomic, retain) NSArray *msgArr;
@property (nonatomic, retain) UIView *noneMsgView;
@property (nonatomic, retain) UITableView *table;
@end

@implementation IMListViewController

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
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    self.title = @"IM即时消息";
    
    UIBarButtonItem *clearMessage=[[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"清除会话" target:self action:@selector(clearMessage)]];
    self.navigationItem.rightBarButtonItem = clearMessage;
    [clearMessage release];
    
    UIView* selfview = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    selfview.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    self.view = selfview;
    [selfview release];
   
    UITableView *tableView = nil;
    if (IPHONE5)
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 578.f-20.f)
                                                 style:UITableViewStylePlain];;
    }
    else
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 460.0f)
                                                 style:UITableViewStylePlain];
    }
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.delegate = self;
	tableView.dataSource = self;
    tableView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    tableView.tableFooterView = [[[UIView alloc] init] autorelease];
    self.table = tableView;
	[self.view addSubview:tableView];
	[tableView release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.modelEngineVoip.UIDelegate = self;
    
    self.msgArr = [self.modelEngineVoip.imDBAccess getIMListArray];
    [self.modelEngineVoip downloadPreIMMsg];
    [self.table reloadData];
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

- (void)dealloc
{
    self.msgArr = nil;
    self.noneMsgView = nil;
    self.table = nil;
    [super dealloc];
}

#pragma mark - private method

//返回值0 P2P；1 group
-(NSInteger)sessionTypeOfSomeone:(NSString*)someone
{
    NSInteger type = 0;
    
    NSString *g = [someone substringToIndex:1];
    if ([g isEqualToString:@"g"])
    {
        type = 1;
    }
    return type;
}

- (UIView*)getNoneMsgView
{
    if (self.noneMsgView == nil)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 150.0f)];
        self.noneMsgView = view;
        view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 80.0f, 300.0f, 25.0f)];
        label.text = @"暂无消息";
        [view addSubview:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        [label release];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 115.0f, 300.0f, 15.0f)];
        label1.text = @"可通过联系人或群组开始聊天";
        [view addSubview:label1];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.textColor = [UIColor grayColor];
        label1.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        [label1 release];
        
        [view release];
    }
    return self.noneMsgView;
}

- (void)goToSelectContact
{
    UIselectContactsViewController* view = [[UIselectContactsViewController alloc] initWithAccountList:self.modelEngineVoip.accountArray andSelectType:ESelectViewType_IMMsgView];
    view.backView = self;
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)goToGroupView
{
    GroupListViewController *view = [[GroupListViewController alloc] init];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)clearMessage
{
    [self displayProgressingView];
    NSArray* arr = [self.modelEngineVoip.imDBAccess getAllFilePath];
    [self.modelEngineVoip deleteFileWithPathArr:arr];
    [self.modelEngineVoip.imDBAccess deleteAllIMMsg];
    self.msgArr = [self.modelEngineVoip.imDBAccess getIMListArray];
    [self dismissProgressingView];
    [self.table reloadData];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1 && indexPath.row==0 && self.msgArr.count==0)
    {
        return 160.0f;
    }
    return 44.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0.0f;
    }
    return 23.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0)
    {
        UIView *headView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 23.0f)] autorelease];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_bg.png"]];
        [headView addSubview:image];
        [image release];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, 300, 23.0f)];
        [headView addSubview:label];
        label.font = [UIFont systemFontOfSize:13.0f];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"消息列表";
        label.textColor = [UIColor whiteColor];
        [label release];
        
        return headView;
    }
    return [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)] autorelease];;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            [self goToSelectContact];
        }
        else
        {
            [self goToGroupView];
        }
    }
    else
    {
        if (self.msgArr.count > 0 )
        {
            IMConversation *msg = [self.msgArr objectAtIndex:indexPath.row];
            if (msg.type == EConverType_Notice)
            {
                IMGroupNotifyViewController *view = [[IMGroupNotifyViewController alloc] init];
                [self.navigationController pushViewController:view animated:YES];
                [view release];
            }
            else
            {
                // 进入IM即时消息界面
                SendIMViewController *imdetailView = [[SendIMViewController alloc] initWithReceiver:msg.contact];
                imdetailView.backView = self;
                [self.navigationController pushViewController:imdetailView animated:YES];
                [imdetailView release];
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else
    {
        return self.msgArr.count==0?1:self.msgArr.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
    
    if (indexPath.section == 0)
    {
        static NSString* cellid = @"imlist_section_0_cell";
        cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        
        UILabel *countLabel = nil;
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
            cell.contentView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;

            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_icon01.png"]];
            image.center = CGPointMake(28.0f, 22.0f);
            
            if (indexPath.row == 1)
            {
                image.image = [UIImage imageNamed:@"list_icon02.png"];
            }
            
            [cell.contentView addSubview:image];
            [image release];
            
            UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(56.0f, 12.0f, 320.0f-88.0f, 20.0f)];
            idLabel.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            idLabel.font = [UIFont systemFontOfSize:17.0f];
            idLabel.tag = 1001;
            countLabel = idLabel;
            [cell.contentView addSubview:idLabel];
            [idLabel release];
            
            UIImageView *accessImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon02.png"]];
            accessImage.center = CGPointMake(320.0f-22.0f, 22.0f);
            [cell.contentView addSubview:accessImage];
            [accessImage release];
            
            UIImageView *lineImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice_mail_line.png"]];
            lineImg.frame = CGRectMake(0.0f, 43.0f, 320.0f, 1.0f);
            [cell.contentView addSubview:lineImg];
            [lineImg release];
        }
        else
        {
            countLabel = (UILabel*)[cell viewWithTag:1001];
        }
        
        if (indexPath.row == 0)
        {
            countLabel.text = [NSString stringWithFormat:@"联系人(%d)", self.modelEngineVoip.accountArray.count];
        }
        else
        {
            countLabel.text = @"群组";
        }
    }
    else if(self.msgArr.count == 0 )
    {
        static NSString* cellid = @"imlist_section_1_none_cell";
        cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
            cell.contentView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:[self getNoneMsgView]];
        }
    }
    else
    {
        IMConversation *msg = [self.msgArr objectAtIndex:indexPath.row];
        static NSString* cellid = @"imlist_section_1_cell";
        cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        
        UILabel *nameLabel = nil;
        UILabel *msgLabel = nil;
        UILabel *timeLabel = nil;
        UILabel *unreadLabel = nil;
        UIImageView *porImage = nil;
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
            cell.contentView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_icon02.png"]];
            image.center = CGPointMake(28.0f, 22.0f);
            porImage = image;
            image.tag = 1000;
            [cell.contentView addSubview:image];
            [image release];
            
            UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(56.0f, 7.0f, 320.0f-88.0f, 17.0f)];
            idLabel.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            idLabel.font = [UIFont systemFontOfSize:15.0f];
            idLabel.tag = 1001;
            nameLabel = idLabel;
            [cell.contentView addSubview:idLabel];
            [idLabel release];
            
            UILabel *msgLabeltmp = [[UILabel alloc] initWithFrame:CGRectMake(56.0f, 26.0f, 200.0f, 13.0f)];
            msgLabeltmp.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            msgLabeltmp.font = [UIFont systemFontOfSize:12.0f];
            msgLabel.textColor = [UIColor grayColor];
            msgLabeltmp.tag = 1002;
            msgLabel = msgLabeltmp;
            [cell.contentView addSubview:msgLabeltmp];
            [msgLabeltmp release];
            
            UILabel *ttLabel = [[UILabel alloc] initWithFrame:CGRectMake(200.0f, 10.0f, 110.0f, 13.0f)];
            ttLabel.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            ttLabel.font = [UIFont systemFontOfSize:11.0f];
            ttLabel.textColor = [UIColor grayColor];
            ttLabel.tag = 1003;
            ttLabel.textAlignment = NSTextAlignmentRight;
            timeLabel = ttLabel;
            [cell.contentView addSubview:ttLabel];
            [ttLabel release];
            
            UILabel *ucLabel = [[UILabel alloc] initWithFrame:CGRectMake(280.0f, 25.0f, 21.0f, 15.0f)];
            ucLabel.backgroundColor = [UIColor redColor];
            ucLabel.font = [UIFont systemFontOfSize:11.0f];
            ucLabel.textColor = [UIColor whiteColor];
            ucLabel.tag = 1004;
            ucLabel.textAlignment = NSTextAlignmentRight;
            unreadLabel = ucLabel;
            [cell.contentView addSubview:ucLabel];
            [ucLabel release];
            
            UIImageView *lineImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice_mail_line.png"]];
            lineImg.frame = CGRectMake(0.0f, 43.0f, 320.0f, 1.0f);
            [cell.contentView addSubview:lineImg];
            [lineImg release];
        }
        else
        {
            porImage = (UIImageView*)[cell viewWithTag:1000];
            nameLabel = (UILabel*)[cell viewWithTag:1001];
            msgLabel = (UILabel*)[cell viewWithTag:1002];
            timeLabel = (UILabel*)[cell viewWithTag:1003];
            unreadLabel = (UILabel*)[cell viewWithTag:1004];
        }
        
        msgLabel.text = msg.content;
        int count = 0;
        if (msg.type == EConverType_Notice)
        {
            porImage.image = [UIImage imageNamed:@"system_messages_icon.png"];
            nameLabel.text = @"系统通知消息";
            msgLabel.text = msg.content;
            count = [self.modelEngineVoip.imDBAccess getUnreadCountOfGroupNotice];
        }
        else
        {
            NSInteger type = [self sessionTypeOfSomeone:msg.contact];
            if(type == 1)
            {
                //群组类型
                porImage.image = [UIImage imageNamed:@"list_icon02.png"];
                NSString *name = [self.modelEngineVoip.imDBAccess queryNameOfGroupId:msg.contact];
                nameLabel.text = name.length>0?name:msg.contact;
            }
            else
            {
                //点对点类型
                porImage.image = [UIImage imageNamed:@"list_icon03.png"];
                nameLabel.text = msg.contact;
             //   NSLog(@"%@",msg.contact);
            }
            count = [self.modelEngineVoip.imDBAccess getUnreadCountOfSessionId:msg.contact];
        }
        
        timeLabel.text = msg.date;
        if (count == 0)
        {
            unreadLabel.text = @"";
            unreadLabel.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        }
        else
        {
            unreadLabel.backgroundColor = [UIColor redColor];
            unreadLabel.text = [NSString stringWithFormat:@"%d", count];
        }
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

#pragma mark - UIDelegate
- (void)responseMessageStatus:(EMessageStatusResult)event callNumber:(NSString *)callNumber data:(NSString *)data
{
    switch (event)
	{
        case EMessageStatus_Received:
        {
            self.msgArr = [self.modelEngineVoip.imDBAccess getIMListArray];
            [self.table reloadData];
        }
            break;
        case EMessageStatus_Send:
        {
            
        }
            break;
        case EMessageStatus_SendFailed:
        {
            
        }
            break;
        default:
            break;
    }
}

-(void)responseDownLoadMediaMessageStatus:(CloopenReason *)event
{
    switch (event.reason)
	{
        case 0:
        {
            self.msgArr = [self.modelEngineVoip.imDBAccess getIMListArray];
            [self.table reloadData];
        }
            break;
        default:
            break;
    }
}

-(void)responseIMGroupNotice:(NSString*)groupId data:(NSString *)data
{
    NSLog(@"responseIMGroupNotice:groupid=%@,data=%@",groupId,data);
    self.msgArr = [self.modelEngineVoip.imDBAccess getIMListArray];
    [self.table reloadData];
}
@end
