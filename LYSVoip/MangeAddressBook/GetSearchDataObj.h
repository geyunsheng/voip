/*
 All rights reserved.
 
 Permission to use, copy, modify, and distribute this software
 for any purpose with or without fee is hereby granted, provided
 that the above copyright notice and this permission notice
 appear in all copies.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT OF THIRD PARTY RIGHTS. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 Except as contained in this notice, the name of a copyright
 holder shall not be used in advertising or otherwise to promote
 the sale, use or other dealings in this Software without prior
 written authorization of the copyright holder.
 */

#import <Foundation/Foundation.h>

@interface GetSearchDataObj : NSObject

@property (nonatomic, assign) BOOL checked;
//conatctID
@property (nonatomic, assign) NSInteger contactID;
//联系人姓名
@property (nonatomic, retain) NSString * contactName;
//联系人名字拼音
@property (nonatomic, retain) NSString * pinyin;
//type eg. prefix/pinyin/phone/email
@property (nonatomic, assign) int contactPinyinProperty;
//label eg. home work
@property (nonatomic, retain) NSString * contactPinyinLabel;
//将拼音转化为数字的时候用，例如LQ对应57
@property (nonatomic, retain) NSString * prefix;
//value eg. 13501230123 or custom@work.com
@property (nonatomic, retain) NSString *contactPinyin;
//match pos
@property (nonatomic, retain) NSArray * matchPos;
#pragma mark -
#pragma mark - for order
//start pos
@property (nonatomic, assign)  int startPos;
//match len
@property (nonatomic, assign) int matchLen;
//连续 1 跳跃 0
@property (nonatomic, assign) int isContinuous;
//汉字 1 字母 0 名字里面只要有一个中文，该字段为1
@property (nonatomic, assign) int isPinyin;
//全部匹配 1 部分匹配 0
@property (nonatomic, assign) int isFullMatch;
@property (nonatomic, retain) NSMutableArray * phoneArr;
//match value in array
@property (nonatomic, retain) UIImage * portrait;

- (GetSearchDataObj *)init;
- (void)dealloc;
-(NSComparisonResult)compareContactName:(GetSearchDataObj *)b;
-(NSComparisonResult)compareName:(GetSearchDataObj *)other;
@end
