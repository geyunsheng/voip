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

#import "orderConsultViewController.h"

@interface orderConsultViewController ()

@end

@implementation orderConsultViewController
-(void)dealloc
{
    self.IDStr = nil;
    self.NameStr = nil;
    self.detail = nil;
    self.path = nil;
    self.gradeStr = nil;
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
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(back)]];
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];
    
    UIImageView * img1;
    img1 = [[UIImageView alloc] init];
    img1.frame = CGRectMake(9.5f, 90, 301, 306);
    img1.image = [UIImage imageNamed:@"bg_pt.png"];
    img1.tag = 1001;
    [self.view addSubview:img1];
    [img1 release];
    self.title  = @"专家详情";
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255. alpha:1];

    {
        UILabel* lab1;
        lab1 = [[UILabel alloc] init];
        lab1.frame = CGRectMake(85, 12, 100, 20);
        lab1.text = self.NameStr;
        lab1.textColor = [UIColor blackColor];
        lab1.font = [UIFont boldSystemFontOfSize:16];
        lab1.highlightedTextColor = [UIColor whiteColor];
        lab1.backgroundColor = [UIColor clearColor];
        lab1.tag = 1001;
        [self.view addSubview:lab1];
        [lab1 release];
        
        UILabel* lab2;
        lab2 = [[UILabel alloc] initWithFrame:CGRectMake(170, 12, 230, 20)];
        lab2.textColor = [UIColor blueColor];
        lab2.highlightedTextColor = [UIColor whiteColor];
        lab2.text = self.gradeStr;
        lab2.font = [UIFont systemFontOfSize:13];
        lab2.backgroundColor = [UIColor clearColor];
        lab2.tag = 1001;
        [self.view addSubview:lab2];
        [lab2 release];
        
        for (int i = 0; i<=4; i++)
        {
            UIImageView * img1;
            img1 = [[UIImageView alloc] init];
            img1.frame = CGRectMake(85+14*i, 37, 10, 14);
            if (self.grade >= i+1)
            {
                img1.image = [UIImage imageNamed:@"star_01.png"];
            }
            else
                img1.image = [UIImage imageNamed:@"star_02.png"];
            img1.tag = 1001;
            [self.view addSubview:img1];
            [img1 release];
        }
        
        UILabel* lab3;
        lab3 = [[UILabel alloc] initWithFrame:CGRectMake(85, 55, 230, 15)];
        lab3.textColor = [UIColor colorWithRed:(130.0/255) green:(130.0/255) blue:130.0/255 alpha:1.0];
        lab3.highlightedTextColor = [UIColor whiteColor];
        lab3.text = [NSString stringWithFormat:@"专长:%@",self.detail];
        lab3.font = [UIFont systemFontOfSize:13];
        lab3.backgroundColor = [UIColor clearColor];
        lab3.tag = 1001;
        [self.view addSubview:lab3];
        [lab3 release];
        
        UIImageView * img1;
        img1 = [[UIImageView alloc] init];
        img1.frame = CGRectMake(12, 12, 59, 59);
        img1.image = [UIImage imageNamed:@"list_avatar.png"];
        img1.tag = 1001;
        [self.view addSubview:img1];
        [img1 release];
        
        UIImageView * img2;
        img2 = [[UIImageView alloc] init];
        img2.frame = CGRectMake(15, 15, 53, 53);
        img2.image = [UIImage imageNamed:self.path];
        img2.tag = 1001;
        [self.view addSubview:img2];
        [img2 release];
        
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
