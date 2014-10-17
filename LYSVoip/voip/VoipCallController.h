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
#import "ModelEngineVoip.h"
#import "CustomeAlertView.h"
#define InComingCall 0  //呼入
#define OutGoingCall 1  //呼出
#define MuteFlagIsMute 1 //静音
#define MuteFlagNotMute 0 //非静音

@interface VoipCallController : UIBaseViewController <ModelEngineUIDelegate,UITextFieldDelegate,CustomeAlertViewDelegate,UIActionSheetDelegate>
{
    int hhInt;
    int mmInt;
    int ssInt;
    NSTimer *timer;
    NSString *callID;
    BOOL isLouder;
    NSInteger voipCallType; //0:免费网络通话 1:直拨 2:回拨
    BOOL p2pFlag;
    UITextField         *utextfield;
}

@property (nonatomic,retain) NSString *callID;
@property (nonatomic,assign) int callDirection;
@property (nonatomic,retain) NSString *callerName;
@property (nonatomic,retain) NSString *callerNo;
@property (nonatomic,retain) NSString *voipNo;

@property (nonatomic,retain) UILabel *topLabel;
@property (nonatomic,retain) UILabel *callerNameLabel;
@property (nonatomic,retain) UILabel *callerNoLabel;
@property (nonatomic,retain) UILabel *realTimeStatusLabel;
@property (nonatomic,retain) UILabel *statusLabel;
@property (nonatomic,retain) UILabel *netStatusLabel;
@property (nonatomic,retain) UILabel *p2pStatusLabel;
@property (nonatomic,retain) UIView *functionAreaView;
@property (nonatomic, retain) UIView* bgView; //适配ios7使用
//挂断电话
@property (nonatomic,retain) UIButton *hangUpButton;
//键盘
@property (nonatomic,retain) UIButton *KeyboardButton;
//免提
@property (nonatomic,retain) UIButton *handfreeButton;
//静音
@property (nonatomic,retain) UIButton *muteButton;
//呼转
@property (nonatomic,retain) UIButton *transferCallButton;
@property (nonatomic,retain) UIActionSheet *menuActionSheet;
/*name:被叫人的姓名，用于界面的显示(自己选择)
 phoneNo:被叫人的真正的电话号，用于电话直拨，电话回拨(也可用于界面的显示,自己选择)
 voipNop:被叫人的voip账号，用于网络免费电话(也可用于界面的显示,自己选择)
 type:电话类型
 */
- (VoipCallController *)initWithCallerName:(NSString *)name andCallerNo:(NSString *)phoneNo andVoipNo:(NSString *)voipNop andCallType:(NSInteger)type;

@end
