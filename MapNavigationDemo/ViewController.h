//
//  ViewController.h
//  MapNavigationDemo
//
//  Created by laudmankimo on 12-11-26.
//  Copyright (c) 2012年 laudmankimo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Place.h"
#import "PlaceMark.h"
#import "MapkitDirection.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, MapkitDirectionsDelegate>
{
    CLLocationManager   *locmanager;
    Place               *src;
    Place               *dst;
}

@property (nonatomic, strong) MapkitDirection *directions;

// the weak objects are references to xib/nib or storyboard,so it should not increases
// the retainCount of objects in xib/nib or storyboard
@property (nonatomic, weak) IBOutlet MKMapView                  *my_mapView;
@property (nonatomic, weak) IBOutlet UILabel                    *zoomLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView    *activity;
@property (nonatomic, weak) IBOutlet UIView                     *routeInfoBar;
@property (nonatomic, weak) IBOutlet UINavigationBar            *navigationBar;
@property (nonatomic, weak) IBOutlet UILabel                    *numberOfRoutes;
@property (nonatomic, weak) IBOutlet UILabel                    *timeCosts;
@property (nonatomic, weak) IBOutlet UILabel                    *summary;
@property (nonatomic, strong) NSMutableArray                    *arrayOfActivePolyline;
@property (nonatomic, strong) NSMutableArray                    *arrayOfInactivePolyline;
@property (nonatomic, readwrite) NSUInteger                     polylineIndex;
@property (nonatomic, readwrite) NSUInteger                     zoomLevel;

// long Press used to put annotation on the map
- (IBAction)longPressAct:(UILongPressGestureRecognizer *)recognizer;
// single tap used to choose active route
- (IBAction)singleTapAct:(UITapGestureRecognizer *)recognizer;

- (void)showRouteFrom:(Place *)f to:(Place *)t;
- (void)updateRouteView;
- (void)centerMap;
- (void)updateRouteInfoBar;
@end
