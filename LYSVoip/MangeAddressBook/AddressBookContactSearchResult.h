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

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "ParseType.h"

@interface AddressBookContactSearchResult : NSObject
#pragma mark -
#pragma mark - for statue
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, retain) NSString *status;
#pragma mark -
#pragma mark - for search
//conatctID
@property (nonatomic, assign) NSInteger contactID;
//联系人姓名
@property (nonatomic, retain) NSString * contactName;
@property (nonatomic, retain) NSString *contactPinyin;

#pragma mark -
#pragma mark for add&edit
@property (nonatomic, retain) NSString *firstname;
@property (nonatomic, retain) NSString *lastname;
@property (nonatomic, retain) NSString *middlename;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSString *prefix;
@property (nonatomic, retain) NSString *suffix;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *firstNamePhonetic;
@property (nonatomic, retain) NSString *lastNamePhonetic;
@property (nonatomic, retain) NSString *middleNamePhonetic;
@property (nonatomic, retain) NSString *company;
@property (nonatomic, retain) NSString *jobTitle;
@property (nonatomic, retain) NSString *department;
@property (nonatomic, retain) NSString *birthday;
@property (nonatomic, retain) NSString *note;

@property (nonatomic, retain) NSData * portrait;


#pragma mark - MULTIVALUE
//按照key，value形式存储，key、value均为string
@property (nonatomic, retain) NSMutableArray *phoneArray;
//按照key，value形式存储，key、value均为string
@property (nonatomic, retain) NSMutableArray *emailArray;
//按照key，value形式存储，key、value均为string
@property (nonatomic, retain) NSMutableArray *urlArray;
//按照key，value形式存储，其中key为string，value为dictionary
@property (nonatomic, retain) NSMutableArray *addressArray;
//按照key，value形式存储，其中key为string，value为dictionary
@property (nonatomic, retain) NSMutableArray *imArray;
//按照key，value形式存储，其中key为string，value为dictionary
//For 5.0 or Later
@property (nonatomic, retain) NSMutableArray *socialArray;
//
@property (nonatomic, retain) NSMutableArray *dateArray;

//有待于定义进一步支持什么大类 custom
//按照key，value形式存储，key、value均为string
@property (nonatomic, retain) NSMutableArray *localArray;

- (AddressBookContactSearchResult *) init;
- (void)dealloc;

@end
