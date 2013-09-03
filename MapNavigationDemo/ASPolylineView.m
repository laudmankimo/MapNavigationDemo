//
//  ASPolylineView.m
//
//  Created by Adrian Schoenig on 21/02/13.
//
//

#import "ASPolylineView.h"

@interface ASPolylineView ()

//@property (nonatomic, strong) MKPolyline *polyline;
@property (nonatomic, strong) ASPolyline *polyline;
//@property (nonatomic, retain) UIColor *backgroundColor;

@end

@implementation ASPolylineView

- (id)initWithPolyline:(MKPolyline *)polyline
{
    self = [super initWithOverlay:polyline];

    if (self)
    {
        self.polyline = (ASPolyline *)polyline;
        // defaults
        self.borderColor = [UIColor blackColor];
        self.backgroundColor = [UIColor whiteColor];
        self.borderMultiplier = 2.0;
    }

    return self;
}

- (void)drawMapRect :(MKMapRect)mapRect
        zoomScale   :(MKZoomScale)zoomScale
        inContext   :(CGContextRef)context
{
    CGFloat baseWidth = self.lineWidth;

    // draw the border. it's slightly wider than the specified line width.
    [self drawLine:self.borderColor.CGColor
    width       :baseWidth * self.borderMultiplier
    allowDashes :NO
    forZoomScale:zoomScale
    inContext   :context];

    // a white background.
    [self drawLine:self.backgroundColor.CGColor
    width       :baseWidth
    allowDashes :NO
    forZoomScale:zoomScale
    inContext   :context];

    // draw the actual line.
    [self drawLine:self.strokeColor.CGColor
    width       :baseWidth
    allowDashes :YES
    forZoomScale:zoomScale
    inContext   :context];

//	CGImageRef imageReference = self.overlayImage.CGImage;
#ifdef DEBUGXXX
    MKMapRect theMapRect = self.overlay.boundingMapRect;
    CGRect theRect = [self rectForMapRect:theMapRect];
    CGContextSetRGBFillColor (context, 0, 0, 1, .1);//blue
    CGContextFillRect (context, theRect);
#endif
//    CGContextSetRGBFillColor (context, 0, 0, 1, .5);
//    CGContextFillRect (context, theRect);

    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
}

- (void)createPath
{
    // turn the polyline into a path
    CGMutablePathRef    newPath = CGPathCreateMutable();
    BOOL                pathIsEmpty = YES;
	NSUInteger			pointCount = self.polyline.pointCount;	// for performance
	CGPoint				center;
	CGPoint				point;
	CGPoint				nextPoint;
	CGPoint				vector;
	float				angle;
#define RADIUS 10.0f
	MKMapPoint pointGlobal;
	NSValue *pptGlobal;

	if (self.polyline.finalPath == nil)
		self.polyline.finalPath = [[NSMutableArray alloc]init];	// 0 objects
	else
		[self.polyline.finalPath removeAllObjects];

	// forward
	for (NSUInteger idx = 0; idx < pointCount; idx++)
    {
		center = [self pointForMapPoint:self.polyline.points[idx]];
		if (idx == (pointCount-1))	// last point
		{
			pointGlobal = [self mapPointForPoint:center];
			pptGlobal = [NSValue value:&pointGlobal withObjCType:@encode(MKMapPoint)];
			[self.polyline.finalPath addObject:pptGlobal];
			pptGlobal = nil;
			
			CGPathAddLineToPoint(newPath, nil, center.x, center.y);
			break;
		}
		nextPoint = [self pointForMapPoint:self.polyline.points[idx+1]];
		vector = CGPointMake(nextPoint.x - center.x, nextPoint.y - center.y);
		angle = atan2f(vector.y, vector.x);

		point.x = center.x + (sinf(angle) * RADIUS);
		point.y = center.y + (cosf(angle) * RADIUS);
		
		pointGlobal = [self mapPointForPoint:point];
		pptGlobal = [NSValue value:&pointGlobal withObjCType:@encode(MKMapPoint)];
		[self.polyline.finalPath addObject:pptGlobal];
		pptGlobal = nil;
		
        if (pathIsEmpty)
        {
            CGPathMoveToPoint(newPath, nil, center.x, center.y);
            pathIsEmpty = NO;
        }
        else
        {
            CGPathAddLineToPoint(newPath, nil, point.x, point.y);
        }
    }
	// backward
	for (NSInteger idx = (pointCount-2); idx >= 0; idx--)
    {
		center = [self pointForMapPoint:self.polyline.points[idx]];
		if (idx == 0)	// last point
		{
			pointGlobal = [self mapPointForPoint:center];
			pptGlobal = [NSValue value:&pointGlobal withObjCType:@encode(MKMapPoint)];
			[self.polyline.finalPath addObject:pptGlobal];
			pptGlobal = nil;
			CGPathAddLineToPoint(newPath, nil, center.x, center.y);
			break;
		}
		nextPoint = [self pointForMapPoint:self.polyline.points[idx-1]];
		vector = CGPointMake(nextPoint.x - center.x, nextPoint.y - center.y);
		angle = atan2f(vector.y, vector.x);

		point.x = center.x + (sinf(angle) * RADIUS);
		point.y = center.y + (cosf(angle) * RADIUS);

		pointGlobal = [self mapPointForPoint:point];
		pptGlobal = [NSValue value:&pointGlobal withObjCType:@encode(MKMapPoint)];
		[self.polyline.finalPath addObject:pptGlobal];
		pptGlobal = nil;

		CGPathAddLineToPoint(newPath, nil, point.x, point.y);
    }
	CGPathCloseSubpath(newPath);
    self.path = newPath;
    CGPathRelease(newPath);

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
//            CGPathMoveToPoint(pathRef, nil, point.x, point.y);
//            pathIsEmpty = NO;
//        }
//        else
//        {
//            CGPathAddLineToPoint(pathRef, nil, point.x, point.y);
//        }
//	}
//    CGPathCloseSubpath(pathRef);
//	
//	self.path = pathRef;
}

//- (MKMapRect)overlayBoundingMapRect
//{ 
//    MKMapPoint topLeft = MKMapPointForCoordinate(self.overlayTopLeftCoordinate);
//    MKMapPoint topRight = MKMapPointForCoordinate(self.overlayTopRightCoordinate);
//    MKMapPoint bottomLeft = MKMapPointForCoordinate(self.overlayBottomLeftCoordinate);
// 
//    return MKMapRectMake(topLeft.x,
//                  topLeft.y,
//                  fabs(topLeft.x - topRight.x),
//                  fabs(topLeft.y - bottomLeft.y));
//}

#pragma mark - Private helpers

- (void)drawLine    :(CGColorRef)color
        width       :(CGFloat)width
        allowDashes :(BOOL)allowDashes
        forZoomScale:(MKZoomScale)zoomScale
        inContext   :(CGContextRef)context
{
//	CGFloat whiteToRed [] = {
//        1.0, 1.0, 1.0, 1.0, // 白色
//        1.0, 0.0, 0.0, 1.0	// 红色
//    };
//	CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();	// 我们要使用RGB颜色空间
	// 在RGB颜色空间内建立一个间层色，有两个颜色在阵列里面，分别是白色到蓝色
//	CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, whiteToRed, NULL, 2);
//	CGContextSaveGState(context);
    CGContextAddPath(context, self.path);
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

    // now set the colour and width
    CGContextSetStrokeColorWithColor(context, color);
//    CGContextSetLineWidth(context, width / zoomScale);
	CGContextSetLineWidth(context, MKRoadWidthAtZoomScale(zoomScale));
    CGContextStrokePath(context);
}

@end
