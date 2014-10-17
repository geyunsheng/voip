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
#import "DBConnection.h"
#import "Statement.h"
//#import "AddressBookContactSearchResult.h"
#import "GetSearchDataObj.h"


@interface SearchDBAccess : NSObject {
    sqlite3 * shareDB;
}

- (SearchDBAccess *) init;
- (void)dealloc;

- (BOOL)contactPinyinTableCreate;
- (BOOL)initDB;
- (BOOL)deleteAllFromPinyinTable; 
- (BOOL)deleteFromPinyinTableInArr:(NSString *)idArr;
//设置查询数据
//- (int)saveSearchData:(int)property label:(NSString *)label Pf:(NSString *)prefix value:(NSString *)pinyin contactID:(NSInteger)id;
- (int)saveSearchData:(int)property label:(NSString *)label Identifier:(int)identifier Pf:(NSString *)prefix value:(NSString *)pinyin contactID:(NSInteger)id;
- (NSArray *)getData:(NSString *)searchItem Second:(NSString *)second Third:(NSString *)third Range:(NSString *)range;
- (NSArray *)getData:(NSString *)searchItem Second:(NSString *)second Third:(NSString *)third;
- (NSArray *)getDataT9:(NSString *)searchItem Second:(NSString *)second Range:(NSString *)range;
- (NSArray *)getDataT9:(NSString *)searchItem Second:(NSString *)second otherPhoneNO:(BOOL)isSearch;
//- (NSArray *)getData:(NSString *)searchItem Sec:(NSString *)second;
- (NSArray *)getDataWithPrefix:(NSString *)searchItem Range:(NSString *)range;
- (NSArray *)getDataWithPrefix:(NSString *)searchItem;
- (NSArray *)getDataWithPrefixT9WithOutRange:(NSString *)searchItem;
- (NSArray *)getDataWithPrefixT9WithRange:(NSString *)searchItem Range:(NSString *)range;
- (NSArray *)getDataWithPrefixT9First:(NSString *)searchItem otherPhoneNO:(BOOL)isSearch;
- (NSArray *)getDataWithPrefixT9Sec:(NSString *)searchItem Filter:(NSString *)filter otherPhoneNO:(BOOL)isSearch;
- (NSArray *)getDataWithPrefixT9:(NSString *)searchItem Filter:(NSString *)filter otherPhoneNO:(BOOL)isSearch;
- (NSArray *)getDataWithNumberFirst:(NSString *)searchItem Range:(NSString *)range;
- (NSArray *)getDataWithNumber:(NSString *)searchItem WithRange:(NSString *)range WithFilter:(NSString *)filter;
- (NSArray *)getDataWithNumber:(NSString *)searchItem Filter:(NSString *)filter  otherPhoneNO:(BOOL)isSearch;
- (NSArray *)getDataWithNumberBatch:(NSString *)searchItem otherPhoneNO:(BOOL)isSearch;
- (NSArray *)getDataWithNumber:(NSString *)searchItem otherPhoneNO:(BOOL)isSearch;
- (NSArray *)getData:(NSString *)searchItem Sec:(NSString *)second Third:(NSString*)third Fourth:(NSString*)fourth Fifth:(NSString *)fifth Sixth:(NSString *)sixth Range:(NSString *)range;
- (NSArray *)getData:(NSString *)searchItem Sec:(NSString *)second Third:(NSString*)third Fourth:(NSString*)fourth Fifth:(NSString *)fifth Sixth:(NSString *)sixth;
- (NSArray *)getDataT9:(NSString *)searchItem Sec:(NSString *)second Third:(NSString*)third Fourth:(NSString*)fourth  Fifth:(NSString *)fifth Six:(NSString *)sixth Range:(NSString *)range;
- (NSArray *)getDataT9:(NSString *)searchItem Sec:(NSString *)second Third:(NSString*)third Fourth:(NSString*)fourth  Fifth:(NSString *)fifth Six:(NSString *)sixth otherPhoneNO:(BOOL)isSearch;
- (int)getDataByPhone:(NSString *)phone;

- (NSArray *)getAllPhoneNum;
- (NSArray *)getIDsByphone:(NSString *)phone;
- (int)getContactIDByString:(NSString *)str;

@end
