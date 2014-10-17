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
#import "AddressBookContactSearchResult.h"
#import "pinyin.h"
#import "SearchDBAccess.h"
#import "AppDefine.h"
#import "SearchDBAccess.h"
#import "AddressBookGroup.h"
#import "SearchDataObj.h"
#import "ContactWithName.h"
#import "GroupDBAccess.h"


@interface AddressBookContactList : NSObject{
@public
    ABAddressBookRef addressBook;
    dispatch_queue_t mySearchQueue;
}

@property (nonatomic,retain) NSMutableDictionary * contactWithName;
@property (nonatomic,retain) SearchDBAccess * mySearchDBAccess;
@property (nonatomic,retain) NSMutableDictionary * registerWithPhoneNO;
@property (nonatomic,retain) NSMutableDictionary * allContactDictionary;
+(AddressBookContactList *) getSharedAddressBookContact;

#pragma mark -
#pragma mark interface exposed to UI
//根据输入搜索联系人，返回AddressBookContactSearchResult数组
- (NSArray *)search:(NSString *)searchItem keyboard:(int)keyboard Range:(NSDictionary *)range;
- (NSArray *)search:(NSString *)searchItem keyboard:(int)keyboard otherPhoneNO:(BOOL)isSearch;
//当对点击查询结果，需要进一步展示用户的详细信息时调用
- (AddressBookContactSearchResult *)getContactByID:(ABRecordID) recordID;
- (NSString *)getContactNameByPhone:(NSString *) phone;
- (NSString *)getContactNameByPhone:(NSString *) phone ID:(int *)contactIDBack;
- (NSString *)getFirstPhoneByStr:(NSString *) str AndID:(int *)contactIDBack;
//列出目前通讯录里的所有联系人
//只返回包括用户名、第一个联系电话等简单的信息，为AddressBookContactSearchResult数组
- (NSMutableDictionary *)listAllContacts;
//对联系人的增删改
//添加联系人时，若成功添加，返回新增联系人ID；否则返回-1
- (int)addContact:(AddressBookContactSearchResult *) theContact;
- (BOOL)updateContact:(AddressBookContactSearchResult *) theContact;
- (BOOL)deleteContactSingle:(int) contactID;//ABRecordRemoveValue
- (BOOL)delContacts:(NSArray *)contactIDArr;
//对联系人图片的操作
- (BOOL)hasPortrait:(int) contactID;
- (BOOL)setImage:(int) contactID image:(NSData *)image;
- (BOOL)removeImage:(int) contactID;
-(UIImage *)drawImage:(UIImage*)image size:(CGSize)size;
- (UIImage *)getImage:(int) contactID;
-(int)getContactIDByPhone:(NSString *) phone;//根据电话获取本地联系人id
//获得全部联系人数量
- (signed long) getContactCount;//ABAddressBookGetPersonCount
//其他相关的组操作
- (BOOL)addANewGroup:(NSString *)groupName;
- (BOOL)delTheGroup:(int)groupID;
//列出所有分组
- (NSArray *)listAllGroups;
- (BOOL)addNewContactToGroup:(int) theContact group:(int)groupID;
- (BOOL)renameGroup:(int)groupID newName:(NSString *)newName;
- (BOOL)removeContactFromGroup:(int)conatctID group:(int)groupID;
- (NSMutableDictionary *)getGroupContacts:(int)groupID;
- (BOOL)moveContactFromOneToAnother:(int)contactID one:(int)groupID another:(int)anotherGroupID;
- (BOOL)setContactsGroups:(int)contactID add:(NSMutableArray*)checkGroupIDList delGroups:(NSMutableArray*)delGroups;
#pragma mark -
#pragma mark - For bakcup addressbook
- (NSArray *)getContactFrom:(int)startNO count:(int)count;
- (NSDictionary *)getAllGroupMemInDic;
- (NSArray *)getGroupListByContactID:(int)contactID withGroupDic:(NSDictionary *) groupDic;

#pragma mark -
#pragma mark - only for internal use
- (NSArray *)searchContact:(NSString *)searchItem Range:(NSDictionary *)range;
- (NSArray *)searchContactT9:(NSString *)searchItem otherPhoneNO:(BOOL)isSearch;
- (NSArray *)searchContactT9:(NSString *)searchItem Range:(NSDictionary *)range;
- (NSArray *)searchContactNumberBatch:(NSString *)searchItem Range:(NSDictionary *) dic;
- (NSArray *)searchContactNumberBatch:(NSString *)searchItem otherPhoneNO:(BOOL)isSearch;
- (void)addArr2Dic:(NSMutableArray *)arr Dic:(NSMutableDictionary *) dic key:(char)key;
#pragma mark -
#pragma mark create pinyin
- (void)createPinyin;
- (void) createPinyinIncrease:(NSNotification *)_notification;
- (NSString *)getFirstNotNullPhoOrEmail:(ABRecordRef)record;
- (NSString *)getFirstNotNullPhoOrEmailForUI:(int)recordID;
- (NSString *)compositeString:(NSString *)first Mid:(NSString *)second Last:(NSString *)third;
#pragma mark -
#pragma mark other local C funs for internal use
NSString * cleanPhoneNo(NSString * oldPho);
NSString * remove86(NSString * beforeRemove);
NSMutableArray * matchStr(int property,NSString * fullPinyin, NSString * nameInPinyin,NSString * searchItem, int * isFullMatch);
NSMutableArray * matchStrT9(int property,NSString * fullPinyin,NSString * prefix, NSString * nameInPinyin,NSString * searchItem, int * isFullMatch);
NSArray * matchStrSingle(int property,NSString * fullPinyin,NSString * nameInPinyin,NSString * searchItem, int * isFullMatch);
NSArray * matchStrSingleT9(int property,NSString * fullPinyin,NSString * prefix, NSString * nameInPinyin,NSString * searchItem, int * isFullMatch);
NSArray * matchStrNumber(int property, NSString * nameInPinyin,NSString * searchItem, int * isFullMatch,int searchItemLen);
#pragma mark - for jump search
NSArray * matchStrJump(int property,NSString * fullPinyin, NSString * nameInPinyin,NSString * searchItem);
NSArray * matchStrJumpT9(int property,NSString * fullPinyin,NSString * prefix, NSString * nameInPinyin,NSString * searchItem);

- (NSArray *)filterArrayWithArray:(NSArray *)source FilterCondition:(NSArray *)filter;
- (NSMutableDictionary *)filterDictionaryWithArray:(NSMutableDictionary *)source FilterCondition:(NSArray *)filter;

//检测iPhone通讯录是否改变，若改变了，则在此函数里调用createPinyin函数重新生成查询数据
#pragma mark detect iPhone contact list changes
void addressBookChanged(ABAddressBookRef addressBook,CFDictionaryRef info,void* context);
-(BOOL)isInGroupWithGroupID:(int)groupID andContactID:(NSInteger)contactid;
@end
