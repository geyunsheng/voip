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

#import "AppDelegate.h"
#import "ModelEngineVoip.h"
#import "VoipIncomingViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ASIHTTPRequest.h"
#import "Demo_GDataXMLParser.h"
#import <CommonCrypto/CommonDigest.h>
#import "CommonClass.h"
#import "NSDataBase64.h"
#import "AccountInfo.h"

#define kServerVersion  @"2013-12-26"

#define KEY_USERINFO_TO_PHONENUMBER        @"toPhoneNumber"
#define KEY_USERINFO_IMGROUP_DATA        @"imGroupData"
#define KEY_USERINFO_IMMEMBER_DATA       @"imMemberData"
#define KEY_USERINFO_IMGROUPID           @"imGroupID"
#define KEY_USERINFO_IMMEMBERID          @"imGroupMemberID"
#define KEY_USERINFO_IMGetPublicGroups   @"GetPublicGroupsUpdateTime"
#define KEY_RESPONSE_USERDATA   @"responseuserdatainfo"

#define defHttps [self getHttpOrHttps]

// 多媒体IM信息成员类
@implementation IMMember
@synthesize sid; //用户的VoIP账号
@synthesize display;//用户名字
@synthesize sex; //用户性别
@synthesize birth; //用户生日
@synthesize tel; //用户电话
@synthesize sign; //用户的签名信息
@synthesize received;
-(void)dealloc
{
    self.sid = nil;
    self.display = nil;
    self.sex = nil;
    self.birth = nil;
    self.tel = nil;
    self.sign = nil;
    self.received = nil;
    [super dealloc];
}
@end

// 多媒体IM信息成员类
@implementation IMGruopCard
@synthesize display; //用户的显示名字
@synthesize sid; //用户的Voip账号
@synthesize tel;//用户电话
@synthesize mail; //用户邮箱
@synthesize remark; //用户备注
@synthesize belong; //用户所属的群组ID

-(id)init
{
    self = [super init];
    if (self)
    {
        self.display = @"";
        self.tel = @"";
        self.mail = @"";
        self.remark = @"";
    }
    return self;
}
-(void)dealloc
{
    self.display = nil;
    self.tel = nil;
    self.mail = nil;
    self.remark = nil;
    self.belong = nil;
    [super dealloc];
}
@end

@implementation ModelEngineVoip
{
    int sendCount;
}
@synthesize VoipCallService;
@synthesize voipAccount;
@synthesize voipName;
@synthesize voipPhone;
@synthesize UIDelegate;
@synthesize appIsActive;
@synthesize registerResult;
@synthesize networkStatusResult;
@synthesize callStatusResult;
@synthesize imDBAccess;
@synthesize vMsgs;
@synthesize unDownLoadedCount;
@synthesize interphoneArray;
@synthesize curInterphoneId;
@synthesize chatroomListArray;
@synthesize videoconferenceListArray;
@synthesize multiVideoconferenceListArray;
@synthesize accountArray;
@synthesize serverIP;
@synthesize serverPort;
@synthesize mainAccount;
@synthesize mainToken;
@synthesize appID;
@synthesize appName;
@synthesize subAccountSid;
@synthesize subAuthToken;
@synthesize voipPasswordStr;
@synthesize udpSocket;
@synthesize ivrPhone;
@synthesize registeredPhone;
@synthesize test_numberArray;
@synthesize developerUserName;
@synthesize developerUserPasswd;
@synthesize developerNickName;
@synthesize emojiCon;
@synthesize rejectCallId;
@synthesize cameraArr;

@synthesize contactAllDic;
@synthesize defaultContactIcon;
@synthesize addressBookContactList;

ModelEngineVoip* gModelEngineVoip = nil;

+(ModelEngineVoip *)getInstance
{
    @synchronized(self){
        if(gModelEngineVoip == nil){
            gModelEngineVoip = [[[self alloc] init] autorelease];
        }
    }
	return gModelEngineVoip;
}

+(id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (gModelEngineVoip == nil) {
            gModelEngineVoip = [super allocWithZone:zone];
            return  gModelEngineVoip;
        }
    }
    return nil;
}
//退出客户体验模式，将内置的账号清除掉
-(void)logoutDemoExperience
{
    self.developerUserName = nil;
    self.developerUserPasswd = nil;
    self.developerNickName = nil;
    self.registeredPhone = nil;
    self.test_numberArray = nil;
    self.accountArray = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"developerUserName"];
    [userDefaults removeObjectForKey:@"developerUserPasswd"];
    [userDefaults synchronize];
}
- (id)init
{
    if (self = [super init])
    {
        [theAppDelegate printLog:@"CCPCallService init"];
        CCPCallService* service = [[CCPCallService alloc] init];
        [service setDelegate:self];
        self.VoipCallService = service;
        [service release];
                
        self.appIsActive = YES;
        self.registerResult = ERegisterNot;
        self.networkStatusResult = ENetworkStatus_NONE;
        self.callStatusResult = ECallStatus_NO;
        self.voipName = @"";
        self.voipPhone = @"";
        self.imDBAccess = [[[IMMsgDBAccess alloc] init] autorelease];
        
        self.vMsgs = nil;
        self.interphoneArray = [[[NSMutableArray alloc] init] autorelease];
        self.chatroomListArray = [[[NSMutableArray alloc] init] autorelease];
        self.videoconferenceListArray = [[[NSMutableArray alloc] init] autorelease];
        self.multiVideoconferenceListArray = [[[NSMutableArray alloc] init] autorelease];
        
        self.accountArray = [[[NSMutableArray alloc] init] autorelease];
        self.attachDownArray = [[[NSMutableArray alloc] init] autorelease];
        self.emojiCon = [[[EmojiConvertor alloc] init] autorelease];
        sendCount = 0;
        //通讯录
        portraitDic = [[NSMutableDictionary alloc] init];
        self.defaultContactIcon = [UIImage imageNamed:@"personal_details_portrait.png"];
    }
    return self;
}

- (void)dealloc
{
    self.ivrPhone = nil;
    self.myVoipPhone = nil;
    self.accountArray = nil;
    self.curInterphoneId = nil;
    self.interphoneArray = nil;
    self.chatroomListArray = nil;
    self.videoconferenceListArray = nil;
    self.multiVideoconferenceListArray = nil;
    self.VoipCallService = nil;
    self.voipAccount = nil;
    self.serverIP = nil;
    self.voipName = nil;
    self.voipPhone = nil;
    self.UIDelegate = nil;
    self.vMsgs = nil;
    self.mainAccount = nil;
    self.mainToken = nil;
    self.imDBAccess = nil;
    self.attachDownArray = nil;
    self.subAccountSid = nil;
    self.subAuthToken = nil;
    self.voipPasswordStr = nil;
    self.registeredPhone = nil;
    self.test_numberArray = nil;
    self.developerUserName = nil;
    self.developerNickName = nil;
    self.developerUserPasswd = nil;
    self.appName = nil;
    self.emojiCon = nil;
    self.rejectCallId = nil;
    [udpSocket release];
    
    //通讯录
    self.addressBookContactList = nil;
    self.defaultContactIcon = nil;
    [portraitDic release];
    [super dealloc];
}

//设置回调代理方法
- (void)setModalEngineDelegate:(id)delegate
{
    [theAppDelegate printLog:@"设置业务消息返回的代理"];
    UIDelegate = delegate;
}

- (void)setVoipDelegate:(id)delegate
{
    [theAppDelegate printLog:@"设置VoipCallService消息返回的代理"];
    [self.VoipCallService setDelegate:delegate];
}

//登录
- (NSInteger)connectToCCP:(NSString *)rest_addr onPort:(NSInteger)rest_port withAccount:(NSString *)accountStr withPsw:(NSString *)passwordStr withAccountSid:(NSString *)accountSid withAuthToken:(NSString *)authToken
{
    isKickedOff = NO;//主动发起连接的话，被踢标记回置
    self.registerResult = ERegistering;
    self.voipAccount = accountStr;
    self.imDBAccess.voipAccount = self.voipAccount;
    [self.imDBAccess updateAllSendingToFailed];
    self.voipPasswordStr = passwordStr;
    self.serverIP = rest_addr;
    self.serverPort = rest_port;
    self.subAccountSid = accountSid;
    self.subAuthToken = authToken;
    [theAppDelegate printLog:[NSString stringWithFormat:@"connectToCCP account=%@;psw=%@;sub=%@;token=%@",accountStr,passwordStr,accountSid,authToken]];
    return [self.VoipCallService connectToCCP:rest_addr onPort:rest_port withAccount:accountStr withPsw:passwordStr withAccountSid:accountSid withAuthToken:authToken];
}

#pragma mark - 呼叫函数
//回拨电话
- (NSInteger)callback:(NSString *)fromPhone withTOCall:(NSString *)toPhone
{
    [theAppDelegate printLog:[NSString stringWithFormat:@"%@ make callback to %@",fromPhone,toPhone]];
    return [self.VoipCallService makeCallback:[NSString stringWithFormat:@"0086%@", fromPhone] withTOCall:[NSString stringWithFormat:@"0086%@", toPhone] andSrcSerNum:nil andDestSerNum:nil];
}

//呼叫 voip
- (NSString *)makeCall:(NSString *)called withPhone:(NSString*)phone withType:(NSInteger)callType withVoipType:(NSInteger)voiptype
{
    self.callStatusResult = ECallStatus_Calling;
    NSString* callid = nil;    
    if (0 == voiptype)
    {
        //电话直拨，使用被叫人电话号
        [theAppDelegate printLog:[NSString stringWithFormat:@"电话直拨 to %@",phone]];
        if ([called length] > 3 && [[called substringToIndex:3] isEqualToString:@"+86"])
            callid = [self.VoipCallService makeCallWithType:callType andCalled:phone];
        else
            callid = [self.VoipCallService makeCallWithType:callType andCalled:[NSString stringWithFormat:@"0086%@", phone]];
    }
    else
    {
        //网络免费电话 使用被叫人voip账号
        [theAppDelegate printLog:[NSString stringWithFormat:@"网络免费电话 to %@",called]];
        callid = [self.VoipCallService makeCallWithType:callType andCalled:called];
    }
    [theAppDelegate printLog:[NSString stringWithFormat:@"makeCall callid=%@;called=%@;phone=%@;",callid,called,phone]];
    return callid;
}

//挂断呼叫
- (NSInteger)releaseCall:(NSString *)callid
{
    [theAppDelegate printLog:@"电话挂断"];
    return [self.VoipCallService releaseCall:callid];
}

//接受呼叫 开始通话
- (NSInteger)acceptCall:(NSString*)callid
{
    [theAppDelegate printLog:[NSString stringWithFormat:@"接听网络电话 callid=%@",callid]];
    return [self.VoipCallService acceptCall:callid];
}

//接受呼叫 开始通话 v2.1
- (NSInteger)acceptCall:(NSString*)callid withType:(NSInteger)callType
{
    [theAppDelegate printLog:[NSString stringWithFormat:@"接听网络电话 callid=%@",callid]];
    return [self.VoipCallService acceptCall:callid withType:callType];
}
//拒绝呼叫(挂断一样,当被呼叫的时候被呼叫方的挂断状态)
- (NSInteger)rejectCall:(NSString *)callid andReason:(NSInteger) reason
{
    [theAppDelegate printLog:[NSString stringWithFormat:@"拒接网络电话 callid=%@",callid]];
    return [self.VoipCallService rejectCall:callid andReason:reason];
}

//暂停
- (NSInteger)pauseCall:(NSString *)callid
{
    return [self.VoipCallService pauseCall:callid];
}
//恢复
- (NSInteger)resumeCall:(NSString *)callid
{
    return [self.VoipCallService resumeCall:callid];
}

//呼转
- (NSInteger)transferCall:(NSString *)callid withTransferID:(NSString *)destination
{
    return [self.VoipCallService transferCall:callid withTransferID:destination];
}

//获取呼叫的媒体类型
- (NSInteger)getCallMediaType:(NSString*)callid
{
    return [self.VoipCallService getCallMediaType:callid];
}

#pragma mark - DTMF函数
//发DTMF,单独拨一个数字号
- (NSInteger)sendDTMF:(NSString*)callid dtmf:(NSString *)dtmf
{
    return [self.VoipCallService sendDTMF:callid dtmf:dtmf];
}

- (NSString*) sendInstanceMessage:(NSString*) receiver andText:(NSString*) text andAttached:(NSString*) attached andUserdata:(NSString *)userdata
{
    if ([UIDevice currentDevice].systemVersion.floatValue > 6)
    {
        text = [self.emojiCon convertEmojiUnicodeToSoftbank:text];
    }
    return [self.VoipCallService sendInstanceMessage:receiver andText:text andAttached:attached andUserdata:userdata];
}

#pragma mark - 基本设置函数
//静音或取消静音
- (NSInteger)setMute:(BOOL)on
{
    return [self.VoipCallService setMute:on];
}
//获取静音状态
- (NSInteger)getMuteStatus
{
    return [self.VoipCallService getMuteStatus];
}

//开启或关闭扬声器
- (NSInteger)enableLoudsSpeaker:(BOOL)flag
{
    return [self.VoipCallService enableLoudsSpeaker:flag];
}

- (NSInteger)setVideoView:(UIView *)view andLocalView:(UIView*)localView
{
    return [self.VoipCallService setVideoView:view andLocalView:localView];
}

//获取摄像头信息
- (NSArray*)getCameraInfo
{
    if (self.cameraArr == nil) {
        self.cameraArr = [self.VoipCallService getCameraInfo];
    }
    return self.cameraArr;
}

//选取摄像头
- (NSInteger)selectCamera:(NSInteger)cameraIndex
{
    if (cameraIndex >= self.cameraArr.count) {
        return -1;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger fps = [userDefaults integerForKey:Camera_fps_KEY];
    if (fps == 0){
        fps = 12;
    }
    
    NSInteger capabilityIndex = [userDefaults integerForKey:Camera_Resolution_KEY];
    CameraDeviceInfo *camera = [self.cameraArr objectAtIndex:cameraIndex];
    if (capabilityIndex >= camera.capabilityArray.count) {
        capabilityIndex = 0;
    }
    
    return [self.VoipCallService selectCamera:cameraIndex capability:capabilityIndex fps:fps rotate:Rotate_Auto];
}
//设置用户名字
- (void)setVoipUserName:(NSString *)username
{
    self.voipName = username;
}

//设置用户信息,发送给被叫
- (void)setVoipUserPhone:(NSString *)phone
{
    self.voipPhone = phone;
}

//设置音频处理的开关,在呼叫前调用
-(NSInteger)setAudioConfigEnabledWithType:(EAudioType) type andEnabled:(BOOL) enabled andMode:(NSInteger) mode{
    return [self.VoipCallService setAudioConfigEnabledWithType:type andEnabled:enabled andMode:mode];
}

//设置视频通话码率  bitrates  视频码流，kb/s，范围30-300
-(void)setVideoBitRates:(NSInteger)bitrates{
    [self.VoipCallService setVideoBitRates:bitrates];
}

//保存Rtp数据到文件，只能在通话过程中调用，如果没有调用stopRtpDump，通话结束后底层会自动调用
-(NSInteger) startRtpDump:(NSString*)callid andMediaType:(NSInteger) mediaType andFileName:(NSString*)fileName andDirection:(NSInteger) direction{
    return [self.VoipCallService startRtpDump:callid andMediaType:mediaType andFileName:fileName andDirection:direction];
}

//停止保存RTP数据，只能在通话过程中调用。
-(NSInteger) stopRtpDump:(NSString*)callid andMediaType:(NSInteger) mediaType  andDirection:(NSInteger) direction{
    return [self.VoipCallService stopRtpDump:callid andMediaType:mediaType andDirection:direction];
}

#pragma mark - CCPCallManagerDelegate
- (void)onReachbilityChanged:(NSInteger)status
{
    if (status == NETWORK_STATUS_NONE)
    {
        self.networkStatusResult = ENetworkStatus_NONE;
        [theAppDelegate printLog:@"当前无网络"];
    }
    else if (status == NETWORK_STATUS_WIFI)
    {
        self.networkStatusResult = ENetworkStatus_WIFI;
        [theAppDelegate printLog:@"当前网络:WiFi"];
    }
    else if (status == NETWORK_STATUS_GPRS)
    {
        self.networkStatusResult = ENetworkStatus_GPRS;
        [theAppDelegate printLog:@"当前网络:GPRS"];
    }
    else if (status == NETWORK_STATUS_3G)
    {
        self.networkStatusResult = ENetworkStatus_3G;
        [theAppDelegate printLog:@"当前网络:3G"];
    }
    
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseNetworkStatus:data:)])
    {
        [self.UIDelegate responseNetworkStatus:self.networkStatusResult data:nil];
    }
    if (status !=NETWORK_STATUS_NONE)
    {
        if (!isKickedOff)//如果不是被踢下线的话重连
        {
            [self reConnectCCP];//网络变化后如果有网络就重连服务器
        }
    }
}

-(void)reConnectCCP//网络变化重连服务器
{
    if (self.serverIP  && self.serverPort && self.subAccountSid && self.subAuthToken && self.voipAccount && self.voipPasswordStr)
    {
        [self connectToCCP:self.serverIP onPort:self.serverPort withAccount:self.voipAccount withPsw:self.voipPasswordStr withAccountSid:self.subAccountSid withAuthToken:self.subAuthToken];
    }
}
//与voip服务器平台连接成功
- (void)onConnected
{
    [theAppDelegate printLog:@"与voip服务器平台连接成功"];
    self.registerResult = ERegisterSuccess;
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseVoipRegister:data:)])
    {
         [self.UIDelegate responseVoipRegister:ERegisterSuccess data:nil];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL noSet = [userDefaults boolForKey:@"noSet"];
    if (!noSet)
    {
        [userDefaults setBool:YES forKey:@"noSet"];
        [userDefaults setInteger:-1 forKey:AUTOMANAGE_KEY];//如果没有配置过，默认配置为不开启
        [userDefaults setInteger:eAgcAdaptiveDigital forKey:AUTOMANAGE_INDEX_KEY]; //如果没有配置过，默认配置为eAgcAdaptiveDigital
        [userDefaults setInteger:1 forKey:ECHOCANCELLED_KEY];//如果没有配置过，默认配置为开启
        [userDefaults setInteger:eEcConference forKey:ECHOCANCELLED_INDEX_KEY];    //如果没有配置过，默认配置为eEcAecm
        [userDefaults setInteger:1 forKey:SILENCERESTRAIN_KEY];//如果没有配置过，默认配置为开启
        [userDefaults setInteger:eNsVeryHighSuppression forKey:SILENCERESTRAIN_INDEX_KEY];        //如果没有配置过，默认配置为eNsVeryHighSuppression
        [userDefaults setInteger:1 forKey:VIDEOSTREAM_KEY];//如果没有配置过，默认配置为开启
        [userDefaults setObject:[NSString stringWithFormat:@"%d",150] forKey:VIDEOSTREAM_CONTENT_KEY];//默认设置码流为150KB
        [userDefaults setInteger:1 forKey:VOICE_CHUNKED_SEND_KEY];
        [userDefaults setInteger:1 forKey:SHIELDMOSAIC_KEY];
        [userDefaults setInteger:-1 forKey:RECORDVOICE_KEY];
        [userDefaults synchronize];
    }
   
    NSString* silkRates = [userDefaults objectForKey:SILKSTREAM_RATE_KEY];//获取当前silk码率
    if (silkRates.length > 0) {
        [self.VoipCallService setSilkRate:silkRates.integerValue];
    }
    
    NSInteger selectedIndex = 0;
    BOOL flag = NO;
    if ([userDefaults integerForKey:AUTOMANAGE_KEY] == 1)
    {
        flag = YES;
    }
    
    //设置自动增益
    selectedIndex = [userDefaults integerForKey:AUTOMANAGE_INDEX_KEY];
    [self setAudioConfigEnabledWithType:eAUDIO_AGC andEnabled:flag andMode:selectedIndex];
    
    flag = NO;
    if ([userDefaults integerForKey:ECHOCANCELLED_KEY] == 1)
    {
        flag = YES;
    }
    //设置回音消除
    selectedIndex = [userDefaults integerForKey:ECHOCANCELLED_INDEX_KEY];
    [self setAudioConfigEnabledWithType:eAUDIO_EC andEnabled:flag andMode:selectedIndex];
    
    
    flag = NO;
    if ([userDefaults integerForKey:SILENCERESTRAIN_KEY] == 1)
    {
        flag = YES;
    }
    //设置静音抑制
    selectedIndex = [userDefaults integerForKey:SILENCERESTRAIN_INDEX_KEY];
    [self setAudioConfigEnabledWithType:eAUDIO_NS andEnabled:flag andMode:selectedIndex];
    
    //马赛克
    if ([userDefaults integerForKey:SHIELDMOSAIC_KEY] == 1)
        [self setShieldMosaic:YES];
    else
        [self setShieldMosaic:NO];
    
    flag = NO;
    if ([userDefaults integerForKey:Codec_G729_KEY] == 0)
    {
        flag = YES;
    }
    [self.VoipCallService setCodecEnabledWithCodec:Codec_G729 andEnabled:flag];
    
    flag = NO;
    if ([userDefaults integerForKey:Codec_H264_KEY] == 0)
    {
        flag = YES;
    }
    [self.VoipCallService setCodecEnabledWithCodec:Codec_H264 andEnabled:flag];
    
    flag = NO;
    if ([userDefaults integerForKey:Codec_iLBC_KEY] == 0)
    {
        flag = YES;
    }
    [self.VoipCallService setCodecEnabledWithCodec:Codec_iLBC andEnabled:flag];
    
    flag = NO;
    if ([userDefaults integerForKey:Codec_PCMA_KEY] == 0)
    {
        flag = YES;
    }
    [self.VoipCallService setCodecEnabledWithCodec:Codec_PCMA andEnabled:flag];
    
    flag = NO;
    if ([userDefaults integerForKey:Codec_PCMU_KEY] == 0)
    {
        flag = YES;
    }
    [self.VoipCallService setCodecEnabledWithCodec:Codec_PCMU andEnabled:flag];
    
    flag = NO;
    if ([userDefaults integerForKey:Codec_SILK12K_KEY] == 0)
    {
        flag = YES;
    }
    [self.VoipCallService setCodecEnabledWithCodec:Codec_SILK12K andEnabled:flag];
    
    flag = NO;
    if ([userDefaults integerForKey:Codec_SILK16K_KEY] == 0)
    {
        flag = YES;
    }
    [self.VoipCallService setCodecEnabledWithCodec:Codec_SILK16K andEnabled:flag];
    
    flag = NO;
    if ([userDefaults integerForKey:Codec_SILK8K_KEY] == 0)
    {
        flag = YES;
    }
    [self.VoipCallService setCodecEnabledWithCodec:Codec_SILK8K andEnabled:flag];
    
    flag = NO;
    if ([userDefaults integerForKey:Codec_VP8_KEY] == 0)
    {
        flag = YES;
    }
    [self.VoipCallService setCodecEnabledWithCodec:Codec_VP8 andEnabled:flag];
    
    if ([userDefaults integerForKey:Camera_fps_KEY] == 0)
    {
        [userDefaults setInteger:12 forKey:Camera_fps_KEY];
    }
}

//与voip服务器平台连接失败或连接断开
- (void)onConnectError:(NSInteger)reason withReasonMessge:(NSString *)reasonMessage
{
    if (reason == EReasonKickedOff)
    {
        isKickedOff = YES;
        [theAppDelegate printLog:@"你已下线，账号在其他位置登录！"];        
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseKickedOff)])
        {
            [self.UIDelegate responseKickedOff];
        }
    }
    else
    {
        [theAppDelegate printLog:[NSString stringWithFormat:@"与voip服务器平台连接失败或连接断开 reason = %d reasonMessage = %@",reason,reasonMessage]];
        if ((reason != EReasonNoResponse || reason != EReasonNoNetwork) && self.appIsActive)
        {
            NSString *msg = [NSString stringWithFormat:@"错误码:%d\r\n错误详情:%@", reason, reasonMessage.length>0?reasonMessage:@"未知"];
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                           message:msg
                                                          delegate:nil
                                                 cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [view show];;
            [view release];
        }
    }
    
    self.registerResult = ERegisterFail;
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseVoipRegister:data:)]) 
    {
        [self.UIDelegate responseVoipRegister:ERegisterFail data:[NSString stringWithFormat:@"%d",reason]];
    }
}

//回拨成功
- (void)onCallBackWithReason:(CloopenReason *)reason andFrom:(NSString *)src To:(NSString *)dest
{
    NSString *callReason = nil;
    if (reason.reason == 0)
    {
        [theAppDelegate printLog:@"回拨成功"];
        self.callStatusResult = ECallStatus_CallBack;
    }
    else
    {
        NSString* str = @"";
        if ([reason.msg length]>0)
        {
            str = reason.msg;
        }
        else if (reason.reason == 121002)
        {
            str = @"计费鉴权失败,余额不足";
        }
        
        callReason = [NSString stringWithFormat:@"错误%d,%@",reason.reason, str];
        [theAppDelegate printLog:callReason];
        self.callStatusResult = ECallStatus_CallBackFailed;
    }
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseVoipManagerStatus:callID:data:)])
    {
        [self.UIDelegate responseVoipManagerStatus:self.callStatusResult callID:@"callback" data:callReason];
    }
}


//有呼叫进入 voip
- (void)onIncomingCallReceived:(NSString*)callid withCallerAccount:(NSString *)caller withCallerPhone:(NSString *)callerphone withCallerName:(NSString *)callername withCallType:(NSInteger)calltype
{
    [theAppDelegate printLog:[NSString stringWithFormat:@"onIncomingCallReceived callid=%@ caller=%@ callerphone=%@ callername=%@ calltype=%d", callid, caller, callerphone, callername, calltype]];
    
    if (self.callStatusResult != ECallStatus_NO && self.callStatusResult != ECallStatus_Released)
    {
        [self.VoipCallService rejectCall:callid andReason:EReasonBusy];//通话中来电直接拒绝掉，客户可以根据自己需要进行处理
        self.rejectCallId = callid;
        return;
    }
    
    self.callStatusResult = ECallStatus_Incoming;
    
    if (self.appIsActive)
    {
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(incomingCallID:caller:phone:name:callStatus:callType:)])
        {
            NSString* phoneNO = @"";
            NSString* name = @"";
            if ([callerphone length] > 0)
                phoneNO = callerphone;
            if ([callername length] > 0)
                name = callername;
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:callid,@"callid",caller,@"caller",[NSString stringWithFormat:@"%d",calltype],@"calltype", phoneNO,@"callerphone",name,@"callername",nil];
            [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(delayCall:) userInfo:dict repeats:NO];
        }
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseVoipManagerStatus:callID:data:)])
        {
            [self.UIDelegate responseVoipManagerStatus:ECallStatus_Incoming callID:callid data:caller];
        }
    }
    else
    {
//        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        //本地推送
        //设置时间 
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:1];
        //创建一个本地推送
        UILocalNotification *noti = [[[UILocalNotification alloc] init] autorelease];
        if (noti) 
        {
            //设置推送时间
            noti.fireDate = date;
            //设置时区
            noti.timeZone = [NSTimeZone defaultTimeZone];
            //设置重复间隔
            noti.repeatInterval = 0;
            //推送声音
            noti.soundName = @"incomingRing.wav";
            //内容
            if ([callerphone length] <= 0) {
                callerphone = caller;
            }
            noti.alertBody = [NSString stringWithFormat:@"%@请求与你通话",callerphone];
            //显示在icon上的红色圈中的数子
//            noti.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
            //设置userinfo 方便在之后需要撤销的时候使用
            NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:@"comingCall",KEY_TYPE,callid,KEY_CALLID,callerphone,KEY_CALLERPHONE, [NSString stringWithFormat:@"%d", calltype], KEY_CALL_TYPE, caller, KEY_CALLNUMBER, callername,KEY_CALLERNAME,nil];
            noti.userInfo = infoDic;
            //添加推送到uiapplication        
            UIApplication *app = [UIApplication sharedApplication];
            [app scheduleLocalNotification:noti];  
        }
    }
}

//呼叫处理中
- (void)onCallProceeding:(NSString *)callid
{
    self.callStatusResult = ECallStatus_Proceeding;
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseVoipManagerStatus:callID:data:)])
    {
        [self.UIDelegate responseVoipManagerStatus:ECallStatus_Proceeding callID:callid data:nil];
    }
}

//呼叫振铃
- (void)onCallAlerting:(NSString *)callid
{
    self.callStatusResult = ECallStatus_Alerting;
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseVoipManagerStatus:callID:data:)]) 
    {
        [self.UIDelegate responseVoipManagerStatus:ECallStatus_Alerting callID:callid data:nil];
    }
}

//外呼对方应答 开始通话
- (void)onCallAnswered:(NSString *)callid
{
    [theAppDelegate printLog:@"外呼对方应答 开始通话"];
    self.callStatusResult = ECallStatus_Answered;
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseVoipManagerStatus:callID:data:)]) 
    {
        [self.UIDelegate responseVoipManagerStatus:ECallStatus_Answered callID:callid data:nil];
    }
}

//外呼失败
- (void)onMakeCallFailed:(NSString *)callid withReason:(int)reason
{
    [theAppDelegate printLog:[NSString stringWithFormat:@"外呼失败 callid=%@ ,reason=%d",callid,reason]];
    if (reason == 170007)
    {
        [theAppDelegate printLog:[NSString stringWithFormat:@"该版本不支持此功能 callid=%@ ,reason=%d",callid,reason]];
    }
    self.callStatusResult = ECallStatus_Failed;
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseVoipManagerStatus:callID:data:)]) 
    {
        [self.UIDelegate responseVoipManagerStatus:ECallStatus_Failed callID:callid data:[NSString stringWithFormat:@"%d",reason]];
    }
    self.callStatusResult = ECallStatus_Released;
}

//呼叫挂机
- (void)onCallReleased:(NSString *)callid
{
    if ([self.rejectCallId isEqualToString:callid])//通话中来电默认拒绝，因当前呼叫还在继续因此不上报消息
    {
        return;
    }
    [theAppDelegate printLog:@"呼叫挂机"];
    self.callStatusResult = ECallStatus_Released;
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseVoipManagerStatus:callID:data:)])
    {
        [self.UIDelegate responseVoipManagerStatus:ECallStatus_Released callID:callid data:nil];
    }
}

//本地Pause呼叫成功
- (void)onCallPaused:(NSString *)callid
{
    self.callStatusResult = ECallStatus_Pasused;
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseVoipManagerStatus:callID:data:)])
    {
        [self.UIDelegate responseVoipManagerStatus:ECallStatus_Pasused callID:callid data:nil];
    }
}

//呼叫被对端pasue
- (void)onCallPausedByRemote:(NSString *)callid
{
    self.callStatusResult = ECallStatus_PasusedByRemote;
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseVoipManagerStatus:callID:data:)])
    {
        [self.UIDelegate responseVoipManagerStatus:ECallStatus_PasusedByRemote callID:callid data:nil];
    }
}

//本地Pause呼叫成功
- (void)onCallResumed:(NSString *)callid
{
    self.callStatusResult = ECallStatus_Resumed;
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseVoipManagerStatus:callID:data:)])
    {
        [self.UIDelegate responseVoipManagerStatus:ECallStatus_Resumed callID:callid data:nil];
    }
}

//呼叫被对端pasue
- (void)onCallResumedByRemote:(NSString *)callid
{
    self.callStatusResult = ECallStatus_ResumedByRemote;
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseVoipManagerStatus:callID:data:)])
    {
        [self.UIDelegate responseVoipManagerStatus:ECallStatus_ResumedByRemote callID:callid data:nil];
    }
}

//呼叫被转接
- (void)onCallTransfered:(NSString *)callid transferTo:(NSString *)destination
{
    self.callStatusResult = ECallStatus_Transfered;
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseVoipManagerStatus:callID:data:)]) 
    {
        [self.UIDelegate responseVoipManagerStatus:ECallStatus_Transfered callID:callid data:destination];
    }
    self.callStatusResult = ECallStatus_Calling;
}

- (void)onMessageRemoteVideoRotate:(NSString*)degree
{
    NSLog(@"[onMessageRemoteVideoRotate:%@]",degree);
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onMessageRemoteVideoRotate:)])
    {
        [self.UIDelegate onMessageRemoteVideoRotate:degree];
    }
}

//收到对方请求切换音视频
//request：0  请求增加视频（需要响应用responseSwitchCallMediaType处理） 1:请求删除视频（不需要响应）
- (void)onSwitchCallMediaType:(NSString *)callid withRequest:(NSInteger)request
{
    NSLog(@"[onSwitchCallMediaType:%@ withRequest:%d]",callid,request);
    [self.VoipCallService responseSwitchCallMediaType:callid withAction:1];
    [self enableLoudsSpeaker:YES];
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onSwitchCallMediaType:withRequest:)])
    {
        [self.UIDelegate onSwitchCallMediaType:callid withRequest:request];
    }
}

//对方应答切换音视频请求
//切换后的媒体状态 0 有视频 1 无视频
- (void)onSwitchCallMediaType:(NSString *)callid withResponse:(NSInteger)response
{
    NSLog(@"[onSwitchCallMediaType:%@ withResponse:%d]",callid,response);
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onSwitchCallMediaType:withResponse:)])
    {
        [self.UIDelegate onSwitchCallMediaType:callid withResponse:response];
    }
}

//视频分辨率发生改变
- (void)onCallVideoRatioChanged:(NSString *)callid andVoIP:(NSString *)voip andIsConfrence:(BOOL)isConference andWidth:(NSInteger)width andHeight:(NSInteger)height;
{
    NSLog(@"onCallVideoRatioChanged callid=%@;width=%d;height=%d;voip=%@;isConference=%d", callid, width, height,voip, isConference);
    if(self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onCallVideoRatioChanged:andVoIP:andIsConfrence:andWidth:andHeight:)])
    {
        [self.UIDelegate onCallVideoRatioChanged:callid andVoIP:voip andIsConfrence:isConference andWidth:width andHeight:height];
    }
}

- (void) onOriginalAudioDataWithCallid:(NSString*)callid andInData:(NSData*) inData andSampleRate:(NSInteger)sampleRate andNumChannels:(NSInteger)numChannels andCodec:(NSString*)codec andIsSend:(BOOL)isSend
{
    NSLog(@"onOriginalAudioDataWithCallid=%@;data=%@;sampleRate=%d;numchannels=%d;codec=%@;isSend=%d;",callid, inData,sampleRate,numChannels,codec,isSend);
    /*
    if (isSend)
    {
        if (sendYesFileHandle == NULL)
        {
            NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* doc_path = [path objectAtIndex:0];
            NSString* _filename = [doc_path stringByAppendingPathComponent:[NSString stringWithFormat:@"SendIsYes%@.wav", callid]];
            sendYesFileHandle =fopen([_filename UTF8String],"wb+");
        }

        if (sendYesFileHandle != NULL)
        {
            fwrite([inData bytes],1,[inData length],sendYesFileHandle);
        }
    }
    else
    {
        if (sendNoFileHandle == NULL)
        {
            NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* doc_path = [path objectAtIndex:0];
            NSString* _filename = [doc_path stringByAppendingPathComponent:[NSString stringWithFormat:@"SendIsNo%@.wav", callid]];
            sendNoFileHandle =fopen([_filename UTF8String],"wb+");
        }
        
        if (sendNoFileHandle != NULL)
        {
            fwrite([inData bytes],1,[inData length],sendNoFileHandle);
        }
    }*/
}

// 停止当前录音
-(void)stopCurRecording{
    [self.VoipCallService stopVoiceRecording];
}
-(void)cancelVoiceRecording
{
    [self.VoipCallService cancelVoiceRecording];
}
// 播放语音文件
-(void)playVoiceMsg:(NSString*) fileName{
    [self.VoipCallService playVoiceMsg:fileName];
}
// 停止当前播放语音
-(void)stopVoiceMsg{
    [self.VoipCallService stopVoiceMsg];
}
// 获取语音文件的播放时长
-(long)getVoiceDuration:(NSString*) fileName{
    return [self.VoipCallService getVoiceDuration:fileName];
}

#pragma mark - 语音留言相关函数

// 录音超时
-(void)onRecordingTimeOut:(long) ms
{
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseRecordingTimeOut:)])
    {
        
        [self.UIDelegate responseRecordingTimeOut:ms];
    }
}

//通知客户端当前录音振幅
-(void)onRecordingAmplitude:(double) amplitude
{
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseRecordingAmplitude:)])
    {
        [self.UIDelegate responseRecordingAmplitude:amplitude];
    }
}

//播放完成
-(void)onFinishedPlaying
{
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseFinishedPlaying)])
    {
        
        [self.UIDelegate responseFinishedPlaying];
    }
}

#pragma mark - 对讲相关函数
//启动对讲场景
- (void) startInterphoneWithJoiner:(NSArray*)joinerArr inAppId:(NSString*)appid
{
    [self.VoipCallService startInterphoneWithJoiner:joinerArr inAppId:appid];
}

//加入对讲场景
- (void) joinInterphoneToConfNo:(NSString*)confNo
{
    [self.VoipCallService joinInterphoneToConfNo:confNo];
}

//退出对讲
- (BOOL) exitInterphone
{
    self.curInterphoneId = nil;
    return [self.VoipCallService exitInterphone];
}

//发起对讲——抢麦
- (void) controlMicInConfNo:(NSString*)confNo
{
    [theAppDelegate printLog:@"controlMicInConfNo_______start"];
    [self.VoipCallService controlMicInConfNo:confNo];
}

//结束对讲——放麦
- (void) releaseMicInConfNo:(NSString*)confNo
{
    [theAppDelegate printLog:(@"releaseMicInConfNo_______start")];
    [self.VoipCallService releaseMicInConfNo:confNo];
}

//查询参与对讲成员
- (void) getMemberListInConfNo:(NSString*)confNo
{
    [self.VoipCallService queryMembersWithInterphone:confNo];
}


#pragma mark - 对讲代理函数
//通知客户端收到新的实时语音信息
- (void)onReceiveInterphoneMsg:(InterphoneMsg*) msg
{
    NSLog(@"onReceiveInterphoneMsg-------------%@",msg);
  
    if ([msg isKindOfClass:[InterphoneInviteMsg class]])
    {
        InterphoneInviteMsg *msgInfo = (InterphoneInviteMsg*)msg;
        if (msgInfo.interphoneId.length > 0)
        {
            BOOL isExist = NO;
            for (NSString *interphoneid in self.interphoneArray)
            {
                if ([interphoneid isEqualToString:msgInfo.interphoneId])
                {
                    isExist = YES;
                    break;
                }
            }
            if (!isExist)
            {
                [self.interphoneArray addObject:msgInfo.interphoneId];
            }
        }
    }
    else if([msg isKindOfClass:[InterphoneOverMsg class]])
    {
        InterphoneOverMsg *msgInfo = (InterphoneOverMsg*)msg;
        if (msg.interphoneId.length > 0)
        {
            for (NSString *interphoneid in self.interphoneArray)
            {
                if ([interphoneid isEqualToString:msgInfo.interphoneId])
                {
                    [self.interphoneArray removeObject:interphoneid];
                    break;
                }
            }
        }
    }
    
    
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onReceiveInterphoneMsg:)])
    {
        AudioServicesPlaySystemSound(1007);        
        [self.UIDelegate onReceiveInterphoneMsg:msg];
    }
}

//对讲场景状态
- (void)onInterphoneStateWithReason:(CloopenReason *) reason andConfNo:(NSString*)confNo
{
    NSLog(@"onInterphoneState-------------reason=%d, confNo=%@", reason.reason, confNo);
    if (reason.reason == 0 && confNo.length > 0)
    {
        self.curInterphoneId = confNo;
        BOOL isExist = NO;
        for (NSString *interphoneid in self.interphoneArray)
        {
            if ([interphoneid isEqualToString:confNo])
            {
                isExist = YES;
                break;
            }
        }
        if (!isExist)
        {
            [self.interphoneArray addObject:confNo];
        }
    }
    
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onInterphoneStateWithReason:andConfNo:)])
    {
        
        [self.UIDelegate onInterphoneStateWithReason:reason andConfNo:confNo];
    }
}

//发起对讲——抢麦
- (void)onControlMicStateWithReason:(CloopenReason *) reason andSpeaker:(NSString *)speaker
{
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onControlMicStateWithReason:andSpeaker:)])
    {
        [self.UIDelegate onControlMicStateWithReason:reason andSpeaker:speaker];
    }
}

//结束对讲——放麦
- (void)onReleaseMicStateWithReason:(CloopenReason *) reason
{
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onReleaseMicStateWithReason:)])
    {
        [self.UIDelegate onReleaseMicStateWithReason:reason];
    }
}

//获取对讲场景的成员
- (void)onInterphoneMembersWithReason:(CloopenReason *) reason andData:(NSArray*)members
{
    NSLog(@"onInterphoneMembers-------------data=%@", members);
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onInterphoneMembersWithReason:andData:)])
    {
        [self.UIDelegate onInterphoneMembersWithReason:reason andData:members];
    }
}

#pragma mark - 聊天室相关函数
//创建聊天室
- (void) startChatroomWithName:(NSString *)roomName andPassword:(NSString *)roomPwd andSquare:(NSInteger)square andKeywords:(NSString *)keywords inAppId:(NSString*)appid andIsAutoClose:(BOOL)isAutoClose andVoiceMod:(NSInteger) voiceMod andAutoDelete:(BOOL) autoDelete andIsAutoJoin:(BOOL) isAutoJoin;
{
    [self.VoipCallService startChatroomInAppId:appid withName:roomName andSquare:square andKeywords:keywords andPassword:roomPwd andIsAutoClose:isAutoClose andVoiceMod:voiceMod andAutoDelete:autoDelete andIsAutoJoin:isAutoJoin];
}

//加入聊天室
- (void) joinChatroomInRoom:(NSString *)roomNo andPwd:(NSString *)pwd
{
    [self.VoipCallService joinChatroomInRoom:roomNo andPwd:pwd];
}

//退出聊天室
- (BOOL) exitChatroom
{
    return [self.VoipCallService exitChatroom];
}

//获取聊天室成员
- (void) queryMembersWithChatroom:(NSString *)roomNo
{
    [self.VoipCallService queryMembersWithChatroom:roomNo];
}

//获取所有的房间列表
- (void)queryChatroomsOfAppId:(NSString *)appid withKeywords:(NSString *)keywords
{
    [self.VoipCallService queryChatroomsOfAppId:appid withKeywords:keywords];
}

//外呼邀请成员加入群聊
- (void)inviteMembers:(NSArray*)members joinChatroom:(NSString*)roomNo ofAppId:(NSString *)appid
{
    [self.VoipCallService inviteMembers:members joinChatroom:roomNo ofAppId:appid];
}
/**
 * 解散聊天室
 * @param appId 应用id
 * @param roomNo 房间号
 */
- (void) dismissChatroomWithAppId:(NSString*) appId andRoomNo:(NSString*) roomNo
{
    [self.VoipCallService dismissChatroomWithAppId:appId andRoomNo:roomNo];
}

/**
 * 踢出聊天室成员
 * @param appId 应用id
 * @param roomNo 房间号
 * @param member 成员号码
 */
- (void) removeMemberFromChatroomWithAppId:(NSString*) appId andRoomNo:(NSString*) roomNo andMember:(NSString*) member
{
    [self.VoipCallService removeMemberFromChatroomWithAppId:appId andRoomNo:roomNo andMember:member];
}
#pragma mark - 聊天室代理函数
//通知客户端收到新的聊天室信息
- (void)onReceiveChatroomMsg:(ChatroomMsg*) msg
{
    NSLog(@"onReceiveChatroomMsg-------------%@",msg);
    
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onReceiveChatroomMsg:)])
    {
        [self.UIDelegate onReceiveChatroomMsg:msg];
    }
}

//聊天室状态
- (void)onChatroomStateWithReason:(CloopenReason *) reason andRoomNo:(NSString*)roomNo
{
    NSLog(@"onChatroomeState-------------reason=%d, roomNo=%@", reason.reason, roomNo);
    if (reason.reason == 0 && roomNo.length > 0)
    {
        BOOL isExist = NO;
        for (Chatroom* room in self.chatroomListArray)
        {
            if ([room.roomNo isEqualToString:roomNo])
            {
                isExist = YES;
                break;
            }
        }
        if (!isExist)
        {
            [self queryChatroomsOfAppId:appID withKeywords:@""];
        }
    }
    
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onChatroomStateWithReason:andRoomNo:)])
    {
        [self.UIDelegate onChatroomStateWithReason:reason andRoomNo:roomNo];
    }

}

//获取聊天室的成员
- (void)onChatroomMembersWithReason:(CloopenReason *) reason andData:(NSArray*)members
{
    NSLog(@"onChatroomMembers------------- data=%@", members);
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onChatroomMembersWithReason:andData:)])
    {
        [self.UIDelegate onChatroomMembersWithReason:reason andData:members];
    }
}

//获取聊天室
- (void)onChatroomsWithReason:(CloopenReason *) reason andRooms:(NSArray*)chatrooms
{
    [self.chatroomListArray removeAllObjects];
    [self.chatroomListArray addObjectsFromArray:chatrooms];
    NSLog(@"onChatroomsInApp-------------chatrooms=%@",  chatrooms);
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onChatroomsInAppWithReason:andRooms:)])
    {
        
        [self.UIDelegate onChatroomsInAppWithReason:reason andRooms:chatrooms];
    }
    [self displayErrorAlert:reason];
}

//邀请加入聊天室
- (void)onChatroomInviteMembersWithReason:(CloopenReason *) reason andRoomNo:(NSString*)roomNo
{
    NSLog(@"onChatroomInvite-------------roomNo=%@", roomNo);
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onChatroomInviteMembersWithReason:andRoomNo:)])
    {
        [self.UIDelegate onChatroomInviteMembersWithReason:reason andRoomNo:roomNo];
    }
    [self displayErrorAlert:reason];
}

/**
 * 解散聊天室回调
 * @param reason 状态值 0:成功
 * @param roomNo 房间号
 */
- (void) onChatroomDismissWithReason:(CloopenReason *) reason andRoomNo:(NSString*) roomNo;
{
    NSLog(@"onChatroomDismissWithReason-------------roomNo=%@", roomNo);
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onChatroomDismissWithReason:andRoomNo:)])
    {
        [self.UIDelegate onChatroomDismissWithReason:reason andRoomNo:roomNo];
    }
    [self displayErrorAlert:reason];
}

/**
 * 移除成员
 * @param reason 状态值 0:成功
 * @param member 成员号
 */
- (void) onChatroomRemoveMemberWithReason:(CloopenReason *) reason andMember:(NSString*) member;
{
    NSLog(@"onChatroomRemoveMemberWithReason-------------member=%@", member);
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onChatroomRemoveMemberWithReason:andMember:)])
    {
        [self.UIDelegate onChatroomRemoveMemberWithReason:reason andMember:member];
    }
}


#pragma mark - 视频会议代理函数
//通知客户端收到新的会议信息
- (void)onReceiveVideoConferenceMsg:(VideoConferenceMsg*) msg
{
    NSLog(@"onReceiveVideoConferenceMsg-------------%@",msg.conferenceId);
    
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onReceiveVideoConferenceMsg:)])
    {
        [self.UIDelegate onReceiveVideoConferenceMsg:msg];
    }
}

//会议状态
- (void)onVideoConferenceStateWithReason:(CloopenReason *) reason andConferenceId:(NSString*)conferenceId
{
    NSLog(@"onVideoConferenceeState------------- roomNo=%@", conferenceId);
    if (reason.reason == 0 && conferenceId.length > 0)
    {
        BOOL isExist = NO;
        for (VideoConference* room in self.videoconferenceListArray)
        {
            if ([room.conferenceName isEqualToString:conferenceId])
            {
                isExist = YES;
                break;
            }
        }
        if (!isExist)
        {
            [self queryVideoConferencesOfAppId:appID withKeywords:@""];
        }
    }
    
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onVideoConferenceStateWithReason:andConferenceId:)])
    {
        
        [self.UIDelegate onVideoConferenceStateWithReason:reason andConferenceId:conferenceId];
    }
    [self displayErrorAlert:reason];
}

//获取会议的成员
- (void)onVideoConferenceMembersWithReason:(CloopenReason *) reason andData:(NSArray*)members
{
    NSLog(@"onVideoConferenceMembers-------------data=%@", members);
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onVideoConferenceMembersWithReason:andData:)])
    {
        
        [self.UIDelegate onVideoConferenceMembersWithReason:reason andData:members];
    }
    [self displayErrorAlert:reason];
}

//获取会议
- (void)onVideoConferencesWithReason:(CloopenReason *) reason andConferences:(NSArray*)conferences
{
    [self.videoconferenceListArray removeAllObjects];
//    [self.videoconferenceListArray addObjectsFromArray:conferences];
    [self.multiVideoconferenceListArray removeAllObjects];
    for (VideoConference* room in conferences)
    {
        if (room.isMultiVideo == 1)
        {
            [self.multiVideoconferenceListArray addObject:room];
        }
        else
        {
            [self.videoconferenceListArray addObject:room];
        }
    }
    NSLog(@"onVideoConferencesInApp-------------VideoConferences=%@", conferences);
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onVideoConferencesWithReason:andConferences:)])
    {
        [self.UIDelegate onVideoConferencesWithReason:reason andConferences:conferences];
    }
    [self displayErrorAlert:reason];
}

//邀请加入会议
- (void)onVideoConferenceInviteMembersWithReason:(CloopenReason *) reason andRoomNo:(NSString*)roomNo
{
    NSLog(@"onVideoConferenceInvite-------------roomNo=%@", roomNo);
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onVideoConferenceInviteMembersWithReason:andRoomNo:)])
    {
        [self.UIDelegate onVideoConferenceInviteMembersWithReason:reason andConferenceId:roomNo];
    }
    [self displayErrorAlert:reason];
}

/**
 * 解散会议回调
 * @param reason 状态值 0:成功
 * @param roomNo 房间号
 */
- (void) onVideoConferenceDismissWithReason:(CloopenReason *) reason andConferenceId:(NSString*) conferenceId;
{
    NSLog(@"onVideoConferenceDismissWithReason-------------roomNo=%@", conferenceId);
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onVideoConferenceDismissWithReason:andConferenceId:)])
    {
        [self.UIDelegate onVideoConferenceDismissWithReason:reason andConferenceId:conferenceId];
    }
    [self displayErrorAlert:reason];
}

/**
 * 移除成员
 * @param reason 状态值 0:成功
 * @param member 成员号
 */
- (void) onVideoConferenceRemoveMemberWithReason:(CloopenReason *) reason andMember:(NSString*) member;
{
    NSLog(@"onVideoConferenceRemoveMemberWithReason-------------member=%@", member);
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onVideoConferenceRemoveMemberWithReason:andMember:)])
    {
        [self.UIDelegate onVideoConferenceRemoveMemberWithReason:reason andMember:member];
    }
    [self displayErrorAlert:reason];
}
/**
 * 切换主屏幕回调
 * @param reason 状态值 0:成功
 */
- (void) onSwitchRealScreenToVoipWithReason:(CloopenReason *) reason
{
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onSwitchRealScreenToVoipWithReason:)])
    {
        [self.UIDelegate onSwitchRealScreenToVoipWithReason:reason];
    }
    if (reason.reason != 111805 && reason.reason != 111813)
        [self displayErrorAlert:reason];
}

/**
 * 发送头像到视频会议
 * @param reason 状态值 0:成功
 * @param portraitPath 本地头像路径
 */
- (void) onSendLocalPortraitWithReason:(CloopenReason *) reason andPortrait:(NSString*)portraitPath
{
    isSendingPortrait = NO;
    NSLog(@"onSendLocalPortraitWithReason-------Path=%@", portraitPath);
    if([[NSFileManager defaultManager] removeItemAtPath:portraitPath error:nil])
    {
        NSLog(@"onSendPortraitToVideoConforence deletepath=%@",portraitPath);
    }
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onSendLocalPortraitWithReason:andPortrait:)])
    {
        [self.UIDelegate onSendLocalPortraitWithReason:reason andPortrait:portraitPath];
    }
    if (reason.reason != 111805 && reason.reason != 111813)
        [self displayErrorAlert:reason];
}

/**
 * 获取视频会议中的成员头像
 * @param reason 状态值 0:成功
 * @param portraitlist 成员头像列表
 */
- (void) onGetPortraitsFromVideoConferenceWithReason:(CloopenReason *) reason andPortraitList:(NSArray*)portraitlist
{
    if (reason.reason != 111805 && reason.reason != 111813)
        [self displayErrorAlert:reason];
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGetPortraitsFromVideoConferenceWithReason:andPortraitList:)])
    {
        [self.UIDelegate onGetPortraitsFromVideoConferenceWithReason:reason andPortraitList:portraitlist];
    }
}

//发布视频
-(void)onPublishVideoInVideoConferenceWithReason:(CloopenReason *)reason
{
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onPublishVideoInVideoConferenceWithReason:)])
    {
        [self.UIDelegate onPublishVideoInVideoConferenceWithReason:reason];
    }
    if (reason.reason != 0)
        [self displayErrorAlert:reason];
}

//取消视频发布
-(void)onUnpublishVideoInVideoConferenceWithReason:(CloopenReason *)reason
{
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onUnpublishVideoInVideoConferenceWithReason:)])
    {
        [self.UIDelegate onUnpublishVideoInVideoConferenceWithReason:reason];
    }
    if (reason.reason != 0)
        [self displayErrorAlert:reason];
}


- (void)onRequestConferenceMemberVideoFailed:(CloopenReason*)reason andConferenceId:(NSString*)conferenceId andVoip:(NSString*)voip
{
    NSLog(@"\r\n////////////////onRequestConferenceMemberVideoFailed reason=%d, conif=%@, voip=%@",reason.reason,conferenceId,voip);
}

- (void)onCancelConferenceMemberVideo:(CloopenReason*)reason andConferenceId:(NSString*)conferenceId andVoip:(NSString*)voip
{
    NSLog(@"\r\n/////////////////onCancelConferenceMemberVideo reason=%d, conif=%@, voip=%@",reason.reason,conferenceId,voip);
}

-(void)delayCall:(NSTimer*)theTimer
{
    NSDictionary* callInfo = (NSDictionary*)theTimer.userInfo;
    extern BOOL globalisVoipView;
    if (globalisVoipView)
    {
        [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(delayCall:) userInfo:callInfo repeats:NO];
    }
    else
    {
        [self.UIDelegate incomingCallID:[callInfo objectForKey:@"callid"]  caller:[callInfo objectForKey:@"caller"] phone:[callInfo objectForKey:@"callerphone"] name:[callInfo objectForKey:@"callername"]  callStatus:IncomingCallStatus_incoming callType:[[callInfo objectForKey:@"calltype"] intValue]];
    }
}


#pragma mark - 多媒体IM
//发送语音IM
- (NSString*) startVoiceRecordingWithReceiver:(NSString*) receiver andPath:(NSString*) path andChunked:(BOOL) chunked andUserdata:(NSString *)userdata
{
    return [self.VoipCallService startVoiceRecordingWithReceiver:receiver andPath:path andChunked:chunked andUserdata:userdata];
}

//确认已下载多媒体IM
- (void) confirmInstanceMessageWithMsgId :(NSArray*) msgIds
{
    [self.VoipCallService confirmInstanceMessageWithMsgId:msgIds];
}

/********************多媒体IM的方法********************/
//发送多媒体IM结果回调
- (void) onSendInstanceMessageWithReason: (CloopenReason *) reason andMsg:(InstanceMsg*) data
{
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onSendInstanceMessageWithReason:andMsg:)])
    {
        [self.UIDelegate onSendInstanceMessageWithReason:reason andMsg:data];
    }
    if (reason.reason == 170016 || reason.reason == 170017 || reason.reason == 112037)
        return;
    [self displayErrorAlert:reason];
}

- (void)onDownloadAttachedWithReason:(CloopenReason *)reason andFileName:(NSString*) fileName
{
    switch (reason.reason)
    {
        case 0:
        {
            NSString *fileN = [fileName lastPathComponent];
            for (IMMessageObj *vmsg in self.attachDownArray)
            {
                NSRange range1 = [vmsg.fileUrl rangeOfString:@"?fileName="];
                NSString *file = [vmsg.fileUrl substringFromIndex:range1.location+range1.length];
                if ([fileN isEqualToString:file])//根据返回的本地文件名找到对应的AppVoiceMsgInfo对象
                {
                    [self confirmInstanceMessageWithMsgId:[NSArray arrayWithObject:vmsg.msgid]];
                    {
                        vmsg.filePath = fileName;
                        if ([[fileN pathExtension] isEqualToString:@"amr"])
                        {
                            if (vmsg.duration <=0)
                            {
                                vmsg.duration = [self getVoiceDuration:fileName];
                            }
                        }
                        else
                            vmsg.duration = 0;
                        [self.imDBAccess updateFilePath:vmsg.filePath andMsgid:vmsg.msgid andDuration:vmsg.duration];
                        [self.attachDownArray removeObject:vmsg];
                        AudioServicesPlaySystemSound(1007);
                    }
                    break;
                }
            }
        }
            break;
        case 170016:
        case 170017:
        {
            NSString *fileN = [fileName lastPathComponent];
            for (IMMessageObj *vmsg in self.attachDownArray)
            {
                NSRange range1 = [vmsg.fileUrl rangeOfString:@"?fileName="];
                NSString *file = [vmsg.fileUrl substringFromIndex:range1.location+range1.length];
                if ([fileN isEqualToString:file])//根据返回的本地文件名找到对应的AppVoiceMsgInfo对象
                {
                    [self.imDBAccess deleteMessageOfMsgid:vmsg.msgid];
                    [self.attachDownArray removeObject:vmsg];
                    break;
                }
            }
        }
            break;
        default:
            break;
    }

    if (self.unDownLoadedCount == 0 &&self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseDownLoadMediaMessageStatus:)])
    {
        [self.UIDelegate responseDownLoadMediaMessageStatus:reason];
    }
    if (reason.reason == 170016 || reason.reason == 170017)
        return;
    [self displayErrorAlert:reason];
}
//通知客户端收到新的IM信息
- (void)onReceiveInstanceMessage:(InstanceMsg*) msg
{
    NSLog(@"onReceiveInstanceMessage %@", msg);
    
    if ([msg isKindOfClass:[IMTextMsg class]])
    {
        IMTextMsg *textmsg = (IMTextMsg*)msg;
        NSLog(@"[onReceiveInstanceMessage] IMTextMsg sender=%@;receiver=%@",textmsg.sender,textmsg.receiver);
        NSLog(@"[onReceiveInstanceMessage] text msgId=%@", textmsg.msgId);
        if ([textmsg.sender isEqualToString:@"registrar"])
        {
            return;
        }
        if([self.imDBAccess isMessageExistOfMsgid:textmsg.msgId])
            return;
        NSString *message = textmsg.message;
        IMMessageObj *immsg = [[IMMessageObj alloc] init];
        immsg.msgid = textmsg.msgId;
        if ([UIDevice currentDevice].systemVersion.floatValue > 6)
        {
            message = [self.emojiCon convertEmojiSoftbankToUnicode:textmsg.message];
        }
        immsg.content = message;
        immsg.sessionId = textmsg.sender;
        immsg.sender = textmsg.sender;
        immsg.msgtype = EMessageType_Text;
        immsg.isRead = EReadState_Unread;
        immsg.imState = EMessageState_Received;
        immsg.dateCreated = textmsg.dateCreated;
        NSLog(@"[onReceiveInstanceMessage]text msgtime=%@", textmsg.dateCreated);
        NSLog(@"[onReceiveInstanceMessage]text userdata=%@", textmsg.userData);
        NSLog(@"[onReceiveInstanceMessage]text textmsg.msgId=%@", textmsg.msgId);
        if (textmsg.receiver.length>0)
        {
            NSString *g = [textmsg.receiver substringToIndex:1];
            if ([g isEqualToString:@"g"])
            {
                immsg.sessionId = textmsg.receiver;
            }
        }
        
        NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *curTimeStr = [dateformatter stringFromDate:[NSDate date]];
        [dateformatter release];
        immsg.curDate = curTimeStr;
        [self.imDBAccess insertIMMessage:immsg];
        [immsg release];
        
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseMessageStatus:callNumber:data:)])
        {
            [self.UIDelegate responseMessageStatus:EMessageStatus_Received callNumber:textmsg.sender data:message];
        }

    }
    else if ([msg isKindOfClass:[IMAttachedMsg class]])
    {
        IMAttachedMsg* attachmsg = (IMAttachedMsg*)msg;
        NSLog(@"[onReceiveInstanceMessage] IMAttachedMsg sender=%@;receiver=%@", attachmsg.sender, attachmsg.receiver);
        NSLog(@"[onReceiveInstanceMessage] attachmsg msgId=%@", attachmsg.msgId);
        if([self.imDBAccess isMessageExistOfMsgid:attachmsg.msgId])
            return;
        IMMessageObj *immsg = [[IMMessageObj alloc] init];
        immsg.msgid = attachmsg.msgId;
        immsg.fileUrl = attachmsg.fileUrl;
        immsg.fileExt = attachmsg.ext;
        immsg.sessionId = attachmsg.sender;
        if (attachmsg.receiver.length>0)
        {
            NSString *g = [attachmsg.receiver substringToIndex:1];
            if ([g isEqualToString:@"g"])
            {
                immsg.sessionId = attachmsg.receiver;
            }
        }
        
        NSLog(@"[onReceiveInstanceMessage]attachmsg msgtime=%@", attachmsg.dateCreated);
        NSLog(@"[onReceiveInstanceMessage]attachmsg userdata=%@", attachmsg.userData);
        
        immsg.sender = attachmsg.sender;
        if ([attachmsg.ext isEqualToString:@"amr"]) {
            immsg.msgtype = EMessageType_Voice;
        }
        else
            immsg.msgtype = EMessageType_File;
        immsg.isRead = EReadState_Unread;
        immsg.imState = EMessageState_Received;
        immsg.dateCreated = attachmsg.dateCreated;
        
        NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *curTimeStr = [dateformatter stringFromDate:[NSDate date]];
        [dateformatter release];
        immsg.curDate = curTimeStr;
        [self.attachDownArray addObject:immsg];
        [self.imDBAccess insertIMMessage:immsg];
        [immsg release];
        
//        NSString *file =[attachmsg.fileUrl lastPathComponent];
//        NSString *fullFile =[NSTemporaryDirectory() stringByAppendingPathComponent:file];
        NSRange range1 = [attachmsg.fileUrl rangeOfString:@"?fileName="];
        NSString *file = [attachmsg.fileUrl substringFromIndex:range1.location+range1.length];
        NSString *fullFile =[NSTemporaryDirectory() stringByAppendingPathComponent:file];        
        
        DownloadInfo* downloadInfo =[[DownloadInfo alloc] init];
        downloadInfo.fileName = fullFile;
        downloadInfo.fileUrl  = attachmsg.fileUrl;
        downloadInfo.isChunked = attachmsg.chunked;
        [self.VoipCallService downloadAttached:[NSArray arrayWithObject:downloadInfo]];
        [downloadInfo release];
    }
    else if([msg isKindOfClass:[IMDismissGroupMsg class]])
    {
        IMDismissGroupMsg *instanceMsg = (IMDismissGroupMsg*)msg;
        
        [imDBAccess insertNoticeMessage:msg withType:EGroupNoticeType_DismissGroup];
        
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseIMGroupNotice:data:)])
        {
            [self.UIDelegate responseIMGroupNotice:instanceMsg.groupId data:@"群组解散"];
        }
    }
    else if([msg isKindOfClass:[IMInviterMsg class]])
    {
        IMInviterMsg *instanceMsg = (IMInviterMsg*)msg;
               
        [imDBAccess insertNoticeMessage:msg withType:EGroupNoticeType_InviteJoin];
        
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseIMGroupNotice:data:)])
        {
            [self.UIDelegate responseIMGroupNotice:instanceMsg.groupId data:@"有群组邀请加入"];
        }
    }
    else if([msg isKindOfClass:[IMProposerMsg class]])
    {
        IMProposerMsg *instanceMsg = (IMProposerMsg*)msg;
       
        [imDBAccess insertNoticeMessage:msg withType:EGroupNoticeType_ApplyJoin];
        
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseIMGroupNotice:data:)])
        {
            [self.UIDelegate responseIMGroupNotice:instanceMsg.groupId data:@"有人申请加入群组"];
        }
    }
    else if([msg isKindOfClass:[IMQuitGroupMsg class]])
    {
        IMQuitGroupMsg *instanceMsg = (IMQuitGroupMsg*)msg;
        [imDBAccess insertNoticeMessage:msg withType:EGroupNoticeType_QuitGroup];
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseIMGroupNotice:data:)])
        {
            [self.UIDelegate responseIMGroupNotice:instanceMsg.groupId data:@"有人退出群组"];
        }
    }
    else if([msg isKindOfClass:[IMRemoveMemberMsg class]])
    {
        IMRemoveMemberMsg *instanceMsg = (IMRemoveMemberMsg*)msg;
        [imDBAccess insertNoticeMessage:msg withType:EGroupNoticeType_RemoveMember];
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseIMGroupNotice:data:)])
        {
            [self.UIDelegate responseIMGroupNotice:instanceMsg.groupId data:@"被移除群组"];
        }
    }
    else if([msg isKindOfClass:[IMReplyJoinGroupMsg class]])
    {
        IMReplyJoinGroupMsg *instanceMsg = (IMReplyJoinGroupMsg*)msg;
        [imDBAccess insertNoticeMessage:msg withType:EGroupNoticeType_ReplyJoin];
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseIMGroupNotice:data:)])
        {
            [self.UIDelegate responseIMGroupNotice:instanceMsg.groupId data:@"申请加入群组消息回复"];
        }
    }
    else if([msg isKindOfClass:[IMReplyInviteGroupMsg class]])
    {
        IMReplyInviteGroupMsg *instanceMsg = (IMReplyInviteGroupMsg*)msg;
        [imDBAccess insertNoticeMessage:msg withType:EGroupNoticeType_ReplyInvite];
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseIMGroupNotice:data:)])
        {
            [self.UIDelegate responseIMGroupNotice:instanceMsg.groupId data:@"邀请加入群组消息回复"];
        }
    }
    else if([msg isKindOfClass:[IMJoinGroupMsg class]])
    {
        IMJoinGroupMsg *instanceMsg = (IMJoinGroupMsg*)msg;
       
        [imDBAccess insertNoticeMessage:msg withType:EGroupNoticeType_JoinedGroup];
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(responseIMGroupNotice:data:)])
        {
            [self.UIDelegate responseIMGroupNotice:instanceMsg.groupId data:@"有人申请加入群组"];
        }
    }
}


//下载未下载完成的数据内容
- (void)downloadPreIMMsg
{
    NSArray *preImmsgArr = [self.imDBAccess getMessageOfFilePathisNull];
    
    for (IMMessageObj *newObj in preImmsgArr)
    {
        BOOL isNew = YES;
        for (IMMessageObj *downObj in self.attachDownArray)
        {            
            if ([newObj.msgid isEqualToString:downObj.msgid])
            {
                isNew = NO;
                break;
            }
        }
        if (isNew)
        {
            [self.attachDownArray addObject:newObj];
        }
    }
    
    for (IMMessageObj *obj in preImmsgArr)
    {
        NSRange range1 = [obj.fileUrl rangeOfString:@"?fileName="];
        NSString *file = [obj.fileUrl substringFromIndex:range1.location+range1.length];
        NSString *fullFile =[NSTemporaryDirectory() stringByAppendingPathComponent:file];
        
        DownloadInfo* downloadInfo =[[DownloadInfo alloc] init];
        downloadInfo.fileName = fullFile;
        downloadInfo.fileUrl  = obj.fileUrl;
        downloadInfo.isChunked = obj.isChunk;
        [self.VoipCallService downloadAttached:[NSArray arrayWithObject:downloadInfo]];
        [downloadInfo release];
    }
}

- (void)testUdpNet
{
    testCount = 0;
    succeedCount = 0;
    if (udpTestTimer)
    {
        [udpTestTimer invalidate];
        udpTestTimer = nil;
        [udpSocket close];
        self.udpSocket = nil;
    }
    self.udpSocket = [[[AsyncUdpSocket alloc] initWithDelegate:self] autorelease];
    udpTestTimer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(sendUdpTest) userInfo:nil repeats:YES];
}

-(void)stopUdpTest
{
    [udpTestTimer invalidate];
    udpTestTimer = nil;
    [udpSocket close];
    self.udpSocket = nil;
}

-(void)sendUdpTest{
    if (testCount >= 1000)
    {
        [udpTestTimer invalidate];
        udpTestTimer = nil;
        [udpSocket close];
        self.udpSocket = nil;
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onTestUdpNetSucceedCount:)])
        {
            [self.UIDelegate onTestUdpNetSucceedCount:succeedCount];
        }
        return;
    }
    testCount++;
    
    NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *curTimeStr = [dateformatter stringFromDate:[NSDate date]];
    [dateformatter release];
    
    [self sendToUDPServerMsg:curTimeStr address:@"42.121.115.160" port:2009];
}

-(void)sendToUDPServerMsg:(NSString*) msg address:(NSString*)address port:(int)port{
    [udpSocket receiveWithTimeout:10 tag:2]; //设置超时10秒
    NSData *data=[msg dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data toHost:address port:port withTimeout:10 tag:1]; //发送udp
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onTestUdpNetStatus:andReceivedTime:)])
    {
        [self.UIDelegate onTestUdpNetStatus:1 andReceivedTime:0];
    }
}


-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
    NSString* rData= [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSDateFormatter *inputFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate* inputDate = [inputFormatter dateFromString:rData];
    NSDate* date = [NSDate date];
    int ms = [date timeIntervalSinceDate:inputDate]*1000;
    succeedCount ++;
    //NSLog(@"onUdpSocket:didReceiveData:---%@ count %d",rData,count++);
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onTestUdpNetStatus:andReceivedTime:)])
    {
        [self.UIDelegate onTestUdpNetStatus:0 andReceivedTime:ms];
    }
    return YES;
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
  //  NSLog(@"didNotSendDataWithTag----");
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onTestUdpNetStatus:andReceivedTime:)])
    {
        [self.UIDelegate onTestUdpNetStatus:-1 andReceivedTime:0];
    }
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    //NSLog(@"didNotReceiveDataWithTag----");
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onTestUdpNetStatus:andReceivedTime:)])
    {
        [self.UIDelegate onTestUdpNetStatus:-2 andReceivedTime:0];
    }
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    //NSLog(@"didSendDataWithTag----");
}

-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock{
    //NSLog(@"onUdpSocketDidClose----");
}
- (void) onEditTestNumWithReason:(CloopenReason *) reason
{
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onEditTestNumWithReason:)])
    {
        [self.UIDelegate onEditTestNumWithReason:reason];
    }
    [self displayErrorAlert:reason];
}

-(NSString*)getHttpOrHttps
{
    if ([self.serverIP hasPrefix:@"http"])
    {
        return @"";
    }
    else
    {
        return @"https://";
    }
}

#pragma mark - 发起外呼通知
//phoneNumber    必选    待拨打号码
- (void)LandingCall:(NSString*)phoneNO
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/Accounts/%@/Calls/LandingCalls?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.mainAccount,[self getMainSig:timestamp]];
    NSLog(@"Demo LandingCalls url= %@",requestUrl);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
        request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:phoneNO, KEY_USERINFO_TO_PHONENUMBER, nil];
    request.requestType = ERequestType_LandingCalls;
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getMainAuthorization:timestamp]];
    NSString *xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><LandingCall><appId>%@</appId><mediaName type=\"1\">%@</mediaName><to>0086%@</to></LandingCall>",self.appID, @"ccp_marketingcall.wav",phoneNO];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}


#pragma mark - 发起语音验证码请求
//verifyCode 	 必选	 验证码内容，为数字和英文字母，不区分大小写，长度4-20位
//playTimes	 	 必选	 播放次数，1－3次
//to             必选     接收验证码的手机、座机号码
//respUrl	 	 可选	 用户发起语音验证码请求后，云通讯平台将向该url地址发送呼叫结果通知
- (void)VoiceCodeWithVerifyCode:(NSString*)verifyCode andTo:(NSString*)to andPlayTimes:(int) playTimes andRespUrl:(NSString*)respUrl
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/Accounts/%@/Calls/VoiceVerify?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.mainAccount,[self getMainSig:timestamp]];
    NSLog(@"Demo LandingCalls url= %@",requestUrl);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_VoiceCode;
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getMainAuthorization:timestamp]];
    NSString *xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><VoiceVerify><appId>%@</appId><verifyCode>%@</verifyCode><playTimes>%d</playTimes><to>%@</to></VoiceVerify>",self.appID,verifyCode,playTimes,to];
    NSLog(@"Demo VoiceVerify xmlBody= %@",xmlBody);
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

-(void)postRespondsEvent:(ASIHTTPRequest*)request andElement:(Demo_GDataXMLElement*)element andReason:(CloopenReason*) reason andData:(NSMutableDictionary*) data
{
    if (request.requestType == ERequestType_LandingCalls)
    {
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onLandingCAllsStatus:andCallSid:andToPhoneNumber:andDateCreated:)])
        {
            NSString* strToPhone = [request.userInfo objectForKey:KEY_USERINFO_TO_PHONENUMBER];
            [self.UIDelegate onLandingCAllsStatus: reason andCallSid:nil andToPhoneNumber:strToPhone andDateCreated:nil];
        }
    }
    else if (request.requestType == ERequestType_VoiceCode)
    {
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onVoiceCode:)])
        {
            [self.UIDelegate onVoiceCode: reason];
        }
    }
    else if (request.requestType == ERequestType_Group_CreateGroup)
    {
        [self parseCreateGroup:element withData:data];
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGroupCreateGroupWithReason:andGroupId:)])
        {
              [self.UIDelegate onGroupCreateGroupWithReason:reason andGroupId:[data objectForKey:KEY_RESPONSE_USERDATA]];
        }
    }
    
    else if (request.requestType == ERequestType_Group_ModifyGroup)
    {
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGroupModifyGroupWithReason:)])
        {
            [self.UIDelegate onGroupModifyGroupWithReason:reason];
        }
    }
    
    else if (request.requestType == ERequestType_Group_DeleteGroup)
    {
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGroupDeleteGroupWithReason:)])
        {
            [self.UIDelegate onGroupDeleteGroupWithReason:reason];
        }
    }
        
    else if (request.requestType == ERequestType_Group_GetPublicGroups)
    {
        [self parse_QueryPublicGroups:element withData:data];
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGroupQueryPublicGroupsWithReason:andGroups:)])
        {
            [self.UIDelegate onGroupQueryPublicGroupsWithReason:reason andGroups:[data objectForKey:KEY_RESPONSE_USERDATA]];
        }
    }
    else if (request.requestType == ERequestType_Group_SearchPublicGroups)
    {
        [self parse_SearchPublicGroups:element withData:data];
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGroupSearchPublicGroupsWithReason:andGroups:)])
        {
            [self.UIDelegate onGroupSearchPublicGroupsWithReason:reason andGroups:[data objectForKey:KEY_RESPONSE_USERDATA]];
        }
    }

    else if (request.requestType == ERequestType_Group_QueryGroup)
    {
        [self parse_QueryGroupDetail:element withData:data];
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGroupQueryGroupWithReason:andGroup:)])
        {
            [self.UIDelegate onGroupQueryGroupWithReason:reason andGroup:[data objectForKey:KEY_RESPONSE_USERDATA]];
        }
    }
    else if (request.requestType == ERequestType_Group_JoinGroup)
    {
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGroupJoinGroupWithReason:)])
        {
            [self.UIDelegate onGroupJoinGroupWithReason:reason];
        }
    }

    else if (request.requestType == ERequestType_Group_InviteJoinGroup)
    {
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGroupInviteJoinGroupWithReason:)])
        {
            [self.UIDelegate onGroupInviteJoinGroupWithReason:reason];
        }
    }
    else if (request.requestType == ERequestType_Group_DeleteGroupMember)
    {
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGroupDeleteGroupMemberWithReason:)])
        {
            [self.UIDelegate onGroupDeleteGroupMemberWithReason:reason];
        }
    }
    else if (request.requestType == ERequestType_Group_LogoutGroup)
    {
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGroupLogoutGroupWithReason:)])
        {
            [self.UIDelegate onGroupLogoutGroupWithReason:reason];
        }
    }
    else if (request.requestType == ERequestType_Member_QueryMember)
    {
        [self parseMember_QueryMember: element withData:data];
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onMemberQueryMemberWithReason:andMembers:)])
        {
            [self.UIDelegate onMemberQueryMemberWithReason:reason andMembers:[data objectForKey:KEY_RESPONSE_USERDATA]];
        }
    }
    else if (request.requestType == ERequestType_Member_QueryGroup)
    {
        [self parseMember_QueryGroup:element withData:data];
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onMemberQueryGroupWithReason:andGroups:)])
        {
            [self.UIDelegate onMemberQueryGroupWithReason:reason andGroups:[data objectForKey:KEY_RESPONSE_USERDATA]];
        }
    }
    else if (request.requestType == ERequestType_Member_ForbidSpeak)
    {
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onForbidSpeakWithReason:)])
        {
            [self.UIDelegate onForbidSpeakWithReason:reason];
        }
    }
    else if (request.requestType == ERequestType_Member_AskJoin)
    {
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onMemberAskJoinWithReason:)])
        {
            [self.UIDelegate onMemberAskJoinWithReason:reason];
        }
    }
    else if (request.requestType == ERequestType_Member_InviteGroup)
    {
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onMemberInviteGroupWithReason:)])
        {
            [self.UIDelegate onMemberInviteGroupWithReason:reason];
        }
    }
    else if (request.requestType == ERequestType_GrupCard_ModifyCard)
    {
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onModifyGroupCardWithReason:)])
        {
            [self.UIDelegate onModifyGroupCardWithReason:reason];
        }
    }
    else if (request.requestType == ERequestType_GrupCard_QueryCard)
    {
         [self parse_queryCard:element withData:data];
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onQueryCardWithReason:andGroupCard:)])
        {
            [self.UIDelegate onQueryCardWithReason:reason andGroupCard:[data objectForKey:KEY_RESPONSE_USERDATA]];
        }
    }
    else if (request.requestType == ERequestType_GetCategoryList)
    {
        [self parseGetCategoryList:element withData:data];
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGetCategoryListWithReason:andCategorys:)])
        {
            [self.UIDelegate onGetCategoryListWithReason:reason andCategorys:[data objectForKey:KEY_RESPONSE_USERDATA]];
        }
    }
    else if (request.requestType == ERequestType_GetServiceNum)
    {
        [self parseGetServiceNum:element];
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGetServiceNumWithReason:)])
        {
            [self.UIDelegate onGetServiceNumWithReason:reason];
        }
    }
    else if (request.requestType == ERequestType_GetExpertList)
    {
        [self parseGetExpertList:element withData:data];
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGetExpertListWithReason:andExperts:)])
        {
            [self.UIDelegate onGetExpertListWithReason:reason andExperts:[data objectForKey:KEY_RESPONSE_USERDATA]];
        }
    }
    else if (request.requestType == ERequestType_LockExpert)
    {
        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onLoceExpertWithReason:)])
        {
            [self.UIDelegate onLoceExpertWithReason:reason];
        }
    }
//    else if (request.requestType == ERequestType_GetDemoAccounts)
//    {
//        [self parseGetDemoAccounts:element withData:data];
//        if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGetDemoAccountsWithReason:)])
//        {
//            if (reason.reason == 0)
//            {
//                if (!self.accountArray)
//                {
//                    self.accountArray = [[NSMutableArray alloc] init];
//                    
//                }
//                else
//                    [self.accountArray removeAllObjects];
//                NSDictionary* myDict = [data objectForKey:KEY_RESPONSE_USERDATA];
//                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                [userDefaults setObject:__BASE64(self.developerUserName) forKey:@"developerUserName"];
//                [userDefaults setObject:__BASE64(self.developerUserPasswd) forKey:@"developerUserPasswd"];
//                [userDefaults synchronize];
//                self.mainAccount = [myDict objectForKey:@"main_account"];
//                self.mainToken = [myDict objectForKey:@"main_token"];
//                self.developerNickName = [myDict objectForKey:@"nick_name"];
//                self.registeredPhone = [myDict objectForKey:@"mobile"];
//                self.test_numberArray = [NSMutableArray arrayWithArray:[[myDict objectForKey:@"test_number"] componentsSeparatedByString:@","]];
//                NSArray* applications = [myDict objectForKey:@"Applications"];
//                if ([applications count] > 0)
//                {
//                    NSDictionary *applicationDict =  [applications objectAtIndex:0];
//                    {
//                        self.appID = [applicationDict objectForKey:@"appId"];
//                        self.appName = [applicationDict objectForKey:@"appName"];
//                        NSArray* accountsArray = [applicationDict objectForKey:@"SubAccounts"];
//                        NSMutableArray* tmpAccountArray = [[NSMutableArray alloc] init];
//                        for (NSDictionary *subaccountInfo in accountsArray)
//                        {
//                            AccountInfo *info = [[AccountInfo alloc] init];
//                            info.subAccount = [subaccountInfo objectForKey:@"sub_account"];
//                            info.subToken = [subaccountInfo objectForKey:@"sub_token"];
//                            info.voipId = [subaccountInfo objectForKey:@"voip_account"];
//                            info.password = [subaccountInfo objectForKey:@"voip_token"];
//                            [tmpAccountArray addObject:info];
//                            [info release];
//                        }
//                        
//                        NSComparator cmptr = ^(id obj1, id obj2)
//                        {
//                            AccountInfo *account1 = (AccountInfo *)obj1;
//                            AccountInfo *account2 = (AccountInfo *)obj2;
//                            
//                            if ([account1.voipId longLongValue] > [account2.voipId longLongValue])
//                            {
//                                return (NSComparisonResult)NSOrderedDescending;
//                            }
//                            if ([account1.voipId longLongValue] < [account2.voipId longLongValue])
//                            {
//                                return (NSComparisonResult)NSOrderedAscending;  
//                            }
//                            return (NSComparisonResult)NSOrderedSame;  
//                        };
//                        [self.accountArray addObjectsFromArray:[tmpAccountArray sortedArrayUsingComparator:cmptr]];
//                        [tmpAccountArray release];
//                    }
//                }
//                else
//                {
//                    reason.reason = 170090;
//                    reason.msg = @"获取账号信息失败，没有找到Applications节点";
//                    NSLog(@"获取账号信息失败，没有找到Applications节点");
//                }
//            }
//            [self.UIDelegate onGetDemoAccountsWithReason:reason];
//        }
//    }
}

#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    
    NSString *responseString = [[NSString alloc] initWithData:(NSData *)responseData  encoding:NSUTF8StringEncoding];
    NSLog(@"[CCPRestService] request type is %d requestFinished body=%@",request.requestType,responseString);
    [responseString release];
    Demo_GDataXMLDocument *xmldoc = [[Demo_GDataXMLDocument alloc] initWithData:responseData options:0 error:nil];
    if (!xmldoc)
    {
        CloopenReason* myReason = [[CloopenReason alloc] init];
        myReason.reason = ERequestType_XmlError;
        [self postRespondsEvent:request andElement:nil andReason:myReason andData:nil];
        [myReason release];
        [xmldoc release];
        return;
    }
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    [userData setValuesForKeysWithDictionary:request.userInfo];
    Demo_GDataXMLElement *rootElement = [xmldoc rootElement];
    
    NSArray *statuscodeArray = [rootElement elementsForName:@"statusCode"];
    NSString* strStatusCode = nil;
    int status = 0;
    NSString* strMsg = nil;
    if (statuscodeArray.count > 0)
    {
        Demo_GDataXMLElement *element = (Demo_GDataXMLElement *)[statuscodeArray objectAtIndex:0];
        strStatusCode = element.stringValue;
        status = strStatusCode.integerValue;
        
        NSArray *statusmsgArray = [rootElement elementsForName:@"statusMsg"];
        if (statusmsgArray.count > 0)
        {
            Demo_GDataXMLElement *msgelement = (Demo_GDataXMLElement *)[statusmsgArray objectAtIndex:0];
            strMsg = msgelement.stringValue;
        }
    }
    else
    {
        status = ERequestType_XmlError;
    }
    
    if(request.requestType == ERequestType_VoiceCode)
    {
        status = 0;//测试，语音验证码总是成功
    }
    
    CloopenReason* myReason = [[CloopenReason alloc] init];
    myReason.reason = status;
    myReason.msg = strMsg;
    [self postRespondsEvent:request andElement:rootElement andReason:myReason andData:userData];
    [myReason release];
    [userData release];
    [xmldoc release];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"[CCPRestService] requestFailed error=%@",error);
    CloopenReason* myReason = [[CloopenReason alloc] init];
    myReason.reason = ERequestType_NetError;
    [self postRespondsEvent:request andElement:nil andReason:myReason andData:nil];
    [myReason release];
}

//得到当前时间的字符串
- (NSString *)getTimestamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    return currentDateStr;
}

//根据sid和当前时间字符串获取一个Authorization编码
- (NSString *)getAuthorization:(NSString *)timestamp
{
    NSString *authorizationString = [NSString stringWithFormat:@"%@:%@",self.subAccountSid,timestamp];
    return [ASIHTTPRequest base64forData:[authorizationString dataUsingEncoding:NSUTF8StringEncoding]];
}

//根据sid和当前时间字符串获取一个Authorization编码
- (NSString *)getMainAuthorization:(NSString *)timestamp
{
    NSString *authorizationString = [NSString stringWithFormat:@"%@:%@",self.mainAccount,timestamp];
    return [ASIHTTPRequest base64forData:[authorizationString dataUsingEncoding:NSUTF8StringEncoding]];
}

//获取sig编码
- (NSString *)getSig:(NSString *)timestamp
{
    NSString *sigString = [NSString stringWithFormat:@"%@%@%@", self.subAccountSid, self.subAuthToken, timestamp];
    const char *cStr = [sigString UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

//获取sig编码
- (NSString *)getMainSig:(NSString *)timestamp
{
    NSString *sigString = [NSString stringWithFormat:@"%@%@%@", self.mainAccount, self.mainToken, timestamp];
    const char *cStr = [sigString UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

#pragma mark - 多媒体IM群组
/**
 * 创建群组
 * @param name          NSString		群组名字
 * @param type          NSString		群组类型 0：临时组(上限100人)  1：普通组(上限300人)  2：VIP组 (上限500人)
 * @param declared      NSString		群组公告
 * @param permission	NSInteger     	申请加入模式 0：默认直接加入1：需要身份验证 2:私有群组
 */
- (void) createGroupWithName:(NSString*) name andType:(NSInteger) type andDeclared:(NSString*) declared andPermission:(NSInteger) permission
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Group/CreateGroup?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_Group_CreateGroup;
    IMGroupInfo* group =[[IMGroupInfo alloc] init];
    group.name = name;
    group.type = type;
    group.declared = declared;
    group.permission = permission;
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:group, KEY_USERINFO_IMGROUP_DATA, nil];
    [group release];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody;
    if (declared.length == 0)
    {
        xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><name>%@</name><type>%d</type><declared></declared><permission>%d</permission></Request>", name, type,permission];
    }
    else
        xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><name>%@</name><type>%d</type><declared>%@</declared><permission>%d</permission></Request>", name, type,declared,permission];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

/**
 * 修改群组
 * @param groupId       NSString		群组ID
 * @param name          NSString		群组名字
 * @param declared      NSString		群组公告
 * @param permission	NSInteger     	申请加入模式 0：默认直接加入1：需要身份验证 2:私有群组
 */
- (void) modifyGroupWithGroupId:(NSString*) groupId andName:(NSString*) name andDeclared:(NSString*) declared andPermission:(NSInteger) permission
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Group/ModifyGroup?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_Group_ModifyGroup;
    IMGroupInfo* group =[[IMGroupInfo alloc] init];
    group.groupId = groupId;
    group.name = name;
    group.declared = declared;
    group.permission = permission;
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:group, KEY_USERINFO_IMGROUP_DATA, nil];
    [group release];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><groupId>%@</groupId><name>%@</name><declared>%@</declared><permission>%d</permission></Request>",groupId,name,declared,permission];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

/**
 * 删除群组
 * @param groupId       NSString		群组ID
 */
- (void) deleteGroupWithGroupId:(NSString*) groupId
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Group/DeleteGroup?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_Group_DeleteGroup;
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:groupId, KEY_USERINFO_IMGROUPID, nil];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><groupId>%@</groupId></Request>",groupId];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

/**
 * 查询公共群组
 * @param lastUpdateTime       NSString		上次更新的时间戳ms（用于分页获取，最大支持1个月前的时间，超过以1个月时间为准）
 */
- (void) queryPublicGroupsWithLastUpdateTime:(NSString*) lastUpdateTime
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Group/GetPublicGroups?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    //NSLog(@"[CCPRestService] QueryGroup url=%@",requestUrl);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_Group_GetPublicGroups;

    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><lastUpdateTime>%@</lastUpdateTime></Request>",lastUpdateTime];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}


/**
 * 按条件搜索公共群组
 * @param groupId       NSString		群组ID        根据群组ID查找（同时具备两个条件，查询以此为先）
 * @param name          NSString		群组名字 可选   根据群组名字查找（模糊查询，结果集中不能有私有群组）
 */
- (void) queryPublicGroupsWithGroupId:(NSString*) groupId andName:(NSString*) name
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Group/GetPublicGroups?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    NSLog(@"[CCPRestService] QueryGroup url=%@",requestUrl);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_Group_GetPublicGroups;
    
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><groupId>%@</groupId></Request><name>%@</name>",groupId,name];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

/**
 * 查询群组
 * @param groupId       NSString		群组ID
 */
- (void) queryGroupDetailWithGroupId:(NSString*) groupId
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Group/QueryGroupDetail?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_Group_QueryGroup;
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:groupId, KEY_USERINFO_IMGROUPID, nil];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><groupId>%@</groupId></Request>",groupId];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}


/**
 *申请加入群组
 * @param groupId       NSString      群组ID
 * @param declared      NSString		申请理由
 */
- (void) joinGroupWithGroupId:(NSString*) groupId  andDeclared:(NSString*) declared
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Group/JoinGroup?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_Group_JoinGroup;
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:groupId, KEY_USERINFO_IMGROUPID, nil];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><groupId>%@</groupId><declared>%@</declared></Request>",groupId,declared];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}
/**
 *管理员邀请加入群组
 * @param groupId       NSString        群组ID
 * @param members       NSArray         被邀请的人员列表
 * @param declared      NSString		邀请理由
 * @param confirm       NSInteger       是否需要被邀请人确认 0:需要 1：不需要(自动加入群组)
 */
- (void) inviteJoinGroupWithGroupId:(NSString*) groupId andMembers:(NSArray*) members andDeclared:(NSString*) declared andConfirm:(NSInteger) confirm
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Group/InviteJoinGroup?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_Group_InviteJoinGroup;
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:groupId, KEY_USERINFO_IMGROUPID, nil];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSMutableString* strMembers = [[NSMutableString alloc] init];
    for (NSString* str in members) {
        [strMembers appendFormat:@"<member>%@</member>",str];
    }
    
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><groupId>%@</groupId><members>%@</members><declared>%@</declared><confirm>%d</confirm></Request>",groupId,strMembers,declared,confirm];
    [strMembers release];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

/**
 *群组管理员删除成员
 * @param groupId       NSString        群组ID
 * @param members       NSArray         被邀请的人员列表
 */
- (void) deleteGroupMemberWithGroupId:(NSString*) groupId andMembers:(NSArray*) members
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Group/DeleteGroupMember?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_Group_DeleteGroupMember;
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:groupId, KEY_USERINFO_IMGROUPID, nil];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSMutableString* strMembers = [[NSMutableString alloc] init];
    for (NSString* str in members) {
        [strMembers appendFormat:@"<member>%@</member>",str];
    }
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><groupId>%@</groupId><members>%@</members></Request>",groupId,strMembers];
    [strMembers release];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

/**
 *成员主动退出群组
 * @param groupid       NSString		群组ID
 * @param asker         NSString		退出者
 */
- (void) logoutGroupWithGroupId:(NSString*) groupId;
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Group/LogoutGroup?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_Group_LogoutGroup;
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:groupId, KEY_USERINFO_IMGROUPID, nil];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><groupId>%@</groupId></Request>",groupId];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}
#pragma mark - 多媒体IM群组名片

/**
 *修改群组名片信息
 * @param gruopCard       IMGruopCard         群组名片信息
 */
- (void) modifyGroupCard:(IMGruopCard *)gruopCard
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Member/ModifyCard?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_GrupCard_ModifyCard;
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    
    NSString *display = @"";
    NSString *voip = @"";
    NSString *tel = @"";
    NSString *mail = @"";
    NSString *remark = @"";
    
    if ([gruopCard.display length] > 0)
    {
        display = gruopCard.display;
    }
    
    if ([gruopCard.sid length] > 0)
    {
        voip = [NSString stringWithFormat:@"<voipAccount>%@</voipAccount>",gruopCard.sid];
    }
    
    if ([gruopCard.tel length] > 0)
    {
        tel = gruopCard.tel;
    }
    
    if ([gruopCard.mail length] > 0)
    {
        mail = gruopCard.mail;
    }
    
    if ([gruopCard.remark length] > 0)
    {
        remark = gruopCard.remark;
    }
    
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><display>%@</display><tel>%@</tel><mail>%@</mail><remark>%@</remark><belong>%@</belong>%@</Request>",display,tel,mail,remark,gruopCard.belong,voip];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

/**
 *查询群组名片信息
 * @param other   NSString         群组中成员的账号
 * @param belong  NSString         用户所属的群组ID
 */
- (void) queryGroupCardWithOther:(NSString*) other andBelong:(NSString*) belong
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Member/QueryCard?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_GrupCard_QueryCard;
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><other>%@</other><belong>%@</belong></Request>",other,belong];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

- (void)parse_queryCard:(Demo_GDataXMLElement*)rootElement  withData:(NSMutableDictionary*)userData
{
    Demo_GDataXMLElement *requestElement = (Demo_GDataXMLElement*)rootElement;
    IMGruopCard* imGroupCard = [[IMGruopCard alloc] init];
    NSArray *nameArray = [requestElement elementsForName:@"display"];
    if (nameArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[nameArray objectAtIndex:0];
        imGroupCard.display = valueElement.stringValue;
    }
    
    NSArray *typeArray = [requestElement elementsForName:@"tel"];
    if (typeArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[typeArray objectAtIndex:0];
        imGroupCard.tel = valueElement.stringValue;
    }
    
    NSArray *declaredArray = [requestElement elementsForName:@"mail"];
    if (declaredArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[declaredArray objectAtIndex:0];
        imGroupCard.mail = valueElement.stringValue;
    }
    
    NSArray *createdArray = [requestElement elementsForName:@"remark"];
    if (createdArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[createdArray objectAtIndex:0];
        imGroupCard.remark = valueElement.stringValue;
    }
    
    NSArray *countArray = [requestElement elementsForName:@"belong"];
    if (countArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[countArray objectAtIndex:0];
        imGroupCard.belong = valueElement.stringValue;
    }    
    [userData setObject:imGroupCard forKey:KEY_RESPONSE_USERDATA];
    [imGroupCard release];
}


#pragma mark - 多媒体IM群组成员管理

/**
 *查询成员
 * @param groupid      NSString         群组ID
 */
- (void) queryMemberWithGroupId:(NSString*) groupId
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Member/QueryMember?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_Member_QueryMember;
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:groupId, KEY_USERINFO_IMGROUPID, nil];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><groupId>%@</groupId></Request>",groupId];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

/**
 *查询成员加入的群组
 * @param asker        NSString         成员的Voip账号
 */
- (void) queryGroupWithAsker:(NSString*) asker
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Member/QueryGroup?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_Member_QueryGroup;
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:asker, KEY_USERINFO_IMMEMBERID, nil];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><asker>%@</asker></Request>",asker];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}
/**禁言
 *groupId	String	必选	群组ID
 *member	String	必选	成员的VoIP账号
 *operation	int	必选	0：可发言（默认）1：禁言 2：对组内所有成员禁言
 */
- (void)forbidSpeakWithGroupId:(NSString*) groupId andMember:(NSString*) member andOperation:(NSInteger) operation
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Member/ForbidSpeak?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_Member_ForbidSpeak;
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><groupId>%@</groupId><member>%@</member><operation>%d</operation></Request>",groupId,member,operation];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

/**
 *管理员验证用户申请加入群组
 * @param groupid      NSString         群组ID
 * @param asker        NSString         成员的Voip账号
 * @param confirm      NSInteger        0：通过 1：拒绝
 */
- (void) askJoinWithGroupId:(NSString*) groupId andAsker:(NSString*) asker andConfirm:(NSInteger) confirm
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Member/AskJoin?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_Member_AskJoin;
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:asker, KEY_USERINFO_IMMEMBERID, nil];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><groupId>%@</groupId><asker>%@</asker><confirm>%d</confirm></Request>",groupId, asker,confirm];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}
/**
 *用户验证邀请加入群组
 * @param groupid      NSString         群组ID
 * @param confirm      NSInteger        0：通过 1：拒绝
 */
- (void) inviteGroupWithGroupId:(NSString*) groupId andConfirm:(NSInteger) confirm
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Member/InviteGroup?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_Member_InviteGroup;
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><groupId>%@</groupId><confirm>%d</confirm></Request>",groupId,confirm];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

- (void)parseCreateGroup:(Demo_GDataXMLElement*)rootElement  withData:(NSMutableDictionary*)userData
{        
    {
        Demo_GDataXMLElement *requestElement = (Demo_GDataXMLElement*)rootElement;
        NSArray *groupIdArray = [requestElement elementsForName:@"groupId"];
        if (groupIdArray.count > 0)
        {
            Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[groupIdArray objectAtIndex:0];
            [userData setObject:valueElement.stringValue forKey:KEY_RESPONSE_USERDATA];
        }
    }
}

- (void)parse_QueryPublicGroups:(Demo_GDataXMLElement*)rootElement  withData:(NSMutableDictionary*)userData
{    
    NSArray *updateTimeArray = [rootElement elementsForName:@"updateTime"];
    if (updateTimeArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[updateTimeArray objectAtIndex:0];
        [userData setObject:valueElement.stringValue forKey:KEY_USERINFO_IMGetPublicGroups];
    }
    
    NSArray *groupsInfo = [rootElement elementsForName:@"groups"];
    if (groupsInfo.count > 0)
    {
        Demo_GDataXMLElement *requestElement = (Demo_GDataXMLElement*)[groupsInfo objectAtIndex :0];
        NSArray *groupsArray = [requestElement elementsForName:@"group"];
        if (groupsArray.count > 0)
        {
            NSMutableArray *publicGroupList = [[NSMutableArray alloc] init];
            for (Demo_GDataXMLElement *groupElement in groupsArray)
            {
                IMGroupInfo* imGroup = [[IMGroupInfo alloc] init];
                NSArray *groupIdArray = [groupElement elementsForName:@"groupId"];
                if (groupIdArray.count > 0)
                {
                    Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[groupIdArray objectAtIndex:0];
                    imGroup.groupId = valueElement.stringValue;
                }
                
                NSArray *nameArray = [groupElement elementsForName:@"name"];
                if (nameArray.count > 0)
                {
                    Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[nameArray objectAtIndex:0];
                    imGroup.name = valueElement.stringValue;
                }
                
                NSArray *typeArray = [groupElement elementsForName:@"type"];
                if (typeArray.count > 0)
                {
                    Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[typeArray objectAtIndex:0];
                    imGroup.type = valueElement.stringValue.integerValue;
                }
                
                NSArray *countArray = [groupElement elementsForName:@"count"];
                if (countArray.count > 0)
                {
                    Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[countArray objectAtIndex:0];
                    imGroup.count = valueElement.stringValue.integerValue;
                }
                
                NSArray *permissionArray = [groupElement elementsForName:@"permission"];
                if (permissionArray.count > 0)
                {
                    Demo_GDataXMLElement *permissionElement = (Demo_GDataXMLElement*)[permissionArray objectAtIndex:0];
                    imGroup.permission = permissionElement.stringValue.integerValue;
                }
                
                NSArray *updateTimeArray = [groupElement elementsForName:@"updateTime"];
                if (updateTimeArray.count > 0)
                {
                    Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[updateTimeArray objectAtIndex:0];
                    imGroup.created = valueElement.stringValue;
                }
                
                [publicGroupList addObject: imGroup];
                [imGroup release];
            }
            [userData setObject: publicGroupList forKey:KEY_RESPONSE_USERDATA];
            [publicGroupList release];
        }
    }
}

- (void)parse_SearchPublicGroups:(Demo_GDataXMLElement*)rootElement  withData:(NSMutableDictionary*)userData
{
    {
        Demo_GDataXMLElement *requestElement = (Demo_GDataXMLElement*)rootElement;
        NSArray *groupsInfo = [requestElement elementsForName:@"groups"];
        if (groupsInfo.count > 0)
        {
            Demo_GDataXMLElement *requestElement = (Demo_GDataXMLElement*)[groupsInfo objectAtIndex :0];
            NSArray *groupsArray = [requestElement elementsForName:@"group"];
            NSMutableArray *publicGroupList = [[NSMutableArray alloc] init];
            for (Demo_GDataXMLElement *groupElement in groupsArray)
            {
                IMGroupInfo* imGroup = [[IMGroupInfo alloc] init];
                NSArray *groupIdArray = [groupElement elementsForName:@"groupId"];
                if (groupIdArray.count > 0)
                {
                    Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[groupIdArray objectAtIndex:0];
                    imGroup.groupId = valueElement.stringValue;
                }
                
                NSArray *nameArray = [groupElement elementsForName:@"name"];
                if (nameArray.count > 0)
                {
                    Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[nameArray objectAtIndex:0];
                    imGroup.name = valueElement.stringValue;
                }
                
                NSArray *typeArray = [groupElement elementsForName:@"type"];
                if (typeArray.count > 0)
                {
                    Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[typeArray objectAtIndex:0];
                    imGroup.type = valueElement.stringValue.integerValue;
                }
                
                NSArray *countArray = [groupElement elementsForName:@"count"];
                if (countArray.count > 0)
                {
                    Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[countArray objectAtIndex:0];
                    imGroup.count = valueElement.stringValue.integerValue;
                }
                
                NSArray *permissionArray = [groupElement elementsForName:@"permission"];
                if (permissionArray.count > 0)
                {
                    Demo_GDataXMLElement *permissionElement = (Demo_GDataXMLElement*)[permissionArray objectAtIndex:0];
                    imGroup.permission = permissionElement.stringValue.integerValue;
                }                
                [publicGroupList addObject: imGroup];
                [imGroup release];
            }
            [userData setObject: publicGroupList forKey:KEY_RESPONSE_USERDATA];
            [publicGroupList release];
        }
    }
}

- (void)parse_QueryGroupDetail:(Demo_GDataXMLElement*)rootElement  withData:(NSMutableDictionary*)userData
{
    Demo_GDataXMLElement *requestElement = (Demo_GDataXMLElement*)rootElement;
    IMGroupInfo* imGroup = [[IMGroupInfo alloc] init];
    NSArray *nameArray = [requestElement elementsForName:@"name"];
    if (nameArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[nameArray objectAtIndex:0];
        imGroup.name = valueElement.stringValue;
        NSString* groupid = [userData objectForKey : KEY_USERINFO_IMGROUPID];
        imGroup.groupId = groupid;
    }
    
    NSArray *typeArray = [requestElement elementsForName:@"owner"];
    if (typeArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[typeArray objectAtIndex:0];
        imGroup.owner = valueElement.stringValue;
    }
    
    NSArray *declaredArray = [requestElement elementsForName:@"declared"];
    if (declaredArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[declaredArray objectAtIndex:0];
        imGroup.declared = valueElement.stringValue;
    }
    
    NSArray *createdArray = [requestElement elementsForName:@"created"];
    if (createdArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[createdArray objectAtIndex:0];
        imGroup.created = valueElement.stringValue;
    }
    
    NSArray *countArray = [requestElement elementsForName:@"count"];
    if (countArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[countArray objectAtIndex:0];
        imGroup.count = valueElement.stringValue.integerValue;
    }
    
    NSArray *permissionArray = [requestElement elementsForName:@"permission"];
    if (permissionArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[permissionArray objectAtIndex:0];
        imGroup.permission = valueElement.stringValue.integerValue;
    }
    
    [userData setObject:imGroup forKey:KEY_RESPONSE_USERDATA];
    [imGroup release];
}

- (void)parseMember_QueryMember:(Demo_GDataXMLElement*)rootElement  withData:(NSMutableDictionary*)userData
{
    Demo_GDataXMLElement *requestElement = (Demo_GDataXMLElement*)rootElement;
    NSArray *membersArray = [requestElement elementsForName:@"members"];
    if (membersArray.count > 0)
    {
        Demo_GDataXMLElement *membersInfoElement = (Demo_GDataXMLElement*)[membersArray objectAtIndex :0];
        NSArray *membersInfoArray = [membersInfoElement elementsForName:@"member"];
        if([membersInfoArray count]>0)
        {
            NSMutableArray *membersArray = [[NSMutableArray alloc] init];
            for (Demo_GDataXMLElement *memberElement in membersInfoArray)
            {
                NSArray *voipArray = [memberElement elementsForName:@"voipAccount"];
                if([voipArray count]>0)
                {
                    NSMutableString *strMember = [[NSMutableString alloc] init];
                    
                    Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[voipArray objectAtIndex:0];
                    NSString* strVoip = valueElement.stringValue;
                    [strMember appendString:strVoip];
                    
                    NSArray *displayArray = [memberElement elementsForName:@"display"];
                    if([displayArray count]>0)
                    {
                        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[displayArray objectAtIndex:0];
                        NSString* display = valueElement.stringValue;
                        [strMember appendFormat:@"|&|%@", display];
                    }
                    
                    NSArray *isBanArray = [memberElement elementsForName:@"isBan"];
                    if([isBanArray count]>0)
                    {
                        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[isBanArray objectAtIndex:0];
                        NSString* isBan = valueElement.stringValue;
                        [strMember appendFormat:@";&;%@", isBan];
                    }
                    
                    [membersArray addObject:strMember];
                    [strMember release];
                }
            }
            [userData setObject: membersArray forKey:KEY_RESPONSE_USERDATA];
            [membersArray release];
        }
    }
}

- (void)parseMember_QueryGroup:(Demo_GDataXMLElement*)rootElement  withData:(NSMutableDictionary*)userData
{
    NSArray *groupsArray = [rootElement elementsForName:@"groups"];
    if (groupsArray.count)
    {
        Demo_GDataXMLElement *requestElement = (Demo_GDataXMLElement*)[groupsArray objectAtIndex :0];
        NSArray *groupArr = [requestElement elementsForName:@"group"];
        if (groupArr.count > 0)
        {
            NSMutableArray *groupsInfoArray = [[NSMutableArray alloc] init];
            for (Demo_GDataXMLElement *groupElement in groupArr)
            {
                IMGroupInfo* imGroup = [[IMGroupInfo alloc] init];
                NSArray *groupIdArray = [groupElement elementsForName:@"groupId"];
                if (groupIdArray.count > 0)
                {
                    Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[groupIdArray objectAtIndex:0];
                    imGroup.groupId  = valueElement.stringValue;
                }
                
                NSArray *nameArray = [groupElement elementsForName:@"name"];
                if (nameArray.count > 0)
                {
                    Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[nameArray objectAtIndex:0];
                    imGroup.name = valueElement.stringValue;
                }
                
                NSArray *typeArray = [groupElement elementsForName:@"type"];
                if (typeArray.count > 0)
                {
                    Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[typeArray objectAtIndex:0];
                    imGroup.type = valueElement.stringValue.integerValue;
                }
                
                NSArray *countArray = [groupElement elementsForName:@"count"];
                if (countArray.count > 0)
                {
                    Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement*)[countArray objectAtIndex:0];
                    imGroup.count = valueElement.stringValue.integerValue;
                }
                
                NSArray *permissionArray = [groupElement elementsForName:@"permission"];
                if (permissionArray.count > 0)
                {
                    Demo_GDataXMLElement *permissionElement = (Demo_GDataXMLElement*)[permissionArray objectAtIndex:0];
                    imGroup.permission = permissionElement.stringValue.integerValue;
                }
                [groupsInfoArray addObject: imGroup];
                [imGroup release];
            }
            [userData setObject: groupsInfoArray forKey:KEY_RESPONSE_USERDATA];
            [groupsInfoArray release];
        }
    }
}

- (void)onConfirmInstanceMessageWithReason:(CloopenReason *)reason
{
    NSLog(@"[onConfirmInstanceMessageWithReason] reason=%d",reason.reason);
}

-(void)onReceiveEvents:(CCPEvents)events
{
    if (events == SYSCallComing)
    {
        NSLog(@"系统通话事件");
    }
    else if(events == BatteryLower)
    {
        NSLog(@"电量低于10%%");
    }
}

-(NSString*)getLIBVersion
{
    return [self.VoipCallService getLIBVersion];
}

/**
 * 返回SDK版本信息
 * @ret  返回版本信息
 */
- (NSString*)getSDKDate
{
    return [self.VoipCallService getSDKDate];
}

- (NSString*)getSDKVersion
{
    return [self.VoipCallService getSDKVersion];
}

-(StatisticsInfo*)getCallStatistics
{
    return [self.VoipCallService getCallStatistics];
}

-(void)deleteFileWithPathArr:(NSArray*) pathArr
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString* strPath in pathArr)
    {
        BOOL success = [fileManager fileExistsAtPath:strPath];
        NSError *delError;
        if (success)
        {
            success = [fileManager removeItemAtPath:strPath error:&delError];
            if (!success)
            {
                NSLog(@"Failed to create writable database file with message '%@'.", [delError localizedDescription]);
            }
        }
    }
}


#pragma mark - 专家咨询
//获取咨询类别列表
- (void)getCategoryList{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Consult/GetCategoryList?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_GetCategoryList;
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

//获取咨询专家列表
- (void)getExpertListOfCategoryId:(NSString*)categoryId{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Consult/GetExpertList?sig=%@&categoryId=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp],categoryId];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_GetExpertList;
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

//获取特服号
- (void)getServiceNum{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Consult/GetServiceNum?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_GetServiceNum;
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

//锁定专家
- (void)lockExpertId:(NSString*)expertId andSrcPhone:(NSString*)srcPhone{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/SubAccounts/%@/Consult/LockExpert?sig=%@",defHttps,self.serverIP,self.serverPort,kServerVersion,self.subAccountSid,[self getSig:timestamp]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.requestType = ERequestType_LockExpert;
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody = xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><LockExpert><expertId>%@</expertId><srcPhone>%@</srcPhone></LockExpert>",expertId, srcPhone];
    [request appendPostData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

- (void)parseGetCategoryList:(Demo_GDataXMLElement*)rootElement  withData:(NSMutableDictionary*)userData
{
    Demo_GDataXMLElement *requestElement = (Demo_GDataXMLElement*)rootElement;
    NSArray *categorys = [requestElement elementsForName:@"category"];
    if (categorys.count > 0)
    {
        NSInteger index = 0;
        NSMutableArray *categoryArr = [[NSMutableArray alloc] init];
        for (Demo_GDataXMLElement *categoryElement in categorys)
        {
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
            
            NSArray *idArray = [categoryElement elementsForName:@"id"];
            if(idArray.count > 0)
            {
                Demo_GDataXMLElement *idElement = (Demo_GDataXMLElement *)[idArray objectAtIndex:0];
                NSString *counselorid = idElement.stringValue;
                [dict setObject:counselorid forKey:@"id"];
            }
            
            NSArray *nameArray = [categoryElement elementsForName:@"name"];
            if(nameArray.count > 0)
            {
                Demo_GDataXMLElement *nameElement = (Demo_GDataXMLElement *)[nameArray objectAtIndex:0];
                NSString *name = nameElement.stringValue;
                [dict setObject:name forKey:@"name"];
            }
            
            NSArray *detailArray = [categoryElement elementsForName:@"detail"];
            if (detailArray.count > 0)
            {
                Demo_GDataXMLElement *detailElement = (Demo_GDataXMLElement*)[detailArray objectAtIndex:0];
                NSString *detail = detailElement.stringValue;
                [dict setObject:detail forKey:@"detail"];
            }
            
            NSArray *posArray = [categoryElement elementsForName:@"position"];
            if (posArray.count > 0)
            {
                Demo_GDataXMLElement *posElement = (Demo_GDataXMLElement*)[posArray objectAtIndex:0];
                NSString *pos = posElement.stringValue;
                [dict setObject:pos forKey:@"position"];
            }
            
            [dict setObject:[NSString stringWithFormat:@"clinic_%0.2d_icon.png",index%18+1] forKey:@"imgPath"];
            [categoryArr addObject:dict];
            [dict release];
            index++;
        }
        
        [userData setObject:categoryArr forKey:KEY_RESPONSE_USERDATA];
        [categoryArr release];
    }
}

- (void)parseGetExpertList:(Demo_GDataXMLElement*)rootElement  withData:(NSMutableDictionary*)userData{
    Demo_GDataXMLElement *requestElement = (Demo_GDataXMLElement*)rootElement;
    NSArray* experts = [requestElement elementsForName:@"expert"];
    if (experts.count > 0)
    {
        NSMutableArray *expertArray = [[NSMutableArray alloc] init];
        for (Demo_GDataXMLElement *expertElement in experts)
        {
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
            
            NSArray* idArray = [expertElement elementsForName:@"id"];
            if (idArray.count > 0)
            {
                Demo_GDataXMLElement *idElement = (Demo_GDataXMLElement*)[idArray objectAtIndex:0];
                NSString *idString = idElement.stringValue;
                [dict setObject:idString forKey:@"id"];
            }
            
            NSArray *nameArray = [expertElement elementsForName:@"name"];
            if (nameArray.count > 0)
            {
                Demo_GDataXMLElement *nameElement = (Demo_GDataXMLElement*)[nameArray objectAtIndex:0];
                NSString* name = nameElement.stringValue;
                [dict setObject:name forKey:@"name"];
            }
            
            NSArray *detailArray = [expertElement elementsForName:@"detail"];
            if (detailArray.count > 0)
            {
                Demo_GDataXMLElement *detailElement = (Demo_GDataXMLElement*)[detailArray objectAtIndex:0];
                NSString *detail = detailElement.stringValue;
                [dict setObject:detail forKey:@"detail"];
            }
            
            NSArray *personinfoArray = [expertElement elementsForName:@"personInfo"];
            if (personinfoArray.count > 0)
            {
                Demo_GDataXMLElement *personinfoElement = (Demo_GDataXMLElement*)[personinfoArray objectAtIndex:0];
                NSString *personinfo = personinfoElement.stringValue;
                [dict setObject:personinfo forKey:@"personInfo"];
            }
            
            NSArray *gradeArray = [expertElement elementsForName:@"grade"];
            if (gradeArray.count > 0)
            {
                Demo_GDataXMLElement *gradeElement = (Demo_GDataXMLElement*)[gradeArray objectAtIndex:0];
                NSString *grade = gradeElement.stringValue;
                [dict setObject:grade forKey:@"grade"];
            }
            
            [expertArray addObject:dict];
            [dict release];
        }
        [userData setObject:expertArray forKey:KEY_RESPONSE_USERDATA];
        [expertArray release];
    }
}

- (void)parseGetServiceNum:(Demo_GDataXMLElement*)rootElement{
    NSArray * ServiceNumlist = [rootElement elementsForName:@"ServiceNum"];
    if (ServiceNumlist.count>0)
    {
        Demo_GDataXMLElement *ServiceNumlistElement = (Demo_GDataXMLElement*)[ServiceNumlist objectAtIndex:0];
        NSArray * ivrphoneList = [ServiceNumlistElement elementsForName:@"ivrPhone"];
        if (ivrphoneList.count>0)
        {
            Demo_GDataXMLElement *ivrphoneElement = (Demo_GDataXMLElement *)[ivrphoneList objectAtIndex:0];
            self.ivrPhone = ivrphoneElement.stringValue;
        }
        NSArray * voipphoneList = [ServiceNumlistElement elementsForName:@"voipPhone"];
        if (voipphoneList.count>0)
        {
            Demo_GDataXMLElement *voipphoneElement = (Demo_GDataXMLElement *)[voipphoneList objectAtIndex:0];
            self.myVoipPhone = voipphoneElement.stringValue;
        }
    }
}

- (void)onFirewallPolicyEnabled
{
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onFirewallPolicyEnabled)])
    {
        [self.UIDelegate onFirewallPolicyEnabled];
    }
}

//是否抑制马赛克
-(NSInteger) setShieldMosaic:(BOOL) flag
{
    return [self.VoipCallService setShieldMosaic:flag];
}


/**
 * 创建视频会议
 * @param appId 应用id
 * @param conferenceName 会议名称
 * @param square 参与的最大方数
 * @param keywords 业务属性，有应用定义
 * @param conferencePwd 房间密码，可为null
 */
- (void) startVideoConferenceInAppId:(NSString*)appId withName:(NSString *)conferenceName andSquare:(NSInteger)square andKeywords:(NSString *)keywords andPassword:(NSString *)conferencePwd andIsAutoClose:(BOOL)isAutoClose andVoiceMod:(NSInteger) voiceMod andAutoDelete:(BOOL) autoDelete andIsAutoJoin:(BOOL) isAutoJoin;
{
    [self.VoipCallService startVideoConferenceInAppId:appId withName:conferenceName andSquare:square andKeywords:keywords andPassword:conferencePwd andIsAutoClose:isAutoClose andVoiceMod:voiceMod andAutoDelete:autoDelete andIsAutoJoin:isAutoJoin];
}

/**
 * 加入视频会议
 * @param conferenceId 会议号
 */
- (void) joinInVideoConference:(NSString *)conferenceId
{
    [self.VoipCallService joinInVideoConference:conferenceId];
}

/**
 * 退出当前视频会议
 * @return false:失败 true:成功
 */
- (BOOL) exitVideoConference
{
    return [self.VoipCallService exitVideoConference];
}

/**
 * 查询视频会议成员
 * @param conferenceId 会议号
 */
- (void) queryMembersInVideoConference:(NSString *)conferenceId
{
    [self.VoipCallService queryMembersInVideoConference:conferenceId];
}

/**
 * 查询视频会议列表
 * @param appId 应用id
 * @param keywords 业务属性
 */
- (void)queryVideoConferencesOfAppId:(NSString *)appId withKeywords:(NSString *)keywords
{
    [self.VoipCallService queryVideoConferencesOfAppId:appId withKeywords:keywords];
}

/**
 * 解散视频会议
 * @param appId 应用id
 * @param conferenceId 会议号
 */
- (void) dismissVideoConferenceWithAppId:(NSString*) appId andVideoConference:(NSString*) conferenceId
{
    [self.VoipCallService dismissVideoConferenceWithAppId:appId andVideoConference:conferenceId];
}

/**
 * 踢出视频会议成员
 * @param appId 应用id
 * @param conferenceId 会议号
 * @param member 成员号码
 */
- (void) removeMemberFromVideoConferenceWithAppId:(NSString*) appId andVideoConference:(NSString*)conferenceId andMember:(NSString*) member
{
    [self.VoipCallService removeMemberFromVideoConferenceWithAppId:appId andVideoConference:conferenceId andMember:member];
}

/**
 * 切换实时视频显示
 * @param voip 实时图像的voip
 * @param conferenceId 会议号
 * @param appId 应用id
 */
- (void) switchRealScreenToVoip:(NSString*)voip ofVideoConference:(NSString*)conferenceId inAppId:(NSString*)appId
{
    [self.VoipCallService switchRealScreenToVoip:voip ofVideoConference:conferenceId inAppId:appId];
}

/**
 * 上传自己的头像数据
 * @param filename 头像数据
 * @param conferenceId 会议号
 */
- (void) sendLocalPortrait:(NSString*)filename toVideoConference:(NSString*)conferenceId
{
    NSLog(@"sendLocalPortrait path=%@",filename);
    isSendingPortrait = YES;
    [self.VoipCallService sendLocalPortrait:filename toVideoConference:conferenceId];
}

/**
 * 下载视频会议头像列表
 * @param conferenceId 会议号
 */
- (void) getPortraitsFromVideoConference:(NSString*)conferenceId
{
    [self.VoipCallService getPortraitsFromVideoConference:conferenceId];
}

- (NSString*)getCurrentCall
{
    return [self.VoipCallService getCurrentCall];
}
/**
 * 下载头像数据
 * @param portraitsList 下载的头像信息
 */
- (void)downloadVideoConferencePortraits:(NSArray*)portraitsList
{
    [self.VoipCallService downloadVideoConferencePortraits:portraitsList];
}
-(void)onDownloadVideoConferencePortraitsWithReason:(CloopenReason *)reason andPortrait:(VideoPartnerPortrait*)portrait
{
    if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onDownloadVideoConferencePortraitsWithReason:andPortrait:)])
    {
        [self.UIDelegate onDownloadVideoConferencePortraitsWithReason:reason andPortrait:portrait];
    }
    [self displayErrorAlert:reason];
}

- (void) getDemoAccountsWithUserName:(NSString*) userName andUserPwd:(NSString*)userPwd
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@:%d/%@/General/GetDemoAccounts", defHttps, self.serverIP,self.serverPort,kServerVersion];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestUrl]];
 //   request.requestType = ERequestType_GetDemoAccounts;
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/xml"];
    [request addRequestHeader:@"Content-Type" value:@"application/xml;charset=utf-8"];
    [request addRequestHeader:@"Authorization" value:[self getAuthorization:timestamp]];
    NSString *xmlBody = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF8'?><Request><user_name>%@</user_name><user_pwd>%@</user_pwd></Request>",userName,userPwd];
    NSString *crpyStr = __BASE64(xmlBody);
    [request appendPostData:[crpyStr dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startAsynchronous];
}

- (void)parseGetDemoAccounts:(Demo_GDataXMLElement*)rootElement withData:(NSMutableDictionary*)userData
{
    NSMutableDictionary* AccountInfo = [[NSMutableDictionary alloc] init];
    NSArray *main_accountArray = [rootElement elementsForName:@"main_account"];
    if (main_accountArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement *)[main_accountArray objectAtIndex:0];
        [AccountInfo setObject: valueElement.stringValue forKey:@"main_account"];
    }
    
    NSArray *main_tokenArray = [rootElement elementsForName:@"main_token"];
    if (main_tokenArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement *)[main_tokenArray objectAtIndex:0];
        [AccountInfo setObject: valueElement.stringValue forKey:@"main_token"];
    }
    
    NSArray *nickArray = [rootElement elementsForName:@"nickname"];
    if (nickArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement *)[nickArray objectAtIndex:0];
        [AccountInfo setObject: valueElement.stringValue forKey:@"nick_name"];
    }
    
    NSArray *mobileArray = [rootElement elementsForName:@"mobile"];
    if (mobileArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement *)[mobileArray objectAtIndex:0];
        [AccountInfo setObject: valueElement.stringValue forKey:@"mobile"];
    }
    
    NSArray *testnumberArray = [rootElement elementsForName:@"test_number"];
    if (testnumberArray.count > 0)
    {
        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement *)[testnumberArray objectAtIndex:0];
        [AccountInfo setObject: valueElement.stringValue forKey:@"test_number"];
    }
    
    NSArray *ApplicationsArray = [rootElement elementsForName:@"Application"];
    if (ApplicationsArray.count > 0)
    {
        NSMutableArray *applicationInfoArray = [[NSMutableArray alloc] init];
        
        for (Demo_GDataXMLElement *applicationElement in ApplicationsArray)
        {
            NSMutableDictionary* ApplicationDict = [[NSMutableDictionary alloc] init];
            NSArray *appIdArray = [applicationElement elementsForName:@"appId"];
            if (appIdArray.count > 0)
            {
                Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement *)[appIdArray objectAtIndex:0];
                [ApplicationDict setObject: valueElement.stringValue forKey:@"appId"];
            }
            NSArray *appNameArray = [applicationElement elementsForName:@"friendlyName"];
            if (appNameArray.count > 0)
            {
                Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement *)[appNameArray objectAtIndex:0];
                [ApplicationDict setObject: valueElement.stringValue forKey:@"appName"];
            }
            NSArray *SubAccountArray = [applicationElement elementsForName:@"SubAccount"];
            if (SubAccountArray.count > 0)
            {
                NSMutableArray *subAccountArray = [[NSMutableArray alloc] init];
                for (Demo_GDataXMLElement *sub_accountInfoElement in SubAccountArray)
                {
                    NSMutableDictionary* sub_accountDict = [[NSMutableDictionary alloc] init];
                    NSArray *sub_accountArray = [sub_accountInfoElement elementsForName:@"sub_account"];
                    if (sub_accountArray.count > 0)
                    {
                        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement *)[sub_accountArray objectAtIndex:0];
                        [sub_accountDict setObject: valueElement.stringValue forKey:@"sub_account"];
                    }
                    
                    NSArray *sub_tokenArray = [sub_accountInfoElement elementsForName:@"sub_token"];
                    if (sub_tokenArray.count > 0)
                    {
                        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement *)[sub_tokenArray objectAtIndex:0];
                        [sub_accountDict setObject: valueElement.stringValue forKey:@"sub_token"];
                    }
                    
                    NSArray *voipAccountArray = [sub_accountInfoElement elementsForName:@"voip_account"];
                    if (voipAccountArray.count > 0)
                    {
                        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement *)[voipAccountArray objectAtIndex:0];
                        [sub_accountDict setObject: valueElement.stringValue forKey:@"voip_account"];
                    }
                    
                    NSArray *voip_tokenArray = [sub_accountInfoElement elementsForName:@"voip_token"];
                    if (voip_tokenArray.count > 0)
                    {
                        Demo_GDataXMLElement *valueElement = (Demo_GDataXMLElement *)[voip_tokenArray objectAtIndex:0];
                        [sub_accountDict setObject: valueElement.stringValue forKey:@"voip_token"];
                    }
                    
                    [subAccountArray addObject:sub_accountDict];
                    [sub_accountDict release];
                }
                [ApplicationDict setObject: subAccountArray forKey:@"SubAccounts"];
                [subAccountArray release];
            }
            [applicationInfoArray addObject:ApplicationDict];
            [ApplicationDict release];
        }
        [AccountInfo setObject:applicationInfoArray forKey:@"Applications"];
        [applicationInfoArray release];
    }
    [userData setObject:AccountInfo forKey:KEY_RESPONSE_USERDATA];
    [AccountInfo release];
}
/**
 * 视频通话或者视频会议获取本地端帧数据
 */
- (void) getLocalPortrait
{
    NSLog(@"getLocalPortrait isSendingPortrait=%@", isSendingPortrait?@"YES":@"NO");
    if (!isSendingPortrait)//发送完上一张图片才获取新图片
    {
        //时间＋６位数字
        static int seedNum = 0;
        //保证是6位数字
        if(seedNum >= 1000000)
            seedNum = 0;
        seedNum++;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        
        NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter release];
        
        NSString *digid = [NSString stringWithFormat:@"%@%06d", currentDateStr, seedNum];
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        UIImage * image =[self.VoipCallService getLocalVideoSnapshotWithCallid:[self.VoipCallService getCurrentCall]];
        if (image)
        {
            NSString  *jpgPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", digid]];
            [UIImageJPEGRepresentation(image,0.6) writeToFile:jpgPath atomically:YES];
            if (self.UIDelegate && [self.UIDelegate respondsToSelector:@selector(onGetLocalPortrait:)])
            {
                [self.UIDelegate onGetLocalPortrait:jpgPath];
            }
        }
        [pool release];
    }
}

//视频通话或者视频会议获取远端帧数据
- (NSInteger)getRemoteVideoSnapshotWithCallid:(NSString*)callid;
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSInteger ret = -1;
    UIImage * image = [self.VoipCallService getRemoteVideoSnapshotWithCallid:callid];
    if (image)
    {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        ret = 0;
    }
    [pool release];
    return ret;
}

- (void) editTestNumWithOldPhoneNumber:(NSString*) oldPhoneNumber andNewPhoneNumber:(NSString*) newPhoneNumber
{
    [self.VoipCallService editTestNumWithOldPhoneNumber:oldPhoneNumber andNewPhoneNumber:newPhoneNumber andServerIP:self.serverIP andServerPort:self.serverPort andServerVersion:kServerVersion andMainAccount:self.mainAccount andMainToken:self.mainToken];
}

- (void) displayErrorAlert:(CloopenReason *)reason
{
    if (reason.reason != 0)
    {
        NSString *msg = [NSString stringWithFormat:@"错误码:%d\r\n错误详情:%@", reason.reason, reason.msg.length>0?reason.msg:@"未知"];
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                       message:msg
                                                      delegate:nil
                                             cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [view show];;
        [view release];
    }
}




- (NSArray *)filterArrayWithArray:(NSArray *)source FilterCondition:(NSArray *)filter{
    return[self.addressBookContactList filterArrayWithArray:source FilterCondition:filter];
}

- (NSMutableDictionary *)filterDictionaryWithArray:(NSMutableDictionary *)source
                                   FilterCondition:(NSArray *)filter
{
    return[self.addressBookContactList filterDictionaryWithArray:source FilterCondition:filter];
}
//联系人操作和查询操作
//根据输入搜索联系人，返回AddressBookContactSearchResult数组
- (NSArray *)search:(NSString *)searchItem keyboard:(int)keyboard otherPhoneNO:(BOOL)isSearch
{
    return [self.addressBookContactList search:searchItem keyboard:keyboard otherPhoneNO:isSearch];
}

- (NSArray *)contactsSearch:(NSString *)searchItem keyboard:(int)keyboard
{
    return [self.addressBookContactList search:searchItem keyboard:keyboard otherPhoneNO:NO];
}

- (NSArray *)search:(NSString *)searchItem keyboard:(int)keyboard Range:(NSDictionary *)range {
    return [self.addressBookContactList search:searchItem keyboard:keyboard Range:range];
}

- (AddressBookContactSearchResult *)getContactByID:(ABRecordID) recordID
{
    return [self.addressBookContactList getContactByID:recordID];
}

//列出目前通讯录里的所有联系人
//只返回包括用户名、第一个联系电话等简单的信息，为AddressBookContactSearchResult数组
- (NSMutableDictionary *)listAllContactsReset:(BOOL)reset listAll:(BOOL)list
{
    self.contactAllDic = self.addressBookContactList.allContactDictionary;
    
    if(reset){
        for (NSString* key in [self.contactAllDic allKeys]) {
            NSArray* contactOfKey = [self.contactAllDic objectForKey:key];
            for (GetSearchDataObj* contact in contactOfKey) {
                contact.checked = NO;
            }
        }
    }
    return self.contactAllDic;
}
-(NSMutableDictionary *)listAllContacts{
    return [self.addressBookContactList listAllContacts];
}


- (NSString *)getContactNameByID:(NSInteger)contactid
{
    ContactWithName* contactwithName = [self.addressBookContactList.contactWithName objectForKey:[NSNumber numberWithInteger:contactid]];
    return (contactwithName.name.length>0?contactwithName.name:nil);
}

//对联系人的增删改
- (BOOL)addContact:(AddressBookContactSearchResult *) theContact
{
    return [self.addressBookContactList addContact:theContact];
}

- (BOOL)updateContact:(AddressBookContactSearchResult *) theContact
{
    return [self.addressBookContactList updateContact:theContact];
}

- (BOOL)deleteContactSingle:(int) contactID
{
    return [self.addressBookContactList deleteContactSingle:contactID];
}

- (BOOL)delContacts:(NSArray *) contactIDArr
{
    return [self.addressBookContactList delContacts:contactIDArr];
}

//对联系人图片的操作
- (BOOL)hasPortrait:(int) contactID
{
    return [self.addressBookContactList hasPortrait:contactID];
}

- (BOOL)setPortrait:(int) contactID image:(NSData *)image
{
    return [self.addressBookContactList setImage:contactID image:image];
}

- (BOOL)removePortrait:(int) contactID
{
    return [self.addressBookContactList removeImage:contactID];
}

- (void)resetPortraitDic:(int)contactID{
    NSNumber *strID = [NSNumber numberWithInt:contactID];
    UIImage *portraitImage = [portraitDic objectForKey:strID];
    if (portraitImage) {
        [portraitDic removeObjectForKey:strID];
    }
}


- (UIImage *)getPortrait:(int) contactID
{
    NSNumber *strID = [NSNumber numberWithInt:contactID];
    UIImage *portraitImage = [portraitDic objectForKey:strID];  //缓存图片
    
    if (!portraitImage) //如果不存在缓存图片，则去获取
    {
        if ([self hasPortrait:contactID])  //是否存在“我”为联系人设置的头像，如果存在，则用“我”设置的
        {
            portraitImage = [self.addressBookContactList getImage:contactID];
            [portraitDic setObject:portraitImage forKey:strID];
        }
        else
        {
            return self.defaultContactIcon;
        }
    }
    return portraitImage;
}

//获得全部联系人数量
- (signed long) getContactCount
{
    return [self.addressBookContactList getContactCount];
}

//其他相关的组操作
- (BOOL)addGroup:(NSString *)groupName
{
    return [self.addressBookContactList addANewGroup:groupName];
}

- (BOOL)renameGroup:(int)groupID newName:(NSString *)newName {
    if ([newName length]>0) {
        return [self.addressBookContactList renameGroup:groupID newName:newName];
    }
    return false;
}

- (BOOL)delGroup:(int)groupID
{
    return [self.addressBookContactList delTheGroup:groupID];
}

//列出所有分组
- (NSArray *)listAllGroups
{
    return [self.addressBookContactList listAllGroups];
}

- (BOOL)removeContactFromGroup:(int)conatctID group:(int)groupID
{
    return [self.addressBookContactList removeContactFromGroup:conatctID group:groupID];
}

- (NSMutableDictionary *)getGroupContacts:(int)groupID
{
    return [self.addressBookContactList getGroupContacts:groupID];
}

- (BOOL)moveContactFromOneToAnother:(int)contactID one:(int)groupID another:(int)anotherGroupID {
    return [self.addressBookContactList moveContactFromOneToAnother:contactID one:groupID another:anotherGroupID];
}

- (BOOL)addAllRecords:(NSArray *)groupArr {
    GroupDBAccess * groupDBAccess = [[GroupDBAccess alloc] init];
    BOOL flag = [groupDBAccess addAllRecords:groupArr];
    [groupDBAccess release];
    return flag;
}

- (BOOL)setContactsGroups:(int)contactID add:(NSMutableArray*)checkGroupIDList delGroups:(NSMutableArray*)delGroups {
    return [self.addressBookContactList setContactsGroups:contactID add:checkGroupIDList delGroups:delGroups];
}

- (NSString *)getFirstNotNullPhoOrEmailForUI:(int)recordID {
    return [self.addressBookContactList getFirstNotNullPhoOrEmailForUI:recordID];
}

- (void)onLogInfo:(NSString *)loginfo
{
    NSLog(@"%@",loginfo);
}

@end
