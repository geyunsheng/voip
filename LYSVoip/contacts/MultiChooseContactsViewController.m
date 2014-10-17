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
#import "MultiChooseContactsViewController.h"
#import "selectTableCell.h"

#define MULTIPHONE_TABLE_TAG 13
@interface MultiChooseContactsViewController ()

@end

@implementation MultiChooseContactsViewController

@synthesize maxCount;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _selectedRow = -1;
    _selectedSection = -1;
    if (self.maxCount <=0)
    {
        self.maxCount = 5;
    }
    NSMutableArray* tmpArray = [[NSMutableArray alloc] init];
    self.selectedArray = tmpArray;
    [tmpArray release];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithTitle:@"确定" target:self action:@selector(confirm)]];
    self.navigationItem.rightBarButtonItem = right;
    [right release];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == ContactsViewController_ContactsTableView)
    {
        return 20;
    }
    
    if (tableView.tag!=MULTIPHONE_TABLE_TAG)
    {
        return 20;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == MULTIPHONE_TABLE_TAG)
    {
        return MULTIPHOME_TABLE_ROW_HEIGHT;
    }
    else
    {
        if ((indexPath.row == _selectedRow) && (_selectedSection==indexPath.section))
        {
            return (46+_selectedContact.phoneArr.count*MULTIPHOME_TABLE_ROW_HEIGHT);
        }
        
        return 44;
    }
    
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == ContactsViewController_ContactsTableView)
    {
        NSString *key = [keys objectAtIndex:section];
        NSArray *contact = [ContactsList objectForKey:key];
        return [contact count];
    }
    else if(tableView.tag == MULTIPHONE_TABLE_TAG)
    {
        if (_selectedContact == nil)
        {
            return 0;
        }
        else
        {
            return _selectedContact.phoneArr.count;
        }
    }
    
    return [self.filteredListContent count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    //多号码联系人列表
    if (tableView.tag == MULTIPHONE_TABLE_TAG)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.textLabel.font = [cell.textLabel.font fontWithSize:17];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSString* phone = [_selectedContact.phoneArr objectAtIndex:indexPath.row];
        
        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:1001];
        
        if ( imgView == nil )
        {
            imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"call_logo_line1.png"]];
            imgView.tag = 1001;
            [cell.contentView addSubview:imgView];
            [imgView release];
        }
        
        imgView.frame = CGRectMake(0, 0, 320, 1);
        
        cell.tag = 0;
        [cell.imageView setImage:[UIImage imageNamed:@"choose.png"]];
        
        if (_selectedContact.checked)
        {
            for (ContactPhone *contact in self.selectedArray)
            {
                if ((_selectedContact.contactID==contact.contactID) && ([phone isEqualToString:contact.phone]))
                {
                    cell.tag = 1;
                    [cell.imageView setImage:[UIImage imageNamed:@"choose_on.png"]];
                    break;
                }
            }
        }
        
        cell.textLabel.text = phone;
        return cell;
    }
    
    selectTableCell *cell = (selectTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[selectTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [cell.textLabel.font fontWithSize:17];
    }
	
	cell.accessoryType = UITableViewCellAccessoryNone;
    GetSearchDataObj* infoItem = nil;
    
    //所有联系人列表
    if (tableView == [self.view viewWithTag:ContactsViewController_ContactsTableView])
	{
        NSString *key = [keys objectAtIndex:indexPath.section];
        NSArray *contactlist = [self.ContactsList objectForKey:key];
        infoItem = [contactlist objectAtIndex:indexPath.row];
    }
	else //搜索联系人列表
	{
        infoItem = [self.filteredListContent objectAtIndex:indexPath.row];
        
        for (ContactPhone *contact in self.selectedArray)
        {
            if (infoItem.contactID == contact.contactID)
            {
                infoItem.checked = TRUE;
                break;
            }
        }
    }
    
    UIView* tmpView = [cell.contentView viewWithTag:MULTIPHONE_TABLE_TAG];
    
    if (tmpView != nil)
    {
        [tmpView removeFromSuperview];
    }
    
    if ((indexPath.row == _selectedRow) && (indexPath.section == _selectedSection))
    {
        [cell.contentView addSubview:[self createMultiPhoneView:infoItem.phoneArr]];
    }
    
    UIImage* tmpPortrait = [[ModelEngineVoip getInstance] getPortrait:infoItem.contactID];
    
    NSInteger imageIndex = 0;
    
    if (infoItem.phoneArr==nil || infoItem.phoneArr.count<=0)
    {
        imageIndex = 0;
    }
    else
    {
        imageIndex = (infoItem.checked? 1:2);
    }
        NSString* phone = nil;
    if ([infoItem.phoneArr count] == 1)
    {
        phone = [infoItem.phoneArr objectAtIndex:0];
    }
    else if ([infoItem.phoneArr count] >1)
    {
        phone = @"（多号码）";
    }
    
    [cell setContactImage:tmpPortrait andContactName:infoItem.contactName andPhone:phone andChecked:imageIndex];
    
    return cell;
}

-(UITableView*)createMultiPhoneView:(NSArray*)phoneArray
{
    UITableView *multiPhoneView = [[UITableView alloc] initWithFrame:CGRectMake(44, 45, 276, phoneArray.count*MULTIPHOME_TABLE_ROW_HEIGHT)
                                                               style:UITableViewStylePlain];
    multiPhoneView.scrollEnabled = FALSE;
    multiPhoneView.separatorStyle = UITableViewCellSeparatorStyleNone;
    multiPhoneView.tag = MULTIPHONE_TABLE_TAG;
    multiPhoneView.delegate = self;
    multiPhoneView.dataSource = self;
    return [multiPhoneView autorelease];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == MULTIPHONE_TABLE_TAG)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        BOOL isIn = FALSE;
        ContactPhone* contact = nil;
        NSString* phone = [_selectedContact.phoneArr objectAtIndex:indexPath.row];
        
        for (contact in self.selectedArray)
        {
            if ((_selectedContact.contactID==contact.contactID) && ([phone isEqualToString:contact.phone]))
            {
                isIn = TRUE;
                break;
            }
        }
        
        
        if (cell.tag == 1)
        {
            cell.tag = 0;
        }
        else
        {
            if ([self.selectedArray count] >= maxCount)
            {
                [self popPromptViewWithMsg:@"未能选择，已达到最大号码数"];
                return;
            }
            cell.tag = 1;
        }
        
        if (cell.tag == 1)
        {
            if (!isIn)
            {
                ContactPhone* tempContact = [[ContactPhone alloc] init];
                tempContact.contactID = _selectedContact.contactID;
                tempContact.name = _selectedContact.contactName;
                tempContact.phone = phone;
                [self.selectedArray addObject:tempContact];
                [tempContact release];
                _selectedContact.checked = TRUE;
            }
        }
        else
        {
            if (isIn)
            {
                [self.selectedArray removeObject:contact];
                
                isIn = FALSE;
                
                for (contact in self.selectedArray)
                {
                    if (_selectedContact.contactID == contact.contactID)
                    {
                        isIn = TRUE;
                        break;
                    }
                }
                
                if (!isIn)
                {
                    _selectedContact.checked = FALSE;
                }
            }
        }
        
        if (searchDC.active)
        {
            NSArray* groupContact = [self.ContactsList valueForKey:[CommonTools getKeyByName:[_selectedContact.contactName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
            
            for (GetSearchDataObj* contact in groupContact)
            {
                if (contact.contactID == _selectedContact.contactID)
                {
                    contact.checked = _selectedContact.checked;
                }
            }
            
            [searchDC.searchResultsTableView reloadData];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UITableView* view = (UITableView*)[self.view viewWithTag:ContactsViewController_ContactsTableView];
        [view reloadData];
        return;
    }
    
    GetSearchDataObj* infoItem = nil;
    selectTableCell *cell = (selectTableCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    //全部联系人列表的表操作
    if (tableView.tag == ContactsViewController_ContactsTableView)
	{
        NSString *key = [keys objectAtIndex:indexPath.section];
        NSArray *contactlist = [self.ContactsList objectForKey:key];
        infoItem = [contactlist objectAtIndex:indexPath.row];
    }
	else //搜索联系人列表的表操作
	{
        ccp_AddressLog(@"row=%d,filtered=%d",indexPath.row,self.filteredListContent.count);
        infoItem = [self.filteredListContent objectAtIndex:indexPath.row];
    }
    
    if (infoItem.phoneArr.count == 0)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"此人无电话号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av show];
        [av release];
        return;
    }
    
    if (infoItem.phoneArr.count > 1)
    {
        BOOL isExpanded = NO;
        
        if ((_selectedRow != -1) && (_selectedSection != -1))
        {
            isExpanded = YES;
        }
        
        if (([cell.contentView viewWithTag:MULTIPHONE_TABLE_TAG] != nil) && (_selectedRow==indexPath.row && _selectedSection==indexPath.section))
        {
            _selectedContact = nil;
            _selectedRow = -1;
            _selectedSection = -1;
            
        }
        else
        {
            _selectedRow = indexPath.row;
            _selectedSection = indexPath.section;
            _selectedContact = infoItem;
        }
        
        [tableView reloadData];
        
        if (isExpanded)
        {
            CGRect rect = [tableView convertRect:[tableView rectForRowAtIndexPath:indexPath] toView:[tableView superview]];
            
            if (rect.origin.y <= 0 )
            {
                [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
        
        return;
    }
    
    if ([self.selectedArray count] >= maxCount && !infoItem.checked)
    {
        [self popPromptViewWithMsg:@"未能选择，已达到最大号码数"];
        return;
    }
    
    infoItem.checked = !infoItem.checked;
    
    if (tableView == searchDC.searchResultsTableView)
    {
        NSArray* groupContact = [self.ContactsList valueForKey:[CommonTools getKeyByName:[infoItem.contactName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
        
        for (GetSearchDataObj* contact in groupContact)
        {
            if (contact.contactID == infoItem.contactID)
            {
                contact.checked = infoItem.checked;
            }
        }
    }
    
    NSInteger imageIndex = 0;
    
    if (infoItem.phoneArr==nil || infoItem.phoneArr.count<=0)
    {
        imageIndex = 0;
    }
    else
    {
        imageIndex = (infoItem.checked? 1:2);
    }
    
    [cell setChecked:imageIndex];
    
    BOOL isIn = FALSE;
    ContactPhone* contact = nil;
    
    for (contact in self.selectedArray)
    {
        if ((infoItem.contactID==contact.contactID) && ([infoItem.contactPinyin isEqualToString:contact.phone]))
        {
            isIn = TRUE;
            break;
        }
    }
    
    if (infoItem.checked)
    {
        if (!isIn)
        {
            ContactPhone* tempContact = [[ContactPhone alloc] init];
            tempContact.contactID = infoItem.contactID;
            tempContact.name = infoItem.contactName;
            tempContact.phone = infoItem.contactPinyin;
            [self.selectedArray addObject:tempContact];
            [tempContact release];
        }
    }
    else
    {
        if (isIn)
        {
            [self.selectedArray removeObject:contact];
        }
    }
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    _selectedRow = -1;
    [self filterContentForSearchText:searchString];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;
{
    return YES;
}

#pragma mark -
#pragma mark UISearchBarDelegate Delegate Methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    _selectedRow = -1;
    [searchBar setKeyboardType:UIKeyboardTypeAlphabet];
    [searchBar setShowsCancelButton:YES animated:YES];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        if ([selSearchBar respondsToSelector: @selector (barTintColor)])
        {
            [selSearchBar setBarTintColor:SEARCHBAR_BACKGROUNDCOLOR];
        }
    }
    else
    {
        for(UIView *subView in searchBar.subviews)
        {
            if([subView isKindOfClass:UIButton.class])
            {
                [(UIButton*)subView setTitle:@"取消" forState:UIControlStateNormal];
                [(UIButton*)subView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }
    }
    if (isKeyboardAscii) {
        selSearchBar.keyboardType = UIKeyboardTypeASCIICapable;
    }
    else{
        selSearchBar.keyboardType = UIKeyboardTypeNumberPad;
    }
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableVie
{
    if (!searchDC.active)
    {
        _selectedRow = -1;
        _selectedSection = -1;
        UITableView* table = (UITableView*)[self.view viewWithTag:ContactsViewController_ContactsTableView];
        [table reloadData];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if (!searchDC.active)
    {
        _selectedRow = -1;
        _selectedSection = -1;
        UITableView* table = (UITableView*)[self.view viewWithTag:ContactsViewController_ContactsTableView];
        [table reloadData];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7 && !searchDC.active)
    {
        if ([selSearchBar respondsToSelector: @selector (barTintColor)])
        {
            [selSearchBar setBarTintColor:[UIColor clearColor]];
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;                    // called when cancel button pressed
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        if ([selSearchBar respondsToSelector: @selector (barTintColor)])
        {
            [selSearchBar setBarTintColor:[UIColor clearColor]];
        }
    }
}


- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    _selectedRow = -1;
    _selectedSection = -1;
    UITableView* table = (UITableView*)[self.view viewWithTag:ContactsViewController_ContactsTableView];
    [table reloadData];
}

-(void)confirm
{
    [self.delegate getPhoneNumbers:self.selectedArray];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    self.selectedArray = nil;
    [super dealloc];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
