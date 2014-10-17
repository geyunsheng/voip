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

#import "InterphoneViewController.h"
#import "IntercomingViewController.h"
#import "UIselectContactsViewController.h"
#import <AudioToolbox/AudioToolbox.h>
@interface InterphoneViewController ()
{
    UIButton *joinInterphoneBtn;
    UITableView *interphoneListView;
    NSMutableArray *interphoneIdArray;
    UIView * noneView;
}
@end

@implementation InterphoneViewController
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
    self.title = @"对讲列表";
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"发起对讲" target:self action:@selector(startInterphone:)]];
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
    statusLabel.text = @"点击即可加入实时对讲";
    statusLabel.contentMode = UIViewContentModeCenter;
    statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:statusLabel];
    [statusLabel release];
    
    interphoneIdArray = self.modelEngineVoip.interphoneArray;
    
    UIView *noneDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 29.0f, 320.0f, 480.0f)];
    noneDataView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    noneView = noneDataView;
    [self.view addSubview:noneDataView];
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 30.0f, 320.0f, 25.0f)];
    text.text = @"没有收到对讲邀请，可以主动发起";
    text.font = [UIFont systemFontOfSize:15.0f];
    text.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    text.textAlignment = NSTextAlignmentCenter;
    text.textColor = [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f];
    [noneDataView addSubview:text];
    [text release];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake(82.0f, 70.0f, 136.0f, 38.0f);
    startBtn.titleLabel.textColor = [UIColor whiteColor];
    [startBtn setTitle:@"发起实时对讲" forState:UIControlStateNormal];
    [startBtn setBackgroundImage:[UIImage imageNamed:@"button03_off.png"] forState:UIControlStateNormal];
    [startBtn setBackgroundImage:[UIImage imageNamed:@"button03_on.png"] forState:UIControlStateHighlighted];
    [startBtn addTarget:self action:@selector(startInterphone:) forControlEvents:UIControlEventTouchUpInside];
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
    interphoneListView = tableView;
	[self.view addSubview:tableView];
	[tableView release];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.modelEngineVoip setUIDelegate:self];
    [self viewRefresh];
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

-(void) dealloc
{
    [super dealloc];
}

- (void)viewRefresh
{
    if (interphoneIdArray.count > 0)
    {
        interphoneListView.alpha = 1.0f;
        noneView.alpha = 0.0f;
    }
    else
    {
        interphoneListView.alpha = 0.0f;
        noneView.alpha = 1.0f;
    }
    [interphoneListView reloadData];
}

#pragma mark - table DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [interphoneIdArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *interphoneLabel = nil;
    
    static NSString* cellid = @"interphonemember_cellid";
    UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.contentView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon01.png"]];
        image.center = CGPointMake(22.0f, 22.0f);
        [cell.contentView addSubview:image];
        [image release];
        
        UILabel *voipLabel = [[UILabel alloc] initWithFrame:CGRectMake(44.0f, 0.0f, 320.0f-88.0f, 44.0f)];
        voipLabel.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        voipLabel.font = [UIFont systemFontOfSize:17.0f];
        voipLabel.tag = 1001;
        interphoneLabel = voipLabel;
        [cell.contentView addSubview:voipLabel];
        [voipLabel release];
        
        UIImageView *accessImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon02.png"]];
        accessImage.center = CGPointMake(320.0f-22.0f, 22.0f);
        [cell.contentView addSubview:accessImage];
        [accessImage release];
    }
    else
    {
        interphoneLabel = (UILabel*)[cell viewWithTag:1001];
    }
    
    NSString *interphoneid = [interphoneIdArray objectAtIndex:indexPath.row];
    interphoneLabel.text = interphoneid;
    return cell;
}

#pragma mark - tabl Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectId = [interphoneIdArray objectAtIndex:indexPath.row];
    if(selectId.length > 0)
    {
        if (self.modelEngineVoip.curInterphoneId.length>0)
        {
            //当前正在一个对讲中
            if ([self.modelEngineVoip.curInterphoneId isEqualToString:selectId])
            {
                //选择的是当前所在的对讲
                IntercomingViewController *intercoming = [[IntercomingViewController alloc] init];
                intercoming.navigationItem.hidesBackButton = YES;
                intercoming.curInterphoneId = selectId;
                intercoming.backView = self;
                [self.navigationController pushViewController:intercoming animated:YES];
                [intercoming release];
            }
            else
            {
                //选择的不是当前所在的对讲，需要先退出当前的对讲 再加入另一个对讲中
                [self.modelEngineVoip exitInterphone];
                [self.modelEngineVoip joinInterphoneToConfNo:selectId];
                [self displayProgressingView];
            }

        }
        else
        {
            //当前对讲状态空闲
            [self.modelEngineVoip joinInterphoneToConfNo:selectId];
            [self displayProgressingView];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - interphone method
- (void)startInterphone:(id)sender
{
    if (self.modelEngineVoip.curInterphoneId.length>0)
    {
        //当前正在一个对讲中,需要先退出才可创建
        [self.modelEngineVoip exitInterphone];
    }
    
    UIselectContactsViewController* selectView = [[UIselectContactsViewController alloc] initWithAccountList:self.modelEngineVoip.accountArray andSelectType:ESelectViewType_InterphoneView];
    selectView.backView = self;
    [self.navigationController pushViewController:selectView animated:YES];
    [selectView release];
}

/********************实时语音的方法********************/

//通知客户端收到新的实时语音信息        
- (void)onReceiveInterphoneMsg:(InterphoneMsg*) receiveMsgInfo
{
    if ([receiveMsgInfo isKindOfClass:[InterphoneInviteMsg class]])
    {
        [self viewRefresh];
    }
    else if([receiveMsgInfo isKindOfClass:[InterphoneOverMsg class]])
    {
        [self viewRefresh];
    }
}

//对讲场景状态
- (void)onInterphoneStateWithReason:(CloopenReason *)reason andConfNo:(NSString*)confNo
{
    [self dismissProgressingView];
    if (reason.reason == 0 && confNo.length > 0)
    {
        IntercomingViewController *intercoming = [[IntercomingViewController alloc] init];
        intercoming.navigationItem.hidesBackButton = YES;
        intercoming.curInterphoneId = confNo;
        intercoming.backView = self;
        [self.navigationController pushViewController:intercoming animated:YES];
        [intercoming release];
    }
    else
    {
        NSString *msg = [NSString stringWithFormat:@"错误码:%d\r\n错误详情:%@", reason.reason, reason.msg.length>0?reason.msg:@"未知"];
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                       message:msg
                                                      delegate:nil
                                             cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [view show];;
        [view release];
    }
}

@end
