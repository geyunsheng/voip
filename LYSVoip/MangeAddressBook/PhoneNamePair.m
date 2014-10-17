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
#import "PhoneNamePair.h"

@implementation PhoneNamePair

@synthesize value1,value2,isPinyin,name;

- (PhoneNamePair *)init {
    if (self=[super init]) {
        return self;
    }
    return nil;
}

- (void)dealloc {
    self.value1 = nil;
    self.value2 = nil;
    self.name = nil;
    [super dealloc];
}

- (NSComparisonResult)compareByValue1:(PhoneNamePair *)b {
    return [self.value1 compare:b.value1];
}
- (NSComparisonResult)compareByValue2:(PhoneNamePair *)b {
    return [self.value2 compare:b.value2];
}
- (NSComparisonResult)compareByMultiFactors:(PhoneNamePair *)b {
    if (self.isPinyin < b.isPinyin) {
        return NSOrderedAscending;
    }
    else if (self.isPinyin > b.isPinyin) {
        return NSOrderedDescending;
    }
    return [self.value2 compare:b.value2];
}
@end
