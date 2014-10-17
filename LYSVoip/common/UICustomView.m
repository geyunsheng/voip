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

#import "UICustomView.h"

@implementation UICustomView


- (id)initWithFrame:(CGRect)frame andLabel1Text:(NSString *)label1Text andLabel2Text:(NSString *)label2Text andLabel3Text:(NSString *)label3Text andLabel4Text:(NSString *)label4Text
{
    self = [self initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 135, 167)];
    menuImageView.backgroundColor = [UIColor clearColor];
    menuImageView.image = [UIImage imageNamed:@"dialog_four.png"];
    [self addSubview:menuImageView];
    menuImageView.tag = MENUVIEW_TAG;
    [menuImageView release];     
    
    btnBackGround = [[UIImageView alloc] initWithFrame:CGRectMake(0, 9, 135, 38)];
    btnBackGround.backgroundColor = [UIColor clearColor];
    btnBackGround.image = [UIImage imageNamed:@"dialog_on.png"];
    [self addSubview:btnBackGround];
    btnBackGround.hidden = YES;
    btnBackGround.tag = MENUVIEW_TAG;
    [btnBackGround release]; 

    btn1Label = [[UILabel alloc] initWithFrame:CGRectMake(5, 12, 130, 35)];
    btn1Label.text = label1Text;
    btn1Label.backgroundColor = [UIColor clearColor];
    [btn1Label setFont:[UIFont systemFontOfSize :16]];    
    btn1Label.textColor = [UIColor whiteColor];
    [self addSubview:btn1Label];
    btn1Label.tag = MENUVIEW_TAG;
    [btn1Label release]; 
    
    btn2Label = [[UILabel alloc] initWithFrame:CGRectMake(5, 52, 130, 35)];
    
    btn2Label.textColor = [UIColor whiteColor];
    viewflag = YES;
    
    btn2Label.text = label2Text;
    btn2Label.backgroundColor = [UIColor clearColor];
    [btn2Label setFont:[UIFont systemFontOfSize :16]];    
    [self addSubview:btn2Label];
    btn2Label.tag = MENUVIEW_TAG;
    [btn2Label release]; 
    
    _btn3Label = [[UILabel alloc] initWithFrame:CGRectMake(5, 92, 130, 35)];
    _btn3Label.textColor = [UIColor whiteColor];
    
    _btn3Label.text = label3Text;
    _btn3Label.backgroundColor = [UIColor clearColor];
    [_btn3Label setFont:[UIFont systemFontOfSize:16]];    
    [self addSubview:_btn3Label];
    _btn3Label.tag = MENUVIEW_TAG;
    [_btn3Label release]; 

    _btn4Label = [[UILabel alloc] initWithFrame:CGRectMake(5, 132, 130, 35)];
    _btn4Label.textColor = [UIColor whiteColor];
    
    _btn4Label.text = label4Text;
    _btn4Label.backgroundColor = [UIColor clearColor];
    [_btn4Label setFont:[UIFont systemFontOfSize:16]];
    [self addSubview:_btn4Label];
    _btn4Label.tag = MENUVIEW_TAG;
    [_btn4Label release];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame andLabel1Text:(NSString *)label1Text andLabel2Text:(NSString *)label2Text
{
    self = [self initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 135, 87)];
    menuImageView.backgroundColor = [UIColor clearColor];
    menuImageView.image = [UIImage imageNamed:@"dialog_two.png"];
    [self addSubview:menuImageView];
    menuImageView.tag = MENUVIEW_TAG;
    [menuImageView release];
    
    btnBackGround = [[UIImageView alloc] initWithFrame:CGRectMake(0, 9, 135, 38)];
    btnBackGround.backgroundColor = [UIColor clearColor];
    btnBackGround.image = [UIImage imageNamed:@"dialog_on.png"];
    [self addSubview:btnBackGround];
    btnBackGround.hidden = YES;
    btnBackGround.tag = MENUVIEW_TAG;
    [btnBackGround release];
    
    btn1Label = [[UILabel alloc] initWithFrame:CGRectMake(5, 12, 130, 35)];
    btn1Label.text = label1Text;
    btn1Label.backgroundColor = [UIColor clearColor];
    [btn1Label setFont:[UIFont systemFontOfSize :16]];
    btn1Label.textColor = [UIColor whiteColor];
    [self addSubview:btn1Label];
    btn1Label.tag = MENUVIEW_TAG;
    [btn1Label release];
    
    btn2Label = [[UILabel alloc] initWithFrame:CGRectMake(5, 52, 130, 35)];
    
    btn2Label.textColor = [UIColor whiteColor];
    viewflag = YES;
    
    btn2Label.text = label2Text;
    btn2Label.backgroundColor = [UIColor clearColor];
    [btn2Label setFont:[UIFont systemFontOfSize :16]];
    [self addSubview:btn2Label];
    btn2Label.tag = MENUVIEW_TAG;
    [btn2Label release];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code    
    }
    return self;
}
-(void)set_Delegate:(id)delegate{
    viewDelegate = delegate;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    
    if ( menuImageView.frame.size.height > 127 )
    {
        [self ShowView: pos isFour:YES];
    }
    else
    {
        [self ShowView:pos isTwo:YES];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    
    if ( menuImageView.frame.size.height > 87 )
    {
        [self ShowView: pos isFour:YES];
    }
    else
    {
        [self ShowView:pos isTwo:YES];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    btnBackGround.hidden = YES; 
    [viewDelegate ChooseWithFlag:chooseFlag];
}

- (void)ShowView:(CGPoint)pos isFour:(BOOL)isFour
{
    chooseFlag = EChooseNone;
    
    if ((pos.x< 0)||(pos.x>167))
    {
        btnBackGround.hidden = YES; 
        return;
    }
    
    if ((pos.y < 49) && (pos.y > 0))
    {
        CGRect backFrame = btnBackGround.frame;
        backFrame.origin.y = 9;
        btnBackGround.frame = backFrame;
        btnBackGround.hidden = NO;
        chooseFlag = EChooseFirst;
    }
    else  if ((pos.y > 49) && (pos.y < 87))
    {
        if (!viewflag)
        {
            chooseFlag = EChooseDisalbe;
            return;
        }
        
        CGRect backFrame = btnBackGround.frame;
        backFrame.origin.y = 49;
        btnBackGround.frame = backFrame;
        btnBackGround.hidden = NO;
        chooseFlag = EChooseSecond;
    }
    else  if ((pos.y > 87) && (pos.y < 127))
    {
        if (!viewflag)
        {
            chooseFlag = EChooseDisalbe;
            return;
        }
        
        CGRect backFrame = btnBackGround.frame;
        backFrame.origin.y = 88;
        btnBackGround.frame = backFrame;
        btnBackGround.hidden = NO;
        chooseFlag = EChooseThird;
    }
    else
    {
        if ( isFour )
        {
            if ((pos.y > 127) && (pos.y < 167))
            {
                if ( !viewflag )
                {
                    chooseFlag = EChooseDisalbe;
                    return;
                }
                
                CGRect backFrame = btnBackGround.frame;
                backFrame.origin.y = 128;
                btnBackGround.frame = backFrame;
                btnBackGround.hidden = NO;
                chooseFlag = EChooseFour;
            }
            else
            {
                btnBackGround.hidden = YES;
            }
        }
        else
        {
            btnBackGround.hidden = YES; 
        }
    }
}

- (void)ShowView:(CGPoint)pos isTwo:(BOOL)isTwo
{
    chooseFlag = EChooseNone;
    
    if ((pos.x< 0)||(pos.x>167))
    {
        btnBackGround.hidden = YES;
        return;
    }
    
    if ((pos.y < 49) && (pos.y > 0))
    {
        CGRect backFrame = btnBackGround.frame;
        backFrame.origin.y = 9;
        btnBackGround.frame = backFrame;
        btnBackGround.hidden = NO;
        chooseFlag = EChooseFirst;
    }
    else
    {
        if ( isTwo )
        {
            if ((pos.y > 49) && (pos.y < 87))
            {
                if ( !viewflag )
                {
                    chooseFlag = EChooseDisalbe;
                    return;
                }
                
                CGRect backFrame = btnBackGround.frame;
                backFrame.origin.y = 49;
                btnBackGround.frame = backFrame;
                btnBackGround.hidden = NO;
                chooseFlag = EChooseSecond;
            }
            else
            {
                btnBackGround.hidden = YES;
            }
        }
        else
        {
            btnBackGround.hidden = YES;
        }
    }
}

-(void) dealloc{
    [super dealloc];
}


@end
