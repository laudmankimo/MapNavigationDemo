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

	[directions navigateFromPoint:CLLocationCoordinate2DMake(28.6695, 115.85763)
	                      ToPoint:CLLocationCoordinate2DMake(31.23145, 121.47651)
					  Alternative:YES
						   Region:@"cn"
					   avoidTolls:NO
					avoidHighways:NO];
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
		[routeInfoBar setFrame:CGRectMake(0.0, 0.0, 320.0, 64.0)];
		[navigationBar setFrame:CGRectMake(0.0, 0.0, 320.0, 64.0)];
		timeCosts.text = [NSString stringWithFormat:@"%@ - %@",
		weakLegPointer.duration.text,
		weakLegPointer.distance.text];

		summary.text = [NSString stringWithFormat:@"%@", weakRoutePointer.summary];
	}
	else
	{
		[routeInfoBar setFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
		[navigationBar setFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
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

    PlaceMark   *from = [[PlaceMark alloc] initWithPlace:f];
    PlaceMark   *to = [[PlaceMark alloc] initWithPlace:t];

    [my_mapView addAnnotation:from];
    [my_mapView addAnnotation:to];

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
    	[my_mapView addOverlay:lineOne];
		[arrayOfInactivePolyline addObject:lineOne];
		lineOne = nil;

		lineOne = (ASPolyline *)[ASPolyline polylineWithCoordinates:pointsToUse count:pointCount];
		lineOne.active = YES;
		[arrayOfActivePolyline addObject:lineOne];
		lineOne = nil;
	}

	// set first route as active route
//	lineOne = [arrayOfActivePolyline objectAtIndex:[arrayOfActivePolyline count]-1];
	lineOne = [arrayOfActivePolyline objectAtIndex:0];
	[my_mapView addOverlay:lineOne];
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
//        CGContextSetLineJoin(context, kCGLineJoinRound);
//        CGContextSetLineCap(context, kCGLineCapRound);
//
//		  NSUInteger u = 0;
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
//        CGPoint                 touchPoint = [recognizer locationInView:my_mapView];
//        CLLocationCoordinate2D  coordinate = [my_mapView convertPoint:touchPoint
//													  toCoordinateFromView:my_mapView];
//        dst.latitude = [dst.latitude initWithDouble:coordinate.latitude];
//        dst.longitude = [dst.longitude initWithDouble:coordinate.longitude];
//        [self showRouteFrom:src to:dst];
    }
}

- (IBAction)singleTapAct:(UITapGestureRecognizer *)recognizer
{
//	MKMapView               *mapView = (MKMapView *)recognizer.view;
//	ASPolylineView          *tappedOverlay = nil;
//	CGPoint                 touchPoint = [recognizer locationInView:mapView];
//	CLLocationCoordinate2D  touchMapCoordinate = [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
//	MKMapPoint              mapPoint = MKMapPointForCoordinate(touchMapCoordinate);
//	NSUInteger				u = 1;
//	
//	for (ASPolyline *polyline in arrayOfInactivePolyline)
//	{
//		ASPolylineView *view = (ASPolylineView *)[mapView viewForOverlay:polyline];
//		CGPoint polygonViewPoint = [view pointForMapPoint:mapPoint];
//		
//		if (CGPathContainsPoint(view.path, nil, polygonViewPoint, NO))
//		{
//			NSLog(@"you just touched INactive path %d!", u);
//		}
//		if (CGPathContainsPoint(view.path, nil, touchPoint, NO))
//		{
//			NSLog(@"you just touched INactive path %d!", u);
//		}
//		u++;
//	}
//	u = 1;
//	for (ASPolyline *polyline in arrayOfActivePolyline)
//	{
//		ASPolylineView *view = (ASPolylineView *)[my_mapView viewForOverlay:polyline];
//		CGPoint polygonViewPoint = [view pointForMapPoint:mapPoint];
//
//		if (CGPathContainsPoint(view.path, nil, polygonViewPoint, NO))
//		{
//			NSLog(@"you just touched active path %d!", u);
//		}
//		if (CGPathContainsPoint(view.path, nil, touchPoint, NO))
//		{
//			NSLog(@"you just touched active path %d!", u);
//		}
//		u++;
//	}

//	NSMutableArray *tappedOverlays = [[NSMutableArray alloc]init];    // 0 object
//    MKMapView       *mapView = (MKMapView *)recognizer.view;
//    id <MKOverlay>  tappedOverlay = nil;
//
//    for (id <MKOverlay> overlay in arrayOfInactivePolyline)
//    {
//        MKOverlayView *view = [mapView viewForOverlay:overlay];
////		view hitTest: withEvent:
//    	if (overlay != nil)
//    	{
//        	UIView* hitView = [view hitTest:[recognizer locationInView:view] withEvent:nil];
//			if (hitView == view)
//			{
//				NSLog(@"your touch inside the polyline");
//			}
//    	}
//        if (view)
//        {
//            // Get view frame rect in the mapView's coordinate system
//            CGRect viewFrameInMapView = [view.superview convertRect:view.frame toView:mapView];
//            // Get touch point in the mapView's coordinate system
//            CGPoint point = [recognizer locationInView:mapView];
//
//            // Check if the touch is within the view bounds
//            if (CGRectContainsPoint(viewFrameInMapView, point))
//            {
//                //        tappedOverlay = overlay;
//                [tappedOverlays addObject:overlay];
//                //        break;
//                continue;
//            }
//        }
//    }
//    for (id <MKOverlay> overlay in tappedOverlays)
//    {
//        NSLog(@"Tapped view: %@", [mapView viewForOverlay:overlay]);
//    }

	// if there is only one path on the map, do nothing
	if ([directions.status isEqualToString:@"OK"])
	{
		if (my_mapView.overlays.count == 1)
			return;

		// remove active, last polyline (top layer) on the map
		[my_mapView removeOverlay:[my_mapView.overlays lastObject]];

		// find out current active polyline
		NSUInteger totalRouteCount = ([arrayOfInactivePolyline count]);

		if (polylineIndex == (totalRouteCount - 1))
			polylineIndex = 0;
		else
			polylineIndex++;

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
       if (lineOne.active)
       {
            polylineView.lineWidth = 5.0f;
            polylineView.borderMultiplier = 1.5f;
            //polylineView.backgroundColor = [UIColor clearColor];
            //polylineView.fillColor = [UIColor blueColor];
            polylineView.strokeColor = [[UIColor blueColor]colorWithAlphaComponent:0.5f];
            polylineView.borderColor = [UIColor colorWithRed:0.0f green:0.1f blue:1.0f alpha:1.0f];

            // uncomment these line if you want to enable dash line
            NSArray *lineDashPattern = @[@4, @8];
            polylineView.lineDashPhase = 2.0f;
            polylineView.lineDashPattern = lineDashPattern;
       }
       else	// inactive
       {
            polylineView.lineWidth = 4.0f;
            polylineView.borderMultiplier = 1.5f;
            //polylineView.backgroundColor = [UIColor clearColor];
            //polylineView.fillColor = [UIColor blueColor];
            polylineView.strokeColor = [UIColor colorWithRed:0.0f green:0.5f blue:0.5f alpha:0.2f];
            polylineView.borderColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f];
       }
		polylineView.lineJoin = kCGLineJoinBevel;
		polylineView.lineCap = kCGLineJoinRound;

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

    src = [[Place alloc]init];
    src.name = @"Home";
    src.description = @"Sweet home";
    src.latitude = [[NSNumber alloc]initWithDouble:28.6695];
    src.longitude = [[NSNumber alloc]initWithDouble:115.85763];

    dst = [[Place alloc] init];
    dst.name = @"Office";
    dst.description = @"Bad office";
    dst.latitude = [[NSNumber alloc]initWithDouble:31.23145];
    dst.longitude = [[NSNumber alloc]initWithDouble:121.47651];

    //[activity startAnimating];
    [self showRouteFrom:src to:dst];
    [activity stopAnimating];
	[self updateRouteInfoBar];
}

@end
