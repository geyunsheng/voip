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

#import <UIKit/UIKit.h>
#import "AppDefine.h"

@protocol UIViewDelegate <NSObject>

-(void)ChooseWithFlag:(NSInteger) Flag;//返回1代表选择按钮1； 返回2代表选择按钮2 返回其他值则认为是啥都没选
@end

typedef enum
{
    EChooseNone = 0,
    EChooseFirst,
    EChooseSecond,
    EChooseThird,
    EChooseFour,
    EChooseDisalbe
} EChooseFlag;

@interface UICustomView : UIView
{
    UIImageView             *btnBackGround;
    UIImageView             *menuImageView;
    UILabel                 *btn1Label;
    UILabel                 *btn2Label;
    UILabel                 *_btn3Label;
    UILabel                 *_btn4Label;
    id<UIViewDelegate>      viewDelegate;
    NSInteger               chooseFlag;
    BOOL                    viewflag;
}

- (void)set_Delegate:(id)delegate;

- (id)initWithFrame:(CGRect)frame andLabel1Text:(NSString *)label1Text andLabel2Text:(NSString *)label2Text;
- (id)initWithFrame:(CGRect)frame andLabel1Text:(NSString *)label1Text andLabel2Text:(NSString *)label2Text andLabel3Text:(NSString *)label3Text  andLabel4Text:(NSString *)label4Text;

@end


