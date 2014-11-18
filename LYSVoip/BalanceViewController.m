//
//  RemainViewController.m
//  LYSVoip
//
//  Created by Ge-Yunsheng on 2014/11/07.
//  Copyright (c) 2014年 atjava. All rights reserved.
//

#import "BalanceViewController.h"
#import "ASIFormDataRequest.h"
#import "TFHpple.h"

@interface BalanceViewController ()

@end

@implementation BalanceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadView
{
    self.title = @"余额明细";
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation.png"] forBarMetrics:0];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    UIButton *background = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [background addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:background];
    [background release];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigation.png"]];
    imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, 70.0f);
    [self.view addSubview:imageView];
    [imageView release];
    
    UILabel *labelBalance = [[UILabel alloc]initWithFrame:CGRectMake(20.0f, 5.0f, 200.0f, 30.0f)];
    self.labelSum = labelBalance;
    labelBalance.textColor = [UIColor blackColor];
    [labelBalance setTextAlignment:NSTextAlignmentLeft];
    [imageView addSubview:labelBalance];
    [labelBalance release];
    
    UILabel *labelTime = [[UILabel alloc]initWithFrame:CGRectMake(20.0f, 35.0f, 200.0f, 30.0f)];
    self.labelPhone = labelTime;
    labelTime.textColor = [UIColor blackColor];
    [labelTime setTextAlignment:NSTextAlignmentLeft];
    [imageView addSubview:labelTime];
    [labelTime release];
    
    UILabel *labelInfo = [[UILabel alloc]initWithFrame:CGRectMake(20.0f, 80.0f, 280.0f, 50.0f)];
    labelInfo.textColor = [UIColor blackColor];
    [labelInfo setFont:[UIFont systemFontOfSize:12.0f]];
    labelInfo.text = @"请输入查询通话时间的起止日期，格式YYYYMMDD，如不输入将查询所有历史记录";
    labelInfo.numberOfLines = 0;
    labelInfo.lineBreakMode = UILineBreakModeCharacterWrap;
    [self.view addSubview:labelInfo];
    [labelInfo release];
    
    UITextField *textStart = [[UITextField alloc]initWithFrame:CGRectMake(40.0f, 150.0f, 240.0f, 30.0f)];
    [textStart setBorderStyle:UITextBorderStyleRoundedRect];
    textStart.placeholder = @"开始日期";
    textStart.delegate = self;
    self.textStartTime = textStart;
    [self.view addSubview:textStart];
    [textStart release];
    
    UITextField *textEnd = [[UITextField alloc]initWithFrame:CGRectMake(40.0f, 200.0f, 240.0f, 30.0f)];
    [textEnd setBorderStyle:UITextBorderStyleRoundedRect];
    textEnd.placeholder = @"截止日期";
    textEnd.delegate = self;
    self.textEndTime = textEnd;
    [self.view addSubview:textEnd];
    [textEnd release];
    
    UIButton *search = [UIButton buttonWithType:UIButtonTypeSystem];
    search.frame = CGRectMake(130.0f, 280.0f, 60.0f, 40.0f);
    [search setTitle:@"查询" forState:UIControlStateNormal];
    [search addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:search];
    
    UIDatePicker *picker = [[UIDatePicker alloc]init];
    self.picker = picker;
    [picker setDatePickerMode:UIDatePickerModeDate];
    NSLocale *currentLocal = [NSLocale currentLocale];
    [picker setLocale:currentLocal];
    [picker addTarget:self action:@selector(setTime:) forControlEvents:UIControlEventValueChanged];
    [picker release];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textStartTime.inputView = self.picker;
    self.textEndTime.inputView = self.picker;
    
    [self getBalance];
    
}

-(void)setTime:(id)sender
{
    NSDateFormatter* format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMdd"];
    
    if ([self.textStartTime isFirstResponder])
    {
        self.textStartTime.text = [format stringFromDate:[sender date]];
    }
    else if ([self.textEndTime isFirstResponder])
    {
        self.textEndTime.text = [format stringFromDate:[sender date]];
    }
    
}

- (void)doSearch
{
    [self getBalance];
}

-(void)getBalance
{
    NSString* urlString = [[NSString alloc]initWithFormat:@"http://voip.atjava.com/voip_accounBtalance_request.php?voipaccount=%@&amp;datefrom=%@&dateto=%@",self.userBasic.voipId,self.textStartTime.text,self.textEndTime.text];
    
    /*************************************dummy*****************************************/
//    NSString* urlString = [[NSString alloc]initWithFormat:@"http://voip.atjava.com/voip_accounBtalance_request.php?voipaccount=82325700000033&amp;datefrom=%@&dateto=%@",self.textStartTime.text,self.textEndTime.text];
    
    ASIFormDataRequest* _request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    [_request setDelegate:self];
    [_request setDidFinishSelector:@selector(getSucceed:)];
    [_request setDidFailSelector:@selector(fail:)];
    [_request startAsynchronous];
}

-(void)getSucceed:(ASIHTTPRequest *)request
{
    NSData *data =[request responseData];
    
    TFHpple* xpathParser = [[TFHpple alloc] initWithXMLData:data];
    NSArray* ststus  = [xpathParser searchWithXPathQuery:@"//status"];
    NSString* strStatus = [[[[ststus objectAtIndex:0] children] objectAtIndex:0] content];
    
    if ([strStatus isEqualToString:@"success"])
    {
        NSArray* sum  = [xpathParser searchWithXPathQuery:@"//sum"];
        NSString* strSum = [[[[sum objectAtIndex:0] children] objectAtIndex:0] content];
        NSString* sumValue = [[NSString alloc]initWithFormat:@"当月剩余通话时间: %@分钟",strSum];
        [self.labelSum setText:sumValue];
        [sumValue release];
        
        NSArray* item = [xpathParser searchWithXPathQuery:@"//item"];
//        NSLog(@"item count is %d",[item count]);
        if (0 == [item count])
        {
            NSString* timeValue = [[NSString alloc]initWithString:@"通话时间: 0分钟"];
            [self.labelPhone setText:timeValue];
            [timeValue release];
        }
        else
        {
            NSMutableArray* callArray = [NSMutableArray arrayWithCapacity:1];
            NSInteger callTime = 0;
            for (int index = 1; index <= [item count]; index++)
            {
                NSString* str2 = [[[NSString alloc]initWithFormat:@"/result/data/item[%d]/callType",index] autorelease];
                NSArray* arrayCallType = [xpathParser searchWithXPathQuery:str2];
                NSString* callTypeStr = [[[[arrayCallType objectAtIndex:0] children] objectAtIndex:0] content];
                
                NSString* str1 = [[[NSString alloc]initWithFormat:@"/result/data/item[%d]/callTimeSecond",index] autorelease];
                NSArray* arrayCallTime = [xpathParser searchWithXPathQuery:str1];
                NSString* callTimeStr = [[[[arrayCallTime objectAtIndex:0] children] objectAtIndex:0] content];
                
                if (0 == [callTypeStr integerValue])
                {
                    callTime = [callTimeStr integerValue];
                }
                else if (1 == [callTypeStr integerValue])
                {
                    callTime = 2 * [callTimeStr integerValue];
                }
                
                if ((callTime % 60) > 0)
                {
                    callTime = callTime/60 + 1;
                }
                else
                {
                    callTime = callTime/60;
                }
                
                [callArray addObject:[NSNumber numberWithInt:callTime]];
                callTime = 0;
            }
            for (NSNumber* obj in callArray)
            {
                callTime += [obj intValue];
            }
            
            NSString* phoneValue = [[NSString alloc]initWithFormat:@"通话时间: %d分钟",callTime];
            [self.labelPhone setText:phoneValue];
            [phoneValue release];
            
        }
        
        
    }
    else if ([strStatus isEqualToString:@"request error"])
    {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:@"request error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }

}

-(void)fail:(ASIHTTPRequest *)request
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Fail" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideKeyboard
{
    for (UIView* view in self.view.subviews)
    {
        if ([view isKindOfClass:[UITextField class]])
        {
            [view resignFirstResponder];
        }
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    
    int offset = (frame.origin.y + frame.size.height) - (self.view.frame.size.height - 216.0) + 10;//键盘高度216,空余高度10
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    if(offset > 0)
    {
        self.view.frame = CGRectMake(0.0f, 64 - offset, self.view.frame.size.width, self.view.frame.size.height);//64是导航栏和状态栏高度
    }
    [UIView commitAnimations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame =CGRectMake(0, 64.0f, self.view.frame.size.width, self.view.frame.size.height);
}
@end
