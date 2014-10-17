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
#import "MMGridView.h"
#import "EditGroupCardViewController.h"
#import "CustomeAlertView.h"

@interface GroupInfoViewController : UIBaseViewController<MMGridViewDelegate, MMGridViewDataSource, UIAlertViewDelegate,UITextFieldDelegate, UIActionSheetDelegate,UITableViewDataSource, UITableViewDelegate,CustomeAlertViewDelegate>
{
    UITextField* declaredTextField;
    UIButton *rightBtn;
    int      selectIndex;
    UIView*  selfview;
    UITableView *groupCardTableView;
}
@property (nonatomic, retain) IMGroupInfo *groupInfo;
@property (nonatomic, retain) IMGruopCard *groupCard;
@property (nonatomic, retain) UIViewController *backView;
@property (nonatomic, retain) UIImageView *titleImgView;
- (id)initWithGroupId:(NSString*)groupid andIsMyJoin:(BOOL)isJoin andPermission:(NSInteger)permission;
@end
