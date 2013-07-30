//
//  MapkitDirection.h
//  MapkitDirection
//
//  Created by laudmankimo on 13-7-12.
//  Copyright (c) 2013年 laudmankimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Routes.h"
#import "Legs.h"
#import "Steps.h"

@class  MapkitDirection;

@protocol MapkitDirectionsDelegate <NSObject>

- (void) navigationCompleted;

@end

@interface MapkitDirection : NSObject <NSURLConnectionDelegate>
{
	NSMutableData *webdata;
	NSURLConnection *connection;
	NSMutableArray *array;
}
@property (nonatomic, copy) NSString *status;
@property (nonatomic, retain) NSMutableArray *arrayOfRoutes;
@property (nonatomic, assign) id<MapkitDirectionsDelegate> delegate;

- (void)decodePolyLine:(NSMutableString *)encoded toArray:(NSMutableArray *)targetArray from:(CLLocationCoordinate2D)f to:(CLLocationCoordinate2D)t;

- (BOOL)navigateFromPoint:(CLLocationCoordinate2D)src ToPoint:(CLLocationCoordinate2D)dst Alternative:(BOOL)alt Region:(NSString *)region avoidTolls:(BOOL)tolls avoidHighways:(BOOL)highways;

- (BOOL)navigateFrom:(NSString *)src To:(NSString *)dst Alternative:(BOOL)alt Region:(NSString *)region avoidTolls:(BOOL)tolls avoidHighways:(BOOL)highways;
@end
