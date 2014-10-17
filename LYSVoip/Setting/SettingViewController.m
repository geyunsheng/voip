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

#import "SettingViewController.h"
#import "AccountInfo.h"
#import "AutoManageViewController.h"
#import "CheckNetViewController.h"
#import "AboutViewController.h"


#define TAG_SWITCH_AUTO                 1000    //自动增益控制
#define TAG_SWITCH_ECHOCANCELLED        1001    //回音消除
#define TAG_SWITCH_SILENCE              1002    //静音抑制
#define TAG_SWITCH_VIDEO                1003    //视频码流控制
#define TAG_ALERTVIEW_VIDEOSTREAM       1004    //输入码率AlertView
#define TAG_ALERTVIEW_P2P_SERVER        1005    //P2P服务器设置
#define TAG_SWITCH_CHUNKED              1007    //chunked录音控制
#define TAG_SWITCH_SHIELDMOSAIC         1009    //马赛克抑制
#define TAG_SWITCH_RECORDVOICE          1010    //录音开关
@interface SettingViewController ()

@end

@implementation SettingViewController
@synthesize myTable;
@synthesize myTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

- (void)loadView
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = btnBack;
    [btnBack release];
    
    self.title = @"设置";
    
    UIView *selfView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view = selfView;
    [selfView release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, self.view.frame.size.height-44) style:UITableViewStyleGrouped];

    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;

    [self.view addSubview:tableView];
    self.myTable = tableView;
    [tableView release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [myTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.myTable = nil;
    
    [super dealloc];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)] autorelease];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 60, 20)];
    
    switch (section)
    {
        case 0:
        {
            label.text = @"参数配置";
        }
            break;
        case 1:
        {
            label.text = @"其它";
        }
            break;
        default:
            break;
    }
    
    label.font = [UIFont systemFontOfSize:14.0f];
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    [view addSubview:label];
    [label release];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (indexPath.section)
	{
        case 0:
        {
            if (indexPath.row == 0) //自动增益控制
            {
                NSMutableArray *itemArray = [[NSMutableArray alloc] init];
                AccountInfo *info = [[AccountInfo alloc] init];
                info.voipId = @"AgcUnchanged";
                [itemArray addObject:info];
                [info release];
                
                AccountInfo *info1 = [[AccountInfo alloc] init];
                info1.voipId = @"AgcDefault";
                [itemArray addObject:info1];
                [info1 release];
                
                AccountInfo *info2 = [[AccountInfo alloc] init];
                info2.voipId = @"AgcAdaptiveAnalog";
                [itemArray addObject:info2];
                [info2 release];
                
                AccountInfo *info3 = [[AccountInfo alloc] init];
                info3.voipId = @"AgcAdaptiveDigital";
                [itemArray addObject:info3];
                [info3 release];
                
                AccountInfo *info4 = [[AccountInfo alloc] init];
                info4.voipId = @"AgcFixedDigital";
                [itemArray addObject:info4];
                [info4 release];
                NSInteger index = 0;
                
                index = [defaults integerForKey:AUTOMANAGE_INDEX_KEY];
                AccountInfo *infoIndex = [itemArray objectAtIndex:index];
                infoIndex.isChecked = YES;

                AutoManageViewController *view = [[AutoManageViewController alloc] initWithList:itemArray WithType:EAutoManage];
                [self.navigationController pushViewController:view animated:YES];
                [view release];
                [itemArray release];
            }
            else if (indexPath.row == 1) //回音消除
            {
                NSMutableArray *itemArray = [[NSMutableArray alloc] init];
                
                AccountInfo *info = [[AccountInfo alloc] init];
                info.voipId = @"EcUnchanged";
                [itemArray addObject:info];
                [info release];
                
                AccountInfo *info1 = [[AccountInfo alloc] init];
                info1.voipId = @"EcDefault";
                [itemArray addObject:info1];
                [info1 release];
                
                AccountInfo *info2 = [[AccountInfo alloc] init];
                info2.voipId = @"EcConference";
                [itemArray addObject:info2];
                [info2 release];
                
                AccountInfo *info3 = [[AccountInfo alloc] init];
                info3.voipId = @"EcAec";
                [itemArray addObject:info3];
                [info3 release];
                
                AccountInfo *info4 = [[AccountInfo alloc] init];
                info4.voipId = @"EcAecm";
                [itemArray addObject:info4];
                [info4 release];
                NSInteger index = 0;
                
                index = [defaults integerForKey:ECHOCANCELLED_INDEX_KEY];
                AccountInfo *infoIndex = [itemArray objectAtIndex:index];
                infoIndex.isChecked = YES;
                
                AutoManageViewController *view = [[AutoManageViewController alloc] initWithList:itemArray WithType:EEchoCancelled];
                [self.navigationController pushViewController:view animated:YES];
                [view release];
                [itemArray release];
            }
            else if (indexPath.row == 2) //静音抑制
            {
                NSMutableArray *itemArray = [[NSMutableArray alloc] init];
                AccountInfo *info = [[AccountInfo alloc] init];
                info.voipId = @"NsUnchanged";
                [itemArray addObject:info];
                [info release];
                
                AccountInfo *info1 = [[AccountInfo alloc] init];
                info1.voipId = @"NsDefault";
                [itemArray addObject:info1];
                [info1 release];
                
                AccountInfo *info2 = [[AccountInfo alloc] init];
                info2.voipId = @"NsConference";
                [itemArray addObject:info2];
                [info2 release];
                
                AccountInfo *info3 = [[AccountInfo alloc] init];
                info3.voipId = @"NsLowSuppression";
                [itemArray addObject:info3];
                [info3 release];
                
                AccountInfo *info4 = [[AccountInfo alloc] init];
                info4.voipId = @"NsModerateSuppression";
                [itemArray addObject:info4];
                [info4 release];

                AccountInfo *info5 = [[AccountInfo alloc] init];
                info5.voipId = @"NsHighSuppression";
                [itemArray addObject:info5];
                [info5 release];

                AccountInfo *info6 = [[AccountInfo alloc] init];
                info6.voipId = @"NsVeryHighSuppression";
                [itemArray addObject:info6];
                [info6 release];
                
                NSInteger index = 0;
               
                index = [defaults integerForKey:SILENCERESTRAIN_INDEX_KEY];
                AccountInfo *infoIndex = [itemArray objectAtIndex:index];
                infoIndex.isChecked = YES;
                
                AutoManageViewController *view = [[AutoManageViewController alloc] initWithList:itemArray WithType:ESilenceRestrain];
                [self.navigationController pushViewController:view animated:YES];
                [view release];
                [itemArray release];
            }
            else if (indexPath.row == 3) //视频码流控制
            {
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
                {
                    CustomeAlertView *customeAlertView = [[CustomeAlertView alloc]init];
                    customeAlertView.delegate = self;
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 15.0f, 180.0f, 25.0f)];
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.textAlignment = UITextAlignmentCenter;
                    titleLabel.textColor = [UIColor blackColor];
                    titleLabel.font = [UIFont systemFontOfSize:14.0f];
                    titleLabel.text = @"视频码流控制";
                    [customeAlertView.myView addSubview:titleLabel];
                    [titleLabel release];
                    
                    myTextField = [[[UITextField alloc] initWithFrame:CGRectMake(20.0, 55.0, 220.0, 25.0)] autorelease];
                    myTextField.borderStyle = UITextBorderStyleRoundedRect;
                    myTextField.tag = TAG_ALERTVIEW_VIDEOSTREAM;
                    myTextField.placeholder = @"";
                    [myTextField setBackgroundColor:[UIColor whiteColor]];
                    myTextField.delegate = self;
                    myTextField.keyboardType = UIKeyboardTypeNumberPad;
                    [customeAlertView.myView addSubview:myTextField];
                    
                    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 90.0f, 180.0f, 25.0f)];
                    noteLabel.backgroundColor = [UIColor clearColor];
                    noteLabel.textAlignment = UITextAlignmentCenter;
                    noteLabel.textColor = [UIColor blackColor];
                    noteLabel.font = [UIFont systemFontOfSize:14.0f];
                    noteLabel.text = @"输入规则：30-300整数";
                    [customeAlertView.myView addSubview:noteLabel];
                    [noteLabel release];
                    
                    CGRect frame = customeAlertView.myView.frame;
                    frame.origin.y -= 60;
                    frame.size.height -= 20;
                    [customeAlertView setViewFrame:frame];
                    
                    [customeAlertView show];
                    [myTextField becomeFirstResponder];
                }
                else
                {                    
                    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"视频码流控制" message:@"\n \n \n \n" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    alertview.tag = TAG_ALERTVIEW_VIDEOSTREAM;
                    myTextField = [[[UITextField alloc] initWithFrame:CGRectMake(40.0, 55.0, 220.0, 25.0)] autorelease];
                    myTextField.tag = TAG_ALERTVIEW_VIDEOSTREAM;
                    myTextField.placeholder = @"";
                    [myTextField setBackgroundColor:[UIColor whiteColor]];
                    myTextField.delegate = self;
                    myTextField.keyboardType = UIKeyboardTypeNumberPad;
                    [alertview addSubview:myTextField];
                    
                    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 95.0f, 180.0f, 25.0f)];
                    noteLabel.backgroundColor = [UIColor clearColor];
                    noteLabel.textColor = [UIColor whiteColor];
                    noteLabel.font = [UIFont systemFontOfSize:14.0f];
                    noteLabel.text = @"输入规则：30-300整数";
                    [alertview addSubview:noteLabel];
                    [noteLabel release];
                    
                    [alertview show];
                    [alertview release];
                    [myTextField becomeFirstResponder];
                }
            }
        }
            break;
        case 1: //其它
        {
            if (indexPath.row == 0)
            {
                CheckNetViewController *view = [[CheckNetViewController alloc] init];
                [self.navigationController pushViewController:view animated:YES];
                [view release];
            }
            else if (indexPath.row == 4)
            {
                AboutViewController * view = [[AboutViewController alloc] init];
                [self.navigationController pushViewController:view animated:YES];
                [view release];
            }
        }
            break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger iCount = 0;
    if (section == 0)
    {
        iCount = 4;
    }
    else
    {
        iCount = 5;
    }
    return iCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    NSString *switchCellIdent = @"SwitchCell";
    NSString *styleDefaultCellIdent = @"StyleDefaultCell";
    
    for (UIView * view in cell.contentView.subviews)
    {
        if (view.tag >= 1000)
        {
            [view removeFromSuperview];
        }
    }
    
    switch (indexPath.section)
	{
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:switchCellIdent];
            
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:switchCellIdent] autorelease];
            }
            [cell setSelectionStyle:(UITableViewCellSelectionStyleNone)];
            UISwitch* switchCtr = [[UISwitch alloc] init];
            CGRect frame = switchCtr.frame;
            frame.origin.x = 300-frame.size.width;
            frame.origin.y = 22-frame.size.height*0.5;
            switchCtr.frame = frame;
            switchCtr.backgroundColor = [UIColor clearColor];
            
            if (indexPath.row == 0)
            {
                cell.textLabel.text = @"自动增益控制";                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *content = [defaults objectForKey:AUTOMANAGE_CONTENT_KEY];
                NSInteger flag = [defaults integerForKey:AUTOMANAGE_KEY];
                cell.detailTextLabel.text = content;
                
                switch ([defaults integerForKey:AUTOMANAGE_INDEX_KEY])
                {
                    case 0:
                        cell.detailTextLabel.text = @"AgcUnchanged";
                        break;
                    case 1:
                        cell.detailTextLabel.text = @"AgcDefault";
                        break;
                    case 2:
                        cell.detailTextLabel.text = @"AgcAdaptiveAnalog";
                        break;
                    case 3:
                        cell.detailTextLabel.text = @"AgcAdaptiveDigital";
                    case 4:
                        cell.detailTextLabel.text = @"AgcFixedDigital";
                        break;
                    default:
                        break;
                }
                
                switchCtr.tag = TAG_SWITCH_AUTO;

                if (flag == -1)
                {
                    switchCtr.on = NO;
                }
                else
                {
                    switchCtr.on = YES;
                }
            }
            else if (indexPath.row == 1)
            {
                cell.textLabel.text = @"回音消除";
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *content = [defaults objectForKey:ECHOCANCELLED_CONTENT_KEY];
                NSInteger flag = [defaults integerForKey:ECHOCANCELLED_KEY];
                cell.detailTextLabel.text = content;
                
                switch ([defaults integerForKey:ECHOCANCELLED_INDEX_KEY])
                {
                    case 0:
                        cell.detailTextLabel.text = @"EcUnchanged";
                        break;
                    case 1:
                        cell.detailTextLabel.text = @"EcDefault";
                        break;
                    case 2:
                        cell.detailTextLabel.text = @"EcConference";
                        break;
                    case 3:
                        cell.detailTextLabel.text = @"EcAec";
                    case 4:
                        cell.detailTextLabel.text = @"EcAecm";
                        break;
                    default:
                        break;
                }
                                
                switchCtr.tag = TAG_SWITCH_ECHOCANCELLED;
                
                if (flag == -1)
                {
                    switchCtr.on = NO;
                }
                else
                {
                    switchCtr.on = YES;
                }
            }
            else if (indexPath.row == 2)
            {
                cell.textLabel.text = @"静音抑制";
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *content = [defaults objectForKey:SILENCERESTRAIN_CONTENT_KEY];
                NSInteger flag = [defaults integerForKey:SILENCERESTRAIN_KEY];
                cell.detailTextLabel.text = content;
                                
                switch ([defaults integerForKey:SILENCERESTRAIN_INDEX_KEY])
                {
                    case 0:
                        cell.detailTextLabel.text = @"NsUnchanged";
                        break;
                    case 1:
                        cell.detailTextLabel.text = @"NsDefault";
                        break;
                    case 2:
                        cell.detailTextLabel.text = @"NsConference";
                        break;
                    case 3:
                        cell.detailTextLabel.text = @"NsLowSuppression";
                    case 4:
                        cell.detailTextLabel.text = @"NsModerateSuppression";
                        break;
                    case 5:
                        cell.detailTextLabel.text = @"NsHighSuppression";
                        break;
                    case 6:
                        cell.detailTextLabel.text = @"NsVeryHighSuppression";
                        break;
                    default:
                        break;
                }

                switchCtr.tag = TAG_SWITCH_SILENCE;
                
                if (flag == -1)
                {
                    switchCtr.on = NO;
                }
                else
                {
                    switchCtr.on = YES;
                }
            }
            else if (indexPath.row == 3)
            {
                cell.textLabel.text = @"视频码流控制";
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *content = [defaults objectForKey:VIDEOSTREAM_CONTENT_KEY];
                NSInteger flag = [defaults integerForKey:VIDEOSTREAM_KEY];
                cell.detailTextLabel.text = content;                
                switchCtr.tag = TAG_SWITCH_VIDEO;                
                if (flag == -1)
                {
                    switchCtr.on = NO;
                }
                else
                {
                    switchCtr.on = YES;
                }
            }

            [switchCtr addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchCtr];
            [switchCtr release];
        }
            break;
        case 1:
        {
            if (indexPath.row == 3) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"StyleP2PCell"];
            }
            else
                cell = [tableView dequeueReusableCellWithIdentifier:styleDefaultCellIdent];
            
            if (cell == nil)
            {
                if (indexPath.row == 3) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"StyleP2PCell"] autorelease];
                }
                else
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:styleDefaultCellIdent] autorelease];
            }
            [cell setSelectionStyle:(UITableViewCellSelectionStyleNone)];
            
            if (indexPath.row == 0)
            {
                cell.textLabel.text = @"网络检测";
                cell.detailTextLabel.text = @"";
            }
            else if (indexPath.row == 1)
            {
                UISwitch* switchCtr = [[UISwitch alloc] init];
                CGRect frame = switchCtr.frame;
                frame.origin.x = 300-frame.size.width;
                frame.origin.y = 22-frame.size.height*0.5;
                switchCtr.frame = frame;
                switchCtr.backgroundColor = [UIColor clearColor];
                
                cell.textLabel.text = @"录音边录边传";
                cell.detailTextLabel.text = @"";
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSInteger flag = [defaults integerForKey:VOICE_CHUNKED_SEND_KEY];
                switchCtr.tag = TAG_SWITCH_CHUNKED;
                if (flag == 1)
                {
                    switchCtr.on = YES;
                }
                else
                {
                    switchCtr.on = NO;
                }
                [switchCtr addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:switchCtr];
                [switchCtr release];
            }
            else if (indexPath.row == 2)
            {
                UISwitch* switchCtr = [[UISwitch alloc] init];
                CGRect frame = switchCtr.frame;
                frame.origin.x = 300-frame.size.width;
                frame.origin.y = 22-frame.size.height*0.5;
                switchCtr.frame = frame;
                switchCtr.backgroundColor = [UIColor clearColor];
                cell.textLabel.text = @"视频通话马赛克抑制";
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSInteger flag = [defaults integerForKey:SHIELDMOSAIC_KEY];
                switchCtr.tag = TAG_SWITCH_SHIELDMOSAIC;
                if (flag == 1)
                {
                    switchCtr.on = YES;
                }
                else
                {
                    switchCtr.on = NO;
                }
                [switchCtr addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:switchCtr];
                [switchCtr release];
            }
            else if (indexPath.row == 3)
            {
                UISwitch* switchCtr = [[UISwitch alloc] init];
                CGRect frame = switchCtr.frame;
                frame.origin.x = 300-frame.size.width;
                frame.origin.y = 22-frame.size.height*0.5;
                switchCtr.frame = frame;
                switchCtr.backgroundColor = [UIColor clearColor];
                cell.textLabel.text = @"通话录音";
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSInteger flag = [defaults integerForKey:RECORDVOICE_KEY];
                switchCtr.tag = TAG_SWITCH_RECORDVOICE;
                if (flag == 1)
                {
                    switchCtr.on = YES;
                }
                else
                {
                    switchCtr.on = NO;
                }
                [switchCtr addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:switchCtr];
                [switchCtr release];
            }
            else if (indexPath.row == 4)
            {
                cell.textLabel.text = @"帮助与关于";
            }
            
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Switch事件

-(void)switchAction:(id)sender
{
    UISwitch* switchctl = (UISwitch*) sender;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    EAudioType audioType;
    BOOL flag = NO;
    if (switchctl.tag == TAG_SWITCH_AUTO)   //自动增益控制
    {
        if (switchctl.isOn)
        {
            [userDefaults setInteger:1 forKey:AUTOMANAGE_KEY];
            flag = YES;
        }
        else
        {
            [userDefaults setInteger:-1 forKey:AUTOMANAGE_KEY];
        }
        audioType = eAUDIO_AGC;
        int selectedIndex = [userDefaults integerForKey:AUTOMANAGE_INDEX_KEY];
        [self.modelEngineVoip setAudioConfigEnabledWithType:audioType andEnabled:flag andMode:selectedIndex];
    }
    else if (switchctl.tag == TAG_SWITCH_ECHOCANCELLED) //回音消除
    {
        if (switchctl.isOn)
        {
            [userDefaults setInteger:1 forKey:ECHOCANCELLED_KEY];
            flag = YES;
        }
        else
        {
            [userDefaults setInteger:-1 forKey:ECHOCANCELLED_KEY];
        }
        audioType = eAUDIO_EC;
        int selectedIndex = [userDefaults integerForKey:ECHOCANCELLED_INDEX_KEY];        
        [self.modelEngineVoip setAudioConfigEnabledWithType:audioType andEnabled:flag andMode:selectedIndex];
    }
    else if (switchctl.tag == TAG_SWITCH_SILENCE) //静音抑制
    {        
        if (switchctl.isOn)
        {
            [userDefaults setInteger:1 forKey:SILENCERESTRAIN_KEY];
            flag = YES;
        }
        else
        {
            [userDefaults setInteger:-1 forKey:SILENCERESTRAIN_KEY];
        }
        audioType = eAUDIO_NS;
        int selectedIndex = [userDefaults integerForKey:SILENCERESTRAIN_INDEX_KEY];
        [self.modelEngineVoip setAudioConfigEnabledWithType:audioType andEnabled:flag andMode:selectedIndex];
    }
    else if (switchctl.tag == TAG_SWITCH_VIDEO) //视频码流控制
    {
        if (switchctl.isOn)
        {
            [userDefaults setInteger:1 forKey:VIDEOSTREAM_KEY];
        }
        else
        {
            [userDefaults setInteger:-1 forKey:VIDEOSTREAM_KEY];
            [self.modelEngineVoip setVideoBitRates:150];
        }
    }
    else if (switchctl.tag == TAG_SWITCH_CHUNKED) //chunked控制
    {
        if (switchctl.isOn)
        {
            [userDefaults setInteger:1 forKey:VOICE_CHUNKED_SEND_KEY];
        }
        else
        {
            [userDefaults setInteger:-1 forKey:VOICE_CHUNKED_SEND_KEY];
        }
    }
    else if (switchctl.tag == TAG_SWITCH_SHIELDMOSAIC) //马赛克
    {
        if (switchctl.isOn)
        {
            [userDefaults setInteger:1 forKey:SHIELDMOSAIC_KEY];
            [self.modelEngineVoip setShieldMosaic:YES];
        }
        else
        {
            [userDefaults setInteger:-1 forKey:SHIELDMOSAIC_KEY];
            [self.modelEngineVoip setShieldMosaic:NO];
        }
    }
    else if (switchctl.tag == TAG_SWITCH_RECORDVOICE) //通话录音
    {
        if (switchctl.isOn)
        {
            [userDefaults setInteger:1 forKey:RECORDVOICE_KEY];
            [self.modelEngineVoip setShieldMosaic:YES];
        }
        else
        {
            [userDefaults setInteger:-1 forKey:RECORDVOICE_KEY];
            [self.modelEngineVoip setShieldMosaic:NO];
        }
    }
    [userDefaults synchronize]; // writes modifications to disk
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
	{
        case TAG_ALERTVIEW_VIDEOSTREAM:
        {
            if (buttonIndex == 1)
            {
                if ([myTextField.text length] > 0)
                {                   
                    NSInteger bitRates = 30;
                    if ([myTextField.text length]> 0)
                    {
                        bitRates = myTextField.text.integerValue;
                    }
                    
                    if ( bitRates<= 30)
                    {
                        bitRates = 30;
                    }
                    else if ( bitRates >300)
                    {
                        bitRates = 300;
                    }
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:[NSString stringWithFormat:@"%d",bitRates] forKey:VIDEOSTREAM_CONTENT_KEY];
                    [userDefaults synchronize]; // writes modifications to disk
                    [self.modelEngineVoip setVideoBitRates:bitRates];
                    [myTable reloadData];
                }
            }
        }
        case kKickedOff:
        {
            if (buttonIndex == 1)
            {
                exit(0);
            }
            else
            {
                [theAppDelegate logout];
            }
        }
            break;
        default:
            break;
    }
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
        if ([myTextField.text length] > 0)
        {
            NSInteger bitRates = 30;
            if ([myTextField.text length]> 0)
            {
                bitRates = myTextField.text.integerValue;
            }
            
            if ( bitRates<= 30)
            {
                bitRates = 30;
            }
            else if ( bitRates >300)
            {
                bitRates = 300;
            }
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[NSString stringWithFormat:@"%d",bitRates] forKey:VIDEOSTREAM_CONTENT_KEY];
            [userDefaults synchronize]; // writes modifications to disk
            [self.modelEngineVoip setVideoBitRates:bitRates];
            [myTable reloadData];
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
    NSMutableString *text = [[myTextField.text mutableCopy] autorelease];
    [text replaceCharactersInRange:range withString:string];
    if (textField.tag == TAG_ALERTVIEW_VIDEOSTREAM)
    {
        return [text length] <= 3;
    }
    return [text length] <= 30;
}

@end
