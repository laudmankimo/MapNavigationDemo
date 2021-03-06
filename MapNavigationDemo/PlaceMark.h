//
//  PlaceMark.h
//  Miller
//
//  Created by laudmankimo on 2/7/10.
//  Copyright 2010 laudmankimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Place.h"

@interface PlaceMark : NSObject <MKAnnotation>

@property (strong, nonatomic) Place *place;

- (id)initWithPlace:(Place *)p;

@end
