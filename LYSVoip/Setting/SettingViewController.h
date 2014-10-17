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
#import "UIBaseViewController.h"
#import "CustomeAlertView.h"


@interface SettingViewController : UIBaseViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate,CustomeAlertViewDelegate>

@property (retain, nonatomic) UITableView *myTable;
@property (retain, nonatomic) UITextField *myTextField;

- (void)switchAction:(id)sender;

@end
