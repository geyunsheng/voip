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

#import "IMCommon.h"

@implementation IMConversation
@synthesize conversationId;
@synthesize contact;
@synthesize date;
@synthesize content;
@synthesize type;
- (void)dealloc
{
    self.conversationId = nil;
    self.contact = nil;
    self.date = nil;
    self.content = nil;
    [super dealloc];
}
@end

@implementation IMMessageObj
@synthesize msgid;
@synthesize sessionId;
@synthesize msgtype;
@synthesize sender;
@synthesize isRead;
@synthesize imState;
@synthesize dateCreated;
@synthesize curDate;
@synthesize userData;
@synthesize content;
@synthesize fileUrl;
@synthesize filePath;
@synthesize fileExt;
@synthesize duration;
@synthesize isChunk;
- (id)init
{
    if (self = [super init])
    {
        self.isChunk = NO;
    }
    return self;
}
- (void)dealloc
{
    self.fileExt = nil;
    self.filePath = nil;
    self.fileUrl = nil;
    self.content = nil;
    self.userData = nil;
    self.curDate = nil;
    self.dateCreated = nil;
    self.sender = nil;
    self.sessionId = nil;
    self.msgid = nil;
    [super dealloc];
}
@end

@implementation IMGroupNotice
@synthesize messageId;
@synthesize msgType;
@synthesize verifyMsg;
@synthesize state;
@synthesize groupId;
@synthesize who;
@synthesize curDate;
@synthesize isRead;
- (id)init
{
    if (self = [super init])
    {
        messageId = -1;
    }
    return self;
}

- (void)dealloc
{
    self.verifyMsg = nil;
    self.groupId = nil;
    self.who = nil;
    self.curDate = nil;
    [super dealloc];
}
@end

@implementation IMGroupInfo
@synthesize groupId;//群组ID
@synthesize name; //群组名字
@synthesize owner;//所有者
@synthesize type;//群组类型 0：临时组(上限100人)  1：普通组(上限300人)  2：VIP组 (上限500人)
@synthesize count;//人数
@synthesize permission;//申请加入模式 0：默认直接加入1：需要身份验证 2:私有群组
@synthesize declared; //群组公告
@synthesize created; //该群组的创建时间

-(id)init
{
    self = [super init];
    if (self)
    {
        self.declared = @"";
    }
    return self;
}
-(void)dealloc
{
    self.groupId = nil;
    self.name = nil;
    self.owner = nil;
    self.declared = nil;
    self.created = nil;
    [super dealloc];
}
@end