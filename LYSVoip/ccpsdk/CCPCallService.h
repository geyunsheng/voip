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
#import <AVFoundation/AVAudioPlayer.h>
#import <UIKit/UIKit.h>
#import "CommonClass.h"
#define ShieldMosaic
enum EReason {
    EReasonNone,
    EReasonNoResponse,//无响应,无返回
    EReasonBadCredentials,//认证失败
    EReasonDeclined,//对方拒接
    EReasonNotFound,//拒接
    EReasonCallMissed,//
    EReasonBusy,
    EReasonNoNetwork,
    EReasonReFetchSoftSwitch,
    EReasonKickedOff,
    EReasonCalleeNoVoip,
    EReasonInvalidProxy
};

enum EMessageFailedResult {
    EMessageFailed,                 //发送短信失败
    EMessageRegisterFailed,         //没有登录
};

enum EVoipCallType{
    EVoipCallType_Voice = 0,
    EVoipCallType_Video
};

enum ENETWORK_STATUS{
    NETWORK_STATUS_NONE,
    NETWORK_STATUS_LAN,
    NETWORK_STATUS_WIFI,
    NETWORK_STATUS_GPRS,
    NETWORK_STATUS_3G
};

enum ECCPResult{
    ECCP_Success = 0,               //成功
    ECCP_Sending = 1,               //发送中
    ECCP_Failed  = -1               //失败
};

typedef enum  {
    Codec_iLBC = 0,
    Codec_G729,
    Codec_PCMU,
    Codec_PCMA,
    Codec_VP8,
    Codec_H264
} Codec;

typedef enum
{
    phonePolicyNoFirewall = 0,
    phonePolicyUseIce
} APPFirewallPolicy;

@class StatisticsInfo;

@interface CCPCallService : NSObject

#pragma mark - 初始化函数
//初始化呼叫(初始化和注册一起)
- (CCPCallService *)initWithDelegate:(id)delegate;
//设置代理方法
- (void)setDelegate:(id)delegate;

//登录
- (NSInteger)connectToCCP:(NSString *)proxy_addr onPort:(NSInteger)proxy_port withAccount:(NSString *)accountStr withPsw:(NSString *)passwordStr withAccountSid:(NSString *)accountSid withAuthToken:(NSString *)authToken;
//注销
-(NSInteger)disConnectToCCP;
#pragma mark - 呼叫控制函数
/**
 * 拨打电话
 * @param callType 电话类型
 * @param called 电话号(加国际码)或者VoIP号码
 * @return 本次电话的id
 */
- (NSString *)makeCallWithType:(NSInteger)callType andCalled:(NSString *)called;

/**
 * 回拨电话
 * @param src 主叫的电话（加国际码）
 * @param dest 被叫的电话（加国际码）
 * @param srcSerNum 主叫侧显示的号码，根据平台侧显号规则控制
 * @param destSerNum 被叫侧显示的客服号码，根据平台侧显号规则控制
 */
- (NSInteger)makeCallback:(NSString *)src withTOCall:(NSString *)dest andSrcSerNum:(NSString*) srcSerNum andDestSerNum:(NSString*) destSerNum;

/**
 * 挂断电话
 * @param callid 电话id
 */
- (NSInteger)releaseCall:(NSString *)callid;

/**
 * 挂断电话3.6.3以后版本可以使用
 * @param callid 电话id
 * @param reason 预留参数,挂断原因值，可以传入大于1000的值，通话对方会在onMakeCallFailed收到该值
 */
- (NSInteger)releaseCall:(NSString *)digid andReason:(NSInteger) reason;

/**
 * 接听电话
 * @param callid 电话id
 * V2.0
 */
- (NSInteger)acceptCall:(NSString*)callid;

/**
 * 接听电话
 * @param callid 电话id
 * @param callType 电话类型
 * V2.1
 */
- (NSInteger)acceptCall:(NSString*)callid withType:(NSInteger)callType;

/**
 * 开始通话录音
 * @param callid 电话id
 * @param filename 录音文件名，保存为wav格式
 */
- (NSInteger) startRecordVoiceCallWithCallid:(NSString*) callid andFilename:(NSString*) filename;

/**
 * 停止通话录音
 * @param callid 电话id
 */
- (NSInteger) stopRecordVoiceCallWithCallid:(NSString*) callid;

/**
 * 拒绝呼叫(挂断一样,当被呼叫的时候被呼叫方的挂断状态)
 * @param callid 电话id
 * @param reason 拒绝呼叫的原因, 可以传入ReasonDeclined:用户拒绝 ReasonBusy:用户忙
 */
- (NSInteger)rejectCall:(NSString *)callid andReason:(NSInteger) reason;
/**
 * 暂停通话
 * @param callid 电话id
 */
- (NSInteger)pauseCall:(NSString*)callid;

/**
 * 恢复通话
 * @param callid 电话id
 */
- (NSInteger)resumeCall:(NSString*)callid;

/**
 * 转接电话
 * @param callid 电话id
 * @param destination 转接目标电话
 * @param type 扩展字段，备用
 */
- (NSInteger)transferCall:(NSString*)callid withTransferID:(NSString *)destination andType:(NSInteger) type;

/**
 * 转接电话3.6.2及以前版本
 * @param callid 电话id
 * @param destination 转接目标电话
 */
- (NSInteger)transferCall:(NSString*)callid withTransferID:(NSString *)destination;

/**
 * 获取当前通话的callid
 * @return 电话id
 */
-(NSString*)getCurrentCall;

/**
 * 视频通话或者视频会议中获取本地图像
 * @param  callid 会话id
 * @return 成功返回数据 失败返回nil
 */
- (UIImage *)getLocalVideoSnapshotWithCallid:(NSString*)callid;

/**
 * 视频通话或者视频会议中获取对端的图像
 * @param  callid 会话id
 * @return 成功返回数据 失败返回nil
 */
- (UIImage *)getRemoteVideoSnapshotWithCallid:(NSString*)callid;

/**
 * 获取呼叫的媒体类型
 * @return 0音频，1视频
 */
- (NSInteger)getCallMediaType:(NSString*)digid;

//更新已存在呼叫的媒体类型
- (NSInteger)updateCallMedia:(NSString*)callid withType:(NSInteger)callType;

//回复对方的更新请求
//1 同意  0 拒绝
- (NSInteger)answerCallMediaUpdate:(NSString*)callid withAction:(NSInteger)action;
/**
 * 获取当前状态
 * @return 状态值
 */
- (BOOL)isOnline;

#pragma mark - DTMF函数
/**
 * 发送DTMF
 * @param callid 电话id
 * @param dtmf 键值
 */
- (NSInteger)sendDTMF:(NSString *)callid dtmf:(NSString *)dtmf;

#pragma mark - 基本设置函数

/**
 * 静音设置
 * @param on false:正常 true:静音
 */
- (NSInteger)setMute:(BOOL)on;

/**
 * 获取当前静音状态
 * @return false:正常 true:静音
 */
- (NSInteger)getMuteStatus;

/**
 * 获取当前免提状态
 * @return false:关闭 true:打开
 */
- (NSInteger)getLoudsSpeakerStatus;

/**
 * 免提设置
 * @param enable false:关闭 true:打开
 */
- (NSInteger)enableLoudsSpeaker:(BOOL)enable; 

//重置音频设备,应用挂起时调用无效，切换前台后马上调用容易失败，因为设备此时还未初始化完毕，如果想要启动后调用，可以在切换到前台后延时调用。
- (NSInteger)resetAudio:(BOOL)flag;
/**
 * 设置电话
 * @param phoneNumber 电话号
 */
- (void)setSelfPhoneNumber:(NSString *)phoneNumber;

/**
 * 设置昵称
 * @param nickName 昵称ftong
 */
- (void)setSelfName:(NSString *)nickName;

/**
 * 设置视频通话显示的view
 * @param view 对方显示视图
 * @param localView 本地显示视图
 */
- (NSInteger)setVideoView:(UIView*)view andLocalView:(UIView*)localView;

//发送本端旋转的角度，如果传递的图像在对端显示是颠倒的则传入负值
- (void)notifyTo:(NSString *)receiver AndVideoRotate:(NSInteger)degree;
/**
 * 获取摄像设备信息
 * @return 摄像设备信息数组
 */
- (NSArray*)getCameraInfo;

/**
 * 选择使用的摄像设备
 * @param cameraIndex 设备index
 * @param capabilityIndex 能力index
 * @param fps 帧率
 * @param rotate 旋转的角度
 */
- (NSInteger)selectCamera:(NSInteger)cameraIndex capability:(NSInteger)capabilityIndex fps:(NSInteger)fps rotate:(Rotate)rotate;

/**
 * 设置支持的编解码方式，默认全部都支持
 * @param codec 编解码类型
 * @param enabled 0:不支持 1:支持
 */
-(void)setCodecEnabledWithCodec:(Codec) codec andEnabled:(BOOL) enabled;

//设置客户端标示
- (void)setUserAgent:(NSString *)agent;

/**
* 设置音频处理的开关,在呼叫前调用
* @param type  音频处理类型. enum AUDIO_TYPE { AUDIO_AGC, AUDIO_EC, AUDIO_NS };
* @param enabled AGC默认关闭; EC和NS默认开启.
* @param mode: 各自对应的模式: AUDIO_AgcMode、AUDIO_EcMode、AUDIO_NsMode.
* @return  成功 0 失败 -1
*/
-(NSInteger)setAudioConfigEnabledWithType:(EAudioType) type andEnabled:(BOOL) enabled andMode:(NSInteger) mode;

/**
 * 设置视频通话码率
 * @param bitrates  视频码流，kb/s，范围30-300
 */
-(void)setVideoBitRates:(NSInteger)bitrates;


/**
* 保存Rtp数据到文件，只能在通话过程中调用，如果没有调用stopRtpDump，通话结束后底层会自动调用
* @param callid    回话ID
* @param mediaType 媒体类型， 0：音频 1：视频
* @param fileName  文件名
* @paramdirection  需要保存RTP的方向，0：接收 1：发送
* @return     成功 0 失败 -1 
*/
-(NSInteger) startRtpDump:(NSString*)callid andMediaType:(NSInteger) mediaType andFileName:(NSString*)fileName andDirection:(NSInteger) direction;

/**
* 停止保存RTP数据，只能在通话过程中调用。
* @param   callid :  会话ID
* @param   mediaType: 媒体类型， 0：音频 1：视频
* @param   direction: 需要保存RTP的方向，0：接收 1：发送
* @return  成功 0 失败 -1
*/
-(NSInteger) stopRtpDump:(NSString*)callid andMediaType:(NSInteger) mediaType  andDirection:(NSInteger) direction;

/**
 * 返回底层库版本信息
 * @ret  返回版本信息
 */
-(NSString*)getLIBVersion;

/**
 * 返回SDK版本信息
 * @ret  返回版本信息
 */
- (NSString*)getSDKVersion;

//获取SDK打包时间
- (NSString*)getSDKDate;
/**
 *统计通话质量
  @ret  返回丢包率等通话质量信息对象
 */
-(StatisticsInfo*)getCallStatistics;

/**
 *获取通话的网络流量信息
 * @param   callid :  会话ID,会议类传入房间号
   @ret  返回网络流量信息对象
 */
- (NetworkStatistic*)getNetworkStatisticWithCallId:(NSString*) callid;

//是否抑制马赛克
-(NSInteger) setShieldMosaic:(BOOL) flag;

#pragma mark - 实时对讲相关函数
/**
 * 创建实时对讲场景
 * @param members 邀请的对讲成员
 * @param appId 应用id
 */
- (void) startInterphoneWithJoiner:(NSArray*)members inAppId:(NSString*)appId;

/**
 * 加入实时对讲
 * @param confNo 实时对讲会议号
 */
- (void) joinInterphoneToConfNo:(NSString*)confNo;

/**
 * 退出当前实时对讲
 * @return false:失败 true:成功
 */
- (BOOL) exitInterphone;

/**
 * 实时对讲中，控麦
 * @param confNo 实时对讲会议号
 */
- (void) controlMicInConfNo:(NSString*)confNo;

/**
 * 实时对讲中，放麦
 * @param confNo 实时对讲会议号
 */
- (void) releaseMicInConfNo:(NSString*)confNo;

/**
 * 查询实时对讲中成员
 * @param confNo 实时对讲会议号
 */
- (void) queryMembersWithInterphone:(NSString*)confNo;

#pragma mark - 聊天室相关函数
/**
 * 创建群聊室
 * @param appId 应用id
 * @param roomName 房间名称
 * @param square 参与的最大方数
 * @param keywords 业务属性，有应用定义
 * @param roomPwd 房间密码，可为null
 * @param isAutoClose 创建者退出是否自动解散
 * @param voiceMod 背景音类型 默认值为1。0：无提示音有背景音；1：有提示音有背景音；2：无提示音无背景音；3：有提示音无背景音
 * @param autoDelete 是否永久会议
 * @param isAutoJoin 是否创建后自动加入会议
 */
- (void) startChatroomInAppId:(NSString *)appId withName:(NSString *)roomName andSquare:(NSInteger)square andKeywords:(NSString *)keywords andPassword:(NSString *)roomPwd andIsAutoClose:(BOOL)isAutoClose andVoiceMod:(NSInteger) voiceMod andAutoDelete:(BOOL) autoDelete andIsAutoJoin:(BOOL) isAutoJoin;

/**
 * 加入聊天室
 * @param roomNo 房间号
 * @param pwd    密码（可选）
 */
- (void) joinChatroomInRoom:(NSString *)roomNo andPwd:(NSString*) pwd;

/**
 * 退出当前聊天室
 * @return false:失败 true:成功
 */
- (BOOL) exitChatroom;

/**
 * 查询聊天室成员
 * @param roomNo 房间号
 */
- (void) queryMembersWithChatroom:(NSString *)roomNo;

/**
 * 查询聊天室列表
 * @param appId 应用id
 * @param keywords 业务属性
 */
- (void)queryChatroomsOfAppId:(NSString *)appId withKeywords:(NSString *)keywords;

/**
 * 外呼邀请成员加入聊天室
 * @param members 被邀请者的电话
 * @param roomNo 房间号
 * @param appId 应用id
 */
- (void)inviteMembers:(NSArray*)members joinChatroom:(NSString*)roomNo ofAppId:(NSString *)appId;

/**
 * 解散聊天室
 * @param appId 应用id
 * @param roomNo 房间号
 */
- (void) dismissChatroomWithAppId:(NSString*) appId andRoomNo:(NSString*) roomNo;

/**
 * 踢出聊天室成员
 * @param appId 应用id
 * @param roomNo 房间号
 * @param member 成员号码
 */
- (void) removeMemberFromChatroomWithAppId:(NSString*) appId andRoomNo:(NSString*) roomNo andMember:(NSString*) member;

//设置语音SRTP加密属性
-(NSInteger) setSrtpWithKey:(NSString*) key;

#pragma mark - 多媒体IM
/**
 * 发送录音
 * @param receiver  接收方的VoIP账号或群组id
 * @param path      音频文件本地保存路径
 * @param chunked   是否进行边录边上传
 * @param userdata  用户自定义数据 最大支持255个字符
 */
- (NSString*) startVoiceRecordingWithReceiver:(NSString*) receiver andPath:(NSString*) path andChunked:(BOOL) chunked andUserdata:(NSString*)userdata;

// 停止录音
-(void)stopVoiceRecording;

//取消录音上传chunked
- (void) cancelVoiceRecording;

/**
 * 播放语音文件
 * @param fileName 语音路径
 */
-(void)playVoiceMsg:(NSString*) path;

/**
 * 停止播放语音
 */
-(void)stopVoiceMsg;

/**
 * 获取语音文件时长
 * @param fileName 语音路径
 * @return 时长，单位ms
 */
-(long)getVoiceDuration:(NSString*) fileName;

/**
 * 发送多媒体信息及文本信息
 * @param receiver 接收方的VoIP账号或者是群组Id
 * @param text 发送内容。长度140字符
 * @param attached 附件的路径
 * @param userdata 用户自定义数据 最大支持255个字符  
 * @return 函数返回字符串 表示msgId
 */
- (NSString*) sendInstanceMessage:(NSString*) receiver andText:(NSString*) text andAttached:(NSString*) attached andUserdata:(NSString*)userdata;


/*下载附件API，该API根据数组中DownLoadInfo对象里的fileUrl字段进行下载，DownLoadInfo对象里的isChunked字段用来标示是否通过Chunked方式下载，默认是非Chunked方式下载，传入YES则使用Chunked方式下载；完成下载后通过onDownloadAttachedWithReason回调接口返回下载状态。*/
/**
 * 下载附件
 * @param 下载文件DownloadInfo数组
 */
- (void) downloadAttached:(NSArray*)urlList;

/**
 * 确认已成功下载IM附件
 * @param 消息id数组
 */
- (void) confirmInstanceMessageWithMsgId:(NSArray*) msgIds;

#pragma mark - 视频会议 video conference

/**
 * 创建视频会议
 * @param appId 应用id
 * @param conferenceName 会议名称
 * @param square 参与的最大方数
 * @param keywords 业务属性，有应用定义
 * @param conferencePwd 房间密码，可为null
 * @param isAutoClose 是否可以自动解散
 * @param voiceMod 背景音类型 默认值为1。0：无提示音有背景音；1：有提示音有背景音；2：无提示音无背景音；3：有提示音无背景音
 * @param autoDelete 是否永久会议
 * @param isAutoJoin 是否创建后自动加入会议
 */
- (void) startVideoConferenceInAppId:(NSString*)appId withName:(NSString *)conferenceName andSquare:(NSInteger)square andKeywords:(NSString *)keywords andPassword:(NSString *)conferencePwd andIsAutoClose:(BOOL)isAutoClose andVoiceMod:(NSInteger) voiceMod andAutoDelete:(BOOL) autoDelete andIsAutoJoin:(BOOL) isAutoJoin;

/**
 * 加入视频会议
 * @param conferenceId 会议号
 */
- (void) joinInVideoConference:(NSString *)conferenceId;

/**
 * 退出当前视频会议
 * @return false:失败 true:成功
 */
- (BOOL) exitVideoConference;

/**
 * 查询视频会议成员
 * @param conferenceId 会议号
 */
- (void) queryMembersInVideoConference:(NSString *)conferenceId;

/**
 * 查询视频会议列表
 * @param appId 应用id
 * @param keywords 业务属性
 */
- (void)queryVideoConferencesOfAppId:(NSString *)appId withKeywords:(NSString *)keywords;

/**
 * 解散视频会议
 * @param appId 应用id
 * @param conferenceId 会议号
 */
- (void) dismissVideoConferenceWithAppId:(NSString*) appId andVideoConference:(NSString*) conferenceId;

/**
 * 踢出视频会议成员
 * @param appId 应用id
 * @param conferenceId 会议号
 * @param member 成员号码
 */
- (void) removeMemberFromVideoConferenceWithAppId:(NSString*) appId andVideoConference:(NSString*)conferenceId andMember:(NSString*) member;

/**
 * 切换实时视频显示
 * @param voip 实时图像的voip
 * @param conferenceId 会议号
 * @param appId 应用id
 */
- (void) switchRealScreenToVoip:(NSString*)voip ofVideoConference:(NSString*)conferenceId inAppId:(NSString*)appId;

/**
 * 上传自己的头像数据
 * @param filename 头像数据
 * @param conferenceId 会议号
 */
- (void) sendLocalPortrait:(NSString*)filename toVideoConference:(NSString*)conferenceId;

/**
 * 下载视频会议头像列表
 * @param conferenceId 会议号
 */
- (void) getPortraitsFromVideoConference:(NSString*)conferenceId;

/**
 * 下载头像数据
 * @param portraitsList 下载的头像信息
 */
- (void)downloadVideoConferencePortraits:(NSArray*)portraitsList;

- (void) editTestNumWithOldPhoneNumber:(NSString*) oldPhoneNumber andNewPhoneNumber:(NSString*) newPhoneNumber andServerIP:(NSString*) server_IP andServerPort:(NSInteger) server_Port andServerVersion :(NSString*) serverVersion andMainAccount:(NSString*) mainAccount andMainToken:(NSString*) mainToken;

@end
