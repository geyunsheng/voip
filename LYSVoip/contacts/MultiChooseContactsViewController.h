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

#import "ContactBaseViewController.h"
#define MULTIPHOME_TABLE_ROW_HEIGHT 44

@protocol ChooseMultiPhonesDelegate <NSObject>

-(void)getPhoneNumbers:(NSArray*) phoneNumbers;
@end


@interface MultiChooseContactsViewController : ContactBaseViewController
{
    GetSearchDataObj                            *_selectedContact;
    NSInteger                                   _selectedRow;
    NSInteger                                   _selectedSection;

}
@property (nonatomic, assign) NSInteger    maxCount;
@property (nonatomic, retain) NSMutableArray    *selectedArray;
@property(nonatomic,assign) id<ChooseMultiPhonesDelegate> delegate;
@end
