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

#import "AccountInfo.h"

@implementation AccountInfo
@synthesize subAccount;
@synthesize subToken;
@synthesize voipId;
@synthesize password;
@synthesize isChecked;
@synthesize userID;
@synthesize userName;
@synthesize userCompany;
@synthesize dateCreated;
@synthesize mail;

-(void)dealloc
{
    self.subAccount = nil;
    self.subToken = nil;
    self.voipId = nil;
    self.password = nil;
    self.userCompany = nil;
    self.userID = nil;
    self.userName = nil;
    self.dateCreated = nil;
    self.mail = nil;
    [super dealloc];
}
@end
