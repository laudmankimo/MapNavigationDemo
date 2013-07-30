//
//  Distance.m
//  MapkitDirection
//
//  Created by laudmankimo on 13-7-13.
//  Copyright (c) 2013年 laudmankimo. All rights reserved.
//

#import "Properties.h"

@implementation Properties
@synthesize text;
@synthesize value;

- (void) dealloc
{
	[text release];
	[super dealloc];
}

@end
