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

#import "ContactsViewController.h"
#import "AddressBookGroup.h"
#import "AddressBookFuns.h"
#import <AddressBookUI/AddressBookUI.h>
#import "CustomPersonViewController.h"

@implementation ContactsViewController


- (void)viewDidLoad 
{
    [super viewDidLoad];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationItemBtnInitWithNormalImageNamed:@"add_button.png" andHighlightedImageNamed:@"add_button_on.png" target:self action:@selector(addContact)]];
    self.navigationItem.rightBarButtonItem = right;
    [right release];
}

-(void)addContact
{
    extern NSInteger contactOptState;
    contactOptState = 1;
    ABNewPersonViewController *picker1 = [[ABNewPersonViewController alloc] init];
    picker1.newPersonViewDelegate = self;
    UINavigationController *navigation1 = [[UINavigationController alloc] initWithRootViewController:picker1];
    self.contactsUI = picker1;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0)
    {
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)
        {
            [picker1.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_iOS7.png"] forBarMetrics:0];
        }
        else
            [picker1.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation.png"] forBarMetrics:0];
        
        navigation1.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleBordered;
    }
    else
    {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0/255 green:130.0/255 blue:180.0/255 alpha:0.8];
    }
    
    [self presentModalViewController:navigation1 animated:YES];
    [picker1 release];
    [navigation1 release];
}

-(void)editContactWithContactID:(NSInteger) contactID
{
    extern NSInteger contactOptState;
    contactOptState = 3;
    ABNewPersonViewController* picker1 = nil;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)
    {
        picker1 = [[ABNewPersonViewController alloc] init];
    }
    else
        picker1 = [[CustomPersonViewController alloc] init];
    self.contactsUI = picker1;
	picker1.newPersonViewDelegate = self;
	UINavigationController *navigation1 = [[UINavigationController alloc] initWithRootViewController:picker1];
    
	ABAddressBookRef addressBook = ABAddressBookCreate();
    picker1.addressBook =  addressBook;
    picker1.title = @"编辑联系人";
    picker1.displayedPerson = ABAddressBookGetPersonWithRecordID(addressBook, contactID);
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0)
    {
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)
        {
            [picker1.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_iOS7.png"] forBarMetrics:0];
        }
        else
        {
            [picker1 setEditing:YES];
            [picker1.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation.png"] forBarMetrics:0];
        }
    }
    else
    {
        [picker1 setEditing:YES];
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0/255 green:130.0/255 blue:180.0/255 alpha:0.8];
    }
    
    [self presentModalViewController:navigation1 animated:YES];
	[picker1 release];
	[navigation1 release];
    CFRelease(addressBook);
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissModalViewControllerAnimated:YES];
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
    extern NSInteger  contactOptState;
    NSInteger  ContactID;
    NSString* strID;
    if (person) {
        ContactID = ABRecordGetRecordID(person);
        strID = [NSString stringWithFormat:@"%d",ContactID];
        NSDictionary *userdata = [NSDictionary dictionaryWithObject: strID forKey:@"V"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addressbookChangedIncrease" object:self userInfo:userdata]; 
        [[ModelEngineVoip getInstance]resetPortraitDic:ContactID];
    }
    else
        contactOptState = 0;
    [self LoadContactTableView];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc 
{
    [super dealloc];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GetSearchDataObj* infoItem = nil;
    if(tableView.tag != ContactsViewController_ContactsTableView)//搜索出来的联系人选择的话就跳到详情界面
    {
        infoItem = [self.filteredListContent objectAtIndex:indexPath.row];
        [self editContactWithContactID:infoItem.contactID];
    }
    else
    {
        NSString *key = [keys objectAtIndex:indexPath.section];
        NSArray *nameSection = [ContactsList objectForKey:key];
        infoItem = [nameSection objectAtIndex:indexPath.row];
        [self editContactWithContactID:infoItem.contactID];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
