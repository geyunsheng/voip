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

#import "AddressBookSyncDBAccess.h"
#import "CommonTools.h"
#import "NSDataBase64.h"
#import "CommonTools.h"
@implementation AddressBookSyncDBAccess

- (AddressBookSyncDBAccess *)init:(EAddressBokkSynctype)type
{
    if (self=[super init]) {
        idType = type;
        shareDB = [DBConnection getSharedDatabase];        
        [self AddressBookSyncTableCreate];        
        return self;
    }
    return nil; 
}
- (void)dealloc
{
    [super dealloc];
}

- (BOOL)AddressBookSyncTableCreate
{
    @try {
        const char * createTable = nil;
        if (EAddressBookSyncGroup==idType) {
            createTable = "CREATE TABLE IF NOT EXISTS x_group_sync(id INTEGER PRIMARY KEY,groupID INTEGER,md5Value TEXT);CREATE INDEX IF NOT EXISTS idx_x_group_sync ON x_group_sync(groupID)";
        }
        else {
            createTable = "CREATE TABLE IF NOT EXISTS x_contact_sync(id INTEGER PRIMARY KEY,contactID INTEGER,md5Value TEXT);CREATE INDEX IF NOT EXISTS idx_x_group_sync ON x_contact_sync(contactID)";
        }
        char * errmsg;
        int flag = sqlite3_exec(shareDB, createTable, NULL, NULL, &errmsg);
        if (SQLITE_OK!=flag) {
            ccp_AddressLog(@"ERROR: Failed to create table x_group_sync or x_contact_sync!");
            sqlite3_free(errmsg);
            return DbDmlFailed;
        }
        return DbOk;
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return DbDmlFailed;
}

- (BOOL)addSyncMD5Data:(NSMutableDictionary *)hashData {
    @try {
        if (EAddressBookSyncGroup==idType) {
            const char * insertSql = "INSERT INTO x_group_sync(groupID,md5Value) values(?,?)";
            static Statement * stmtG = nil;
            if (nil==stmtG) {
                stmtG = [DBConnection statementWithQuery:insertSql];
                [stmtG retain];
            }
            int ret;
            for (NSNumber * key in [hashData allKeys]) {
                [stmtG bindInt32:key.intValue forIndex:1];
                [stmtG bindString:[hashData objectForKey:key] forIndex:2];
                ret = [stmtG step];
                if (SQLITE_DONE!=ret) {
                    ccp_AddressLog(@"ERROR: Failed to add record(%d,%@) into x_group_sync!",key.intValue,[hashData objectForKey:key]);
                }
                [stmtG reset];
            }
            return DbOk;
        }
        else {
            const char * insertSql = "INSERT INTO x_contact_sync(contactID,md5Value) values(?,?)";
            static Statement * stmt = nil;
            if (nil==stmt) {
                stmt = [DBConnection statementWithQuery:insertSql];
                [stmt retain];
            }
            int ret;
            for (NSNumber * key in [hashData allKeys]) {
                [stmt bindInt32:key.intValue forIndex:1];
                [stmt bindString:[hashData objectForKey:key] forIndex:2];
                ret = [stmt step];
                if (SQLITE_DONE!=ret) {
                    ccp_AddressLog(@"ERROR: Failed to add record(%d,%@) into x_contact_sync!",key.intValue,[hashData objectForKey:key]);
                }
                [stmt reset];
            }
            return DbOk;
        }
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return DbOk;
}
- (NSMutableDictionary *)getMD5Data {
    @try {
        NSMutableDictionary * forReturn = [[[NSMutableDictionary alloc] init] autorelease];
        if (EAddressBookSyncGroup==idType) {
            int gID;
            NSString * md5Value;
            const char * selSql = "SELECT groupID,md5Value FROM x_group_sync";
            static Statement * stmtG = nil;
            if (nil==stmtG) {
                stmtG = [DBConnection statementWithQuery:selSql];
                [stmtG retain];
            }
            while (SQLITE_ROW==[stmtG step]) {
                gID = [stmtG getInt32:0];
                md5Value = [stmtG getString:1];
                [forReturn setObject:md5Value forKey:[NSNumber numberWithInt:gID]];
            }
            [stmtG reset];
            if ([forReturn count]>0) {
                return forReturn;
            }
            else return nil;
        }
        else {
            int cID;
            NSString * md5Value;
            const char * selSql = "SELECT contactID,md5Value FROM x_contact_sync";
            static Statement * stmt = nil;
            if (nil==stmt) {
                stmt = [DBConnection statementWithQuery:selSql];
                [stmt retain];
            }
            while (SQLITE_ROW==[stmt step]) {
                cID = [stmt getInt32:0];
                md5Value = [stmt getString:1];
                [forReturn setObject:md5Value forKey:[NSNumber numberWithInt:cID]];
            }
            [stmt reset];
            if ([forReturn count]>0) {
                return forReturn;
            }
            else return nil;
        }
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return Nil;
}
- (BOOL)updateSyncTable:(NSMutableDictionary *) add Update:(NSMutableDictionary *)update Del:(NSArray *)del {
    @try {
        if (EAddressBookSyncGroup==idType) {
            int flag;
            if ([add count]>0) {
                flag = [self addSyncMD5Data:add];
            }
            if (DbOk==flag) {
                if ([update count]>0) {
                    const char * updateSql = "UPDATE x_group_sync SET md5Value = ? WHERE groupID = ?";
                    static Statement * stmtGupdate = nil;
                    if (nil==stmtGupdate) {
                        stmtGupdate = [DBConnection statementWithQuery:updateSql];
                        [stmtGupdate retain];
                    }
                    for (NSNumber * key in [update allKeys]) {
                        [stmtGupdate bindString:[update objectForKey:key] forIndex:1];
                        [stmtGupdate bindInt32:key.intValue forIndex:2];
                        
                        if (SQLITE_DONE!=[stmtGupdate step]) {
                            flag = DbDmlFailed;
                            ccp_AddressLog(@"ERROR: Failed to set new value(%d,%@) in x_group_sync!",key.intValue,[update objectForKey:key]);
                        }
                        [stmtGupdate reset];
                    }
                }
                if ([del count]>0) {
                    NSMutableString * delStr = [[NSMutableString alloc] init];
                    for (int count=0; count<[del count]-1; count++) {
                        [delStr appendFormat:@"%d,",[[del objectAtIndex:count] intValue]];
                    }
                    [delStr appendFormat:@"%d",[[del lastObject] intValue]];
                    NSString * strGroup = [NSString stringWithFormat:@"DELETE FROM x_group_sync where groupID in (%@)",delStr];
                    const char * delSql = [strGroup UTF8String];
                    char * errmsg;
                    flag = sqlite3_exec(shareDB, delSql, NULL, NULL, &errmsg);
                    if (SQLITE_OK!=flag) {
                        ccp_AddressLog(@"ERROR: Failed to delete the following records:%@",delStr);
                        sqlite3_free(errmsg);
                        [delStr release];
                        return DbDmlFailed;
                    }
                    [delStr release];
                    return DbOk;
                }
            }
            return DbDmlFailed;
        }
        else {
            int flag=DbOk;
            if ([add count]>0) {
                flag = [self addSyncMD5Data:add];
            }
            if (DbOk==flag) {
                if ([update count]>0) {
                    const char * updateSql = "UPDATE x_contact_sync SET md5Value = ? WHERE contactID = ?";
                    static Statement * stmtupdate = nil;
                    if (nil==stmtupdate) {
                        stmtupdate = [DBConnection statementWithQuery:updateSql];
                        [stmtupdate retain];
                    }
                    for (NSNumber * key in [update allKeys]) {
                        [stmtupdate bindString:[update objectForKey:key] forIndex:1];
                        [stmtupdate bindInt32:key.intValue forIndex:2];
                        
                        if (SQLITE_DONE!=[stmtupdate step]) {
                            flag = DbDmlFailed;
                            ccp_AddressLog(@"ERROR: Failed to set new value(%d,%@) in x_contact_sync!",key.intValue,[update objectForKey:key]);
                        }
                        [stmtupdate reset];
                    }
                }
                if ([del count]>0) {
                    NSMutableString * delStr = [[NSMutableString alloc] init];
                    for (int count=0; count<[del count]-1; count++) {
                        [delStr appendFormat:@"%d,",[[del objectAtIndex:count] intValue]];
                    }
                    [delStr appendFormat:@"%d",[[del lastObject] intValue]];
                    NSString * strContact = [NSString stringWithFormat:@"DELETE FROM x_contact_sync where contactID in (%@)",delStr];
                    const char * delSql = [strContact UTF8String];
                    char * errmsg;
                    flag = sqlite3_exec(shareDB, delSql, NULL, NULL, &errmsg);
                    if (SQLITE_OK!=flag) {
                        ccp_AddressLog(@"ERROR: Failed to delete the following records:%@",delStr);
                        sqlite3_free(errmsg);
                        [delStr release];
                        return DbDmlFailed;
                    }
                    [delStr release];
                    return DbOk;
                }
            }
            return DbDmlFailed;
        }
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return DbOk;
}

- (BOOL)cleanTable {
    if (EAddressBookSyncGroup==idType) {
        @try {
            const char * delSql = "DELETE FROM x_group_sync";
            static Statement * stmtG = nil;
            if (nil==stmtG) {
                stmtG = [DBConnection statementWithQuery:delSql];
                [stmtG retain];
            }
            if (SQLITE_DONE!=[stmtG step]) {
                ccp_AddressLog(@"ERROR: Failed to clean x_group_sync!");
                [stmtG reset];
                return DbDmlFailed;
            }
            [stmtG reset];
            return  DbOk;
        }
        @catch (NSException *exception) {
            ccp_AddressLog(@"Exception name=%@",exception.name);
            ccp_AddressLog(@"Exception reason=%@",exception.reason);
        }
        @finally {
        }
    } else {
        @try {
            const char * delSql = "DELETE FROM x_contact_sync";
            static Statement * stmt = nil;
            if (nil==stmt) {
                stmt = [DBConnection statementWithQuery:delSql];
                [stmt retain];
            }
            if (SQLITE_DONE!=[stmt step]) {
                ccp_AddressLog(@"ERROR: Failed to clean x_contact_sync!");
                [stmt reset];
                return DbDmlFailed;
            }
            [stmt reset];
            return  DbOk;
        }
        @catch (NSException *exception) {
            ccp_AddressLog(@"Exception name=%@",exception.name);
            ccp_AddressLog(@"Exception reason=%@",exception.reason);
        }
        @finally {
        }
    }
}

- (BOOL)updateDBFromAdressBook
{
    return DbOk;
}

- (void)composeDBFromAdressBook
{
    if (changeMutableDic != nil) {
        [changeMutableDic release];
        changeMutableDic = nil;
    }
    if (idMutableDic != nil) {
        [idMutableDic release];
        idMutableDic = nil;
    }
    changeMutableDic = [[NSMutableDictionary alloc] init];
    idMutableDic = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *newMutDic = [self getAllHashString];
    NSMutableDictionary *oldMutDic = [self getMD5Data];

    NSMutableSet *newMutSet = [[[NSMutableSet alloc] initWithArray:[newMutDic allKeys]] autorelease];
    NSMutableSet *oldMutSet = [[[NSMutableSet alloc] initWithArray:[oldMutDic allKeys]] autorelease];
    
    NSMutableSet *addMutSet = [[[NSMutableSet alloc] init] autorelease];
    NSMutableSet *delMutSet = [[[NSMutableSet alloc] init] autorelease];
    NSMutableSet *intersectMutSet = [[[NSMutableSet alloc] init] autorelease];
    [addMutSet setSet:newMutSet];
    [delMutSet setSet:oldMutSet];
    [intersectMutSet setSet:newMutSet];
    
    [addMutSet minusSet:oldMutSet];    
    [intersectMutSet intersectSet:oldMutSet];
    [delMutSet minusSet:newMutSet];
    
    NSArray *addArray = [addMutSet allObjects];
    for (NSNumber *addID in addArray) {
        [idMutableDic setObject:@"1" forKey:addID];
        NSString *hashString = [newMutDic objectForKey:addID];
        [changeMutableDic setObject:hashString forKey:addID];
    }
    
    NSArray *delArray = [delMutSet allObjects];
    for (NSNumber *delID in delArray) {
        [idMutableDic setObject:@"2" forKey:delID];
    }
    
    NSArray *intersectArray = [intersectMutSet allObjects];
    for (NSNumber *intersectID in intersectArray) {
        NSString *newHash = [newMutDic objectForKey:intersectID];
        NSString *oldHash = [oldMutDic objectForKey:intersectID];
        if (![newHash isEqualToString:oldHash]) {
            [idMutableDic setObject:@"3" forKey:intersectID];
            [changeMutableDic setObject:newHash forKey:intersectID];
        }
    }
}


- (NSMutableDictionary*)getContactsChangedCount
{
    if (changeMutableDic != nil) {
        [changeMutableDic release];
        changeMutableDic = nil;
    }
    if (idMutableDic != nil) {
        [idMutableDic release];
        idMutableDic = nil;
    }
    changeMutableDic = [[NSMutableDictionary alloc] init];
    idMutableDic = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *newMutDic = [self getAllHashString];
    NSMutableDictionary *oldMutDic = [self getMD5Data];
    
    NSMutableSet *newMutSet = [[[NSMutableSet alloc] initWithArray:[newMutDic allKeys]] autorelease];
    NSMutableSet *oldMutSet = [[[NSMutableSet alloc] initWithArray:[oldMutDic allKeys]] autorelease];    
    NSMutableSet *addMutSet = [[[NSMutableSet alloc] init] autorelease];
    NSMutableSet *delMutSet = [[[NSMutableSet alloc] init] autorelease];
    NSMutableSet *intersectMutSet = [[[NSMutableSet alloc] init] autorelease];
    [addMutSet setSet:newMutSet];
    [delMutSet setSet:oldMutSet];
    [intersectMutSet setSet:newMutSet];
    [addMutSet minusSet:oldMutSet];
    [intersectMutSet intersectSet:oldMutSet];
    [delMutSet minusSet:newMutSet];
    
    int editCount=0;
    NSArray *intersectArray = [intersectMutSet allObjects];
    for (NSNumber *intersectID in intersectArray) {
        NSString *newHash = [newMutDic objectForKey:intersectID];
        NSString *oldHash = [oldMutDic objectForKey:intersectID];
        if (![newHash isEqualToString:oldHash]) {
            editCount++;
        }
    }
        
    int addCount = [[addMutSet allObjects] count];
    int delCount = [[delMutSet allObjects] count];
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setObject:[NSNumber numberWithInt:addCount] forKey:@"addCount"];
    [dict setObject:[NSNumber numberWithInt:delCount] forKey:@"delCount"];
    [dict setObject:[NSNumber numberWithInt:editCount] forKey:@"editCount"];
    return  dict;
}

- (NSMutableDictionary *)getChangedInfo
{
    return idMutableDic;
}

- (BOOL)updateDBWithChangedInfo:(NSMutableArray *)contactIDArray
{
    if (changeMutableDic != nil) {
        
        if (idMutableDic.count <= 0) {
            return DbDmlFailed;
        }
        NSMutableDictionary *addMutDic = [[[NSMutableDictionary alloc] init] autorelease];
        NSMutableDictionary *updateMutDic = [[[NSMutableDictionary alloc] init] autorelease];
        NSMutableArray *delMutArray = [[[NSMutableArray alloc] init] autorelease];
        
        if (idType == EAddressBookSyncGroup) {
            for (NSNumber *groupID in [idMutableDic allKeys]) {
                NSString *value = [idMutableDic objectForKey:groupID];
                NSString *groupHashString = [changeMutableDic objectForKey:groupID];
                if ([value isEqualToString:@"1"] == YES) {
                    [addMutDic setObject:groupHashString forKey:groupID];
                }
                else if ([value isEqualToString:@"2"] == YES) {
                    [delMutArray addObject:groupID];
                }
                else if ([value isEqualToString:@"3"] == YES) {
                    [updateMutDic setObject:groupHashString forKey:groupID];
                }
            }
            [idMutableDic removeAllObjects];
        }
        else {
            for (NSNumber *contactID in contactIDArray) {
                NSString *value = [idMutableDic objectForKey:contactID];
                NSString *contactHashString = [changeMutableDic objectForKey:contactID];
                if ([value isEqualToString:@"1"] == YES) {
                    [addMutDic setObject:contactHashString forKey:contactID];
                }
                else if ([value isEqualToString:@"2"] == YES) {
                    [delMutArray addObject:contactID];
                }
                else if ([value isEqualToString:@"3"] == YES) {
                    [updateMutDic setObject:contactHashString forKey:contactID];
                }
                [idMutableDic removeObjectForKey:contactID];
            }
        }
        
        return [self updateSyncTable:addMutDic Update:updateMutDic Del:delMutArray];
    }
    else {
        return DbDmlFailed;
    }
}

- (BOOL)addItemByID:(NSInteger)itemID
{
    return DbOk;
}

- (BOOL)updateItemByID:(NSInteger)itemID
{
    return DbOk;
}

- (BOOL)delItmByID:(NSInteger)itemID
{
    return DbOk;
}

- (NSMutableDictionary *)getAllHashString
{
    NSMutableDictionary *hashMutDic = [[[NSMutableDictionary alloc] init] autorelease];
    AddressBookFuns *addressBookFuns = (AddressBookFuns *)[AddressBookFuns initAddressBookFuns];
    
    if (idType == EAddressBookSyncGroup) {
        NSArray *groupArray = [addressBookFuns groups];
        for (id group in groupArray)
        {
            ABRecordID groupID = ABRecordGetRecordID(group);
            
            NSString *groupHashString = [self getHashGroupString:group];
            
            [hashMutDic setObject:groupHashString forKey:[NSNumber numberWithInt:groupID]];
        }
    }
    else {
        NSArray *contactArray = [addressBookFuns contacts];
        for (id contact in contactArray) 
        {
            ABRecordID localID = ABRecordGetRecordID(contact);
            
            ccp_AddressLog(@"联系人哈希值ID:%d",localID);
            
            NSString *contactHashString = [self getHashContactString:contact addressBookFuns:addressBookFuns];
            
            [hashMutDic setObject:contactHashString forKey:[NSNumber numberWithInt:localID]];
        }
    }    
    return hashMutDic;
}

- (BOOL)wirteToSyncTable
{
    return [self addSyncMD5Data:[self getAllHashString]];
}

- (NSString *)getHashGroupString:(id)group
{
    NSString *groupString = (NSString *)ABRecordCopyCompositeName(group);
    
    return [CommonTools md5:[groupString autorelease]];
}

- (NSString *)getHashContactString:(id)contact addressBookFuns:(AddressBookFuns *)addressBookFuns
{
    NSMutableString *contactString = [[[NSMutableString alloc] init] autorelease];
    NSString *nickName = (NSString *)ABRecordCopyValue(contact, kABPersonNicknameProperty);
    
    if (nickName != nil)
    {
        [contactString appendString:nickName];
    }
    
    //名
    NSString *firstName = (NSString *)ABRecordCopyValue(contact, kABPersonFirstNameProperty);
    
    if (firstName != nil)
    {
        [contactString appendString:firstName];
    }
    
    //姓
    NSString *lastName = (NSString *)ABRecordCopyValue(contact, kABPersonLastNameProperty);
    
    if (lastName != nil)
    {
        [contactString appendString:lastName];
    }
    
    //名拼音
    NSString *firstNamePhonetic = (NSString *)ABRecordCopyValue(contact, kABPersonFirstNamePhoneticProperty);
    
    if (firstNamePhonetic != nil)
    {
        [contactString appendString:firstNamePhonetic];
        [firstNamePhonetic release];
    }
    
    //姓拼音
    NSString *lastNamePhonetic = (NSString *)ABRecordCopyValue(contact, kABPersonLastNamePhoneticProperty);
    
    if (lastNamePhonetic != nil)
    {
        [contactString appendString:lastNamePhonetic];
        [lastNamePhonetic release];
    }
    
    //prefix
    NSString *prefixStr = (NSString *)ABRecordCopyValue(contact, kABPersonPrefixProperty);
    
    if (prefixStr != nil)
    {
        [contactString appendString:prefixStr];
        [prefixStr release];
    }
    
    //middleName
    NSString *middleName = (NSString *)ABRecordCopyValue(contact, kABPersonMiddleNameProperty);
    
    if (middleName != nil)
    {
        [contactString appendString:middleName];
    }
    
    //suffix
    NSString *suffixStr = (NSString *)ABRecordCopyValue(contact, kABPersonSuffixProperty);
    
    if (suffixStr != nil)
    {
        [contactString appendString:suffixStr];
    }
    
    //读取电话
    ABMultiValueRef phoneProperty = ABRecordCopyValue((ABRecordRef)contact, kABPersonPhoneProperty);
    
    if (phoneProperty != nil)
    {
        for (int i = 0; i < ABMultiValueGetCount(phoneProperty); i++)
        {
            NSString *label = (NSString *)ABMultiValueCopyLabelAtIndex(phoneProperty, i);
            if (nil != label)
            {
                [contactString appendString:label];
            }
            
            NSString *phoneNo = (NSString *)ABMultiValueCopyValueAtIndex(phoneProperty, i);                
            
            if (phoneNo != nil)
            {
                [contactString appendString:phoneNo];
            }
            
            [label release];
            [phoneNo release];
        }
        
        CFRelease( phoneProperty );
    }
    
    //photo
    if (ABPersonHasImageData(contact))
    {
        //缩略图
        NSData *photoFormat = (NSData *)ABPersonCopyImageDataWithFormat(contact, kABPersonImageFormatThumbnail);
        
        NSMutableData *phoData= [[NSMutableData alloc] init];
        if (photoFormat.length < 50) 
        {
            [phoData appendData:photoFormat];
        }
        else
        {
            int nCount=5;   //图片字节分段数
            int nLocation = photoFormat.length/nCount;
            for (int i=0; i<nCount; i++) {
                NSRange range;
                range.length = 10;  //取分断的前十个字节
                range.location = nLocation*i;
                [phoData appendData:[photoFormat subdataWithRange:range]];
            }            
        }
        
        NSString *tempStr = [[phoData base64Encoding] description];
        if (nil != tempStr)
        {
            [contactString appendString:tempStr];
        }
        
        [phoData release];
        [photoFormat release];
    }
    
    //addr
    ABMultiValueRef address = ABRecordCopyValue(contact, kABPersonAddressProperty);
    
    if (address != nil)
    {
        int addressCount = ABMultiValueGetCount(address);
        
        for (int j = 0; j < addressCount; j++)
        {
            //获取地址Label
            NSString *addressLabel = (NSString *)ABMultiValueCopyLabelAtIndex(address, j);
            
            if (nil != addressLabel)
            {
                [contactString appendString:addressLabel];
            }
            
            //获取该地址下的属性
            NSDictionary *addressDic = (NSDictionary *)ABMultiValueCopyValueAtIndex(address, j);
            
            //国家
            NSString *countryValue = [addressDic valueForKey:(NSString *)kABPersonAddressCountryKey];
            
            if (countryValue != nil)
            {
                [contactString appendString:countryValue];
            }
            
            //国家代码
            NSString *countrycodeValue = [addressDic valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
            
            if (countrycodeValue != nil)
            {
                [contactString appendString:countrycodeValue];
            }
            
            //街道
            NSString *streetValue = [addressDic valueForKey:(NSString *)kABPersonAddressStreetKey];
            
            if (streetValue != nil)
            {
                [contactString appendString:streetValue];
            }
            
            //城市
            NSString *cityValue = [addressDic valueForKey:(NSString *)kABPersonAddressCityKey];
            
            if (cityValue != nil)
            {
                [contactString appendString:cityValue];
            }
            
            //省、地区
            NSString *regionValue = [addressDic valueForKey: (NSString *)kABPersonAddressStateKey];
            
            if (regionValue != nil)
            {
                [contactString appendString:regionValue];
            }
            
            //邮政编码 
            NSString *postcodeValue = [addressDic valueForKey: (NSString *)kABPersonAddressZIPKey];
            
            if (postcodeValue != nil)
            {
                [contactString appendString:postcodeValue];
            }
            
            [addressLabel release];
            [addressDic release];
        }
        
        CFRelease( address );
    }   
    
    //email
    ABMultiValueRef email = ABRecordCopyValue(contact, kABPersonEmailProperty);
    
    if (email != nil)
    {
        int emailCount = ABMultiValueGetCount(email);
        
        for (int k = 0; k < emailCount; k++)
        {
            //获取email label
            NSString *emailLabel = (NSString *)ABMultiValueCopyLabelAtIndex(email, k);
            if (nil != emailLabel)
            {
                [contactString appendString:emailLabel];
            }
            
            NSString *emailValue = (NSString *)ABMultiValueCopyValueAtIndex(email, k);
            if (nil != emailValue)
            {
                [contactString appendString:emailValue];
            }
            
            [emailLabel release];
            [emailValue release];
        }
        
        CFRelease( email );
    }
    
    //im
    ABMultiValueRef im = ABRecordCopyValue(contact, kABPersonInstantMessageProperty);
    
    if (im != nil)
    {
        int imCount = ABMultiValueGetCount(im);
        
        for (int m = 0; m < imCount; m++)
        {
            NSString *labelName = (NSString *)ABMultiValueCopyLabelAtIndex(im, m);
            if (labelName.length > 0)
            {
                [contactString appendString:labelName];
            }
            [labelName release];
            NSDictionary *imDic = (NSDictionary *)ABMultiValueCopyValueAtIndex(im, m);
            
            NSString *userName = [imDic valueForKey:(NSString *)kABPersonInstantMessageUsernameKey];
            
            if (userName != nil)
            {
                [contactString appendString:userName];
                
                NSString *service = [imDic valueForKey:(NSString *)kABPersonInstantMessageServiceKey];
                
                if (service != nil)
                {
                    [contactString appendString:service];
                }
            }
            
            [imDic release];
        }
        
        CFRelease( im );
    }
    
    //rperson
    ABMultiValueRef rperson = ABRecordCopyValue(contact, kABPersonRelatedNamesProperty);
    if (rperson != nil) {
        int rPersonCount = ABMultiValueGetCount(rperson);
        for (int n=0; n<rPersonCount; n++) {
            NSString *labelName = (NSString *)ABMultiValueCopyLabelAtIndex(rperson, n);
            if (labelName.length > 0)
            {
                [contactString appendString:labelName];
            }
            
            NSString *relatedName = (NSString *)ABMultiValueCopyValueAtIndex(rperson, n);
            if (relatedName != nil) {
                [contactString appendString:relatedName];
                [relatedName release];
            }
            [labelName release];
        }
        CFRelease( rperson );
    }
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0)
    {
        //twitter
        ABMultiValueRef twitters = [CommonTools TABRecordCopyValueOfSocialProfile:contact];
        
        if (twitters != nil)
        {
            int twitterCount = ABMultiValueGetCount(twitters);
            
            for (int m = 0; m < twitterCount; m++)
            {                
                NSDictionary *twitterDic = (NSDictionary *)ABMultiValueCopyValueAtIndex(twitters, m);
                
                NSString *userName = [twitterDic valueForKey:(NSString *)kABPersonSocialProfileUsernameKey];
                
                if (userName != nil)
                {
                    [contactString appendString:userName];
                    
                    NSString *service = [twitterDic valueForKey:(NSString *)kABPersonSocialProfileServiceKey];
                    
                    if (service != nil)
                    {
                        [contactString appendString:service];
                    }
                }
                
                [twitterDic release];
            }
            
            CFRelease( twitters );
        }
    }
    
    //org
    NSString *org = (NSString *)ABRecordCopyValue(contact, kABPersonOrganizationProperty);
    NSString *jobTitle = (NSString *)ABRecordCopyValue(contact, kABPersonJobTitleProperty);
    NSString *departTitle = (NSString *)ABRecordCopyValue(contact, kABPersonDepartmentProperty);
    
    if (org != nil)
    {
        [contactString appendString:org];
        [org release];
    }
    if (jobTitle != nil)
    {
        [contactString appendString:jobTitle];
        [jobTitle release];
    }
    if (departTitle != nil)
    {
        [contactString appendString:departTitle];
        [departTitle release];
    }
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    //event:other
    ABMultiValueRef dates = ABRecordCopyValue(contact, kABPersonDateProperty);
    
    if (dates != nil)
    {
        int datesCount = ABMultiValueGetCount(dates);
        
        for (int n = 0; n < datesCount; n++)
        {
            //获取dates Label
            NSString *dateLabel = (NSString *)ABMultiValueCopyLabelAtIndex(dates, n);
            if (dateLabel.length > 0)
            {
                [contactString appendString:dateLabel];
            }
            
            
            NSDate *dateValue = (NSDate *)ABMultiValueCopyValueAtIndex(dates, n);
            
            if (dateValue != nil)
            {
                NSString *dayStr = [formatter stringFromDate: dateValue];
                [contactString appendString:dayStr];
            }
            
            [dateLabel release];
            [dateValue release];
        }
        
        CFRelease( dates );
    }
    
    //event:birthday
    NSDate *birthday = (NSDate *)ABRecordCopyValue(contact, kABPersonBirthdayProperty);

    if (birthday != nil)
    {
        NSString *birthdayStr = [formatter stringFromDate: birthday];
        if (birthdayStr.length > 0)
        {
            [contactString appendString:birthdayStr];
        }
        
        [birthday release];
    }
    
    [formatter release];
    
    //website
    ABMultiValueRef url = ABRecordCopyValue(contact, kABPersonURLProperty);
    
    if (url != nil)
    {
        int urlCount = ABMultiValueGetCount(url);
        
        for (int z = 0; z < urlCount; z++)
        {
            NSString *urlLabel = (NSString *)ABMultiValueCopyLabelAtIndex(url, z);
            if (urlLabel.length > 0)
            {
                [contactString appendString:urlLabel];
            }
            
            
            NSString *urlValue = (NSString *)ABMultiValueCopyValueAtIndex(url, z);
            
            if ( urlValue != nil)
            {
                [contactString appendString:urlValue];
            }
            
            [urlLabel release];
            [urlValue release];
        }
        
        CFRelease( url );
    }
    
    //remark 在iPhone上为备忘录
    NSString *note = (NSString *)ABRecordCopyValue(contact, kABPersonNoteProperty);
    
    if (note != nil)
    {
        [contactString appendString:note];
        [note release];
    }
    
    //group
    NSArray *groupIDArray = [addressBookFuns getGroupList:contact];
    [groupIDArray sortedArrayUsingSelector:@selector(compare:)];
    if (groupIDArray != nil && [groupIDArray count] > 0)
    {
        NSMutableString *groupValue = [[NSMutableString alloc] init ];
        int groupCount = [groupIDArray count];
        for (int z=0; z < groupCount; z++)
        {
            NSString *tempStr = [NSString stringWithFormat:@"%d", [[groupIDArray objectAtIndex:z] intValue]];
            if (tempStr.length > 0)
            {
                [groupValue appendString:tempStr];
            }
        }
        if (groupValue.length > 0)
        {
            [contactString appendString:groupValue];
        }
        
        [groupValue release];
    }
    NSString *contactHashString = [CommonTools md5:contactString];
    ccp_AddressLog(@"上传时候的哈希串:%@",contactString);
    [nickName release];
    [firstName release];
    [lastName release];
    [middleName release];
    [suffixStr release];    
    return contactHashString;
}

@end
