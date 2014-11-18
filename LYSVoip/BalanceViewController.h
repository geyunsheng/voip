//
//  RemainViewController.h
//  LYSVoip
//
//  Created by Ge-Yunsheng on 2014/11/07.
//  Copyright (c) 2014年 atjava. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBaseViewController.h"
#import "AccountInfo.h"


@interface BalanceViewController : UIBaseViewController<UITextFieldDelegate>

@property (nonatomic, retain) AccountInfo* userBasic;
@property (nonatomic, strong) UILabel* labelSum;
@property (nonatomic, strong) UILabel* labelPhone;
@property (nonatomic, strong) UITextField* textStartTime;
@property (nonatomic, strong) UITextField* textEndTime;
@property (nonatomic, strong) UIDatePicker* picker;

@end
