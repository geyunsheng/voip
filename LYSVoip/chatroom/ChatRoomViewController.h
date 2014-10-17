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
#import "CustomeAlertView.h"

@interface ChatRoomViewController : UIBaseViewController<UITextFieldDelegate,UIAlertViewDelegate,CustomeAlertViewDelegate>
{
    UITextField *utextfield;
}
@property (nonatomic, assign) UIViewController *backView;
@property (nonatomic, retain) NSString* curChatroomId;
@property (nonatomic, retain) NSString* roomname;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSTimer *timerNetworkStatistic;
@property (nonatomic, assign) BOOL isCreator;
@property (nonatomic, assign) BOOL isCreatorExit;
-(void)createChatroomWithChatroomName:(NSString*)chatroomName andPassword:(NSString *)roomPwd andSquare:(NSInteger)square andKeywords:(NSString *)keywords inAppId:(NSString*)appid andIsAutoClose:(BOOL)isAutoClose andVoiceMod:(NSInteger) voiceMod andAutoDelete:(BOOL) autoDelete andIsAutoJoin:(BOOL) isAutoJoin;
- (void) joinChatroomInRoom:(NSString *)roomNo andPwd:(NSString *)pwd;
@end
