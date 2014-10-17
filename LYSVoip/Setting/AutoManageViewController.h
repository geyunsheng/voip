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

typedef enum
{
    EAutoManage = 0,        //自动增益控制
    EEchoCancelled,         //回音消除
    ESilenceRestrain,       //静音抑制
    EVideoStreamControl     //视频码流控制
} ESettingType;



@interface AutoManageViewController : UIBaseViewController<UITableViewDelegate, UITableViewDataSource>
{
    ESettingType            settingType;
    NSInteger               selectedIndex;//单选用到，表示选到的
    NSInteger               lastSelectedIndex;//单选用到，表示最后选择的
}

@property (retain, nonatomic) UILabel               *headerLabel;
@property (retain, nonatomic) UILabel               *footerLabel;
@property (retain, nonatomic) UITableView           *myTableView;
@property (retain, nonatomic) NSMutableArray        *cellDataArray;


- (id)initWithList:(NSMutableArray*)list WithType:(ESettingType)type;
- (void)goBack;

@end
