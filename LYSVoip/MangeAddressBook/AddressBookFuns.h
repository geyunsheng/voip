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
#import <AddressBook/AddressBook.h>

@interface AddressBookFuns : NSObject
{
    NSMutableArray      *groupsArray;
    NSMutableArray      *groupIDArray;
    ABAddressBookRef     addressBook;
}

+ (id)initAddressBookFuns;

- (void)dealloc;

//获取联系人数目
- (int) contactsCount;

//联系人数组，使用的时候需要释放
- (NSArray *) contacts;

//分组数目
- (int) numOfGroups;

//分组数组，使用的时候需要释放
- (NSArray *) groups;

//获取组信息,把每个组内的联系record　id记录到数组里面
- (void)initGroupsArray;

- (NSArray *)getGroupList:(ABRecordRef)contactRef;

+ (ABRecordID)createGroup:(NSString *)groupName;

+ (void)cleanAddressBook;

+ (NSDictionary *) addressWithStreet: (NSString *) street withCity: (NSString *) city
                                    withState:(NSString *) state withZip: (NSString *) zip
                                    withCountry: (NSString *) country withCode: (NSString *) code;

+ (NSDictionary *) dictionaryWithValue: (id) value andLabel: (CFStringRef) label;

//即时消息单项，即：IM
+ (NSDictionary *) smsWithService: (CFStringRef) service andUser: (NSString *) userName;

//twitter
+ (NSDictionary *) twitterWithService: (CFStringRef) service andUser: (NSString *) userName;

@end
