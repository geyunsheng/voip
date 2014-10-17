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

@interface PhoneNamePair : NSObject

@property (nonatomic,retain) NSString * value1; //如Phone
@property (nonatomic,retain) NSString * value2; //如汉字对应拼音或者英文
@property (nonatomic,assign) BOOL isPinyin; //扩展字段 若name中含有中文，为1
@property (nonatomic,retain) NSString * name;//扩展字段


- (PhoneNamePair *)init;
- (void)dealloc;

- (NSComparisonResult)compareByValue1:(PhoneNamePair *)b;
- (NSComparisonResult)compareByValue2:(PhoneNamePair *)b;
- (NSComparisonResult)compareByMultiFactors:(PhoneNamePair *)b;
@end
