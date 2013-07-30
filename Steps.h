//
//  Steps.h
//  MapkitDirection
//
//  Created by laudmankimo on 13-7-12.
//  Copyright (c) 2013年 laudmankimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapkit/MapKit.h>
#import "Properties.h"

@interface Steps : NSObject
@property (nonatomic, retain) Properties *distance;
@property (nonatomic, retain) Properties *duration;
@property (nonatomic, readwrite) CLLocationCoordinate2D start_locatoin;
@property (nonatomic, readwrite) CLLocationCoordinate2D end_location;
@property (nonatomic, copy) NSString *html_instructions;
//@property (nonatomic, retain) NSMutableArray *polylines;
@property (nonatomic, copy) NSString *polyline;
@property (nonatomic, copy) NSString *travel_mode;

@end
