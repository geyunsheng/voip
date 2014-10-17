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

@interface UIselectContactsViewController : UIBaseViewController <UITableViewDataSource,
UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,CustomeAlertViewDelegate>
{
    NSInteger           selectedIndex;//单选用到，表示选到的
    NSInteger           lastSelectedIndex;//单选用到，表示最后选择的
    ESelectViewType     selectType;       //选择联系人的类型 0为创建延时语音会话的选择 1为创建实时语音会话的选择
    //2是voip拨打页面调用的选择，仅仅只有单选
    NSInteger           selectCount;
    UITextField         *utextfield;
    UITextField         *myTextField;
    int                 isConfirm;
}

@property (retain, nonatomic) UILabel             *headerLabel;
@property (retain, nonatomic) UILabel             *footerLabel;
@property (retain, nonatomic) UITableView          *myTableView;
@property (retain, nonatomic) NSMutableArray       *cellDataArray;
@property (assign, nonatomic) UIViewController     *backView;
@property (retain, nonatomic) NSString             *groupId;
- (id)initWithAccountList:(NSMutableArray*) list andSelectType:(ESelectViewType) type;

@end
