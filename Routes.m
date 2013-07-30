//
//  Routes.m
//  MapkitDirection
//
//  Created by laudmankimo on 13-7-12.
//  Copyright (c) 2013年 laudmankimo. All rights reserved.
//

#import "Routes.h"
#import "Bounds.h"

@implementation Routes
@synthesize bounds;
@synthesize copyrights;
@synthesize summary;
@synthesize legs;
@synthesize overview_polyline;
@synthesize detailed_polyline;

- (void) dealloc
{
	[bounds release];
	[copyrights release];
	[summary release];
	[legs release];
	[overview_polyline release];
	[detailed_polyline release];
	[super dealloc];
}

@end
