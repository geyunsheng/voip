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

#import "GroupListViewController.h"
#import "CreateGroupViewController.h"
#import "GroupInfoViewController.h"
#import "SendIMViewController.h"

#define TAG_TABLEVIEW_MYJOINGROUP   300
#define TAG_TABLEVIEW_PUBLICGROUP   301

@interface GroupListViewController ()
@property (nonatomic, retain) UIImageView *titleImgView;
@property (nonatomic, retain) NSArray *myJoinGroupArr;
@property (nonatomic, retain) NSArray *publicGroupArr;
@end

@implementation GroupListViewController

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
    
    //self.title = @"群组";
    
    UIBarButtonItem *creatGroup=[[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"新建" target:self action:@selector(creatNewGroup)]];
    self.navigationItem.rightBarButtonItem = creatGroup;
    [creatGroup release];
    
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 145.0f, 44.0f)];
    
    UIImageView *titleImg = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 8.0f, 145.0f, 28.0f)];
    self.titleImgView = titleImg;
    titleImg.image = [UIImage imageNamed:@"title_button_01.png"];
    [titleView addSubview:titleImg];
    [titleImg release];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0.0f, 8.0f, 72.0f, 28.0f);
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [leftBtn addTarget:self action:@selector(displayMyJoinGroups:) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setTitle:@"我加入的群" forState:UIControlStateNormal];
    
    [titleView addSubview:leftBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    rightBtn.frame = CGRectMake(73.0f, 8.0f, 72.0f, 28);
    [rightBtn addTarget:self action:@selector(displayPublicGroups:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"公共群组" forState:UIControlStateNormal];
    [titleView addSubview:rightBtn];
    
    self.navigationItem.titleView = titleView;
    [titleView release];
    
    UIView* selfview = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    selfview.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    self.view = selfview;
    [selfview release];
    
    [self createTableViewWithTag:TAG_TABLEVIEW_MYJOINGROUP];

    [self createTableViewWithTag:TAG_TABLEVIEW_PUBLICGROUP];
    
    UIView* tmpview = [self.view viewWithTag:TAG_TABLEVIEW_MYJOINGROUP];
    [self.view bringSubviewToFront:tmpview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.titleImgView = nil;
    self.myJoinGroupArr = nil;
    self.publicGroupArr = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.modelEngineVoip.UIDelegate = self;
    [self.modelEngineVoip queryGroupWithAsker:self.modelEngineVoip.voipAccount];
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%lld", (long long)tmp];//转为字符型
    [self.modelEngineVoip queryPublicGroupsWithLastUpdateTime:timeString];
}

#pragma mark - private method
- (void)creatNewGroup
{
    CreateGroupViewController *view = [[CreateGroupViewController alloc] init];
    view.backView = self;
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)displayMyJoinGroups:(id)sender
{
    self.titleImgView.image = [UIImage imageNamed:@"title_button_01.png"];
    UIView* tmpview = [self.view viewWithTag:TAG_TABLEVIEW_MYJOINGROUP];
    [self.view bringSubviewToFront:tmpview];
}

- (void)displayPublicGroups:(id)sender
{
    self.titleImgView.image = [UIImage imageNamed:@"title_button_02.png"];
    UIView* tmpview = [self.view viewWithTag:TAG_TABLEVIEW_PUBLICGROUP];
    [self.view bringSubviewToFront:tmpview];
}

- (BOOL)isMyJoinGroupWithGroup:(IMGroupInfo*)group
{
    BOOL isMyJoinGroup = NO;
    for (IMGroupInfo *joinGroup in self.myJoinGroupArr)
    {
        if ([group.groupId isEqualToString:joinGroup.groupId])
        {
            isMyJoinGroup = YES;
        }
    }
    return isMyJoinGroup;
}

- (void)goToGroupInfoViewWithGroupId:(IMGroupInfo*)group
{
    BOOL isMyJoinGroup = NO;    
    isMyJoinGroup = [self isMyJoinGroupWithGroup:group];
    GroupInfoViewController *view = [[GroupInfoViewController alloc] initWithGroupId:group.groupId andIsMyJoin:isMyJoinGroup andPermission:group.permission];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

- (void)goToSendIMViewWithGroupId:(NSString*)groupid
{
    SendIMViewController *imdetailView = [[SendIMViewController alloc] initWithReceiver:groupid];
    imdetailView.backView = self;
    [self.navigationController pushViewController:imdetailView animated:YES];
    [imdetailView release];
}

- (void)createTableViewWithTag:(NSInteger) tag
{
    UIView* view = [self.view viewWithTag:tag];
    if (view == nil)
    {
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
        tableView.tag = tag;
        [self.view addSubview:tableView];
        [tableView release];
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == TAG_TABLEVIEW_MYJOINGROUP)
    {
        UIView *headView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 23.0f)] autorelease];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_bg.png"]];
        [headView addSubview:image];
        [image release];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, 300, 23.0f)];
        [headView addSubview:label];
        label.font = [UIFont systemFontOfSize:13.0f];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"我加入的群组";
        label.textColor = [UIColor whiteColor];
        [label release];
        
        return headView;
    }
    else if (tableView.tag == TAG_TABLEVIEW_PUBLICGROUP)
    {
        UIView *headView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 23.0f)] autorelease];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_bg.png"]];
        [headView addSubview:image];
        [image release];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, 300, 23.0f)];
        [headView addSubview:label];
        label.font = [UIFont systemFontOfSize:13.0f];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"群组列表";
        label.textColor = [UIColor whiteColor];
        [label release];
        
        return headView;
    }
    
    return [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)] autorelease];;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == TAG_TABLEVIEW_MYJOINGROUP)
    {
        IMGroupInfo *group = [self.myJoinGroupArr objectAtIndex:indexPath.row];
        [self goToSendIMViewWithGroupId:group.groupId];
    }
    else if(tableView.tag == TAG_TABLEVIEW_PUBLICGROUP)
    {
        IMGroupInfo *group = [self.publicGroupArr objectAtIndex:indexPath.row];
        if ([self isMyJoinGroupWithGroup:group]) {
            [self goToSendIMViewWithGroupId:group.groupId];
        }
        else
            [self goToGroupInfoViewWithGroupId:group];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (tableView.tag == TAG_TABLEVIEW_MYJOINGROUP)
    {
        count = self.myJoinGroupArr.count;
    }
    else if(tableView.tag == TAG_TABLEVIEW_PUBLICGROUP)
    {
        count = self.publicGroupArr.count;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellid = @"GroupCell_cellid";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    
    UILabel *nameLabel = nil;
    UILabel *countLabel = nil;
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
        [cell.contentView addSubview:image];
        [image release];
        
        UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(56.0f, 12.0f, 150.0f, 20.0f)];
        idLabel.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        idLabel.font = [UIFont systemFontOfSize:17.0f];
        idLabel.tag = 1001;
        nameLabel = idLabel;
        [cell.contentView addSubview:idLabel];
        [idLabel release];
        
        UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(240.0f, 14.0f, 80.0f, 14.0f)];
        tmpLabel.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        tmpLabel.font = [UIFont systemFontOfSize:13.0f];
        tmpLabel.tag = 1002;
        countLabel = tmpLabel;
        [cell.contentView addSubview:tmpLabel];
        [tmpLabel release];
        
        countLabel.textAlignment = NSTextAlignmentCenter;
        
        UIImageView *lineImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice_mail_line.png"]];
        lineImg.frame = CGRectMake(0.0f, 43.0f, 320.0f, 1.0f);
        [cell.contentView addSubview:lineImg];
        [lineImg release];
    }
    else
    {
        nameLabel = (UILabel*)[cell viewWithTag:1001];
        countLabel = (UILabel*)[cell viewWithTag:1002];
    }
    
    if (tableView.tag == TAG_TABLEVIEW_MYJOINGROUP)
    {
        IMGroupInfo * group = [self.myJoinGroupArr objectAtIndex:indexPath.row];
        nameLabel.text = group.name;
        countLabel.text = [NSString stringWithFormat:@"%d人" ,group.count];
    }
    else if(tableView.tag ==  TAG_TABLEVIEW_PUBLICGROUP)
    {
        for (UIView *view in cell.contentView.subviews)
        {
            if (view.tag == 1003)
                [view removeFromSuperview];
        }
        IMGroupInfo * group = [self.publicGroupArr objectAtIndex:indexPath.row];
        nameLabel.text = group.name;
        int top = 16;
        if (group.permission == 1)
        {
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock_closed.png"]];
            image.tag = 1003;
            image.frame = CGRectMake(268.f, 5.f,24.0f, 24.0f);
            [cell.contentView addSubview:image];
            [image release];
            top = 30;
        }
        
        countLabel.frame = CGRectMake(240.0f, top, 80.0f, 14.0f);
        if ([self isMyJoinGroupWithGroup:group])
        {
            countLabel.text = [NSString stringWithFormat:@"%d人  已加入" ,group.count];
        }
        else
            countLabel.text = [NSString stringWithFormat:@"%d人" ,group.count];
    }

    return cell;
}


-(void)onGroupQueryPublicGroupsWithReason:(CloopenReason*)reason andGroups:(NSArray *)groups
{
    if (reason.reason == 0)
    {
        [self.modelEngineVoip.imDBAccess insertOrUpdateGroupInfos:groups];
        self.publicGroupArr = groups;
        UITableView* tmpview = (UITableView*)[self.view viewWithTag:TAG_TABLEVIEW_PUBLICGROUP];
        [tmpview reloadData];
    }
    else
    {
        [self popPromptViewWithMsg:[NSString stringWithFormat:@"错误码：%d,错误详情：%@",reason.reason,reason.msg]];
    }
}

-(void)onMemberQueryGroupWithReason:(CloopenReason*)reason andGroups:(NSArray *)groups
{
    if (reason.reason == 0)
    {
        [self.modelEngineVoip.imDBAccess insertOrUpdateGroupInfos:groups];
        self.myJoinGroupArr = groups;
        UITableView* tmpview = (UITableView*)[self.view viewWithTag:TAG_TABLEVIEW_MYJOINGROUP];
        [tmpview reloadData];
    }
    else
    {
        [self popPromptViewWithMsg:[NSString stringWithFormat:@"错误码：%d,错误详情：%@",reason.reason,reason.msg]];
    }
}

- (void)responseMessageStatus:(EMessageStatusResult)event callNumber:(NSString *)callNumber data:(NSString *)data
{
    switch (event)
	{
        case EMessageStatus_Received:
        {            
            [self.modelEngineVoip queryGroupWithAsker:self.modelEngineVoip.voipAccount];
            NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
            NSString *timeString = [NSString stringWithFormat:@"%lld", (long long)tmp];//转为字符型
            [self.modelEngineVoip queryPublicGroupsWithLastUpdateTime:timeString];
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

@end
