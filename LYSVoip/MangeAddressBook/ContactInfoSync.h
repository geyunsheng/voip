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

@interface ContactInfoSync : NSObject

@property (nonatomic,retain) NSString * phone;
//有自定义图像 1 没有自定义图像 0
@property (nonatomic,assign) int contactID;
@property (nonatomic,retain) NSString * userDefinedPortraitPath;
@property (nonatomic,retain) NSString * updateTime;
@property (nonatomic,retain) NSString * updateTimeNew;
//背景图
@property (nonatomic,assign) int backImageID;   //背景图的ID

@property (nonatomic, retain) NSString *backImgUrl;      //自定义背景url
@property (nonatomic, retain) NSString *backImgPath;     //自定义背景本地路径

@end
