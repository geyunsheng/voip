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
#import <UIKit/UIKit.h>

@protocol VideoViewDelegate <NSObject>

@optional
-(void)onChooseIndex:(NSInteger)index andVoipAccount:(NSString*) voip;

@end

@interface VideoView : UIView
{
   
}
@property (nonatomic,assign)id<VideoViewDelegate> myDelegate;
@property (nonatomic,retain) NSString* strVoip;
@property (nonatomic,retain) NSString* imagePath;
@property (nonatomic,retain)UIImageView* icon;
@property (nonatomic,retain)UIImageView* ivChoose;
@property (nonatomic,retain)UIView* footView;
@property (nonatomic,retain)UILabel* voipLabel;
@property (nonatomic,retain)UILabel* videoLabel;
@property (nonatomic,retain)UIView* bgView;
- (void)setBgViewImagePath:(NSString*)imagePath;
@end
