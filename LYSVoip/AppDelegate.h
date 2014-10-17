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
#define kKeyboardBtnpng             @"dial_icon.png"
#define kKeyboardBtnOnpng           @"dial_icon_on.png"
#define kHandsfreeBtnpng            @"handsfree_icon.png"
#define kHandsfreeBtnOnpng          @"handsfree_icon_on.png"
#define kMuteBtnpng                 @"mute_icon.png"
#define kMuteBtnOnpng               @"mute_icon_on.png"
#define kTransferCallBtnpng         @"call_transfer_icon.png"
#define kTransferCallBtnOnpng       @"call_transfer_icon_on.png"
#import <UIKit/UIKit.h>


NSInteger globalcontactsChanged;
NSInteger globalContactID;
NSInteger contactOptState;

@class ModelEngineVoip;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) ModelEngineVoip *modeEngineVoip;
//用于输出日志
-(void)printLog:(NSString*)log;
-(void)logout;
@end

