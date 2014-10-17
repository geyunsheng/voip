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
#define InComingCall1 0  //呼入
#define OutGoingCall1 1  //呼出
#define MuteFlagIsMute1 1 //静音
#define MuteFlagNotMute1 0 //非静音

#define kCallBg02pngVoip            @"call_bg02.png"

typedef enum
{
    IncomingCallStatus_accepting = 19,
    IncomingCallStatus_incoming,
    IncomingCallStatus_accepted,
    IncomingCallStatus_over
}IncomingCallStatus;

@interface VoipIncomingViewController : UIBaseViewController<ModelEngineUIDelegate,UITextFieldDelegate,CustomeAlertViewDelegate,UIActionSheetDelegate>
{
    int hhInt;
    int mmInt;
    int ssInt;
    NSTimer *timer;
    NSString *callID;
    UIImageView *backgroundImg;
     BOOL isLouder;
    id parentView;
    BOOL p2pFlag;
    UITextField         *utextfield;
}
@property (nonatomic, retain) UIView* bgView; //适配ios7使用
@property(nonatomic,retain) NSString *contactName;
@property(nonatomic,retain) NSString *contactPhoneNO;
@property(nonatomic,retain) NSString *contactVoip;
@property(nonatomic,retain) UILabel *lblIncoming;
@property(nonatomic,retain) UILabel *lblName;
@property(nonatomic,retain) UILabel *lblPhoneNO;
@property(nonatomic,retain) UIView *functionAreaView;
@property(nonatomic,retain) UIImage   *contactPortrait;
@property (nonatomic,retain) NSString *callID;
//挂断电话
@property (nonatomic,retain) UIButton *hangUpButton;
//拒接
@property (nonatomic,retain) UIButton *rejectButton;
//接听
@property (nonatomic,retain) UIButton *answerButton;
//键盘
@property (nonatomic,retain) UIButton *KeyboardButton;
//免提
@property (nonatomic,retain) UIButton *handfreeButton;
//静音
@property (nonatomic,retain) UIButton *muteButton;
//呼转
@property (nonatomic,retain) UIButton *transferCallButton;

@property (nonatomic,assign) IncomingCallStatus status;
@property (nonatomic,retain) UILabel *statusLabel;
@property (nonatomic,retain) UILabel *netStatusLabel;
@property (nonatomic,retain) UILabel *p2pStatusLabel;
@property (nonatomic,retain) UIActionSheet *menuActionSheet;
- (id)initWithName:(NSString *)name andPhoneNO:(NSString *)phoneNO andCallID:(NSString*)callid andParent:(id)viewController;

@end
