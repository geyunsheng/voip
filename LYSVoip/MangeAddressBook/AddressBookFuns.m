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

#import "AddressBookFuns.h"


@implementation AddressBookFuns

+ (id)initAddressBookFuns
{
    AddressBookFuns *addressBookFuns = [[AddressBookFuns alloc]init];
    [addressBookFuns initGroupsArray];
    
    return [addressBookFuns autorelease];
}

- (void)dealloc
{
    [groupsArray release];
    [groupIDArray release];
    
    if (addressBook) {
        CFRelease(addressBook);
    }
    [super dealloc];
}

//获取组信息,把每个组内的联系record　id记录到数组里面
//groupsArray:　里面每一个元素是一个数组,这些数组里面,保存的是联系人id
//groupIDArray:　保存组id

- (void)initGroupsArray
{
    ABRecordID contactRecord;
    
    if(groupsArray)
    {
        //已经获取了信息,
        return;
    }
    
    addressBook = ABAddressBookCreate();
    groupsArray = [[NSMutableArray alloc] init];
    groupIDArray = [[NSMutableArray alloc] init];
    
    //获取所有组的列表
    NSArray *groups = (NSArray*)ABAddressBookCopyArrayOfAllGroups(addressBook);
    for (id groupref in groups)
    {
        NSMutableArray *recordArray = [[NSMutableArray alloc] init];
        
        //把组的recordid　放在数组的第一个位置
        NSNumber *groupNum = [[NSNumber alloc] initWithDouble:ABRecordGetRecordID(groupref)];
        [groupIDArray addObject:groupNum];        
        [groupNum release];
        
        NSArray *contacts = (NSArray *)ABGroupCopyArrayOfAllMembers(groupref);
        for (id item in contacts)
        {
            //把组里面的联系人id,存到数组里面
            contactRecord = ABRecordGetRecordID((ABRecordRef)item);
            NSNumber *contactNum = [[NSNumber alloc] initWithDouble:contactRecord];
            [recordArray addObject:contactNum];
            [contactNum release];
        }
        [contacts release];
        [groupsArray addObject:recordArray];   
        [recordArray release];
    }
    [groups release];
}

- (int) contactsCount
{
    return ABAddressBookGetPersonCount(addressBook);
}

- (NSArray *) contacts
{
	NSArray *thePeople = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
	return [thePeople autorelease];
}

- (int) numOfGroups
{
	int ncount = ABAddressBookGetGroupCount(addressBook);
    
    return ncount;
}

- (NSArray *) groups
{
	NSArray *groups = (NSArray *)ABAddressBookCopyArrayOfAllGroups(addressBook);
	return [groups autorelease];
}

- (NSArray *)getGroupList:(ABRecordRef)contactRef
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    CFIndex index = 0;
    
    //获取联系人的id
    ABRecordID contactRecord = ABRecordGetRecordID(contactRef);
    NSNumber *contactNumber = [[NSNumber alloc] initWithDouble:contactRecord];    
    //遍历组
    for (id array in groupsArray) 
    {
        if ([array containsObject:contactNumber])
        {            
            //数组的第一个位置就是组的id
            [resultArray addObject:[groupIDArray objectAtIndex:index]];
        }
        index++;
    }
    
    [contactNumber release];
    return [resultArray autorelease];
}

+ (ABRecordID)createGroup:(NSString *)groupName
{
    BOOL res = NO;
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordRef group = ABGroupCreate();
    ABRecordSetValue(group, kABGroupNameProperty, groupName, nil);
    res = ABAddressBookAddRecord(addressBook, group, nil);
    
    if ( !res )
    {
        CFRelease(addressBook);
        CFRelease(group);
        return 0;
    }
    
    res = ABAddressBookSave(addressBook, nil);

    CFRelease(addressBook);
    CFRelease(group);
    
    if ( !res )
    {
        return 0;
    }
    
    ABRecordID groupID = ABRecordGetRecordID(group);
    return groupID;
}

+ (void)cleanAddressBook
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    //删除所有组
    NSArray *groups = (NSArray *)ABAddressBookCopyArrayOfAllGroups(addressBook);
    
    for (int i = 0; i < groups.count; i++) 
    {
        ABAddressBookRemoveRecord(addressBook, [groups objectAtIndex:i], nil);
    }
    [groups release];

    //删除所有联系人
    NSArray *contactArray = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    for(id contact in contactArray)
    {
        ABAddressBookRemoveRecord(addressBook, (ABRecordRef)contact, NULL);   
    }
    [contactArray release];
    
    ABAddressBookSave(addressBook, NULL);
    CFRelease(addressBook);
}

+ (NSDictionary *) addressWithStreet: (NSString *) street withCity: (NSString *) city
						   withState:(NSString *) state withZip: (NSString *) zip
						 withCountry: (NSString *) country withCode: (NSString *) code
{
	NSMutableDictionary *md = [NSMutableDictionary dictionary];
	if (street) [md setObject:street forKey:(NSString *) kABPersonAddressStreetKey];
	if (city) [md setObject:city forKey:(NSString *) kABPersonAddressCityKey];
	if (state) [md setObject:state forKey:(NSString *) kABPersonAddressStateKey];
	if (zip) [md setObject:zip forKey:(NSString *) kABPersonAddressZIPKey];
	if (country) [md setObject:country forKey:(NSString *) kABPersonAddressCountryKey];
	if (code) [md setObject:code forKey:(NSString *) kABPersonAddressCountryCodeKey];
	return md;
}

+ (NSDictionary *) dictionaryWithValue: (id) value andLabel: (CFStringRef) label
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	if (value) [dict setObject:value forKey:@"value"];
	if (label) [dict setObject:(NSString *)label forKey:@"label"];
	return dict;
}

+ (NSDictionary *) smsWithService: (CFStringRef) service andUser: (NSString *) userName
{
	NSMutableDictionary *sms = [NSMutableDictionary dictionary];
	if (service) [sms setObject:(NSString *) service forKey:(NSString *) kABPersonInstantMessageServiceKey];
	if (userName) [sms setObject:userName forKey:(NSString *) kABPersonInstantMessageUsernameKey];
	return sms;
}

+ (NSDictionary *) twitterWithService: (CFStringRef) service andUser: (NSString *) userName
{
   	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	if (service) [dict setObject:(NSString *) service forKey:(NSString *) kABPersonSocialProfileServiceKey];
	if (userName) [dict setObject:userName forKey:(NSString *) kABPersonSocialProfileUsernameKey];
	return dict; 
}

@end
