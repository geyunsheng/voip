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
#import "VideoConfListViewController.h"
#import "VideoConfNameViewController.h"
#import "VideoConfViewController.h"
#import "HighlightDelegateCell.h"
@interface VideoConfListViewController ()
{
    UITableView *ConfListView;
    NSMutableArray *VideoConfsArray;
    UIView * noneView;
}
@end

@implementation VideoConfListViewController

@synthesize backView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)goBack
{
    //[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToViewController:self.backView animated:YES];
}

- (void)loadView
{
    self.title = @"视频会议列表";
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
    
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(goBack)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithNormalImageNamed:@"videoConfAdd.png" andHighlightedImageNamed:@"videoConfAdd_on.png" target:self action:@selector(startCharConf:)]];
    self.navigationItem.rightBarButtonItem = right;
    [right release];
    
    UIImageView *pointImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_new_tips.png"]];
    pointImg.frame = CGRectMake(0.0f, 0.0f, 320.0f, 22.0f);
    [self.view addSubview:pointImg];
    [pointImg release];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.0f, 0.0f, 320.0f, 22.0f)];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont systemFontOfSize:13.0f];
    statusLabel.text = @"点击即可加入视频会议";
    statusLabel.contentMode = UIViewContentModeCenter;
    [self.view addSubview:statusLabel];
    [statusLabel release];
    
    VideoConfsArray = self.modelEngineVoip.videoconferenceListArray;
    
    UIView *noneDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 22.0f, 320.0f, self.view.frame.size.height-44.0f-22.0f)];
    
    UIImageView *noneDatabackview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoConfBg_1136.png"]];
    [noneDataView addSubview:noneDatabackview];
    [noneDatabackview release];
    
    noneView = noneDataView;
    [self.view addSubview:noneDataView];
    
    UIImageView *iconimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoConf32.png"]];
    iconimage.center = CGPointMake(74.0f, 164.0f);
    [noneDataView addSubview:iconimage];
    [iconimage release];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(96.0f, 152.0f, 175.0f, 25.0f)];
    text.text = @"暂无房间，请先创建一个";
    text.font = [UIFont systemFontOfSize:15.0f];
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
    [noneDataView addSubview:text];
    [text release];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake(11.0f, noneDataView.frame.size.height-44.0f-11.0f, 298.0f, 44.0f);
    [startBtn setImage:[UIImage imageNamed:@"videoConfCreate.png"] forState:UIControlStateNormal];
    [startBtn setImage:[UIImage imageNamed:@"videoConfCreate_on.png"] forState:UIControlStateHighlighted];
    [startBtn addTarget:self action:@selector(startCharConf:) forControlEvents:UIControlEventTouchUpInside];
    [noneDataView addSubview:startBtn];
    
    [self.view addSubview:noneDataView];
    [noneDataView release];
    
    UITableView *tableView = nil;
    if (IPHONE5)
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(11.0f, 33.0f, 2980.0f, 548.0f-33.0f)
                                                 style:UITableViewStylePlain];;
    }
    else
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(11.0f, 33.0f, 298.0f, 460.0f-33.0f)
                                                 style:UITableViewStylePlain];
    }
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
	tableView.delegate = self;
	tableView.dataSource = self;
    tableView.tableFooterView = [[[UIView alloc] init] autorelease];
    ConfListView = tableView;
	[self.view addSubview:tableView];
	[tableView release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.modelEngineVoip setUIDelegate:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //获取会议列表
    [self.modelEngineVoip queryVideoConferencesOfAppId :self.modelEngineVoip.appID withKeywords:@""];
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
    if (VideoConfsArray.count > 0)
    {
        ConfListView.alpha = 1.0f;
        noneView.alpha = 0.0f;
    }
    else
    {
        ConfListView.alpha = 0.0f;
        noneView.alpha = 1.0f;
    }
    [ConfListView reloadData];
}

#pragma mark - table DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [VideoConfsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *nameLabel = nil;
    UILabel *infoLabel = nil;
    UIImageView *backimage = nil;
    UIImageView *accessimage = nil;
    
    static NSString* cellid = @"VideoConf_cellid";
    UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil)
    {
        cell = [[[HighlightDelegateCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        CGRect cellframe = cell.frame;
        cellframe.size.width -= 22.0f;
        cell.frame = cellframe;
        
        UIImageView *cellbackview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoConf51.png"]];
        [cell.contentView addSubview:cellbackview];
        backimage = cellbackview;
        cellbackview.tag = 1003;
        [cellbackview release];
        
        UILabel *Label1 = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 0.0f, cell.frame.size.width-66.0f, 24.0f)];
        Label1.backgroundColor = [UIColor clearColor];
        Label1.font = [UIFont systemFontOfSize:17.0f];
        Label1.tag = 1001;
        nameLabel = Label1;
        nameLabel.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:Label1];
        [Label1 release];
        
        UILabel *Label2 = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 24.0f, cell.frame.size.width-66.0f, 15.0f)];
        Label2.backgroundColor = [UIColor clearColor];
        Label2.font = [UIFont systemFontOfSize:14.0f];
        Label2.textColor = [UIColor colorWithRed:136.0f/255.0f green:136.0f/255.0f blue:136.0f/255.0f alpha:1.0f];
        Label2.tag = 1002;
        infoLabel = Label2;
        [cell.contentView addSubview:Label2];
        [Label2 release];
        
        UIImageView *accessImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewConfAccessIcon.png"]];
        accessImage.center = CGPointMake(cell.frame.size.width-22.0f, 22.0f);
        [cell.contentView addSubview:accessImage];
        accessimage = accessImage;
        accessImage.tag = 1004;
        [accessImage release];
    }
    else
    {
        nameLabel = (UILabel*)[cell viewWithTag:1001];
        infoLabel = (UILabel*)[cell viewWithTag:1002];
        accessimage = (UIImageView*)[cell viewWithTag:1004];
        backimage = (UIImageView*)[cell viewWithTag:1003];
    }
    
    backimage.image = [UIImage imageNamed:@"videoConf51.png"];
    accessimage.image = [UIImage imageNamed:@"viewConfAccessIcon.png"];
    
    VideoConference *ConfInfo = [VideoConfsArray objectAtIndex:indexPath.row];
    
    NSString *name = nil;
    if (ConfInfo.conferenceName.length>0)
    {
        name = ConfInfo.conferenceName;
    }
    else
    {
        name = [NSString stringWithFormat:@"%@的会议", (ConfInfo.conferenceId.length>4?[ConfInfo.conferenceId substringFromIndex:(ConfInfo.conferenceId.length-4)]:ConfInfo.conferenceId)];
    }
    nameLabel.text = name;
    
    NSString *info = nil;
    if (ConfInfo.square == ConfInfo.joinNum)
    {
        info = [NSString stringWithFormat:@"%d人加入(已满)", ConfInfo.joinNum];
    }
    else
    {
        info = [NSString stringWithFormat:@"%d人加入", ConfInfo.joinNum];
    }
    
    NSUInteger fromIndex = ConfInfo.creator.length>4?(ConfInfo.creator.length-4):0;
    infoLabel.text = [NSString stringWithFormat:@"%@,由%@创建", info, [ConfInfo.creator substringFromIndex:fromIndex]];
    
    return cell;
}

#pragma mark - tabl Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoConference *selectConf = [VideoConfsArray objectAtIndex:indexPath.row];
    if(selectConf.conferenceId.length > 0  && selectConf.square > selectConf.joinNum)
    {
        NSString *name = nil;
        BOOL iscreator = NO;
        self.curRoomNo = nil;
        self.curRoomName = nil;
        for (VideoConference *conf in VideoConfsArray)
        {
            if ([conf.conferenceId isEqualToString:selectConf.conferenceId])
            {
                self.curRoomName = [NSString stringWithFormat:@"%@",name];
                if ([conf.creator isEqualToString:self.modelEngineVoip.voipAccount])
                {
                    iscreator = YES;
                }
                break;
            }
        }
        if (iscreator)
        {
            self.curRoomName = [NSString stringWithFormat:@"%@",name];
            self.curRoomNo = [NSString stringWithFormat:@"%@",selectConf.conferenceId];
            UIActionSheet *menu = [[UIActionSheet alloc]
                    initWithTitle: @"选择"
                    delegate:self
                    cancelButtonTitle:nil
                    destructiveButtonTitle:nil
                    otherButtonTitles:@"加入会议",@"解散会议",@"取消",nil];
            [menu setCancelButtonIndex:2];
            menu.tag = 1000;
            [menu showInView:self.view.window];
            [menu release];
        }
        else
        {
            [self joinConfWithRoomNo:selectConf.conferenceId andRoomname:name andCreator:iscreator];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)joinConfWithRoomNo:(NSString*)roomNo andRoomname:(NSString*)roomname andCreator:(BOOL)creator
{
    VideoConfViewController *VideoConfview = [[VideoConfViewController alloc] init];
    VideoConfview.navigationItem.hidesBackButton = YES;
    VideoConfview.curVideoConfId = roomNo;
    VideoConfview.Confname = roomname;
    VideoConfview.backView = self;
    VideoConfview.isCreator = creator;
    [self.navigationController pushViewController:VideoConfview animated:YES];
    [VideoConfview joinInVideoConf];
    [VideoConfview release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1000)
    {
        switch (buttonIndex)
        {
            case 0:
                [self joinConfWithRoomNo:self.curRoomNo andRoomname:self.curRoomName andCreator:YES];
                break;
            case 1:
                [self displayProgressingView];
                [self.modelEngineVoip dismissVideoConferenceWithAppId:self.modelEngineVoip.appID andVideoConference:self.curRoomNo];
                break;
            default:
                break;
        }
    }
}

-(void)onVideoConferenceDismissWithReason:(CloopenReason *)reason andConferenceId:(NSString *)conferenceId
{
    [self dismissProgressingView];
    if (reason.reason == 0 ||reason.reason == 101020 || reason.reason == 111805)
    {
        [self.modelEngineVoip queryVideoConferencesOfAppId :self.modelEngineVoip.appID withKeywords:@""];
        [self viewRefresh];
    }
    else if (reason.reason == 111806)
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

#pragma mark - VideoConf method
- (void)startCharConf:(id)sender
{
    VideoConfNameViewController* ConfNameView = [[VideoConfNameViewController alloc] init];
    ConfNameView.backView = self;
    [self.navigationController pushViewController:ConfNameView animated:YES];
    [ConfNameView release];
}

/********************会议的方法********************/

- (void)onVideoConferencesWithReason:(CloopenReason *) reason andConferences:(NSArray*)conferences
{
    [self dismissProgressingView];
    [self viewRefresh];
}

//通知客户端收到新的会议信息
- (void)onReceiveVideoConferenceMsg:(VideoConferenceMsg*) msg;
{
    [self dismissProgressingView];
    if([msg isKindOfClass:[VideoConferenceMsg class]])
    {
        [self.modelEngineVoip queryVideoConferencesOfAppId:self.modelEngineVoip.appID withKeywords:@""];
        [self viewRefresh];
    }
}
- (void) dealloc
{
    self.backView = nil;
    [super dealloc];
}
@end
