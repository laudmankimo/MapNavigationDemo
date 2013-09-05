//
//  ViewController.m
//  MapNavigationDemo
//
//  Created by laudmankimo on 12-11-26.
//  Copyright (c) 2012年 laudmankimo. All rights reserved.
//

#import "dbgprintf.h"
#import "ViewController.h"
#import "ASPolyline.h"
#import "ASPolylineView.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize directions;
@synthesize my_mapView;
@synthesize activity;
@synthesize routeInfoBar;
@synthesize navigationBar;
@synthesize numberOfRoutes;
@synthesize timeCosts;
@synthesize summary;
@synthesize arrayOfActivePolyline;
@synthesize arrayOfInactivePolyline;
@synthesize polylineIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
////////////////////////////////////////////////////////////////////////////////
    if ([CLLocationManager locationServicesEnabled])
    {
        locmanager = [[CLLocationManager alloc] init];          // 创建位置管理器
        locmanager.delegate = self;                             // 设置代理
        locmanager.desiredAccuracy = kCLLocationAccuracyBest;   // 指定需要的精度级别
        locmanager.distanceFilter = 1000.0f;                    // 设置距离筛选器
        [locmanager startUpdatingLocation];                     // 启动位置管理器
    }
////////////////////////////////////////////////////////////////////////////////
	directions = [[MapkitDirection alloc]init];
	directions.delegate = self;

	[activity startAnimating];

	[directions navigateFromPoint:CLLocationCoordinate2DMake
//(31.108654, 121.338329)
(28.6695, 115.85763)
	                      ToPoint:CLLocationCoordinate2DMake
//(31.131505, 121.334639)
(31.23145, 121.47651)
					  Alternative:YES
						   Region:@"cn"
					   avoidTolls:NO
					avoidHighways:NO];

	routeInfoBar.frame = CGRectMake(0.0, 0.0, 320.0, 45.0);
	navigationBar.frame = CGRectMake(0.0, 0.0, 320.0, 45.0);
}

- (void)viewDidUnload
{
	my_mapView = nil;
	activity = nil;
	routeInfoBar = nil;
	numberOfRoutes = nil;
	timeCosts = nil;
	[self setSummary:nil];
	[self setNavigationBar:nil];
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)centerMap
{
    MKCoordinateRegion region;
    CLLocationDegrees   maxLat = -90;	// south pole
    CLLocationDegrees   maxLon = -180;
    CLLocationDegrees   minLat = 90;	// north pole
    CLLocationDegrees   minLon = 180;

	__weak Routes *routexxx = [directions.arrayOfRoutes objectAtIndex:0];
	__weak NSArray *route1 = routexxx.overview_polyline;

	for (CLLocation *currentLocation in route1)	// faster forin loop
	{
		// scan every latitude and longitude to find max and min
        if (currentLocation.coordinate.latitude > maxLat)
		{
            maxLat = currentLocation.coordinate.latitude;
		}
        if (currentLocation.coordinate.latitude < minLat)
		{
            minLat = currentLocation.coordinate.latitude;
		}
        if (currentLocation.coordinate.longitude > maxLon)
		{
            maxLon = currentLocation.coordinate.longitude;
		}
        if (currentLocation.coordinate.longitude < minLon)
		{
            minLon = currentLocation.coordinate.longitude;
		}
	}

	// get the center of the path between max and min (lat,long)
    region.center.latitude = (maxLat + minLat) / 2;
    region.center.longitude = (maxLon + minLon) / 2;
    region.span.latitudeDelta = maxLat - minLat + 0.018;
    region.span.longitudeDelta = maxLon - minLon + 0.018;

    [my_mapView setRegion:region animated:YES];
}

- (void)updateRouteInfoBar
{
    if (my_mapView.overlays.count == 1)
    {
        return;
    }

    NSUInteger totalRouteCount = ([arrayOfInactivePolyline count]);

    __weak Routes   *weakRoutePointer = [directions.arrayOfRoutes objectAtIndex:polylineIndex];
    __weak Legs     *weakLegPointer = [weakRoutePointer.legs objectAtIndex:0];

    numberOfRoutes.text = [NSString stringWithFormat:@"路线 %d (共 %d 条建议路线)",
        polylineIndex + 1,
        totalRouteCount];

    timeCosts.text = [NSString stringWithFormat:@"%@ - %@ - %@",
        weakLegPointer.duration.text,
        weakLegPointer.distance.text,
        weakRoutePointer.summary];

	CGSize size = [timeCosts.text sizeWithFont:timeCosts.font constrainedToSize:CGSizeMake(MAXFLOAT, timeCosts.frame.size.height)];

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];

	if (size.width > 320.0)
	{
		routeInfoBar.frame = CGRectMake(0.0, 0.0, 320.0, 65.0);
		navigationBar.frame = CGRectMake(0.0, 0.0, 320.0, 65.0);
		timeCosts.text = [NSString stringWithFormat:@"%@ - %@",
		weakLegPointer.duration.text,
		weakLegPointer.distance.text];

		summary.text = [NSString stringWithFormat:@"%@", weakRoutePointer.summary];
	}
	else
	{
		routeInfoBar.frame = CGRectMake(0.0, 0.0, 320.0, 45.0);
		navigationBar.frame = CGRectMake(0.0, 0.0, 320.0, 45.0);
	}
    [UIView commitAnimations];
}

- (void)showRouteFrom:(Place *)f to:(Place *)t
{
	// remove all annotation on mapview
    if (directions.arrayOfRoutes)
	{
        [my_mapView removeAnnotations:my_mapView.annotations];
	}

    PlaceMark   *from = [[PlaceMark alloc] initWithPlace:f];	f = nil;
    PlaceMark   *to = [[PlaceMark alloc] initWithPlace:t];	t = nil;

    [my_mapView addAnnotation:from];	from = nil;
    [my_mapView addAnnotation:to];	to = nil;

    [self updateRouteView];
    [self centerMap];
}

- (void)updateRouteView
{
	// remove all polyline(overlay)on MapView
    [my_mapView removeOverlays:my_mapView.overlays];

	ASPolyline *lineOne = nil;

	if (arrayOfActivePolyline == nil)
		arrayOfActivePolyline = [[NSMutableArray alloc]init];
	else
		[arrayOfActivePolyline removeAllObjects];

	if (arrayOfInactivePolyline == nil)
		arrayOfInactivePolyline = [[NSMutableArray alloc]init];
	else
		[arrayOfInactivePolyline removeAllObjects];

	NSUInteger u = 0;
	__weak NSMutableArray *_tmpMutableArray = directions.arrayOfRoutes;

	NSUInteger uu = 0;
	for (Routes *routexxx in _tmpMutableArray)
	{
		__weak NSArray *route = routexxx.overview_polyline;	// use weak pointer to prevent autoincrease of retainCount
		NSUInteger pointCount = [route count];
    	CLLocationCoordinate2D  pointsToUse[pointCount];
		u = 0;
		for (CLLocation *loc in route)
		{
	        CLLocationCoordinate2D  coords;
    	    coords.latitude = loc.coordinate.latitude;
	        coords.longitude = loc.coordinate.longitude;
        	pointsToUse[u] = coords;
			u++;
		}
		lineOne = (ASPolyline *)[ASPolyline polylineWithCoordinates:pointsToUse count:pointCount];
		lineOne.active = NO;
		// if there is only one route ,it is no need to draw 2 layer of active/inactive route on the mapview
		if ([_tmpMutableArray count] != 1)
		{
    		[my_mapView addOverlay:lineOne];
			[arrayOfInactivePolyline addObject:lineOne];
		}
#ifdef DEBUG
NSLog(@"%u %@ %@", uu, lineOne.active ? @"active" : @"inactive", lineOne);
#endif
		lineOne = nil;

		lineOne = (ASPolyline *)[ASPolyline polylineWithCoordinates:pointsToUse count:pointCount];
		lineOne.active = YES;
		[arrayOfActivePolyline addObject:lineOne];
		lineOne = nil;
		uu++;
	}

	// set first route as active route
//	lineOne = [arrayOfActivePolyline objectAtIndex:[arrayOfActivePolyline count]-1];
	lineOne = [arrayOfActivePolyline objectAtIndex:0];
	[my_mapView addOverlay:lineOne];
#ifdef DEBUG
NSLog(@"%u %@ %@", uu, lineOne.active ? @"active" : @"inactive", lineOne);
#endif
	lineOne = nil;
	polylineIndex = 0;
}

//        CGContextRef context = CGBitmapContextCreate(nil,
//                routeView.frame.size.width,
//                routeView.frame.size.height, 8,
//		      4 * routeView.frame.size.width,
//                CGColorSpaceCreateDeviceRGB(),
//                kCGImageAlphaPremultipliedLast);
//
//        CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
//        CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
//        CGContextSetLineWidth(context, 10);
//        CGContextSetAlpha(context, 0.5);
//		  NSUInteger u = 0;
//
//		  for (CLLocation location in routes)
//        {
//            CGPoint     point = [my_mapView convertCoordinate:location.coordinate toPointToView:routeView];
//            if (u == 0)
//            {
//                CGContextMoveToPoint(context, point.x, routeView.frame.size.height - point.y);
//				u++;
//            }
//            else
//            {
//                CGContextAddLineToPoint(context, point.x, routeView.frame.size.height - point.y);
//            }
//        }
//        CGContextStrokePath(context);
//        CGImageRef  image = CGBitmapContextCreateImage(context);
//        UIImage     *img = [UIImage imageWithCGImage:image];
//        routeView.image = img;
//        CGContextRelease(context);

#pragma mark - UIGestureRecognizerDelegate functions

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer
						 :(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (IBAction)longPressAct:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
//CGPoint                 touchPoint = [recognizer locationInView:my_mapView];
//CLLocationCoordinate2D  coordinate = [my_mapView convertPoint:touchPoint
//toCoordinateFromView:my_mapView];
//dst.latitude = [dst.latitude initWithDouble:coordinate.latitude];
//dst.longitude = [dst.longitude initWithDouble:coordinate.longitude];
//[self showRouteFrom:src to:dst];
    }
}

- (BOOL)isTouchPoint:(CGPoint)touchPoint touchInsidePolyline:(ASPolyline *)polyline
{
    if ([polyline.finalPath count] != 0)
    {
        CGMutablePathRef    pathRef = CGPathCreateMutable();
        NSMutableArray      *mutableArray = polyline.finalPath;
        MKMapPoint          mapPoint;
        BOOL                first_time = YES;
        BOOL                result;
        CGPoint             point;

        for (NSValue *value in mutableArray)
        {
            [value getValue:&mapPoint];
            point = [my_mapView convertCoordinate:MKCoordinateForMapPoint(mapPoint) toPointToView:my_mapView];

            if (first_time)
            {
                CGPathMoveToPoint(pathRef, NULL, point.x, point.y);
                // NSLog(@"firstPoint(x, y) = (%f, %f)", point.x, point.y);
                first_time = NO;
            }
            else
            {
                CGPathAddLineToPoint(pathRef, NULL, point.x, point.y);
                // NSLog(@"nextPoint(x, y) = (%f, %f)", point.x, point.y);
            }
        }

        CGPathCloseSubpath(pathRef);

        if (CGPathContainsPoint(pathRef, nil, touchPoint, NO))
        {
            result = YES;
        }
        else
        {
            result = NO;
        }

        CGPathRelease(pathRef);
        return result;
    }

    return NO;
}

- (IBAction)singleTapAct:(UITapGestureRecognizer *)recognizer
{
//	MKMapView               *mapView = (MKMapView *)recognizer.view;
//	CGPoint                 touchPoint = [recognizer locationInView:mapView];
//	CLLocationCoordinate2D  touchMapCoordinate = [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
//	CGPoint					touchPoint2 = [mapView convertCoordinate:touchMapCoordinate toPointToView:mapView];
//#ifdef DEBUG
//	NSLog(@"touchPoint(x, y) = (%f, %f)", touchPoint.x, touchPoint.y);
//#endif
//	NSUInteger u = 1;	
//	for (ASPolyline *polyline in arrayOfInactivePolyline)
//	{
//		if ([self isTouchPoint:touchPoint touchInsidePolyline:polyline])
//		{
//			NSLog(@"you just touched INactive path %u %@", u, polyline);
//		}
//		u++;
//	}
//	u = 1;
//	for (ASPolyline *polyline in arrayOfActivePolyline)
//	{
//		if ([self isTouchPoint:touchPoint touchInsidePolyline:polyline])
//		{
//			NSLog(@"you just touched   Active path %u %@", u, polyline);
//		}
//		u++;
//	}

	// if there is only one path on the map, do nothing
	if ([directions.status isEqualToString:@"OK"])
	{
		if (my_mapView.overlays.count == 1)// one active and one inactive
			return;

		// remove active, last polyline (top layer) on the map
		[my_mapView removeOverlay:[my_mapView.overlays lastObject]];

		// switch active to next polyline
		NSUInteger totalRouteCount = ([arrayOfInactivePolyline count]);

		polylineIndex = (polylineIndex == totalRouteCount-1) ? 0 : (polylineIndex+1);

		// set active poly line to next polyline
		ASPolyline *lineOne = [arrayOfActivePolyline objectAtIndex:polylineIndex];
		[my_mapView addOverlay:lineOne];
		lineOne = nil;
		[self updateRouteInfoBar];
	}
}

//- (IBAction)userCurrentLocation:(id)sender
//{
//    locmanager = [[CLLocationManager alloc]init];
//    locmanager.delegate = self;
//    locmanager.desiredAccuracy = kCLLocationAccuracyBest;
//    [locmanager startUpdatingLocation];
//}

#pragma mark - CLLocationManagerDelegate functions

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
//    dbgprintf(@"%f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
//    dst = [[Place alloc] init];
//    dst.name = @"Office";
//    dst.description = @"Bad office";
//    dst.latitude = [dst.latitude initWithDouble:loc.latitude];
//    dst.longitude = [dst.longitude initWithDouble:loc.longitude];
//    [self showRouteFrom:src to:dst];
}

#pragma mark - MKMapViewDelegate functions

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[PlaceMark class]])
    {
        static NSString *const  kPinAnnotationIdentifier = @"PinIdentifier";
        MKPinAnnotationView     *pinView = (MKPinAnnotationView *)[my_mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];

        if (pinView)
        {
            pinView.annotation = annotation;
        }
        else
        {
            pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation
                									 reuseIdentifier:kPinAnnotationIdentifier];
        }
		pinView.canShowCallout = YES;

		if ([[annotation title] isEqualToString:@"Home"])
			pinView.pinColor = MKPinAnnotationColorGreen;
		else if ([[annotation title] isEqualToString:@"Office"])
			pinView.pinColor = MKPinAnnotationColorRed;

        return pinView;
    }

    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[ASPolyline class]])
	{
//MKPolylineView *lineView = [[MKPolylineView alloc] initWithOverlay:overlay];
		ASPolylineView *polylineView = [[ASPolylineView alloc] initWithPolyline:(ASPolyline *)overlay];
		ASPolyline *lineOne = overlay;

		//polylineView.lineJoin = kCGLineJoinBevel;
		//polylineView.lineCap = kCGLineCapRound;
		polylineView.lineJoin = kCGLineJoinRound;
		polylineView.lineCap = kCGLineCapSquare;

       if (lineOne.active)
       {
            polylineView.lineWidth = 5.0f;
            polylineView.borderMultiplier = 2.0f;
            //polylineView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.0f];
            //polylineView.fillColor = [UIColor blueColor];
            polylineView.strokeColor = [[UIColor blueColor]colorWithAlphaComponent:0.1f];
            polylineView.borderColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f];
            // uncomment these line if you want to enable dash line
            //NSArray *lineDashPattern = @[@4, @8];
            //polylineView.lineDashPhase = 2.0f;
            //polylineView.lineDashPattern = lineDashPattern;
       }
       else	// inactive
       {
            polylineView.lineWidth = 5.0f;
            polylineView.borderMultiplier = 1.5f;
            //polylineView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.0f];
            //polylineView.fillColor = [UIColor cyanColor];
            polylineView.strokeColor = [[UIColor blueColor]colorWithAlphaComponent:0.1f];
			//[UIColor colorWithRed:0.5f green:0.5f blue:1.0f alpha:0.1f];
            polylineView.borderColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f];
       }
        return polylineView;
	}
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	MKZoomScale zoomScale = mapView.visibleMapRect.size.width / mapView.frame.size.width;
    double zoomExponent = log2(zoomScale);
    self.zoomLevel = (NSUInteger)(20 - ceil(zoomExponent));
	self.zoomLabel.text = [NSString stringWithFormat:@"current zoom level : %d", self.zoomLevel];
}

#pragma mark - MapkitDirectionsDelegate functions

- (void)navigationCompleted
{
	// shows the routeInfoBar
    routeInfoBar.hidden = NO;

	if (src) src = nil;
	if (dst) dst = nil;

    src = [[Place alloc]init];
    dst = [[Place alloc]init];
    src.name = @"Home";
    src.description = @"Sweet home";
    dst.name = @"Office";
    dst.description = @"Bad office";

	Routes *route = [directions.arrayOfRoutes objectAtIndex:0];
	Legs *leg = [route.legs objectAtIndex:0];
	CLLocationCoordinate2D start = leg.start_location;
	CLLocationCoordinate2D end = leg.end_location;
	route = nil;
	leg = nil;
	src.latitude = [[NSNumber alloc]initWithDouble:start.latitude];
	src.longitude = [[NSNumber alloc]initWithDouble:start.longitude];
	dst.latitude = [[NSNumber alloc]initWithDouble:end.latitude];
	dst.longitude = [[NSNumber alloc]initWithDouble:end.longitude];

    [self showRouteFrom:src to:dst];
	src = nil;
	dst = nil;
    [activity stopAnimating];
	[self updateRouteInfoBar];
}

@end
