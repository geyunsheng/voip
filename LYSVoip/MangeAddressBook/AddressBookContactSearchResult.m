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

#import "AddressBookContactSearchResult.h"

@implementation AddressBookContactSearchResult
#pragma mark - search
@synthesize checked;
@synthesize status;
@synthesize contactName;
@synthesize contactPinyin;
@synthesize contactID;
#pragma mark - add&edit
@synthesize firstname;
@synthesize lastname;
@synthesize middlename;
@synthesize displayName;
@synthesize prefix;
@synthesize suffix;
@synthesize nickname;
@synthesize firstNamePhonetic;
@synthesize lastNamePhonetic;
@synthesize middleNamePhonetic;
@synthesize company;
@synthesize jobTitle;
@synthesize department;
@synthesize birthday;
@synthesize note;
@synthesize portrait;
@synthesize phoneArray;
@synthesize emailArray;
@synthesize urlArray;
@synthesize addressArray;
@synthesize imArray;
@synthesize socialArray;
@synthesize dateArray;
@synthesize localArray;

#pragma mark -
#pragma mark - functions

- (AddressBookContactSearchResult *)init {
    if (self=[super init]) {
        return self;
    }
    return nil;
}

-(void)dealloc {
    self.status = nil;
    self.contactName = nil;
    self.contactPinyin = nil;
    self.contactPinyin = nil;
    self.firstname = nil;
    self.lastname = nil;
    self.middlename = nil;
    self.displayName = nil;
    self.prefix = nil;
    self.suffix = nil;
    self.nickname = nil;
    self.firstNamePhonetic = nil;
    self.lastNamePhonetic = nil;
    self.middleNamePhonetic = nil;
    self.company = nil;
    self.jobTitle = nil;
    self.department = nil;
    self.birthday = nil;
    self.note = nil;
    self.portrait = nil;    
    self.phoneArray = nil;
    self.emailArray = nil;
    self.urlArray = nil;
    self.addressArray =  nil;
    self.imArray = nil;
    self.socialArray = nil;
    self.dateArray = nil;
    self.localArray = nil;
    [super dealloc];
}


@end
