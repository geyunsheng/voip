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
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>

#define MakeRgbColor(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]


typedef enum
{
    EImageJPG = 0,
    EImageGIF,
    EImageBMP,
    EImagePNG,
    EImageInvalidType
}EImageType;


#define __BASE64( text )  [CommonTools encodedData:text]
#define __TEXT(base64Str) [CommonTools decodeData:base64Str]
@interface CommonTools : NSObject
+ (UIButton*) navigationBackItemBtnInitWithTarget:(id)target action:(SEL)actMethod;
+ (UIButton*) navigationItemBtnInitWithNormalImageNamed:(NSString*)normalImageName andHighlightedImageNamed:(NSString*)highlighedImageName target:(id)target action:(SEL)actMethod;
+ (UIButton*) navigationItemBtnInitWithTitle:(NSString*)title target:(id)target action:(SEL)actMethod;
+ (UIButton*) navigationItemNewBtnInitWithTitle:(NSString*)title target:(id)target action:(SEL)actMethod;


//加密
+ (NSString *)encodedData:(NSString *)srcData;
//解密
+ (NSString *)decodeData:(NSString *)srcata;
//获取表情
+(NSString*)getExpressionStrById:(int)idx;


+ (Boolean)isNumberCharaterString:(NSString *)str;
+ (Boolean)isCharaterString:(NSString *)str;
+ (Boolean)isNumberString:(NSString *)str;
+ (Boolean)hasillegalString:(NSString *)str;
+ (Boolean)isValidSmsString:(NSString *)str;
+ (NSString*) getKeyByName:(NSString*)name;
+ (EImageType)getImageTypeByData:(NSData *)imageData;
+ (BOOL)writeImage:(UIImage*)image toFileAtPath:(NSString*)aPath;
//封装了通讯录访问的两个函数，因为kABPersonSocialProfileProperty这个值，总是出现奇怪问题，导致程序崩溃。
+ (CFTypeRef)TABRecordCopyValueOfSocialProfile:(ABRecordRef)record;
+ (BOOL)TABRecordSetValueOfSocialProfile:(ABRecordRef)record value:(CFTypeRef)value    error:(CFErrorRef*)error;
+(BOOL)verifyEmail:(NSString*)email;
+(BOOL)verifyPhone:(NSString*)phone;
+(BOOL)verifyMobilePhone:(NSString*)phone;
+(NSString *)getTimeString:(NSInteger)duration; //通过时长获取时分秒的字符串
BOOL accessAddressBook(ABAddressBookRef addressBook);
+ (NSString *)cleanPhone:(NSString *)beforeClean;
@end
