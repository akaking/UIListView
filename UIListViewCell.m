//
//  UIListViewCell.m
//  UIListView
//
//  Created by SeeKool on 11/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIListViewCell.h"

@implementation UIListViewCell

@synthesize textLabel = _textLabel;

#pragma mark -
#pragma mark - dealloc (Memory Manager)
- (void)dealloc
{
    [_textLabel release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark - init
- (id)init
{
    self = [super init];
    if (self) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(1.0f, 1.0f, 79, 159.0f)];
        _textLabel.backgroundColor = [UIColor redColor];
        _textLabel.textColor = [UIColor whiteColor];
        
        [[UIDevice currentDevice] systemVersion];
        _textLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:_textLabel];
        
        self.backgroundColor = [UIColor grayColor];
    }
    
    return self;
}

@end
