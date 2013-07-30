//
//  Steps.m
//  MapkitDirection
//
//  Created by laudmankimo on 13-7-12.
//  Copyright (c) 2013年 laudmankimo. All rights reserved.
//

#import "Steps.h"

@implementation Steps
@synthesize distance;
@synthesize duration;
@synthesize start_locatoin;
@synthesize end_location;
@synthesize html_instructions;
@synthesize polyline;
@synthesize travel_mode;

- (void) dealloc
{
	[distance release];
	[duration release];
	[html_instructions release];
	[polyline release];
	[travel_mode release];
	[super dealloc];
}

@end
