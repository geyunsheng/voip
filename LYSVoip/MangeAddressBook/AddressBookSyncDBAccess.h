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
#import "AddressBookFuns.h"

typedef enum 
{
    EAddressBookSyncGroup= 0,    //存储群组的同步信息
    EAddressBookSyncContact      //存储联系人的同步信息
} EAddressBokkSynctype;

@interface AddressBookSyncDBAccess : NSObject
{
    EAddressBokkSynctype idType;
    sqlite3 * shareDB;
    NSMutableDictionary *changeMutableDic;
    NSMutableDictionary *idMutableDic;
}

- (AddressBookSyncDBAccess *)init:(EAddressBokkSynctype)type;
- (void)dealloc;

//创建空表
- (BOOL)AddressBookSyncTableCreate;
//将生成的MD5值入库
- (BOOL)addSyncMD5Data:(NSMutableDictionary *)hashData;
- (NSMutableDictionary *)getMD5Data;
- (BOOL)updateSyncTable:(NSMutableDictionary *) add Update:(NSMutableDictionary *)update Del:(NSArray *)del;
- (BOOL)cleanTable;

- (NSMutableDictionary *)getAllHashString;
//外部调用哈希值写入本地库中
- (BOOL)wirteToSyncTable;

- (NSString *)getHashGroupString:(id)group;
- (NSString *)getHashContactString:(id)contact addressBookFuns:(AddressBookFuns *)addressBookFuns;

//根据当前通讯录数据，更新数据库，会替换以前版本
- (BOOL)updateDBFromAdressBook;

- (void)composeDBFromAdressBook;

//和通讯录比较，返回差别的id，字典的key为：０：添加　　１：删除　　２：修改，对应的为id数组
- (NSMutableDictionary *)getChangedInfo;
- (BOOL)updateDBWithChangedInfo:(NSMutableArray *)contactIDArray;

//和通讯录里面的数据同步
- (BOOL)addItemByID:(NSInteger)itemID;
- (BOOL)updateItemByID:(NSInteger)itemID;
- (BOOL)delItmByID:(NSInteger)itemID;
- (NSMutableDictionary*)getContactsChangedCount;//获取联系人的变更 NSMutableDictionary内 addCount为增加的联系人数目，editCount是修改的，delCount是删除的
@end
