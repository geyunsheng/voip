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

#ifndef CCPVoipDemo_DefineAndEnum_h
#define CCPVoipDemo_DefineAndEnum_h


//REST服务器
#define VOIP_SERVICEIP      @"app.cloopen.com"
#define VOIP_SERVICEPORT    @"8883"

#define CONFIG_FILE_NAME    @"config.plist"
//config.plist文件中的key
#define CONFIG_KEY_SERVERIP         @"serverip"
#define CONFIG_KEY_SERVERPORT       @"serverport"
#define CONFIG_KEY_APPID            @"app_id"
#define CONFIG_KEY_MAINACCOUNT      @"main_account"
#define CONFIG_KEY_MAINTOKEN        @"main_token"
#define CONFIG_KEY_APPID            @"app_id"
#define CONFIG_KEY_SUBACCOUNTSINFO  @"subaccounts_info"

//config.plist文件中的子信息内容
#define CONFIG_KEY_SUBACCOUNT       @"sub_account"
#define CONFIG_KEY_SUBTOKEN         @"sub_token"
#define CONFIG_KEY_VOIPACCOUNT      @"voip_account"
#define CONFIG_KEY_VOIPPASSWORD     @"voip_password"


//notification
#define KNOTIFICATION_DISMISSMODALVIEW      @"Notification_DismissModalView"

#define KEY_REASON          @"reason"
#define KEY_CALLID          @"callid"
#define KEY_CALLNUMBER      @"callnumber"
#define KEY_TYPE            @"calltype"
#define KEY_CALL_TYPE       @"voipcalltype"
#define KEY_CALLERNAME      @"callername"
#define KEY_CALLERPHONE     @"callerphone"

typedef enum
{
    ERegisterNot=0,         //没有登录
    ERegistering,           //登录中
    ERegisterSuccess,       //登录成功
    ERegisterFail,          //登录失败
    ERegisterLogout         //注销
}ERegisterResult;

typedef enum
{
    ENetworkStatus_NONE=0,   //没有网络
    ENetworkStatus_WIFI,     //WIFI网络
    ENetworkStatus_GPRS,     //2G网络
    ENetworkStatus_3G        //3G网络
}ENetworkStatusResult;

typedef enum
{
    ECallStatus_NO=0,               //没有呼叫
    ECallStatus_Calling,            //呼叫中
    ECallStatus_Proceeding,         //服务器有回应
    ECallStatus_Alerting,           //对方振铃
    ECallStatus_Answered,           //对方应答
    ECallStatus_Pasused,            //保持成功
    ECallStatus_PasusedByRemote,    //被对方保持
    ECallStatus_Resumed,            //恢复通话
    ECallStatus_ResumedByRemote,    //对方恢复通话
    ECallStatus_Released,           //通话释放
    ECallStatus_Failed,             //呼叫失败
    ECallStatus_Incoming,           //来电
    ECallStatus_Transfered,         //呼叫转移
    ECallStatus_CallBack,           //回拨成功
    ECallStatus_CallBackFailed      //回拨失败
}ECallStatusResult;

typedef enum
{
    EMessageStatus_Received,        //接受消息
    EMessageStatus_Send,            //发送消息成功
    EMessageStatus_Sending,         //发送消息中
    EMessageStatus_SendFailed       //发送消息失败
}EMessageStatusResult;

#endif
