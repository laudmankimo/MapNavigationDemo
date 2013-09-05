//
//  MapkitDirection.m
//  MapkitDirection
//
//  Created by laudmankimo on 13-7-12.
//  Copyright (c) 2013年 laudmankimo. All rights reserved.
//

#import "MapkitDirection.h"

@implementation MapkitDirection
@synthesize status;
@synthesize arrayOfRoutes;

- (void)dealloc
{
    [status release];
    [arrayOfRoutes release];
    [webdata release];
    [connection release];
    [super dealloc];
}

- (void)decodePolyLine:(NSMutableString *)encoded toArray:(NSMutableArray *)targetArray from:(CLLocationCoordinate2D)f to:(CLLocationCoordinate2D)t
{
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
    options :NSLiteralSearch
    range   :NSMakeRange(0, [encoded length])];

    NSInteger   len = [encoded length];
    NSInteger   index = 0;
    NSInteger   lat = 0;
    NSInteger   lng = 0;

    while (index < len)
    {
        NSInteger   b;
        NSInteger   shift = 0;
        NSInteger   result = 0;

        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);

        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;

        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);

        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        CLLocation *loc = [[CLLocation alloc] initWithLatitude:(lat * 1e-5)
            longitude:(lng * 1e-5)];

        [targetArray addObject:loc];
        [loc release];
    }

    CLLocation *first = [[CLLocation alloc]
        initWithLatitude:[[NSNumber numberWithFloat:f.latitude] floatValue]
        longitude       :[[NSNumber numberWithFloat:f.longitude] floatValue]];

    CLLocation *end = [[CLLocation alloc]
        initWithLatitude:[[NSNumber numberWithFloat:t.latitude] floatValue]
        longitude       :[[NSNumber numberWithFloat:t.longitude] floatValue]];

    [targetArray insertObject:first atIndex:0];
    [first release];
    [targetArray addObject:end];
    [end release];
}

- (BOOL)navigateFromPoint:(CLLocationCoordinate2D)src ToPoint:(CLLocationCoordinate2D)dst Alternative:(BOOL)alt Region:(NSString *)region avoidTolls:(BOOL)tolls avoidHighways:(BOOL)highways
{
    NSString *urlstring = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=(%f,%f)&destination=(%f,%f)&sensor=false&alternatives=%@&region=%@%@%@", src.latitude, src.longitude, dst.latitude, dst.longitude,
	(alt) ? @"true":@"false",
	region,
	(tolls)? @"&avoid=tolls" : nil,
	(highways) ? @"&avoid=highways" : nil
	];

    NSURL *url = [NSURL URLWithString:urlstring];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    connection = [NSURLConnection connectionWithRequest:request delegate:self];

    if (connection)
    {
        if (webdata == nil)
        {
            webdata = [[NSMutableData alloc]init];
        }

        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)navigateFrom:(NSString *)src To:(NSString *)dst Alternative:(BOOL)alt Region:(NSString *)region avoidTolls:(BOOL)tolls avoidHighways:(BOOL)highways
{
    NSString *urlstring = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=false&alternatives=%@&region=%@%@%@", src, dst,
	(alt) ? @"true":@"false",
	region,
	(tolls)? @"&avoid=tolls" : nil,
	(highways) ? @"&avoid=highways" : nil
	];

    NSURL           *url = [NSURL URLWithString:urlstring];
    NSURLRequest    *request = [NSURLRequest requestWithURL:url];

    connection = [NSURLConnection connectionWithRequest:request delegate:self];

    if (connection)
    {
        if (webdata == nil)
        {
            webdata = [[NSMutableData alloc]init];
        }
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webdata setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webdata appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"failed with error");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    Bounds          *tmpBounds = nil;
    Properties      *tmpProperties = nil;
    NSMutableArray  *tmpMutableArray = nil;
    NSString        *tmpString = nil;
	NSMutableString *encoded = nil;

    CLLocationCoordinate2D  start;
    CLLocationCoordinate2D  end;

    NSDictionary *allDataDictionary = [NSJSONSerialization JSONObjectWithData:webdata
        options:0 error:nil];

    if (status != nil)  // if previous google direction services status exist, free it!
    {
        [status dealloc];
    }

//    tmpString = [[NSString alloc]initWithFormat:@"%@", [allDataDictionary objectForKey:@"status"]];
//    status = tmpString;
//    [tmpString release];
//    tmpString = nil;
    status = [[NSString alloc]initWithFormat:@"%@", allDataDictionary[@"status"]];// retainCount = 2
    //	status = [NSString stringWithFormat:@"%@", [allDataDictionary objectForKey:@"status"]];

    if (arrayOfRoutes == nil)
    {
        arrayOfRoutes = [[NSMutableArray alloc]init];
    }
    else if ([arrayOfRoutes count] > 0)     // arrayOfRoutes not nil and has more than 1 object(s)
    {
        [arrayOfRoutes removeAllObjects];   // force empty and can be used later
    }

    if ([status isEqualToString:@"OK"])
    {
        NSLog(@"google navigation:OK!");
    }
    else
    {
        NSLog(@"google navigation failed!");
    }

    NSArray *routes = allDataDictionary[@"routes"];

    for (NSDictionary *diction in routes)
    {
        Routes *route = [[Routes alloc]init];

        tmpBounds = [[Bounds alloc]init];
        id id_in_routes = diction[@"bounds"][@"northeast"];
        tmpBounds.northeast = CLLocationCoordinate2DMake([id_in_routes[@"lat"] doubleValue], [id_in_routes[@"lng"]doubleValue]);

        id_in_routes = diction[@"bounds"][@"southwest"];
        tmpBounds.southwest = CLLocationCoordinate2DMake([id_in_routes[@"lat"] doubleValue], [id_in_routes[@"lng"] doubleValue]);
        route.bounds = tmpBounds;
        [tmpBounds release]; tmpBounds = nil;

        tmpString = [[NSString alloc]initWithFormat:@"%@", diction[@"summary"]];
        route.summary = tmpString;
        [tmpString release]; tmpString = nil;

        tmpString = [[NSString alloc]initWithFormat:@"%@", diction[@"copyrights"]]; // allocated new memory to hold string
        route.copyrights = tmpString;
        [tmpString release]; tmpString = nil;

        tmpMutableArray = [[NSMutableArray alloc]init];
        route.legs = tmpMutableArray;
        [tmpMutableArray release]; tmpMutableArray = nil;

        tmpMutableArray = [[NSMutableArray alloc]init];
        route.overview_polyline = tmpMutableArray;
        [tmpMutableArray release]; tmpMutableArray = nil;

        tmpMutableArray = [[NSMutableArray alloc]init];
        route.detailed_polyline = tmpMutableArray;
        [tmpMutableArray release]; tmpMutableArray = nil;

        NSArray *legs = diction[@"legs"];

        for (NSDictionary *diction2 in legs)
        {
            Legs    *leg = [[Legs alloc]init];
            id      id_in_legs;
            id_in_legs = diction2[@"distance"];
            tmpProperties = [[Properties alloc]init];

            tmpString = [[NSString alloc]initWithFormat:@"%@", id_in_legs[@"text"]];
            tmpProperties.text = tmpString;
            [tmpString release]; tmpString = nil;

            tmpProperties.value = [id_in_legs[@"value"] integerValue];
            leg.distance = tmpProperties;
            [tmpProperties release]; tmpProperties = nil;

            id_in_legs = diction2[@"duration"];
            tmpProperties = [[Properties alloc]init];

            tmpString = [[NSString alloc]initWithFormat:@"%@", id_in_legs[@"text"]];
            tmpProperties.text = tmpString;
            [tmpString release]; tmpString = nil;

            tmpProperties.value = [id_in_legs[@"value"] integerValue];
            leg.duration = tmpProperties;
            [tmpProperties release]; tmpProperties = nil;

            id_in_legs = diction2[@"start_address"];
            tmpString = [[NSString alloc]initWithFormat:@"%@", id_in_legs];
            leg.start_address = tmpString;
            [tmpString release]; tmpString = nil;

            id_in_legs = diction2[@"end_address"];
            tmpString = [[NSString alloc]initWithFormat:@"%@", id_in_legs];
            leg.end_address = tmpString;
            [tmpString release]; tmpString = nil;

            id_in_legs = diction2[@"start_location"];
            leg.start_location = CLLocationCoordinate2DMake([id_in_legs[@"lat"]doubleValue], [id_in_legs[@"lng"]doubleValue]);
            start = leg.start_location; // copy

            id_in_legs = diction2[@"end_location"];
            leg.end_location = CLLocationCoordinate2DMake([id_in_legs[@"lat"]doubleValue], [id_in_legs[@"lng"]doubleValue]);
            end = leg.end_location; // copy

            tmpMutableArray = [[NSMutableArray alloc]init];
            leg.steps = tmpMutableArray;
            [tmpMutableArray release]; tmpMutableArray = nil;

            NSArray *steps = diction2[@"steps"]; // get number of steps

            for (NSDictionary *diction3 in steps)
            {
                Steps   *step = [[Steps alloc]init];
                id      id_in_steps = nil;

                id_in_steps = diction3[@"distance"];
                tmpProperties = [[Properties alloc]init];
                tmpString = [[NSString alloc]initWithFormat:@"%@", id_in_steps[@"text"]];
                tmpProperties.text = tmpString;
                [tmpString release]; tmpString = nil;
                tmpProperties.value = [id_in_steps[@"value"]integerValue];
                step.distance = tmpProperties;
                [tmpProperties release];
                tmpProperties = nil;

                id_in_steps = diction3[@"duration"];
                tmpProperties = [[Properties alloc]init];
                tmpString = [[NSString alloc]initWithFormat:@"%@", id_in_steps[@"text"]];
                tmpProperties.text = tmpString;
                [tmpString release]; tmpString = nil;
                tmpProperties.value = [id_in_steps[@"value"]integerValue];
                step.distance = tmpProperties;
                [tmpProperties release];
                tmpProperties = nil;

                id_in_steps = diction3[@"start_location"];
                step.start_locatoin = CLLocationCoordinate2DMake([id_in_steps[@"lat"]doubleValue], [id_in_steps[@"lng"]doubleValue]);

                id_in_steps = diction3[@"end_location"];
                step.end_location = CLLocationCoordinate2DMake([id_in_steps[@"lat"]doubleValue], [id_in_steps[@"lng"]doubleValue]);

                id_in_steps = diction3[@"polyline"];
                tmpString = [[NSString alloc]initWithFormat:@"%@", id_in_steps[@"points"]];
                step.polyline = tmpString;
                [tmpString release]; tmpString = nil;

                id_in_steps = diction3[@"travel_mode"];
                tmpString = [[NSString alloc]initWithFormat:@"%@", id_in_steps];
                step.travel_mode = tmpString;
                [tmpString release]; tmpString = nil;

                id_in_steps = diction3[@"html_instructions"];
                tmpString = [[NSString alloc]initWithFormat:@"%@", id_in_steps];
                step.html_instructions = tmpString;
                [tmpString release]; tmpString = nil;

                [leg.steps addObject:step];
                [step release]; // retainCount -1
            } // for (NSDictionary *diction3 in steps)

            [route.legs addObject:leg];
            [leg release];  // retainCount -1
        } // for (NSDictionary *diction2 in legs)

		// translate 'overview_polyline' encoded polyline string to NSMutableArray of (CLLocation *)
        id_in_routes = diction[@"overview_polyline"];
        encoded = [[NSMutableString alloc]initWithFormat:@"%@", id_in_routes[@"points"]];
        [self decodePolyLine:encoded toArray:route.overview_polyline from:start to:end];
        [encoded release]; encoded = nil;    // free memory

		// translate 'detail_polyline' encoded polyline string to NSMutableArray of (CLLocation *)
		// not implemented yet

        [arrayOfRoutes addObject:route];
        [route release];    // retainCount -1
    } // for (NSDictionary *diction in routes)

	[self.delegate navigationCompleted];
}

@end
