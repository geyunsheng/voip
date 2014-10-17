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

@implementation UINavigationBar (Customized)

- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed:@"navigation.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end


#import "CommonTools.h"
#import "NSDataBase64.h"
#import "vm_crypto.h"
#import "EmojiConvertor.h"
#import "AppDefine.h"
#import "pinyin.h"

EmojiConvertor *emojiConvert = nil;

@implementation CommonTools

+ (UIButton*) navigationBackItemBtnInitWithTarget:(id)target action:(SEL)actMethod {
    return [CommonTools navigationItemBtnInitWithNormalImageNamed:@"videoConf03.png" andHighlightedImageNamed:@"videoConf03_on.png" target:target action:actMethod];
}

+ (UIButton*) navigationItemBtnInitWithNormalImageNamed:(NSString*)normalImageName andHighlightedImageNamed:(NSString*)highlighedImageName target:(id)target action:(SEL)actMethod {
    UIButton* itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:normalImageName];
    itemBtn.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    [itemBtn setBackgroundImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
    [itemBtn setBackgroundImage:[UIImage imageNamed:highlighedImageName] forState:UIControlStateHighlighted];
    [itemBtn addTarget:target action:actMethod forControlEvents:UIControlEventTouchUpInside];
    return itemBtn;
}


+ (UIButton*) navigationItemBtnInitWithTitle:(NSString*)title target:(id)target action:(SEL)actMethod {
    UIButton* itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIFont* font = [UIFont boldSystemFontOfSize:14];
    CGSize titlesize = [title sizeWithFont:font];
    itemBtn.frame = CGRectMake(0, 0, titlesize.width+20, 30);
    [itemBtn setTitle:title forState:UIControlStateNormal];
//    UIEdgeInsets titleInset = itemBtn.titleEdgeInsets;
//    titleInset.left = 10.0f;
//    itemBtn.titleEdgeInsets = titleInset;
    itemBtn.titleLabel.font = font;
    UIImage *offimg = [UIImage imageNamed: @"button01_off.png"];
    UIImage *onimg = [UIImage imageNamed: @"button01_on.png"];
    [itemBtn setBackgroundImage:[offimg stretchableImageWithLeftCapWidth:offimg.size.width*0.5 topCapHeight:offimg.size.height*0.5] forState:UIControlStateNormal];
    [itemBtn setBackgroundImage:[onimg stretchableImageWithLeftCapWidth:onimg.size.width*0.5 topCapHeight:onimg.size.height*0.5] forState:UIControlStateHighlighted];
    [itemBtn addTarget:target action:actMethod forControlEvents:UIControlEventTouchUpInside];
    return itemBtn;
}

+ (UIButton*) navigationItemNewBtnInitWithTitle:(NSString*)title target:(id)target action:(SEL)actMethod {
    UIButton* itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIFont* font = [UIFont boldSystemFontOfSize:14];
    CGSize titlesize = [title sizeWithFont:font];
    itemBtn.frame = CGRectMake(0, 0, titlesize.width+36-titlesize.height, 30);
    [itemBtn setTitle:title forState:UIControlStateNormal];
    itemBtn.titleLabel.font = font;
    [itemBtn setBackgroundImage:[[UIImage imageNamed: @"view_image_bg_icon.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
    [itemBtn setBackgroundImage:[[UIImage imageNamed: @"view_image_bg_icon_on.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateHighlighted];
    [itemBtn addTarget:target action:actMethod forControlEvents:UIControlEventTouchUpInside];
    return itemBtn;
}

//加密
+ (NSString *)encodedData:(NSString *)srcData
{
    NSString *theKey = @"a04daaca96294836bef207594a0a4df8";
    if ( !srcData || srcData.length == 0 )
    {
        return nil;
    }
    
    const char *cstrOriBody = [srcData cStringUsingEncoding:NSUTF8StringEncoding];
    int cstrOriBodyLen = strlen(cstrOriBody);
    
    char *chEncodeBody = (char*)malloc(cstrOriBodyLen+8);
    memset(chEncodeBody, 0, cstrOriBodyLen+8);
    
    int encodelen = 0;
    
    encodelen = AES_Encrypt_1((const unsigned char*)cstrOriBody,
                              cstrOriBodyLen,
                              (unsigned char*)chEncodeBody,
                              (const unsigned char*)[theKey UTF8String]);
    
    NSData *encodedData = [[NSData alloc] initWithBytes:chEncodeBody length:encodelen];
    NSString *base64 = [encodedData base64Encoding];
    free(chEncodeBody);
    
    //    NSData *mybody = [[[NSData alloc] initWithData:[base64 dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
    [encodedData release];
    
    return base64;
}

+ (NSString *)decodeData:(NSString *)srcData
{
    NSString *theKey = @"a04daaca96294836bef207594a0a4df8";
    if ( !srcData || srcData.length == 0 )
    {
        return nil;
    }
    
    NSData *encodedData = [[[NSData alloc] initWithData:[srcData dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
    
    //解密包体
    char *chDecodeBody = (char*)malloc([encodedData length]*2);
    memset(chDecodeBody, 0, [encodedData length]*2);
    
    NSString *base64Body = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
    NSData *encodeData = [NSData dataWithBase64EncodedString:base64Body];
    [base64Body release];
    
    AES_Decrypt_1((unsigned char*)[encodeData bytes], encodeData.length, (unsigned char*)chDecodeBody, (const unsigned char*)[theKey UTF8String]);
    
    CFDataRef bodyData = CFDataCreate(NULL, (UInt8 *)chDecodeBody, strlen(chDecodeBody));
    //    NSData *data = (NSData *)bodyData;
    
    NSString *bodyMsg = [[NSString alloc] initWithData:(NSData *)bodyData encoding:NSUTF8StringEncoding];
    
    free(chDecodeBody);
    CFRelease(bodyData);
    
    return [bodyMsg autorelease];;
}

+(NSString*)getExpressionStrById:(int)idx
{
    NSString * str = [self getExpressionById:idx];
    if ([UIDevice currentDevice].systemVersion.floatValue > 6)
    {
        if (emojiConvert == nil)
        {
            emojiConvert = [[EmojiConvertor alloc] init];
        }
        str = [emojiConvert convertEmojiSoftbankToUnicode:str];
    }
    return str;
}

+(NSString*)getExpressionById:(int)idx
{
	switch(idx)
	{
        case 0: return @"\ue415";
        case 1: return @"\ue056";
        case 2: return @"\ue057";
        case 3: return @"\ue414";
        case 4: return @"\ue405";
        case 5: return @"\ue106";
        case 6: return @"\ue418";
        case 7: return @"\ue417";
        case 8: return @"\ue40d";
        case 9: return @"\ue40a";
        case 10: return @"\ue404";
        case 11: return @"\ue105";
        case 12: return @"\ue409";
        case 13: return @"\ue40e";
        case 14: return @"\ue402";
        case 15: return @"\ue108";
        case 16: return @"\ue403";
        case 17: return @"\ue058";
        case 18: return @"\ue407";
        case 19: return @"\ue401";
        case 20: return @"\ue40f";
        case 21: return @"\ue40b";
        case 22: return @"\ue406";
        case 23: return @"\ue413";
        case 24: return @"\ue411";
        case 25: return @"\ue412";
        case 26: return @"\ue410";
        case 27: return @"\ue107";
        case 28: return @"\ue059";
        case 29: return @"\ue416";
        case 30: return @"\ue408";
        case 31: return @"\ue40c";
        case 32: return @"\ue11a";
        case 33: return @"\ue10c";
        case 34: return @"\ue022";
        case 35: return @"\ue023";
        case 36: return @"\ue329";
        case 37: return @"\ue32e";
        case 38: return @"\ue335";
        case 39: return @"\ue337";
        case 40: return @"\ue336";
        case 41: return @"\ue13c";
        case 42: return @"\ue331";
        case 43: return @"\ue03e";
        case 44: return @"\ue11d";
        case 45: return @"\ue05a";
        case 46: return @"\ue00e";
        case 47: return @"\ue421";
        case 48: return @"\ue420";
        case 49: return @"\ue00d";
        case 51: return @"\ue011";
        case 52: return @"\ue22e";
        case 53: return @"\ue22f";
        case 54: return @"\ue231";
        case 55: return @"\ue230";
        case 56: return @"\ue00f";
        case 57: return @"\ue14c";
        case 58: return @"\ue111";
        case 59: return @"\ue425";
        case 60: return @"\ue001";
        case 61: return @"\ue002";
        case 62: return @"\ue005";
        case 63: return @"\ue004";
        case 64: return @"\ue04e";
        case 65: return @"\ue11c";
        case 66: return @"\ue003";
        case 67: return @"\ue04a";
        case 68: return @"\ue04b";
        case 69: return @"\ue049";
        case 70: return @"\ue048";
        case 71: return @"\ue04c";
        case 72: return @"\ue13d";
        case 73: return @"\ue43e";
        case 74: return @"\ue04f";
        case 75: return @"\ue052";
        case 76: return @"\ue053";
        case 77: return @"\ue524";
        case 78: return @"\ue52c";
        case 79: return @"\ue52a";
        case 80: return @"\ue531";
        case 81: return @"\ue050";
        case 82: return @"\ue527";
        case 83: return @"\ue051";
        case 84: return @"\ue10b";
        case 85: return @"\ue52b";
        case 86: return @"\ue52f";
        case 87: return @"\ue109";
        case 88: return @"\ue528";
        case 89: return @"\ue01a";        
        case 90: return @"\ue52d";
        case 91: return @"\ue521";
        case 92: return @"\ue52e";
        case 93: return @"\ue055";
        case 94: return @"\ue525";
        case 95: return @"\ue10a";
        case 96: return @"\ue522";
        case 97: return @"\ue054";
        case 98: return @"\ue520";
        case 99: return @"\ue032";
        case 100: return @"\ue303";
        case 101: return @"\ue307";
        case 102: return @"\ue308";
        case 103: return @"\ue437";
        case 104: return @"\ue445";
        case 105: return @"\ue11b";
        case 106: return @"\ue448";
        case 107: return @"\ue033";
        case 108: return @"\ue112";
        case 109: return @"\ue325";
        case 110: return @"\ue312";
        case 111: return @"\ue310";
        case 112: return @"\ue126";
        case 113: return @"\ue008";
        case 114: return @"\ue03d";
        case 115: return @"\ue00c";
        case 116: return @"\ue12a";
        case 117: return @"\ue009";
        case 118: return @"\ue145";
        case 119: return @"\ue144";
        case 120: return @"\ue03f";
        case 121: return @"\ue116";
        case 122: return @"\ue10f";
        case 123: return @"\ue101";
        case 124: return @"\ue13f";
        case 125: return @"\ue12f";
        case 126: return @"\ue311";
        case 127: return @"\ue113";
        case 128: return @"\ue30f";
        case 129: return @"\ue42b";
        case 130: return @"\ue42a";
        case 131: return @"\ue018";
        case 132: return @"\ue016";
        case 133: return @"\ue015";
        case 134: return @"\ue131";
        case 135: return @"\ue12b";
        case 136: return @"\ue03c";
        case 137: return @"\ue041";
        case 138: return @"\ue322";
        case 139: return @"\ue10e";
        case 140: return @"\ue43c";
        case 141: return @"\ue323";
        case 142: return @"\ue31c";
        case 143: return @"\ue034";
        case 144: return @"\ue035";
        case 145: return @"\ue045";
        case 146: return @"\ue047";
        case 147: return @"\ue30c";
        case 148: return @"\ue044";
        case 149: return @"\ue120";
        case 150: return @"\ue33b";
        case 151: return @"\ue33f";
        case 152: return @"\ue344";
        case 153: return @"\ue340";
        case 154: return @"\ue147";
        case 155: return @"\ue33a";
        case 156: return @"\ue34b";
        case 157: return @"\ue345";
        case 158: return @"\ue01d";
        case 159: return @"\ue10d";
        case 160: return @"\ue136";        
        case 161: return @"\ue435";
        case 162: return @"\ue252";
        case 163: return @"\ue132";
        case 164: return @"\ue138";
        case 165: return @"\ue139";
        case 166: return @"\ue332";
        case 167: return @"\ue333";
        case 168: return @"\ue24e";
        case 169: return @"\ue24f";
        case 170: return @"\ue537";
	}
	return @"\ue056";
}


+ (Boolean)isNumberCharaterString:(NSString *)str
{
    NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789QWERTYUIOPLKJHGFDSAZXCVBNMqwertyuioplkjhgfdsazxcvbnm"] invertedSet];
    NSRange foundRange = [str rangeOfCharacterFromSet:disallowedCharacters];
    if (foundRange.location == NSNotFound) {
        ccp_AddressLog(@"是数字和字母的集合");
        return YES;
    }
    return NO;
}

+ (Boolean)isCharaterString:(NSString *)str
{
    NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"QWERTYUIOPLKJHGFDSAZXCVBNMqwertyuioplkjhgfdsazxcvbnm"] invertedSet];
    NSRange foundRange = [str rangeOfCharacterFromSet:disallowedCharacters];
    if (foundRange.location == NSNotFound) {
        ccp_AddressLog(@"字母的集合");
        return YES;
    }
    return NO;
}

+ (Boolean)isNumberString:(NSString *)str
{
    NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSRange foundRange = [str rangeOfCharacterFromSet:disallowedCharacters];
    if (foundRange.location == NSNotFound) {
        ccp_AddressLog(@"是数字集合");
        return YES;
    }
    return NO;
}

+ (Boolean)hasillegalString:(NSString *)str
{
    if ( str.length == 0 )  //目前允许是空
    {
        return NO;
    }
    
    NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"/／!！@@#＃$￥%^……&&*＊(（)）——_++|“”:：｛{}｝《<>》?？~～、-；;"] invertedSet];
    NSRange foundRange = [str rangeOfCharacterFromSet:disallowedCharacters];
    
    ccp_AddressLog( @"%@", str );
    
    if (foundRange.location == NSNotFound)
    {
        ccp_AddressLog(@"含有非法字符");
        return YES;
    }
    
    return NO;
}

+ (Boolean)isValidSmsString:(NSString *)str
{
    NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789+"] invertedSet];
    NSRange foundRange = [str rangeOfCharacterFromSet:disallowedCharacters];
    if (foundRange.location == NSNotFound) {
        ccp_AddressLog(@"是数字集合");
        return YES;
    }
    return NO;
}

+(NSString*) getKeyByName:(NSString*)name{
    NSMutableArray * pinyinStr = [[NSMutableArray alloc] initWithCapacity:1];
    //根据联系人姓名生成拼音
    unichar key;
    xm_string_to_pinyin(name, name.length, pinyinStr);
    if (pinyinStr.count>0) {
        key = [[pinyinStr objectAtIndex:0] characterAtIndex:0];
    }
    else
        key = '#';
    
    [pinyinStr release];
    switch (key) {
        case 'a':
        case 'A':
            return @"A";
        case 'b':
        case 'B':
            return @"B";
        case 'c':
        case 'C':
            return @"C";
        case 'd':
        case 'D':
            return @"D";
        case 'e':
        case 'E':
            return @"E";
        case 'f':
        case 'F':
            return @"F";
        case 'g':
        case 'G':
            return @"G";
        case 'h':
        case 'H':
            return @"H";
        case 'i':
        case 'I':
            return @"I";
        case 'j':
        case 'J':
            return @"J";
        case 'k':
        case 'K':
            return @"K";
        case 'l':
        case 'L':
            return @"L";
        case 'm':
        case 'M':
            return @"M";
        case 'n':
        case 'N':
            return @"N";
        case 'o':
        case 'O':
            return @"O";
        case 'p':
        case 'P':
            return @"P";
        case 'q':
        case 'Q':
            return @"Q";
        case 'r':
        case 'R':
            return @"R";
        case 's':
        case 'S':
            return @"S";
        case 't':
        case 'T':
            return @"T";
        case 'u':
        case 'U':
            return @"U";
        case 'v':
        case 'V':
            return @"V";
        case 'w':
        case 'W':
            return @"W";
        case 'x':
        case 'X':
            return @"X";
        case 'y':
        case 'Y':
            return @"Y";
        case 'z':
        case 'Z':
            return @"Z";
        default:
            return @"^";
    }
}

+ (EImageType)getImageTypeByData:(NSData *)imageData
{
    unsigned char imageHeadBytes[8];
    [imageData getBytes:imageHeadBytes length:8];
    ccp_AddressLog(@"%d", (int)imageHeadBytes[0]);
    ccp_AddressLog(@"%d", (int)imageHeadBytes[1]);
    ccp_AddressLog(@"%d", (int)imageHeadBytes[2]);
    ccp_AddressLog(@"%d", (int)imageHeadBytes[3]);
    
    if(imageHeadBytes[0] == 0xFF)
    {
        
        if(imageHeadBytes[1] == 0xD8)
            return EImageJPG;
    }
    else if(imageHeadBytes[0] == 0x47)
    {
        if(imageHeadBytes[1] == 0x49
           && imageHeadBytes[2] == 0x46
           && imageHeadBytes[3] == 0x38
           && (imageHeadBytes[4] == 0x37 || imageHeadBytes[4] == 0x39)
           && imageHeadBytes[5] == 0x61
           )
            return EImageGIF;
    }
    else if(imageHeadBytes[0] == 0x42)
    {
        if(imageHeadBytes[1] == 0x4D)
            return EImageBMP;
    }
    else if(imageHeadBytes[0] == 0x89)
    {
        if(imageHeadBytes[1] == 0x50
           && imageHeadBytes[2] == 0x4E
           && imageHeadBytes[3] == 0x47
           && imageHeadBytes[4] == 0x0D
           && imageHeadBytes[5] == 0x0A
           && imageHeadBytes[6] == 0x1A
           && imageHeadBytes[7] == 0x0A
           )
            return EImagePNG;
    }
    
    return EImageInvalidType;
}
+ (BOOL)writeImage:(UIImage*)image toFileAtPath:(NSString*)aPath
{
    if ((image == nil) || (aPath == nil) || ([aPath isEqualToString:@""]))
        return NO;
    @try
    {
        NSData *imageData = nil;
        NSString *ext = [aPath pathExtension];
        if ([ext isEqualToString:@"png"])
        {
            // the rest, we write to jpeg
            // 0. best, 1. lost. about compress.
            imageData = UIImagePNGRepresentation(image);
        }
        else
        {
            imageData = UIImageJPEGRepresentation (image, 0.7);
        }
        if ((imageData == nil) || ([imageData length] <= 0))
            return NO;
        [imageData writeToFile:aPath atomically:YES];
        return YES;
    }
    @catch (NSException *e)
    
    {
        ccp_AddressLog(@"create thumbnail exception.");
    }
    return NO;
}
+ (UIImage *)compressImage:(UIImage *)image withSize:(CGSize)viewsize
{
    CGFloat imgHWScale = image.size.height/image.size.width;
    CGFloat viewHWScale = viewsize.height/viewsize.width;
    CGRect rect = CGRectZero;
    if (imgHWScale>viewHWScale)
    {
        rect.size.height = viewsize.width*imgHWScale;
        rect.size.width = viewsize.width;
        rect.origin.x = 0.0f;
        rect.origin.y =  (viewsize.height - rect.size.height)*0.5f;
    }
    else
    {
        CGFloat imgWHScale = image.size.width/image.size.height;
        rect.size.width = viewsize.height*imgWHScale;
        rect.size.height = viewsize.height;
        rect.origin.y = 0.0f;
        rect.origin.x = (viewsize.width - rect.size.width)*0.5f;
    }
    
	UIGraphicsBeginImageContext(viewsize);
	[image drawInRect:rect];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return newimg;
}

+ (CFTypeRef)TABRecordCopyValueOfSocialProfile:(ABRecordRef)record
{
    return ABRecordCopyValue(record, kABPersonSocialProfileProperty);
}

+ (BOOL)TABRecordSetValueOfSocialProfile:(ABRecordRef)record value:(CFTypeRef)value    error:(CFErrorRef*)error
{
    return ABRecordSetValue(record, kABPersonSocialProfileProperty, value, error);
}

+(BOOL)verifyEmail:(NSString*)email
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[A-Za-z0-9._%+-]+@[A-Za-z0-9._%+-]+\\.[A-Za-z0-9._%+-]+$" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSInteger numberOfMatches = [regex numberOfMatchesInString:email options:0 range:NSMakeRange(0, [email length])];
    if (numberOfMatches != 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+(BOOL)verifyPhone:(NSString*)phone
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]{3,}" options:NSRegularExpressionCaseInsensitive error:nil];
    
    
    
    NSInteger numberOfMatches = [regex numberOfMatchesInString:phone options:0 range:NSMakeRange(0, [phone length])];
    if (numberOfMatches != 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+(BOOL)verifyMobilePhone:(NSString*)phone
{
    NSString *regex = @"1[0-9]{10}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:phone] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (NSString *)getTimeString:(NSInteger)duration
{
    NSInteger hour = 0;
    NSInteger minute = 0;
    NSInteger second = 0;
    
    hour = duration / 3600;
    minute = duration % 3600 / 60;
    second = duration % 3600 % 60;
    
    NSString *dateStr = nil;
    
    if ( hour > 0 )
    {
        dateStr = [NSString stringWithFormat:@"%02d小时%02d分%02d秒", hour, minute, second];
    }
    else if ( minute > 0 )
    {
        dateStr = [NSString stringWithFormat:@"%02d分%02d秒", minute, second];
    }
    else
    {
        dateStr = [NSString stringWithFormat:@"%02d秒", second];
    }
    
    return dateStr;
}

BOOL accessAddressBook(ABAddressBookRef addressBook)
{
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL)
    {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                 {
                                                     accessGranted = granted;
                                                     dispatch_semaphore_signal(sema);
                                                 });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else
        accessGranted = YES;
    return accessGranted;
}

+ (NSString *)cleanPhone:(NSString *)beforeClean
{
    if ([beforeClean hasPrefix:@"+86"])
    {
        return [beforeClean substringFromIndex:3];
    }
    else if ([beforeClean hasPrefix:@"0086"])
    {
        return [beforeClean substringFromIndex:4];
    }
    else
        return beforeClean;
}

@end