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
#import "UISelectCell.h"

@implementation UISelectCell

@synthesize checkImageView;
@synthesize voipAccountLabel;
@synthesize info;
@synthesize isSingleCheck;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.checkImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(285.0f, 10.0f, 25.0f, 25)] autorelease];
        [self addSubview:self.checkImageView];
        self.voipAccountLabel = [[[UILabel alloc] initWithFrame:CGRectMake(15, 14, 200, 20)] autorelease];
        self.voipAccountLabel.backgroundColor = [UIColor clearColor];
        self.voipAccountLabel.textColor = [UIColor blackColor];
        self.voipAccountLabel.font = [UIFont systemFontOfSize:17.0f];
        [self addSubview:self.voipAccountLabel];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
    {
        self.voipAccountLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        self.voipAccountLabel.textColor = [UIColor darkGrayColor];
    }
}

-(void)makeCellWithVoipInfo:(AccountInfo *) voip_Info;
{
    self.info = voip_Info;    
    [self resetCheckImge:self.info.isChecked];
    self.voipAccountLabel.text = voip_Info.userName;
}

//设置是否选择图像
-(void)resetCheckImge:(BOOL)_isChecked
{
    if (_isChecked)
    {
        if (self.isSingleCheck)
            self.checkImageView.image = [UIImage imageNamed:@"select_on.png"];
        else
            self.checkImageView.image = [UIImage imageNamed:@"mark_on.png"];
    }
    else
    {
        if (self.isSingleCheck)
            self.checkImageView.image = [UIImage imageNamed:@"select_off.png"];
        else
            self.checkImageView.image = [UIImage imageNamed:@"mark_off.png"];
    }
}

-(void)dealloc
{
    self.checkImageView = nil;
    self.voipAccountLabel = nil;
    self.info = nil;
    [super dealloc];
}

@end
