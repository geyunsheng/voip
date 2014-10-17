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

#import "AddressBookContactList.h"
#import "CommonTools.h"
NSMutableDictionary * contactWithName;

@interface AddressBookContactList (Private)

@end

@implementation AddressBookContactList

static AddressBookContactList * theAddressBookContactList = nil;
@synthesize contactWithName;
@synthesize mySearchDBAccess;
@synthesize registerWithPhoneNO;
@synthesize allContactDictionary;

#pragma mark -
#pragma mark - class method
+(AddressBookContactList *) getSharedAddressBookContact {
    if (nil == theAddressBookContactList) {
        theAddressBookContactList = [[AddressBookContactList alloc] init];
    }
    return theAddressBookContactList;
}
#pragma mark -
#pragma mark - custom methods to ensure singleton
- (id) init {
    self=[super init];
    addressBook = ABAddressBookCreate();
    ABAddressBookRegisterExternalChangeCallback(addressBook, addressBookChanged, self);
    NSMutableDictionary * muDictionary = [[NSMutableDictionary alloc] init];
    self.contactWithName = muDictionary;
    [muDictionary release];
     
    SearchDBAccess * tempSearchDBAccess = [[SearchDBAccess alloc] init];
    self.mySearchDBAccess = tempSearchDBAccess;
    [tempSearchDBAccess release];
    [self createPinyin];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createPinyin) 
                                                 name:@"addressbookChangedLocal"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createPinyinIncrease:)
                                                 name:@"addressbookChangedIncrease"
                                               object:nil];
    return  self;
}
+(id)allocWithZone:(NSZone *)zone {
    if (nil==theAddressBookContactList) {
        theAddressBookContactList = [super allocWithZone:zone];
        return theAddressBookContactList;
    };
    return theAddressBookContactList;
}
-(id)copyWithZone:(NSZone *)zone {
    return self;
}
-(id)retain {
    return self;
}
-(NSUInteger)retainCount {
    return NSUIntegerMax;
}
-(oneway void)release {

}
-(id)autorelease {
    return self;
}

#pragma mark -
#pragma mark - functional methods
//根据用户的名字、电话、邮箱等生成查询数据
- (void) createPinyin {
    ccp_AddressLog(@"%s begins...",__func__);
    int alpha[26] = {2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,7,8,8,8,9,9,9,9};
    NSString * tempName;
    NSString * capitalString;
    NSString * capitalStringWithoutWhiteSpace;
    [contactWithName removeAllObjects];
    ABAddressBookRef addressBookForPinyin=ABAddressBookCreate();
    NSMutableArray * searchData = [[NSMutableArray alloc] init];
    if (accessAddressBook(addressBookForPinyin))
    {
        
        CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBookForPinyin);
        CFMutableArrayRef peopleMutableForPinyin = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(results), results);
        CFArraySortValues(peopleMutableForPinyin, CFRangeMake(0, CFArrayGetCount(peopleMutableForPinyin)), (CFComparatorFunction)ABPersonComparePeopleByName, (void *)ABPersonGetSortOrdering());
        int peopleCount = CFArrayGetCount(peopleMutableForPinyin);
        
        //以下依次将联系人的名字等相关信息添加到检索表中
        for (int out=0; out<peopleCount; out++) {
            ContactWithName * tempWithName = [[ContactWithName alloc] init];
            ABRecordRef person = CFArrayGetValueAtIndex(peopleMutableForPinyin, out);
            int contactID = ABRecordGetRecordID(person);
            tempWithName.contactID = contactID;
            NSString * firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString * lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            NSMutableString * compositeName = [[NSMutableString alloc]init];
            if (nil!=lastName) {
                [compositeName appendString:lastName];
            }
            if (nil!=firstName) {
                [compositeName appendString:@" "];
                [compositeName appendString:firstName];
            }
            if ([compositeName length] > 50) {
                NSRange range;
                range.location = 50;
                range.length = [compositeName length] -50;
                [compositeName deleteCharactersInRange:range];
            }
            [lastName release];
            [firstName release];
            NSMutableArray * pinyinStr = [[NSMutableArray alloc] initWithCapacity:1];
            tempWithName.name = [compositeName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //根据联系人姓名生成拼音
            tempWithName.isPinyin = xm_string_to_pinyin(compositeName,[compositeName length],pinyinStr);
            if ([pinyinStr count]>0) {
                tempWithName.pinyin = [[[[pinyinStr objectAtIndex:0] lowercaseString] capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
            //添加联系人拼音前缀
            for (int ii=0; ii<[pinyinStr count]; ii++) {
                capitalString = [[[pinyinStr objectAtIndex:ii] lowercaseString] capitalizedString];
                NSMutableArray * prefixArr = [[NSMutableArray alloc] initWithArray:[[pinyinStr objectAtIndex:ii] componentsSeparatedByString:@" "]];
                if ([prefixArr containsObject:@""]) {
                    [prefixArr removeObject:@""];
                }
                NSMutableString * preStr = [[NSMutableString alloc] initWithCapacity:1];
                for (int j=0; j<[prefixArr count]; j++) {
                    [preStr appendFormat:@"%c",[[prefixArr objectAtIndex:j] characterAtIndex:0]];
                }
                //将数据存放到对象数组
                capitalStringWithoutWhiteSpace = [capitalString stringByReplacingOccurrencesOfString:@" " withString:@""];
                SearchDataObj * tempOjbPre = [[SearchDataObj alloc] init];
                tempName = [preStr lowercaseString];
                tempOjbPre.property = 0;
                tempOjbPre.label = capitalStringWithoutWhiteSpace;
                tempOjbPre.value = [tempName uppercaseString];
                tempOjbPre.contactID = contactID;
                [searchData addObject:tempOjbPre];
                [tempOjbPre release];
                [prefixArr release];
                //将拼音前缀转化为数字
                NSMutableString * tempPrefixInNumber = [[NSMutableString alloc] init];
                for (int inNumber=0; inNumber<[tempName length]; inNumber++) {
                    if ('a'<=[tempName characterAtIndex:inNumber] && [tempName characterAtIndex:inNumber]<='z') {
                        [tempPrefixInNumber appendFormat:@"%d",alpha[[tempName characterAtIndex:inNumber]-'a']];
                    }
                    else {
                        [tempPrefixInNumber appendFormat:@"%c",[tempName characterAtIndex:inNumber]];
                    }
                }
                SearchDataObj * tempPRObjNumber = [[SearchDataObj alloc] init];
                tempPRObjNumber.property = 4;
                //对于转化为数字的拼音前缀来说，还需要保留，复用Label字段
                tempPRObjNumber.label = capitalStringWithoutWhiteSpace;
                tempPRObjNumber.prefix = [tempName uppercaseString];
                tempPRObjNumber.value = tempPrefixInNumber;
                [tempPrefixInNumber release];
                tempPRObjNumber.contactID = contactID;
                [searchData addObject:tempPRObjNumber];
                [tempPRObjNumber release];
                [preStr release];
                //添加联系人名字拼音
                SearchDataObj * tempObjPinyin = [[SearchDataObj alloc] init];
                tempObjPinyin.property = 1;
                tempObjPinyin.label = capitalStringWithoutWhiteSpace;
                tempObjPinyin.value = [[pinyinStr objectAtIndex:ii] lowercaseString];
                tempObjPinyin.contactID = contactID;
                [searchData addObject:tempObjPinyin];
                [tempObjPinyin release];
                
                //联系人名字的拼音转化为数字
                tempName = [[pinyinStr objectAtIndex:ii] lowercaseString];
                NSMutableString * tempNameInNumber = [[NSMutableString alloc] init];
                for (int inNumber=0; inNumber<[tempName length]; inNumber++) {
                    if ('a'<=[tempName characterAtIndex:inNumber] && [tempName characterAtIndex:inNumber]<='z') {
                        [tempNameInNumber appendFormat:@"%d",alpha[[tempName characterAtIndex:inNumber]-'a']];
                    }
                    else {
                        [tempNameInNumber appendFormat:@"%c",[tempName characterAtIndex:inNumber]];
                    }
                }
                SearchDataObj * tempObjNumber = [[SearchDataObj alloc] init];
                tempObjNumber.property = 5;
                //对于转化为数字的拼音来说，还需要保留，复用Label字段
                tempObjNumber.label = capitalStringWithoutWhiteSpace;
                tempObjNumber.prefix = tempName;
                tempObjNumber.value = tempNameInNumber;
                [tempNameInNumber release];
                tempObjNumber.contactID = contactID;
                [searchData addObject:tempObjNumber];
                [tempObjNumber release];
            }
            //添加联系人电话
            ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
            NSInteger phoneCount = ABMultiValueGetCount(phone);
            for (int i1=0; i1<phoneCount; i1++) {
                CFStringRef tempStr = ABMultiValueCopyLabelAtIndex(phone, i1);
                NSString * personPhoneLabel = (NSString *)ABAddressBookCopyLocalizedLabel(tempStr);                
                if (tempStr) {
                    CFRelease(tempStr);
                }
                NSString * oldPho = (NSString *)ABMultiValueCopyValueAtIndex(phone, i1);
                NSString * personPhone = remove86(cleanPhoneNo(oldPho));
                if (personPhone!=nil) {
                    if (0==i1) {
                        tempWithName.firstNotNullPhoOrMail=personPhone;
                    }
                    [tempWithName.phoneArr addObject:personPhone];
                    SearchDataObj * tempObjPhone = [[SearchDataObj alloc] init];
                    tempObjPhone.property = 2;
                    tempObjPhone.label = personPhoneLabel;
                    tempObjPhone.value = personPhone;
                    tempObjPhone.contactID = contactID;
                    tempObjPhone.identifier = ABMultiValueGetIdentifierAtIndex(phone,i1);
                    [searchData addObject:tempObjPhone];
                    [tempObjPhone release];
                }
                [personPhoneLabel release];
                [oldPho release];
            }
            CFRelease(phone);
            if (1==EMAIL) {
                //添加联系人邮箱
                ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
                NSInteger emailCount = ABMultiValueGetCount(email);
                for (int i2=0; i2<emailCount; i2++) {
                    CFStringRef tempStr = ABMultiValueCopyLabelAtIndex(email, i2);
                    NSString * personEmailLabel = (NSString *)ABAddressBookCopyLocalizedLabel(tempStr);
                    if (tempStr) {
                        CFRelease(tempStr);
                    }
                    NSString * personEmail = (NSString *)ABMultiValueCopyValueAtIndex(email, i2);
                    if (personEmail!=nil) {
                        if (nil==tempWithName.firstNotNullPhoOrMail) {
                            tempWithName.firstNotNullPhoOrMail=personEmail;
                        }
                        SearchDataObj * tempObjMail = [[SearchDataObj alloc] init];
                        tempObjMail.property = 3;
                        tempObjMail.label = personEmailLabel;
                        tempObjMail.value = personEmail;
                        tempObjMail.contactID = contactID;
                        [searchData addObject:tempObjMail];
                        [tempObjMail release];
                    }
                    [personEmailLabel release];
                    [personEmail release];
                }
                CFRelease(email);
            }
            if (nil==tempWithName.firstNotNullPhoOrMail) {
                tempWithName.firstNotNullPhoOrMail = [self getFirstNotNullPhoOrEmail:person];
            }
            [compositeName release];
            [pinyinStr release];
            NSNumber * tempNumber = [[NSNumber alloc] initWithInt:contactID];
            [self.contactWithName setObject:tempWithName forKey:tempNumber];
            [tempNumber release];
            [tempWithName release];
        }
        CFRelease(addressBookForPinyin);
        CFRelease(results);
        CFRelease(peopleMutableForPinyin);
        //    ccp_AddressLog(@"Create data end!");
    }
    
//搜索数据入库
    [DBConnection beginTransaction];
    [self.mySearchDBAccess contactPinyinTableCreate];
    [self.mySearchDBAccess deleteAllFromPinyinTable];
    int loopCount = [searchData count];
    for (int inner = 0; inner<loopCount; inner++) {
        SearchDataObj * tempCurr = [searchData objectAtIndex:inner];
        [self.mySearchDBAccess saveSearchData:tempCurr.property label:tempCurr.label Identifier: tempCurr.identifier Pf:tempCurr.prefix value:tempCurr.value contactID:tempCurr.contactID];
    }
    [DBConnection commitTransaction];
    [searchData release];
    //App状态同步
    self.allContactDictionary = [self listAllContacts];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addressbookChanged" object:nil userInfo:nil];
    ccp_AddressLog(@"%s ends...",__func__);
}

//根据用户的名字、电话、邮箱等生成查询数据
- (void) createPinyinIncrease:(NSNotification *)_notification {
    extern NSInteger contactOptState;

    
    NSDictionary* idDic = [_notification userInfo];
    if (1==contactOptState) {//增加
        NSArray * idArr = [[idDic objectForKey:@"V"] componentsSeparatedByString:@","];
        int alpha[26] = {2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,7,8,8,8,9,9,9,9};
        NSString * tempName;
        NSString * capitalString;
        NSString * capitalStringWithoutWhiteSpace;
        ABAddressBookRef addressBookForPinyin=ABAddressBookCreate();
        
        int peopleCount = [idArr count];
        NSMutableArray * searchData = [[NSMutableArray alloc] init];
        //以下依次将联系人的名字等相关信息添加到检索表中
        for (int out=0; out<peopleCount; out++) {
            ContactWithName * tempWithName = [[ContactWithName alloc] init];
            int contactID = [[idArr objectAtIndex:out] intValue];
            tempWithName.contactID = contactID;
            ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBookForPinyin, contactID);
            NSString * firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString * lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            NSMutableString * compositeName = [[NSMutableString alloc]init];
            if (nil!=lastName) {
                [compositeName appendString:lastName];
            }
            if (nil!=firstName) {
                [compositeName appendString:@" "];
                [compositeName appendString:firstName];
            }
            if ([compositeName length] > 50) {
                NSRange range;
                range.location = 50;
                range.length = [compositeName length] -50;
                [compositeName deleteCharactersInRange:range];
            }
            [lastName release];
            [firstName release];
            NSMutableArray * pinyinStr = [[NSMutableArray alloc] initWithCapacity:1];
            tempWithName.name = [compositeName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //根据联系人姓名生成拼音
            tempWithName.isPinyin = xm_string_to_pinyin(compositeName,[compositeName length],pinyinStr);
            if ([pinyinStr count]>0) {
                tempWithName.pinyin = [[[[pinyinStr objectAtIndex:0] lowercaseString] capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
            //添加联系人拼音前缀
            for (int ii=0; ii<[pinyinStr count]; ii++) {
                capitalString = [[[pinyinStr objectAtIndex:ii] lowercaseString] capitalizedString];
                NSMutableArray * prefixArr = [[NSMutableArray alloc] initWithArray:[[pinyinStr objectAtIndex:ii] componentsSeparatedByString:@" "]];
                if ([prefixArr containsObject:@""]) {
                    [prefixArr removeObject:@""];
                }
                NSMutableString * preStr = [[NSMutableString alloc] initWithCapacity:1];
                for (int j=0; j<[prefixArr count]; j++) {
                    [preStr appendFormat:@"%c",[[prefixArr objectAtIndex:j] characterAtIndex:0]];
                }
                //将数据存放到对象数组
                capitalStringWithoutWhiteSpace = [capitalString stringByReplacingOccurrencesOfString:@" " withString:@""];
                SearchDataObj * tempOjbPre = [[SearchDataObj alloc] init];
                tempName = [preStr lowercaseString];
                tempOjbPre.property = 0;
                tempOjbPre.label = capitalStringWithoutWhiteSpace;
                tempOjbPre.value = [tempName uppercaseString];
                tempOjbPre.contactID = contactID;
                [searchData addObject:tempOjbPre];
                [tempOjbPre release];
                [prefixArr release];
                //将拼音前缀转化为数字
                NSMutableString * tempPrefixInNumber = [[NSMutableString alloc] init];
                for (int inNumber=0; inNumber<[tempName length]; inNumber++) {
                    if ('a'<=[tempName characterAtIndex:inNumber] && [tempName characterAtIndex:inNumber]<='z') {
                        [tempPrefixInNumber appendFormat:@"%d",alpha[[tempName characterAtIndex:inNumber]-'a']];
                    }
                    else {
                        [tempPrefixInNumber appendFormat:@"%c",[tempName characterAtIndex:inNumber]];
                    }
                }
                SearchDataObj * tempPRObjNumber = [[SearchDataObj alloc] init];
                tempPRObjNumber.property = 4;
                //对于转化为数字的拼音前缀来说，还需要保留，复用Label字段
                tempPRObjNumber.label = capitalStringWithoutWhiteSpace;
                tempPRObjNumber.prefix = [tempName uppercaseString];
                tempPRObjNumber.value = tempPrefixInNumber;
                [tempPrefixInNumber release];
                tempPRObjNumber.contactID = contactID;
                [searchData addObject:tempPRObjNumber];
                [tempPRObjNumber release];
                [preStr release];
                //添加联系人名字拼音
                SearchDataObj * tempObjPinyin = [[SearchDataObj alloc] init];
                tempObjPinyin.property = 1;
                tempObjPinyin.label = capitalStringWithoutWhiteSpace;
                tempObjPinyin.value = [[pinyinStr objectAtIndex:ii] lowercaseString];
                tempObjPinyin.contactID = contactID;
                [searchData addObject:tempObjPinyin];
                [tempObjPinyin release];
                
                //联系人名字的拼音转化为数字
                tempName = [[pinyinStr objectAtIndex:ii] lowercaseString];
                NSMutableString * tempNameInNumber = [[NSMutableString alloc] init];
                for (int inNumber=0; inNumber<[tempName length]; inNumber++) {
                    if ('a'<=[tempName characterAtIndex:inNumber] && [tempName characterAtIndex:inNumber]<='z') {
                        [tempNameInNumber appendFormat:@"%d",alpha[[tempName characterAtIndex:inNumber]-'a']];
                    }
                    else {
                        [tempNameInNumber appendFormat:@"%c",[tempName characterAtIndex:inNumber]];
                    }
                }
                SearchDataObj * tempObjNumber = [[SearchDataObj alloc] init];
                tempObjNumber.property = 5;
                //对于转化为数字的拼音来说，还需要保留，复用Label字段
                tempObjNumber.label = capitalStringWithoutWhiteSpace;
                tempObjNumber.prefix = tempName;
                tempObjNumber.value = tempNameInNumber;
                [tempNameInNumber release];
                tempObjNumber.contactID = contactID;
                [searchData addObject:tempObjNumber];
                [tempObjNumber release];
            }
            //添加联系人电话
            ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
            NSInteger phoneCount = ABMultiValueGetCount(phone);
            for (int i1=0; i1<phoneCount; i1++) {
                CFStringRef tempStr = ABMultiValueCopyLabelAtIndex(phone, i1);
                NSString * personPhoneLabel = (NSString *)ABAddressBookCopyLocalizedLabel(tempStr);
                if (tempStr) {
                    CFRelease(tempStr);
                }
                NSString * oldPho = (NSString *)ABMultiValueCopyValueAtIndex(phone, i1);
                NSString * personPhone = remove86(cleanPhoneNo(oldPho));
                if (personPhone!=nil) {
                    if (0==i1) {
                        tempWithName.firstNotNullPhoOrMail=personPhone;
                    }
                    [tempWithName.phoneArr addObject:personPhone];
                    SearchDataObj * tempObjPhone = [[SearchDataObj alloc] init];
                    tempObjPhone.property = 2;
                    tempObjPhone.label = personPhoneLabel;
                    tempObjPhone.value = personPhone;
                    tempObjPhone.contactID = contactID;
                    tempObjPhone.identifier = ABMultiValueGetIdentifierAtIndex(phone,i1);
                    [searchData addObject:tempObjPhone];
                    [tempObjPhone release];
                }
                [personPhoneLabel release];
                [oldPho release];
            }
            CFRelease(phone);
            if (1==EMAIL) {
                //添加联系人邮箱
                ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
                NSInteger emailCount = ABMultiValueGetCount(email);
                for (int i2=0; i2<emailCount; i2++) {
                    CFStringRef tempStr = ABMultiValueCopyLabelAtIndex(email, i2);
                    NSString * personEmailLabel = (NSString *)ABAddressBookCopyLocalizedLabel(tempStr);
                    if (tempStr) {
                        CFRelease(tempStr);
                    }
                    NSString * personEmail = (NSString *)ABMultiValueCopyValueAtIndex(email, i2);
                    if (personEmail!=nil) {
                        if (nil==tempWithName.firstNotNullPhoOrMail) {
                            tempWithName.firstNotNullPhoOrMail=personEmail;
                        }
                        SearchDataObj * tempObjMail = [[SearchDataObj alloc] init];
                        tempObjMail.property = 3;
                        tempObjMail.label = personEmailLabel;
                        tempObjMail.value = personEmail;
                        tempObjMail.contactID = contactID;
                        [searchData addObject:tempObjMail];
                        [tempObjMail release];
                    }
                    [personEmailLabel release];
                    [personEmail release];
                }
                CFRelease(email);
            }
            if (nil==tempWithName.firstNotNullPhoOrMail) {
                tempWithName.firstNotNullPhoOrMail = [self getFirstNotNullPhoOrEmail:person];
            }
            [compositeName release];
            [pinyinStr release];
            NSNumber * tempNumber = [[NSNumber alloc] initWithInt:contactID];
            [self.contactWithName setObject:tempWithName forKey:tempNumber];
            [tempNumber release];
            [tempWithName release];
        }
        CFRelease(addressBookForPinyin);

        //搜索数据入库
        [DBConnection beginTransaction];
        [self.mySearchDBAccess contactPinyinTableCreate];
        int loopCount = [searchData count];
        for (int inner = 0; inner<loopCount; inner++) {
            SearchDataObj * tempCurr = [searchData objectAtIndex:inner];
            [self.mySearchDBAccess saveSearchData:tempCurr.property label:tempCurr.label Identifier:tempCurr.identifier Pf:tempCurr.prefix value:tempCurr.value contactID:tempCurr.contactID];
        }
        [DBConnection commitTransaction];
        [searchData release];

    } 
    else if (3==contactOptState) {//修改
        NSString * idStr = [idDic objectForKey:@"V"];
        NSArray * idArr = [idStr componentsSeparatedByString:@","];
        for (NSString * str in idArr) {
            [self.contactWithName removeObjectForKey:[NSNumber numberWithInt:str.intValue]];
        }
        int alpha[26] = {2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,7,8,8,8,9,9,9,9};
        NSString * tempName;
        NSString * capitalString;
        NSString * capitalStringWithoutWhiteSpace;
        ABAddressBookRef addressBookForPinyin=ABAddressBookCreate();
        
        int peopleCount = [idArr count];
        NSMutableArray * searchData = [[NSMutableArray alloc] init];
        //以下依次将联系人的名字等相关信息添加到检索表中
        for (int out=0; out<peopleCount; out++) {
            ContactWithName * tempWithName = [[ContactWithName alloc] init];
            int contactID = [[idArr objectAtIndex:out] intValue];
            tempWithName.contactID = contactID;
            ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBookForPinyin, contactID);
            NSString * firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString * lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            NSMutableString * compositeName = [[NSMutableString alloc]init];
            if (nil!=lastName) {
                [compositeName appendString:lastName];
            }
            if (nil!=firstName) {
                [compositeName appendString:@" "];
                [compositeName appendString:firstName];
            }
            [lastName release];
            [firstName release];
            NSMutableArray * pinyinStr = [[NSMutableArray alloc] initWithCapacity:1];
            tempWithName.name = [compositeName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //根据联系人姓名生成拼音
            tempWithName.isPinyin = xm_string_to_pinyin(compositeName,[compositeName length],pinyinStr);
            if ([pinyinStr count]>0) {
                tempWithName.pinyin = [[[[pinyinStr objectAtIndex:0] lowercaseString] capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
            //添加联系人拼音前缀
            for (int ii=0; ii<[pinyinStr count]; ii++) {
                capitalString = [[[pinyinStr objectAtIndex:ii] lowercaseString] capitalizedString];
                NSMutableArray * prefixArr = [[NSMutableArray alloc] initWithArray:[[pinyinStr objectAtIndex:ii] componentsSeparatedByString:@" "]];
                if ([prefixArr containsObject:@""]) {
                    [prefixArr removeObject:@""];
                }
                NSMutableString * preStr = [[NSMutableString alloc] initWithCapacity:1];
                for (int j=0; j<[prefixArr count]; j++) {
                    [preStr appendFormat:@"%c",[[prefixArr objectAtIndex:j] characterAtIndex:0]];
                }
                //将数据存放到对象数组
                capitalStringWithoutWhiteSpace = [capitalString stringByReplacingOccurrencesOfString:@" " withString:@""];
                SearchDataObj * tempOjbPre = [[SearchDataObj alloc] init];
                tempName = [preStr lowercaseString];
                tempOjbPre.property = 0;
                tempOjbPre.label = capitalStringWithoutWhiteSpace;
                tempOjbPre.value = [tempName uppercaseString];
                tempOjbPre.contactID = contactID;
                [searchData addObject:tempOjbPre];
                [tempOjbPre release];
                [prefixArr release];
                //将拼音前缀转化为数字
                NSMutableString * tempPrefixInNumber = [[NSMutableString alloc] init];
                for (int inNumber=0; inNumber<[tempName length]; inNumber++) {
                    if ('a'<=[tempName characterAtIndex:inNumber] && [tempName characterAtIndex:inNumber]<='z') {
                        [tempPrefixInNumber appendFormat:@"%d",alpha[[tempName characterAtIndex:inNumber]-'a']];
                    }
                    else {
                        [tempPrefixInNumber appendFormat:@"%c",[tempName characterAtIndex:inNumber]];
                    }
                }
                SearchDataObj * tempPRObjNumber = [[SearchDataObj alloc] init];
                tempPRObjNumber.property = 4;
                //对于转化为数字的拼音前缀来说，还需要保留，复用Label字段
                tempPRObjNumber.label = capitalStringWithoutWhiteSpace;
                tempPRObjNumber.prefix = [tempName uppercaseString];
                tempPRObjNumber.value = tempPrefixInNumber;
                [tempPrefixInNumber release];
                tempPRObjNumber.contactID = contactID;
                [searchData addObject:tempPRObjNumber];
                [tempPRObjNumber release];
                [preStr release];
                //添加联系人名字拼音
                SearchDataObj * tempObjPinyin = [[SearchDataObj alloc] init];
                tempObjPinyin.property = 1;
                tempObjPinyin.label = capitalStringWithoutWhiteSpace;
                tempObjPinyin.value = [[pinyinStr objectAtIndex:ii] lowercaseString];
                tempObjPinyin.contactID = contactID;
                [searchData addObject:tempObjPinyin];
                [tempObjPinyin release];
                
                //联系人名字的拼音转化为数字
                tempName = [[pinyinStr objectAtIndex:ii] lowercaseString];
                NSMutableString * tempNameInNumber = [[NSMutableString alloc] init];
                for (int inNumber=0; inNumber<[tempName length]; inNumber++) {
                    if ('a'<=[tempName characterAtIndex:inNumber] && [tempName characterAtIndex:inNumber]<='z') {
                        [tempNameInNumber appendFormat:@"%d",alpha[[tempName characterAtIndex:inNumber]-'a']];
                    }
                    else {
                        [tempNameInNumber appendFormat:@"%c",[tempName characterAtIndex:inNumber]];
                    }
                }
                SearchDataObj * tempObjNumber = [[SearchDataObj alloc] init];
                tempObjNumber.property = 5;
                //对于转化为数字的拼音来说，还需要保留，复用Label字段
                tempObjNumber.label = capitalStringWithoutWhiteSpace;
                tempObjNumber.prefix = tempName;
                tempObjNumber.value = tempNameInNumber;
                [tempNameInNumber release];
                tempObjNumber.contactID = contactID;
                [searchData addObject:tempObjNumber];
                [tempObjNumber release];
            }
            //添加联系人电话
            ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
            NSInteger phoneCount = ABMultiValueGetCount(phone);
            for (int i1=0; i1<phoneCount; i1++) {
                CFStringRef tempStr = ABMultiValueCopyLabelAtIndex(phone, i1);
                NSString * personPhoneLabel = (NSString *)ABAddressBookCopyLocalizedLabel(tempStr);
                if (tempStr) {
                    CFRelease(tempStr);
                }
                NSString * oldPho = (NSString *)ABMultiValueCopyValueAtIndex(phone, i1);
                NSString * personPhone = remove86(cleanPhoneNo(oldPho));
                if (personPhone!=nil) {
                    if (0==i1) {
                        tempWithName.firstNotNullPhoOrMail=personPhone;
                    }
                    [tempWithName.phoneArr addObject:personPhone];
                    SearchDataObj * tempObjPhone = [[SearchDataObj alloc] init];
                    tempObjPhone.property = 2;
                    tempObjPhone.label = personPhoneLabel;
                    tempObjPhone.value = personPhone;
                    tempObjPhone.contactID = contactID;
                    tempObjPhone.identifier = ABMultiValueGetIdentifierAtIndex(phone,i1);
                    [searchData addObject:tempObjPhone];
                    [tempObjPhone release];
                }
                [personPhoneLabel release];
                [oldPho release];
            }
            CFRelease(phone);
            if (1==EMAIL) {
                //添加联系人邮箱
                ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
                NSInteger emailCount = ABMultiValueGetCount(email);
                for (int i2=0; i2<emailCount; i2++) {
                    CFStringRef tempStr = ABMultiValueCopyLabelAtIndex(email, i2);
                    NSString * personEmailLabel = (NSString *)ABAddressBookCopyLocalizedLabel(tempStr);
                    if (tempStr) {
                        CFRelease(tempStr);
                    }
                    NSString * personEmail = (NSString *)ABMultiValueCopyValueAtIndex(email, i2);
                    if (personEmail!=nil) {
                        if (nil==tempWithName.firstNotNullPhoOrMail) {
                            tempWithName.firstNotNullPhoOrMail=personEmail;
                        }
                        SearchDataObj * tempObjMail = [[SearchDataObj alloc] init];
                        tempObjMail.property = 3;
                        tempObjMail.label = personEmailLabel;
                        tempObjMail.value = personEmail;
                        tempObjMail.contactID = contactID;
                        [searchData addObject:tempObjMail];
                        [tempObjMail release];
                    }
                    [personEmailLabel release];
                    [personEmail release];
                }
                CFRelease(email);
            }
            if (nil==tempWithName.firstNotNullPhoOrMail) {
                tempWithName.firstNotNullPhoOrMail = [self getFirstNotNullPhoOrEmail:person];
            }
            [compositeName release];
            [pinyinStr release];
            NSNumber * tempNumber = [[NSNumber alloc] initWithInt:contactID];
            [self.contactWithName setObject:tempWithName forKey:tempNumber];
            [tempNumber release];
            [tempWithName release];
        }
        CFRelease(addressBookForPinyin);

        //搜索数据入库
        [DBConnection beginTransaction];
        [self.mySearchDBAccess contactPinyinTableCreate];
        [self.mySearchDBAccess deleteFromPinyinTableInArr:idStr];
        int loopCount = [searchData count];
        for (int inner = 0; inner<loopCount; inner++) {
            SearchDataObj * tempCurr = [searchData objectAtIndex:inner];
            [self.mySearchDBAccess saveSearchData:tempCurr.property label:tempCurr.label Identifier:tempCurr.identifier Pf:tempCurr.prefix value:tempCurr.value contactID:tempCurr.contactID];
        }
        [DBConnection commitTransaction];
        [searchData release];

    }
    else if (2==contactOptState) {//删除
        NSString * idStr = [idDic objectForKey:@"V"];
        NSArray * idArr = [idStr componentsSeparatedByString:@","];
        for (NSString* keystr in idArr) {
            int contactID = [keystr intValue];
            NSNumber * tempNumber = [[NSNumber alloc] initWithInt:contactID];
            [self.contactWithName removeObjectForKey:tempNumber];
            [tempNumber release];
        }
        [self.mySearchDBAccess deleteFromPinyinTableInArr:idStr];
    }
    self.allContactDictionary = [self listAllContacts];
    ccp_AddressLog(@"post addressbookAllChanged");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addressbookChanged" object:nil userInfo:nil];
}

//property 属性 nameInPinyin 搜索数据  searchItem 搜索输入
NSMutableArray * matchStr(int property,NSString * fullPinyin, NSString * nameInPinyin,NSString * searchItem, int * isFullMatch) {
    NSMutableArray * matchArr = [[NSMutableArray alloc] init];
    NSInteger searchItemPos = 0;
    *isFullMatch=0;
    if (0==property) {//首字母匹配
        NSString * searchItemU = [searchItem uppercaseString];
        if ([nameInPinyin isEqualToString:searchItemU]) {

            *isFullMatch=1;
            NSRange range;
            NSRange lastRange = [fullPinyin rangeOfString:[NSString stringWithFormat:@"%c",[nameInPinyin characterAtIndex:0]]];
            [matchArr addObject:[NSValue valueWithRange:lastRange]];
            for (int inner=1; inner<[nameInPinyin length]; inner++) {
                range = [[fullPinyin substringFromIndex:lastRange.location+lastRange.length] rangeOfString:[NSString stringWithFormat:@"%c",[nameInPinyin characterAtIndex:inner]]];
                range.location=range.location+lastRange.location+lastRange.length;
                lastRange.location=range.location;
                lastRange.length=range.length;
                [matchArr addObject:[NSValue valueWithRange:range]];
            }
            return [matchArr autorelease];
        }
        else if (NSNotFound!=[nameInPinyin rangeOfString:searchItemU].location){
            *isFullMatch=0;
            NSRange range;
            NSRange lastRange = [fullPinyin rangeOfString:[NSString stringWithFormat:@"%c",[searchItemU characterAtIndex:0]]];
            [matchArr addObject:[NSValue valueWithRange:lastRange]];
            for (int inner=1; inner<[searchItemU length]; inner++) {
                range = [[fullPinyin substringFromIndex:lastRange.location+lastRange.length] rangeOfString:[NSString stringWithFormat:@"%c",[searchItemU characterAtIndex:inner]]];
                range.location=range.location+lastRange.location+lastRange.length;
                lastRange.location=range.location;
                lastRange.length=range.length;
                [matchArr addObject:[NSValue valueWithRange:range]];
            }
            return [matchArr autorelease];
        }
    }
    else if (1==property) {//拼音匹配
        int endPos=0;
        NSMutableArray * nameArr = (NSMutableArray *)[nameInPinyin componentsSeparatedByString:@" "];
        if ([nameArr containsObject:@""]) {
            [nameArr removeObject:@""];
        }
        int lengthOuter=0;
        int lengthInner;
        for (int outer=0; outer<[nameArr count]; outer++) {
            if (outer>0) {
                lengthOuter+=[[nameArr objectAtIndex:outer-1] length];
            }
            if ([[nameArr objectAtIndex:outer] hasPrefix:searchItem]) {
                [matchArr removeAllObjects];
                searchItemPos = [searchItem length];
                NSRange tempRange = NSMakeRange(lengthOuter, searchItemPos);
                NSValue * tempValue = [NSValue valueWithRange:tempRange];
                [matchArr addObject:tempValue];
                return [matchArr autorelease];
            }
            lengthInner=0;
            for (int i=outer; i<[nameArr count]&&searchItemPos<[searchItem length]; i++) {
                endPos=i;
                NSInteger pos = 0;
                NSString * currPinyin = [nameArr objectAtIndex:i];
                if (i-outer>0) {
                     lengthInner+=[[nameArr objectAtIndex:i-1] length];
                }
                while (searchItemPos<[searchItem length]&&pos<[currPinyin length]&&[currPinyin characterAtIndex:pos]==[searchItem characterAtIndex:searchItemPos]) {
                    pos++;
                    searchItemPos++;
                }
                if (pos>0) {
                    NSRange tempRange = NSMakeRange(lengthInner+lengthOuter, pos);
                    NSValue * tempValue = [NSValue valueWithRange:tempRange];
                        [matchArr addObject:tempValue];
                } 
                if (0==pos&&searchItemPos<[searchItem length]) {
                    [matchArr removeAllObjects];
                    searchItemPos=0;
                    break;
                }
            }
            if (searchItemPos==[searchItem length]) {
                if (0==outer&&endPos==([nameArr count]-1)) {
                    *isFullMatch=1;
                }
                return [matchArr autorelease];
            }
        }
    }
    else {//邮箱匹配
        if ([nameInPinyin isEqualToString:searchItem]) {
            *isFullMatch=1;
            NSRange range = NSMakeRange(0, [searchItem length]);
            [matchArr addObject:[NSValue valueWithRange:range]];
            return [matchArr autorelease];
        }
        else if (NSNotFound!=[nameInPinyin rangeOfString:searchItem].location){
            NSRange rangeEmail = [nameInPinyin rangeOfString:searchItem];
            [matchArr addObject:[NSValue valueWithRange:rangeEmail]];
            return [matchArr autorelease];
        }
    }
    if (searchItemPos<[searchItem length]) {
        [matchArr release];
        return nil;
    }
    if (0==[matchArr count]) {
        [matchArr release];
        return nil;
    }
    [matchArr release];
    return nil;
}

/*用户输入搜索关键字长度大于1时的T9搜索
 *property 属性
 *fullPinyin 全拼(eg. ZhanSan)
 *prefix 数字对应的原始的首字母或者全拼，eg. 97->ZS 94264 726->zhang san
 *nameInPinyin 从数据库中取出的搜索数据
 *searchItem 搜索输入的关键字
 */
NSMutableArray * matchStrT9(int property,NSString * fullPinyin,NSString * prefix, NSString * nameInPinyin,NSString * searchItem, int * isFullMatch) {
    NSMutableArray * matchArr = [[NSMutableArray alloc] init];
    NSInteger searchItemPos = 0;
    *isFullMatch=0;
    if (4==property) {//首字母匹配
        if ([nameInPinyin isEqualToString:searchItem]) {
            *isFullMatch=1;
            NSRange range;
            NSRange lastRange = [fullPinyin rangeOfString:[NSString stringWithFormat:@"%c",[prefix characterAtIndex:0]]];
            [matchArr addObject:[NSValue valueWithRange:lastRange]];
            for (int inner=1; inner<[nameInPinyin length]; inner++) {
                range = [[fullPinyin substringFromIndex:lastRange.location+lastRange.length] rangeOfString:[NSString stringWithFormat:@"%c",[prefix characterAtIndex:inner]]];
                range.location=range.location+lastRange.location+lastRange.length;
                lastRange.location=range.location;
                lastRange.length=range.length;
                [matchArr addObject:[NSValue valueWithRange:range]];
            }
            return [matchArr autorelease];
        }
        else if (NSNotFound!=[nameInPinyin rangeOfString:searchItem].location){
            int start = [nameInPinyin rangeOfString:searchItem].location;
            *isFullMatch=0;
            NSRange range;
            NSRange lastRange = [fullPinyin rangeOfString:[NSString stringWithFormat:@"%c",[prefix characterAtIndex:start++]]];
            [matchArr addObject:[NSValue valueWithRange:lastRange]];
            for (int inner=1; inner<[searchItem length]; inner++) {
                range = [[fullPinyin substringFromIndex:lastRange.location+lastRange.length] rangeOfString:[NSString stringWithFormat:@"%c",[prefix characterAtIndex:start++]]];
                range.location=range.location+lastRange.location+lastRange.length;
                lastRange.location=range.location;
                lastRange.length=range.length;
                [matchArr addObject:[NSValue valueWithRange:range]];
            }
            return [matchArr autorelease];
        }
    }
    else if (2==property) {//电话匹配
        if ([nameInPinyin isEqualToString:searchItem]) {
            *isFullMatch=1;
            NSRange range = NSMakeRange(0, [searchItem length]);
            [matchArr addObject:[NSValue valueWithRange:range]];
            return [matchArr autorelease];
        }
        else if (NSNotFound!=[nameInPinyin rangeOfString:searchItem].location){
            NSRange rangeEmail = [nameInPinyin rangeOfString:searchItem];
            [matchArr addObject:[NSValue valueWithRange:rangeEmail]];
            return [matchArr autorelease];
        }
    }
    else {//拼音匹配
        int endPos=0;
        NSMutableArray * nameArr = (NSMutableArray *)[nameInPinyin componentsSeparatedByString:@" "];
        if ([nameArr containsObject:@""]) {
            [nameArr removeObject:@""];
        }
        int lengthOuter=0;
        int lengthInner;
        for (int outer=0; outer<[nameArr count]; outer++) {
            if (outer>0) {
                lengthOuter+=[[nameArr objectAtIndex:outer-1] length];
            }
            if ([[nameArr objectAtIndex:outer] hasPrefix:searchItem]) {
                [matchArr removeAllObjects];
                searchItemPos = [searchItem length];
                NSRange tempRange = NSMakeRange(lengthOuter, searchItemPos);
                NSValue * tempValue = [NSValue valueWithRange:tempRange];
                [matchArr addObject:tempValue];
                return [matchArr autorelease];
            }
            lengthInner=0;
            for (int i=outer; i<[nameArr count]&&searchItemPos<[searchItem length]; i++) {
                endPos=i;
                NSInteger pos = 0;
                NSString * currPinyin = [nameArr objectAtIndex:i];
                if (i-outer>0) {
                    lengthInner+=[[nameArr objectAtIndex:i-1] length];
                }
                while (searchItemPos<[searchItem length]&&pos<[currPinyin length]&&[currPinyin characterAtIndex:pos]==[searchItem characterAtIndex:searchItemPos]) {
                    pos++;
                    searchItemPos++;
                }
                if (pos>0) {
                    NSRange tempRange = NSMakeRange(lengthInner+lengthOuter, pos);
                    NSValue * tempValue = [NSValue valueWithRange:tempRange];
                    [matchArr addObject:tempValue];
                } 
                if (0==pos&&searchItemPos<[searchItem length]) {
                    [matchArr removeAllObjects];
                    searchItemPos=0;
                    break;
                }
            }
            if (searchItemPos==[searchItem length]) {
                if (0==outer&&endPos==([nameArr count]-1)) {
                    *isFullMatch=1;
                }
                return [matchArr autorelease];
            }
        }
    }
    if (searchItemPos<[searchItem length]) {
        [matchArr release];
        return nil;
    }
    if (0==[matchArr count]) {
        [matchArr release];
        return nil;
    }
    [matchArr release];
    return nil;
}

/*用户输入搜索关键字长度大于1时的跳跃搜索
 *property 属性
 *fullPinyin 全拼(eg. ZhanSan)
 *nameInPinyin 从数据库中取出的搜索数据
 *searchItem 搜索输入的关键字
 */
NSArray * matchStrJump(int property,NSString * fullPinyin, NSString * nameInPinyin,NSString * searchItem) {
    int pinyinLen = [nameInPinyin length];
    int searchLen = [searchItem length];
    if (0==searchLen || pinyinLen<=searchLen) {
        return nil;
    }
    NSMutableArray * matchArr = [[NSMutableArray alloc] init];
    NSInteger searchItemPos = 0;
    if (0==property) {//首字母匹配
        NSString * searchItemU = [searchItem uppercaseString];
        NSRange range;
        NSRange lastRange = [fullPinyin rangeOfString:[NSString stringWithFormat:@"%c",[searchItemU characterAtIndex:0]]];
        [matchArr addObject:[NSValue valueWithRange:lastRange]];
        for (int inner=1; inner<[searchItemU length]; inner++) {
            range = [[fullPinyin substringFromIndex:lastRange.location+lastRange.length] rangeOfString:[NSString stringWithFormat:@"%c",[searchItemU characterAtIndex:inner]]];
            range.location=range.location+lastRange.location+lastRange.length;
            lastRange.location=range.location;
            lastRange.length=range.length;
            [matchArr addObject:[NSValue valueWithRange:range]];
        }
        return [matchArr autorelease];
    }
    else if (1==property) {//全拼匹配
        NSMutableArray * nameArr = (NSMutableArray *)[nameInPinyin componentsSeparatedByString:@" "];
        if ([nameArr containsObject:@""]) {
            [nameArr removeObject:@""];
        }
        NSInteger pos = 0;
        int lengthOuter=0;
        for (int outer=0; outer<[nameArr count]&&searchItemPos<searchLen; outer++) {
            pos = 0;
            if (outer>0) {
                lengthOuter+=[[nameArr objectAtIndex:outer-1] length];
            }
            NSString * currPinyin = [nameArr objectAtIndex:outer];
            while (searchItemPos<searchLen&&pos<[currPinyin length]&&[currPinyin characterAtIndex:pos]==[searchItem characterAtIndex:searchItemPos]) {
                pos++;
                searchItemPos++;
            }
            if (pos>0) {
                NSRange tempRange = NSMakeRange(lengthOuter, pos);
                NSValue * tempValue = [NSValue valueWithRange:tempRange];
                [matchArr addObject:tempValue];
            }
            if (searchItemPos==searchLen) {
                return [matchArr autorelease];
            }
        }
    }
    if (searchItemPos<[searchItem length]) {
        [matchArr release];
        return nil;
    }
    [matchArr release];
    return nil;
}

/*用户输入搜索关键字长度大于1时的跳跃T9搜索
 *property 属性
 *fullPinyin 全拼(eg. ZhanSan)
 *prefix 数字对应的原始的首字母或者全拼，eg. 97->ZS 94264 726->zhang san 
 *nameInPinyin 从数据库中取出的搜索数据
 *searchItem 搜索输入的关键字
 */
NSArray * matchStrJumpT9(int property,NSString * fullPinyin,NSString * prefix, NSString * nameInPinyin,NSString * searchItem) {
    int pinyinLen = [nameInPinyin length];
    int searchLen = [searchItem length];
    if (0==searchLen || pinyinLen<=searchLen) {
        return nil;
    }
    NSMutableArray * matchArr = [[NSMutableArray alloc] init];
    NSInteger searchItemPos = 0;
    if (4==property) {//前缀匹配
        
        NSRange range;
        NSRange strRange;
        int start=0;
        int strStart=0;
        int prefixPos=0;
        int searchCursor=0;
        for (int count=0; count<[searchItem length]; count++) {
            range = [[nameInPinyin substringFromIndex:start] rangeOfString:[NSString stringWithFormat:@"%c",[searchItem characterAtIndex:searchCursor++]]];
            prefixPos=start+range.location;
            strRange = [[fullPinyin substringFromIndex:strStart] rangeOfString:[NSString stringWithFormat:@"%c",[prefix characterAtIndex:prefixPos]]];
            strRange.location+=strStart;
            [matchArr addObject:[NSValue valueWithRange:strRange]];
            start += range.location+1;
            strStart=strRange.location+1;
            
        }
        
        return [matchArr autorelease];
    }
    else if (5==property) {//全拼匹配
        NSMutableArray * nameArr = (NSMutableArray *)[nameInPinyin componentsSeparatedByString:@" "];
        if ([nameArr containsObject:@""]) {
            [nameArr removeObject:@""];
        }
        NSInteger pos = 0;
        int lengthOuter=0;
        for (int outer=0; outer<[nameArr count]&&searchItemPos<searchLen; outer++) {
            pos = 0;
            if (outer>0) {
                lengthOuter+=[[nameArr objectAtIndex:outer-1] length];
            }
            NSString * currPinyin = [nameArr objectAtIndex:outer];
            while (searchItemPos<searchLen&&pos<[currPinyin length]&&[currPinyin characterAtIndex:pos]==[searchItem characterAtIndex:searchItemPos]) {
                pos++;
                searchItemPos++;
            }
            if (pos>0) {
                NSRange tempRange = NSMakeRange(lengthOuter, pos);
                NSValue * tempValue = [NSValue valueWithRange:tempRange];
                [matchArr addObject:tempValue];
            }
            if (searchItemPos==searchLen) {
                return [matchArr autorelease];
            }
        }
    }//end of else
    if (searchItemPos<[searchItem length]) {
        [matchArr release];
        return nil;
    }
    [matchArr release];
    return nil;
}

/*用户输入搜索关键字长度等于1时的普通搜索
 *property 属性
 *fullPinyin 全拼(eg. ZhanSan)
 *nameInPinyin 从数据库中取出的搜索数据
 *searchItem 搜索输入的关键字
 */
NSArray * matchStrSingle(int property,NSString * fullPinyin, NSString * nameInPinyin,NSString * searchItem, int * isFullMatch) {
    NSMutableArray * matchArr = [[NSMutableArray alloc] init];
    NSInteger searchItemPos = 0;
    *isFullMatch=0;
    if (1==[nameInPinyin length]) {
        *isFullMatch=1;
        NSRange tempRang = NSMakeRange(0, 1);
        NSValue * tempValue = [NSValue valueWithRange:tempRang];
        [matchArr addObject:tempValue];
        return [matchArr autorelease];
    }
    else if (NSNotFound!=[nameInPinyin rangeOfString:searchItem].location){
        *isFullMatch=0;
        NSRange myRange = [fullPinyin rangeOfString:searchItem];
        NSValue * tempValue = [NSValue valueWithRange:myRange];
        [matchArr addObject:tempValue];
        return [matchArr autorelease];
    }
    if (searchItemPos<1) {
        [matchArr release];
        return nil;
    }
    return nil;
}

/*用户输入搜索关键字长度等于1时的T9搜索
 *property 属性
 *fullPinyin 全拼(eg. ZhanSan)
 *prefix 数字对应的原始的首字母，eg. 97->ZS
 *nameInPinyin 从数据库中取出的搜索数据
 *searchItem 搜索输入的关键字
 */
NSArray * matchStrSingleT9(int property,NSString * fullPinyin,NSString * prefix, NSString * nameInPinyin,NSString * searchItem, int * isFullMatch) {
    NSMutableArray * matchArr = [[NSMutableArray alloc] init];
    NSInteger searchItemPos = 0;
    *isFullMatch=0;
    if (1==[nameInPinyin length]) {
        *isFullMatch=1;
        NSRange tempRang = NSMakeRange(0, 1);
        NSValue * tempValue = [NSValue valueWithRange:tempRang];
        [matchArr addObject:tempValue];
        return [matchArr autorelease];
    }
    else if (NSNotFound!=[nameInPinyin rangeOfString:searchItem].location){
        *isFullMatch=0;
        if (4==property) {//首字母
            NSRange myRange = [fullPinyin rangeOfString:[NSString stringWithFormat:@"%c",[prefix characterAtIndex: [nameInPinyin rangeOfString: searchItem].location]]];
            NSValue * tempValue = [NSValue valueWithRange:myRange];
            [matchArr addObject:tempValue];
        }
        else {//电话
            NSRange myRange = [nameInPinyin rangeOfString:searchItem];
            NSValue * tempValue = [NSValue valueWithRange:myRange];
            [matchArr addObject:tempValue];
        }
        
        return [matchArr autorelease];
    }
    if (searchItemPos<1) {
        [matchArr release];
        return nil;
    }
    return nil;
}
/*输入关键字为为数字时的搜索
 *
 */
NSArray * matchStrNumber(int property, NSString * nameInPinyin,NSString * searchItem, int * isFullMatch,int searchItemLen) {
    NSMutableArray * matchArr = [[NSMutableArray alloc] init];
    NSInteger searchItemPos = 0;
    *isFullMatch=0;
    if (1==[nameInPinyin length]) {
        searchItemPos=searchItemLen;
        *isFullMatch=1;
        NSRange tempRang = NSMakeRange(1, searchItemPos);
        NSValue * tempValue = [NSValue valueWithRange:tempRang];
        [matchArr addObject:tempValue];
        return [matchArr autorelease];
    }
    else if (NSNotFound!=[nameInPinyin rangeOfString:searchItem].location){
        *isFullMatch=0;
        NSRange myRange = [nameInPinyin rangeOfString:searchItem];
        NSValue * tempValue = [NSValue valueWithRange:myRange];
        [matchArr addObject:tempValue];
        return [matchArr autorelease];
    }
    if (searchItemPos<1) {
        [matchArr release];
        return nil;
    }
    return nil;
}

- (void)searchContactT9Single:(NSString *)searchItem Filter:(NSString *)filter otherPhoneNO:(BOOL)isSearch{
    NSMutableArray * result = [[NSMutableArray alloc] init];
    NSMutableArray * resultID = [[NSMutableArray alloc] init];
    NSString * searchItem1 = [[NSString alloc] initWithFormat:@"%%%c%%",[searchItem characterAtIndex:0]];
    NSArray* posArr;
    GetSearchDataObj *temp;
    ContactWithName * tempContactBriefInfo;
    int isFullMatch=0;
    int isContinuous=0;
    NSArray * resultBefFilter = [self.mySearchDBAccess getDataWithPrefixT9:searchItem1 Filter:filter otherPhoneNO:isSearch];
    [searchItem1 release];
    int countBefFilter=[resultBefFilter count];
    //正常非跳跃搜索
    for (int i=0; i<countBefFilter; i++) {
        temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:i];
        //前缀和拼音搜索
        NSNumber * contactIDInStr = [[[NSNumber alloc] initWithInt:temp.contactID] autorelease];
        //若已经在结果集了，就不在搜索contactID一样的记录   
        if ([resultID containsObject:contactIDInStr]) {
            continue;
        }
        posArr = matchStrSingleT9(temp.contactPinyinProperty,temp.contactPinyinLabel,temp.prefix,temp.contactPinyin,searchItem,&isFullMatch);
        if (nil!=posArr) {
            isContinuous=1;
            [resultID addObject:contactIDInStr];
            tempContactBriefInfo = [self.contactWithName objectForKey:contactIDInStr];
            temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
            if (4==temp.contactPinyinProperty) {
                temp.contactPinyin = [tempContactBriefInfo firstNotNullPhoOrMail];
            }
            else {
                temp.contactPinyinLabel = tempContactBriefInfo.pinyin;
            }
            temp.matchPos=posArr;
            temp.startPos=[[posArr objectAtIndex:0] rangeValue].location;
            temp.matchLen=[posArr count];
            temp.isPinyin=tempContactBriefInfo.isPinyin;
            temp.phoneArr = [tempContactBriefInfo phoneArr];
            temp.isFullMatch=isFullMatch;
            temp.isContinuous=isContinuous;
            [result addObject:temp];
        }
    }
    [resultID release];
    [result sortUsingSelector:@selector(compareName:)];
//发消息说最后查找完毕
    NSDictionary * dic = [[[NSDictionary alloc] initWithObjectsAndKeys:result,searchItem, nil] autorelease];
    [result release];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"T9SearchEnds" object:nil userInfo:dic];
}


- (NSArray *)searchContactT9:(NSString *)searchItem otherPhoneNO:(BOOL)isSearch{
    ccp_AddressLog(@"Search T9 Begins...");
    NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray * resultID = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray* posArr;
    GetSearchDataObj *temp;
    ContactWithName * tempContactBriefInfo;
    int isFullMatch=0;
    int isContinuous=0;
    NSArray * resultBefFilter;
    ccp_AddressLog(@"Get Data T9 Begins_...");
    if (1==[searchItem length])
    {
        NSMutableString * searchItemFirst = [[[NSMutableString alloc] initWithFormat:@"%c%%",[searchItem characterAtIndex:0]] autorelease];
        resultBefFilter = [self.mySearchDBAccess getDataWithPrefixT9First:searchItemFirst otherPhoneNO:isSearch];
        ccp_AddressLog(@"Get Data T9 Ends First...");
        NSMutableString * strFilter = [[[NSMutableString alloc] init] autorelease];
        int countFirst = [resultBefFilter count];
        for (int iFirst=0; iFirst<countFirst; iFirst++) {
            temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:iFirst];
            NSNumber * contactIDInStr = [NSNumber numberWithInt:temp.contactID];
            if ([resultID containsObject:contactIDInStr]) {
                continue;
            }
            [resultID addObject:contactIDInStr];
            tempContactBriefInfo = [self.contactWithName objectForKey:contactIDInStr];
            [strFilter appendFormat:@"%d,",temp.contactID];
            temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
            temp.phoneArr = [tempContactBriefInfo phoneArr];
            temp.contactPinyin = tempContactBriefInfo.firstNotNullPhoOrMail;
            temp.isPinyin = tempContactBriefInfo.isPinyin;
            temp.matchPos = [NSArray arrayWithObject:[NSValue valueWithRange:NSMakeRange(0, 1)]];
            [result addObject:temp];
        }
        if ([result count]<20) {
            for (int ii=1; ii<MaxSearchLength-5; ii++) {
                [searchItemFirst insertString:@"_" atIndex:searchItemFirst.length-2];
                if ([strFilter length]>0) {
                    resultBefFilter = [self.mySearchDBAccess getDataWithPrefixT9Sec:searchItemFirst Filter:[strFilter substringToIndex:[strFilter length]-1] otherPhoneNO:isSearch];
                }
                else {
                    resultBefFilter = [self.mySearchDBAccess getDataWithPrefixT9First:searchItemFirst otherPhoneNO:isSearch];
                }
                ccp_AddressLog(@"Get Data T9 Ends Second...");
                int countSec = [resultBefFilter count];
                for (int iSec=0; iSec<countSec; iSec++) {
                    temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:iSec];
                    NSNumber * contactIDNumber = [NSNumber numberWithInt:temp.contactID];
                    if ([resultID containsObject:contactIDNumber]) {
                        continue;
                    }
                    [resultID addObject:contactIDNumber];
                    [strFilter appendFormat:@"%d,",temp.contactID];
                    posArr = matchStrSingleT9(temp.contactPinyinProperty,temp.contactPinyinLabel,temp.prefix,temp.contactPinyin,searchItem,&isFullMatch);
                    if (nil!=posArr) {
                        tempContactBriefInfo = [self.contactWithName objectForKey:contactIDNumber];
                        temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
                        temp.phoneArr = [tempContactBriefInfo phoneArr];
                        temp.contactPinyin = tempContactBriefInfo.firstNotNullPhoOrMail;
                        temp.isPinyin = tempContactBriefInfo.isPinyin;
                        temp.matchPos=posArr;                       
                        [result addObject:temp];
                    }
                }
                if (result.count>20) {
                    break;
                }
            }
        }
        if (mySearchQueue) {
            dispatch_async(mySearchQueue, ^{
                if ([strFilter length]>0) {
                    [self searchContactT9Single:searchItem Filter:[strFilter substringToIndex:[strFilter length]-1] otherPhoneNO:isSearch];
                }
                else [self searchContactT9Single:searchItem Filter:@"999" otherPhoneNO:isSearch];
            });
        }
        else {
            mySearchQueue = dispatch_queue_create("MySearchQueue", NULL);
            dispatch_async(mySearchQueue, ^{
                if ([strFilter length]>0) {
                    [self searchContactT9Single:searchItem Filter:[strFilter substringToIndex:[strFilter length]-1] otherPhoneNO:isSearch];
                }
                else [self searchContactT9Single:searchItem Filter:@"999" otherPhoneNO:isSearch];
            });
        }
    }
    else { //输入关键字长度大于1
        if (2==[searchItem length]) {
            NSMutableString * newSearchItem = [[NSMutableString alloc] initWithFormat:@"%%"];
            for (int i=0; i<[searchItem length]; i++) {
                [newSearchItem appendFormat:@"%c%%",[searchItem characterAtIndex:i]];
            }
            NSString * searchItem1 = [[NSString alloc] initWithFormat:@"%@%%",searchItem];
            NSString * searchItem2 = [[NSString alloc] initWithFormat:@"%% %@%%",searchItem];
            NSString * searchItem3 = [[NSString alloc] initWithFormat:@"%c%% %c%%",[searchItem characterAtIndex:0],[searchItem characterAtIndex:1]];
            NSString * searchItem4 = [[NSString alloc] initWithFormat:@"%% %c%% %c%%",[searchItem characterAtIndex:0],[searchItem characterAtIndex:1]];
            NSString * searchItem5 = [[NSString alloc] initWithFormat:@"%%%@%%",searchItem];
            resultBefFilter = [self.mySearchDBAccess getDataT9:searchItem1 Sec:searchItem2 Third:searchItem3 Fourth:searchItem4 Fifth:searchItem5 Six:newSearchItem otherPhoneNO:isSearch];
            [searchItem1 release];
            [searchItem2 release];
            [searchItem3 release];
            [searchItem4 release];
            [searchItem5 release];
            [newSearchItem release];
        }
        else 
        {
            NSMutableString * newSearchItem = [[NSMutableString alloc] initWithFormat:@"%%"];
            for (int i=0; i<[searchItem length]; i++) 
            {
                [newSearchItem appendFormat:@"%c%%",[searchItem characterAtIndex:i]];
            }
            NSString * searchItem2 = [[NSString alloc] initWithFormat:@"%%%@%%",searchItem];
            resultBefFilter=[self.mySearchDBAccess getDataT9:newSearchItem Second:searchItem2 otherPhoneNO:isSearch];
            [newSearchItem release];
            [searchItem2 release];
        }
        ccp_AddressLog(@"Get Data T9 Ends...");
        
        int countBefFilter=[resultBefFilter count];
        //正常非跳跃搜索
        for (int i=0; i<countBefFilter; i++) {
            temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:i];
            NSNumber * contactIDInStr = [[[NSNumber alloc] initWithInt:temp.contactID] autorelease];  
            if ([resultID containsObject:contactIDInStr]) {
                continue;
            }
            posArr = matchStrT9(temp.contactPinyinProperty,temp.contactPinyinLabel,temp.prefix,temp.contactPinyin,searchItem,&isFullMatch);
            if (nil!=posArr) {
                isContinuous=1;
                [resultID addObject:contactIDInStr];
                tempContactBriefInfo = [self.contactWithName objectForKey:contactIDInStr];
                temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
                temp.phoneArr = [tempContactBriefInfo phoneArr];
                if (5==temp.contactPinyinProperty||4==temp.contactPinyinProperty) {
                    temp.contactPinyin = [tempContactBriefInfo firstNotNullPhoOrMail];
                }
                else {
                    temp.contactPinyinLabel = tempContactBriefInfo.pinyin;
                }
                temp.matchPos=posArr;
                temp.startPos=[[posArr objectAtIndex:0] rangeValue].location;
                temp.matchLen=[posArr count];
                temp.isPinyin=tempContactBriefInfo.isPinyin;
                temp.isFullMatch=isFullMatch;
                temp.isContinuous=isContinuous;
                [result addObject:temp];
            }
        }
        //开始跳跃搜索
        for (int i=0; i<countBefFilter; i++) {
            temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:i];
            //若是电话跳过，因为电话无跳跃搜索
            if (2==temp.contactPinyinProperty) {
                continue;
            }
            //若已经在结果集了，就不在搜索contactID一样的记录   
            NSNumber * contactIDInStr = [[[NSNumber alloc] initWithInt:temp.contactID] autorelease];
            if ([resultID containsObject:contactIDInStr]) {
                continue;
            }
            posArr = matchStrJumpT9(temp.contactPinyinProperty,temp.contactPinyinLabel,temp.prefix,temp.contactPinyin,searchItem);
            if (nil!=posArr) {
                isContinuous=0;
                isFullMatch=0;
                [resultID addObject:contactIDInStr];
                tempContactBriefInfo = [self.contactWithName objectForKey:contactIDInStr];
                temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
                temp.contactPinyin=[tempContactBriefInfo firstNotNullPhoOrMail];
                temp.phoneArr = [tempContactBriefInfo phoneArr];
                temp.matchPos=posArr;
                temp.startPos=[[posArr objectAtIndex:0] rangeValue].location;
                temp.matchLen=[posArr count];
                temp.isPinyin=tempContactBriefInfo.isPinyin;
                temp.isFullMatch=isFullMatch;
                temp.isContinuous=isContinuous;
                [result addObject:temp];
            }
        }
        //跳跃搜索结束
        ccp_AddressLog(@"Before sort!");
        [result sortUsingSelector:@selector(compareName:)];
        ccp_AddressLog(@"After sort!");
    }//输入关键字长度大于1
    ccp_AddressLog(@"Search T9 Ends...");
    [resultID release];
    return [result autorelease];
}//end of searchContact


//根据用户输入查找
- (NSArray *)searchContactT9:(NSString *)searchItem Range:(NSDictionary *)range {
    ccp_AddressLog(@"Search T9 Begins...");
    NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray * resultID = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray* posArr;
    GetSearchDataObj *temp;
    ContactWithName * tempContactBriefInfo;
    int isFullMatch=0;
    int isContinuous=0;
    NSArray * resultBefFilter;
    
    NSMutableString * strFilter = [[[NSMutableString alloc] init] autorelease];
    if (nil!=range) {
        for (NSString * key in [range allKeys]) {
            for (GetSearchDataObj * tempObj in [range objectForKey:key]) {
                [strFilter appendFormat:@"%d,",tempObj.contactID];
            }
        }
    }
    
    ccp_AddressLog(@"Get Data T9 Begins...");
    if (1==[searchItem length]) {
        NSString * searchItemFirst = [[NSString alloc] initWithFormat:@"%%%c%%",[searchItem characterAtIndex:0]];
        if ([strFilter length]>0) {
            resultBefFilter = [self.mySearchDBAccess getDataWithPrefixT9WithRange:searchItemFirst Range:[strFilter substringToIndex:[strFilter length] -1]];
        }
        else {
            resultBefFilter = [self.mySearchDBAccess getDataWithPrefixT9WithOutRange:searchItemFirst];
        }
        ccp_AddressLog(@"Get Data T9 Ends First...");
        [searchItemFirst release];
        int countFirst = [resultBefFilter count];
        for (int iFirst=0; iFirst<countFirst; iFirst++) {
            temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:iFirst];
            NSNumber * contactIDInStr = [NSNumber numberWithInt:temp.contactID];
            if ([resultID containsObject:contactIDInStr]) {
                continue;
            }
            [resultID addObject:contactIDInStr];
            posArr = matchStrSingleT9(temp.contactPinyinProperty,temp.contactPinyinLabel,temp.prefix,temp.contactPinyin,searchItem,&isFullMatch);
            if (nil!=posArr) {
                tempContactBriefInfo = [self.contactWithName objectForKey:contactIDInStr];
                temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
                temp.phoneArr = [tempContactBriefInfo phoneArr];
                temp.contactPinyin = tempContactBriefInfo.firstNotNullPhoOrMail;
                temp.isPinyin = tempContactBriefInfo.isPinyin;
                temp.matchPos=posArr;
                [result addObject:temp];
            }
        }
    }
    else { //输入关键字长度大于1
        if (2==[searchItem length]) {
            NSMutableString * newSearchItem = [[NSMutableString alloc] initWithFormat:@"%%"];
            for (int i=0; i<[searchItem length]; i++) {
                [newSearchItem appendFormat:@"%c%%",[searchItem characterAtIndex:i]];
            }
            NSString * searchItem1 = [[NSString alloc] initWithFormat:@"%@%%",searchItem];
            NSString * searchItem2 = [[NSString alloc] initWithFormat:@"%% %@%%",searchItem];
            NSString * searchItem3 = [[NSString alloc] initWithFormat:@"%c%% %c%%",[searchItem characterAtIndex:0],[searchItem characterAtIndex:1]];
            NSString * searchItem4 = [[NSString alloc] initWithFormat:@"%% %c%% %c%%",[searchItem characterAtIndex:0],[searchItem characterAtIndex:1]];
            NSString * searchItem5 = [[NSString alloc] initWithFormat:@"%%%@%%",searchItem];
            if ([strFilter length]>0) {
                resultBefFilter = [self.mySearchDBAccess getDataT9:searchItem1 Sec:searchItem2 Third:searchItem3 Fourth:searchItem4 Fifth:searchItem5 Six:newSearchItem Range:[strFilter substringToIndex:[strFilter length] -1]];
            } else {
                resultBefFilter = [self.mySearchDBAccess getDataT9:searchItem1 Sec:searchItem2 Third:searchItem3 Fourth:searchItem4 Fifth:searchItem5 Six:newSearchItem otherPhoneNO:NO];
            }
            
            [searchItem1 release];
            [searchItem2 release];
            [searchItem3 release];
            [searchItem4 release];
            [searchItem5 release];
            [newSearchItem release];
        }
        else {
            NSMutableString * newSearchItem = [[NSMutableString alloc] initWithFormat:@"%%"];
            for (int i=0; i<[searchItem length]; i++) {
                [newSearchItem appendFormat:@"%c%%",[searchItem characterAtIndex:i]];
            }
            NSString * searchItem2 = [[NSString alloc] initWithFormat:@"%%%@%%",searchItem];
            if ([strFilter length]>0) {
                resultBefFilter=[self.mySearchDBAccess getDataT9:newSearchItem Second:searchItem2 Range:[strFilter substringToIndex:[strFilter length]-1]];
            }
            else {
                resultBefFilter=[self.mySearchDBAccess getDataT9:newSearchItem Second:searchItem2 otherPhoneNO:NO];
            }
            [newSearchItem release];
            [searchItem2 release];
        }
        ccp_AddressLog(@"Get Data T9 Ends...");
        
        int countBefFilter=[resultBefFilter count];
        //正常非跳跃搜索
        for (int i=0; i<countBefFilter; i++) {
            temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:i];
            NSNumber * contactIDInStr = [[[NSNumber alloc] initWithInt:temp.contactID] autorelease];  
            if ([resultID containsObject:contactIDInStr]) {
                continue;
            }
            posArr = matchStrT9(temp.contactPinyinProperty,temp.contactPinyinLabel,temp.prefix,temp.contactPinyin,searchItem,&isFullMatch);
            if (nil!=posArr) {
                isContinuous=1;
                [resultID addObject:contactIDInStr];
                tempContactBriefInfo = [self.contactWithName objectForKey:contactIDInStr];
                temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
                temp.phoneArr = [tempContactBriefInfo phoneArr];
                if (5==temp.contactPinyinProperty||4==temp.contactPinyinProperty) {
                    temp.contactPinyin = [tempContactBriefInfo firstNotNullPhoOrMail];
                }
                else {
                    temp.contactPinyinLabel = tempContactBriefInfo.pinyin;
                }
                temp.matchPos=posArr;
                temp.startPos=[[posArr objectAtIndex:0] rangeValue].location;
                temp.matchLen=[posArr count];
                temp.isPinyin=tempContactBriefInfo.isPinyin;
                temp.isFullMatch=isFullMatch;
                temp.isContinuous=isContinuous;
                [result addObject:temp];
            }
        }
//开始跳跃搜索
        for (int i=0; i<countBefFilter; i++) {
            temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:i];
//若是电话跳过，因为电话无跳跃搜索
            if (2==temp.contactPinyinProperty) {
                continue;
            }
//若已经在结果集了，就不在搜索contactID一样的记录   
            NSNumber * contactIDInStr = [[[NSNumber alloc] initWithInt:temp.contactID] autorelease];
            if ([resultID containsObject:contactIDInStr]) {
                continue;
            }
            posArr = matchStrJumpT9(temp.contactPinyinProperty,temp.contactPinyinLabel,temp.prefix,temp.contactPinyin,searchItem);
            if (nil!=posArr) {
                isContinuous=0;
                isFullMatch=0;
                [resultID addObject:contactIDInStr];
                tempContactBriefInfo = [self.contactWithName objectForKey:contactIDInStr];
                temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
                temp.phoneArr = [tempContactBriefInfo phoneArr];
                temp.contactPinyin=[tempContactBriefInfo firstNotNullPhoOrMail];
                temp.matchPos=posArr;
                temp.startPos=[[posArr objectAtIndex:0] rangeValue].location;
                temp.matchLen=[posArr count];
                temp.isPinyin=tempContactBriefInfo.isPinyin;
                temp.isFullMatch=isFullMatch;
                [result addObject:temp];
            }
        }
        //跳跃搜索结束
    }//输入关键字长度大于1
    ccp_AddressLog(@"Search T9 Ends...");
    [resultID release];
    ccp_AddressLog(@"Before sort!");
    [result sortUsingSelector:@selector(compareName:)];
    ccp_AddressLog(@"After sort!");
    return [result autorelease];
}//end of searchContact


//keyboard:0普通键盘，1T9键盘，2数字键盘
- (NSArray *)search:(NSString *)searchItem keyboard:(int)keyboard Range:(NSDictionary *)range{
    if (0==[searchItem length]) {
        return nil;
    }
    NSString *searchItemLower = [searchItem lowercaseString];
    if (OriginalKeyboard == keyboard) {
        return [self searchContact:searchItemLower Range:range];
    }
    else if (T9Keyboard == keyboard) {
        //若含有0/1，则将输入作为数字处理，只搜索电话号码
        if (NSNotFound != [searchItemLower rangeOfString:@"0"].location || NSNotFound != [searchItemLower rangeOfString:@"1"].location) {
            return [self searchContactNumberBatch:searchItemLower Range:range];
        }
        return [self searchContactT9:searchItemLower Range:range];
    }
    else if (NumberKeyboard == keyboard) {
        return [self searchContactNumberBatch:searchItemLower Range:range];
    }
    else {
        ccp_AddressLog(@"不支持此键盘类型，请选择正确的键盘类型!");
        return nil;
    }
}

//keyboard:0普通键盘，1T9键盘，2数字键盘
- (NSArray *)search:(NSString *)searchItem keyboard:(int)keyboard otherPhoneNO:(BOOL)isSearch{
    if (0==[searchItem length]) {
        return nil;
    }
    NSString *searchItemLower = [searchItem lowercaseString];
    if (OriginalKeyboard == keyboard) {
        return [self searchContact:searchItemLower Range:nil];
    }
    else if (T9Keyboard == keyboard) {
        //若含有0/1，则将输入作为数字处理，只搜索电话号码
        if (NSNotFound != [searchItemLower rangeOfString:@"0"].location || NSNotFound != [searchItemLower rangeOfString:@"1"].location) {
            return [self searchContactNumberBatch:searchItemLower otherPhoneNO:isSearch];
        }
        return [self searchContactT9:searchItemLower otherPhoneNO:isSearch];
    }
    else if (NumberKeyboard == keyboard) {
        return [self searchContactNumberBatch:searchItemLower otherPhoneNO:isSearch];
    }
    else {
        ccp_AddressLog(@"不支持此键盘类型，请选择正确的键盘类型!");
        return nil;
    }
}

- (NSString *)getFirstNotNullPhoOrEmailForUI:(int)recordID {
    ABAddressBookRef localAddreddbook = ABAddressBookCreate();
    ABRecordRef localRecord = ABAddressBookGetPersonWithRecordID(localAddreddbook, recordID);
    if (localRecord) {
        NSString * forReturn = [self getFirstNotNullPhoOrEmail:localRecord];
        CFRelease(localAddreddbook);
        return forReturn;
    }
    CFRelease(localAddreddbook);
    return nil;
}

- (NSString *)getFirstNotNullPhoOrEmail:(ABRecordRef)record {
    CFRetain(record);
    ABMutableMultiValueRef phone = ABRecordCopyValue(record, kABPersonPhoneProperty);
    NSInteger phoneCount = ABMultiValueGetCount(phone);
    for (int i=0; i<phoneCount; i++) {
        CFStringRef tempStr = ABMultiValueCopyLabelAtIndex(phone, i);
        NSString * personPhoneLabel = (NSString *)ABAddressBookCopyLocalizedLabel(tempStr);
        if (tempStr) {
            CFRelease(tempStr);
        }
        NSString * oldPho = (NSString *)ABMultiValueCopyValueAtIndex(phone, i);
        NSString * personPhone = cleanPhoneNo(oldPho);
        [personPhoneLabel release];
        [oldPho release];
        if (personPhone!=nil) {
            CFRelease(record);
            CFRelease(phone);
            return personPhone;
        }
    }
    CFRelease(phone);
//电话全部为空
    ABMutableMultiValueRef mail = ABRecordCopyValue(record, kABPersonEmailProperty);
    NSInteger mailCount = ABMultiValueGetCount(mail);
    for (int i=0; i<mailCount; i++) {
        CFStringRef tempStr = ABMultiValueCopyLabelAtIndex(mail, i);
        NSString * personMailLabel = (NSString *)ABAddressBookCopyLocalizedLabel(tempStr);
        if (tempStr) {
            CFRelease(tempStr);
        }
        NSString * mailContent = (NSString *)ABMultiValueCopyValueAtIndex(mail, i);
        [personMailLabel release];
        if (mailContent!=nil) {
            CFRelease(record);
            CFRelease(mail);
            return [mailContent autorelease];
        }
    }
    CFRelease(mail);
    CFRelease(record);
    return nil;
}




//根据用户输入查找
- (NSArray *)searchContact:(NSString *)searchItem Range:(NSDictionary *)range{
    ccp_AddressLog(@"Search Begins...");
    NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray * resultID = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray* posArr;
    GetSearchDataObj *temp;
    ContactWithName * tempContactBriefInfo;
    int isFullMatch=0;
    int isContinuous=0;
    NSArray * resultBefFilter;
    NSMutableString * strFilter = [[[NSMutableString alloc] init] autorelease];
    if (nil!=range) {
        for (NSString * key in [range allKeys]) {
            for (GetSearchDataObj * tempObj in [range objectForKey:key]) {
                [strFilter appendFormat:@"%d,",tempObj.contactID];
            }
        }
    }
    
    ccp_AddressLog(@"Get Data Begins...");
    if (1==[searchItem length]) {
        searchItem = [searchItem uppercaseString];
        NSString * searchItem1 = [[NSString alloc] initWithFormat:@"%%%c%%",[searchItem characterAtIndex:0]];
        if ([strFilter length]>0) {
            resultBefFilter = [self.mySearchDBAccess getDataWithPrefix:searchItem1 Range:[strFilter substringToIndex:[strFilter length] - 1]];
        }
        else {
            resultBefFilter = [self.mySearchDBAccess getDataWithPrefix:searchItem1];
        }
        ccp_AddressLog(@"Get Data Ends...");
        [searchItem1 release];
        int countBefFilter=[resultBefFilter count];
        for (int i=0; i<countBefFilter; i++) {
            temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:i];
            NSNumber * contactIDInStr = [[[NSNumber alloc] initWithInt:temp.contactID] autorelease];
            //若已经在结果集了，就不在搜索contactID一样的记录   
            if ([resultID containsObject:contactIDInStr]) {
                continue;
            }
            posArr = matchStrSingle(temp.contactPinyinProperty,temp.contactPinyinLabel,temp.contactPinyin,searchItem,&isFullMatch);
            if (nil!=posArr) {
                isContinuous=1;
                [resultID addObject:contactIDInStr];
                tempContactBriefInfo = [self.contactWithName objectForKey:contactIDInStr];
                temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
                temp.contactPinyin = [tempContactBriefInfo firstNotNullPhoOrMail];
                temp.phoneArr = [tempContactBriefInfo phoneArr];
                temp.matchPos=posArr;
                temp.startPos=[[posArr objectAtIndex:0] rangeValue].location;
                temp.matchLen=[posArr count];
                temp.isPinyin=tempContactBriefInfo.isPinyin;
                temp.isFullMatch=isFullMatch;
                temp.isContinuous=isContinuous;
                [result addObject:temp];
            }
        }
    }
    else { //输入关键字长度大于1
        if (2==[searchItem length]) {
            NSString * searchItem1 = [[NSString alloc] initWithFormat:@"%@%%",searchItem];
            NSString * searchItem2 = [[NSString alloc] initWithFormat:@"%% %@%%",searchItem];
            NSString * searchItem3 = [[NSString alloc] initWithFormat:@"%c%% %c%%",[searchItem characterAtIndex:0],[searchItem characterAtIndex:1]];
            NSString * searchItem4 = [[NSString alloc] initWithFormat:@"%% %c%% %c%%",[searchItem characterAtIndex:0],[searchItem characterAtIndex:1]];
            //匹配邮箱
            NSString * searchItem5 = [[NSString alloc] initWithFormat:@"%%%@%%",searchItem];
            //首字母
            NSString * searchItem6 = [[NSString alloc] initWithFormat:@"%%%c%%%c%%",[[searchItem uppercaseString] characterAtIndex:0],[[searchItem uppercaseString] characterAtIndex:1]];
            if ([strFilter length]>0) {
                resultBefFilter = [self.mySearchDBAccess getData:searchItem1 Sec:searchItem2 Third:searchItem3 Fourth:searchItem4 Fifth:searchItem5 Sixth:searchItem6 Range:[strFilter substringToIndex:[strFilter length] -1]];
            } else {
                resultBefFilter = [self.mySearchDBAccess getData:searchItem1 Sec:searchItem2 Third:searchItem3 Fourth:searchItem4 Fifth:searchItem5 Sixth:searchItem6];
            }
            ccp_AddressLog(@"Get Data Ends...");
            [searchItem1 release];
            [searchItem2 release];
            [searchItem3 release];
            [searchItem4 release];
            [searchItem5 release];
            [searchItem6 release];
        }
        else {
            NSMutableString * newSearchItem = [[NSMutableString alloc] initWithFormat:@"%%"];
            for (int i=0; i<[searchItem length]; i++) {
                [newSearchItem appendFormat:@"%c%%",[searchItem characterAtIndex:i]];
            }
            NSString * searchItem2 = [[NSString alloc] initWithFormat:@"%%%@%%",searchItem];
            NSString * searchItem3 = [[NSString alloc] initWithString:[searchItem2 uppercaseString]];
            if ([strFilter length]>0) {
                resultBefFilter=[self.mySearchDBAccess getData:newSearchItem Second:searchItem2 Third:searchItem3 Range:[strFilter substringToIndex:[strFilter length] -1]];
            } else {
                resultBefFilter=[self.mySearchDBAccess getData:newSearchItem Second:searchItem2 Third:searchItem3];
            }
            [newSearchItem release];
            [searchItem2 release];
            [searchItem3 release];
        }
        ccp_AddressLog(@"Get Data Ends...");
        
        int countBefFilter=[resultBefFilter count];
//正常非跳跃搜索
        for (int i=0; i<countBefFilter; i++) {
            temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:i];
            NSNumber * contactIDInStr = [[[NSNumber alloc] initWithInt:temp.contactID] autorelease];
//若已经在结果集了，就不在搜索contactID一样的记录   
            if ([resultID containsObject:contactIDInStr]) {
                continue;
            }
            posArr = matchStr(temp.contactPinyinProperty,temp.contactPinyinLabel,temp.contactPinyin,searchItem,&isFullMatch);
            if (nil!=posArr) {
                isContinuous=1;
                [resultID addObject:contactIDInStr];
                tempContactBriefInfo = [self.contactWithName objectForKey:contactIDInStr];
                temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
                if (1==temp.contactPinyinProperty||0==temp.contactPinyinProperty) {
                    temp.contactPinyin = [tempContactBriefInfo firstNotNullPhoOrMail];
                }
                else {
                    temp.contactPinyinLabel = tempContactBriefInfo.pinyin;
                }
                temp.matchPos=posArr;
                temp.phoneArr = [tempContactBriefInfo phoneArr];
                temp.startPos=[[posArr objectAtIndex:0] rangeValue].location;
                temp.matchLen=[posArr count];
                temp.isPinyin=tempContactBriefInfo.isPinyin;
                temp.isFullMatch=isFullMatch;
                temp.isContinuous=isContinuous;
                [result addObject:temp];
            }
        }
        
    //正常非跳跃搜索结束
    //开始跳跃搜索
        for (int i=0; i<countBefFilter; i++) {
            temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:i];
            NSNumber * contactIDInStr = [[[NSNumber alloc] initWithInt:temp.contactID] autorelease];
            //若已经在结果集了，就不在搜索contactID一样的记录   
            if ([resultID containsObject:contactIDInStr]) {
                continue;
            }
            posArr = matchStrJump(temp.contactPinyinProperty,temp.contactPinyinLabel,temp.contactPinyin,searchItem);
            if (nil!=posArr) {
                isContinuous=0;
                isFullMatch=0;
                [resultID addObject:contactIDInStr];
                tempContactBriefInfo = [self.contactWithName objectForKey:contactIDInStr];
                temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
                if (1==temp.contactPinyinProperty||0==temp.contactPinyinProperty) {
                    temp.contactPinyin=[tempContactBriefInfo firstNotNullPhoOrMail];
                }
                else {
                    temp.contactPinyinLabel = tempContactBriefInfo.pinyin;
                }
                temp.phoneArr = [tempContactBriefInfo phoneArr];
                temp.matchPos=posArr;
                temp.startPos=[[posArr objectAtIndex:0] rangeValue].location;
                temp.matchLen=[posArr count];
                temp.isPinyin=tempContactBriefInfo.isPinyin;
                temp.isFullMatch=isFullMatch;
                temp.isContinuous=isContinuous;
                [result addObject:temp];
            }
        }
    //跳跃搜索结束
    }
    ccp_AddressLog(@"Search Ends...");
    [result sortUsingSelector:@selector(compareName:)];
    [resultID release];
    return [result autorelease];
}//end of searchContact

- (void)searchContactNumberFinal:(NSString *)searchItem Filter:(NSString *)filter  otherPhoneNO:(BOOL)isSearch{
    NSMutableArray * result = [[NSMutableArray alloc] init];
    NSMutableArray * resultID = [[NSMutableArray alloc] init];
    GetSearchDataObj *temp;
    ContactWithName * tempContactBriefInfo;
    int isContinuous=0;
    NSArray * resultBefFilter;
    ccp_AddressLog(@"Get Data Number Begins... in func %s",__func__);
    NSString * searchItem1 = [[NSString alloc] initWithFormat:@"%%%c%%",[searchItem characterAtIndex:0]];
    resultBefFilter = [self.mySearchDBAccess getDataWithNumber:searchItem1 Filter:filter otherPhoneNO:isSearch];
    ccp_AddressLog(@"Get Data Number Ends... in func %s",__func__);
    [searchItem1 release];
    int countBefFilter=[resultBefFilter count];
    for (int i=0; i<countBefFilter; i++) {
        temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:i];
        NSNumber * contactIDInStr = [NSNumber numberWithInt:temp.contactID];
        if ([resultID containsObject:contactIDInStr]) {
            continue;
        }
        if (NSNotFound!=[temp.contactPinyin rangeOfString:searchItem].location) {
            NSArray* posArr = [NSArray arrayWithObject:[NSValue valueWithRange:[temp.contactPinyin rangeOfString:searchItem]]];
            isContinuous=1;
            [resultID addObject:contactIDInStr];
            tempContactBriefInfo = [self.contactWithName objectForKey:contactIDInStr];
            temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
            temp.phoneArr = [tempContactBriefInfo phoneArr];
            temp.contactPinyinLabel = tempContactBriefInfo.pinyin;
            temp.matchPos=posArr;
            temp.startPos=[[posArr objectAtIndex:0] rangeValue].location;
            temp.matchLen=[posArr count];
            temp.isFullMatch=([temp.contactPinyin length]==[searchItem length]?1:0);
            temp.isContinuous=isContinuous;
            [result addObject:temp];
            
        }  
    }
    ccp_AddressLog(@"Search Number Ends... in func %s",__func__);
    [resultID release];
    [result sortUsingSelector:@selector(compareName:)];
    NSDictionary * dic = [[[NSDictionary alloc] initWithObjectsAndKeys:result,searchItem, nil] autorelease];
    [result release];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"T9SearchEnds" object:nil userInfo:dic];
}


/*号码搜索第二批搜索数据
 *range为搜索的范围
 *filter为需要过滤的联系人ID
 */
- (void)searchContactNumberBatchFinal:(NSString *)searchItem Range:(NSString *)range Filter:(NSString *)filter {
    NSMutableArray * result = [[NSMutableArray alloc] init];
    NSMutableArray * resultID = [[NSMutableArray alloc] init];
    GetSearchDataObj *temp;
    ContactWithName * tempContactBriefInfo;
    int isContinuous=0;
    NSArray * resultBefFilter;
    ccp_AddressLog(@"Get Data Number Begins... in func %s",__func__);
    NSString * searchItem1 = [[NSString alloc] initWithFormat:@"%%%@%%",searchItem];
    resultBefFilter = [self.mySearchDBAccess getDataWithNumber:searchItem1 WithRange:range WithFilter:filter];
    ccp_AddressLog(@"Get Data Number Ends... in func %s",__func__);
    [searchItem1 release];
    int countBefFilter=[resultBefFilter count];
    for (int i=0; i<countBefFilter; i++) {
        temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:i];
        NSNumber * contactIDInStr = [NSNumber numberWithInt:temp.contactID];
        if ([resultID containsObject:contactIDInStr]) {
            continue;
        }
        if (NSNotFound!=[temp.contactPinyin rangeOfString:searchItem].location) {
            NSArray* posArr = [NSArray arrayWithObject:[NSValue valueWithRange:[temp.contactPinyin rangeOfString:searchItem]]];
            isContinuous=1;
            [resultID addObject:contactIDInStr];
            tempContactBriefInfo = [self.contactWithName objectForKey:contactIDInStr];
            temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
            temp.phoneArr = [tempContactBriefInfo phoneArr];
            temp.contactPinyinLabel = tempContactBriefInfo.pinyin;
            temp.matchPos=posArr;
            temp.startPos=[[posArr objectAtIndex:0] rangeValue].location;
            temp.matchLen=[posArr count];
            temp.isFullMatch=([temp.contactPinyin length]==[searchItem length]?1:0);
            temp.isContinuous=isContinuous;
            [result addObject:temp];
            
        }
    }
    ccp_AddressLog(@"Search Number Ends... in func %s",__func__);
    [resultID release];
    [result sortUsingSelector:@selector(compareName:)];
    NSDictionary * dic = [[[NSDictionary alloc] initWithObjectsAndKeys:result,searchItem, nil] autorelease];
    [result release];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"T9SearchEnds" object:nil userInfo:dic];
}



//分批传数据搜索
- (NSArray *)searchContactNumberBatch:(NSString *)searchItem Range:(NSDictionary *) dic{
    ccp_AddressLog(@"Search Number Begins...");
    NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray * resultID = [[NSMutableArray alloc] initWithCapacity:1];
    GetSearchDataObj *temp;
    ContactWithName * tempContactBriefInfo;
    int isContinuous=0;
    NSArray * resultBefFilter;
    NSMutableString *strRange = [[[NSMutableString alloc] init] autorelease];
    NSMutableString * strFilter = [[[NSMutableString alloc] init] autorelease];
    if (nil!=dic) {
        for (NSString * key in [dic allKeys]) {
            for (GetSearchDataObj * tempObj in [dic objectForKey:key]) {
                [strFilter appendFormat:@"%d,",tempObj.contactID];
            }
        }
    }
    
    ccp_AddressLog(@"Get Data Number Begins...");
    if ([searchItem length] > 0) {
        NSString * searchItemFirst = [[NSString alloc] initWithFormat:@"%%%@%%",searchItem];
        if ([strFilter length]>0) {
            resultBefFilter = [self.mySearchDBAccess getDataWithNumberFirst:searchItemFirst Range:[strFilter substringToIndex:[strFilter length] -1 ]];
        } else {
            resultBefFilter = [self.mySearchDBAccess getDataWithNumberFirst:searchItemFirst Range:nil];
        }
        [searchItemFirst release];
        
        int countFirst = [resultBefFilter count];
        for (int iFirst=0; iFirst<countFirst; iFirst++) {
            temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:iFirst];
            NSNumber * contactIDInStr = [NSNumber numberWithInt:temp.contactID];
            if ([resultID containsObject:contactIDInStr]) {
                continue;
            }
            if (NSNotFound!=[temp.contactPinyin rangeOfString:searchItem].location) {
                NSArray* posArr = [NSArray arrayWithObject:[NSValue valueWithRange:[temp.contactPinyin rangeOfString:searchItem]]];
                isContinuous=1;
                [resultID addObject:contactIDInStr];
                tempContactBriefInfo = [self.contactWithName objectForKey:contactIDInStr];
                [strRange appendFormat:@"%d,",temp.contactID];
                temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
                temp.phoneArr = [tempContactBriefInfo phoneArr];
                temp.contactPinyinLabel = tempContactBriefInfo.pinyin;
                temp.matchPos=posArr;
                temp.startPos=[[posArr objectAtIndex:0] rangeValue].location;
                temp.matchLen=1;
                temp.isFullMatch=([temp.contactPinyin length]==[searchItem length]?1:0);
                temp.isContinuous=isContinuous;
                [result addObject:temp];
            }
        }
    
    if (mySearchQueue) {
        dispatch_async(mySearchQueue, ^{
            if ([strRange length]>0) {
                [self searchContactNumberBatchFinal:searchItem Range:[strFilter substringToIndex:[strFilter length] -1 ] Filter:[strRange substringToIndex:strRange.length-1]];
            }
            else {
                [self searchContactNumberBatchFinal:searchItem Range:[strFilter substringToIndex:[strFilter length] -1 ] Filter:nil];
            }
        });
    }
    else {
        mySearchQueue = dispatch_queue_create("MySearchQueue", NULL);
        dispatch_async(mySearchQueue, ^{
            if ([strRange length]>0) {
                [self searchContactNumberBatchFinal:searchItem Range:[strFilter substringToIndex:[strFilter length] -1 ] Filter:[strRange substringToIndex:strRange.length-1]];
            }
            else {
                [self searchContactNumberBatchFinal:searchItem Range:[strFilter substringToIndex:[strFilter length] -1 ] Filter:nil];
            }
        });
    }
    }
    
    
    [resultID release];
    [result sortUsingSelector:@selector(compareName:)];
    return [result autorelease];
}

//分批传数据搜索
- (NSArray *)searchContactNumberBatch:(NSString *)searchItem otherPhoneNO:(BOOL)isSearch{
    ccp_AddressLog(@"Search Number Begins...");
    NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray * resultID = [[NSMutableArray alloc] initWithCapacity:1];
    GetSearchDataObj *temp;
    ContactWithName * tempContactBriefInfo;
    int isContinuous=0;
    NSArray * resultBefFilter;
    NSMutableString * strFilter = [[[NSMutableString alloc] init] autorelease];    
    ccp_AddressLog(@"Get Data Number Begins...");
    if ([searchItem length]==1) {
        NSMutableString * searchItemFirst = [[[NSMutableString alloc] init] autorelease];
        for (int i=0; i<MaxSearchLength; i++) {
            if (0==i) {
                [searchItemFirst appendFormat:@"%c%%",[searchItem characterAtIndex:0]];
            }
            else {
                [searchItemFirst insertString:@"_" atIndex:searchItemFirst.length-2];
            }
            resultBefFilter = [self.mySearchDBAccess getDataWithNumberBatch:searchItemFirst otherPhoneNO:isSearch];
            
            int countFirst = [resultBefFilter count];
            for (int iFirst=0; iFirst<countFirst; iFirst++) {
                temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:iFirst];
                NSNumber * contactIDInStr = [NSNumber numberWithInt:temp.contactID];
                if ([resultID containsObject:contactIDInStr]) {
                    continue;
                }
                [resultID addObject:contactIDInStr];
                tempContactBriefInfo = [self.contactWithName objectForKey:contactIDInStr];
                [strFilter appendFormat:@"%d,",temp.contactID];
                temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
                temp.contactPinyinLabel = tempContactBriefInfo.pinyin;
                temp.phoneArr = [tempContactBriefInfo phoneArr];
                temp.matchPos = [NSArray arrayWithObject:[NSValue valueWithRange:NSMakeRange(i, 1)]];
                [result addObject:temp];
            }
            if (result.count>20) {
                break;
            }
        }
        if (mySearchQueue) {
            dispatch_async(mySearchQueue, ^{
                if ([strFilter length]>0) {
                    [self searchContactNumberFinal:searchItem Filter:[strFilter substringToIndex:[strFilter length]-1] otherPhoneNO:isSearch];
                } 
                else {
                    [self searchContactNumberFinal:searchItem Filter:nil otherPhoneNO:isSearch];
                }
            });
        }
        else {
            mySearchQueue = dispatch_queue_create("MySearchQueue", NULL);
            dispatch_async(mySearchQueue, ^{
                if ([strFilter length]>0) {
                    [self searchContactNumberFinal:searchItem Filter:[strFilter substringToIndex:[strFilter length]-1] otherPhoneNO:isSearch];
                } 
                else {
                    [self searchContactNumberFinal:searchItem Filter:nil otherPhoneNO:isSearch];
                }
            });
        }
    }
    else {
        NSString * searchItem1 = [[NSString alloc] initWithFormat:@"%%%@%%",searchItem];
        resultBefFilter = [self.mySearchDBAccess getDataWithNumber:searchItem1 otherPhoneNO:isSearch];
        ccp_AddressLog(@"Get Data Number Ends...");
        [searchItem1 release];
        int countBefFilter=[resultBefFilter count];
        for (int i=0; i<countBefFilter; i++) {
            temp = (GetSearchDataObj *)[resultBefFilter objectAtIndex:i];
            NSNumber * contactIDInStr = [[[NSNumber alloc] initWithInt:temp.contactID] autorelease];
            if ([resultID containsObject:contactIDInStr]) {              
                continue;
            }
            if (NSNotFound!=[temp.contactPinyin rangeOfString:searchItem].location) {
                NSArray* posArr = [NSArray arrayWithObject:[NSValue valueWithRange:[temp.contactPinyin rangeOfString:searchItem]]];
                isContinuous=1;
                [resultID addObject:contactIDInStr];
                tempContactBriefInfo = [self.contactWithName objectForKey:contactIDInStr];
                temp.contactName = 0!=tempContactBriefInfo.name.length?tempContactBriefInfo.name:(0!=tempContactBriefInfo.firstNotNullPhoOrMail.length?tempContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
                temp.phoneArr = [tempContactBriefInfo phoneArr];
                temp.contactPinyinLabel = tempContactBriefInfo.pinyin;
                temp.matchPos=posArr;
                temp.startPos=[[posArr objectAtIndex:0] rangeValue].location;
                temp.matchLen=[posArr count];               
                temp.isFullMatch=([temp.contactPinyin length]==[searchItem length]?1:0);
                temp.isContinuous=isContinuous;
                [result addObject:temp];
                
            }  
        }
        ccp_AddressLog(@"Search Number Ends...");
        [result sortUsingSelector:@selector(compareName:)];
    }
    [resultID release];
    return [result autorelease];
}

- (NSString *)compositeString:(NSString *)first Mid:(NSString *)second Last:(NSString *)third {
    NSMutableString * composite =[[[NSMutableString alloc] init] autorelease];
    (nil!=third?[composite appendString:third]:nil);
    (nil!=second?[composite appendString:second]:nil);
    (nil!=first?[composite appendString:first]:nil);
    return (0!=[composite length]?composite:nil);
}

- (AddressBookContactSearchResult *)getContactByID:(ABRecordID) recordID {
    AddressBookContactSearchResult * theContact = [[[AddressBookContactSearchResult alloc] init] autorelease];
    ABAddressBookRef localAddressBook = ABAddressBookCreate();
    ABRecordRef theIphoneContact = ABAddressBookGetPersonWithRecordID(localAddressBook, recordID);
    if (theIphoneContact) {
        theContact.contactID = recordID;
        NSString * tempFirstname = (NSString *)ABRecordCopyValue(theIphoneContact, kABPersonFirstNameProperty);
        theContact.firstname = tempFirstname;
        [tempFirstname release];
        NSString * tempLastname = (NSString *)ABRecordCopyValue(theIphoneContact, kABPersonLastNameProperty);
        theContact.lastname = tempLastname;
        [tempLastname release];
        NSString * tempMiddlename = (NSString *)ABRecordCopyValue(theIphoneContact, kABPersonMiddleNameProperty);
        theContact.middlename = tempMiddlename;
        [tempMiddlename release];        
        theContact.contactName=[self compositeString:theContact.firstname Mid:theContact.middlename Last:theContact.lastname];        
        NSString * tempDisplayName = (NSString *)ABRecordCopyCompositeName(theIphoneContact);
        theContact.displayName = tempDisplayName;
        [tempDisplayName release];
        
        NSString * tempPrefix = (NSString *)ABRecordCopyValue(theIphoneContact, kABPersonPrefixProperty);
        theContact.prefix = tempPrefix;
        [tempPrefix release];
        
        NSString * tempSuffix = (NSString *)ABRecordCopyValue(theIphoneContact, kABPersonSuffixProperty);
        theContact.suffix = tempSuffix;
        [tempSuffix release];
        
        NSString * tempNickname = (NSString *)ABRecordCopyValue(theIphoneContact, kABPersonNicknameProperty);
        theContact.nickname = tempNickname;
        [tempNickname release];
        
        NSString * tempFirstnamePhonetic = (NSString *)ABRecordCopyValue(theIphoneContact, kABPersonFirstNamePhoneticProperty);
        theContact.firstNamePhonetic = tempFirstnamePhonetic;
        [tempFirstnamePhonetic release];
        
        NSString * tempLastnamePhontic = (NSString *)ABRecordCopyValue(theIphoneContact, kABPersonLastNamePhoneticProperty);
        theContact.lastNamePhonetic = tempLastnamePhontic;
        [tempLastnamePhontic release];
        
        NSString * tempMiddlenamePhonetic = (NSString *)ABRecordCopyValue(theIphoneContact, kABPersonMiddleNamePhoneticProperty);
        theContact.middleNamePhonetic = tempMiddlenamePhonetic;
        [tempMiddlenamePhonetic release];
        
        NSString * tempCompany = (NSString *)ABRecordCopyValue(theIphoneContact, kABPersonOrganizationProperty);
        theContact.company = tempCompany;
        [tempCompany release];
        
        NSString * tempJobtitle = (NSString *)ABRecordCopyValue(theIphoneContact, kABPersonJobTitleProperty);
        theContact.jobTitle = tempJobtitle;
        [tempJobtitle release];
        
        NSString * tempDepartment = (NSString *)ABRecordCopyValue(theIphoneContact, kABPersonDepartmentProperty);
        theContact.department = tempDepartment;
        [tempDepartment release];
        ParseType * parser = [[ParseType alloc] init];        
        NSDate * tempDate = (NSDate *)ABRecordCopyValue(theIphoneContact, kABPersonBirthdayProperty);
        NSString * tempBirthday = [parser dateToString:tempDate format:@"yyyyMMdd"];
        if (tempDate) {
            CFRelease(tempDate);
        }
        theContact.birthday = tempBirthday;
        
        NSString * tempNote = (NSString *)ABRecordCopyValue(theIphoneContact, kABPersonNoteProperty);
        theContact.note = tempNote;
        [tempNote release];
        // portrait
        CFDataRef imageData;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=4) {
            imageData = ABPersonCopyImageDataWithFormat(theIphoneContact, kABPersonImageFormatThumbnail);
        }
        else {
            imageData = ABPersonCopyImageData(theIphoneContact);
        }
        
        theContact.portrait = (NSData *)imageData;
        
        if (imageData)
        {
            CFRelease(imageData);
        }
        
        
        //多值
        /*暂定这样，
         *其实也可以将每一个label、value对存到一个dictionary里，然后将字典加到array里。
         *但若那样得反复的对dictionary进行alloc和release，可能对效率有一定的影响。
         */
        // phone
        ABMutableMultiValueRef localPhone = ABRecordCopyValue(theIphoneContact, kABPersonPhoneProperty);
        NSInteger phoneCount = ABMultiValueGetCount(localPhone);
        NSMutableArray * tempPhoneArr = [[NSMutableArray alloc] init];
        for (int i=0; i<phoneCount; i++) {
            CFStringRef tempStr = ABMultiValueCopyLabelAtIndex(localPhone, i);
            NSString * phoneLabel = (NSString *)ABAddressBookCopyLocalizedLabel(tempStr);
            NSString * phoneNo = (NSString *)ABMultiValueCopyValueAtIndex(localPhone, i);
            NSString * phoneAfterClean = cleanPhoneNo(phoneNo); 
            if (nil!=phoneAfterClean) {
                [tempPhoneArr addObject:phoneLabel];
                [tempPhoneArr addObject:phoneAfterClean];
            }
            if (tempStr) {
                CFRelease(tempStr);
            }
            
            [phoneLabel release];
            [phoneNo release];
        }
        theContact.phoneArray = tempPhoneArr;
        [tempPhoneArr release];
        CFRelease(localPhone);
        // email
        ABMutableMultiValueRef localEmail = ABRecordCopyValue(theIphoneContact, kABPersonEmailProperty);
        NSInteger emailCount = ABMultiValueGetCount(localEmail);
        NSMutableArray * tempMailArr = [[NSMutableArray alloc] init];
        for (int i=0; i<emailCount; i++) {
            CFStringRef tempStr = ABMultiValueCopyLabelAtIndex(localEmail, i);
            NSString * mailLabel = (NSString *)ABAddressBookCopyLocalizedLabel(tempStr);
            NSString * mailValue = (NSString *)ABMultiValueCopyValueAtIndex(localEmail, i);
            if (nil!=mailValue) {
                [tempMailArr addObject:mailLabel];
                [tempMailArr addObject:mailValue];
            }
            if (tempStr) {
                CFRelease(tempStr);
            }
            [mailLabel release];
            [mailValue release];
        }
        theContact.emailArray = tempMailArr;
        [tempMailArr release];
        CFRelease(localEmail);
        // URL
        ABMutableMultiValueRef localURL = ABRecordCopyValue(theIphoneContact, kABPersonURLProperty);
        NSInteger urlCount = ABMultiValueGetCount(localURL);
        NSMutableArray * tempURLArr = [[NSMutableArray alloc] init];
        for (int i=0; i<urlCount; i++) {
            CFStringRef tempStr = ABMultiValueCopyLabelAtIndex(localURL, i);
            NSString * urlLabel = (NSString *)ABAddressBookCopyLocalizedLabel(tempStr);
            NSString * urlValue = (NSString *)ABMultiValueCopyValueAtIndex(localURL, i);
            if (nil!=urlValue) {
                [tempURLArr addObject:urlLabel];
                [tempURLArr addObject:urlValue];
            }
            if (tempStr) {
                CFRelease(tempStr);
            }
            [urlLabel release];
            [urlValue release];
        }
        theContact.urlArray = tempURLArr;
        [tempURLArr release];
        CFRelease(localURL); 
        // address
        ABMultiValueRef localAddress = ABRecordCopyValue(theIphoneContact, kABPersonAddressProperty);
        NSInteger addressCount = ABMultiValueGetCount(localAddress);
        NSMutableArray * tempAddressArr = [[NSMutableArray alloc] init];
        for (int i=0; i<addressCount; i++) {
            CFStringRef tempStr = ABMultiValueCopyLabelAtIndex(localAddress, i);
            NSString * addressLabel = (NSString *) ABAddressBookCopyLocalizedLabel(tempStr);
            NSDictionary * addressContent = (NSDictionary *)ABMultiValueCopyValueAtIndex(localAddress, i);
            if (nil!=addressContent) {
                [tempAddressArr addObject:addressLabel];
                [tempAddressArr addObject:addressContent];
            }
            if (tempStr) {
                CFRelease(tempStr);
            }
            [addressLabel release];
            [addressContent release];
        }
        theContact.addressArray = tempAddressArr;
        [tempAddressArr release];
        CFRelease(localAddress);
        // im
        ABMutableMultiValueRef localIM = ABRecordCopyValue(theIphoneContact, kABPersonInstantMessageProperty);
        NSInteger imCount = ABMultiValueGetCount(localIM);
        NSMutableArray * tempIMArr = [[NSMutableArray alloc] init];
        for (int i=0; i<imCount; i++) {
            CFStringRef tempStr = ABMultiValueCopyLabelAtIndex(localIM, i);
            NSString * imDicLabel = (NSString *)ABAddressBookCopyLocalizedLabel(tempStr);
            NSDictionary * imDic = (NSDictionary *)ABMultiValueCopyValueAtIndex(localIM, i);
            if (nil!=imDic) {
                [tempIMArr addObject:imDicLabel];
                [tempIMArr addObject:imDic];
            }
            if (tempStr) {
                CFRelease(tempStr);
            }
            [imDicLabel release];
            [imDic release];
        }
        theContact.imArray = tempIMArr;
        [tempIMArr release];
        CFRelease(localIM);
        // social profile
        NSString * systemVersion = [[UIDevice currentDevice] systemVersion];
        float version = [systemVersion floatValue];
        if (version>=5.0) {
            ABMutableMultiValueRef localSocialProfile = [CommonTools TABRecordCopyValueOfSocialProfile:theIphoneContact];            
            NSInteger spCount = ABMultiValueGetCount(localSocialProfile);
            NSMutableArray * tempSPArr = [[NSMutableArray alloc] init];
            for (int i=0; i<spCount; i++) {
                NSDictionary * socialDic = (NSDictionary *)ABMultiValueCopyValueAtIndex(localSocialProfile, i);
                [tempSPArr addObject:socialDic];
                [socialDic release];
            }
            theContact.socialArray = tempSPArr;
            [tempSPArr release];
            CFRelease(localSocialProfile);
        }
        // date
        ABMutableMultiValueRef localDate = ABRecordCopyValue(theIphoneContact, kABPersonDateProperty);
        NSInteger dateCount = ABMultiValueGetCount(localDate);
        NSMutableArray * tempDateArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < dateCount; i++)
        {
            CFStringRef tempStr = ABMultiValueCopyLabelAtIndex(localDate, i);
            NSString* dateLabel = (NSString*)ABAddressBookCopyLocalizedLabel(tempStr);
            NSDate * dateInDate = (NSDate *)ABMultiValueCopyValueAtIndex(localDate, i);
            NSString * dateContent = [parser dateToString:dateInDate format:@"yyyyMMdd"];
            [tempDateArr addObject:dateLabel];
            [tempDateArr addObject:dateContent];
            if (tempStr) {
                CFRelease(tempStr);
            }
            [dateLabel release];
            CFRelease(dateInDate);
        }
        [parser release];
        theContact.dateArray = tempDateArr;
        [tempDateArr release];
        CFRelease(localDate);
    }//end of if
    else {
        ccp_AddressLog(@"没有ID为%d的联系人",recordID);
    }
    CFRelease(localAddressBook);
    return  theContact;
}
-(int)getContactIDByPhone:(NSString *) phone
{
    return  [self.mySearchDBAccess getDataByPhone:phone];
}
- (NSString *)getContactNameByPhone:(NSString *) phone {
    NSMutableString * name= [[NSMutableString alloc] init];
    int contactID = [self.mySearchDBAccess getDataByPhone:phone];
    if (0!=contactID) {
        NSString *tempStr = [[self.contactWithName objectForKey:[NSNumber numberWithInt:contactID]] name];
        if (nil != tempStr)
        {
            [name appendString:tempStr];
        }
    }
    if ([name length]>0) {
        return [name autorelease];
    }
    [name release];
    return nil;
}

- (NSString *)getContactNameByPhone:(NSString *) phone ID:(int *)contactIDBack {
    NSMutableString * name= [[NSMutableString alloc] init];
    int contactID = [self.mySearchDBAccess getDataByPhone:phone];
     *contactIDBack = contactID;
    if (0!=contactID) {
        NSString *tempStr = [[self.contactWithName objectForKey:[NSNumber numberWithInt:contactID]] name];
        if (nil != tempStr)
        {
            [name appendString:tempStr];
        }
    }
    if ([name length]>0) {
        return [name autorelease];
    }
    [name release];
    return nil;
}

- (NSString *)getFirstPhoneByStr:(NSString *) str AndID:(int *)contactIDBack {
    *contactIDBack = [self.mySearchDBAccess getContactIDByString:str];
    if (0!=*contactIDBack) {
        return [[self.contactWithName objectForKey:[NSNumber numberWithInt:*contactIDBack]] firstNotNullPhoOrMail];
    }
    return nil;
}

- (void)addArr2Dic:(NSMutableArray *)arr Dic:(NSMutableDictionary *) dic key:(char)key {
    if ([arr count]>0) {
        [arr sortUsingSelector:@selector(compareContactName:)];
        NSString * keyO = [[NSString alloc] initWithFormat:@"%c",key];
        [dic setObject:arr forKey:keyO];
        [keyO release];
    }
}

//将一组联系人按照名字的或名字拼音的首字母将其分散到一个字典里
- (NSDictionary *)categorizeContact2Dic:(NSArray *)allContactArr {
    [allContactArr retain];
    NSMutableDictionary * contactInDicFormat = [[[NSMutableDictionary alloc] init] autorelease];
    //定义其他27数组
    NSMutableArray * contactArrA = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrB = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrC = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrD = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrE = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrF = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrG = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrH = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrI = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrJ = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrK = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrL = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrM = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrN = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrO = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrP = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrQ = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrR = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrS = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrT = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrU = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrV = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrW = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrX = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrY = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrZ = [[NSMutableArray alloc] init];
    NSMutableArray * contactArrSpecial = [[NSMutableArray alloc] init];
    for (int counter=0; counter<[allContactArr count]; counter++) {
        if ([[[allContactArr objectAtIndex:counter] pinyin] length]>0) {
            unsigned short tempFirstchar = (unsigned short)[[[allContactArr objectAtIndex:counter] pinyin] characterAtIndex:0];
            NSMutableString * forSplitInToDic = [[NSMutableString alloc] init];
            if (xm_IsAlpha(tempFirstchar)) {
                [forSplitInToDic appendFormat:@"%c",tempFirstchar];
            } else {
                [forSplitInToDic appendFormat:@"#"];
            }
            //根据forSplitInToDic的第一个字母来判断
            switch ([[forSplitInToDic lowercaseString] characterAtIndex:0]) {
                case ContactNameFirstCharA:
                    [contactArrA addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharB:
                    [contactArrB addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharC:
                    [contactArrC addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharD:
                    [contactArrD addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharE:
                    [contactArrE addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharF:
                    [contactArrF addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharG:
                    [contactArrG addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharH:
                    [contactArrH addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharI:
                    [contactArrI addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharJ:
                    [contactArrJ addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharK:
                    [contactArrK addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharL:
                    [contactArrL addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharM:
                    [contactArrM addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharN:
                    [contactArrN addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharO:
                    [contactArrO addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharP:
                    [contactArrP addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharQ:
                    [contactArrQ addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharR:
                    [contactArrR addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharS:
                    [contactArrS addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharT:
                    [contactArrT addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharU:
                    [contactArrU addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharV:
                    [contactArrV addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharW:
                    [contactArrW addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharX:
                    [contactArrX addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharY:
                    [contactArrY addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNameFirstCharZ:
                    [contactArrZ addObject:[allContactArr objectAtIndex:counter]];
                    break;
                case ContactNamefirstCharSpecial:
                    [contactArrSpecial addObject:[allContactArr objectAtIndex:counter]];
                    break;
                default:
                    break;
            }//end of switch
            [forSplitInToDic release];
        }
        else {//联系人名字为异常，如为空时
            [contactArrSpecial addObject:[allContactArr objectAtIndex:counter]];
        }
    }
    [allContactArr release];
    //将数组添加到字典    
    
    [self addArr2Dic:contactArrA Dic:contactInDicFormat key:'A'];
    [self addArr2Dic:contactArrB Dic:contactInDicFormat key:'B'];
    [self addArr2Dic:contactArrC Dic:contactInDicFormat key:'C'];
    [self addArr2Dic:contactArrD Dic:contactInDicFormat key:'D'];
    [self addArr2Dic:contactArrE Dic:contactInDicFormat key:'E'];
    [self addArr2Dic:contactArrF Dic:contactInDicFormat key:'F'];
    [self addArr2Dic:contactArrG Dic:contactInDicFormat key:'G'];
    [self addArr2Dic:contactArrH Dic:contactInDicFormat key:'H'];
    [self addArr2Dic:contactArrI Dic:contactInDicFormat key:'I'];
    [self addArr2Dic:contactArrJ Dic:contactInDicFormat key:'J'];
    [self addArr2Dic:contactArrK Dic:contactInDicFormat key:'K'];
    [self addArr2Dic:contactArrL Dic:contactInDicFormat key:'L'];
    [self addArr2Dic:contactArrM Dic:contactInDicFormat key:'M'];
    [self addArr2Dic:contactArrN Dic:contactInDicFormat key:'N'];
    [self addArr2Dic:contactArrO Dic:contactInDicFormat key:'O'];
    [self addArr2Dic:contactArrP Dic:contactInDicFormat key:'P'];
    [self addArr2Dic:contactArrQ Dic:contactInDicFormat key:'Q'];
    [self addArr2Dic:contactArrR Dic:contactInDicFormat key:'R'];
    [self addArr2Dic:contactArrS Dic:contactInDicFormat key:'S'];
    [self addArr2Dic:contactArrT Dic:contactInDicFormat key:'T'];
    [self addArr2Dic:contactArrU Dic:contactInDicFormat key:'U'];
    [self addArr2Dic:contactArrV Dic:contactInDicFormat key:'V'];
    [self addArr2Dic:contactArrW Dic:contactInDicFormat key:'W'];
    [self addArr2Dic:contactArrX Dic:contactInDicFormat key:'X'];
    [self addArr2Dic:contactArrY Dic:contactInDicFormat key:'Y'];
    [self addArr2Dic:contactArrZ Dic:contactInDicFormat key:'Z'];
    [self addArr2Dic:contactArrSpecial Dic:contactInDicFormat key:'^'];
    //释放所有数组
    [contactArrA release];
    [contactArrB release];
    [contactArrC release];
    [contactArrD release];
    [contactArrE release];
    [contactArrF release];
    [contactArrG release];
    [contactArrH release];
    [contactArrI release];
    [contactArrJ release];
    [contactArrK release];
    [contactArrL release];
    [contactArrM release];
    [contactArrN release];
    [contactArrO release];
    [contactArrP release];
    [contactArrQ release];
    [contactArrR release];
    [contactArrS release];
    [contactArrT release];
    [contactArrU release];
    [contactArrV release];
    [contactArrW release];
    [contactArrX release];
    [contactArrY release];
    [contactArrZ release];
    [contactArrSpecial release];
    return contactInDicFormat;
}

//当要列出全部联系人时，只返回联系人名字、ID（用作当用户需要返回联系人的明细用）、第一个非空的电话号码
- (NSMutableDictionary *)listAllContacts {
    ccp_AddressLog(@"%s Begins",__func__);
    ABAddressBookRef addressBookForListAll = ABAddressBookCreate();
    if (!accessAddressBook(addressBookForListAll))
    {
        return nil;
        if (addressBookForListAll)
            CFRelease(addressBookForListAll);
    }

    NSMutableArray * allContactArr = [[NSMutableArray alloc] initWithCapacity:1];
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBookForListAll);
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault,CFArrayGetCount(people),people);
    CFArraySortValues (peopleMutable,CFRangeMake(0, CFArrayGetCount(peopleMutable)),(CFComparatorFunction)ABPersonComparePeopleByName,(void*)ABPersonGetSortOrdering());
    int peopleCount = CFArrayGetCount(peopleMutable);
    ContactWithName * tempGetContactBriefInfo;
//依次获取每个联系人信息
    for (int i=0; i<peopleCount; i++) {
        GetSearchDataObj * temp = [[GetSearchDataObj alloc] init];
        ABRecordRef person = CFArrayGetValueAtIndex(peopleMutable, i);
        int contactID = ABRecordGetRecordID(person);  
        temp.contactID = contactID;
//获得第一个非空的电话或邮箱
        NSNumber * tempKeyNumber = [NSNumber numberWithInt:contactID];
        tempGetContactBriefInfo =  [self.contactWithName objectForKey:tempKeyNumber];
        temp.contactPinyin = [tempGetContactBriefInfo firstNotNullPhoOrMail];
        temp.contactName = 0!=tempGetContactBriefInfo.name.length?tempGetContactBriefInfo.name:(0!=tempGetContactBriefInfo.firstNotNullPhoOrMail.length?tempGetContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
        temp.phoneArr = [tempGetContactBriefInfo phoneArr];
//通过名字获得拼音，返回联系人时排序用
        temp.pinyin = [tempGetContactBriefInfo pinyin];
        temp.isPinyin = [tempGetContactBriefInfo isPinyin];
        [allContactArr addObject:temp];
        [temp release];
    }
    CFRelease(people);
    CFRelease(peopleMutable);
    CFRelease(addressBookForListAll); 
    [allContactArr sortUsingSelector:@selector(compareContactName:)];
    NSMutableDictionary * contactInDicFormat = [[NSMutableDictionary alloc] initWithDictionary:[self categorizeContact2Dic:allContactArr]];
    [allContactArr release];
    ccp_AddressLog(@"%s Ends",__func__);
    return [contactInDicFormat autorelease];
}

- (int)addContact:(AddressBookContactSearchResult *)theContact {
    ABAddressBookRef add2AddressBook = ABAddressBookCreate();
    ABRecordRef newPerson = ABPersonCreate();
    CFErrorRef error = NULL;
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, theContact.firstname, &error);
    ABRecordSetValue(newPerson, kABPersonLastNameProperty, theContact.lastname, &error);
    ABRecordSetValue(newPerson, kABPersonOrganizationProperty, theContact.company, &error);
    ABRecordSetValue(newPerson, kABPersonMiddleNameProperty, theContact.middlename, &error);
    ABRecordSetValue(newPerson, kABPersonPrefixProperty, theContact.prefix, &error);
    ABRecordSetValue(newPerson, kABPersonSuffixProperty, theContact.suffix, &error);
    ABRecordSetValue(newPerson, kABPersonNicknameProperty, theContact.nickname, &error);
    ABRecordSetValue(newPerson, kABPersonFirstNamePhoneticProperty, theContact.firstNamePhonetic, &error);
    ABRecordSetValue(newPerson, kABPersonLastNamePhoneticProperty, theContact.lastNamePhonetic, &error);
    ABRecordSetValue(newPerson, kABPersonMiddleNamePhoneticProperty, theContact.middleNamePhonetic, &error);
    ABRecordSetValue(newPerson, kABPersonJobTitleProperty, theContact.jobTitle, &error);
    ABRecordSetValue(newPerson, kABPersonDepartmentProperty, theContact.department, &error);
    NSDateFormatter * dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyyMMdd"];
    NSDate * birthIndate = [dateformat dateFromString:theContact.birthday];
    [dateformat release];
    ABRecordSetValue(newPerson, kABPersonBirthdayProperty, birthIndate, &error);
    ABRecordSetValue(newPerson, kABPersonNoteProperty, theContact.note, &error);
    //add portrait
    if (nil!=theContact.portrait) {
        CFDataRef cfLocalData = CFDataCreate(NULL, [theContact.portrait bytes], [theContact.portrait length]);
        if (cfLocalData) {
            ABPersonSetImageData(newPerson, cfLocalData, &error);
            CFRelease(cfLocalData);
        }
    }
    
    //add phone 
    /*phone数组的偶数位（如0、2等）有如下含义
     *1 Mobile
     *2 iPhone
     *3 Home
     *4 Work
     *5 Main
     *6 HomeFax
     *7 WorkFax
     *8 OtherFax
     *9 Pager
     *0 Other
     *其他传入的参数都将被直接用作电话的自定义标签
     */
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABStringPropertyType);
    ParseType * parseType = [[ParseType alloc] init];
    for (int i=0; i<[theContact.phoneArray count]; i++) {
        NSString * telType = [parseType getTelLabel:[theContact.phoneArray objectAtIndex:i] customName:nil];
        i++;
        ABMultiValueAddValueAndLabel(multiPhone, [theContact.phoneArray objectAtIndex:i], (CFStringRef)telType, NULL);
    }
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone, &error);
    CFRelease(multiPhone);
    //add email
    /*email数组的偶数位（如0、2）有如下含义
     *1 Home
     *2 Work
     *3 Other
     *其他传入的参数都将被直接用作邮件的自定义标签
     */
    ABMutableMultiValueRef multiMail = ABMultiValueCreateMutable(kABStringPropertyType);
    for (int i=0; i<[theContact.emailArray count]; i++) {
        NSString * mailType = [parseType getGeneralLabel:[theContact.emailArray objectAtIndex:i]];
        i++;
        ABMultiValueAddValueAndLabel(multiMail, [theContact.emailArray objectAtIndex:i], (CFStringRef)mailType, NULL);
    }
    ABRecordSetValue(newPerson, kABPersonEmailProperty, multiMail, &error);
    CFRelease(multiMail);
    //add url
    /*
     *url数组的偶数位有如下含义
     *1 HomePage
     *2 Home
     *3 Work
     *4 Other
     *其他传入的参数都将被直接用作URL的自定义标签
     */
    ABMutableMultiValueRef multiURL = ABMultiValueCreateMutable(kABStringPropertyType);
    for (int i=0; i<[theContact.urlArray count]; i++) {
        NSString * urlType = [parseType getWebsiteLabel:[theContact.urlArray objectAtIndex:i]];
        i++;
        ABMultiValueAddValueAndLabel(multiURL, [theContact.urlArray objectAtIndex:i], (CFStringRef)urlType, NULL);
    }
    ABRecordSetValue(newPerson, kABPersonURLProperty, multiURL, &error);
    CFRelease(multiURL);
    //add address
    /*
     *address数组的偶数位有如下含义
     *1 Home
     *2 Work
     *3 Other
     *其他传入的参数都将被直接用作address的自定义标签
     *每个奇数位（1、3等）都是一个dictionary，在dictionary里每个键值如下含义
     *1 Street
     *2 City
     *3 State
     *4 Zip
     *5 Country
     *6 CountryCode
     */
    ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    for (int i=0; i<[theContact.addressArray count]; i++) {
        NSString * addressType = [parseType getGeneralLabel:[theContact.addressArray objectAtIndex:i]];
        i++;
        NSMutableDictionary * temp = [[NSMutableDictionary alloc] init];
        for (NSString * tempKey in [[theContact.addressArray objectAtIndex:i] allKeys]) {
            switch ([tempKey intValue]) {
                case 1:
                    [temp setObject:[[theContact.addressArray objectAtIndex:i] objectForKey:tempKey] forKey:(NSString *)kABPersonAddressStreetKey];
                    break;
                case 2:
                    [temp setObject:[[theContact.addressArray objectAtIndex:i] objectForKey:tempKey] forKey:(NSString *)kABPersonAddressCityKey];
                    break;
                case 3:
                    [temp setObject:[[theContact.addressArray objectAtIndex:i] objectForKey:tempKey] forKey:(NSString *)kABPersonAddressStateKey];
                    break;
                case 4:
                    [temp setObject:[[theContact.addressArray objectAtIndex:i] objectForKey:tempKey] forKey:(NSString *)kABPersonAddressZIPKey];
                    break;
                case 5:
                    [temp setObject:[[theContact.addressArray objectAtIndex:i] objectForKey:tempKey] forKey:(NSString *)kABPersonAddressCountryKey];
                    break;
                case 6:
                    [temp setObject:[[theContact.addressArray objectAtIndex:i] objectForKey:tempKey] forKey:(NSString *)kABPersonAddressCountryCodeKey];
                    break;
                default:
                    break;
            }
        }
        ABMultiValueAddValueAndLabel(multiAddress, temp, (CFStringRef)addressType, NULL);
        [temp release];
    }
    ABRecordSetValue(newPerson, kABPersonAddressProperty, multiAddress,&error);
    CFRelease(multiAddress);
    //im
    /*
     *im数组的偶数位有如下含义
     *1 Home
     *2 Work
     *3 Other
     *其他传入的参数都将直接用作im的自定义标签
     *每个奇数位（1、3等）都是一个dictionary，在dictionary里每个键值如下定义
     *1 Service
     *2 UserName
     *其中Service值1（AIM）、2（GoogleTalk）、3（Yahoo）、4（MSN）、5（ICQ），其他直接作为service
     */
    ABMutableMultiValueRef multiIM = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    for (int i=0; i<[theContact.imArray count]; i++) {
        NSString * imType = [parseType getGeneralLabel:[theContact.imArray objectAtIndex:i]];
        i++;
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
        for (NSString * tempKey in [[theContact.imArray objectAtIndex:i] allKeys]) {
            switch ([tempKey intValue]) {
                case 1:
                    [temp setObject:[parseType getImLabel:[[theContact.imArray objectAtIndex:i] objectForKey:tempKey]] forKey:(NSString *)kABPersonInstantMessageServiceKey];
                    break;
                case 2:
                    [temp setObject:[[theContact.imArray objectAtIndex:i] objectForKey:tempKey] forKey:(NSString *)kABPersonInstantMessageUsernameKey];
                    break;
                default:
                    break;
            }
        }
        ABMultiValueAddValueAndLabel(multiIM, temp, (CFStringRef)imType, NULL);
        [temp release];
    }
    ABRecordSetValue(newPerson, kABPersonInstantMessageProperty, multiIM, &error);
    CFRelease(multiIM);
    
    //date
    /*
     *date数组的偶数位有如下含义
     *1 纪念日（Anniversary）
     *2 Other
     *其他传入的参数都将被直接用作DATE的自定义标签
     *date数组的奇数位为日期，格式为YYYYMMDD
     */
    ABMutableMultiValueRef multiDate = ABMultiValueCreateMutable(kABPersonDateProperty);
    for (int i=0; i<[theContact.dateArray count]; i++) {
        NSString * dateType = [parseType getDateLabel:[theContact.dateArray objectAtIndex:i]];
        i++;
        NSString * dateValue = [theContact.dateArray objectAtIndex:i];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyyMMdd"];
        NSDate * theDate = [format dateFromString:dateValue];
        [format release];
        ABMultiValueAddValueAndLabel(multiDate, theDate, (CFStringRef)dateType, NULL);
    }
    ABRecordSetValue(newPerson, kABPersonDateProperty, multiDate, &error);
    CFRelease(multiDate);
    //social profile 5.0以上才支持
    /*
     *social profile是一个直接有dictionary组成的数组，即数组的每一个元素都是一个dictionary。
     *其中每一个dictionary的键值如下定义
     *1 service
     *2 username
     *其中service值1（Facebook）、2（Flickr）、3（LinkedIn）、4（Myspace）、5（Twitter），其他直接作为service。
     */
    //判断当前设备ios版本
    NSString * systemVersion = [[UIDevice currentDevice] systemVersion];
    float version = [systemVersion floatValue];
    if (version>=5.0) {
        //add social profile
        ABMutableMultiValueRef multiSP = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
        for (int i=0; i<[theContact.socialArray count]; i++) {
            NSMutableDictionary * tempDic = [[NSMutableDictionary alloc] init];
            NSString * spLabel = [parseType getSocialProfile:[[theContact.socialArray objectAtIndex:i] objectForKey:@"1"]];
            NSString * spContent = [[theContact.socialArray objectAtIndex:i] objectForKey:@"2"];
            [tempDic setObject:spLabel forKey:@"service"];
            [tempDic setObject:spContent forKey:@"username"];
            ABMultiValueAddValueAndLabel(multiSP, tempDic, NULL, NULL);
            [tempDic release];
        }   
        [CommonTools TABRecordSetValueOfSocialProfile:newPerson value:multiSP error:&error];
        CFRelease(multiSP);
    }
    //add newperson to addressbook
    ABAddressBookAddRecord(add2AddressBook, newPerson, &error);
    ABAddressBookSave(add2AddressBook, &error);
    if (NULL!=error) {
        ccp_AddressLog(@"没有成功添加联系人");
        [parseType release];
        CFRelease(newPerson);
        CFRelease(add2AddressBook);
        return -1;
    }
    ccp_AddressLog(@"成功添加联系人");
    int newRecordID = ABRecordGetRecordID(newPerson);
    CFRelease(newPerson);
    [parseType release];
    CFRelease(add2AddressBook);
    return newRecordID;
}

- (BOOL)updateContact:(AddressBookContactSearchResult *)theContact {  
//先将联系人通过id删除，再调用添加联系人的接口添加
    [self deleteContactSingle:theContact.contactID];
    [self addContact:theContact];
    return YES;
}

- (BOOL)deleteContactSingle:(int)contactID {
    @try {
        CFErrorRef error = NULL;
        int flag;
        if (contactID) {
            ABRecordRef deleteContact = ABAddressBookGetPersonWithRecordID(addressBook, contactID);
            if (deleteContact) {
                flag = ABAddressBookRemoveRecord(addressBook, deleteContact, &error);;
                flag = ABAddressBookSave(addressBook, &error);
            }
            else {
                ccp_AddressLog(@"没有ID为%d的联系人！",contactID);
                flag = NO;
            }
        }
        else {
            ccp_AddressLog(@"联系人ID没有设置，请设置后再删除联系人！");
            flag = NO;
        }
        return flag;
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

- (BOOL)delContacts:(NSArray *)contactIDArr {
    @try {
        CFErrorRef error = NULL;
        int flag;
        int contactID=0;
        for (id index in contactIDArr) {
            contactID = [index intValue];
            if (contactID) {
                ABRecordRef deleteContact = ABAddressBookGetPersonWithRecordID(addressBook, contactID);
                if (deleteContact) {
                    flag = ABAddressBookRemoveRecord(addressBook, deleteContact, &error);;
                }
                else {
                    ccp_AddressLog(@"ERROR: 没有ID为%d的联系人！",contactID);
                    flag = NO;
                }
            }
            else {
                ccp_AddressLog(@"ERROR: 联系人ID没有设置，请设置后再删除联系人！");
                flag = NO;
            }
        }
        flag = ABAddressBookSave(addressBook, &error);
        return flag;
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

#pragma mark -
- (signed long) getContactCount {
    ABAddressBookRef getAddressCount = ABAddressBookCreate();
    @try
    {
        if (!accessAddressBook(getAddressCount))
        {
            return 0;
            if (getAddressCount)
                CFRelease(getAddressCount);
        }
    }
    @finally
    {
        
    }
    
    NSInteger count = ABAddressBookGetPersonCount(getAddressCount);
    if (getAddressCount)
    CFRelease(getAddressCount);
    return count;
}

#pragma mark -
#pragma mark - manage contact portrait
- (BOOL)hasPortrait:(int) contactID {
    @try {
        int flag;
        if (contactID) {
            ABRecordRef imageContact = ABAddressBookGetPersonWithRecordID(addressBook, contactID);
            if (imageContact) {
                flag = ABPersonHasImageData(imageContact);
            }
            else {
                ccp_AddressLog(@"没有ID为%d的联系人，请传入正确的联系人ID！",contactID);
                return NO;
            }
        }
        else {
            ccp_AddressLog(@"该联系人不在通讯录中，请将联系人添加后判断是否有头像！");
            flag = NO;
        }
        return flag;
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}
- (BOOL)setImage:(int) contactID image:(NSData *)image {
    @try {
        CFDataRef cfLocalData = CFDataCreate(NULL, [image bytes], [image length]);
        int flag;
        if (cfLocalData) {
            CFErrorRef error = NULL;
            int flag;
            if (contactID) {
                ABRecordRef imageContact = ABAddressBookGetPersonWithRecordID(addressBook, contactID);
                if (imageContact) {
                    flag = ABPersonSetImageData(imageContact, cfLocalData, &error);
                    flag = ABAddressBookSave(addressBook, &error);
                }
                else {
                    ccp_AddressLog(@"没有ID为%d的联系人，请传入正确的联系人ID！",contactID);
                    return NO;
                }
            }
            else {
                ccp_AddressLog(@"联系人ID没有设置，请设置后再设置联系人头像！");
                flag = NO;
            }
            CFRelease(cfLocalData);
        }
        else {
            ccp_AddressLog(@"联系人头像设置错误!");
            flag = NO;
        }
        return flag;
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}
- (BOOL)removeImage:(int) contactID {
    @try {
        CFErrorRef error = NULL;
        int flag;
        flag = [self hasPortrait:contactID];
        if (flag) {
            ABRecordRef removeImage = ABAddressBookGetPersonWithRecordID(addressBook, contactID);
            flag = ABPersonRemoveImageData(removeImage, &error);
            flag = ABAddressBookSave(addressBook, &error);
        }
        else {//联系人没有头像
            ccp_AddressLog(@"此联系人没有头像！");
        }
        return flag;
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

-(UIImage *)drawImage:(UIImage*)image size:(CGSize)size
{
    CGContextRef mainViewContentContext;
    CGColorSpaceRef colorSpace;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    mainViewContentContext = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(mainViewContentContext, CGRectMake(0, 0, size.width, size.height));
    CGColorSpaceRelease(colorSpace);
    
    UIImage* newImg = nil;
    if (mainViewContentContext != NULL) 
    {
        CGImageRef maskImage = [[UIImage imageNamed:@"group_image_01_mask.png"] CGImage];
        CGContextClipToMask(mainViewContentContext, CGRectMake(0, 0, size.width, size.height), maskImage);
        CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, size.width, size.width), [image CGImage]);
        CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
        CGContextRelease(mainViewContentContext);
        
        newImg = [UIImage imageWithCGImage:mainViewContentBitmapContext];
        CGImageRelease(mainViewContentBitmapContext);
    }
    
    UIGraphicsBeginImageContext(size);                    
    CGRect imageRect = CGRectMake(0.0, 0.0, size.width, image.size.height*size.width/image.size.width);
    [newImg drawInRect:imageRect];
    UIImage* boundImage = [UIImage imageNamed:@"group_image_01.png"];
    [boundImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)getImage:(int) contactID{
    @try {
        int flag;
        NSData * imageData = nil;
        UIImage * img;
        flag = [self hasPortrait:contactID];
        if (true==flag && -1!=flag) 
        {
            ABRecordRef copyImage = ABAddressBookGetPersonWithRecordID(addressBook, contactID);
            if (ABPersonCopyImageDataWithFormat != NULL) 
            {
                imageData = (NSData *)ABPersonCopyImageDataWithFormat(copyImage, kABPersonImageFormatThumbnail);
            } 
            else 
            {
                imageData = (NSData *)ABPersonCopyImageData(copyImage);
            }
            if (imageData) 
            {
                UIImage *image =  [UIImage imageWithData:imageData];
                img = [self drawImage:image size:CGSizeMake(120, 120)];
                [imageData release];
                return img;
            }            
        }
        else {
            ccp_AddressLog(@"没有此联系人或者此联系人没有头像！");
            return nil;
        }
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return nil;
}

#pragma mark -
#pragma mark - group functions
- (BOOL)addANewGroup:(NSString *)groupName {
    ABAddressBookRef addNewGroup = ABAddressBookCreate();
    CFErrorRef error = NULL;
    int flag;
    ABRecordRef group = ABGroupCreate();
    flag = ABRecordSetValue(group, kABGroupNameProperty, groupName, &error);
    if (true==flag) {
        flag = ABAddressBookAddRecord(addNewGroup, group, &error);
    }
    if (true==flag) {
        flag = ABAddressBookSave(addNewGroup, &error);
    }
    CFRelease(group);
    CFRelease(addNewGroup);
    return flag;
}

- (BOOL)renameGroup:(int)groupID newName:(NSString *)newName {
    @try {
        ABAddressBookRef addressbookLocal = ABAddressBookCreate();
        CFErrorRef error = NULL;
        int flag;
        ABRecordRef group = ABAddressBookGetGroupWithRecordID(addressbookLocal, groupID);
        flag = ABRecordSetValue(group, kABGroupNameProperty, newName, &error);
        if (true==flag) {
            flag = ABAddressBookSave(addressbookLocal, &error);
        }
        CFRelease(addressbookLocal);
        return flag;
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return NO;
}

- (NSArray *)listAllGroups {
    GroupDBAccess * groupDBAccess = [[GroupDBAccess alloc] init];
    NSDictionary * idAndOrder = [groupDBAccess getAllRecords];
    [groupDBAccess release];
    NSMutableArray * groupArr = [[[NSMutableArray alloc] init] autorelease];
    ABAddressBookRef listG = ABAddressBookCreate();
    @try
    {
        if (!accessAddressBook(listG))
        {
            if (listG)
                CFRelease(listG);
            return nil;
        }
    }
    @finally
    {
        
    }
    CFArrayRef groupRef = ABAddressBookCopyArrayOfAllGroups(listG);
    for (int i=0; i<CFArrayGetCount(groupRef); i++) {
        ABRecordRef group = CFArrayGetValueAtIndex(groupRef, i);
        AddressBookGroup * temp = [[AddressBookGroup alloc] init]; 
        temp.groupID = ABRecordGetRecordID(group);
        temp.order = [[idAndOrder objectForKey:[NSNumber numberWithInt:temp.groupID]] intValue];
        NSString * tempGroupname = (NSString *)ABRecordCopyValue(group, kABGroupNameProperty);
        temp.groupName = tempGroupname;
        [tempGroupname release];
        [groupArr addObject:temp];
        [temp release];
    }
    CFRelease(listG);
    CFRelease(groupRef);
    [groupArr sortUsingSelector:@selector(compareByOrder:)];
    return groupArr;
}

- (BOOL)delTheGroup:(int)groupID {
    CFErrorRef error = NULL;
    int flag=TRUE;
    ABAddressBookRef delGroup = ABAddressBookCreate();
    ABRecordRef theGroup = ABAddressBookGetGroupWithRecordID(delGroup, groupID);
    if (nil!=theGroup) {
        flag = ABAddressBookRemoveRecord(delGroup, theGroup, &error);
        flag = ABAddressBookSave(delGroup, &error);
    }
    CFRelease(delGroup);
    return flag;
}


- (BOOL)addNewContactToGroup:(int)contactID group:(int)groupID {
    CFErrorRef error = NULL;
    ABAddressBookRef addMember2Group = ABAddressBookCreate();
    ABRecordRef theGroup = ABAddressBookGetGroupWithRecordID(addMember2Group, groupID);
    if (nil!=theGroup) {
        //若不为零，则直接通过id获得联系人，再添加到组
        ABRecordRef hasAdd = ABAddressBookGetPersonWithRecordID(addMember2Group, contactID);
        ABGroupAddMember(theGroup, hasAdd, &error);
        ABAddressBookSave(addMember2Group, &error);
    }
    else {
        ccp_AddressLog(@"没有此组!");
        CFRelease(addMember2Group);
        return NO;
    }
    CFRelease(addMember2Group);
    return YES;
}


- (BOOL)removeContactFromGroup:(int)contactID group:(int)groupID {
    CFErrorRef error = NULL;
    int flag;
    ABAddressBookRef delFromGroup = ABAddressBookCreate();
    ABRecordRef theGroup = ABAddressBookGetGroupWithRecordID(delFromGroup, groupID);
    if (nil!=theGroup) {
        if (0!=contactID) {
            ABRecordRef forDel = ABAddressBookGetPersonWithRecordID(delFromGroup, contactID);
            flag = ABGroupRemoveMember(theGroup, forDel, &error);
            flag = ABAddressBookSave(delFromGroup, &error);
        }
        else {
            ccp_AddressLog(@"没有此联系人!");
            flag = NO;
        }
    }
    else {
        ccp_AddressLog(@"没有此组!");
        flag = NO;
    }
    CFRelease(delFromGroup);
    return flag;
}

//此函数为将联系人从一个组拖入到另外一个组时使用，所以拖动时联系人肯定已经在一个组，所以无需判断联系人是否在一个组里
- (BOOL)moveContactFromOneToAnother:(int)contactID one:(int)groupID another:(int)anotherGroupID {
    int flag;
    if (anotherGroupID<=0) {
        flag = [self addNewContactToGroup:contactID group:groupID];
    }
    else {
        flag = [self removeContactFromGroup:contactID group:groupID];
        if (flag) {
            flag = [self addNewContactToGroup:contactID group:anotherGroupID];
        }
    }
    return flag;
}

- (BOOL)setContactsGroups:(int)contactID add:(NSMutableArray*)checkGroupIDList delGroups:(NSMutableArray*)delGroups {
    @try {
        BOOL flag;
        for (int add=0; add<[checkGroupIDList count]; add++) {
            flag = [self addNewContactToGroup:contactID group:[[checkGroupIDList objectAtIndex:add] intValue]];
            if (!flag) {
                ccp_AddressLog(@"ERROR: Failed in function %s add",__func__);
                return NO;
            }
        }
        for (int del=0; del<[delGroups count]; del++) {
            flag = [self removeContactFromGroup:contactID group:[[delGroups objectAtIndex:del] intValue]];
            if (!flag) {
                ccp_AddressLog(@"ERROR: Failed in function %s del",__func__);
                return NO;
            }
        }
        return YES;
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    
}

- (NSMutableDictionary *)getGroupContacts:(int)groupID {
    ABAddressBookRef getGroupContacts = ABAddressBookCreate();
    NSMutableArray * forReturn = [[NSMutableArray alloc] init];
    ABRecordRef theGroup = ABAddressBookGetGroupWithRecordID(getGroupContacts, groupID);
    if (nil!=theGroup) {
        CFArrayRef groupMembers = ABGroupCopyArrayOfAllMembers(theGroup);
        NSArray * forGetCount = (NSArray *)ABGroupCopyArrayOfAllMembers(theGroup);
        ContactWithName * tempGetContactBriefInfo;
        int count = [forGetCount count];
        [forGetCount release];
        for (int i=0; i<count; i++) {
            GetSearchDataObj * temp = [[GetSearchDataObj alloc] init];
            ABRecordRef person = CFArrayGetValueAtIndex(groupMembers, i);
            int contactID = ABRecordGetRecordID(person);
            NSNumber * tempKey = [NSNumber numberWithInt:contactID];
            tempGetContactBriefInfo = [self.contactWithName objectForKey:tempKey];
            temp.contactID = contactID;
            temp.contactName = 0!=tempGetContactBriefInfo.name.length?tempGetContactBriefInfo.name:(0!=tempGetContactBriefInfo.firstNotNullPhoOrMail.length?tempGetContactBriefInfo.firstNotNullPhoOrMail:@"(未知)");
            temp.contactPinyin = [tempGetContactBriefInfo firstNotNullPhoOrMail];
            temp.phoneArr = tempGetContactBriefInfo.phoneArr;
            //通过名字获得拼音，返回联系人时排序用
            temp.pinyin = [tempGetContactBriefInfo pinyin];
            temp.isPinyin = [tempGetContactBriefInfo isPinyin];
            [forReturn addObject:temp];
            [temp release];
        }
        if (groupMembers) {
            CFRelease(groupMembers);
        }
    }
    else {
        ccp_AddressLog(@"没有此组!");
    }
    CFRelease(getGroupContacts);
    NSMutableDictionary * contactInDic=nil;
    if ([forReturn count]>0) {
        [forReturn sortUsingSelector:@selector(compareContactName:)];
        contactInDic = [[NSMutableDictionary alloc] initWithDictionary:[self categorizeContact2Dic:forReturn]];
    }
    [forReturn release];
    return [contactInDic autorelease];
}

#pragma mark -
#pragma mark - For bakcup addressbook
- (NSArray *)getContactFrom:(int)startNO count:(int)count {
    @try {
        ABAddressBookRef addressbook = ABAddressBookCreate();
        NSArray * allContact = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressbook);
        NSMutableArray * forReturn = [[NSMutableArray alloc] init];
        int totalCount = ABAddressBookGetPersonCount(addressbook);
        int calculator = 0;
        for (int i = startNO; i<totalCount&&calculator<count; i++,calculator++) {
            ABRecordRef cursor = [allContact objectAtIndex:i];
            AddressBookContactSearchResult * currentContact = [self getContactByID:ABRecordGetRecordID(cursor)];
            [forReturn addObject:currentContact];
        }
        CFRelease(addressbook);
        return [forReturn autorelease];
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return  nil;
}

- (NSDictionary *)getAllGroupMemInDic {
    @try {
        ABAddressBookRef addressbookGetAll = ABAddressBookCreate();
        NSArray * groupArr = (NSArray *)ABAddressBookCopyArrayOfAllGroups(addressbookGetAll);
        NSMutableDictionary * forReturn = [[NSMutableDictionary alloc] init];
        ABRecordID recordID;
        for (id groupref in groupArr) {
            NSMutableArray * tempArr = [[NSMutableArray alloc] init];
            NSNumber * groupID = [[NSNumber alloc] initWithInt:ABRecordGetRecordID(groupref)];
            NSArray * contactIDInGroup = (NSArray *)ABGroupCopyArrayOfAllMembers(groupref);
            for (id item in contactIDInGroup) {
                recordID = ABRecordGetRecordID((ABRecordRef)item);
                NSNumber * contactID = [[NSNumber alloc] initWithInt:recordID];
                [tempArr addObject:contactID];
                [contactID release];
            }
            [forReturn setObject:tempArr forKey:groupID];
            [groupID release];
            [tempArr release];
            [contactIDInGroup release];
        }
        CFRelease(groupArr);
        CFRelease(addressbookGetAll);
        return [forReturn autorelease];
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return nil;
}

- (NSArray *)getGroupListByContactID:(int)contactID withGroupDic:(NSDictionary *) groupDic {
    @try {
        NSNumber * contactIDInObj = [[NSNumber alloc] initWithInt:contactID];
        NSMutableArray * forReturn = [[NSMutableArray alloc] init];
        for (id groupID in [groupDic allKeys]) {
            NSArray * temp = [groupDic objectForKey:groupID];
            if ([temp containsObject:contactIDInObj]) {
                [forReturn addObject:groupID];
            }
        }
        [contactIDInObj release];
        return [forReturn autorelease];
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return nil;
}

#pragma mark -
#pragma mark - C funtions
NSString * cleanPhoneNo(NSString * oldPho)
{
    const char * charOldPho = [oldPho UTF8String];
    NSUInteger lenth = strlen(charOldPho);
    NSMutableString * newPho = [[NSMutableString alloc]initWithCapacity:8];
    for (int i=0; i<lenth; i++) {
        char c = charOldPho[i];
        if ('('==c || ')'==c || '-'==c || ' '==c) {
            continue;
        }
            [newPho appendFormat:@"%c",c];
    }
    if (newPho.length>0) {
        return [newPho autorelease];
    } else {
        [newPho release];
        return nil;
    }
}

NSString * remove86(NSString * beforeRemove)
{
    if ([beforeRemove hasPrefix:@"+86"])
    {
        return [beforeRemove substringFromIndex:3];
    }
    else
        return beforeRemove;
}

//将此函数在第一次实例化时注册为检测iPhone通讯录变化时调用的函数
void addressBookChanged(ABAddressBookRef addressBook,CFDictionaryRef info,void* context) {
    extern NSInteger contactOptState;
    
    ccp_AddressLog(@"contactOptState=%d",contactOptState);
    ABAddressBookRevert(addressBook);
    
    if (-1==contactOptState) {
        ccp_AddressLog(@"!!!! Address Book Changed!");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addressbookChangedLocal" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addressbookChanged" object:nil userInfo:nil];
        contactOptState=0;
    }
}




-(void) dealloc {
    ccp_AddressLog(@"运行了AddressBookContactList的dealloc");
    if (mySearchQueue) {
        dispatch_release(mySearchQueue);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CFRelease(addressBook);
    self.contactWithName = nil;
    self.mySearchDBAccess = nil;
    self.registerWithPhoneNO = nil;
    self.allContactDictionary = nil;
    [super dealloc];
}
#pragma mark -
#pragma mark - filter funtion for array
- (NSArray *)filterArrayWithArray:(NSArray *)source FilterCondition:(NSArray *)filter {
    @try {
        ContactWithName * tempGetContactBriefInfo;
        if (source.count<=0) {
            return source;
        }
        NSString *regex = @"1[0-9]{10}";
        NSString *regex86 = @"\\+861[0-9]{10}";
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@) AND ((SELF.length == 11 AND SELF MATCHES %@) OR (SELF.length == 14 AND SELF MATCHES %@))",filter, regex,regex86]; 
        NSMutableArray * arrForReturn = [[NSMutableArray alloc] init];
        for (GetSearchDataObj * cursor in source) {
            GetSearchDataObj * newItem = [[GetSearchDataObj alloc] init];
            NSNumber * tempKeyNumber = [[NSNumber alloc] initWithInt:cursor.contactID];
            tempGetContactBriefInfo =  [self.contactWithName objectForKey:tempKeyNumber];
            NSMutableArray * array = [[NSMutableArray alloc] initWithArray:[cursor.phoneArr filteredArrayUsingPredicate:predicate]]; 
            if (array.count>0)
            {
                NSMutableArray *mutableArray = [array mutableCopy];
                newItem.phoneArr = mutableArray;
                [mutableArray release];

                if (1==cursor.contactPinyinProperty||0==cursor.contactPinyinProperty) {
                    newItem.contactPinyin = [filter containsObject:[tempGetContactBriefInfo firstNotNullPhoOrMail]]?[array objectAtIndex:0]:cursor.contactPinyin;
                }
                newItem.contactID = cursor.contactID;
                newItem.checked = cursor.checked;                              
                newItem.contactName = 0!= tempGetContactBriefInfo.name.length? cursor.contactName:cursor.contactPinyin;
                [arrForReturn addObject:newItem];
            }
            [newItem release];
            [array release];
            [tempKeyNumber release];
        }
        if (arrForReturn.count>0) {
            return [arrForReturn autorelease];
        }
        else {
            [arrForReturn release];
            return nil;
        }
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
}

- (NSMutableDictionary *)filterDictionaryWithArray:(NSMutableDictionary *)source FilterCondition:(NSArray *)filter {
    @try {
        NSArray * tempArr = nil;
        NSMutableDictionary* ret= [[NSMutableDictionary alloc] init];
        for (NSString * key in [source allKeys]) {
            tempArr = [self filterArrayWithArray:[source objectForKey:key] FilterCondition:filter] ;
            if (tempArr.count>0) {
                [ret setObject:tempArr forKey:key];
            }
        }
        if (ret.count>0) {
            return [ret autorelease];
        }
        else {
            [ret release];
            return nil;
        }
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
}

-(BOOL)isInGroupWithGroupID:(int)groupID andContactID:(NSInteger)contactid
{
    ABRecordRef theGroup = ABAddressBookGetGroupWithRecordID(addressBook, groupID);
    if (nil!=theGroup) {
        CFArrayRef groupMembers = ABGroupCopyArrayOfAllMembers(theGroup);
        NSArray * forGetCount = (NSArray *)ABGroupCopyArrayOfAllMembers(theGroup);
        int count = [forGetCount count];
        [forGetCount release];
        for (int i=0; i<count; i++) 
        {
            ABRecordRef person = CFArrayGetValueAtIndex(groupMembers, i);
            int contactID = ABRecordGetRecordID(person);
            if (contactid == contactID) {
                if (groupMembers) {
                    CFRelease(groupMembers);
                }
                return YES;
            }
        }
        if (groupMembers) {
            CFRelease(groupMembers);
        }
    }
    else {
        return NO;
    }
    return NO;
}
@end
