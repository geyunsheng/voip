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
#import <MessageUI/MessageUI.h>
#import "ModelEngineVoip.h"
#import "AppDefine.h"
#import "CommonTools.h"
#import "GetSearchDataObj.h"
#import <AddressBookUI/AddressBookUI.h>
#define theAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

typedef enum
{
    EDialNone = 0,
    EDialAction,        //点击拨号，弹出呼叫提示框了
    EDialCancel,        //用户取消呼叫
    EDialOut,           //用户点击呼叫
    EDialConnected,     //呼叫连接上
    EDialDisconnected   //呼叫被拒
} EDialState;


@interface UIBaseViewController : UIViewController<ModelEngineUIDelegate,UIImagePickerControllerDelegate,MFMessageComposeViewControllerDelegate,UIAlertViewDelegate>
{
    UILabel             *popLabel;
    UIImageView         *popTipView;
}

@property (retain, nonatomic)ModelEngineVoip                *modelEngineVoip;

@property (retain, nonatomic)NSString                       *voipCallID;

//系统界面,来电需要用到
@property (retain, nonatomic)UIImagePickerController        *imagePicker;
@property (retain, nonatomic)MFMessageComposeViewController *messageCompose;
@property (retain, nonatomic)ABNewPersonViewController      *contactsUI;

@property (nonatomic, retain)UIActionSheet                  *viewActionSheet;
- (void)popToPreView;
-(void)popPromptViewWithMsg:(NSString *)message;
-(void)popPromptViewWithNewMsg:(NSString *)message;
- (void)popPromptViewWithMsg:(NSString*)message AndFrame: (CGRect)frame;
- (void)displayProgressingView;
- (void)dismissProgressingView;
- (UIImage *) createImageWithColor: (UIColor *) color;
-(void)goChoosePhoneNumber;
-(void)goChooseMultiPhoneNumbers;
- (BOOL)isContactsAccessGranted;
@end
