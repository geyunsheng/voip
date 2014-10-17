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
#import "HPGrowingTextView.h"

@interface EditGroupCardViewController : UIBaseViewController<UITextFieldDelegate,HPGrowingTextViewDelegate>
{
    NSInteger type;
    NSInteger count;
    HPGrowingTextView   *textView;
    IMGruopCard* myGroupCard;
    UILabel* label;
}
@property (nonatomic, retain)    UITextField* textField;
- (id)initWithType:(NSInteger)   editType andGroupCard:(IMGruopCard*) groupCard;
@end
