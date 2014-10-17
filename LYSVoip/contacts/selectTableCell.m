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

#import "selectTableCell.h"

@implementation selectTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.backgroundView = [[[UIView alloc] init] autorelease];
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        if (checkImageView == nil)
		{
			checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"choose.png"]];
			[self addSubview:checkImageView];
		}
		nameLabelwidth = 200;
		checkImageView.frame = CGRectMake(8, 10, 22, 22);
        
        if (contactImageView == nil) {
            contactImageView = [[UIImageView alloc] initWithFrame:CGRectMake(48, 4.5, 35, 35)];
            [self addSubview:contactImageView];
        }
        
        if (nameLabel == nil) {
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(103, 0, nameLabelwidth, CGRectGetHeight(self.bounds))];
            nameLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:nameLabel];
        }
        
        if (phoneLabel == nil) {
            phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(103, CGRectGetHeight(self.bounds) - 13 , nameLabelwidth, 11)];
            phoneLabel.backgroundColor = [UIColor clearColor];
            phoneLabel.textColor = [UIColor grayColor];
            phoneLabel.font = [UIFont systemFontOfSize:11];
            [self addSubview:phoneLabel];
        }    }
    return self;
}



- (void)dealloc 
{
	[checkImageView release];
	checkImageView = nil;
    
    [contactImageView release];
    contactImageView = nil;
    
    [nameLabel release];
    nameLabel = nil;
    [phoneLabel release];
    phoneLabel = nil;
    [super dealloc];
}


- (void) setChecked:(NSInteger)checked
{
	if (checked == 0)
	{
		checkImageView.image = [UIImage imageNamed:@"check_off.png"];
	}
    else if (checked == 1) {
        checkImageView.image = [UIImage imageNamed:@"choose_on.png"];
    }
	else
	{
		checkImageView.image = [UIImage imageNamed:@"choose.png"];
	}
}

- (void) setContactName:(NSString*)name{
    nameLabel.text = name;
}

- (void) setPhone:(NSString*)phone
{
    phoneLabel.text = phone;
}

- (void) setnameLabelWidth:(NSInteger)width
{
    nameLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y, width, nameLabel.frame.size.height);
}
- (void) setContactImage:(UIImage*)image{
    contactImageView.image = image;
}

- (void) setContactImage:(UIImage*)contactImage andContactName:(NSString*)name andPhone:(NSString*)phone andChecked:(NSInteger)checked{
    [self setContactImage:contactImage];
    [self setContactName:name];
    [self setPhone:phone];
    [self setChecked:checked];  
}
@end
