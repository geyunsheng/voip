//
//  LoginViewController.h
//  CCPVoipDemo
//
//  Created by Ge-Yunsheng on 2014/09/22.
//  Copyright (c) 2014年 hisun. All rights reserved.
//

#import "UIBaseViewController.h"
#import "AccountInfo.h"
#import "RadioButton.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate,RadioButtonDelegate>
{
    
    UITextField* _userID;
    UITextField* _userName;
 //   UITextField* _userCompany;
    UITextField* _userMail;
    NSString* _dateCreated;
    UIActivityIndicatorView* _myAct;
}

@property (strong, nonatomic) UITextField *userName;
@property (strong, nonatomic) UITextField *userID;
//@property (strong, nonatomic) UITextField *userCompany;
@property (strong, nonatomic) UITextField *userMail;
@property (copy, nonatomic) NSString *dateCreated;
@property (strong) UIActivityIndicatorView* myAct;
@property (retain, nonatomic) AccountInfo* userBasic;

- (void)login:(id)sender;

@end
