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

#import "UIBaseViewController.h"
#import "HPGrowingTextView.h"
#import "MWPhotoBrowser.h"

typedef enum
{
    ERecordState_Origin,
    ERecordState_Start,
    ERecordState_Recording
} ERecordState;

@interface SendIMViewController : UIBaseViewController<UITableViewDataSource, UITableViewDelegate, HPGrowingTextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MWPhotoBrowserDelegate,UIAlertViewDelegate>
{
    BOOL isSavedToAlbum;
    //voice使用
    int sendType;//发送类型，首次创建会话还是以前的会话
    BOOL isPlaying;
    BOOL isRecording;
    BOOL isOutside;
    int  recordState;
    UIButton *voiceBtn;
    //voice end
}
//voice使用
@property (nonatomic, retain) NSString* curVoiceSid;
@property (nonatomic, retain) UIImageView * curImg;
@property (nonatomic, retain) NSString* groupID;
@property (nonatomic, retain) NSString* curRecordFile;//当前录音文件名
@property (nonatomic, retain) UIView* popView;
@property (nonatomic, retain) UIImageView* ivPopImg;
@property (nonatomic, retain) NSArray* imgArray;
@property (nonatomic, retain) NSTimer* recordTimer;
//voice end
@property (assign, nonatomic) UIViewController     *backView;
@property (retain, nonatomic) MWPhoto             *displayPhoto;
- (id)initWithReceiver:(NSString*)receiver;

//voice使用
//调用底层的停止录音
-(void)stop;
//根据一定规则生成文件不重复的文件名
- (NSString *)createFileName;
//停止放音
-(void)stopRecMsg;
//播放当前点击的语音
-(void)playVoiceMsg:(id)sender;
//根据传入的文件名播放语音
-(void)playRecMsg:(NSString*) fileName;
//停止动画效果
-(void)stopAnimation;
//voice end
@end
