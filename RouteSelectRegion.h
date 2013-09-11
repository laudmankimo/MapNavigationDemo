//
//  RouteSelectRegion.h
//  MapNavigationDemo
//
//  Created by laudmankimo on 13-9-11.
//  Copyright (c) 2013年 kai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouteSelectRegion : NSObject
{
    CGMutablePathRef region;	// it's a pointer
}

@property (nonatomic) CGMutablePathRef region;

- (id)init;
- (void)dealloc;
@end
