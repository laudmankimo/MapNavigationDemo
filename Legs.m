//
//  Legs.m
//  MapkitDirection
//
//  Created by laudmankimo on 13-7-12.
//  Copyright (c) 2013年 laudmankimo. All rights reserved.
//

#import "Legs.h"

@implementation Legs
@synthesize distance;
@synthesize duration;
@synthesize start_address;
@synthesize   end_address;
@synthesize start_location;
@synthesize   end_location;
@synthesize steps;

- (void) dealloc
{
	[distance release];
	[duration release];
	[start_address release];
	[end_address release];
	[steps release];
	[super dealloc];
}

@end
