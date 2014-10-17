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

#import <Foundation/Foundation.h>

typedef enum{
    EReadState_Unread = 0,
    EReadState_IsRead
} EReadState;

typedef enum{
    EConverType_Message = 0,
    EConverType_Notice
}EConverType;


@interface IMConversation : NSObject
//消息id
@property (nonatomic, retain) NSString* conversationId;
//显示的联系人
@property (nonatomic, retain) NSString* contact;
//显示的时间
@property (nonatomic, retain) NSString* date;
//显示的内容
@property (nonatomic, retain) NSString* content;
//消息类型
@property (nonatomic, assign) EConverType type;
@end


typedef enum{
    EMessageType_Text = 0,
    EMessageType_File,
    EMessageType_Voice
}EMessageType;

typedef enum{
    EMessageState_Sending = 0,
    EMessageState_SendSuccess,
    EMessageState_SendFailed,
    EMessageState_Send_OtherReceived,
    EMessageState_Received
}EMessageState;

@interface IMMessageObj: NSObject

//消息id
@property (nonatomic, retain) NSString *msgid;

//会话的分组，群消息保存groupid 点对点保存对方voip
@property (nonatomic, retain) NSString *sessionId;

@property (nonatomic, assign) EMessageType msgtype;

//群组消息，消息的发送者voip； 点对点保存对方voip
@property (nonatomic, retain) NSString *sender;

@property (nonatomic, assign) EReadState isRead;

@property (nonatomic, assign) EMessageState imState;

@property (nonatomic, retain) NSString* dateCreated;
@property (nonatomic, retain) NSString* curDate;

@property (nonatomic, retain) NSString *userData;

//如果是文本信息则是内容
@property (nonatomic, retain) NSString *content;

@property (nonatomic, retain) NSString *fileUrl;
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSString *fileExt;
@property (nonatomic, assign) double duration;
@property (nonatomic, assign) BOOL isChunk;

@end

typedef enum{
    EGroupNoticeType_ApplyJoin = 401,
    EGroupNoticeType_ReplyJoin,
    EGroupNoticeType_InviteJoin,
    EGroupNoticeType_RemoveMember,
    EGroupNoticeType_QuitGroup,
    EGroupNoticeType_DismissGroup,
    EGroupNoticeType_JoinedGroup
}EGroupNoticeType;

typedef enum{
    EGroupNoticeOperation_NeedAuth = 0,
    EGroupNoticeOperation_UnneedAuth,
    EGroupNoticeOperation_Access,
    EGroupNoticeOperation_Reject
}EGroupNoticeOperation;

@interface IMGroupNotice : NSObject
@property (nonatomic, assign) NSInteger messageId;
@property (nonatomic, assign) EGroupNoticeType msgType;
@property (nonatomic, retain) NSString* verifyMsg;

//对于msgType=ApplyJoin、InviteJoin、ReplyJoin时使用
@property (nonatomic, assign) EGroupNoticeOperation state;
@property (nonatomic, retain) NSString* groupId;
@property (nonatomic, retain) NSString* who;
@property (nonatomic, retain) NSString* curDate;
@property (nonatomic, assign) EReadState isRead;
@end

@interface IMGroupInfo : NSObject
@property (nonatomic,retain) NSString* groupId; //群组ID
@property (nonatomic,retain) NSString* name; //群组名字
@property (nonatomic,retain) NSString* owner;//群组所有者（默认为管理员）
@property (nonatomic,assign) NSInteger type; //群组类型 0：临时组(上限100人)  1：普通组(上限300人)  2：VIP组 (上限500人)
@property (nonatomic,retain) NSString* declared; //群组公告
@property (nonatomic,retain) NSString* created; //该群组的创建时间
@property (nonatomic,assign) NSInteger count;//人数
@property (nonatomic,assign) NSInteger permission;//申请加入模式 0：默认直接加入1：需要身份验证 2:私有群组
@end