//
//  ASPolylineView.m
//
//  Created by Adrian Schoenig on 21/02/13.
//
//

#import "ASPolylineView.h"
#import "dbgprintf.h"
@interface ASPolylineView ()

// @property (nonatomic, strong) MKPolyline *polyline;
@property (nonatomic, strong) ASPolyline *polyline;
// @property (nonatomic, retain) UIColor *backgroundColor;

@end

@implementation ASPolylineView

- (id)initWithPolyline:(MKPolyline *)polyline
{
    self = [super initWithOverlay:polyline];

    if (self)
    {
        self.polyline = (ASPolyline *)polyline;
		// defaults
        self.borderColor = [[UIColor blackColor]colorWithAlphaComponent:1.0f];
        self.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:1.0f];
        self.borderMultiplier = 2.0f;
    }

    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
	//LOG_FUNCTION;
//    CGFloat baseWidth = self.lineWidth;
    static CGFloat widthTable[] = {1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 2.0f, 2.0f, 2.0f, 2.0f, 2.0f, 2.0f, 2.0f, 2.0f, 1.0f,
                                   1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f};

    CGFloat     adjustedZoomscale = 1.0f / zoomScale;
    double      zoomExponent = log2(adjustedZoomscale);
    NSUInteger  zoomLevel = (NSUInteger)(20 - ceil(zoomExponent));
    CGFloat     baseWidth = widthTable[zoomLevel];

	// draw the border. it's slightly wider than the specified line width.
    [self drawLine:self.borderColor.CGColor width:baseWidth * self.borderMultiplier allowDashes:NO forZoomScale:zoomScale inContext:context];

	// a white background.
    [self drawLine:self.backgroundColor.CGColor width:baseWidth allowDashes:NO forZoomScale:zoomScale inContext:context];

	// draw the actual line.
    [self drawLine:self.strokeColor.CGColor width:baseWidth allowDashes:YES forZoomScale:zoomScale inContext:context];

	//[self drawLine:self.borderColor.CGColor width:baseWidth * self.borderMultiplier allowDashes:YES forZoomScale:zoomScale inContext:context];

	// CGImageRef imageReference = self.overlayImage.CGImage;
#ifdef DEBUGXXX
        MKMapRect   theMapRect = self.overlay.boundingMapRect;
        CGRect      theRect = [self rectForMapRect:theMapRect];
        CGContextSetRGBFillColor(context, 0.0f, 0.0f, 1.0f, 0.1f);	// blue
        CGContextFillRect(context, theRect);
#endif

    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
}

- (void)createPath
{
	//LOG_FUNCTION;
	// turn the polyline into a path
    CGMutablePathRef    newPath = CGPathCreateMutable();
    BOOL                pathIsEmpty = YES;
    NSUInteger          pointCount = self.polyline.pointCount;	// for performance
    CGPoint             point;

    for (NSUInteger idx = 0; idx < pointCount; idx++)
    {
        point = [self pointForMapPoint:self.polyline.points[idx]];

        if (pathIsEmpty)
        {
            CGPathMoveToPoint(newPath, nil, point.x, point.y);
            pathIsEmpty = NO;
        }
        else
        {
            CGPathAddLineToPoint(newPath, nil, point.x, point.y);
        }
    }

    self.path = newPath;
    CGPathRelease(newPath);

	// turn the polyline into a path
//    CGMutablePathRef
//	newPath = CGPathCreateMutable();
//    BOOL
//	pathIsEmpty = YES;
//    NSUInteger          pointCount = self.polyline.pointCount;  // for performance
//    CGPoint             center;
//    CGPoint             point;
//    CGPoint             nextPoint;
//    CGPoint             vector;
//    float               angle;
//
//    MKMapPoint  pointGlobal;
//    NSValue     *pptGlobal;
//
//    if (self.polyline.finalPath == nil)
//    {
//        self.polyline.finalPath = [[NSMutableArray alloc]init]; // 0 objects
//    }
//    else
//    {
//        [self.polyline.finalPath removeAllObjects];
//    }
//
//    // forward
//    for (NSUInteger idx = 0; idx < pointCount; idx++)
//    {
//        center = [self pointForMapPoint:self.polyline.points[idx]];
//
//        if (idx == (pointCount - 1))  // last point
//        {
//            pointGlobal = [self mapPointForPoint:center];
//            pptGlobal = [NSValue value:&pointGlobal withObjCType:@encode(MKMapPoint)];
//            [self.polyline.finalPath addObject:pptGlobal];
//            pptGlobal = nil;
//
//            CGPathAddLineToPoint(newPath, NULL, center.x, center.y);
//            break;
//        }
//
//        nextPoint = [self pointForMapPoint:self.polyline.points[idx + 1]];
//        vector = CGPointMake(nextPoint.x - center.x, nextPoint.y - center.y);
//        angle = atan2f(vector.y, vector.x);
//
//        point.x = center.x + (sinf(angle) * self.lineWidth);
//        point.y = center.y + (cosf(angle) * self.lineWidth);
//
//        pointGlobal = [self mapPointForPoint:point];
//        pptGlobal = [NSValue value:&pointGlobal withObjCType:@encode(MKMapPoint)];
//        [self.polyline.finalPath addObject:pptGlobal];
//        pptGlobal = nil;
//
//        if (pathIsEmpty)
//        {
//            CGPathMoveToPoint(newPath, NULL, center.x, center.y);
//            pathIsEmpty = NO;
//        }
//        else
//        {
//            CGPathAddLineToPoint(newPath, NULL, center.x, center.y);
//        }
//    }
//
//    // backward
//    for (NSInteger idx = (pointCount - 2); idx >= 0; idx--)
//    {
//        center = [self pointForMapPoint:self.polyline.points[idx]];
//
//        if (idx == 0)   // last point
//        {
//            pointGlobal = [self mapPointForPoint:center];
//            pptGlobal = [NSValue value:&pointGlobal withObjCType:@encode(MKMapPoint)];
//            [self.polyline.finalPath addObject:pptGlobal];
//            pptGlobal = nil;
//            CGPathAddLineToPoint(newPath, NULL, center.x, center.y);
//            break;
//        }
//
//        nextPoint = [self pointForMapPoint:self.polyline.points[idx - 1]];
//        vector = CGPointMake(nextPoint.x - center.x, nextPoint.y - center.y);
//        angle = atan2f(vector.y, vector.x);
//
//        point.x = center.x + (sinf(angle) * self.lineWidth);
//        point.y = center.y + (cosf(angle) * self.lineWidth);
//
//        pointGlobal = [self mapPointForPoint:point];
//        pptGlobal = [NSValue value:&pointGlobal withObjCType:@encode(MKMapPoint)];
//        [self.polyline.finalPath addObject:pptGlobal];
//        pptGlobal = nil;
//
//        CGPathAddLineToPoint(newPath, NULL, point.x, point.y);
//    }
//    CGPathCloseSubpath(newPath);
//	self.path = newPath;
//    CGPathRelease(newPath);

//下列代码显示出了地图上的MKOverlay的坐标系统
//	BOOL pathIsEmpty = YES;
//	CGMutablePathRef pathRef = CGPathCreateMutable();
//	CGPoint point;
//	CGPoint center;
//	float angle;
//	float radius = 2500.0f;
//	NSUInteger pointCount = self.polyline.pointCount;	// for performance
//
//	center = [self pointForMapPoint:self.polyline.points[pointCount/2]];
//	MKMapPoint pointGlobal;
//	NSValue *pptGlobal;
//
//	if (self.polyline.finalPath == nil)
//		self.polyline.finalPath = [[NSMutableArray alloc]init];	// 0 objects
//	else
//		[self.polyline.finalPath removeAllObjects];
//
//	NSLog(@"center(x,y) = (%f, %f), and radius = %f", center.x, center.y, radius);
//	for (angle = 0; angle < 6.28318530717959f * 1.0f; angle += (6.28318530717959/50.0))
//	{
//		point.x = center.x + (sinf(angle) * radius);
//		point.y = center.y + (cosf(angle) * radius);
//
//		pointGlobal = [self mapPointForPoint:point];
//		pptGlobal = [NSValue value:&pointGlobal withObjCType:@encode(MKMapPoint)];
//		[self.polyline.finalPath addObject:pptGlobal];
//		pptGlobal = nil;
//
//        if (pathIsEmpty)
//        {
//            CGPathMoveToPoint(pathRef, NULL, point.x, point.y);
//            pathIsEmpty = NO;
//        }
//        else
//        {
//            CGPathAddLineToPoint(pathRef, NULL, point.x, point.y);
//        }
//	}
//    CGPathCloseSubpath(pathRef);
//
//	self.path = pathRef;
}

// - (MKMapRect)overlayBoundingMapRect
// {
//    MKMapPoint topLeft = MKMapPointForCoordinate(self.overlayTopLeftCoordinate);
//    MKMapPoint topRight = MKMapPointForCoordinate(self.overlayTopRightCoordinate);
//    MKMapPoint bottomLeft = MKMapPointForCoordinate(self.overlayBottomLeftCoordinate);
//
//    return MKMapRectMake(topLeft.x,
//                  topLeft.y,
//                  fabs(topLeft.x - topRight.x),
//                  fabs(topLeft.y - bottomLeft.y));
// }

#pragma mark - Private helpers

- (void)drawLine:(CGColorRef)color width:(CGFloat)width allowDashes:(BOOL)allowDashes forZoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
	//LOG_FUNCTION;
	//	CGFloat whiteToRed [] = {
	//        1.0, 1.0, 1.0, 1.0, // 白色
	//        1.0, 0.0, 0.0, 1.0	// 红色
	//    };
	//	CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();	// 我们要使用RGB颜色空间
	// 在RGB颜色空间内建立一个间层色，有两个颜色在阵列里面，分别是白色到蓝色
	//	CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, whiteToRed, NULL, 2);
	//	CGContextSaveGState(context);
    CGContextAddPath(context, self.path);	// call createPath internal
	//	CGContextClip(context);
	//	CGContextEOClip(context);
	//	CGPoint startPoint = CGPointMake(self.path);
	//	CGPoint endPoint = CGPointMake();
	//	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	//	CGContextRestoreGState(context);

	// use the defaults which takes care of the dash pattern
	// and other things
    if (allowDashes)
    {
        [self applyStrokePropertiesToContext:context atZoomScale:zoomScale];
    }
    else
    {
		// some setting we still want to apply
        CGContextSetLineCap(context, self.lineCap);
        CGContextSetLineJoin(context, self.lineJoin);
        CGContextSetMiterLimit(context, self.miterLimit);
    }

	// now set the color and width
    CGContextSetStrokeColorWithColor(context, color);
    CGFloat roadWidth = MKRoadWidthAtZoomScale(zoomScale) * 0.75;
//  CGContextSetLineWidth(context, width / zoomScale);
    CGContextSetLineWidth(context, roadWidth * width);
//NSLog(@"width = %f, zoomScale = %f, width/zoomScale = %f, MKRoadWidthAtZoomScale(zoomScale) = %f", width, zoomScale, width/zoomScale, roadWidth);
    CGContextStrokePath(context);
}

@end
