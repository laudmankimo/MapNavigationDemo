//
//  Routes.h
//  MapkitDirection
//
//  Created by laudmankimo on 13-7-12.
//  Copyright (c) 2013年 laudmankimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bounds.h"
#import "Legs.h"

@interface Routes : NSObject
@property (nonatomic, retain) Bounds *bounds;
@property (nonatomic, copy) NSString *copyrights;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, retain) NSMutableArray *legs;
@property (nonatomic, retain) NSMutableArray *overview_polyline; // array of CLLocationCoordinate2D
@property (nonatomic, retain) NSMutableArray *detailed_polyline; // array of CLLocationCoordinate2D
@end
