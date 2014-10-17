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


#import <sqlite3.h>

//
// Interface for Statement
//
enum DbError
{
	DbOk =TRUE,
	DbDmlFailed=FALSE,
	DbCatch=FALSE
};

@interface Statement : NSObject
{
    sqlite3_stmt	*stmt;
	int				ncol;
}

+ (id)statementWithDB:(sqlite3*)db query:(const char*)sql;
- (id)initWithDB:(sqlite3*)db query:(const char*)sql;

- (int)fieldIndex:(const char*)fieldName;

// method
- (int)step;
- (void)reset;

// GetterBy Index
- (NSString*)getString:(int)index;
- (int)getInt32:(int)index;
- (long long)getInt64:(int)index;
- (NSData*)getData:(int)index;
- (double)getDouble:(int)index;

// Binder
- (int)bindString:(NSString*)value forIndex:(int)index;
- (void)bindInt32:(int)value forIndex:(int)index;
- (void)bindInt64:(long long)value forIndex:(int)index;
- (void)bindData:(NSData*)data forIndex:(int)index;
- (void)bindDouble:(double)value forIndex:(int)index;

@end



