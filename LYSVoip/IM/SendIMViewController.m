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

#import "SendIMViewController.h"
#import "HPGrowingTextView.h"
#import "IMMsgDBAccess.h"
#import "GroupInfoViewController.h"
#import "UICustomView.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>
#define EXPRESSION_BTN_TAG  99
#define ATTACH_BTN_TAG  100
#define VOICE_BTN_TAG   101
#define VIDEO_BTN_TAG   102

#define EXPRESSION_SCROLL_VIEW_TAG 102

#define CONTAINER_VIEW_DISPLAY_HEIGHT 45.0f

#define R_CONTENT_FONT_SIZE 15.0f
#define R_CONTENT_WIDTH 220.0f

#define S_CONTENT_FONT_SIZE 13.0f
#define S_CONTENT_WIDTH 180.0f

@interface SendIMViewController ()
{
    HPGrowingTextView   *textView;
    NSInteger isGroupMsg;
    BOOL isChunk;
    UIPageControl *pageCtrl;
    UIScrollView  *pageScroll;
    BOOL isLoud;
}
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) NSArray *chatArray;
@property (nonatomic, retain) NSString *receiver;
@property (nonatomic, retain) NSString *sendPath;
@property (nonatomic, retain) IMMessageObj *resendMsgObj;
@property (nonatomic, retain) UIView *expressionView;
@end

@implementation SendIMViewController
@synthesize curImg;
@synthesize groupID;
@synthesize curRecordFile;
@synthesize table;
@synthesize popView;
@synthesize ivPopImg;
@synthesize imgArray;
@synthesize curVoiceSid;
@synthesize backView;
@synthesize recordTimer;
@synthesize sendPath;
@synthesize resendMsgObj;
@synthesize expressionView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithReceiver:(NSString*)rec
{
    self = [super init];
    if (self)
    {
        self.receiver = rec;
    }
    return self;
}

#pragma mark - LoadView
- (void)loadView
{
    isLoud = YES;
    isGroupMsg = 0;
    isPlaying = NO;
    UIView* selfview = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    selfview.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    self.view = selfview;
    [selfview release];
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToBackView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    SEL rightSel = nil;
    NSString *rightTitle = nil;
    if ([self isGroupMsg])
    {
        rightSel = @selector(management);
        rightTitle = @"管理";
    }
    else
    {
        self.title = self.receiver;
        rightSel = @selector(clearMessage);
        rightTitle = @"清除";
    }
    
    UIBarButtonItem *clearMessage=[[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:rightTitle target:self action:rightSel]];
    self.navigationItem.rightBarButtonItem = clearMessage;
    [clearMessage release];
    
    UITableView* tableView = nil;
    if (IPHONE5)
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 578.f-44.f-75.f-20.f) style:UITableViewStylePlain];
    }
    else
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 376-35) style:UITableViewStylePlain];
    }
    
    self.table = tableView;
    self.table.allowsSelection = YES;
    self.table.allowsSelectionDuringEditing = YES;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    tableView.tableFooterView = [[[UIView alloc] init] autorelease];
    [self.view addSubview:tableView];
    [tableView release];
        
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-35.0f-40.0f, 320, 40.0f+35.0f)];
    self.containerView = view;
    self.containerView.backgroundColor = [UIColor colorWithRed:225.0f/255.0f green:225.0f/255.0f blue:225.0f/255.0f alpha:1.0f];
    [self.view addSubview:view];
    [view release];
        
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(5.0f, 7.0f, 220.0f, 27.0f)];
    textView.contentInset = UIEdgeInsetsMake(-2, 5, -2, 5);
    textView.backgroundColor = [UIColor whiteColor];
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 4;
    textView.returnKeyType = UIReturnKeyDefault;
    textView.font = [UIFont systemFontOfSize:12.0f];
    textView.delegate = self;
    textView.placeholder = @"添加文本";
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.containerView addSubview:textView];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(237.0f,  8.0f, 73.0f, 27.0f);
    sendBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"talk_send_button_off.png"] forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"talk_send_button_on.png"] forState:UIControlStateHighlighted];
    [self.containerView addSubview:sendBtn];
    
    UIButton *expressionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    expressionBtn.tag = EXPRESSION_BTN_TAG;
    expressionBtn.frame = CGRectMake(0.0f, 45.0f, 80, 30.0f);
    expressionBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [expressionBtn setBackgroundImage:[UIImage imageNamed:@"facial_expression_icon.png"] forState:UIControlStateNormal];
    [expressionBtn setBackgroundImage:[UIImage imageNamed:@"facial_expression_icon_on.png"] forState:UIControlStateHighlighted];
    [expressionBtn addTarget:self action:@selector(additionFunction:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:expressionBtn];
    
    UIButton *videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    videoBtn.tag = VIDEO_BTN_TAG;
    videoBtn.frame = CGRectMake(80, 45.0f, 80, 30.0f);
    videoBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [videoBtn setBackgroundImage:[UIImage imageNamed:@"IM_video_icon.png"] forState:UIControlStateNormal];
    [videoBtn setBackgroundImage:[UIImage imageNamed:@"IM_video_icon_on.png"] forState:UIControlStateHighlighted];
    [videoBtn addTarget:self action:@selector(additionFunction:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:videoBtn];
    
    UIButton *attachBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    attachBtn.tag = ATTACH_BTN_TAG;
    attachBtn.frame = CGRectMake(160, 45.0f, 80, 30.0f);
    attachBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [attachBtn setBackgroundImage:[UIImage imageNamed:@"file_icon.png"] forState:UIControlStateNormal];
    [attachBtn setBackgroundImage:[UIImage imageNamed:@"file_icon_on.png"] forState:UIControlStateHighlighted];
    [attachBtn addTarget:self action:@selector(additionFunction:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:attachBtn];
    
    voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceBtn.tag = VOICE_BTN_TAG;
    voiceBtn.frame = CGRectMake(240, 45.0f, 80, 30.0f);
    voiceBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [voiceBtn setBackgroundImage:[UIImage imageNamed:@"IM_voice_icon.png"] forState:UIControlStateNormal];
    [voiceBtn setBackgroundImage:[UIImage imageNamed:@"IM_voice_icon_on.png"] forState:UIControlStateHighlighted];
    [voiceBtn addTarget:self action:@selector(additionFunction:) forControlEvents:UIControlEventTouchUpInside];

    [voiceBtn addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchDown];
    [voiceBtn addTarget:self action:@selector(recordCancel) forControlEvents:UIControlEventTouchUpOutside];
    [voiceBtn addTarget:self action:@selector(stopSelfRecording) forControlEvents:UIControlEventTouchUpInside];
    [voiceBtn addTarget:self action:@selector(touchOutside) forControlEvents:(UIControlEventTouchDragOutside)];
    [voiceBtn addTarget:self action:@selector(touchInside) forControlEvents:(UIControlEventTouchDragInside)];    
    
    [self.containerView addSubview:voiceBtn];
    
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    UIView* viewPop = [[UIView alloc] initWithFrame:CGRectMake(90, self.view.frame.size.height-35.0f-40.0f- 200, 139, 139)];
    UIImageView* ivPhoneIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 139, 139)];
    ivPhoneIcon.image = [UIImage imageNamed:@"message_interphone_bg.png"];
    [viewPop addSubview:ivPhoneIcon];
    [ivPhoneIcon release];
    
    UIImageView* imgViewPop = [[UIImageView alloc] init];
    imgViewPop.frame  = CGRectMake(100, 55, 23, 53);
    imgViewPop.contentMode = UIViewContentModeBottom;
    [viewPop addSubview:imgViewPop];
    self.ivPopImg = imgViewPop;
    [imgViewPop release];
    
    viewPop.hidden = NO;
    [self.view addSubview:viewPop];
    self.popView = viewPop;
    [viewPop release];
    
    NSMutableArray * arr = [[NSMutableArray alloc] initWithCapacity:6];
    for (int i = 0;i <= 5; i++)
    {
        UIImage * img =[UIImage imageNamed:[NSString stringWithFormat:@"message_interphone%02d.png",i+1]];
        [arr addObject:img];
    }
    self.imgArray = arr;
    [arr release];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopRecMsg];
    self.popView.hidden = YES;
}


#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return 1;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    return self.displayPhoto;
}

#pragma mark - ViewControllerDelegate
- (void)dealloc
{
    [textView release];
    self.sendPath = nil;
    self.containerView = nil;
    self.expressionView = nil;
    self.table = nil;
    self.receiver = nil;
    self.displayPhoto = nil;
    self.curImg = nil;
    self.groupID = nil;
    self.curRecordFile = nil;
    self.popView = nil;
    self.ivPopImg = nil;
    self.imgArray = nil;
    self.curVoiceSid = nil;
    self.backView = nil;
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    self.resendMsgObj = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.displayPhoto = nil;
    
    NSInteger flag = [[NSUserDefaults standardUserDefaults] integerForKey:VOICE_CHUNKED_SEND_KEY];
    if (flag == -1)
    {
        isChunk = NO;
    }
    else
    {
        isChunk = YES;
    }
    
    self.popView.hidden = YES;
    self.modelEngineVoip.UIDelegate = self;
    [self.modelEngineVoip.imDBAccess updateUnreadStateOfSessionId:self.receiver];
    self.chatArray = [self.modelEngineVoip.imDBAccess getMessageOfSessionId:self.receiver];
    if ([self isGroupMsg])
    {
        [self.modelEngineVoip queryGroupDetailWithGroupId:self.receiver];
    }
    [self.table reloadData];
    [self addNotification];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self removeNotification];
    [self.modelEngineVoip.imDBAccess updateUnreadStateOfSessionId:self.receiver];
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
-(BOOL)isGroupMsg
{
    if (isGroupMsg == 0)
    {
        NSString *g = [self.receiver substringToIndex:1];
        if ([g isEqualToString:@"g"])
        {
            isGroupMsg = 100;
        }
        else
        {
            isGroupMsg = -100;
        }
    }
    
    if (isGroupMsg == 100)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)goToGroupInfoView
{
    [self stopRecMsg];
    [self recordCancel];
    GroupInfoViewController *view = [[GroupInfoViewController alloc] initWithGroupId:self.receiver andIsMyJoin:YES andPermission:0];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

-(void)popToBackView
{
    [self recordCancel];
    [self stopRecMsg];
    [self.navigationController popToViewController:self.backView animated:YES];
}

- (void)clearMessage
{
    [self stopRecMsg];
    [self stopSelfRecording];
    [self displayProgressingView];
    NSArray* arr = [self.modelEngineVoip.imDBAccess getAllFilePathOfSessionId:self.receiver];
    [self.modelEngineVoip deleteFileWithPathArr:arr];
    [self.modelEngineVoip.imDBAccess deleteMessageOfSessionId:self.receiver];
    [self dismissProgressingView];
    self.chatArray = [self.modelEngineVoip.imDBAccess getMessageOfSessionId:self.receiver];
    [self.table reloadData];
}

- (CGFloat)getCellHeightWithMsg:(IMMessageObj*)msg
{
    CGFloat heigt = 80.0f;
    if (msg.msgtype == EMessageType_Text && (msg.imState == EMessageState_SendSuccess || msg.imState == EMessageState_SendFailed || msg.imState == EMessageState_Sending || msg.imState == EMessageState_Send_OtherReceived))
    {
        CGSize size = [msg.content sizeWithFont:[UIFont systemFontOfSize:S_CONTENT_FONT_SIZE] constrainedToSize:CGSizeMake(S_CONTENT_WIDTH, 5000.0f) lineBreakMode:UILineBreakModeCharacterWrap];
        heigt = size.height + 50.0f;
    }
    else if (msg.msgtype == EMessageType_Text && msg.imState == EMessageState_Received)
    {
        CGSize size = [msg.content sizeWithFont:[UIFont systemFontOfSize:R_CONTENT_FONT_SIZE] constrainedToSize:CGSizeMake(R_CONTENT_WIDTH, 5000.0f) lineBreakMode:UILineBreakModeCharacterWrap];
        heigt = size.height + 50.0f;
    }
    else if (msg.msgtype == EMessageType_File && (msg.imState == EMessageState_SendSuccess || msg.imState == EMessageState_SendFailed || msg.imState == EMessageState_Sending || msg.imState == EMessageState_Send_OtherReceived || msg.imState == EMessageState_Received))
    {
        if ([msg.fileExt isEqualToString:@"mp4"])
        {
            if (msg.imState == EMessageState_Received)
                heigt = 260.0f;
            else
                heigt = 250;
        }
        else if (msg.imState == EMessageState_Received)
            heigt = 80.0f;
        else
            heigt = 70.0f;
    }
    return heigt;
}

-(void)sendMessage:(id)sender
{
    [self stopRecMsg];
    if (textView.text.length < 1)
    {
        return;
    }
    
    IMMessageObj *msg = [[IMMessageObj alloc] init];
    msg.content = textView.text;
    msg.sessionId = self.receiver;
    msg.msgtype = EMessageType_Text;
    msg.isRead = EReadState_IsRead;
    msg.imState = EMessageState_Sending;
    
    NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *curTimeStr = [dateformatter stringFromDate:[NSDate date]];
    [dateformatter release];
    msg.curDate = curTimeStr;
    
    NSString* cid = [self.modelEngineVoip sendInstanceMessage:self.receiver andText:textView.text andAttached:nil andUserdata:nil];
    if (cid.length > 0)
    {
        msg.msgid = cid;
        [self.modelEngineVoip.imDBAccess insertIMMessage:msg];
    }
    [msg release];
    
    textView.text = @"";
    
    self.chatArray = [self.modelEngineVoip.imDBAccess getMessageOfSessionId:self.receiver];
    [self.table reloadData];
    
    if([self.chatArray count]>0)
		[self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)additionFunction:(id)sender
{
    [self stopRecMsg];
    UIButton *btn = (UIButton*)sender;
    if (btn.tag == ATTACH_BTN_TAG)
    {
        if (recordState != ERecordState_Origin) {
            return;
        }
        UIActionSheet *menu;
        menu = [[UIActionSheet alloc]
                initWithTitle:nil
                delegate:self
                cancelButtonTitle:@"取消"
                destructiveButtonTitle:nil
                otherButtonTitles: @"相册图片", @"拍照", nil];
        menu.tag = 9999;
        [menu showInView:self.view.window];
        self.viewActionSheet = menu;
        [menu release];
    }
    else if (btn.tag == VIDEO_BTN_TAG)
    {
        if (recordState != ERecordState_Origin) {
            return;
        }
        UIActionSheet *menu;
        menu = [[UIActionSheet alloc]
                initWithTitle:nil
                delegate:self
                cancelButtonTitle:@"取消"
                destructiveButtonTitle:nil
                otherButtonTitles: @"相册视频", @"拍摄视频", nil];
        menu.tag = 9998;
        [menu showInView:self.view.window];
        self.viewActionSheet = menu;
        [menu release];
    }
    else if (btn.tag == VOICE_BTN_TAG)
    {
    
    }
    else if (btn.tag == EXPRESSION_BTN_TAG)
    {
        [self showExpressionView];
    }
}

- (void)resendMsg:(id)sender
{
    UIButton *senderbtn = (UIButton*)sender;
    self.resendMsgObj = [self.chatArray objectAtIndex:senderbtn.tag-2000];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"重复消息"
                                                    message:@"要重发该消息吗？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定",nil];
    alert.tag = 500;
    [alert show];
    [alert release];
}


-(void)putExpress:(id)sender{
	
	UIButton *button_tag = (UIButton *)sender;
	textView.text =  [textView.text stringByAppendingString:
                      [CommonTools getExpressionStrById:button_tag.tag]];
}

- (void)backspaceText:(id)sender{
    if (textView.text.length > 0)
    {
        textView.text = [textView.text substringToIndex:textView.text.length-1];
    }
}
- (void)creatExpressionView
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320.0f, 216.0f)];
    self.expressionView = view;
    [self.view addSubview:view];
    [view release];

    NSInteger pageCount = 7;
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    scrollView.tag = EXPRESSION_SCROLL_VIEW_TAG;
    pageScroll = scrollView;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*pageCount, scrollView.frame.size.height);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;    
    scrollView.backgroundColor = [UIColor colorWithRed:209.0f/255.0f green:212.0f/255.0f blue:214.0f/255.0f alpha:1.0f];
    
    int row = 4;
    int column = 7;
    int number = 0;
    for (int p=0; p<pageCount; p++)
    {
        NSInteger page_X = p*scrollView.frame.size.width;
        for (int j=0; j<row; j++)
        {
            NSInteger row_y = 15+50*j;
            for (int i=0; i<column; i++)
            {
                NSInteger column_x = 20+40*i;
                if (number > 170)
                {
                    break;
                }
                
                if (j!=row-1 || i!=column-1)
                {
                    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(page_X+column_x, row_y, 40.0f, 40.0f)];
                    btn.tag = number;
                    btn.backgroundColor = [UIColor clearColor];
                    btn.titleLabel.font = [UIFont systemFontOfSize:20.0f];
                    [btn setTitle:[CommonTools getExpressionStrById:number] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(putExpress:) forControlEvents:UIControlEventTouchUpInside];
                    [scrollView addSubview:btn];
                    [btn release];
                    number++;
                }
            }
        }
        
        UIButton* delBtn = [[UIButton alloc] initWithFrame:CGRectMake(page_X+260.0f, 165.0f, 40.0f, 40.0f)];
        delBtn.backgroundColor = [UIColor clearColor];
        [delBtn setBackgroundImage:[UIImage imageNamed:@"aio_face_delete_pressed.png"] forState:UIControlStateHighlighted];
        [delBtn setBackgroundImage:[UIImage imageNamed:@"aio_face_delete.png"] forState:UIControlStateNormal];
        [delBtn addTarget:self action:@selector(backspaceText:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:delBtn];
        [delBtn release];
    }

    [self.expressionView addSubview:scrollView];
    [scrollView release];
    
    UIPageControl *pageView = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.expressionView.frame.size.height-20.0f, 320.0f, 20.0f)];
    pageView.numberOfPages = pageCount;
    pageView.currentPage = 0;
    [pageView addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    pageCtrl = pageView;
    [self.expressionView addSubview:pageView];
    [pageView release];
}

- (void)showExpressionView
{
    if (self.expressionView == nil)
    {
        [self creatExpressionView];
    }
    
    CGRect expressionFrame = self.expressionView.frame;
    
    CGRect containerFrame = self.containerView.frame;    
    containerFrame.origin.y = self.view.bounds.size.height - (expressionFrame.size.height + CONTAINER_VIEW_DISPLAY_HEIGHT);
    
    expressionFrame.origin.y = self.view.bounds.size.height - expressionFrame.size.height;
    
    //animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    //set views with new info
    self.containerView.frame = containerFrame;
    self.expressionView.frame = expressionFrame;
    self.table.frame = CGRectMake(0.0f, 0.0f, 320.0f, containerFrame.origin.y);
    
    //commit animations
    [UIView commitAnimations];
    
    if([self.chatArray count]>0)
		[self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}

- (void)hideExpressionView
{
    CGRect containerFrame = self.containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    CGRect expressionFrame = self.expressionView.frame;
    expressionFrame.origin.y = self.view.bounds.size.height;
    
    //animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.3];
    
    //set view with new info
    self.containerView.frame = containerFrame;
    self.expressionView.frame = expressionFrame;
    self.table.frame = CGRectMake(0.0f, 0.0f, 320.0f, containerFrame.origin.y);
    
    //commit animations
    [UIView commitAnimations];
}
#pragma mark - UIActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == actionSheet.cancelButtonIndex )
    {
        return;
    }
    if (actionSheet.tag == 9999)
    {
        switch ( buttonIndex )
        {
            case 0:     //相册图片
            {
                isSavedToAlbum = NO;
                UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
                ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
                ipc.delegate = self;
                ipc.allowsEditing = YES;
                self.imagePicker = ipc;
                [self presentModalViewController:ipc animated:YES];
                [ipc release];
            }
                break;
            case 1:     //拍照
            {
                if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] )  //判断设备是否支持拍照功能
                {
                    isSavedToAlbum = YES;
                    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
                    ipc.sourceType =  UIImagePickerControllerSourceTypeCamera;
                    ipc.delegate = self;
                    ipc.allowsEditing = YES;
                    self.imagePicker = ipc;
                    [self presentModalViewController:ipc animated:YES];
                    [ipc release];
                }
                else
                {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该设备不支持拍照功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    alert.tag = 9999;
                    [alert show];
                    [alert release];
                }
            }
                break;
            default:
                break;
        }
    }
    else
    {
        switch ( buttonIndex )
        {
            case 0:     //相册视频
            {
                isSavedToAlbum = NO;
                UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
                ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                ipc.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeMovie];
                ipc.delegate = self;
                ipc.allowsEditing = YES;
                ipc.videoMaximumDuration = 30;
                self.imagePicker = ipc;
                [self presentModalViewController:ipc animated:YES];
                [ipc release];
            }
                break;
            case 1:     //拍视频
            {
                isSavedToAlbum = YES;
                if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] )  //判断设备是否支持拍照功能
                {
                    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
                    ipc.sourceType =  UIImagePickerControllerSourceTypeCamera;
                    ipc.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeMovie];
                    ipc.delegate = self;
                    ipc.videoMaximumDuration = 30;
                    ipc.allowsEditing = YES;
                    self.imagePicker = ipc;
                    [self presentModalViewController:ipc animated:YES];
                    [ipc release];
                }
                else
                {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该设备不支持拍摄功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    alert.tag = 9998;
                    [alert show];
                    [alert release];
                }
            }
                break;
            default:
                break;
        }
    }
}


#pragma mark Camera View Delegate Methods
//3.x  用户选中图片后的回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    @try
    {
        [self dismissModalViewControllerAnimated:NO];
        UIImage* imageSource = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSURL *fileUrl = info[UIImagePickerControllerMediaURL];
        NSString* strFilename = nil;
        
        if (imageSource)
        {
            if ( isSavedToAlbum )
                UIImageWriteToSavedPhotosAlbum(imageSource, nil, nil, nil );
            strFilename = [self saveToDocment:imageSource];
            [self addIMWithFilename:strFilename];
        }
        else if (fileUrl)
        {
            if ( isSavedToAlbum )
                UISaveVideoAtPathToSavedPhotosAlbum([fileUrl path], nil, nil, nil);
            [self encodeVideo:fileUrl];
            return;
        }
        else
            return;
        self.imagePicker = nil;
    }
    @catch (NSException *exception)
    {
        [self  popPromptViewWithMsg:@"发送文件失败，请稍后再试！" AndFrame:CGRectMake(0, 160, 320, 30)];
    }
    @finally
    {
        [self performSelector:@selector(reLoadTable) withObject:nil afterDelay:.5];
    }
}
-(void)reLoadTable
{
    [self.table reloadData];
    if([self.chatArray count]>0)
        [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)addIMWithFilename:(NSString*)strFilename
{
    IMMessageObj* imMsg = [[IMMessageObj alloc] init];
    imMsg.filePath = strFilename;
    imMsg.sessionId = self.receiver;
    imMsg.fileExt =  [[strFilename pathExtension] lowercaseString];
    imMsg.imState = EMessageState_Sending;
    imMsg.msgtype = EMessageType_File;
    imMsg.isRead = EReadState_IsRead;
    NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *curTimeStr = [dateformatter stringFromDate:[NSDate date]];
    [dateformatter release];
    imMsg.curDate = curTimeStr;
    
    NSString* msgid = [self.modelEngineVoip sendInstanceMessage:self.receiver andText:nil andAttached:strFilename andUserdata:nil];
    imMsg.msgid = msgid;
    [self.modelEngineVoip.imDBAccess insertIMMessage:imMsg];
    [imMsg release];
    
    self.chatArray = [self.modelEngineVoip.imDBAccess getMessageOfSessionId:self.receiver];
    [self.table reloadData];
    
    if([self.chatArray count]>0)
        [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(UIImage *)getVideoImage:(NSString *)videoURL
{
    NSString* fileNoExtStr = [videoURL stringByDeletingPathExtension];
    NSString* imagePath = [NSString stringWithFormat:@"%@.jpg", fileNoExtStr];
    UIImage * returnImage = [[[UIImage alloc] initWithContentsOfFile:imagePath] autorelease];
    if (returnImage)
    {
        return returnImage;
    }
    AVURLAsset *asset = [[[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil] autorelease];
    AVAssetImageGenerator *gen = [[[AVAssetImageGenerator alloc] initWithAsset:asset] autorelease];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    returnImage = [[[UIImage alloc] initWithCGImage:image] autorelease];
    CGImageRelease(image);
    [UIImageJPEGRepresentation(returnImage, 0.6) writeToFile:imagePath atomically:YES];
    return returnImage;
}
-(void)encodeVideo:(NSURL*)_videoURL
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:_videoURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    NSString* _mp4Path = nil;
    NSString* timeStr = nil;
    if ([compatiblePresets containsObject:AVAssetExportPreset640x480])
        
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPreset640x480];
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
        timeStr = [formater stringFromDate:[NSDate date]];
        _mp4Path = [NSTemporaryDirectory() stringByAppendingFormat:@"%@.mp4", timeStr];
        [formater release];
        exportSession.outputURL = [NSURL fileURLWithPath: _mp4Path];
        exportSession.shouldOptimizeForNetworkUse = YES;
        BOOL isMp4 = NO;
        NSArray *supportedTypeArray=exportSession.supportedFileTypes;
        for (NSString *str in supportedTypeArray)
        {
            NSLog(@"%@",str);
            if ([str isEqualToString:@"public.mpeg-4"])
            {
                isMp4 = YES;
                break;
            }
        }
        if (isMp4)
        {
            exportSession.outputFileType = AVFileTypeMPEG4;
        }
        else
            exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                    message:[[exportSession error] localizedDescription]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles: nil];
                    [alert show];
                    [alert release];
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Successful!");
                    [self getVideoImage:_mp4Path];
                    [self addIMWithFilename: [_mp4Path mutableCopy]];
                    break;
                default:
                    break;
            }
            [exportSession release];
        }];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"压缩视频出错,该设备不支持视频压缩"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

- (UIImage *)fixOrientation:(UIImage *)aImage
{   // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    // Now we draw the underlying CGImage into a new context, applying the transform     // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,CGImageGetBitsPerComponent(aImage.CGImage), 0,CGImageGetColorSpace(aImage.CGImage),CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation)
    {          case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
        CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
        break;
        default:              CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);              break;
    }       // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

-(NSString*)saveToDocment:(UIImage*)image
{
    UIImage* fixImage = [self fixOrientation:image];
	NSDate *date=[NSDate date];
	NSCalendar *calendar=[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSInteger unitFlags=NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
	NSDateComponents *component=[calendar components:unitFlags fromDate:date];
    [calendar release];
    
	int year=[component year];
	int month=[component month];
	int day=[component day];
	int h=[component hour];
	int m=[component minute];
	int s=[component second];
	NSString* fileName=[NSString stringWithFormat:@"%d-%d-%d_%d:%d:%d.jpg",year,month,day,h,m,s];
	NSString*  filePath=[NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    //图片按0.5的质量压缩－》转换为NSData
    NSData *imageData = UIImageJPEGRepresentation(fixImage, 0.5);
	[imageData writeToFile:filePath atomically:YES];
    return filePath;
}

//用户选择取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
    self.imagePicker = nil;
}

-(void) keyboardWillShow:(NSNotification*)note
{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
        CGRect containerFrame = self.containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + CONTAINER_VIEW_DISPLAY_HEIGHT);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    self.containerView.frame = containerFrame;
    self.table.frame = CGRectMake(0.0f, 0.0f, 320.0f, containerFrame.origin.y);
    [UIView commitAnimations];
    
    if([self.chatArray count]>0)
		[self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

-(void) keyboardWillHide:(NSNotification*)note
{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGRect containerFrame = self.containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDuration:[duration doubleValue]];
    self.containerView.frame = containerFrame;
    self.table.frame = CGRectMake(0.0f, 0.0f, 320.0f, containerFrame.origin.y);
    [UIView commitAnimations];
}

#pragma mark - HPGrowingTextView delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.containerView.frame = r;
    CGRect tableFrame = self.table.frame;
    tableFrame.size.height += diff;
    self.table.frame = tableFrame;

    if (self.chatArray.count>0)
    {
        [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.chatArray.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (range.length == 1) {
        return YES;
    }
    
    //NSInteger textLength = textView.text.length;
    //NSInteger replaceLength = text.length;
    if ( ([text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + [textView.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) >= 2001)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"内容最多为2000字节" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av show];
        [av release];
        return NO;
    }
    return YES;
}


-(void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];

}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
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
        return;
    }
    if ( buttonIndex != alertView.cancelButtonIndex )
    {
        if (alertView.tag == 500)
        {
            NSString *msgid = nil;
            NSLog(@"alertView resendMsgObj.msgid=%@", self.resendMsgObj.msgid);
            if (self.resendMsgObj.msgtype == EMessageType_Text)
            {
                msgid = [self.modelEngineVoip sendInstanceMessage:self.receiver andText:self.resendMsgObj.content andAttached:nil andUserdata:self.resendMsgObj.userData];
            }
            else
            {
                msgid = [self.modelEngineVoip sendInstanceMessage:self.receiver andText:nil andAttached:self.resendMsgObj.filePath andUserdata:resendMsgObj.userData];
            }
            
            if (msgid.length > 0)
            {
                NSLog(@"alertView MsgId=%@", msgid);
                [self.modelEngineVoip.imDBAccess updateimState:EMessageState_Sending OfmsgId:self.resendMsgObj.msgid];
                self.resendMsgObj.imState = EMessageState_Sending;
                
                [self.modelEngineVoip.imDBAccess updateNewMsgId:msgid OfOldMsgId:self.resendMsgObj.msgid];
                self.resendMsgObj.msgid = msgid;
                
                [self.table reloadData];
            }
        }
    }    

    self.resendMsgObj = nil;
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.table)
    {
        [textView resignFirstResponder];
        [self hideExpressionView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == EXPRESSION_SCROLL_VIEW_TAG)
    {
        //更新UIPageControl的当前页
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.frame;
        [pageCtrl setCurrentPage:offset.x / bounds.size.width];
    }
}

- (void)pageTurn:(UIPageControl*)sender
{
    //令UIScrollView做出相应的滑动显示
    CGSize viewSize = pageScroll.frame.size;
    CGRect rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
    [pageScroll scrollRectToVisible:rect animated:YES];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMMessageObj *msg = [self.chatArray objectAtIndex:indexPath.row];
    
    return [self getCellHeightWithMsg:msg];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMMessageObj *msg = [self.chatArray objectAtIndex:indexPath.row];
    if (msg.msgtype == EMessageType_File )
    {
        if ([msg.fileExt isEqualToString:@"mp4"])
        {
            MPMoviePlayerViewController* playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", msg.filePath]]];
            NSLog(@"%@",[NSString stringWithFormat:@"file://localhost%@", msg.filePath]);
            [self presentModalViewController:playerView animated:NO];
            [playerView release];
        }
        else
        {
            self.displayPhoto = nil;
            MWPhoto *photo = [[MWPhoto alloc] initWithFilePath:msg.filePath];
            self.displayPhoto = photo;
            [photo release];
            MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
            [photoBrowser release];
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:nc animated:YES];
            [nc release];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
    NSString* strVoipAccount = [self.modelEngineVoip.voipAccount substringFromIndex:10];;
    IMMessageObj *msg = [self.chatArray objectAtIndex:indexPath.row];
    
    if (msg.imState == EMessageState_Received)
    {
        if ([self isGroupMsg])
        {
            cell = [self tableView:tableView cellOfGroupReceiveMsg:msg];
        }
        else
        {
            cell = [self tableView:tableView cellOfP2PReceiveMsg:msg];
        }
        
        strVoipAccount = msg.sender.length>4?([msg.sender substringFromIndex:msg.sender.length-4]):(msg.sender);
        
    }
    else if (msg.msgtype == EMessageType_Text && msg.imState <= EMessageState_Send_OtherReceived) //send text message
    {
        UILabel *contentLabel = nil;
        UILabel *timeLabel = nil;
        static NSString* cellid = @"im_text_s_message_cell_id";
        cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
            cell.contentView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            cell.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            
            UIImageView *lineImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"talk_line.png"]];
            lineImg.frame = CGRectMake(65.0f, 0.0f, 195.0f, 2.0f);
            [cell.contentView addSubview:lineImg];
            [lineImg release];
            
            UILabel *label1 = [[UILabel alloc] init];
            label1.tag = 1001;
            label1.font = [UIFont systemFontOfSize:S_CONTENT_FONT_SIZE];
            label1.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            contentLabel = label1;
            contentLabel.lineBreakMode = UILineBreakModeCharacterWrap;
            contentLabel.numberOfLines = 0;
            [cell.contentView addSubview:label1];
            label1.textColor = [UIColor grayColor];
            [label1 release];
            
            UILabel *label2 = [[UILabel alloc] init];
            label2.textColor = [UIColor grayColor];
            label2.tag = 1002;
            label2.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            timeLabel = label2;
            label2.font = [UIFont systemFontOfSize:12.0f];
            [cell.contentView addSubview:label2];
            [label2 release];            
        }
        else
        {
            contentLabel = (UILabel *)[cell viewWithTag:1001];
            timeLabel = (UILabel *)[cell viewWithTag:1002];
        }
        
        CGSize size = [msg.content sizeWithFont:[UIFont systemFontOfSize:S_CONTENT_FONT_SIZE] constrainedToSize:CGSizeMake(S_CONTENT_WIDTH, 5000.0f) lineBreakMode:UILineBreakModeCharacterWrap];
        contentLabel.frame = CGRectMake(65.0f, 7.0f, size.width, size.height);
        contentLabel.text = msg.content;
        
        timeLabel.frame = CGRectMake(65.0f, 12.0f+size.height, 120.0f, 10.0f);
        timeLabel.text = msg.curDate;
    }
    else  if (msg.msgtype == EMessageType_File)//send attach message
    {
        UILabel *nameLabel = nil;
        UILabel *timeLabel = nil;
        static NSString* cellid = @"im_attach_s_message_cell_id";
        cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
            cell.contentView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            cell.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            UIImageView *attachImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"talk_box_file_icon.png"]];
            attachImg.frame = CGRectMake(65.0f, 7.0f, 19.0f, 18.0f);
            [cell.contentView addSubview:attachImg];
            [attachImg release];
            
            UIImageView *lineImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"talk_line.png"]];
            lineImg.frame = CGRectMake(65.0f, 0.0f, 195.0f, 2.0f);
            [cell.contentView addSubview:lineImg];
            [lineImg release];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(90.0f, 7.0f, 150.0f, 18.0f)];
            label1.font = [UIFont systemFontOfSize:S_CONTENT_FONT_SIZE];
            label1.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            nameLabel = label1;
            label1.tag = 1001;
            [cell.contentView addSubview:label1];
            label1.textColor = [UIColor grayColor];
            [label1 release];
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(90.0f, 28.0, 120.0f, 10.0f)];
            label2.textColor = [UIColor grayColor];
            timeLabel = label2;
            timeLabel.font = [UIFont systemFontOfSize:12.0f];
            label2.tag = 1002;
            label2.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            [cell.contentView addSubview:label2];
            [label2 release];
        }
        else
        {
            nameLabel = (UILabel *)[cell viewWithTag:1001];
            timeLabel = (UILabel *)[cell viewWithTag:1002];
            for (UIView *view in cell.contentView.subviews)
            {
                if(view.tag == 1004 || view.tag == 1005)
                    [view removeFromSuperview];
            }
        }
        if ([msg.fileExt isEqualToString:@"mp4"])
        {
            UIImage *videoImage = nil;
            NSString* strVideoFile = [msg.filePath mutableCopy];
            videoImage = [self getVideoImage:strVideoFile];
            if (videoImage)
            {
                int iValue = 0;
                if (msg.imState == EMessageState_Received)
                    iValue = 10;
                
                UIImageView *attachImg = [[UIImageView alloc] initWithImage:videoImage];
                attachImg.frame = CGRectMake(10.0f, 60.0f+iValue, 240.0f, 180.0f);
                attachImg.contentMode = UIViewContentModeScaleAspectFill;
                attachImg.clipsToBounds = YES;
                attachImg.tag = 1004;
                [cell.contentView addSubview:attachImg];
                [attachImg release];
                
                UIImageView *playImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playerStart.png"]];
                playImg.alpha = 0.7;
                playImg.tag = 1005;
                playImg.frame = CGRectMake(attachImg.frame.origin.x+98, attachImg.frame.origin.y+68+iValue, 45, 45);
                [cell.contentView addSubview:playImg];
                [playImg release];
                
            }
        }
        NSArray *strArr = [msg.filePath componentsSeparatedByString:@"/"];
        nameLabel.text = strArr.lastObject;
        timeLabel.text = msg.curDate;
    }
    else
    {
        cell = [self getVoiceCellWithTable:tableView andCell:cell andMsg: msg];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for (UIView *view in cell.contentView.subviews)
    {
        if (view.tag > 2000)
        {
            [view removeFromSuperview];
        }
    }
    
    //头像
    int x1 = 320 -55;
    if (msg.imState == EMessageState_Received)
    {
        x1 = 12;
    }
    UIImageView* ivContact = [[UIImageView alloc] initWithFrame:CGRectMake(x1, 8, 45, 46)];
    ivContact.image = [UIImage imageNamed:@"message_avatar.png"];
    [cell.contentView addSubview:ivContact];
    ivContact.tag = 2001;
    [ivContact release];
    
    UILabel* lbName = [[UILabel alloc] initWithFrame:CGRectMake(x1, 54, 45, 13)];
    lbName.text  = strVoipAccount;
    lbName.textAlignment = UITextAlignmentCenter;
    lbName.font = [UIFont systemFontOfSize:11];
    lbName.backgroundColor = [UIColor clearColor];
    lbName.textColor = [UIColor blackColor];
    lbName.tag = 2002;
    [cell.contentView addSubview:lbName];
    [lbName release];
        
    if (msg.imState == EMessageState_SendFailed)
    {
        UIButton *resendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [resendBtn addTarget:self action:@selector(resendMsg:) forControlEvents:UIControlEventTouchUpInside];
        [resendBtn setBackgroundImage:[UIImage imageNamed:@"icon_sms_failure.png"] forState:UIControlStateNormal];
        resendBtn.frame = CGRectMake(10.0f, 26.0f, 44.0f, 24.0f);
        [cell.contentView addSubview:resendBtn];
        resendBtn.tag = 2000+indexPath.row;
    }    
    else if (msg.imState == EMessageState_Sending)
    {
        UIActivityIndicatorView *actview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [actview startAnimating];
        actview.frame = CGRectMake(40,26,11,11);
        actview.tag = 2004;
        [cell.contentView addSubview:actview];
        [actview release];
    }
        
    return cell;
}

#pragma mark - UITableViewCell create methods
- (UITableViewCell*) tableView:(UITableView*)tableView cellOfP2PReceiveMsg:(IMMessageObj*)msg
{
    UITableViewCell *cell = nil;
    if (msg.msgtype == EMessageType_Text) //receive text message
    {
        UILabel *contentLabel = nil;
        UILabel *timeLabel = nil;
        UIImageView *talkBgView = nil;
        static NSString* cellid = @"im_text_r_message_cell_id";
        cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            cell.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            cell.contentView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            UIImageView *talkBg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"talk_box_bg.png"] stretchableImageWithLeftCapWidth:100.0f topCapHeight:30.0f]];
            talkBg.frame = CGRectMake(85.0f, 10.0f, 10.0f, 10.0f);
            [cell.contentView addSubview:talkBg];
            talkBg.tag = 1003;
            talkBgView = talkBg;
            [talkBg release];
            
            UILabel *label1 = [[UILabel alloc] init];
            label1.tag = 1001;
            label1.font = [UIFont systemFontOfSize:R_CONTENT_FONT_SIZE];
            contentLabel = label1;
            contentLabel.lineBreakMode = UILineBreakModeCharacterWrap;
            contentLabel.numberOfLines = 0;
            [cell.contentView addSubview:label1];
            label1.textColor = [UIColor grayColor];
            [label1 release];
            
            UILabel *label2 = [[UILabel alloc] init];
            label2.textColor = [UIColor grayColor];
            label2.tag = 1002;
            timeLabel = label2;
            timeLabel.font = [UIFont systemFontOfSize:12.0f];
            [cell.contentView addSubview:label2];
            [label2 release];
        }
        else
        {
            contentLabel = (UILabel *)[cell viewWithTag:1001];
            timeLabel = (UILabel *)[cell viewWithTag:1002];
            talkBgView = (UIImageView *)[cell viewWithTag:1003];
        }
        
        CGSize size = [msg.content sizeWithFont:[UIFont systemFontOfSize:R_CONTENT_FONT_SIZE] constrainedToSize:CGSizeMake(R_CONTENT_WIDTH, 5000.0f) lineBreakMode:UILineBreakModeCharacterWrap];
        if (size.width < 130)
        {
            size.width = 130;
        }
        CGRect bgFrame = talkBgView.frame;
        bgFrame.size.height = size.height + 30.0f;
        bgFrame.size.width = size.width+10.0f;
        talkBgView.frame = bgFrame;
        
        contentLabel.frame = CGRectMake(90.0f, 15.0f, size.width, size.height);
        contentLabel.text = msg.content;
        
        timeLabel.frame = CGRectMake(85.0f, 27.0f+size.height, 120.0f, 10.0f);
        timeLabel.text = msg.curDate;
    }
    else if (msg.msgtype == EMessageType_File)//receive attach message
    {
        UILabel *contentLabel = nil;
        UILabel *timeLabel = nil;
        static NSString* cellid = @"im_attach_r_message_cell_id";
        cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            cell.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            cell.contentView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            UIImageView *talkBg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"talk_box_bg.png"] stretchableImageWithLeftCapWidth:100.0f topCapHeight:30.0f]];
            talkBg.frame = CGRectMake(85.0f, 10.0f, 231.0f, 60.0f);
            [cell.contentView addSubview:talkBg];
            [talkBg release];
            UIImageView *attachImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"talk_box_file_icon.png"]];
            attachImg.frame = CGRectMake(90.0f, 15.0f, 19.0f, 18.0f);
            [cell.contentView addSubview:attachImg];
            [attachImg release];

            
            UILabel *label1 = [[UILabel alloc] init];
            label1.tag = 1001;
            label1.font = [UIFont systemFontOfSize:R_CONTENT_FONT_SIZE];
            contentLabel = label1;
            [cell.contentView addSubview:label1];
            label1.textColor = [UIColor grayColor];
            [label1 release];
            
            UILabel *label2 = [[UILabel alloc] init];
            label2.textColor = [UIColor grayColor];
            label2.tag = 1002;
            timeLabel = label2;
            timeLabel.font = [UIFont systemFontOfSize:12.0f];
            [cell.contentView addSubview:label2];
            [label2 release];
        }
        else
        {
            contentLabel = (UILabel *)[cell viewWithTag:1001];
            timeLabel = (UILabel *)[cell viewWithTag:1002];
            for (UIView *view in cell.contentView.subviews)
            {
                if(view.tag == 1004 || view.tag == 1005)
                    [view removeFromSuperview];
            }
        }
        
        if ([msg.fileExt isEqualToString:@"mp4"])
        {
            UIImage *videoImage = nil;
            NSString* strVideoFile = [msg.filePath mutableCopy];
            videoImage = [self getVideoImage:strVideoFile];
            if (videoImage)
            {
                int iValue = 0;
                if (msg.imState == EMessageState_Received)
                    iValue = 10;
                
                UIImageView *attachImg = [[UIImageView alloc] initWithImage:videoImage];
                attachImg.frame = CGRectMake(10.0f, 60.0f+iValue, 240.0f, 180.0f);
                attachImg.contentMode = UIViewContentModeScaleAspectFill;
                attachImg.clipsToBounds = YES;
                attachImg.tag = 1004;
                [cell.contentView addSubview:attachImg];
                [attachImg release];
                
                UIImageView *playImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playerStart.png"]];
                playImg.alpha = 0.7;
                playImg.tag = 1005;
                playImg.frame = CGRectMake(attachImg.frame.origin.x+98, attachImg.frame.origin.y+68+iValue, 45, 45);
                [cell.contentView addSubview:playImg];
                [playImg release];
                
            }
        }
        
        NSString *file =[msg.filePath lastPathComponent];
        
        contentLabel.frame = CGRectMake(110.0f, 15.0f, 190.0f, 18.0f);
        contentLabel.text = file;
        
        timeLabel.frame = CGRectMake(110.0f, 12.0f+40.0f, 120.0f, 10.0f);
        timeLabel.text = msg.curDate;
    }
    else
    {
        cell =  [self getVoiceCellWithTable:tableView andCell:cell andMsg: msg];
    }
    return cell;
}

- (UITableViewCell*) tableView:(UITableView*)tableView cellOfGroupReceiveMsg:(IMMessageObj*)msg
{
    UITableViewCell *cell = nil;
    if (msg.msgtype == EMessageType_Text) //receive text message
    {
        UILabel *contentLabel = nil;
        UILabel *nameLabel = nil;
        UILabel *timeLabel = nil;
        UIImageView *talkBgView = nil;
        static NSString* cellid = @"im_text_r_message_cell_id_g";
        cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            
            cell.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            cell.contentView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            UIImageView *talkBg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"talk_box_bg.png"] stretchableImageWithLeftCapWidth:100.0f topCapHeight:30.0f]];
            talkBg.frame = CGRectMake(85.0f, 10.0f, 10.0f, 10.0f);
            [cell.contentView addSubview:talkBg];
            talkBg.tag = 1003;
            talkBgView = talkBg;
            [talkBg release];
            
            UILabel *label1 = [[UILabel alloc] init];
            label1.tag = 1001;
            label1.font = [UIFont systemFontOfSize:R_CONTENT_FONT_SIZE];
            contentLabel = label1;
            contentLabel.lineBreakMode = UILineBreakModeCharacterWrap;
            contentLabel.numberOfLines = 0;
            [cell.contentView addSubview:label1];
            label1.textColor = [UIColor grayColor];
            [label1 release];
            
            UILabel *label2 = [[UILabel alloc] init];
            label2.textColor = [UIColor grayColor];
            label2.tag = 1002;
            timeLabel = label2;
            timeLabel.font = [UIFont systemFontOfSize:12.0f];
            [cell.contentView addSubview:label2];
            [label2 release];
        }
        else
        {
            contentLabel = (UILabel *)[cell viewWithTag:1001];
            timeLabel = (UILabel *)[cell viewWithTag:1002];
            talkBgView = (UIImageView *)[cell viewWithTag:1003];
            nameLabel = (UILabel *)[cell viewWithTag:1000];
        }
        
        CGSize size = [msg.content sizeWithFont:[UIFont systemFontOfSize:R_CONTENT_FONT_SIZE] constrainedToSize:CGSizeMake(R_CONTENT_WIDTH, 5000.0f) lineBreakMode:UILineBreakModeCharacterWrap];
        if (size.width < 130)
        {
            size.width = 130;
        }
        CGRect bgFrame = talkBgView.frame;
        bgFrame.size.height = size.height + 30.0f;
        bgFrame.size.width = size.width+10.0f;
        talkBgView.frame = bgFrame;
        
        contentLabel.frame = CGRectMake(90.0f, 15.0f, size.width, size.height);
        contentLabel.text = msg.content;
        
        timeLabel.frame = CGRectMake(85.0f, 27.0f+size.height, 120.0f, 10.0f);
        timeLabel.text = msg.curDate;
        
        nameLabel.text = msg.sender.length>3?([msg.sender substringFromIndex:msg.sender.length-3]):(msg.sender);
    }
    else if (msg.msgtype == EMessageType_File)//receive attach message
    {
        UILabel *contentLabel = nil;
        UILabel *timeLabel = nil;
        UILabel *nameLabel = nil;
        static NSString* cellid = @"im_attach_r_message_cell_id_g";
        cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            cell.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            cell.contentView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
            UIImageView *talkBg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"talk_box_bg.png"] stretchableImageWithLeftCapWidth:100.0f topCapHeight:30.0f]];
            talkBg.frame = CGRectMake(85.0f, 10.0f, 231.0f, 60.0f);
            [cell.contentView addSubview:talkBg];
            [talkBg release];
            
            UIImageView *attachImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"talk_box_file_icon.png"]];
            attachImg.frame = CGRectMake(90.0f, 15.0f, 19.0f, 18.0f);
            [cell.contentView addSubview:attachImg];
            [attachImg release];
            
            UILabel *label1 = [[UILabel alloc] init];
            label1.tag = 1001;
            label1.font = [UIFont systemFontOfSize:R_CONTENT_FONT_SIZE];
            contentLabel = label1;
            [cell.contentView addSubview:label1];
            label1.textColor = [UIColor grayColor];
            [label1 release];
            
            UILabel *label2 = [[UILabel alloc] init];
            label2.textColor = [UIColor grayColor];
            label2.tag = 1002;
            timeLabel = label2;
            timeLabel.font = [UIFont systemFontOfSize:12.0f];
            [cell.contentView addSubview:label2];
            [label2 release];
        }
        else
        {
            contentLabel = (UILabel *)[cell viewWithTag:1001];
            timeLabel = (UILabel *)[cell viewWithTag:1002];
            for (UIView *view in cell.contentView.subviews)
            {
                if(view.tag == 1004 || view.tag == 1005)
                    [view removeFromSuperview];
            }
        }
        
        if ([msg.fileExt isEqualToString:@"mp4"])
        {
            UIImage *videoImage = nil;
            NSString* strVideoFile = [msg.filePath mutableCopy];
            videoImage = [self getVideoImage:strVideoFile];
            if (videoImage)
            {
                int iValue = 0;
                if (msg.imState == EMessageState_Received)
                    iValue = 10;
                
                UIImageView *attachImg = [[UIImageView alloc] initWithImage:videoImage];
                attachImg.frame = CGRectMake(10.0f, 60.0f+iValue, 240.0f, 180.0f);
                attachImg.contentMode = UIViewContentModeScaleAspectFill;
                attachImg.clipsToBounds = YES;
                attachImg.tag = 1004;
                [cell.contentView addSubview:attachImg];
                [attachImg release];
                
                UIImageView *playImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playerStart.png"]];
                playImg.alpha = 0.7;
                playImg.tag = 1005;
                playImg.frame = CGRectMake(attachImg.frame.origin.x+98, attachImg.frame.origin.y+68+iValue, 45, 45);
                [cell.contentView addSubview:playImg];
                [playImg release];
                
            }
        }
        
        NSString *file =[msg.filePath lastPathComponent];
        contentLabel.frame = CGRectMake(110.0f, 15.0f, 190.0f, 18.0f);
        contentLabel.text = file;
        
        timeLabel.frame = CGRectMake(110.0f, 12.0f+40.0f, 120.0f, 10.0f);
        timeLabel.text = msg.curDate;
        
        nameLabel.text = msg.sender.length>3?([msg.sender substringFromIndex:msg.sender.length-3]):(msg.sender);
    }
    else if (msg.msgtype == EMessageType_Voice)
    {
       cell = [self getVoiceCellWithTable:tableView andCell:cell andMsg: msg];
    }
    
    return cell;
}

- (UITableViewCell*) getVoiceCellWithTable:(UITableView*)tableView andCell:(UITableViewCell*)cell andMsg:(IMMessageObj*) msg
{
    static NSString* cellid = @"im_voice_message_cell_id_g";
    cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
    }
    cell.contentView.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    cell.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    UIImage *image_in1;
    UIImage *image_in2;
    UIImage *image_in3;
    UIImage *image_in4;
    int x = 0;
    int x2 = 0;
    int tag = 1002;
    int x4 = 0;
    BOOL isOut = NO;
    double duration = msg.duration;
    int width = 82+ 148 * (duration/ 1000.f / 60.f);
    CGRect TimeRect = CGRectMake(125.0f, 61.f, 120.0f, 10.0f);
    if (msg.imState <= EMessageState_Send_OtherReceived)
    {
        image_in1 = [UIImage imageNamed:@"message01.png"];
        image_in2 = [image_in1 stretchableImageWithLeftCapWidth:30 topCapHeight:30];
        image_in3 = [UIImage imageNamed:@"message01_on.png"];
        image_in4 = [image_in3 stretchableImageWithLeftCapWidth:30 topCapHeight:30];
        x = 320 - width - 45 - 20;
        x2 = 215;
        x4 = x2 - 60;
        isOut = YES;
    }
    else
    {
        image_in1 = [UIImage imageNamed:@"message02.png"];
        image_in2 = [image_in1 stretchableImageWithLeftCapWidth:40 topCapHeight:30];
        image_in3 = [UIImage imageNamed:@"message02_on.png"];
        image_in4 = [image_in3 stretchableImageWithLeftCapWidth:40 topCapHeight:30];
        x = 65;
        x2 = 90;
        x4 = x2 + 22;
        tag = 1003;
        TimeRect = CGRectMake(90.0f, 61.f , 120.0f, 10.0f);
    }
    
    UIButton *ivb = [UIButton buttonWithType:UIButtonTypeCustom];
    ivb.frame = CGRectMake(x, 12, width, 45);
    [ivb setBackgroundImage:image_in2 forState:(UIControlStateNormal)];
    [ivb setBackgroundImage:image_in4 forState:(UIControlStateHighlighted)];
    [ivb addTarget:self action:@selector(playVoiceMsg:) forControlEvents:(UIControlEventTouchDown)];
    ivb.tag = tag;
    [cell.contentView addSubview:ivb];
    
    
    UIImageView* ivPlay= [[UIImageView alloc] initWithFrame:CGRectMake(x2, 22, 16, 24)];
    if (isOut)
    {
        ivPlay.animationImages=[NSArray arrayWithObjects:
                                [UIImage imageNamed:@"voice_to_playing_s0.png"],
                                [UIImage imageNamed:@"voice_to_playing_s1.png"],
                                [UIImage imageNamed:@"voice_to_playing_s2.png"],
                                [UIImage imageNamed:@"voice_to_playing_s3.png"],nil ];
        [ivPlay setImage:[UIImage imageNamed:@"voice_to_playing_s0.png"]];
    }
    else
    {
        ivPlay.animationImages=[NSArray arrayWithObjects:
                                [UIImage imageNamed:@"voice_from_playing_s0.png"],
                                [UIImage imageNamed:@"voice_from_playing_s1.png"],
                                [UIImage imageNamed:@"voice_from_playing_s2.png"],
                                [UIImage imageNamed:@"voice_from_playing_s3.png"],nil ];
        [ivPlay setImage:[UIImage imageNamed:@"voice_from_playing_s0.png"]];
    }
    
    //设定动画的播放时间
    ivPlay.animationDuration=.7;
    //设定重复播放次数
    ivPlay.animationRepeatCount=100000;
    [cell.contentView addSubview:ivPlay];
    ivPlay.tag = 1005;
    [ivPlay release];    
    

    UILabel* lbTime = [[UILabel alloc] initWithFrame:TimeRect];
    lbTime.text  = msg.curDate;
    lbTime.textAlignment = UITextAlignmentCenter;
    lbTime.font = [UIFont systemFontOfSize:13];
    lbTime.backgroundColor = [UIColor clearColor];
    lbTime.textColor = [UIColor grayColor];
    lbTime.tag = 1001;
    [cell.contentView addSubview:lbTime];
    [lbTime release];
    
    UILabel* lbduration = [[UILabel alloc] initWithFrame:CGRectMake(x4, 25, 60, 17)];
    lbduration.text  = [NSString stringWithFormat:@"%d\" ",(int)(duration / 1000.f)];
    if (isOut)
    {
        lbduration.textAlignment = UITextAlignmentRight;
    }
    else
        lbduration.textAlignment = UITextAlignmentLeft;
    lbduration.font = [UIFont systemFontOfSize:15];
    lbduration.backgroundColor = [UIColor clearColor];
    lbduration.textColor = [UIColor grayColor];
    lbduration.tag = 1001;
    [cell.contentView addSubview:lbduration];
    [lbduration release];
    return cell;
}

#pragma mark - UIDelegate
- (void)responseMessageStatus:(EMessageStatusResult)event callNumber:(NSString *)callNumber data:(NSString *)data
{
    switch (event)
	{
        case EMessageStatus_Received:
        {
            self.chatArray = [self.modelEngineVoip.imDBAccess getMessageOfSessionId:self.receiver];
            [self.table reloadData];
             [self.table scrollRectToVisible:CGRectMake(0, self.table.contentSize.height-15, self.table.contentSize.width, 10) animated:YES];
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

-(void)responseDownLoadMediaMessageStatus:(CloopenReason *)event
{
    switch (event.reason)
	{
        case 0:
        {
            self.chatArray = [self.modelEngineVoip.imDBAccess getMessageOfSessionId:self.receiver];
            [self.table reloadData];
            [self.table scrollRectToVisible:CGRectMake(0, self.table.contentSize.height-15, self.table.contentSize.width, 10) animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void) onSendInstanceMessageWithReason: (CloopenReason *) reason andMsg:(InstanceMsg*) data
{
    if (reason.reason == ERROR_FILE)
    {
        [self  popPromptViewWithMsg:@"发送的文件过大，不能发送超过限制大小的文件！" AndFrame:CGRectMake(0, 160, 320, 30)];
        return;
    }
    else if (reason.reason == 170000)
    {
        [self  popPromptViewWithMsg:@"未连接云通讯平台服务器！" AndFrame:CGRectMake(0, 160, 320, 30)];
        return;
    }
    else if (reason.reason == 170014)
    {
        [self  popPromptViewWithMsg:@"语音过短，发送失败！" AndFrame:CGRectMake(0, 160, 320, 30)];
        return;
    }
    else if (reason.reason == 170016)//用户取消上传
    {
        return;
    }
    else if (reason.reason == 110138 )
    {
        [self  popPromptViewWithMsg:@"你已经被管理员禁言！" AndFrame:CGRectMake(0, 160, 320, 30)];
    }
    else if (reason.reason == 121002)//
    {
        [self  popPromptViewWithMsg:@"计费鉴权失败,余额不足！" AndFrame:CGRectMake(0, 160, 320, 30)];
        return;
    }
    else if (reason.reason == 112037)
    {
        [self  popPromptViewWithMsg:@"群组用户被禁言！" AndFrame:CGRectMake(0, 160, 320, 30)];
        return;
    }
    
    if ([data isKindOfClass:[IMAttachedMsg class]])
    {
        IMAttachedMsg *msg = (IMAttachedMsg*)data;
        BOOL isExist = [self.modelEngineVoip.imDBAccess isMessageExistOfMsgid:msg.msgId];
        if (isExist)
        {
            NSInteger imstate = EMessageState_SendFailed;
            if (reason.reason == 0)
                imstate = EMessageState_SendSuccess;
            
            [self.modelEngineVoip.imDBAccess updateimState:imstate OfmsgId:msg.msgId];
        }
        else
        {
            IMMessageObj* imMsg = [[IMMessageObj alloc] init];
            imMsg.filePath = msg.fileUrl;
            imMsg.sessionId = self.receiver;
            imMsg.fileExt = msg.ext;
            if (reason.reason == 0)
                imMsg.imState = EMessageState_SendSuccess;
            else
                imMsg.imState = EMessageState_SendFailed;
            
            if ([msg.ext isEqualToString:@"amr"])
            {
                imMsg.msgtype = EMessageType_Voice;
                imMsg.duration = [self.modelEngineVoip getVoiceDuration:msg.fileUrl];
            }
            else
            {
                imMsg.msgtype = EMessageType_File;
            }
            imMsg.isRead = EReadState_IsRead;
            imMsg.dateCreated = msg.dateCreated;
            NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
            NSString *curTimeStr = [dateformatter stringFromDate:[NSDate date]];
            [dateformatter release];
            imMsg.curDate = curTimeStr;
            
            [self.modelEngineVoip.imDBAccess insertIMMessage:imMsg];
            [imMsg release];
        }
        
        self.chatArray = [self.modelEngineVoip.imDBAccess getMessageOfSessionId:self.receiver];
        [self.table reloadData];
        
        if([self.chatArray count]>0)
            [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else if ([data isKindOfClass:[IMTextMsg class]])
    {
        //报告发送状态
        IMTextMsg *msg = (IMTextMsg*)data;
        NSInteger status = [msg.status integerValue];
        NSInteger imStatus = 0;
        if (status == -1)
        {
            imStatus = EMessageState_SendFailed;
        }
        else if(status == 0)
        {
            imStatus = EMessageState_SendSuccess;
        }
        else if(status == 1)
        {
            imStatus = EMessageState_Send_OtherReceived;
        }
        NSLog(@"reason=%d,状态报告=%d", reason.reason, status);
        [self.modelEngineVoip.imDBAccess updateimState:imStatus OfmsgId:msg.msgId];
        self.chatArray = [self.modelEngineVoip.imDBAccess getMessageOfSessionId:self.receiver];
        [self.table reloadData];
    }
}

-(void)touchOutside
{
    isOutside = YES;
}

-(void)touchInside
{
    isOutside = NO;
}

-(void)setButtonState:(BOOL) on
{
    if (on) {
        [voiceBtn setBackgroundImage:[UIImage imageNamed:@"IM_voice_icon_on.png"] forState:UIControlStateNormal];
        [voiceBtn setBackgroundImage:[UIImage imageNamed:@"IM_voice_icon_on.png"] forState:UIControlStateHighlighted];
    }
    else
    {
        [voiceBtn setBackgroundImage:[UIImage imageNamed:@"IM_voice_icon.png"] forState:UIControlStateNormal];
        [voiceBtn setBackgroundImage:[UIImage imageNamed:@"IM_voice_icon.png"] forState:UIControlStateHighlighted];
    }

}
#pragma mark - modelEngineVoip function

//开始录音
-(void)record:(id)sender
{
     [self stopRecMsg];
    textView.editable = NO;
    if (recordState != ERecordState_Origin)
    {
        return;
    }
    recordState = ERecordState_Start;
    if ( self.recordTimer)
    {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(startRecording) userInfo:nil repeats:NO];
}

-(void)startRecording
{
    if (recordState != ERecordState_Start)
    {
        return;
    }
    [self setButtonState:YES];
    recordState = ERecordState_Recording;
    self.curRecordFile = [self createFileName];
    NSString* filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.curRecordFile];
    self.popView.hidden = NO;
    self.ivPopImg.image = [self.imgArray objectAtIndex:0];
    [self.view bringSubviewToFront:self.popView];
    self.sendPath = filePath;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [self.modelEngineVoip startVoiceRecordingWithReceiver:self.receiver andPath:filePath andChunked:isChunk andUserdata:@"cloopen"];
}

//录音取消
-(void)recordCancel
{
    textView.editable = YES;
    if (recordState != ERecordState_Recording)
    {
        recordState = ERecordState_Origin;
        return;
    }
    [self setButtonState:NO];
    self.popView.hidden = YES;
    isRecording = NO;
    if (isChunk)
    {
        [self.modelEngineVoip cancelVoiceRecording];
    }
    else
    {
        [self.modelEngineVoip stopCurRecording];
    }
    recordState = ERecordState_Origin;
}

//停止录音
-(void)stopSelfRecording
{
    textView.editable = YES;
    if (recordState != ERecordState_Recording)
    {
        recordState = ERecordState_Origin;
        return;
    }
    [self setButtonState:NO];
    self.popView.hidden = YES;
    isRecording = NO;
    [self stop];
    recordState = ERecordState_Origin;
}

//调用底层的停止录音
-(void)stop
{
    [self.modelEngineVoip stopCurRecording];
    if (!isChunk)
    {
        [self performSelector:@selector(sendVoiceMsg) withObject:nil afterDelay:.5];
    }
}

- (void)sendVoiceMsg{
     [self.modelEngineVoip sendInstanceMessage:self.receiver andText:nil andAttached:self.sendPath andUserdata:@"cloopen"];
}

//根据一定规则生成文件不重复的文件名
- (NSString *)createFileName
{
    static int seedNum = 0;
    if(seedNum >= 1000)
        seedNum = 0;
    seedNum++;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    
    NSString *file = [NSString stringWithFormat:@"tmp%@%03d.amr", currentDateStr, seedNum];
    return file;
}

//停止放音
-(void)stopRecMsg
{
    isPlaying = NO;
    [self.curImg stopAnimating];
    [self.modelEngineVoip stopVoiceMsg];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
}

//播放当前点击的语音
-(void)playVoiceMsg:(id)sender
{
    if (isRecording)
    {
        return;
    }
    [self stopAnimation];
    self.curImg = nil;
    UIView* contentview = [sender superview];
    self.curImg = (UIImageView*)[contentview viewWithTag:1005];
    
    UIView *cell = [contentview superview];
    while (![cell isKindOfClass:[UITableViewCell class]]) {
        cell = [cell superview];
    };

    int i = [self.table indexPathForCell:(UITableViewCell*)cell].row;
    IMMessageObj *msg = [self.chatArray objectAtIndex:i];
    
    NSString* strFileName = msg.filePath;
    if (isPlaying && [msg.msgid isEqualToString:self.curVoiceSid])
    {
        [self stopRecMsg];
        return;
    }
    self.curVoiceSid = msg.msgid;
    [self playRecMsg:strFileName];
}

//根据传入的文件名播放语音
-(void)playRecMsg:(NSString*) fileName
{
    isPlaying = YES;
    [self.curImg startAnimating];
    [self.modelEngineVoip enableLoudsSpeaker:isLoud];
    
    if (isLoud)
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    else
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    [self.modelEngineVoip playVoiceMsg:fileName];
}

//停止播放语音的动画效果
-(void)stopAnimation
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    if (self.curImg)
    {
        [self.curImg stopAnimating];
    }
}

- (void)loudSperker
{
    isLoud = !isLoud;
    if (isLoud)
    {
        //扬声器
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    else
    {
        //听筒
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
}

- (void) CreateClearBackBtn:(UIColor*) backColor
{
    int height = 480;
    if (IPHONE5)
        height = 568;
    UIButton* backgroundBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    [backgroundBtn addTarget:self action:@selector(removeMenu) forControlEvents:UIControlEventTouchUpInside];
    backgroundBtn.backgroundColor = backColor;
    backgroundBtn.alpha  = 1;
    backgroundBtn.tag = MENUVIEW_TAG;
    [self.navigationController.view addSubview:backgroundBtn];
    [backgroundBtn release];
}

- (void) removeMenu
{
    for(UIView* u in self.navigationController.view.subviews)
    {
        if (u.tag == MENUVIEW_TAG)
        {
            [u removeFromSuperview];
        }
    }
}

-(void)management
{
    [self stopRecMsg];
    [self stopSelfRecording];
    [self CreateClearBackBtn:[UIColor clearColor]];
    UICustomView* MenuView;
    
    MenuView = [[UICustomView alloc] initWithFrame:CGRectMake(170, 14, 135, 127)
                                     andLabel1Text:@"群资料"
                                     andLabel2Text:isLoud?@"听筒":@"扬声器"];
    MenuView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, 0.01), 0, 0);
    [self.navigationController.view addSubview:MenuView];
    MenuView.tag = MENUVIEW_TAG;
    [MenuView set_Delegate:self];
    [MenuView release];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    MenuView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, 1), 0, 48);
    [UIView commitAnimations];
}

-(void) ChooseWithFlag:(NSInteger)Flag{
    [self removeMenu];
    switch (Flag)
    {
        case 1:
            [self goToGroupInfoView];
            break;
        case 2:
            [self loudSperker];
            break;
        default:
            break;
    }
}

#pragma mark - VoipModelEngine Delegate

-(void)responseFinishedPlaying
{
    isPlaying = NO;
    [self stopAnimation];
}

//录音超时
-(void)responseRecordingTimeOut:(int) ms
{
    recordState = ERecordState_Origin;
    textView.editable = YES;
    isRecording = NO;
    [self popPromptViewWithMsg:[NSString stringWithFormat: @"语音超时，已达到最大时长%d秒，即将自动进行发送",ms/1000] AndFrame:CGRectMake(0, 160, 320, 30)];
    self.popView.hidden = YES;
    [self setButtonState:NO];
    [self stop];
}

//下载完成后的回调
-(void)responseDownLoadMessageStatus:(int)event;
{
    switch (event)
	{
        case 0:
        {
            //[self updateVoiceMsgArray];
        }
            break;
        default:
            break;
    }
}

//上传录音时声音振幅的回调
-(void)responseRecordingAmplitude:(double) amplitude
{
    if (isOutside)
    {
        self.ivPopImg.image = [UIImage imageNamed:@"message_interphone_bg_off.png"];
        return;
    }
    int iAmplitude = 1;
    
    if (amplitude > .76)
    {
        iAmplitude = 6;
    }
    else if (amplitude > .52)
    {
        iAmplitude = 5;
    }
    else if (amplitude > .37)
    {
        iAmplitude = 4;
    }
    else if (amplitude > .27)
    {
        iAmplitude = 3;
    }
    else if (amplitude > .17)
    {
        iAmplitude = 2;
    }
    
    self.ivPopImg.image = [self.imgArray objectAtIndex:iAmplitude-1];
}

-(void)onGroupQueryGroupWithReason:(CloopenReason*)reason andGroup:(IMGroupInfo *)group
{
    if (reason.reason == 0)
    {
        self.title = group.name;
        [self.modelEngineVoip.imDBAccess insertOrUpdateGroupInfos:[NSArray arrayWithObject:group]];
    }
    else
    {
        [self popPromptViewWithMsg:[NSString stringWithFormat:@"错误码：%d,错误详情：%@",reason.reason,reason.msg]];
    }
}


@end
