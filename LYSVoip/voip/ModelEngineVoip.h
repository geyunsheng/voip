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
#import "CCPCallService.h"
#import "CCPCallEvent.h"
#import "DefineAndEnum.h"
#import "IMMsgDBAccess.h"
#import "AsyncUdpSocket.h"
#import "CommonClass.h"
#import "EmojiConvertor.h"
#import "AddressBookContactList.h"
#define VIDEOSTREAM_CONTENT_KEY         @"ContentOfVideoStream"
#define AUTOMANAGE_KEY                  @"AutoManage"
#define ECHOCANCELLED_KEY               @"EchoCancelled"
#define SILENCERESTRAIN_KEY             @"SilenceRestrain"
#define VIDEOSTREAM_KEY                 @"VideoStream"

#define VOICE_CHUNKED_SEND_KEY          @"VoiceChunkedSendKey"
#define SHIELDMOSAIC_KEY                @"ShieldMosaicKEY"
#define RECORDVOICE_KEY                 @"RECORDVOICEKEY"

//保存到NSUserDefaults中的key
#define AUTOMANAGE_INDEX_KEY        @"IndexOfAutoManage"
#define AUTOMANAGE_CONTENT_KEY      @"ContentOfAutoManage"
#define ECHOCANCELLED_INDEX_KEY     @"IndexOfEchoCancelled"
#define ECHOCANCELLED_CONTENT_KEY   @"ContentOfEchoCancelled"
#define SILENCERESTRAIN_INDEX_KEY   @"IndexOfSilenceRestrain"
#define SILENCERESTRAIN_CONTENT_KEY @"ContentOfSilenceRestrain"
typedef enum {
    ERequestType_NetError = 170005,
    ERequestType_XmlError = 170004
} ERequest_State;

//多媒体IM信息成员类
@interface IMMember : NSObject
@property (nonatomic, retain) NSString *sid;//VoIP账号
@property (nonatomic, retain) NSString *display;//名字
@property (nonatomic, retain) NSString *sex;//性别
@property (nonatomic, retain) NSString *birth;//生日
@property (nonatomic, retain) NSString *tel;//电话
@property (nonatomic, retain) NSString *sign;//的签名信息
@property (nonatomic, retain) NSString *received;
@end

//多媒体IM群名片类
@interface IMGruopCard : NSObject
@property (nonatomic, retain) NSString *display;//名字
@property (nonatomic, retain) NSString *sid;//Voip账号
@property (nonatomic, retain) NSString *tel;//电话
@property (nonatomic, retain) NSString *mail;//邮箱
@property (nonatomic, retain) NSString *remark;//备注
@property (nonatomic, retain) NSString *belong;//所属的群组ID
@end

@protocol ModelEngineUIDelegate <NSObject>
@optional
//登录的信息
-(void)responseVoipRegister:(ERegisterResult)event data:(NSString *)data;

//网络环境信息
-(void)responseNetworkStatus:(ENetworkStatusResult)event data:(NSString *)data;

//voip电话状态信息管理
-(void)responseVoipManagerStatus:(ECallStatusResult)event callID:(NSString*)callid data:(NSString *)data;

//voip文字信息管理
-(void)responseMessageStatus:(EMessageStatusResult)event callNumber:(NSString*)callNumber data:(NSString *)data;

//账号在其他客户端登录消息提示
-(void)responseKickedOff;
//p2p成功
-(void) onFirewallPolicyEnabled;
/********************语音留言的方法********************/
-(void)responseUploadChunkedVoiceMessageStatus:(int)event andGroupID:(NSString*)groupid;
//上传语音文件成功
-(void)responseUploadVoiceMessageStatus:(int)event andGroupID:(NSString*)groupid;
//获取群组成员
-(void)responseMemberListStatus:(int)event andToIDStr:(NSString*)toStr;
//通知客户端当前录音振幅
-(void)responseRecordingAmplitude:(double) amplitude;
//播放完成
-(void)responseFinishedPlaying;
//录音超时
-(void)responseRecordingTimeOut:(int) ms;
//来电信息
-(void)incomingCallID:(NSString*)callid caller:(NSString*)caller phone:(NSString*)phone name:(NSString*)name callStatus:(int)status callType:(NSInteger)calltype;


/********************实时语音的方法********************/

//通知客户端收到新的实时语音信息
- (void)onReceiveInterphoneMsg:(InterphoneMsg*) receiveMsgInfo;

//启动对讲场景状态
- (void)onInterphoneStateWithReason:(CloopenReason *) reason andConfNo:(NSString*)confNo;

//发起对讲——抢麦
- (void)onControlMicStateWithReason:(CloopenReason *) reason andSpeaker:(NSString *)voip;

//结束对讲——放麦
- (void)onReleaseMicStateWithReason:(CloopenReason *) reason;

//获取对讲场景的成员
- (void)onInterphoneMembersWithReason:(CloopenReason *) reason andData:(NSArray*)members;

/********************视频通话的方法********************/
- (void)onMessageRemoteVideoRotate:(NSString*)degree;
//收到对方请求的更新媒体
//request：0  请求增加视频（需要响应） 1:请求删除视频（不需要响应）
- (void)onCallMediaUpdate:(NSString *)callid withRequest:(NSInteger)request;

//对方应答请求更新媒体
//更新后的媒体状态 0 有视频 1 无视频
- (void)onCallMediaUpdate:(NSString *)callid withResponse:(NSInteger)response;

//视频分辨率发生改变
//resolution eg.640*960
- (void)onCallVideoRatioChanged:(NSString *)callid withResolution:(NSString *)resolution;

/********************聊天室的方法********************/

//通知客户端收到新的聊天室信息
- (void)onReceiveChatroomMsg:(ChatroomMsg*) receiveMsgInfo;

//聊天室状态
- (void)onChatroomStateWithReason:(CloopenReason *) reason andRoomNo:(NSString*)roomNo;

//获取聊天室的成员
- (void)onChatroomMembersWithReason:(CloopenReason *) reason andData:(NSArray*)members;

//获取聊天室
- (void)onChatroomsInAppWithReason:(CloopenReason *) reason andRooms:(NSArray*)chatrooms;

//邀请加入聊天室
- (void)onChatroomInviteMembersWithReason:(CloopenReason *) reason andRoomNo:(NSString*)roomNo;

/**
 * 解散聊天室回调
 * @param reason 状态值 0:成功
 * @param roomNo 房间号
 */
- (void) onChatroomDismissWithReason:(CloopenReason *) reason andRoomNo:(NSString*) roomNo;

/**
 * 移除成员
 * @param reason 状态值 0:成功
 * @param member 成员号
 */
- (void) onChatroomRemoveMemberWithReason:(CloopenReason *) reason andMember:(NSString*) member;

/********************多媒体IM的方法********************/
//发送多媒体IM结果回调
- (void) onSendInstanceMessageWithReason: (CloopenReason *) reason andMsg:(InstanceMsg*) data;
//下载文件状态返回
-(void)responseDownLoadMediaMessageStatus:(CloopenReason *)event;
//im群组消息通知
-(void)responseIMGroupNotice:(NSString*)groupId data:(NSString *)data;
/********************网络检测的方法********************/
//udp方式检测网络的返回
-(void)onTestUdpNetStatus:(NSInteger)event andReceivedTime:(NSInteger) ms;
-(void)onTestUdpNetSucceedCount:(NSInteger)count;

/********************外呼通知及语音验证码的方法********************/
//外呼通知返回状态
- (void)onLandingCAllsStatus:(CloopenReason*)reason andCallSid:(NSString*)callSid andToPhoneNumber:(NSString*)phoneNumber andDateCreated:(NSString*)dateCreated;
//语音验证码返回状态
- (void)onVoiceCode:(CloopenReason*)reason;

/********************多媒体IM群组的方法********************/
//创建群组回调
- (void) onGroupCreateGroupWithReason: (CloopenReason*) reason andGroupId:(NSString*)groupId;

//修改群组回调
- (void) onGroupModifyGroupWithReason: (CloopenReason*) reason;

//删除群组回调
- (void) onGroupDeleteGroupWithReason: (CloopenReason*) reason;

//获取公共群组回调
- (void) onGroupQueryPublicGroupsWithReason:(CloopenReason*) reason andGroups:(NSArray*) groups;

//搜索公共群组回调
- (void) onGroupSearchPublicGroupsWithReason:(CloopenReason*) reason andGroups:(NSArray*) groups;

//查询群组回调
- (void) onGroupQueryGroupWithReason:(CloopenReason*) reason andGroup:(IMGroupInfo*) group;

//申请加入群组回调
- (void) onGroupJoinGroupWithReason: (CloopenReason*) reason;

//管理员邀请加入群组回调
- (void) onGroupInviteJoinGroupWithReason: (CloopenReason*) reason;

//群组管理员删除成员回调
- (void) onGroupDeleteGroupMemberWithReason: (CloopenReason*) reason;

//成员主动退出群组回调
- (void) onGroupLogoutGroupWithReason: (CloopenReason*) reason;

/********************多媒体IM群组成员的方法********************/
//添加成员回调
- (void) onMemberAddMemberWithReason: (CloopenReason*) reason;

//修改成员回调
- (void) onMemberModifyMemberWithReason: (CloopenReason*) reason;

//删除成员回调
- (void) onMemberDeleteMemberWithReason: (CloopenReason*) reason;

//查询成员
- (void) onMemberQueryMemberWithReason: (CloopenReason*) reason andMembers:(NSArray*)members;

//查询成员加入的群组
- (void) onMemberQueryGroupWithReason: (CloopenReason*) reason andGroups:(NSArray*)groups;

//管理员对用户禁言回调
- (void)onForbidSpeakWithReason: (CloopenReason*) reason;

//管理员验证用户申请加入群组回调
- (void) onMemberAskJoinWithReason: (CloopenReason*) reason;

//用户验证邀请加入群组回调
- (void) onMemberInviteGroupWithReason: (CloopenReason*) reason;

//修改群名片回调
-(void) onModifyGroupCardWithReason:(CloopenReason*) reason;

//查询群名片回调
-(void) onQueryCardWithReason:(CloopenReason*) reason andGroupCard:(IMGruopCard*) groupCard;

/********************专家咨询回调接口********************/

- (void)onGetServiceNumWithReason:(CloopenReason*)reason;
- (void)onGetCategoryListWithReason:(CloopenReason*)reason andCategorys:(NSMutableArray*)categoryArray;
- (void)onGetExpertListWithReason:(CloopenReason*)reason andExperts:(NSMutableArray*)expertArray;
- (void)onLoceExpertWithReason:(CloopenReason*)reason;

/********************视频会议的方法********************/
//通知客户端收到新的聊天室信息
- (void)onReceiveVideoConferenceMsg:(VideoConferenceMsg*) msg;

//聊天室状态
- (void)onVideoConferenceStateWithReason:(CloopenReason *) reason andConferenceId:(NSString*)conferenceId;

//获取聊天室的成员
- (void)onVideoConferenceMembersWithReason:(CloopenReason *) reason andData:(NSArray*)members;

//获取聊天室（获取房间列表回调方法）
- (void)onVideoConferencesWithReason:(CloopenReason *) reason andConferences:(NSArray*)conferences;

//邀请加入聊天室
- (void)onVideoConferenceInviteMembersWithReason:(CloopenReason *) reason andConferenceId:(NSString*)conferenceId;

/**
 * 解散聊天室回调
 * @param reason 状态值 0:成功
 * @param roomNo 房间号
 */
- (void) onVideoConferenceDismissWithReason:(CloopenReason *) reason andConferenceId:(NSString*) conferenceId;

/**
 * 移除成员
 * @param reason 状态值 0:成功
 * @param member 成员号
 */
- (void) onVideoConferenceRemoveMemberWithReason:(CloopenReason *) reason andMember:(NSString*) member;

/**
 * 切换主屏幕回调
 * @param reason 状态值 0:成功
 */
- (void) onSwitchRealScreenToVoipWithReason:(CloopenReason *) reason;

/**
 * 发送头像到视频会议
 * @param reason 状态值 0:成功
 * @param portraitPath 本地头像路径
 */
- (void) onSendLocalPortraitWithReason:(CloopenReason *) reason andPortrait:(NSString*)portraitPath;

/**
 * 获取视频会议中的成员头像
 * @param reason 状态值 0:成功
 * @param portraitlist 成员头像列表
 */
- (void) onGetPortraitsFromVideoConferenceWithReason:(CloopenReason *) reason andPortraitList:(NSArray*)portraitlist;
/**
 * 下载头像
 * @param reason 状态值 0:成功
 * @param portrait 成员头像信息
 */
- (void) onDownloadVideoConferencePortraitsWithReason:(CloopenReason *) reason andPortrait:(VideoPartnerPortrait*) portrait;

/**
 * 获取账号
 * @param reason 状态值 0:成功
 */
//- (void)onGetDemoAccountsWithReason:(CloopenReason *)reason;
/**
 * 获取本地视频
 * @param portraitPath 成员头像路径
 */
-(void)onGetLocalPortrait:(NSString *)portraitPath;

- (void) onEditTestNumWithReason:(CloopenReason *) reason;

@end

@interface ModelEngineVoip : NSObject<CCPCallEventDelegate,AsyncUdpSocketDelegate>
{    
    NSTimer* udpTestTimer;
    NSInteger testCount;
    NSInteger succeedCount;
    BOOL isSendingPortrait;
    //头像缓存字典
    NSMutableDictionary *portraitDic;
    //联系人缓存列表
    NSMutableDictionary *contactAllDic;
    BOOL contactsChange;//通讯录是否改变
    BOOL isKickedOff;
}

@property (nonatomic, assign)id<ModelEngineUIDelegate> UIDelegate;

@property (nonatomic, retain)CCPCallService         *VoipCallService;

@property (nonatomic,copy)NSString                *mainAccount;     //voip主账号
@property (nonatomic,copy)NSString                *mainToken;       //voip主账号令牌
@property (nonatomic,copy)NSString                *appID;           //应用ID
@property (nonatomic,copy)NSString                *appName;           //应用名字
@property (nonatomic,copy)NSString                *voipName;        //名字或者呢称
@property (nonatomic,copy)NSString                *voipPhone;       //电话号码
@property (nonatomic,copy)NSString                *voipAccount;     //voip账号
@property (nonatomic,copy)NSString                *subAccountSid;   //子账户
@property (nonatomic,copy)NSString                *subAuthToken;    //子账号令牌
@property (nonatomic,copy)NSString                *voipPasswordStr; //voip密码
@property (nonatomic,copy)NSString                *serverIP;        //服务器地址
@property (nonatomic,assign)NSInteger             serverPort;       //服务器端口
@property (nonatomic,assign)BOOL                    appIsActive;    //是否在前台
@property (assign, nonatomic)ERegisterResult        registerResult;
@property (assign, nonatomic)ENetworkStatusResult   networkStatusResult;
@property (assign, nonatomic)ECallStatusResult      callStatusResult;
@property (nonatomic, retain)IMMsgDBAccess         *imDBAccess;
@property (nonatomic, retain)NSMutableArray               *vMsgs;   //语音留言消息对象
@property (assign, nonatomic)int unDownLoadedCount;                 //待下载语音留言文件数量

@property (nonatomic, retain)NSMutableArray *interphoneArray;
@property (nonatomic, retain)NSString *curInterphoneId;

@property (nonatomic, retain)NSMutableArray *accountArray;

@property (nonatomic, retain)NSMutableArray *chatroomListArray;

@property (nonatomic, retain)NSMutableArray *videoconferenceListArray;

@property (nonatomic, retain)NSMutableArray *attachDownArray;

@property (nonatomic, retain)NSMutableArray *test_numberArray;
@property (nonatomic, retain)NSString       *registeredPhone;
@property (nonatomic, retain)NSString       *developerUserName;
@property (nonatomic, retain)NSString       *developerNickName;
@property (nonatomic, retain)NSString       *developerUserPasswd;
@property (nonatomic, retain)AsyncUdpSocket *udpSocket;
@property (nonatomic, retain)NSString* ivrPhone;
@property (nonatomic, retain)NSString* myVoipPhone;
@property (nonatomic, retain)EmojiConvertor *emojiCon;
@property (nonatomic, retain)NSString *rejectCallId;

//通讯录
@property (nonatomic,retain)  AddressBookContactList *addressBookContactList;
@property (nonatomic,retain) UIImage* defaultContactIcon;
@property (nonatomic,retain ) NSMutableDictionary *contactAllDic;
+ (ModelEngineVoip*)getInstance;

#pragma mark - 初始化函数
//设置代理方法
- (void)setModalEngineDelegate:(id)delegate;
- (void)setVoipDelegate:(id)delegate;

#pragma mark - 语音留言相关函数
// 停止当前录音
-(void)stopCurRecording;
-(void)cancelVoiceRecording;
// 播放语音文件
-(void)playVoiceMsg:(NSString*) fileName;
// 停止当前播放语音
-(void)stopVoiceMsg;
// 获取语音文件的播放时长
-(long)getVoiceDuration:(NSString*) fileName;

//登录
- (NSInteger)connectToCCP:(NSString *)rest_addr onPort:(NSInteger)rest_port withAccount:(NSString *)accountStr withPsw:(NSString *)passwordStr withAccountSid:(NSString *)accountSid withAuthToken:(NSString *)authToken;
//设置用户名字
- (void)setVoipUserName:(NSString *)username;

#pragma mark - 呼叫控制函数
//呼叫
/*
 called 被叫人的voip账号，网络免费电话使用
 phone 被叫人的电话号，网络直拨电话使用
 callType 电话类型，视频或语音
 voiptype 根据类型，网络免费电话(voip账号) 或 网络电话直拨(电话号)
 */
- (NSString *)makeCall:(NSString *)called withPhone:(NSString*)phone withType:(NSInteger)callType withVoipType:(NSInteger)voiptype;
//挂断呼叫
- (NSInteger)releaseCall:(NSString *)callid;
//接受呼叫
- (NSInteger)acceptCall:(NSString*)callid;
//v2.1
- (NSInteger)acceptCall:(NSString*)callid withType:(NSInteger)callType;
//拒绝呼叫(挂断一样,当被呼叫的时候被呼叫方的挂断状态) callid是通话id，reason是拒绝呼叫的原因, 可以传入ReasonDeclined:用户拒绝 ReasonBusy:用户忙
- (NSInteger)rejectCall:(NSString *)callid andReason:(NSInteger) reason;
//暂停通话
- (NSInteger)pauseCall:(NSString*)callid;
//恢复通话
- (NSInteger)resumeCall:(NSString*)callid;
//转让到另一路电话
- (NSInteger)transferCall:(NSString*)callid withTransferID:(NSString *)destination;
//获取通话状态
//- (int)getCallState:(NSString *)callID;

//获取呼叫的媒体类型
- (NSInteger)getCallMediaType:(NSString*)callid;

- (NSString*)getCurrentCall;

//回拨电话
- (NSInteger)callback:(NSString *)fromPhone withTOCall:(NSString *)toPhone;
#pragma mark - DTMF函数
//发DTMF,单独拨一个数字号
- (NSInteger)sendDTMF:(NSString*)callid dtmf:(NSString *)dtmf;

#pragma mark - 基本设置函数
//静音或取消静音
- (NSInteger)setMute:(BOOL)on;
//获取静音状态
- (NSInteger)getMuteStatus;
//开启或关闭扬声器
- (NSInteger)enableLoudsSpeaker:(BOOL)flag;

- (NSInteger)setVideoView:(UIView *)view andLocalView:(UIView*)localView;
//获取摄像头信息
- (NSArray*)getCameraInfo;
//选取摄像头
- (NSInteger)selectCamera:(NSInteger)cameraIndex capability:(NSInteger)capabilityIndex fps:(NSInteger)fps rotate:(Rotate)rotate;
//设置用户手机号
- (void)setVoipUserPhone:(NSString *)phone;
//延时呼叫，处理多路打来排队进入
-(void)delayCall:(NSTimer*)theTimer;
//设置音频处理的开关,在呼叫前调用
-(NSInteger)setAudioConfigEnabledWithType:(EAudioType) type andEnabled:(BOOL) enabled andMode:(NSInteger) mode;
//设置视频通话码率  bitrates  视频码流，kb/s，范围30-300
-(void)setVideoBitRates:(NSInteger)bitrates;
//保存Rtp数据到文件，只能在通话过程中调用，如果没有调用stopRtpDump，通话结束后底层会自动调用
-(NSInteger) startRtpDump:(NSString*)callid andMediaType:(NSInteger) mediaType andFileName:(NSString*)fileName andDirection:(NSInteger) direction;
//停止保存RTP数据，只能在通话过程中调用。
-(NSInteger) stopRtpDump:(NSString*)callid andMediaType:(NSInteger) mediaType  andDirection:(NSInteger) direction;
//是否抑制马赛克
-(NSInteger) setShieldMosaic:(BOOL) flag;

#pragma mark - 对讲机函数

//启动对讲场景
- (void) startInterphoneWithJoiner:(NSArray*)joinerArr inAppId:(NSString*)appid;

//加入对讲场景
- (void) joinInterphoneToConfNo:(NSString*)confNo;

//退出对讲
- (BOOL) exitInterphone;

//发起对讲——抢麦
- (void) controlMicInConfNo:(NSString*)confNo;

//结束对讲——放麦
- (void) releaseMicInConfNo:(NSString*)confNo;

//查询参与对讲成员
- (void) getMemberListInConfNo:(NSString*)confNo;

#pragma mark - 聊天室相关函数
//创建聊天室
- (void) startChatroomWithName:(NSString *)roomName andPassword:(NSString *)roomPwd andSquare:(NSInteger)square andKeywords:(NSString *)keywords inAppId:(NSString*)appid andIsAutoClose:(BOOL)isAutoClose andVoiceMod:(NSInteger) voiceMod andAutoDelete:(BOOL) autoDelete andIsAutoJoin:(BOOL) isAutoJoin;

//加入聊天室
- (void) joinChatroomInRoom:(NSString *)roomNo andPwd:(NSString*) pwd;

//退出聊天室
- (BOOL) exitChatroom;

//获取聊天室成员
- (void) queryMembersWithChatroom:(NSString *)roomNo;

//获取所有的房间列表
- (void)queryChatroomsOfAppId:(NSString *)appid withKeywords:(NSString *)keywords;

//外呼邀请成员加入群聊
- (void)inviteMembers:(NSArray*)members joinChatroom:(NSString*)roomNo ofAppId:(NSString *)appid;

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

#pragma mark - 多媒体IM

//发送语音IM
- (NSString*) startVoiceRecordingWithReceiver:(NSString*) receiver andPath:(NSString*) path andChunked:(BOOL) chunked andUserdata:(NSString *)userdata;
//发送IM
- (NSString*) sendInstanceMessage:(NSString*) receiver andText:(NSString*) text andAttached:(NSString*) attached andUserdata:(NSString *)userdata;
//确认已下载多媒体IM
- (void) confirmInstanceMessageWithMsgId :(NSArray*) msgIds;
//下载未下载完成的数据内容
- (void)downloadPreIMMsg;
#pragma mark - 多媒体IM群组
/**
 * 创建群组
 * @param name          NSString		群组名字
 * @param type          NSString		群组类型 0：临时组(上限100人)  1：普通组(上限300人)  2：VIP组 (上限500人)
 * @param declared      NSString		群组公告
 * @param permission	NSInteger     	申请加入模式 0：默认直接加入1：需要身份验证 2:私有群组
 */
- (void) createGroupWithName:(NSString*) name andType:(NSInteger) type andDeclared:(NSString*) declared andPermission:(NSInteger) permission;
/**
 * 修改群组
 * @param groupId       NSString		群组ID
 * @param name          NSString		群组名字
 * @param declared      NSString		群组公告
 * @param permission	NSInteger     	申请加入模式 0：默认直接加入1：需要身份验证 2:私有群组
 */
- (void) modifyGroupWithGroupId:(NSString*) groupId andName:(NSString*) name andDeclared:(NSString*) declared andPermission:(NSInteger) permission;

/**
 * 删除群组
 * @param groupId       NSString		群组ID
 */
- (void) deleteGroupWithGroupId:(NSString*) groupId;

/**
 * 查询公共群组
 * @param lastUpdateTime       NSString		上次更新的时间戳ms（用于分页获取，最大支持1个月前的时间，超过以1个月时间为准）
 */
- (void) queryPublicGroupsWithLastUpdateTime:(NSString*) lastUpdateTime;

/**
 * 按条件搜索公共群组
 * @param groupId       NSString		群组ID        根据群组ID查找（同时具备两个条件，查询以此为先）
 * @param name          NSString		群组名字 可选   根据群组名字查找（模糊查询，结果集中不能有私有群组）
 */
- (void) queryPublicGroupsWithGroupId:(NSString*) groupId andName:(NSString*) name;

/**
 * 查询群组
 * @param groupId       NSString		群组ID
 */
- (void) queryGroupDetailWithGroupId:(NSString*) groupId;

/**
 *申请加入群组
 * @param groupId       NSString      群组ID
 * @param declared      NSString		申请理由
 */
- (void) joinGroupWithGroupId:(NSString*) groupId andDeclared:(NSString*) declared;

/**
 *管理员邀请加入群组
 * @param groupId       NSString        群组ID
 * @param members       NSArray         被邀请的人员列表
 * @param declared      NSString		申请理由
 * @param confirm       NSInteger       是否需要被邀请人确认 0:需要 1：不需要(自动加入群组)
 */
- (void) inviteJoinGroupWithGroupId:(NSString*) groupId andMembers:(NSArray*) members andDeclared:(NSString*) declared andConfirm:(NSInteger) confirm;

/**
 *群组管理员删除成员
 * @param groupId       NSString        群组ID
 * @param members       NSArray         被邀请的人员列表
 */
- (void) deleteGroupMemberWithGroupId:(NSString*) groupId andMembers:(NSArray*) members;

/**
 *成员主动退出群组
 * @param groupid       NSString		群组ID
 */
- (void) logoutGroupWithGroupId:(NSString*) groupId;


#pragma mark - 多媒体IM群名片管理

/**
 *修改群组名片信息
 * @param gruopCard       IMGruopCard         群组名片信息
 */
- (void) modifyGroupCard:(IMGruopCard*) gruopCard;

/**
 *查询群组名片信息
 * @param other   NSString         群组中成员的账号
 * @param belong  NSString         用户所属的群组ID
 */
- (void) queryGroupCardWithOther:(NSString*) other andBelong:(NSString*) belong;

#pragma mark - 多媒体IM群组成员管理
/**
 *查询成员
 * @param groupid      NSString         群组ID
 */
- (void) queryMemberWithGroupId:(NSString*) groupId;

/**
 *查询成员加入的群组
 * @param asker        NSString         成员的Voip账号
 */
- (void) queryGroupWithAsker:(NSString*) asker;
/**禁言
 *groupId	String	必选	群组ID
 *member	String	必选	成员的VoIP账号
 *operation	int	必选	0：可发言（默认）1：禁言 2：对组内所有成员禁言
 */
- (void)forbidSpeakWithGroupId:(NSString*) groupId andMember:(NSString*) member andOperation:(NSInteger) operation;
/**
 *管理员验证用户申请加入群组
 * @param groupid      NSString         群组ID
 * @param asker        NSString         成员的Voip账号
 * @param confirm      NSInteger        0：通过 1：拒绝
 */
- (void) askJoinWithGroupId:(NSString*) groupId andAsker:(NSString*) asker andConfirm:(NSInteger) confirm;

/**
 *用户验证邀请加入群组
 * @param groupid      NSString         群组ID
 * @param confirm      NSInteger        0：通过 1：拒绝
 */
- (void) inviteGroupWithGroupId:(NSString*) groupId andConfirm:(NSInteger) confirm;

#pragma make - 网络检测
- (void)testUdpNet;
-(void)stopUdpTest;

#pragma make - 外呼通知

- (void)LandingCall:(NSString*)phoneNO;

#pragma mark - 语音验证码请求
/**
*语音验证码
*verifyCode 	 必选	 验证码内容，为数字和英文字母，不区分大小写，长度4-20位
*playTimes	 	 必选	 播放次数，1－3次
*to              必选     接收验证码的手机、座机号码
*respUrl	 	 可选	 用户发起语音验证码请求后，云通讯平台将向该url地址发送呼叫结果通知
*/
- (void)VoiceCodeWithVerifyCode:(NSString*)verifyCode andTo:(NSString*)to andPlayTimes:(int) playTimes andRespUrl:(NSString*)respUrl;

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

- (NSString*)getSDKDate;
/**
 *统计通话质量
 *@ret 通话质量对象
 */
-(StatisticsInfo*)getCallStatistics;

//根据列表删除文件
-(void)deleteFileWithPathArr:(NSArray*) pathArr;

#pragma mark - 专家咨询
//获取咨询类别列表
- (void)getCategoryList;
//获取咨询专家列表
- (void)getExpertListOfCategoryId:(NSString*)categoryId;
//获取特服号
- (void)getServiceNum;
//锁定专家
- (void)lockExpertId:(NSString*)expertId andSrcPhone:(NSString*)srcPhone;

#pragma mark - 视频会议
/**
 * 创建视频会议
 * @param appId 应用id
 * @param conferenceName 会议名称
 * @param square 参与的最大方数
 * @param keywords 业务属性，有应用定义
 * @param conferencePwd 房间密码，可为null
 * @param isAutoClose 是否可以自动解散
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
 * 获取帧数据
 */
- (void) getLocalPortrait;

/**
 * 下载头像数据
 * @param portraitsList 下载的头像信息
 */
- (void)downloadVideoConferencePortraits:(NSArray*)portraitsList;
/**
 * 获取Demo账号信息
 * @param userName 网站用户名
 * @param userPwd  网站用户密码
 */
//- (void) getDemoAccountsWithUserName:(NSString*) userName andUserPwd:(NSString*)userPwd;
/**
 * 视频通话中截取对端的图像
 * @param  callid 会话id
 * @return 无
 */
- (NSInteger)getRemoteVideoSnapshotWithCallid:(NSString*)callid;

//退出客户体验模式，将内置的账号清除掉
-(void)logoutDemoExperience;

- (void) editTestNumWithOldPhoneNumber:(NSString*) oldPhoneNumber andNewPhoneNumber:(NSString*) newPhoneNumber;

#pragma mark - 联系人操作和查询操作
- (NSString *)getContactNameByID:(NSInteger)contactid;
//根据输入搜索联系人，返回AddressBookContactSearchResult数组
- (NSArray *)contactsSearch:(NSString *)searchItem keyboard:(int)keyboard;
- (NSArray *)search:(NSString *)searchItem keyboard:(int)keyboard otherPhoneNO:(BOOL)isSearch;
- (NSArray *)search:(NSString *)searchItem keyboard:(int)keyboard Range:(NSDictionary *)range;
//当对点击查询结果，需要进一步展示用户的详细信息时调用
- (AddressBookContactSearchResult *)getContactByID:(ABRecordID) recordID;
//列出目前通讯录里的所有联系人
//只返回包括用户名、第一个联系电话等简单的信息，为AddressBookContactSearchResult数组
- (NSMutableDictionary *)listAllContactsReset:(BOOL)reset listAll:(BOOL)list;
- (NSMutableDictionary *)listAllContacts;
//对联系人的增删改
- (BOOL)addContact:(AddressBookContactSearchResult *) theContact;
- (BOOL)updateContact:(AddressBookContactSearchResult *) theContact;
- (BOOL)deleteContactSingle:(int) contactID;//ABRecordRemoveValue
- (BOOL)delContacts:(NSArray *) contactIDArr;
//对联系人图片的操作
- (BOOL)hasPortrait:(int) contactID;
- (BOOL)setPortrait:(int) contactID image:(NSData *)image;
- (BOOL)removePortrait:(int) contactID;
- (UIImage *)getPortrait:(int) contactID;
- (void)resetPortraitDic:(int)contactID;
//获得全部联系人数量
- (signed long) getContactCount;//ABAddressBookGetPersonCount
//其他相关的组操作
- (BOOL)addGroup:(NSString *)groupName;
- (BOOL)delGroup:(int)groupID;
//列出所有分组
- (NSArray *)listAllGroups;
- (BOOL)removeContactFromGroup:(int)conatctID group:(int)groupID;
- (BOOL)renameGroup:(int)groupID newName:(NSString *)newName;
- (NSMutableDictionary *)getGroupContacts:(int)groupID;
- (BOOL)moveContactFromOneToAnother:(int)contactID one:(int)groupID another:(int)anotherGroupID;
- (BOOL)addAllRecords:(NSArray *)groupArr;
- (BOOL)setContactsGroups:(int)contactID add:(NSMutableArray*)checkGroupIDList delGroups:(NSMutableArray*)delGroups;
@end
