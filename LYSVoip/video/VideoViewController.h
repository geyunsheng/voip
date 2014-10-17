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

@interface VideoViewController : UIBaseViewController
{
    int hhInt;
    int mmInt;
    int ssInt;
    NSTimer *timer;
    NSInteger callStatus; //0:拨打电话 1:电话呼入 2:电话中
    BOOL p2pFlag;
    CGRect myFrame;
}

@property (nonatomic,retain) NSString *callID;
@property (nonatomic,retain) NSString *callerName;
@property (nonatomic,retain) NSString *voipNo;
@property (nonatomic, retain) UIView* bgView; //适配ios7使用
//挂断电话
@property (nonatomic,retain) UIButton *hangUpButton;
//接听
@property (nonatomic,retain) UIButton *acceptButton;
@property (nonatomic,retain) UILabel *netStatusLabel;
@property (nonatomic,retain) UILabel *tipsLabel;
@property (nonatomic,retain) UILabel *p2pStatusLabel;

/*name:被叫人的姓名，用于界面的显示(自己选择)
 voipNop:被叫人的voip账号，用于网络免费电话(也可用于界面的显示,自己选择)
 type:电话类型
 */
- (id)initWithCallerName:(NSString *)name andVoipNo:(NSString *)voipNop andCallstatus:(NSInteger)type;
@end
