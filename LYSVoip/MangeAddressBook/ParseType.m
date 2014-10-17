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

#import "ParseType.h"

@implementation ParseType

- (NSString *)getSystemTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"yyyyMMddHHmmss";
    
    NSString *locationString = [formatter stringFromDate: [NSDate date]];
    [formatter release];
    return locationString;
}

- (NSString *)dateToString:(NSDate *)date format:(NSString *)formatStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatStr];
    
    NSString *locationString = [formatter stringFromDate: date];
    [formatter release];
    return locationString;
}

- (NSString *)getTelLabel:(NSString *)telType customName:(NSString *)name
{
    NSString *telLabel;
    
    if ( telType.intValue == 1 )
    {
        telLabel = (NSString *) kABPersonPhoneMobileLabel;
    }
    else if ( telType.intValue == 2 )
    {
        telLabel = (NSString *) kABPersonPhoneIPhoneLabel;
    }
    else if ( telType.intValue == 3 )
    {
        telLabel = (NSString *) kABHomeLabel;
    }
    else if ( telType.intValue == 4 )
    {
        telLabel = (NSString *) kABWorkLabel;
    }
    else if ( telType.intValue == 5 )
    {
        telLabel = (NSString *) kABPersonPhoneMainLabel;
    }
    else if ( telType.intValue == 6 )
    {
        telLabel = (NSString *) kABPersonPhoneHomeFAXLabel;
    }
    else if ( telType.intValue == 7 )
    {
        telLabel = (NSString *) kABPersonPhoneWorkFAXLabel;
    }
    else if ( telType.intValue == 8 )
    {
        if( [[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0 )
            telLabel = (NSString *) kABPersonPhoneOtherFAXLabel;
        else
            telLabel = (NSString *) kABOtherLabel;
    }
    else if ( telType.intValue == 9 )
    {
        telLabel = (NSString *) kABPersonPhonePagerLabel;        
    }
    else if ( telType.intValue == 0 )   //自定义电话：TYPE_CUSTOM=0;
    {
            telLabel = (NSString *) kABOtherLabel;
    }
    else 
    {
        telLabel = telType;
    }
    return telLabel;
}

- (NSString *)getImLabel:(NSString *)imType
{
    NSString *imLabel;
    
    if ( imType.intValue == 1 )
    {
        imLabel = (NSString *)kABPersonInstantMessageServiceAIM;
    } 
    else if ( imType.intValue == 2 )
    {
        imLabel = (NSString *)kABPersonInstantMessageServiceGoogleTalk;
    }
    else if ( imType.intValue == 3 )
    {
        imLabel = (NSString *)kABPersonInstantMessageServiceYahoo;
    }
    else if ( imType.intValue == 4 )
    {
        imLabel = (NSString *)kABPersonInstantMessageServiceMSN;
    }
    else if ( imType.intValue == 5 )
    {
        imLabel = (NSString *)kABPersonInstantMessageServiceICQ;
    }
    else imLabel = imType;
    return imLabel;
}

- (NSString *)getDateLabel:(NSString *)dateType
{
    NSString *dateLabel;
    
    if ( dateType.intValue == 1 ) //纪念日：TYPE_ANNIVERSARY = 1;
    {
        dateLabel = (NSString *)kABPersonAnniversaryLabel;
    } 
    else if ( dateType.intValue == 2 ) //其他
    {
        dateLabel = (NSString *)kABOtherLabel;        
    }
    else dateLabel = dateType;
    return dateLabel;
}

- (NSString *)getWebsiteLabel:(NSString *)websiteType
{
    NSString *label;
    
    if ( websiteType.intValue == 1 )
    {
        label = (NSString *)kABPersonHomePageLabel;
    }
    else if ( websiteType.intValue == 3 )
    {
        label = (NSString *)kABWorkLabel;
    }
    else if ( websiteType.intValue == 2 )
    {
        label = (NSString *)kABHomeLabel;
    }
    else if ( websiteType.intValue == 4 )
    {
        label = (NSString *)kABOtherLabel;
    }
    else label = websiteType;
    return label;
}

- (NSString *)getGeneralLabel:(NSString *)type
{
    NSString *label;
    
    if ( type.intValue == 2 )
    {
        label = (NSString *)kABWorkLabel;
    } 
    else if (type.intValue == 1 )
    {
        label = (NSString *)kABHomeLabel;
    }
    else if ( type.intValue == 3 )
    {
        label = (NSString *)kABOtherLabel;
    }
    else label = type;
    
    return label;
}

- (NSString *)getSocialProfile:(NSString *)type {
    NSString *label;
    if (type.intValue == 1) {
        label = (NSString *)kABPersonSocialProfileServiceFacebook;
    }
    else if (type.intValue == 2) {
        label = (NSString *)kABPersonSocialProfileServiceFlickr;
    }
    else if (type.intValue == 3) {
        label = (NSString *)kABPersonSocialProfileServiceLinkedIn;
    }
    else if (type.intValue == 4) {
        label = (NSString *)kABPersonSocialProfileServiceMyspace;
    }
    else if (type.intValue == 5) {
        label = (NSString *)kABPersonSocialProfileServiceTwitter;
    }
    else label = type;
    return label;
}


@end
