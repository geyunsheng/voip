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

#import "GetSearchDataObj.h"

@implementation GetSearchDataObj
@synthesize checked;
@synthesize contactID;
@synthesize contactName;
@synthesize pinyin;
@synthesize contactPinyinProperty;
@synthesize contactPinyinLabel;
@synthesize prefix;
@synthesize contactPinyin;
@synthesize matchPos;
@synthesize matchLen;
@synthesize startPos;
@synthesize isFullMatch;
@synthesize isPinyin;
@synthesize isContinuous;
@synthesize phoneArr;
@synthesize portrait;

- (GetSearchDataObj *)init {
    if (self=[super init]) {
        return self;
    }
    return nil;
}

- (void)dealloc {
    self.contactName = nil;
    self.pinyin = nil;
    self.contactPinyinLabel = nil;
    self.prefix = nil;
    self.contactPinyin = nil;
    self.matchPos = nil;
    self.phoneArr = nil;
    self.portrait = nil;
    [super dealloc];
}

-(NSComparisonResult)compareContactName:(GetSearchDataObj *)b {
    if (self.isPinyin<b.isPinyin) {
        return NSOrderedAscending;
    }
    else if (self.isPinyin>b.isPinyin) {
        return NSOrderedDescending;
    }
    return [self.pinyin compare:[b pinyin]];
}

-(NSComparisonResult)compareName:(GetSearchDataObj *)other {
    if (2==self.contactPinyinProperty && self.contactPinyinProperty==other.contactPinyinProperty) {
//都是数字
        if (self.startPos>other.startPos) {
            return NSOrderedDescending;
        }
        else if (self.startPos<other.startPos) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    } 
    else if (2!=self.contactPinyinProperty && 2!=other.contactPinyinProperty) {
//都不是数字
        if (0==self.isFullMatch && self.isFullMatch==other.isFullMatch) {
            if (self.isContinuous>other.isContinuous) {
                return NSOrderedAscending;
            }
            else if (self.isContinuous<other.isContinuous){
                return NSOrderedDescending;
            }
            if (self.startPos>other.startPos) {
                return NSOrderedDescending;
            }
            else if (self.startPos<other.startPos) {
                return NSOrderedAscending;
            }
            if (self.matchLen>other.matchLen) {
                return NSOrderedAscending;
            }
            else if (self.matchLen<other.matchLen) {
                return NSOrderedDescending;
            }
            if (self.isPinyin>other.isPinyin) {
                return NSOrderedDescending;
            }
            else if (self.isPinyin<other.isPinyin){
                return NSOrderedAscending;
            }
            return [self.contactPinyinLabel compare:other.contactPinyinLabel];
        }
        else if (1 == self.isFullMatch && self.isFullMatch==other.isFullMatch) {
            if (self.isPinyin>other.isPinyin) {
                return NSOrderedDescending;
            }
            else if (self.isPinyin<other.isPinyin) {
                return NSOrderedAscending;
            }
            return [self.contactPinyinLabel compare:other.contactPinyinLabel];
        }
        else if (self.isFullMatch<other.isFullMatch) {
            return NSOrderedDescending;
        }
        else if (self.isFullMatch>other.isFullMatch) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }
    else if (2==self.contactPinyinProperty && 2!=other.contactPinyinProperty) {
        return NSOrderedDescending;
    }
    else if (2!=self.contactPinyinProperty && 2==other.contactPinyinProperty) {
        return NSOrderedAscending;
    }
    return NSOrderedSame;
}
@end
