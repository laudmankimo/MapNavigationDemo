//
//  PlaceMark.m
//  Miller
//
//  Created by laudmankimo on 2/7/10.
//  Copyright 2010 laudmankimo. All rights reserved.
//

#import "PlaceMark.h"

@implementation PlaceMark
@synthesize coordinate;
@synthesize place;

- (id)initWithPlace:(Place *)p
{
    self = [super init];

    if (self != nil)
    {
        coordinate.latitude = [p.latitude doubleValue];
        coordinate.longitude = [p.longitude doubleValue];
        self.place = p;
    }

    return self;
}

- (NSString *)title
{
    return self.place.name;
}

- (NSString *)subtitle
{
    return self.place.description;
}

@end
