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

#import "GroupCardInfoViewController.h"
#import "EditGroupCardViewController.h"
#define TAG_TABLEVIEW_GROUPCARD   3000
@interface GroupCardInfoViewController ()

@end

@implementation GroupCardInfoViewController

- (id)initWithVoip:(NSString*)voip andGroupId:(NSString*) groupId andIsOwner:(BOOL)isOwnGroup
{
    self = [super init];
    if (self)
    {
        self.voipAccount = voip;
        self.belong = groupId;
        isOwnerGroup = isOwnGroup;
        self.modelEngineVoip.UIDelegate = self;
        [self.modelEngineVoip queryGroupCardWithOther:self.voipAccount andBelong:self.belong];
        // Custom initialization
    }
    return self;
}

-(void)save
{
    [self displayProgressingView];
    if (isOwnerGroup)
    {
        self.groupCard.sid = self.voipAccount;
    }
    [self.modelEngineVoip modifyGroupCard:self.groupCard];
}

-(void)loadView
{
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    if (isOwnerGroup)
    {
        UIBarButtonItem *clearMessage=[[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"保存" target:self action:@selector(save)]];
        self.navigationItem.rightBarButtonItem = clearMessage;
        [clearMessage release];
    }
    
    self.title = @"成员资料";    
    
    UIView* mainview = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    mainview.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    self.view = mainview;
    [mainview release];
    
    
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
    tableView.tag = TAG_TABLEVIEW_GROUPCARD;
    [self.view addSubview:tableView];
    [tableView release];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"成员资料";
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4)
    {        
        CGSize size = [self.groupCard.remark sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(190.0f, 1000.0f) lineBreakMode:UILineBreakModeCharacterWrap];
        if (size.height > 44) {
            return size.height+20;
        }
    }
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == TAG_TABLEVIEW_GROUPCARD)
    {
        UIView *headView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 23.0f)] autorelease];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_bg.png"]];
        [headView addSubview:image];
        [image release];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, 300, 23.0f)];
        [headView addSubview:label];
        label.font = [UIFont systemFontOfSize:13.0f];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"";
        label.textColor = [UIColor whiteColor];
        [label release];
        return headView;
    }
    return [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)] autorelease];;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (tableView.tag == TAG_TABLEVIEW_GROUPCARD)
    {
        count = 6;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellid = @"GroupCell_cellid";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    
    UILabel *captionLabel = nil;
    UILabel *infoLabel = nil;
    UIImageView *lineImg = nil;
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
        cell.contentView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        
        UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 12.0f, 80.0f, 20.0f)];
        idLabel.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        idLabel.font = [UIFont systemFontOfSize:16.0f];
        idLabel.textColor = [UIColor grayColor];
        idLabel.tag = 1001;
        captionLabel = idLabel;
        [cell.contentView addSubview:idLabel];
        [idLabel release];
        
        UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(110.0f, 12.0f, 190.0f, 20.0f)];
        tmpLabel.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        tmpLabel.font = [UIFont systemFontOfSize:15.0f];
        tmpLabel.tag = 1002;
        infoLabel = tmpLabel;
        [cell.contentView addSubview:tmpLabel];
        [tmpLabel release];
        infoLabel.textAlignment = NSTextAlignmentLeft;
        
        UIImageView *lineImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice_mail_line.png"]];
        lineImg.frame = CGRectMake(0.0f, 43.0f, 320.0f, 1.0f);
        lineImg.tag = 1003;
        [cell.contentView addSubview:lineImg];
        [lineImg release];
    }
    else
    {
        captionLabel = (UILabel*)[cell viewWithTag:1001];
        infoLabel    = (UILabel*)[cell viewWithTag:1002];
        lineImg      = (UIImageView*)[cell viewWithTag:1003];
    }
    if (isOwnerGroup)
    {
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    switch (indexPath.row)
    {
        case 0:                                 
            captionLabel.text = @"群组ID";
            if (self.groupCard.belong)
            {
                infoLabel.text = self.groupCard.belong;
            }
            else
                infoLabel.text = self.belong;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case 1:
            captionLabel.text = @"VoIP账号";
            infoLabel.text = self.voipAccount;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case 2:
            captionLabel.text = @"群昵称";
            if ([self.groupCard.display length]>0)
            {
                infoLabel.text = self.groupCard.display;
            }
            break;
        case 3:
            captionLabel.text = @"电话";
            if ([self.groupCard.tel length]>0)
            {
                infoLabel.text = self.groupCard.tel;
            }
            break;
        case 4:
            captionLabel.text = @"邮箱";
            if ([self.groupCard.mail length]>0)
            {
                infoLabel.text = self.groupCard.mail;
            }
            break;
        case 5:
            captionLabel.text = @"备注";
            if ([self.groupCard.remark length]>0)
            {
                CGSize size = [self.groupCard.remark sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(190.0f, 1000.0f) lineBreakMode:UILineBreakModeCharacterWrap];
                if (size.height > 44) {
                    infoLabel.frame = CGRectMake(110.0f, 12.0f, 190.0f, size.height);
                    infoLabel.lineBreakMode = UILineBreakModeWordWrap;
                    infoLabel.numberOfLines = 0;
                    lineImg.frame = CGRectMake(0.0f, size.height +20, 320.0f, 1.0f);
                }
                infoLabel.text = self.groupCard.remark;
            }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 1 && isOwnerGroup)
    {
        EditGroupCardViewController *view = [[EditGroupCardViewController alloc] initWithType:indexPath.row-1 andGroupCard:self.groupCard];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
}


-(void)onQueryCardWithReason:(CloopenReason*)reason andGroupCard:(IMGruopCard *)groupCard
{
    if (reason.reason == 0)
    {
        self.groupCard = groupCard;
        if (!groupCard.belong)
        {
            self.groupCard.belong = self.belong;
        }
        UITableView* tmpview = (UITableView*) [self.view viewWithTag:TAG_TABLEVIEW_GROUPCARD];
        [tmpview reloadData];
    }
    else
    {
        [self popPromptViewWithMsg:[NSString stringWithFormat:@"错误码：%d,错误详情：%@",reason.reason,reason.msg]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.modelEngineVoip.UIDelegate = self;
    UITableView* tmpview = (UITableView*) [self.view viewWithTag:TAG_TABLEVIEW_GROUPCARD];
    [tmpview reloadData];
}

-(void)dealloc
{
    self.belong = nil;
    self.voipAccount = nil;
    self.groupCard = nil;
    [super dealloc];
}


-(void)onModifyGroupCardWithReason:(CloopenReason*)reason
{
    [self dismissProgressingView];
    if (reason.reason == 0)
    {
        //成功后可以刷新界面或者别的什么
    }
    else
    {
        [self popPromptViewWithMsg:[NSString stringWithFormat:@"群名片保存失败。错误码：%d,错误详情：%@",reason.reason,reason.msg]];
    }
}

@end
