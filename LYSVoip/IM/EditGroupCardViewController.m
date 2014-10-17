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

#import "EditGroupCardViewController.h"

@interface EditGroupCardViewController ()

@end

@implementation EditGroupCardViewController

- (id)initWithType:(NSInteger) editType andGroupCard:(IMGruopCard*) groupCard
{
    self = [super init];
    if (self)
    {
        type = editType;
        myGroupCard = groupCard;
        if (type == 1)
        {
            count = 32;
        }
        else if(type == 2)
        {
            count = 20;
        }
        else if(type == 3)
        {
            count = 30;
        }
        else if(type == 4)
        {
            count = 100;
        }
    }
    return self;
}

//-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    NSMutableString *text = [[textField.text mutableCopy] autorelease];
//    int length = [text length];
//    if (length <=count)
//        label.text = [NSString stringWithFormat:@"%d/%d",length,count];
//    if (range.length == 1) {
//        return YES;
//    }
//    [text replaceCharactersInRange:range withString:string];
//    return length <= count;
//}

- (void)TextFieldTextDidChangeNotification:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    NSInteger textLength = textField.text.length;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > count) {
                textField.text = [toBeString substringToIndex:count];
                textLength = count;
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > count) {
            textField.text = [toBeString substringToIndex:count];
            textLength = count;
        }
    }
    label.text = [NSString stringWithFormat:@"%d/%d",textLength,count];
}

#pragma mark - HPGrowingTextView delegate

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);    
	CGRect r = label.frame;    
    r.origin.y -= diff;
    label.frame = r;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSInteger textLength = textView.text.length;
    NSInteger replaceLength = text.length;
    label.text = [NSString stringWithFormat:@"%d/%d",textLength + replaceLength,count];
    if (range.length == 1)
    {
        return YES;
    }
    
    if ( (textLength + replaceLength) >= count)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"输入内容最多为%d",count] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av show];
        [av release];
        return NO;
    }
    return YES;
}

- (void)hidekey
{
    [self.textField resignFirstResponder];
    [textView resignFirstResponder];
}

-(void)finish
{
    if (type == 1)
    {
        myGroupCard.display = self.textField.text;
    }
    else if(type == 2)
    {
        myGroupCard.tel = self.textField.text;
    }
    else if(type == 3)
    {
        myGroupCard.mail = self.textField.text;
    }
    else if(type == 4)
    {
        myGroupCard.remark = textView.text;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadView
{
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    UIBarButtonItem *clearMessage=[[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"完成" target:self action:@selector(finish)]];
    self.navigationItem.rightBarButtonItem = clearMessage;
    [clearMessage release];
    
    
    self.title = @"备注";
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    UIView* mainview = [[UIView alloc] initWithFrame:frame];
    mainview.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    self.view = mainview;
    
    UIButton* backButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    frame.origin.y = 0;
    backButton.frame = frame;
    [mainview addSubview:backButton];
    [backButton addTarget:self action:@selector(hidekey) forControlEvents:UIControlEventTouchDown];
    [mainview release];

    if (type < 4)
    {
        [self addCountTextField:CGRectMake(250.0f, 50.0f, 70.0f, 27.0f)];
        UITextField* tmpField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 15.0f, 300.0f, 27.0f)];
        tmpField.backgroundColor = [UIColor whiteColor];
        tmpField.delegate = self;
        tmpField.font = [UIFont systemFontOfSize:15.0f];
        tmpField.placeholder = @"请在这里填写内容";
        [self.view addSubview:tmpField];
        self.textField = tmpField;
        [tmpField release];
        switch (type) {
            case 1:
                self.title = @"群昵称";
                if (myGroupCard.display)
                {
                    self.textField.text = myGroupCard.display;
                }
                break;
            case 2:
                self.title = @"电话";
                self.textField.keyboardType = UIKeyboardTypePhonePad;
                if (myGroupCard.tel)
                {
                    self.textField.text = myGroupCard.tel;
                }
                break;
            case 3:
                self.title = @"邮箱";
                self.textField.keyboardType = UIKeyboardTypeEmailAddress;
                if (myGroupCard.mail)
                {
                    self.textField.text = myGroupCard.mail;
                }
                label.text = [NSString stringWithFormat:@"%d/%d",self.textField.text.length,count];
                break;
            default:
                break;
        }
    }
    else
    {
        textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10.0f, 15.0f, 300.0f, 35.0f)];
        //        textView.backgroundColor = [UIColor clearColor];
        textView.contentInset = UIEdgeInsetsMake(-2, 5, -2, 5);
        textView.minNumberOfLines = 1;
        textView.maxNumberOfLines = 9;
        textView.returnKeyType = UIReturnKeyDefault;
        textView.font = [UIFont systemFontOfSize:15.0f];
        textView.delegate = self;
        textView.placeholder = @"请在这里填写内容";
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:textView];
        if ([myGroupCard.remark length] > 0)
        {
            textView.text = myGroupCard.remark;
        }
        [self addCountTextField:CGRectMake(250.0f, 58.0f, 70.0f, 27.0f)];
        label.text = [NSString stringWithFormat:@"%d/%d",self.textField.text.length,count];
    }
}

-(void)addCountTextField:(CGRect) frame
{
    label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"%d/%d",0,count];
    label.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    [self.view addSubview:label];
    label.frame = frame;
    [label release];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.modelEngineVoip.UIDelegate = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextFieldTextDidChangeNotification:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [self hidekey];
    [super viewWillDisappear:animated];
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

-(void)dealloc
{
    self.textField = nil;
    [textView release];
    [super dealloc];
}
@end
