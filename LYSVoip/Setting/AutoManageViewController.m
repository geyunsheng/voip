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

#import "AutoManageViewController.h"
#import "UISelectCell.h"

@interface AutoManageViewController ()

@end

@implementation AutoManageViewController
@synthesize cellDataArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

- (id)initWithList:(NSMutableArray *)list WithType:(ESettingType)type
{
    self = [super init];
    
    if (self)
    {
        self.cellDataArray = list;
        settingType = type;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    selectedIndex = -1;
    lastSelectedIndex = -1;
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(goBack)]];
    self.navigationItem.leftBarButtonItem = btnBack;
    [btnBack release];
    
    if (settingType == EAutoManage)
    {
        self.title = @"自动增益控制";
    }
    else if (settingType == EEchoCancelled)
    {
        self.title = @"回音消除";
    }
    else if (settingType == ESilenceRestrain)
    {
        self.title = @"静音抑制";
    }
    
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    
    UIView* headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, 320, 29);
    UIImageView *imgHeader = [[UIImageView alloc] initWithFrame:headerView.frame];
    imgHeader.image = [UIImage imageNamed:@"point_bg.png"];
    [headerView addSubview:imgHeader];
    [imgHeader release];
    
    UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 29.0f)] ;
    lbHeader.backgroundColor = [UIColor clearColor];
    lbHeader.font = [UIFont systemFontOfSize:13.0f];
    lbHeader.textColor = [UIColor whiteColor];
    lbHeader.textAlignment = UITextAlignmentCenter;
    [headerView addSubview:lbHeader];
    lbHeader.text = @"请点击选择";
    self.headerLabel = lbHeader;
    [lbHeader release];
    [self.view addSubview:headerView];
    [headerView release];
    
	UITableView *tableView = nil;
    
    if (IPHONE5)
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 29, 320, 548-29)
                                                 style:UITableViewStylePlain];
    }
    else
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 29, 320, 460-29)
                                                 style:UITableViewStylePlain];
    }
    
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.delegate = self;
	tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    self.myTableView = tableView;
	[self.view addSubview:tableView];
	[tableView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.headerLabel = nil;
    self.footerLabel = nil;
    self.myTableView = nil;
    self.cellDataArray = nil;

    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cellDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UISelectCell *cell = nil;
    
    static NSString *cellIdentifier = @"Cell";
    
    cell = (UISelectCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ( cell == nil )
    {
        cell = [[[UISelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }

    cell.isSingleCheck = YES;
    
    AccountInfo *content = [cellDataArray objectAtIndex:indexPath.row];
    
    if (content.isChecked)  //进来时默认选中的项
    {
        selectedIndex = indexPath.row;
    }
    
    [cell makeCellWithVoipInfo:content];
    
	return cell;
}

-(void)goBack
{
    //返回之前保存一下设置
    switch (settingType)
	{
        case EAutoManage: //自动增益控制
        {
            if (selectedIndex != -1)
            {
                AccountInfo *info = [cellDataArray objectAtIndex:selectedIndex];
                NSString *content = info.voipId;                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setInteger:selectedIndex forKey:AUTOMANAGE_INDEX_KEY];
                [userDefaults setObject:content forKey:AUTOMANAGE_CONTENT_KEY];
                [userDefaults synchronize]; // writes modifications to disk
                [self.modelEngineVoip setAudioConfigEnabledWithType:eAUDIO_AGC andEnabled:YES andMode:selectedIndex];
            }
         }
            break;
        case EEchoCancelled: //回音消除
        {
            if (selectedIndex != -1)
            {
                AccountInfo *info = [cellDataArray objectAtIndex:selectedIndex];
                NSString *content = info.voipId;                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setInteger:selectedIndex forKey:ECHOCANCELLED_INDEX_KEY];
                [userDefaults setObject:content forKey:ECHOCANCELLED_CONTENT_KEY];
                [userDefaults synchronize]; // writes modifications to disk
                [self.modelEngineVoip setAudioConfigEnabledWithType:eAUDIO_EC andEnabled:YES andMode:selectedIndex];
            }
        }
            break;
        case ESilenceRestrain: //静音抑制
        {
            if (selectedIndex != -1)
            {
                AccountInfo *info = [cellDataArray objectAtIndex:selectedIndex];
                NSString *content = info.voipId;                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setInteger:selectedIndex forKey:SILENCERESTRAIN_INDEX_KEY];
                [userDefaults setObject:content forKey:SILENCERESTRAIN_CONTENT_KEY];
                [userDefaults synchronize]; // writes modifications to disk
                [self.modelEngineVoip setAudioConfigEnabledWithType:eAUDIO_NS andEnabled:YES andMode:selectedIndex];
            }
        }
            break;
        default:
            break;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    lastSelectedIndex = selectedIndex;
    
    if ( lastSelectedIndex != -1 )
    {
        AccountInfo* info = [cellDataArray objectAtIndex:lastSelectedIndex];
        info.isChecked = !info.isChecked;
        
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastSelectedIndex inSection:0];
        UISelectCell *lastCell = (UISelectCell *)[tableView cellForRowAtIndexPath:lastIndexPath];
        [lastCell resetCheckImge:info.isChecked];
    }
    
    selectedIndex = indexPath.row;
    
    if ( selectedIndex != lastSelectedIndex )
    {
        AccountInfo* info = [cellDataArray objectAtIndex:indexPath.row];
        info.isChecked = !info.isChecked;
        
        UISelectCell* cell = (UISelectCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell resetCheckImge:info.isChecked];
    }
    else    //在当前选中的cell中反选，置为初值
    {
        lastSelectedIndex = -1;
        selectedIndex = -1;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
