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

#import "SelectPhoneNOViewController.h"



@interface SelectPhoneNOViewController ()

@end

@implementation SelectPhoneNOViewController

@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GetSearchDataObj* infoItem = nil;
    AddressBookContactSearchResult* contactInfo;
    if(tableView.tag != ContactsViewController_ContactsTableView)//搜索出来的联系人选择的话就跳到详情界面
    {
        infoItem = [self.filteredListContent objectAtIndex:indexPath.row];
        contactInfo = [self.modelEngineVoip.addressBookContactList getContactByID:infoItem.contactID];
    }
    else
    {
        NSString *key = [keys objectAtIndex:indexPath.section];
        NSArray *nameSection = [ContactsList objectForKey:key];
        infoItem = [nameSection objectAtIndex:indexPath.row];
        contactInfo = [self.modelEngineVoip.addressBookContactList getContactByID:infoItem.contactID];
    }
    
    if ([contactInfo.phoneArray count] <= 1)//没有号码给出提示
    {
        [self popPromptViewWithMsg:@"该联系人没有电话号码"];
    }
    else if ([contactInfo.phoneArray count] == 2)//只有一个号码直接返回
    {
        [self.delegate getPhoneNumber:[contactInfo.phoneArray objectAtIndex:1]];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([contactInfo.phoneArray count] >= 2)
    {
        UIActionSheet *menu = [[UIActionSheet alloc]
                               initWithTitle: @"选择电话"
                               delegate:self
                               cancelButtonTitle:nil
                               destructiveButtonTitle:nil
                               otherButtonTitles:nil];
        int i = 0;
        for (NSString* phone in contactInfo.phoneArray)
        {
            if (i % 2 != 0)
            {
                [menu addButtonWithTitle:phone];
            }
            i++;
        }
        [menu addButtonWithTitle:@"取消"];
        [menu setCancelButtonIndex: [contactInfo.phoneArray count] / 2];
        [menu showInView:self.view.window];
        [menu release];
    
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == actionSheet.cancelButtonIndex)
    {
        return;
    }
    NSString *selectStr = [actionSheet buttonTitleAtIndex:buttonIndex];
    [self.delegate getPhoneNumber:selectStr];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    self.delegate = nil;
    [super dealloc];
}
@end
