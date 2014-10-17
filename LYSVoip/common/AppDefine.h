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

//判断是否是iPhone5
#import "AppDelegate.h"
#define IPHONE5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define VIEW_BACKGROUND_COLOR_BLUE      [UIColor colorWithRed:70.0f/255.0f green:102.0f/255.0f blue:146.0f/255.0f alpha:1.0f]
#define VIEW_BACKGROUND_COLOR_FIRSTVIEW [UIColor colorWithRed:35.0f/255.0f green:47.0f/255.0f blue:60.0f/255.0f alpha:1.0f]
#define VIEW_BACKGROUND_COLOR_WHITE     [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0f]
#define VIEW_BACKGROUND_COLOR_GRAY      [UIColor colorWithRed:212.0f/255.0f green:212.0f/255.0f blue:212.0f/255.0f alpha:1.0f]
#define VIEW_BACKGROUND_COLOR_VIDEO     [UIColor colorWithRed:45.0f/255.0f green:52.0f/255.0f blue:61.0f/255.0f alpha:1.0f]
//#define ADDRESS_LOG_OPEN//是否放开日志
#define kKickedOff 2988
#define MENUVIEW_TAG 66666
#define IMGROUP_NOTIFY_MESSAGE_SOMEONE @"000notify000"
#ifdef ADDRESS_LOG_OPEN
# define ccp_AddressLog(...) NSLog(__VA_ARGS__)
#else
# define ccp_AddressLog(...) {}
#endif

#define Chatroom3_6_3_NewFlow


typedef enum
{
    ESelectViewType_VoipView,        //voip
    ESelectViewType_Video,
    ESelectViewType_InterphoneView,  //实时对讲
    ESelectViewType_IMMsgView,    //im消息
    ESelectViewType_GroupMemberView, //创建群组
    ESelectViewType_VideoConf,//视频会议
    ESelectViewType_transferCall//呼叫转移
} ESelectViewType;