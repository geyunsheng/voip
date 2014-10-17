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

@interface RoomNameViewController : UIBaseViewController<UITextFieldDelegate,UIScrollViewAccessibilityDelegate>
{
    BOOL isAutoClose;
    BOOL isAutoJoin;
    NSInteger square;
}
@property (nonatomic, assign) UIViewController *backView;
@property (nonatomic, retain) UIScrollView     *myScrollView;
@end
