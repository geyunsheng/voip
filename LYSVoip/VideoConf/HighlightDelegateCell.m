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
#import "HighlightDelegateCell.h"

@implementation HighlightDelegateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
    {
        UIImageView* accessimage = (UIImageView*)[self viewWithTag:1004];
        UIImageView* backimage = (UIImageView*)[self viewWithTag:1003];
        backimage.image = [UIImage imageNamed:@"videoConf51_on.png"];
        accessimage.image = [UIImage imageNamed:@"viewConfAccessIcon_on.png"];
    }
    else
    {
        UIImageView* accessimage = (UIImageView*)[self viewWithTag:1004];
        UIImageView* backimage = (UIImageView*)[self viewWithTag:1003];
        backimage.image = [UIImage imageNamed:@"videoConf51.png"];
        accessimage.image = [UIImage imageNamed:@"viewConfAccessIcon.png"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    
    if (selected)
    {
        UIImageView* accessimage = (UIImageView*)[self viewWithTag:1004];
        UIImageView* backimage = (UIImageView*)[self viewWithTag:1003];
        backimage.image = [UIImage imageNamed:@"videoConf51_on.png"];
        accessimage.image = [UIImage imageNamed:@"viewConfAccessIcon_on.png"];
    }
    else
    {
        UIImageView* accessimage = (UIImageView*)[self viewWithTag:1004];
        UIImageView* backimage = (UIImageView*)[self viewWithTag:1003];
        backimage.image = [UIImage imageNamed:@"videoConf51.png"];
        accessimage.image = [UIImage imageNamed:@"viewConfAccessIcon.png"];
    }
}

@end
