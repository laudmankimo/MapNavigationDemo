//
//  Legs.h
//  MapkitDirection
//
//  Created by laudmankimo on 13-7-12.
//  Copyright (c) 2013年 laudmankimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapkit/MapKit.h>
#import "Properties.h"
#import "Steps.h"

@interface Legs : NSObject
@property (nonatomic, retain) Properties *distance;
@property (nonatomic, retain) Properties *duration;
@property (nonatomic, copy) NSString *start_address;
@property (nonatomic, copy) NSString *end_address;
@property (nonatomic, readwrite) CLLocationCoordinate2D start_location;
@property (nonatomic, readwrite) CLLocationCoordinate2D end_location;
@property (nonatomic, retain) NSMutableArray *steps;
@end
