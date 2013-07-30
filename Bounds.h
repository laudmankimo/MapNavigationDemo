//
//  Bounds.h
//  MapkitDirection
//
//  Created by laudmankimo on 13-7-12.
//  Copyright (c) 2013年 laudmankimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Bounds : NSObject
@property (nonatomic, readwrite) CLLocationCoordinate2D northeast;
@property (nonatomic, readwrite) CLLocationCoordinate2D southwest;
@end
