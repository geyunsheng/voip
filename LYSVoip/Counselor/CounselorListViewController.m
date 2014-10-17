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


#import "counselorListViewController.h"

@interface counselorListViewController ()

@end

@implementation counselorListViewController


-(void)dealloc
{
    self.IDStr = nil;
    self.NameStr = nil;
    self.arrList = nil;
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithTypeID:(NSString*) typeID
{
    if (self = [super init])
    {
        self.IDStr = typeID;
        return self;
    }
    return nil;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.modelEngineVoip.UIDelegate = self;
    [self displayProgressingView];
    [self.modelEngineVoip getExpertListOfCategoryId:self.IDStr];
    
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].applicationFrame.size.width ,[UIScreen mainScreen].bounds.size.height-64 ) style:(UITableViewStylePlain)];
    tableview.delegate=self;
	tableview.dataSource=self;
    tableview.backgroundView = [[[UIView alloc] initWithFrame:tableview.frame] autorelease];
    tableview.tableFooterView = [[[UIView alloc] init] autorelease];
    [self.view addSubview: tableview];
    [tableview release];
    
    self.title = [NSString stringWithFormat:@"%@专家", self.NameStr];
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(back)]];
    self.navigationItem.leftBarButtonItem = btnBack;
    [btnBack release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section
{
    return self.arrList.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 154 / 2 ;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.modelEngineVoip.UIDelegate = self;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    UITableViewCell *cell;
    {
        static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:
                SectionsTableIdentifier ];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                           reuseIdentifier: SectionsTableIdentifier ] autorelease];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        for (UIView *subview in cell.contentView.subviews)
        {
            if (subview.tag == 1001)
            {
                [subview removeFromSuperview];
            }
        }
    
        {
            NSDictionary* dict = [self.arrList objectAtIndex:row];
            UILabel* lab1;
            lab1 = [[UILabel alloc] init];
            lab1.frame = CGRectMake(85, 10, 70, 20);
            lab1.text = [dict objectForKey:@"name"];
            lab1.textColor = [UIColor blackColor];
            lab1.font = [UIFont boldSystemFontOfSize:16];
            lab1.highlightedTextColor = [UIColor whiteColor];
            lab1.backgroundColor = [UIColor clearColor];
            lab1.tag = 1001;
            [cell.contentView addSubview:lab1];
            [lab1 release];
            
            UILabel* lab2;
            lab2 = [[UILabel alloc] initWithFrame:CGRectMake(160, 10, 230, 20)];
            lab2.textColor = [UIColor blueColor];
            lab2.highlightedTextColor = [UIColor whiteColor];
            NSString* strGrade = [self getgrade:[dict objectForKey:@"grade"]];
            lab2.text = strGrade;
            lab2.font = [UIFont systemFontOfSize:13];
            lab2.backgroundColor = [UIColor clearColor];
            lab2.tag = 1001;
            [cell.contentView addSubview:lab2];
            [lab2 release];
            
            for (int i = 0; i<=4; i++)
            {
                UIImageView * img1;
                img1 = [[UIImageView alloc] init];
                img1.frame = CGRectMake(85+10*i, 35, 10, 14);
                if ([[dict objectForKey:@"grade"] intValue] >= i+1)
                {
                    img1.image = [UIImage imageNamed:@"star_01.png"];
                }
                else
                    img1.image = [UIImage imageNamed:@"star_02.png"];
                img1.tag = 1001;
                [cell.contentView addSubview:img1];
                [img1 release];
            }
            {
                UILabel* lab3;
                lab3 = [[UILabel alloc] initWithFrame:CGRectMake(85, 55, 230, 15)];
                lab3.textColor = [UIColor colorWithRed:(130.0/255) green:(130.0/255) blue:130.0/255 alpha:1.0];
                lab3.highlightedTextColor = [UIColor whiteColor];
                
                NSString* str  = [dict objectForKey:@"personInfo"];
                
                lab3.text = [NSString stringWithFormat:@"专长:%@",[str length] > 0 ? str : self.NameStr];
                lab3.font = [UIFont systemFontOfSize:13];
                lab3.backgroundColor = [UIColor clearColor];
                lab3.tag = 1001;
                [cell.contentView addSubview:lab3];
                [lab3 release];
            }
            {
                UIImageView * img1 = [[UIImageView alloc] init];
                img1.frame = CGRectMake(12, 12, 59, 59);
                NSString * str = [NSString stringWithFormat:@"head_portrait_0%d.png",indexPath.row % 2+1];
                img1.image = [UIImage imageNamed:str];
                img1.tag = 1001;
                [cell.contentView addSubview:img1];
                [img1 release];
            }

        }

    }
    return cell;
}

-(NSString*)getgrade:(NSString*) str
{
    NSString* string;
    if ([str isEqualToString:@"0"])
    {
        string = @"实习医生";
    }
    else if ([str isEqualToString:@"1"])
    {
        string =@"医师";
    }
    else if ([str isEqualToString:@"2"])
    {
        string =@"主治医师";
    }
    else if ([str isEqualToString:@"3"])
    {
        string =@"副主任医师";
    }
    else if ([str isEqualToString:@"4"])
    {
        string =@"主任医师";
    }
    else if ([str isEqualToString:@"5"])
    {
        string =@"专家";
    }
    else
    {
        string =@"老专家";
    }
    return string;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dict = [self.arrList objectAtIndex:indexPath.row];
    counselorInfoViewController* view = [[counselorInfoViewController alloc] initWithID:[dict objectForKey:@"id"] andName:[dict objectForKey:@"name"]];
    
    NSString* str  = [dict objectForKey:@"detail"];
    view.detail = str;
    str = [NSString stringWithFormat:@"head_portrait_0%d.png",indexPath.row %2 +1];
    view.path = str;
    
    view.personInfo = [dict objectForKey:@"personInfo"];
    view.grade = [[dict objectForKey:@"grade"] intValue];
    
    view.gradeStr = [self getgrade:[dict objectForKey:@"grade"]];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
    
    [tableview deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)onGetExpertListWithReason:(CloopenReason*)reason andExperts:(NSMutableArray *)expertArray{
    
    [self dismissProgressingView];
    if (reason.reason == 0)
    {
        self.arrList = expertArray;
        [tableview reloadData];
    }
    else
    {
        [self popPromptViewWithMsg:[NSString stringWithFormat:@"获取专家列表失败。错误码：%d,错误详情：%@",reason.reason,reason.msg]];
    }
}
@end

