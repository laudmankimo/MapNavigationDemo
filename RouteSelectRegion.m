//
//  RouteSelectRegion.m
//  MapNavigationDemo
//
//  Created by laudmankimo on 13-9-11.
//  Copyright (c) 2013年 kai. All rights reserved.
//

#import "RouteSelectRegion.h"

@implementation RouteSelectRegion
@synthesize region;	// generate getter, setter

- (id) init
{
	self = [super init];
	
    if (self != nil)
    {
		region = CGPathCreateMutable();
    }

    return self;
}

- (void) dealloc
{
	CGPathRelease(self.region);
	[super dealloc];
}

@end
