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

#import "UIBaseViewController.h"
#import "AppDelegate.h"
#import "VoipIncomingViewController.h"
#import "VideoViewController.h"
#import "CommonClass.h"
#import <QuartzCore/QuartzCore.h>
//#import "RegisterViewController.h"

#import "SelectPhoneNOViewController.h"
#import "MultiChooseContactsViewController.h"
BOOL globalisVoipView=NO;   //电话界面是否存在
@interface UIBaseViewController()<SelectPhoneNODelegate,ChooseMultiPhonesDelegate>
@property (nonatomic, retain) UIView *progressingView;
@end


@implementation UIBaseViewController

@synthesize modelEngineVoip;
@synthesize voipCallID;
@synthesize imagePicker;
@synthesize messageCompose;
@synthesize viewActionSheet;
@synthesize progressingView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) 
    {
        // Custom initialization
    } 
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    self.progressingView = nil;
    self.modelEngineVoip = nil;
    self.messageCompose = nil;
    self.voipCallID = nil;
    self.imagePicker = nil;
    self.viewActionSheet = nil;
    self.contactsUI = nil;
    [super dealloc];
}

-(id)init
{
    self = [super init];
    
    if (self)
    {
         self.modelEngineVoip = [ModelEngineVoip getInstance];   
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    popTipView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"sms_tip_bg.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15]];
    popTipView .alpha = 0.0f;    
    popLabel = [[UILabel alloc] init];
    popLabel.alpha = 0.0f;
    [popTipView addSubview:popLabel];
    [popLabel release];
    [self.view addSubview:popTipView];
    [popTipView release];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)gotoIncomingCallView:(NSTimer*)theTimer
{
    UIViewController* incomingCallView = (UIViewController*)theTimer.userInfo;
    if (globalisVoipView)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(gotoIncomingCallView:) userInfo:incomingCallView repeats:NO];
    }
    else
    {
        if (self.imagePicker)
        {
            //弹出系统的图片或者拍照界面后，来电的显示
            [self.imagePicker presentModalViewController:incomingCallView animated:YES];
        }
        else if (self.messageCompose)
        {
            //弹出系统的短信界面后，来电的显示
            [self.messageCompose presentModalViewController:incomingCallView animated:YES];
        }
        else if (self.contactsUI)
        {
            //弹出系统的联系人页面后，来电的显示
            [self.contactsUI presentModalViewController:incomingCallView animated:YES];
        }
        else
        {
            [self presentModalViewController:incomingCallView animated:YES];
        }
        [incomingCallView release];
    }
}

#pragma mark - ModelEngineUIDelegate
-(void)incomingCallID:(NSString *)callid caller:(NSString*)caller phone:(NSString *)phone name:(NSString *)name callStatus:(int)status callType:(NSInteger)calltype
{
    UIViewController *incomingCallView = nil;
    if (calltype == EVoipCallType_Video)
    {
        VideoViewController *incomingVideoView = [[VideoViewController alloc] initWithCallerName:name andVoipNo:caller andCallstatus:1];
        incomingVideoView.callID = callid;
        incomingCallView = incomingVideoView;
    }
    else
    {
        VoipIncomingViewController* incomingVoiplView = [[VoipIncomingViewController alloc] initWithName:name andPhoneNO:phone andCallID:callid andParent:self];
        incomingVoiplView.contactVoip = caller;
        incomingVoiplView.status = status;
        incomingCallView = incomingVoiplView;
    }
    
    if (globalisVoipView)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(gotoIncomingCallView:) userInfo:incomingCallView repeats:NO];
    }
    else
    {
        if (self.imagePicker)
        {
            //系统相册界面或者拍照界面
            [self.imagePicker presentModalViewController:incomingCallView animated:YES];
        }
        else if (self.messageCompose)
        {
            //系统短信界面
            [self.messageCompose presentModalViewController:incomingCallView animated:YES];
        }
        else if (self.contactsUI)
        {
            //弹出系统的联系人页面后，来电的显示
            [self.contactsUI presentModalViewController:incomingCallView animated:YES];
        }
        else
        {
            [self presentModalViewController:incomingCallView animated:YES];
        }
        [incomingCallView release];
    }
}

- (void)responseNetworkStatus:(ENetworkStatusResult)event data:(NSString *)data
{
    if (event == ENetworkStatus_NONE)
    {
        [self  popPromptViewWithMsg:@"当前无网络，请稍后再试！" AndFrame:CGRectMake(0, 160, 320, 30)];
    }
}

- (void)responseVoipManagerStatus:(ECallStatusResult)event callID:(NSString *)callid data:(NSString *)data
{
    switch (event)
	{
        case ECallStatus_CallBack:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"回拨呼叫成功" message:@"请注意接听系统来电（可能是未知号码），接听后与对方进行通话" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            [alertView release];
        }
            break;
        case ECallStatus_CallBackFailed:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"回拨呼叫失败" message:@"回拨呼叫失败，请稍后再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            [alertView release];
        }
            break;
        default:
            break;
    }
}

//账号在其他客户端登录消息提示
-(void)responseKickedOff
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"下线提示" message:@"该账号在其他设备登录，你已经下线。" delegate:nil cancelButtonTitle:@"重新登录" otherButtonTitles: @"退出",nil];
    alertView.delegate = self;
    alertView.tag = kKickedOff;
    [alertView show];
    [alertView release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kKickedOff)
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
}
-(void)onTestUdpNetSucceedCount:(NSInteger)count{
    if (count < 700)
    {
        double lostRate = (1000-count) / 10.f;
        NSString* strLostRate = [NSString stringWithFormat:@"网络质量差，丢包率%0.1f%%",lostRate];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络质量提示"message: strLostRate  delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    }
}
- (void)responseMessageStatus:(EMessageStatusResult)event callNumber:(NSString *)callNumber data:(NSString *)data
{
    switch (event)
	{
        case EMessageStatus_Received:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"短消息(%@)",callNumber] message:data delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            [alertView release];
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

//系统的短信,相册或者拍照界面的来电后消失的处理
#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MessageComposeResultCancelled:
        {
            [theAppDelegate printLog:@"Result: canceled"];
        }
            break;
        case MessageComposeResultSent:
        {
            [theAppDelegate printLog:@"Result: Sent"];
        }
            break;
        case MessageComposeResultFailed:
        {
            [theAppDelegate printLog:@"Result: Failed"];
        }
            break;
        default:
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];	
    self.messageCompose = nil;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
    self.imagePicker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
    self.imagePicker = nil;
}

-(void)popPromptViewWithMsg:(NSString *)message
{
    [self  popPromptViewWithMsg:message AndFrame:CGRectMake(0, 160, 320, 30)];
}
-(void)popPromptViewWithNewMsg:(NSString *)message
{
    [self  popPromptViewWithMsg:message AndFrame:CGRectMake(0, 410, 320, 30)];
}
-(void)popPromptViewWithMsg:(NSString*)message AndFrame: (CGRect)frame {
    [self popPromptViewWithMsg:message AndFrame:frame andDuration:3.0f];
}

-(void)popPromptViewWithMsg:(NSString*)message AndFrame: (CGRect)frame andDuration:(NSTimeInterval)duration
{
    UIFont* font = [UIFont systemFontOfSize:14.0f];
    CGSize size = [message sizeWithFont:font constrainedToSize:CGSizeMake(frame.size.width, 200.0f) lineBreakMode:UILineBreakModeCharacterWrap];
    [self.view bringSubviewToFront:popTipView];
    popTipView.frame = CGRectMake((300-size.width)*0.5 ,frame.origin.y , size.width+20 ,size.height+30);
    popLabel.backgroundColor = [UIColor clearColor];
    popLabel.textColor = [UIColor whiteColor];
    popLabel.textAlignment = UITextAlignmentCenter;
    popLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    popLabel.font = font;
    popLabel.numberOfLines = 0;
    popLabel.text = message;
    popLabel.frame = CGRectMake(10, 15, size.width, size.height);
    
    popLabel.alpha = 1.0f;
    popTipView.alpha = 1.0f;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: duration];
    
    popTipView.alpha = 0.0f;
    
    [UIView commitAnimations];
}

//进行中的view操作
- (void)displayProgressingView
{
    if (self.progressingView == nil)
    {
        UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
        tmpView.backgroundColor = [UIColor clearColor];
        
        UIView* centerView = [[UIView alloc] initWithFrame:CGRectMake(110, 220, 100, 100)];
        centerView.layer.cornerRadius = 6;
        centerView.layer.masksToBounds = YES;
        centerView.backgroundColor = [UIColor blackColor];
        centerView.alpha = 0.8;
        [tmpView addSubview:centerView];
        
        UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        aiv.center = CGPointMake(50, 50);
        [aiv startAnimating];
        
        [centerView addSubview:aiv];
        [aiv release];
        
        [centerView release];
        
        self.progressingView = tmpView;
        [self.navigationController.view addSubview:tmpView];
        [tmpView release];
    }
    
    [self.navigationController.view bringSubviewToFront:self.progressingView];
}

- (void)dismissProgressingView
{
    [self.navigationController.view  sendSubviewToBack:self.progressingView];
}

- (void)popToPreView
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)onGroupModifyGroupWithReason:(CloopenReason*)reason
{
    if (reason.reason == 0)
    {
        
    }
    else
    {
        [self popPromptViewWithMsg:[NSString stringWithFormat:@"修改群组信息失败。错误码：%d,错误详情：%@",reason.reason,reason.msg]];
    }
}

- (UIImage *) createImageWithColor: (UIColor *) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(void)getPhoneNumber:(NSString *)phoneNumber
{

}

-(void)getPhoneNumbers:(NSArray *)phoneNumbers
{
    
}

-(void)goChoosePhoneNumber
{
    if ([self isContactsAccessGranted])
    {
        SelectPhoneNOViewController* view = [[SelectPhoneNOViewController alloc] init];
        view.delegate = self;
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
}

-(void)goChooseMultiPhoneNumbers
{
    if ([self isContactsAccessGranted])
    {
        MultiChooseContactsViewController* view = [[MultiChooseContactsViewController alloc] init];
        view.delegate = self;
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
}


- (BOOL)isContactsAccessGranted
{
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.0)
    {
        ABAddressBookRef addressbookSave = ABAddressBookCreate();
        @try
        {
            if (!accessAddressBook(addressbookSave))
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您好，因iOS系统隐私权限控制，通讯录部分功能不能正常使用，需要进入“系统设置--隐私--通讯录”开启通讯录访问权限后才能使用。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                return NO;
            }
        }
        @finally
        {
            if (addressbookSave)
                CFRelease(addressbookSave);
        }
    }
    return YES;
}


@end
