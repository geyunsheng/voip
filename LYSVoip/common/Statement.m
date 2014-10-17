/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.yuntongxun.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */


#import "Statement.h"

@implementation Statement

- (id)initWithDB:(sqlite3*)db query:(const char*)sql
{
    @try {
        self = [super init];
        if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK)
        {

        }
        ncol = sqlite3_column_count(stmt);
        return self;
    }
    @catch (NSException *exception) {

    }
    @finally {
    }
    
}

+ (id)statementWithDB:(sqlite3*)db query:(const char*)sql
{
    return [[[Statement alloc] initWithDB:db query:sql] autorelease];
}

- (int)step
{
    return sqlite3_step(stmt);
}

- (void)reset
{
    sqlite3_reset(stmt);
}

- (void)dealloc
{
    sqlite3_finalize(stmt);
    stmt = NULL;
    [super dealloc];
}
-(int) fieldIndex:(const char* )fieldName
{
	if (0 == fieldName)
		return -1;
	
	for (int i = 0; i < ncol;i++ )
	{
		const char* szField = sqlite3_column_name(stmt, i);
		if (strcasecmp(fieldName, szField)== 0)
			return i;
	}
	return -1;
}

- (NSString*)getString:(int)index
{
	char *text = (char*)sqlite3_column_text(stmt, index);
	if (!text) {
		return nil;
	}
    NSString * forReturn = [[[NSString alloc] initWithUTF8String:text] autorelease];
    return forReturn;
}

- (int)getInt32:(int)index
{
    return (int)sqlite3_column_int(stmt, index);
}

- (long long)getInt64:(int)index
{
    return (long long)sqlite3_column_int64(stmt, index);
}

- (NSData*)getData:(int)index
{
    int length = sqlite3_column_bytes(stmt, index);
    return [NSData dataWithBytes:sqlite3_column_blob(stmt, index) length:length];
}

- (double)getDouble:(int)index
{
    return (double)sqlite3_column_double(stmt, index);
}

//
- (int)bindString:(NSString*)value forIndex:(int)index
{
    return sqlite3_bind_text(stmt, index, [value UTF8String], -1, SQLITE_TRANSIENT);
}

- (void)bindInt32:(int)value forIndex:(int)index
{
    sqlite3_bind_int(stmt, index, value);
}

- (void)bindInt64:(long long)value forIndex:(int)index
{
    sqlite3_bind_int64(stmt, index, value);
}

- (void)bindDouble:(double)value forIndex:(int)index
{
    sqlite3_bind_double(stmt, index, value);
}

- (void)bindData:(NSData*)value forIndex:(int)index
{
    sqlite3_bind_blob(stmt, index, value.bytes, value.length, SQLITE_TRANSIENT);
}
@end
