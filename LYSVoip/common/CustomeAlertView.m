#import "CustomeAlertView.h"

@implementation CustomeAlertView
@synthesize myView;
@synthesize delegate;
@synthesize animation;

-(id)init
{
    return [self initWithBtnTitle1:nil andBtnTitle2:nil];
}

-(id)initWithBtnTitle1:(NSString*)btnTitle1 andBtnTitle2:(NSString*)btnTitle2
{
    if (self=[super init]) {
        self.frame = [[UIScreen mainScreen] bounds];
        self.backgroundColor = [UIColor clearColor];
        //UIWindow的层级 总共有三种
        self.windowLevel = UIWindowLevelAlert;
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 600)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.7;
        [self addSubview:bgView];
        [bgView release];
        myView = [[UIView alloc]initWithFrame:CGRectMake(25.0f, 120.0f, 270.0f, 200.0f)];
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        if (btnTitle1)
            [cancelButton setTitle:btnTitle1 forState:UIControlStateNormal];
        else
            [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor colorWithRed:0.0f green:122.0f/255.0f blue:1.0f alpha:1] forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [cancelButton addTarget:self action:@selector(pressCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"alert_view_left_btn_on"] forState:UIControlStateHighlighted];
        cancelButton.frame = CGRectMake(0, 200.0f-44.5f, 135.5f, 44.5f);
        [myView addSubview:cancelButton];
        UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (btnTitle2)
        {
            [okButton setTitle:btnTitle2 forState:UIControlStateNormal];
        }
        else
            [okButton setTitle:@"确定" forState:UIControlStateNormal];
        [okButton setBackgroundImage:[UIImage imageNamed:@"alert_view_right_btn_on"] forState:UIControlStateHighlighted];
        [okButton addTarget:self action:@selector(pressOKButton:) forControlEvents:UIControlEventTouchUpInside];
        [okButton setTitleColor:[UIColor colorWithRed:0.0f green:122.0f/255.0f blue:1.0f alpha:1] forState:UIControlStateNormal];
        [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        okButton.frame = CGRectMake(135.5f, 200.0f-44.5f, 134.5f, 44.5f);
        okButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [myView addSubview:okButton];
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"alert_view_bg"] stretchableImageWithLeftCapWidth:135.0f topCapHeight:15.0f]];
        [backgroundView setFrame:myView.bounds];
        backgroundView.clipsToBounds = YES;
        [myView insertSubview:backgroundView atIndex:0];
        [backgroundView release];
        animation = [[CustomizedAlertAnimation alloc] customizedAlertAnimationWithUIview:myView];
        animation.delegate = self;
        [self addSubview:myView];
        [myView release];
    }
    return self;
}

-(void)show{
    [self makeKeyAndVisible];
    [animation showAlertAnimation];
}

-(void)dismiss{
    [self resignKeyWindow];
    [animation dismissAlertAnimation];
    
}

-(void) pressCancelButton:(id)sender{
    self.flag = 0;
    [self dismiss];
}

-(void) pressOKButton:(id)sender{
    self.flag = 1;
    [self dismiss];
}

- (void)setViewFrame:(CGRect)frame
{
    myView.frame = frame;
    UIView *view = [myView.subviews objectAtIndex:0];
    view.frame = myView.bounds;
}
#pragma mark -- CustomizedAlertAnimationDelegate


//自定义的alert view出现动画结束后调用
-(void)showCustomizedAlertAnimationIsOverWithUIView:(UIView *)v{
    NSLog(@"showCustomizedAlertAnimationIsOverWithUIView");
}

//自定义的alert view消失动画结束后调用
-(void)dismissCustomizedAlertAnimationIsOverWithUIView:(UIView *)v{
    NSLog(@"dismissCustomizedAlertAnimationIsOverWithUIView");
    [self.delegate CustomeAlertViewDismiss:self];
    
}

@end
