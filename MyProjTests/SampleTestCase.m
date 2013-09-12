#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>
#import <MapKit/MapKit.h>
//#import "MyProjAppDelegate.h"


@interface mySampleClass : NSObject

+ (BOOL) alwaysReturnYES;
- (NSString *) returnObjectiveC;
@end

@implementation mySampleClass

+ (BOOL) alwaysReturnYES
{
	return YES;
}

- (NSString *) returnObjectiveC
{
	return @"Objective-C";
}

@end

@interface SampleLibTest : GHTestCase {}
@end

@implementation SampleLibTest

//- (void)testSimplePass
//{
//    // Another test
//}
//
- (void)testSimpleFail
{
    GHAssertTrue(YES, nil);
}

// simple test to ensure building, linking, and running test case works in the project
- (void)testlowercase
{
    id mock = [OCMockObject mockForClass:NSString.class];
    [[[mock stub] andReturn:@"mocktest"] lowercaseString];

    NSString *returnValue = [mock lowercaseString];
    GHAssertEqualObjects(@"mocktest", returnValue, @"Should have returned the expected string.");
}

- (void)testuppercase
{
    id mock = [OCMockObject mockForClass:NSString.class];
    [[[mock stub] andReturn:@"MOCKTEST"] uppercaseString];

    NSString *returnValue = [mock uppercaseString];
    GHAssertEqualObjects(@"MOCKTEST", returnValue, @"Should have returned the expected string.");
}

- (void)testOCMockFail
{
    id mock = [OCMockObject mockForClass:NSString.class];
    [[[mock stub] andReturn:@"mocktest"] lowercaseString];

    NSString *returnValue = [mock lowercaseString];
    GHAssertEqualObjects(@"thisIsTheWrongValueToCheck", returnValue, @"Should have returned the expected string.");
}

- (void)testReturnObjectiveC
{
//	mySampleClass *myClass = [[mySampleClass alloc]init];
    id mock = [OCMockObject mockForClass:mySampleClass.class];

	// it only means, you expected "you will call 'returnObjectiveC' with returned
	// 'Objective-C' NSString later when verify called

	[[[mock expect] andReturn:@"Objective-C" ] returnObjectiveC];
	NSString *returnedString2 = [mock returnObjectiveC];
//	NSString *returnedString = [myClass returnObjectiveC];

	[mock verify];

	GHAssertEqualStrings(returnedString2, @"Objective-C", nil);	// success
//	[mock returnObjectiveC];
//	BOOL returnValue = [mock notAlwaysReturnYES];
//	[mock verify];
//	[[[mock stub] andReturn:YES] alwaysReturnYES];
//	BOOL returnValue = [mySampleClass alwaysReturnYES];
//	GHAssertTrue(returnValue == YES, nil);
}

- (void)testInitWithFormat
{
//	id mock = [OCMockObject mockForClass:[NSString class]];
	NSString *aString = [[NSString alloc]initWithFormat:@"testing initWithFormat: %@, %d, %.3f", @"testString", 255, 123.456];

	GHAssertTrue( ([aString compare:@"testing initWithFormat: testString, 255, 123.456"] == NSOrderedSame), nil);
}

- (void)testMKMapkit_setShowsUserLocation
{
	id mock = [OCMockObject mockForClass:MKMapView.class];
//	mock stub
	[mock setShowsUserLocation:YES];
	BOOL show = [mock showsUserLocation];
	GHAssertTrue((show == YES), nil);
//	if (show)
//		NSLog(@"true");
//		else
//		NSLog(@"false");
//	GHAssertTrue((show == YES), @"%s", __FUNCTION__);
}

@end
