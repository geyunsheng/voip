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

#import "SearchDBAccess.h"

@implementation SearchDBAccess

- (SearchDBAccess *)init {
    if (self=[super init]) {
        shareDB = [DBConnection getSharedDatabase];
        return self;
    }
    return nil;
}

- (void) dealloc {
    [super dealloc];
}

- (BOOL)contactPinyinTableCreate {
    const char * createTable="CREATE TABLE IF NOT EXISTS x_contact_pinyin (id INTEGER PRIMARY KEY,contactPinyinProperty INTEGER ,contactPinyinLabel TEXT,identifier INTEGER,prefix TEXT,contactPinyin TEXT ,contactID INTEGER);CREATE INDEX IF NOT EXISTS idx_x_contact_pinyin on x_contact_pinyin(contactPinyinProperty,contactPinyin);CREATE INDEX IF NOT EXISTS idx_x_contact_pinyin2 on x_contact_pinyin(identifier,contactPinyinProperty,contactPinyin);CREATE INDEX IF NOT EXISTS idx_x_contact_pinyin_contactid on x_contact_pinyin(contactid)";
    char * errmsg;
    int flag = sqlite3_exec(shareDB,createTable,NULL,NULL,&errmsg);
    if(SQLITE_OK!=flag) {
        sqlite3_free(errmsg);
        ccp_AddressLog(@"ERROR: Failed to Create Table x_contact_pinyin");
        return DbDmlFailed;
    }
    return DbOk;
}

- (BOOL)initDB {
    const char * initSql = "select contactPinyinProperty, contactPinyinLabel,prefix, contactPinyin, contactID FROM x_contact_pinyin WHERE (contactPinyinProperty =4 or contactPinyinProperty =5) and  contactPinyin LIKE ? or contactPinyinProperty = 2 and  contactPinyin LIKE '2%' order by contactPinyinProperty limit 6";
//    flag = sqlite3_exec(shareDB, initSql, NULL, NULL, &errmsg);
    static Statement * stmt = nil;
    if (nil==stmt) {
        stmt = [DBConnection statementWithQuery:initSql];
        [stmt retain];
    }
    [stmt bindString:@"%6%9%" forIndex:1];
    if (SQLITE_ROW!=[stmt step]&&SQLITE_DONE!=[stmt step]) {
        ccp_AddressLog(@"ERROR: Failed to init database!");
        [stmt reset];
        return DbDmlFailed;
    }
    [stmt reset];
    return  DbOk;
}

- (BOOL)deleteAllFromPinyinTable {
    const char * deleteTable = "DELETE FROM x_contact_pinyin";
    char * errmsg;
    int flag = sqlite3_exec(shareDB, deleteTable, NULL, NULL, &errmsg);
    if (SQLITE_OK!=flag) {
        sqlite3_free(errmsg);
        ccp_AddressLog(@"ERROR: Failed to delete Table x_contact_pinyin");
        return DbDmlFailed;
    }
    return DbOk;
}

- (BOOL)deleteFromPinyinTableInArr:(NSString *)idArr {
    @try {
        NSString * strDel = [NSString stringWithFormat:@"DELETE FROM x_contact_pinyin WHERE contactID in (%@)",idArr];
        const char * deleteTable = [strDel UTF8String];
        char * errmsg;
        int flag = sqlite3_exec(shareDB, deleteTable, NULL, NULL, &errmsg);

        if (SQLITE_OK!=flag) {
            sqlite3_free(errmsg);
            ccp_AddressLog(@"ERROR: Failed to delete following records: %@",idArr);
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

- (int)saveSearchData:(int)property label:(NSString *)label Identifier:(int)identifier Pf:(NSString *)prefix value:(NSString *)pinyin contactID:(NSInteger)id {
    static Statement *stmt = nil;
    if(nil==stmt) {
        stmt=[DBConnection statementWithQuery:"INSERT INTO x_contact_pinyin(contactPinyinProperty,contactPinyinLabel,identifier,prefix,contactPinyin,contactID) VALUES(?,?,?,?,?,?)"];
        [stmt retain];
    }
    [stmt bindInt32:property forIndex:1];
    [stmt bindString:label forIndex:2];
    [stmt bindInt32:identifier forIndex:3];
    [stmt bindString:prefix forIndex:4];
    [stmt bindString:pinyin forIndex:5];
    [stmt bindInt32:id forIndex:6];
    int ret = [stmt step];
    if(SQLITE_DONE != ret) {
        [stmt reset];
        return -1;
    }
    [stmt reset];
    return 1;
}

- (int)getDataByPhone:(NSString *)phone 
{
//    ccp_AddressLog(@"phone=%@",phone);
    const char * Sqlstr = "SELECT contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 2 and (contactPinyin like ? or contactPinyin like ?)";
    static Statement *stmt = nil;
    if (nil==stmt) {
        stmt=[DBConnection statementWithQuery:Sqlstr]; 
        [stmt retain];
    }
    [stmt bindString:phone forIndex:1];
    [stmt bindString:[NSString stringWithFormat:@"+86%@",phone] forIndex:2];
    int contactID = 0;
    int ret = [stmt step];
    if (SQLITE_ROW==ret) {
        contactID = [stmt getInt32:0];
    }
    [stmt reset];
    return contactID;
}

- (NSArray *)getData:(NSString *)searchItem Second:(NSString *)second Third:(NSString *)third Range:(NSString *)range {
    NSString * strSql = nil;
    if (range.length>0)
    {
        strSql = [NSString stringWithFormat:@"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE (contactPinyinProperty = 0 and contactPinyin LIKE ? or contactPinyinProperty = 1 and contactPinyin LIKE ? or contactPinyinProperty = 3 and contactPinyin LIKE ?) and contactid in (%@) order by contactPinyinProperty",range];
    }
    else
    {
        strSql= [NSString stringWithFormat:@"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE (contactPinyinProperty = 0 and contactPinyin LIKE ? or contactPinyinProperty = 1 and contactPinyin LIKE ? or contactPinyinProperty = 3 and contactPinyin LIKE ?) order by contactPinyinProperty"];
    }
    Statement *stmt = nil;
    stmt=[DBConnection statementWithQuery:[strSql UTF8String]];
    [stmt retain];
    [stmt bindString:third forIndex:1];
    [stmt bindString:searchItem forIndex:2];
    [stmt bindString:second forIndex:3];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        [stmt release];
        return nil;
    }
    NSMutableArray * searchResult = [[NSMutableArray alloc] init];
    while (SQLITE_ROW==ret) {
        GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
        tempResult.contactPinyinProperty=[stmt getInt32:0];
        tempResult.contactPinyinLabel=[stmt getString:1];
        tempResult.contactPinyin=[stmt getString:2];
        tempResult.contactID=[stmt getInt32:3];
        
        [searchResult addObject:tempResult];
        [tempResult release];
        ret=[stmt step];
    }
    [stmt reset];
    [stmt release];
    return [searchResult autorelease];
    
}

- (NSArray *)getData:(NSString *)searchItem Second:(NSString *)second Third:(NSString *)third {
    static Statement *stmt = nil;
    if (nil==stmt) {
        stmt=[DBConnection statementWithQuery:"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactID>0 and (contactPinyinProperty = 0 and contactPinyin LIKE ? or contactPinyinProperty = 1 and contactPinyin LIKE ? or contactPinyinProperty = 3 and contactPinyin LIKE ?) order by contactPinyinProperty"];
        [stmt retain];
    }
    [stmt bindString:third forIndex:1];
    [stmt bindString:searchItem forIndex:2];
    [stmt bindString:second forIndex:3];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        return nil;
    }
    NSMutableArray * searchResult = [[NSMutableArray alloc] init];
    while (SQLITE_ROW==ret) {
        GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
        tempResult.contactPinyinProperty=[stmt getInt32:0];
        tempResult.contactPinyinLabel=[stmt getString:1];
        tempResult.contactPinyin=[stmt getString:2];
        tempResult.contactID=[stmt getInt32:3];
        
        [searchResult addObject:tempResult];
        [tempResult release];
        ret=[stmt step];
    }
    [stmt reset];
    return [searchResult autorelease];
    
}

- (NSArray *)getDataT9:(NSString *)searchItem Second:(NSString *)second otherPhoneNO:(BOOL)isSearch{
    if (isSearch)
    {
        static Statement *stmt = nil;
        if (nil==stmt) {
            stmt=[DBConnection statementWithQuery:"select contactPinyinProperty, contactPinyinLabel,prefix, contactPinyin, contactID FROM x_contact_pinyin WHERE contactPinyinProperty IN (4,5) and  contactPinyin LIKE ? or contactPinyinProperty = 2 and  contactPinyin LIKE ? order by identifier,contactPinyinProperty"];
            [stmt retain];
        }
        [stmt bindString:searchItem forIndex:1];
        [stmt bindString:second forIndex:2];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            return nil;
        }
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.prefix = [stmt getString:2];
            tempResult.contactPinyin=[stmt getString:3];
            tempResult.contactID=[stmt getInt32:4];
            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        return [searchResult autorelease];
    }
    else
    {
        static Statement *stmt = nil;
        if (nil==stmt) {
            stmt=[DBConnection statementWithQuery:"select contactPinyinProperty, contactPinyinLabel,prefix, contactPinyin, contactID FROM x_contact_pinyin WHERE contactID>0 and (contactPinyinProperty IN (4,5) and  contactPinyin LIKE ? or contactPinyinProperty = 2 and  contactPinyin LIKE ?) order by identifier,contactPinyinProperty"];
            [stmt retain];
        }
        [stmt bindString:searchItem forIndex:1];
        [stmt bindString:second forIndex:2];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            return nil;
        }
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.prefix = [stmt getString:2];
            tempResult.contactPinyin=[stmt getString:3];
            tempResult.contactID=[stmt getInt32:4];
            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        return [searchResult autorelease];
    }
    
}

- (NSArray *)getDataT9:(NSString *)searchItem Second:(NSString *)second Range:(NSString *)range {
    NSString * strSql = [NSString stringWithFormat:@"select contactPinyinProperty, contactPinyinLabel,prefix, contactPinyin, contactID FROM x_contact_pinyin WHERE (contactPinyinProperty IN (4,5) and  contactPinyin LIKE ? or contactPinyinProperty = 2 and  contactPinyin LIKE ?) and contactid in (%@) order by identifier,contactPinyinProperty",range];
    Statement *stmt = nil;
    stmt=[DBConnection statementWithQuery:[strSql UTF8String]];
    [stmt retain];
    [stmt bindString:searchItem forIndex:1];
    [stmt bindString:second forIndex:2];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        [stmt release];
        return nil;
    }
    NSMutableArray * searchResult = [[NSMutableArray alloc] init];
    while (SQLITE_ROW==ret) {
        GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
        tempResult.contactPinyinProperty=[stmt getInt32:0];
        tempResult.contactPinyinLabel=[stmt getString:1];
        tempResult.prefix = [stmt getString:2];
        tempResult.contactPinyin=[stmt getString:3];
        tempResult.contactID=[stmt getInt32:4];
        
        [searchResult addObject:tempResult];
        [tempResult release];
        ret=[stmt step];
    }
    [stmt reset];
    [stmt release];
    return [searchResult autorelease];
    
}

- (NSArray *)getDataWithPrefix:(NSString *)searchItem Range:(NSString *)range {
    NSString * strSql = [NSString stringWithFormat:@"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 0 and contactPinyin LIKE ? and contactid in (%@)",range];
    Statement *stmt = nil;
    stmt=[DBConnection statementWithQuery:[strSql UTF8String]];
    [stmt retain];
    [stmt bindString:searchItem forIndex:1];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        [stmt release];
        return nil;
    }
    NSMutableArray * searchResult = [[NSMutableArray alloc] init];
    while (SQLITE_ROW==ret) {
        GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
        tempResult.contactPinyinProperty=[stmt getInt32:0];
        tempResult.contactPinyinLabel=[stmt getString:1];
        tempResult.contactPinyin=[stmt getString:2];
        tempResult.contactID=[stmt getInt32:3];
        
        [searchResult addObject:tempResult];
        [tempResult release];
        ret=[stmt step];
    }
    [stmt reset];
    [stmt release];
    return [searchResult autorelease];
}

- (NSArray *)getDataWithPrefix:(NSString *)searchItem{
    static Statement *stmt = nil;
    if (nil==stmt) {
        stmt=[DBConnection statementWithQuery:"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactID>0 and contactpinyinproperty = 0 and contactPinyin LIKE ?"];
        [stmt retain];
    }
    [stmt bindString:searchItem forIndex:1];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        return nil;
    }
    NSMutableArray * searchResult = [[NSMutableArray alloc] init];
    while (SQLITE_ROW==ret) {
        GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
        tempResult.contactPinyinProperty=[stmt getInt32:0];
        tempResult.contactPinyinLabel=[stmt getString:1];
        tempResult.contactPinyin=[stmt getString:2];
        tempResult.contactID=[stmt getInt32:3];
        
        [searchResult addObject:tempResult];
        [tempResult release];
        ret=[stmt step];
    }
    [stmt reset];
    return [searchResult autorelease];
}

- (NSArray *)getDataWithPrefixT9WithOutRange:(NSString *)searchItem {
    NSString * strSql = [NSString stringWithFormat:@"select contactPinyinProperty, contactPinyinLabel, prefix, contactPinyin, contactID FROM x_contact_pinyin WHERE contactID>0 and (contactpinyinproperty = 4 or contactpinyinproperty = 2) and contactPinyin LIKE ? ORDER BY identifier,contactPinyinLabel"];
    static Statement *stmt = nil;
    if (nil==stmt) {
        stmt=[DBConnection statementWithQuery:[strSql UTF8String]];
        [stmt retain];
    }
    [stmt bindString:searchItem forIndex:1];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        return nil;
    }
    //计数器，仅取前20
    NSMutableArray * searchResult = [[NSMutableArray alloc] init];
    while (SQLITE_ROW==ret) {
        GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
        tempResult.contactPinyinProperty=[stmt getInt32:0];
        tempResult.contactPinyinLabel=[stmt getString:1];
        tempResult.prefix = [stmt getString:2];
        tempResult.contactPinyin=[stmt getString:3];
        tempResult.contactID=[stmt getInt32:4];
        
        [searchResult addObject:tempResult];
        [tempResult release];
        ret=[stmt step];
    }
    [stmt reset];
    return [searchResult autorelease];
}

- (NSArray *)getDataWithPrefixT9WithRange:(NSString *)searchItem Range:(NSString *)range {
    NSString * strSql = [NSString stringWithFormat:@"select contactPinyinProperty, contactPinyinLabel, prefix, contactPinyin, contactID FROM x_contact_pinyin WHERE (contactpinyinproperty = 4 or contactpinyinproperty = 2) and contactPinyin LIKE ? and contactid in (%@) ORDER BY identifier,contactPinyinLabel",range];
    Statement *stmt = nil;
    stmt=[DBConnection statementWithQuery:[strSql UTF8String]];
    [stmt retain];
    [stmt bindString:searchItem forIndex:1];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        [stmt release];
        return nil;
    }
    NSMutableArray * searchResult = [[NSMutableArray alloc] init];
    while (SQLITE_ROW==ret) {
        GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
        tempResult.contactPinyinProperty=[stmt getInt32:0];
        tempResult.contactPinyinLabel=[stmt getString:1];
        tempResult.prefix = [stmt getString:2];
        tempResult.contactPinyin=[stmt getString:3];
        tempResult.contactID=[stmt getInt32:4];
        
        [searchResult addObject:tempResult];
        [tempResult release];
        ret=[stmt step];
    }
    [stmt reset];
    [stmt release];
    return [searchResult autorelease];
}


- (NSArray *)getDataWithPrefixT9First:(NSString *)searchItem otherPhoneNO:(BOOL)isSearch{
    if (isSearch)
    {
        static Statement *stmt = nil;
        if (nil==stmt) {
            stmt=[DBConnection statementWithQuery:"select contactPinyinProperty, contactPinyinLabel, prefix, contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 4 and contactPinyin LIKE ? ORDER BY contactPinyinLabel limit 66"];
            [stmt retain];
        }
        [stmt bindString:searchItem forIndex:1];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            return nil;
        }
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.prefix = [stmt getString:2];
            tempResult.contactPinyin=[stmt getString:3];
            tempResult.contactID=[stmt getInt32:4];
            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        return [searchResult autorelease];
    }
    else
    {
        static Statement *stmt = nil;
        if (nil==stmt) {
            stmt=[DBConnection statementWithQuery:"select contactPinyinProperty, contactPinyinLabel, prefix, contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 4 and contactPinyin LIKE ? and contactID>0 ORDER BY contactPinyinLabel limit 66"];
            [stmt retain];
        }
        [stmt bindString:searchItem forIndex:1];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            return nil;
        }
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.prefix = [stmt getString:2];
            tempResult.contactPinyin=[stmt getString:3];
            tempResult.contactID=[stmt getInt32:4];
            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        return [searchResult autorelease];
    }
}

- (NSArray *)getDataWithPrefixT9Sec:(NSString *)searchItem Filter:(NSString *)filter otherPhoneNO:(BOOL)isSearch{
    if (isSearch)
    {
        NSString * sql = [NSString stringWithFormat:@"select contactPinyinProperty, contactPinyinLabel, prefix, contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 4 and contactPinyin LIKE ? and contactid not in (%@) ORDER BY contactPinyinLabel limit 66",filter];
        Statement *stmt = nil;
        stmt=[DBConnection statementWithQuery:[sql UTF8String]];
        [stmt retain];
        [stmt bindString:searchItem forIndex:1];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            [stmt release];
            return nil;
        }
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.prefix = [stmt getString:2];
            tempResult.contactPinyin=[stmt getString:3];
            tempResult.contactID=[stmt getInt32:4];
            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        [stmt release];
        return [searchResult autorelease];
    }
    else
    {
        NSString * sql = [NSString stringWithFormat:@"select contactPinyinProperty, contactPinyinLabel, prefix, contactPinyin, contactID FROM x_contact_pinyin WHERE contactID>0 and contactpinyinproperty = 4 and contactPinyin LIKE ? and contactid not in (%@) ORDER BY contactPinyinLabel limit 66",filter];
        Statement *stmt = nil;
        stmt=[DBConnection statementWithQuery:[sql UTF8String]];
        [stmt retain];
        [stmt bindString:searchItem forIndex:1];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            [stmt release];
            return nil;
        }
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.prefix = [stmt getString:2];
            tempResult.contactPinyin=[stmt getString:3];
            tempResult.contactID=[stmt getInt32:4];
            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        [stmt release];
        return [searchResult autorelease];

    }
}

- (NSArray *)getDataWithPrefixT9:(NSString *)searchItem Filter:(NSString *)filter otherPhoneNO:(BOOL)isSearch{
    if (isSearch)
    {
        NSString * sql = [NSString stringWithFormat:@"select contactPinyinProperty, contactPinyinLabel, prefix, contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty IN (2,4) and contactPinyin LIKE ? and contactid not in (%@) ORDER BY identifier,contactPinyinProperty",filter];
        Statement *stmt = nil;
        stmt=[DBConnection statementWithQuery:[sql UTF8String]];
        [stmt retain];
        [stmt bindString:searchItem forIndex:1];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            [stmt release];
            return nil;
        }
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.prefix = [stmt getString:2];
            tempResult.contactPinyin=[stmt getString:3];
            tempResult.contactID=[stmt getInt32:4];            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        [stmt release];
        return [searchResult autorelease];
    }
    else
    {
        NSString * sql = [NSString stringWithFormat:@"select contactPinyinProperty, contactPinyinLabel, prefix, contactPinyin, contactID FROM x_contact_pinyin WHERE contactID>0 and contactpinyinproperty IN (2,4) and contactPinyin LIKE ? and contactid not in (%@) ORDER BY identifier,contactPinyinProperty",filter];
        Statement *stmt = nil;
        stmt=[DBConnection statementWithQuery:[sql UTF8String]];
        [stmt retain];
        [stmt bindString:searchItem forIndex:1];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            [stmt release];
            return nil;
        }
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.prefix = [stmt getString:2];
            tempResult.contactPinyin=[stmt getString:3];
            //        ccp_AddressLog(@"tempResult.contactPinyin=%@",tempResult.contactPinyin);
            tempResult.contactID=[stmt getInt32:4];
            //        ccp_AddressLog(@"tempResult.contactID=%d",tempResult.contactID);
            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        [stmt release];
        return [searchResult autorelease];
    }
}

- (NSArray *)getDataWithNumberFirst:(NSString *)searchItem Range:(NSString *)range {
    NSString *strSql = nil;
    if (0 == range.length)
    {
        strSql = [NSString stringWithFormat:@"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 2 and contactPinyin LIKE ? order by identifier limit 66"];
    }
    else
    {
        strSql = [NSString stringWithFormat:@"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 2 and contactPinyin LIKE ? and contactid in (%@) order by identifier limit 66",range];
    }
    
    Statement *stmt = nil;
    stmt=[DBConnection statementWithQuery:[strSql UTF8String]];
    [stmt retain];
    [stmt bindString:searchItem forIndex:1];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        [stmt release];
        return nil;
    }
    NSMutableArray * searchResult = [[NSMutableArray alloc] init];
    while (SQLITE_ROW==ret) {
        GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
        tempResult.contactPinyinProperty=[stmt getInt32:0];
        tempResult.contactPinyinLabel=[stmt getString:1];
        tempResult.contactPinyin=[stmt getString:2];
        tempResult.contactID=[stmt getInt32:3];
        
        [searchResult addObject:tempResult];
        [tempResult release];
        ret=[stmt step];
    }
    [stmt reset];
    [stmt release];
    return [searchResult autorelease];
}

- (NSArray *)getDataWithNumberFirst:(NSString *)searchItem otherPhoneNO:(BOOL)isSearch{
    if (isSearch)
    {
        static Statement *stmt = nil;
        if (nil==stmt) {
            stmt=[DBConnection statementWithQuery:"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 2 and contactPinyin LIKE ? order by identifier"];
            [stmt retain];
        }
        [stmt bindString:searchItem forIndex:1];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            return nil;
        }
        int counter = 0;
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret&&counter++<50) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.contactPinyin=[stmt getString:2];
            tempResult.contactID=[stmt getInt32:3];
            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        return [searchResult autorelease];
    }
    else
    {
        static Statement *stmt = nil;
        if (nil==stmt) {
            stmt=[DBConnection statementWithQuery:"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactID>0 and contactpinyinproperty = 2 and contactPinyin LIKE ? order by identifier"];
            [stmt retain];
        }
        [stmt bindString:searchItem forIndex:1];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            return nil;
        }
        int counter = 0;
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret&&counter++<50) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.contactPinyin=[stmt getString:2];
            tempResult.contactID=[stmt getInt32:3];
            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        return [searchResult autorelease];
    }
}

/*此函数为数字第二批搜索
 *range为搜索的范围
 *filter为需要过滤的联系人ID
 */

- (NSArray *)getDataWithNumber:(NSString *)searchItem WithRange:(NSString *)range WithFilter:(NSString *)filter {
    NSString * sql;
    if (range.length > 0)
    {
        if (filter.length > 0)
        {
            sql = [[NSString alloc] initWithFormat:@"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 2 and contactPinyin LIKE ? and contactid in (%@) and contactid not in (%@) order by identifier",range,filter];
        }
        else {
            sql = [[NSString alloc] initWithFormat:@"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 2 and contactPinyin LIKE ? and contactid in (%@) order by identifier",range];
        }
    }
    else
    {
        if (filter.length>0) {
            sql = [[NSString alloc] initWithFormat:@"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 2 and contactPinyin LIKE ? and contactid not in (%@) order by identifier",filter];
        }
        else {
            sql = [[NSString alloc] initWithFormat:@"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 2 and contactPinyin LIKE ? order by identifier"];
        }
    }
    
    Statement *stmt = nil;
    stmt=[DBConnection statementWithQuery:[sql UTF8String]];
    [stmt retain];
    [sql release];
    [stmt bindString:searchItem forIndex:1];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        [stmt release];
        return nil;
    }
    NSMutableArray * searchResult = [[NSMutableArray alloc] init];
    while (SQLITE_ROW==ret) {
        GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
        tempResult.contactPinyinProperty=[stmt getInt32:0];
        tempResult.contactPinyinLabel=[stmt getString:1];
        tempResult.contactPinyin=[stmt getString:2];
        tempResult.contactID=[stmt getInt32:3];
        
        [searchResult addObject:tempResult];
        [tempResult release];
        ret=[stmt step];
    }
    [stmt reset];
    [stmt release];
    return [searchResult autorelease];
}


- (NSArray *)getDataWithNumber:(NSString *)searchItem Filter:(NSString *)filter  otherPhoneNO:(BOOL)isSearch{

    NSString * sql;
    if (isSearch)
    {
        if (nil==filter) {
            sql = [[NSString alloc] initWithFormat:@"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 2 and contactPinyin LIKE ? order by identifier"];
        }
        else {
            sql = [[NSString alloc] initWithFormat:@"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 2 and contactPinyin LIKE ? and contactid not in (%@) order by identifier",filter];
        }
    }
    else
    {
        if (nil==filter) {
            sql = [[NSString alloc] initWithFormat:@"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactID>0 and contactpinyinproperty = 2 and contactPinyin LIKE ? order by identifier"];
        }
        else {
            sql = [[NSString alloc] initWithFormat:@"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactID>0 and contactpinyinproperty = 2 and contactPinyin LIKE ? and contactid not in (%@) order by identifier",filter];
        }
    }
    
    Statement *stmt = nil;
    stmt=[DBConnection statementWithQuery:[sql UTF8String]];
    [stmt retain];
    [sql release];
    [stmt bindString:searchItem forIndex:1];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        [stmt release];
        return nil;
    }
    NSMutableArray * searchResult = [[NSMutableArray alloc] init];
    while (SQLITE_ROW==ret) {
        GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
        tempResult.contactPinyinProperty=[stmt getInt32:0];
        tempResult.contactPinyinLabel=[stmt getString:1];
        tempResult.contactPinyin=[stmt getString:2];
        tempResult.contactID=[stmt getInt32:3];
        
        [searchResult addObject:tempResult];
        [tempResult release];
        ret=[stmt step];
    }
    [stmt reset];
    [stmt release];
    return [searchResult autorelease];
}

- (NSArray *)getDataWithNumberBatch:(NSString *)searchItem otherPhoneNO:(BOOL)isSearch{
    if (isSearch)
    {
        static Statement *stmt = nil;
        if (nil==stmt) {
            stmt=[DBConnection statementWithQuery:"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 2 and contactPinyin LIKE ? order by identifier limit 66"];
            [stmt retain];
        }
        [stmt bindString:searchItem forIndex:1];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            return nil;
        }
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.contactPinyin=[stmt getString:2];
            tempResult.contactID=[stmt getInt32:3];
            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        return [searchResult autorelease];
    }
    else
    {
        static Statement *stmt = nil;
        if (nil==stmt) {
            stmt=[DBConnection statementWithQuery:"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactID>0 and contactpinyinproperty = 2 and contactPinyin LIKE ? order by identifier limit 66"];
            [stmt retain];
        }
        [stmt bindString:searchItem forIndex:1];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            return nil;
        }
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.contactPinyin=[stmt getString:2];
            tempResult.contactID=[stmt getInt32:3];
            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        return [searchResult autorelease];
    }
}

- (NSArray *)getDataWithNumber:(NSString *)searchItem  otherPhoneNO:(BOOL)isSearch{
    if (isSearch)
    {
        static Statement *stmt = nil;
        if (nil==stmt) {
            stmt=[DBConnection statementWithQuery:"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactpinyinproperty = 2 and contactPinyin LIKE ? order by identifier"];
            [stmt retain];
        }
        [stmt bindString:searchItem forIndex:1];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            return nil;
        }
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.contactPinyin=[stmt getString:2];
            tempResult.contactID=[stmt getInt32:3];
            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        return [searchResult autorelease];
    }
    else
    {
        static Statement *stmt = nil;
        if (nil==stmt) {
            stmt=[DBConnection statementWithQuery:"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactID>0 and contactpinyinproperty = 2 and contactPinyin LIKE ? order by identifier"];
            [stmt retain];
        }
        [stmt bindString:searchItem forIndex:1];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            return nil;
        }
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.contactPinyin=[stmt getString:2];
            tempResult.contactID=[stmt getInt32:3];
            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        return [searchResult autorelease];
    }
}

- (NSArray *)getData:(NSString *)searchItem Sec:(NSString *)second Third:(NSString*)third Fourth:(NSString*)fourth  Fifth:(NSString *)fifth Sixth:(NSString *)sixth Range:(NSString *)range {
    NSString * strSql = [NSString stringWithFormat:@"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE (contactPinyinProperty = 0 and contactPinyin like ? or contactPinyinProperty = 1 and (contactPinyin LIKE ? or contactPinyin LIKE ? or contactPinyin LIKE ? or contactPinyin LIKE ?) or contactPinyinProperty = 3 and contactPinyin LIKE ?) and contactid in (%@) order by contactPinyinProperty",range];
    Statement *stmt = nil;
    stmt=[DBConnection statementWithQuery:[strSql UTF8String]];
    [stmt retain];
    [stmt bindString:sixth forIndex:1];
    [stmt bindString:searchItem forIndex:2];
    [stmt bindString:second forIndex:3];
    [stmt bindString:third forIndex:4];
    [stmt bindString:fourth forIndex:5];
    [stmt bindString:fifth forIndex:6];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        [stmt release];
        return nil;
    }
    NSMutableArray * searchResult = [[NSMutableArray alloc] init];
    while (SQLITE_ROW==ret) {
        GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
        tempResult.contactPinyinProperty=[stmt getInt32:0];
        tempResult.contactPinyinLabel=[stmt getString:1];
        tempResult.contactPinyin=[stmt getString:2];
        tempResult.contactID=[stmt getInt32:3];
        
        [searchResult addObject:tempResult];
        [tempResult release];
        ret=[stmt step];
    }
    [stmt reset];
    [stmt release];
    return [searchResult autorelease];
    
}


- (NSArray *)getData:(NSString *)searchItem Sec:(NSString *)second Third:(NSString*)third Fourth:(NSString*)fourth  Fifth:(NSString *)fifth Sixth:(NSString *)sixth{
    static Statement *stmt = nil;
    if (nil==stmt) {
        stmt=[DBConnection statementWithQuery:"select contactPinyinProperty, contactPinyinLabel,contactPinyin, contactID FROM x_contact_pinyin WHERE contactID>0 and contactPinyinProperty = 0 and contactPinyin like ? or contactPinyinProperty = 1 and (contactPinyin LIKE ? or contactPinyin LIKE ? or contactPinyin LIKE ? or contactPinyin LIKE ?) or contactPinyinProperty = 3 and contactPinyin LIKE ? order by contactPinyinProperty"];
        [stmt retain];
    }
    [stmt bindString:sixth forIndex:1];
    [stmt bindString:searchItem forIndex:2];
    [stmt bindString:second forIndex:3];
    [stmt bindString:third forIndex:4];
    [stmt bindString:fourth forIndex:5];
    [stmt bindString:fifth forIndex:6];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        return nil;
    }
    NSMutableArray * searchResult = [[NSMutableArray alloc] init];
    while (SQLITE_ROW==ret) {
        GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
        tempResult.contactPinyinProperty=[stmt getInt32:0];
        tempResult.contactPinyinLabel=[stmt getString:1];
        tempResult.contactPinyin=[stmt getString:2];
        tempResult.contactID=[stmt getInt32:3];
        
        [searchResult addObject:tempResult];
        [tempResult release];
        ret=[stmt step];
    }
    [stmt reset];
    return [searchResult autorelease];
    
}

- (NSArray *)getDataT9:(NSString *)searchItem Sec:(NSString *)second Third:(NSString*)third Fourth:(NSString*)fourth  Fifth:(NSString *)fifth Six:(NSString *)sixth Range:(NSString *)range {
    NSString * strSql = [NSString stringWithFormat:@"select contactPinyinProperty, contactPinyinLabel, prefix, contactPinyin, contactID FROM x_contact_pinyin WHERE (contactPinyinProperty = 4 and contactPinyin LIKE ? or contactPinyinProperty = 5 and (contactPinyin LIKE ? or contactPinyin LIKE ? or contactPinyin LIKE ? or contactPinyin LIKE ?) or contactPinyinProperty = 2 and contactPinyin LIKE ?) and contactid in (%@) order by identifier,contactPinyinProperty",range];
    Statement *stmt = nil;
    stmt=[DBConnection statementWithQuery:[strSql UTF8String]];
    [stmt retain];
    [stmt bindString:sixth forIndex:1];
    [stmt bindString:searchItem forIndex:2];
    [stmt bindString:second forIndex:3];
    [stmt bindString:third forIndex:4];
    [stmt bindString:fourth forIndex:5];
    [stmt bindString:fifth forIndex:6];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        [stmt release];
        return nil;
    }
    NSMutableArray * searchResult = [[NSMutableArray alloc] init];
    while (SQLITE_ROW==ret) {
        GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
        tempResult.contactPinyinProperty=[stmt getInt32:0];
        tempResult.contactPinyinLabel=[stmt getString:1];
        tempResult.prefix = [stmt getString:2];
        tempResult.contactPinyin=[stmt getString:3];
        tempResult.contactID=[stmt getInt32:4];
        
        [searchResult addObject:tempResult];
        [tempResult release];
        ret=[stmt step];
    }
    [stmt reset];
    [stmt release];
    return [searchResult autorelease];
}

- (NSArray *)getDataT9:(NSString *)searchItem Sec:(NSString *)second Third:(NSString*)third Fourth:(NSString*)fourth  Fifth:(NSString *)fifth Six:(NSString *)sixth otherPhoneNO:(BOOL)isSearch{
    
    if (isSearch)
    {
        static Statement *stmt = nil;
        if (nil==stmt) {
            stmt=[DBConnection statementWithQuery:"select contactPinyinProperty, contactPinyinLabel, prefix, contactPinyin, contactID FROM x_contact_pinyin WHERE contactPinyinProperty = 4 and contactPinyin LIKE ? or contactPinyinProperty = 5 and (contactPinyin LIKE ? or contactPinyin LIKE ? or contactPinyin LIKE ? or contactPinyin LIKE ?) or contactPinyinProperty = 2 and contactPinyin LIKE ? order by identifier,contactPinyinProperty"];
            [stmt retain];
        }
        [stmt bindString:sixth forIndex:1];
        [stmt bindString:searchItem forIndex:2];
        [stmt bindString:second forIndex:3];
        [stmt bindString:third forIndex:4];
        [stmt bindString:fourth forIndex:5];
        [stmt bindString:fifth forIndex:6];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            return nil;
        }
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.prefix = [stmt getString:2];
            tempResult.contactPinyin=[stmt getString:3];
            tempResult.contactID=[stmt getInt32:4];
            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        return [searchResult autorelease];
    }
    else
    {
        static Statement *stmt = nil;
        if (nil==stmt) {
            stmt=[DBConnection statementWithQuery:"select contactPinyinProperty, contactPinyinLabel, prefix, contactPinyin, contactID FROM x_contact_pinyin WHERE contactID>0 and (contactPinyinProperty = 4 and contactPinyin LIKE ? or contactPinyinProperty = 5 and (contactPinyin LIKE ? or contactPinyin LIKE ? or contactPinyin LIKE ? or contactPinyin LIKE ?) or contactPinyinProperty = 2 and contactPinyin LIKE ?) order by identifier,contactPinyinProperty"];
            [stmt retain];
        }
        [stmt bindString:sixth forIndex:1];
        [stmt bindString:searchItem forIndex:2];
        [stmt bindString:second forIndex:3];
        [stmt bindString:third forIndex:4];
        [stmt bindString:fourth forIndex:5];
        [stmt bindString:fifth forIndex:6];
        int ret = [stmt step];
        if (ret != SQLITE_ROW) {
            [stmt reset];
            return nil;
        }
        NSMutableArray * searchResult = [[NSMutableArray alloc] init];
        while (SQLITE_ROW==ret) {
            GetSearchDataObj *tempResult = [[GetSearchDataObj alloc]init];
            tempResult.contactPinyinProperty=[stmt getInt32:0];
            tempResult.contactPinyinLabel=[stmt getString:1];
            tempResult.prefix = [stmt getString:2];
            tempResult.contactPinyin=[stmt getString:3];
            tempResult.contactID=[stmt getInt32:4];
            
            [searchResult addObject:tempResult];
            [tempResult release];
            ret=[stmt step];
        }
        [stmt reset];
        return [searchResult autorelease];
    }
}

- (NSArray *)getAllPhoneNum {
    @try {
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        const char * getAllPhone = "select distinct contactpinyin from x_contact_pinyin where contactpinyinproperty = 2";
        NSMutableArray * arrForReturn = [[NSMutableArray alloc] init];
        static Statement * stmt = nil;
        if (nil==stmt) {
            stmt = [DBConnection statementWithQuery:getAllPhone];
            [stmt retain];
        }
        while (SQLITE_ROW==[stmt step]) {
            [arrForReturn addObject:[stmt getString:0]];
        }
        [stmt reset];
        if ([arrForReturn count]>0) {
            [pool drain];
            return [arrForReturn autorelease];
        }
        [arrForReturn release];
        [pool drain];
        return  nil;
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return nil;
}

- (NSArray *)getIDsByphone:(NSString *)phone {
    @try {
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        const char * getIDs = "select distinct contactid from x_contact_pinyin where contactpinyinproperty = 2 and contactpinyin = ?";
        NSMutableArray * arrForReturn = [[NSMutableArray alloc] init];
        static Statement * stmt = nil;
        if (nil==stmt) {
            stmt = [DBConnection statementWithQuery:getIDs];
            [stmt retain];
        }
        [stmt bindString:phone forIndex:1];
        while (SQLITE_ROW==[stmt step]) {
            [arrForReturn addObject:[stmt getString:0]];
        }
        [stmt reset];
        if ([arrForReturn count]>0) {
            [pool drain];
            return [arrForReturn autorelease];
        }
        [arrForReturn release];
        [pool drain];
        return  nil;
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return nil;
}

- (int)getContactIDByString:(NSString *)str {
    @try {
        int contactID = 0;
        const char * select = "select contactid from x_contact_pinyin where (contactpinyinproperty = 0 or contactpinyinproperty = 1) and upper(contactpinyinlabel) = upper(?) limit 1";
        static Statement * stmt = nil;
        if (nil==stmt) {
            stmt = [DBConnection statementWithQuery:select];
            [stmt retain];
        }
        [stmt bindString:str forIndex:1];
        if (SQLITE_ROW==[stmt step]) {
            contactID = [stmt getInt32:0];
        }
        [stmt reset];
        return contactID;
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
}

@end
