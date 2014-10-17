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
#import "CustomLabel.h"


@implementation ContactPhone
@synthesize name=contactName,key=contactKey,phone=contactPhone,contactID,pinyin,inAddressBook;

- (id)init{
    self = [super init];
    if (self) {
        contactName = [[NSString alloc] init];
        contactKey = [[NSString alloc] init];
        contactPhone = [[NSString alloc] init];
        pinyin = nil;
        contactID = 0;
        inAddressBook = YES;
    }
    return self;
}

- (void) setName:(NSString *)tmpname{
    
    [contactName release];
    
    if (tmpname == nil) {
        contactName = nil;
    }
    else{
        contactName = [[NSString alloc] initWithString:[tmpname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        self.key = [CommonTools getKeyByName:contactName];
    }
}

- (void) setKey:(NSString *)tmpkey{
    
    [contactKey release];
    
    if (tmpkey == nil) {
        contactKey = nil;
    }
    else{
        contactKey = [[NSString alloc] initWithString:tmpkey];
    }
}

- (void) setPhone:(NSString *)tmpphone{
    
    [contactPhone release];
    
    if (tmpphone == nil) {
        contactPhone = nil;
    }
    else{
        contactPhone = [[NSString alloc] initWithString:tmpphone];
    }
}

-(void)dealloc{
    
    [contactName release];
    contactName = nil;
    [contactKey release];
    contactKey = nil;
    [contactPhone release];
    contactPhone = nil;
    [pinyin release];
    pinyin = nil;
    [super dealloc];
}
@end

@implementation ContactBaseViewController
@synthesize ContactsList;
@synthesize keys;
@synthesize tableview;
@synthesize filteredListContent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        sectionViewDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}
-(void)loadView
{
    UIView* selfview = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    selfview.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
    self.view = selfview;
    [selfview release];

    UITableView* table = nil;
    if (IPHONE5)
    {
        table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 568.f-20.f)
                                             style:UITableViewStylePlain];;
    }
    else
    {
        table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f-20.f)
                                             style:UITableViewStylePlain];
    }
    table.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    table.delegate=self;
	table.dataSource=self;
	table.backgroundColor = TABLE_BACKGROUNDCOLOR;
    table.tag = ContactsViewController_ContactsTableView;
    self.tableview = table;
    [self.view addSubview:self.tableview];
    self.title = @"联系人";
    [self CreatePopView];
	selSearchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)] autorelease];
	selSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	selSearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    selSearchBar.delegate = self;
	self.tableview.tableHeaderView = selSearchBar;
	searchDC = [[UISearchDisplayController alloc] initWithSearchBar:selSearchBar contentsController:self];
	searchDC.searchResultsDataSource = self;
	searchDC.searchResultsDelegate = self;
    searchDC.delegate = self;
    selSearchBar.tintColor = [UIColor colorWithRed:237.0/255 green:236.0/255 blue:231.0/255 alpha:1.0];
    selSearchBar.placeholder = [NSString stringWithFormat: @"共有%ld个联系人", [[ModelEngineVoip getInstance] getContactCount]];
    //将所有26个英文字母放到数组中准备作为tableview的索引
    keyArray = [[NSArray alloc] initWithObjects: @"{search}",@"A", @"B", @"C", @"D", @"E", @"F", @"G",@"H", @"I", @"J", @"K", @"L", @"M", @"N",@"O", @"P", @"Q", @"R", @"S", @"T", @"U",@"V", @"W", @"X", @"Y", @"Z",@"#", nil];
    self.view.tag = 2000;
    self.title = @"全部联系人";
    self.tabBarItem.title = @"联系人";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7)
    {
        for (UIView *subview in  selSearchBar.subviews)
        {
            if ([subview isKindOfClass: NSClassFromString ( @"UISearchBarBackground" )]) {
                [subview removeFromSuperview];
                break ;
            }
        }
    }
    else
    {
        if ([selSearchBar respondsToSelector: @selector (barTintColor)])
        {
            [selSearchBar setBarTintColor:[UIColor clearColor]];
        }
    }
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:[CommonTools navigationBackItemBtnInitWithTarget:self action:@selector(popToPreView)]];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [leftBarItem release];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7)
    {
        for(UIView *view in [self.tableview subviews])
        {
            
            if([[[view class] description] isEqualToString:@"UITableViewIndex"])
            {
                
                [view setBackgroundColor:[UIColor clearColor]];
            }
        }
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        self.tableview.sectionIndexBackgroundColor = [UIColor clearColor];
#endif
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6)
        self.tableview.sectionIndexColor = [UIColor grayColor];
    [self refreshContactsDate];
    
    [table release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ModelEngineVoip getInstance].UIDelegate = self;
    extern NSInteger globalcontactsChanged;
    if (globalcontactsChanged)
    {
        globalcontactsChanged = NO;
        [self refreshContactsDate];
    }
    tableview.scrollEnabled = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contactsChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactsChangedeCallback:)
                                                 name:@"contactsChanged"
                                               object:nil];
    isKeyboardAscii=YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShowOnDelay:)name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(partialSearchData:) name:@"T9SearchEnds" object:nil];
    
    if (searchDC.active) {//搜索table在前
        selSearchBar.text = selSearchBar.text;//如果是从搜索进入的联系人详情页面，再回来时候，这样做会重新触发搜索，以显示最新改变的联系人信息（删除、编辑改名等等）
    }
    extern NSInteger  contactOptState;
    contactOptState=0;
}

-(void) viewWillDisappear:(BOOL)animated
{
    tableview.scrollEnabled = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contactsChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"T9SearchEnds" object:nil];
    [selSearchBar resignFirstResponder];
    if (foundKeyboard)
    {
        UIView* view = [foundKeyboard viewWithTag:100];
        if (view) {
            [view removeFromSuperview];
        }
    }
}

- (void)partialSearchData:(NSNotification *)data
{
    NSString* searchText = selSearchBar.text;
    NSArray *partialArray = [[data userInfo] objectForKey:searchText];
    
    if ( partialArray!=nil && partialArray.count>0 )
    {
        [self.filteredListContent addObjectsFromArray:partialArray];
        [searchDC.searchResultsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

- (void)hideKeyPad
{
    [selSearchBar resignFirstResponder];
    if (foundKeyboard)
    {
        UIView* view = [foundKeyboard viewWithTag:100];
        if (view) {
            [view removeFromSuperview];
        }
    }
}

-(void)changeKeyboardType:(id)sender{
    if (foundKeyboard)
    {
        UIView* view = [foundKeyboard viewWithTag:100];
        if (view) {
            [view removeFromSuperview];
        }
    }
    isKeyboardAscii =! isKeyboardAscii;
    [selSearchBar resignFirstResponder];
    [selSearchBar becomeFirstResponder];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (foundKeyboard)
    {
        UIView* view = [foundKeyboard viewWithTag:100];
        if (view) {
            [view removeFromSuperview];
        }
    }
}

- (void)keyboardWillShowOnDelay:(NSNotification *)notification
{
    [self performSelector:@selector(keyboardWillShow:) withObject:nil afterDelay:0];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (!foundKeyboard) {
        UIWindow *keyboardWindow = nil;
        for (UIWindow *testWindow in [[UIApplication sharedApplication] windows])
        {
            if (![[testWindow class] isEqual:[UIWindow class]])
            {
                keyboardWindow = testWindow;
                break;
            }
        }
        if (!keyboardWindow) return;
        for (UIView *possibleKeyboard in [keyboardWindow subviews])
        {
            if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"])
            {
                for (UIView *subview in [possibleKeyboard subviews])
                {
                    if ([[subview description] hasPrefix:@"<UIKeyboard"])
                    {
                        foundKeyboard = subview;
                        break;
                    }
                }
                break;
            }
        }
    }
    if (foundKeyboard)
    {
        UIView* view = [foundKeyboard viewWithTag:100];
        if (view) {
            [view removeFromSuperview];
        }
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.tag = 100;
        doneButton.adjustsImageWhenHighlighted = NO;
        if(isKeyboardAscii){
            doneButton.frame = CGRectMake(0, 174, 79, 40);
            [doneButton setBackgroundImage:[UIImage imageNamed:@"Customkey2"] forState:UIControlStateNormal];
            [doneButton setTitle:@" 123" forState:UIControlStateNormal];
        }else{
            doneButton.frame = CGRectMake(0, 163, 106, 53);
            [doneButton setTitle:@"ABC" forState:UIControlStateNormal];
        }
        [doneButton addTarget:self action:@selector(changeKeyboardType:) forControlEvents:UIControlEventTouchUpInside];
        
        [foundKeyboard addSubview:doneButton];
    }
}


-(void)contactsChangedeCallback:(NSNotification *)_notification
{
    ccp_AddressLog(@"UI准备刷新数据");
    [self refreshContactsDate];
}

-(void) LoadContactTableView
{
    self.ContactsList = [[ModelEngineVoip getInstance] listAllContactsReset:YES listAll:YES];
    self.keys =[NSMutableArray arrayWithArray:[[ContactsList allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    selSearchBar.placeholder = [NSString stringWithFormat: @"共有%ld个联系人", [[ModelEngineVoip getInstance] getContactCount]];
}

-(void)CreatePopView
{
    //显示点击索引时出现的字母
    popLabelBackImg = [[UIImageView alloc] initWithFrame:CGRectMake(132, 184, 51, 51)];
    popLabelBackImg.image = [UIImage imageNamed:@"contacts_green.png"];
    popLabelBackImg.alpha = 0;
    [self.view addSubview:popLabelBackImg];
    
	label = [[UILabel alloc] initWithFrame: CGRectMake( 132, 184, 51, 51)];
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor blackColor];
	label.font = [UIFont systemFontOfSize: 40];
	label.textAlignment = UITextAlignmentCenter;
	label.layer.cornerRadius = 8;
	label.alpha = 0;
	[self.view addSubview: label];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView.tag != ContactsViewController_ContactsTableView)  {
        return nil;
    }
    else
        return keyArray;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 43;
}

//选中索引时，中间显示个大字母标签可以淡出
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSString * str;
    str = title;
    if (tableView.tag != ContactsViewController_ContactsTableView) return 0;
    if ([title isEqualToString: @"{search}"]){
        tableView.contentOffset = CGPointMake(0, 0);
        label.text = @"搜";
    }
    else if ([title isEqualToString: @"#"]){
        str = @"^";
        label.text= @"#";
    }
    
    else
        label.text = title;
    popLabelBackImg.alpha = 1.0;
	label.alpha = 1.0;
	
	label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:36];
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: 1.0];
	label.alpha = 0.0;
    popLabelBackImg.alpha = 0.0;
	[UIView commitAnimations];
    //控制跳转位置的返回当前选择的索引在 数组里的位置 如果当前选择的索引在数组里不存在，则返回值为上次的值
	NSInteger CharIndex = (unsigned)CFArrayBSearchValues((CFArrayRef) keys,
                                                         CFRangeMake(0, CFArrayGetCount((CFArrayRef)keys)),
                                                         (CFStringRef)str,
                                                         (CFComparatorFunction)CFStringCompare,
                                                         NULL);
	return CharIndex;
}

- (void)dealloc
{
    [keyArray release];
    self.filteredListContent = nil;
    [label release];
    [popLabelBackImg release];
    self.ContactsList=nil;
    self.keys=nil;
    [searchDC release];
    [sectionViewDic release];
    self.tableview = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == ContactsViewController_ContactsTableView)
    {
        NSString* headText = [keys objectAtIndex:section];
        UIView *headView = [sectionViewDic objectForKey:headText];
        if (headView == nil) {
            headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
            headView.backgroundColor = TABLE_BACKGROUNDCOLOR;
            UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 60, 20)];
            if ([headText isEqualToString:@"^"]) {
                label1.text = @"#";
            }
            else{
                label1.text = headText;
            }
            label1.shadowColor = [UIColor whiteColor];
            label1.shadowOffset = CGSizeMake(0, 1);
            label1.textColor = [UIColor colorWithRed:138.0/255 green:138.0/255 blue:138.0/255 alpha:1.0];
            label1.backgroundColor = [UIColor clearColor];
            [headView addSubview:label1];
            [label1 release];
            [sectionViewDic setObject:headView forKey:headText];
            [headView release];
        }
        return headView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag==ContactsViewController_ContactsTableView) return [keys count];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==ContactsViewController_ContactsTableView) {
        NSString *key = [keys objectAtIndex:section];
        NSArray *nameSection = [ContactsList objectForKey:key];
        return [nameSection count];
    }
    return [self.filteredListContent count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    UITableViewCell *cell;
    NSString *key = [keys objectAtIndex:section];
    NSArray *nameSection = [ContactsList objectForKey:key];
    
    static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";
    
    cell = [tableView dequeueReusableCellWithIdentifier:
            SectionsTableIdentifier ];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                       reuseIdentifier: SectionsTableIdentifier ] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    for (UIView *subview in cell.contentView.subviews)
    {
        if (subview.tag == 1001)
        {
            [subview removeFromSuperview];
        }
    }
    //显示电话号码，照片等信息。
    GetSearchDataObj* infoItem;
    if (tableView.tag== ContactsViewController_ContactsTableView)
    {
        infoItem = [nameSection objectAtIndex:row];
        UILabel* lab1;
        lab1 = [[UILabel alloc] init];
        lab1.frame = CGRectMake(65, 5, 160, 22);
        lab1.text = infoItem.contactName;
        lab1.font = [UIFont boldSystemFontOfSize:19];
        lab1.highlightedTextColor = [UIColor whiteColor];
        lab1.backgroundColor = [UIColor clearColor];
        lab1.tag = 1001;
        [cell.contentView addSubview:lab1];
        [lab1 release];
        
        NSString* strLabe2 = nil;
        strLabe2 = infoItem.contactPinyin;
        
        if ([strLabe2 length]<=0)
        {
            lab1.frame = CGRectMake(65, 13, 160, 20);
        }
        else
        {
            UILabel* lab2;
            lab2 = [[UILabel alloc] initWithFrame:CGRectMake(65, 28, 230, 13)];
            lab2.textColor = [UIColor colorWithRed:(130.0/255) green:(130.0/255) blue:130.0/255 alpha:1.0];
            lab2.highlightedTextColor = [UIColor whiteColor];
            lab2.text = strLabe2;
            lab2.font = [UIFont systemFontOfSize:13];
            lab2.backgroundColor = [UIColor clearColor];
            lab2.tag = 1001;
            [cell.contentView addSubview:lab2];
            [lab2 release];
        }
    }
    else
    {
        infoItem = [self.filteredListContent objectAtIndex:indexPath.row];
        CustomLabel* searchNameLabel;
        searchNameLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(65, 13, 100, 22)];
        searchNameLabel.tag = 1001;
        
        infoItem = [self.filteredListContent objectAtIndex:indexPath.row];
        CustomLabel* searchPhoneLabel;
        searchPhoneLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(160, 13, 160, 22)];
        searchPhoneLabel.tag = 1001;
        
        if ( infoItem.contactPinyinProperty == 2 )  //号码匹配，显示名字和号码，号码高亮
        {
            searchNameLabel.text = infoItem.contactName;
            searchNameLabel.font = [UIFont systemFontOfSize:18.0f];
            [searchNameLabel setUIlabelTextColor:[UIColor blackColor] andKeyWordColor:[UIColor blueColor] ];
            searchNameLabel.backgroundColor = [UIColor clearColor];
            
            CGSize size = [searchNameLabel.text sizeWithFont:searchNameLabel.font];
            if (size.width>100)
                size.width = 100;
            [searchNameLabel setFrame:CGRectMake(searchNameLabel.frame.origin.x, searchNameLabel.frame.origin.y, size.width, searchNameLabel.frame.size.height)];
            
            [searchPhoneLabel setFrame:CGRectMake(searchNameLabel.frame.origin.x + searchNameLabel.frame.size.width + 10, searchPhoneLabel.frame.origin.y, searchPhoneLabel.frame.size.width, searchPhoneLabel.frame.size.height)];
            searchPhoneLabel.text = infoItem.contactPinyin;
            searchPhoneLabel.font = [UIFont systemFontOfSize:18.0f];
            [searchPhoneLabel setUIlabelTextColor:[UIColor grayColor] andKeyWordColor:[UIColor blueColor] ];
            searchPhoneLabel.backgroundColor = [UIColor clearColor];
            searchPhoneLabel.list = (NSMutableArray *)infoItem.matchPos;
        }
        else    //等于4或5时，为匹配拼音，只显示名字和拼音，拼音高亮
        {
            if ( infoItem.isPinyin == 0 )   //姓名为字母时，只显示其一
            {
                searchNameLabel.text = infoItem.contactPinyinLabel;
                searchNameLabel.font = [UIFont systemFontOfSize:18.0f];
                [searchNameLabel setUIlabelTextColor:[UIColor blackColor] andKeyWordColor:[UIColor blueColor] ];
                searchNameLabel.backgroundColor = [UIColor clearColor];
                searchNameLabel.list = (NSMutableArray *)infoItem.matchPos;
            }
            else
            {
                searchNameLabel.text = infoItem.contactName;
                searchNameLabel.font = [UIFont systemFontOfSize:18.0f];
                [searchNameLabel setUIlabelTextColor:[UIColor blackColor] andKeyWordColor:[UIColor blueColor] ];
                searchNameLabel.backgroundColor = [UIColor clearColor];
                CGSize size = [searchNameLabel.text sizeWithFont:searchNameLabel.font];
                if (size.width>100)
                    size.width = 100;
                [searchNameLabel setFrame:CGRectMake(searchNameLabel.frame.origin.x, searchNameLabel.frame.origin.y, size.width, searchNameLabel.frame.size.height)];
                [searchPhoneLabel setFrame:CGRectMake(searchNameLabel.frame.origin.x + searchNameLabel.frame.size.width + 10, searchPhoneLabel.frame.origin.y, searchPhoneLabel.frame.size.width, searchPhoneLabel.frame.size.height)];
                searchPhoneLabel.text = infoItem.contactPinyinLabel;
                searchPhoneLabel.font = [UIFont systemFontOfSize:18.0f];
                [searchPhoneLabel setUIlabelTextColor:[UIColor grayColor] andKeyWordColor:[UIColor blueColor] ];
                searchPhoneLabel.backgroundColor = [UIColor clearColor];
                searchPhoneLabel.list = (NSMutableArray *)infoItem.matchPos;
            }
        }
        [cell.contentView addSubview: searchNameLabel];
        [cell.contentView addSubview: searchPhoneLabel];
        [searchNameLabel release];
        [searchPhoneLabel release];
    }
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 2.5, 40, 40)];
    imgView.image = [[ModelEngineVoip getInstance] getPortrait:infoItem.contactID];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.tag=1001;
    [cell.contentView addSubview:imgView];
    [imgView release];
    return cell;
}


- (void) refreshContactsDate
{
    [self LoadContactTableView];
    [tableview reloadData];
}


- (void)filterContentForSearchText:(NSString*)searchText
{
	[filteredListContent removeAllObjects];
    if ([searchText length] == 0)
    {
        self.filteredListContent = nil;
    }
    else
    {
        NSString *regex = @".*[0-9].*";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if ([predicate evaluateWithObject:searchText] == YES)
        {
            self.filteredListContent = (NSMutableArray*)[[ModelEngineVoip getInstance] contactsSearch:searchText keyboard:1];
        }
        else
        {
            self.filteredListContent = (NSMutableArray*)[[ModelEngineVoip getInstance] contactsSearch:searchText keyboard:0];
        }
        
    }
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];//searchDisplayController的回调，把获得的搜索字符串传递给搜索函数
    return YES;
}

#pragma mark -
#pragma mark UISearchBarDelegate Delegate Methods
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;
{
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;
{
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

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar//改变searchBar上文字时进入这里
{   [searchBar setKeyboardType:UIKeyboardTypeAlphabet];
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
@end
