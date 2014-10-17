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

#import "IMMemberGridViewCell.h"

@implementation IMMemberGridViewCell

@synthesize textLabel;
@synthesize backgroundView;

- (void)dealloc
{
    self.textLabel = nil;
    self.backgroundView = nil;
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        // Background view
        self.backgroundView = [[[UIImageView alloc] initWithFrame:CGRectNull] autorelease];
        self.backgroundView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.backgroundView];
        
        // Label
        self.textLabel = [[[UILabel alloc] initWithFrame:CGRectNull] autorelease];
        self.textLabel.textAlignment = UITextAlignmentCenter;
        self.textLabel.backgroundColor = VIEW_BACKGROUND_COLOR_WHITE;
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.textLabel];
    }
    
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Background view
    self.backgroundView.frame = CGRectMake(0.0f, 0.0f, 64.0f, 63.0f);
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Layout label background
    self.textLabel.frame = CGRectMake(0, 64.0f, 64.0f, 20.0f);
    self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

@end
