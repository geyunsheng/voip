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

#import "GroupDBAccess.h"

@implementation GroupDBAccess

- (GroupDBAccess *)init {
    if (self=[super init]) {
        shareDB = [DBConnection getSharedDatabase];
        [self groupTableCreate];
        return self;
    }
    return nil;
}
- (void)dealloc {
    [super dealloc];
}

- (BOOL)groupTableCreate {
    @try {
        const char * createTable = "create table if not exists x_group_order(id integer primary key,groupid integer,grouporder integer)";
        static Statement * createSql = nil;
        if (nil==createSql) {
            createSql = [DBConnection statementWithQuery:createTable];
            [createSql retain];
        }
        int ret = 0;
        ret = [createSql step];
        if (SQLITE_DONE!=ret) {
            ccp_AddressLog(@"ERROR: Failed to create x_group_order!");
            [createSql reset];
            return DbDmlFailed;
        }
        [createSql reset];
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

- (BOOL)addAllRecords:(NSArray *)groupArr {
    @try {
        const char * delSql = "delete from x_group_order";
        char * errmsg;
        int flagDel = sqlite3_exec(shareDB, delSql, NULL, NULL, &errmsg);
        if (SQLITE_OK!=flagDel) {
            sqlite3_free(errmsg);
            ccp_AddressLog(@"ERROR: Failed to delete x_group_order!");
            return DbDmlFailed;
        }
        
        BOOL flag = DbOk;
        const char * insertSql = "insert into x_group_order(groupid,grouporder) values (?,?)";
        static Statement * stmt = nil;
        if (nil==stmt) {
            stmt = [DBConnection statementWithQuery:insertSql];
            [stmt retain];
        }
        for (int cursor=0; cursor<[groupArr count]; cursor++) {
            [stmt bindInt32:[[groupArr objectAtIndex:cursor] intValue] forIndex:1];
            [stmt bindInt32:cursor forIndex:2];
            if (SQLITE_DONE!=[stmt step]) {
                ccp_AddressLog(@"ERROR: Failed to add %d to x_group_order!",[[groupArr objectAtIndex:cursor] intValue]);
                flag = DbDmlFailed;
            }
            [stmt reset];
        }
        return flag;
    }
    @catch (NSException *exception) {
        ccp_AddressLog(@"Exception name=%@",exception.name);
        ccp_AddressLog(@"Exception reason=%@",exception.reason);
    }
    @finally {
    }
    return DbDmlFailed;
}

- (NSDictionary *)getAllRecords {
    @try {
        const char * selectSql = "select grouporder,groupid from x_group_order";
        static Statement * stmt = nil;
        NSMutableDictionary * dicForReturn = [[NSMutableDictionary alloc] init];
        if (nil==stmt) {
            stmt = [DBConnection statementWithQuery:selectSql];
            [stmt retain];
        }
        while (SQLITE_ROW==[stmt step]) {
            [dicForReturn setObject:[NSNumber numberWithInt:[stmt getInt32:0]] forKey:[NSNumber numberWithInt:[stmt getInt32:1]]];
        }
        [stmt reset];
        if ([dicForReturn count]>0) {
            return [dicForReturn autorelease];
        }
        else {
            [dicForReturn release];
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

@end
