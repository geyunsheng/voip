//
//  UserBasicInfo.m
//  LYSVoip
//
//  Created by Ge-Yunsheng on 2014/09/29.
//  Copyright (c) 2014年 hisun. All rights reserved.
//

#import "UserBasicInfo.h"

@implementation UserBasicInfo
@synthesize userCompany;
@synthesize userName;
//@synthesize uuid;
@synthesize userID;


-(void)dealloc
{
    self.userCompany = nil;
    self.userName = nil;
 //   self.uuid = nil;
    self.userID = nil;
    [super dealloc];
}
@end
