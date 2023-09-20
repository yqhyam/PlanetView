//
//  KHPlanetTrackLayer.m
//  planetView
//
//  Created by YAM on 2022/4/12.
//

#import "KHPlanetTrackLayer.h"
#import "UIBezierPath+forEachElement.h"

@implementation KHPlanetTrackLayer

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.lineWidth = 1;
    self.fillColor = nil;
    self.strokeColor = [UIColor whiteColor].CGColor;
}

- (void)parsePathToPoints {
    if (!self.path) {
        return;
    }
    CGPathRef cgDashedPath = CGPathCreateCopyByDashingPath(self.path, NULL, 0, (CGFloat[]){ 1.0f, 1.0f }, 2);
    UIBezierPath *dashedPath = [UIBezierPath bezierPathWithCGPath:cgDashedPath];
    CGPathRelease(cgDashedPath);

    static CGFloat const kMinimumDistance = 0.1f;
    __block CGPoint priorPoint = { HUGE_VALF, HUGE_VALF };

    NSMutableData *pathPointsData = [[NSMutableData alloc] init];
    NSMutableArray *array = [NSMutableArray array];
    [dashedPath forEachElement:^(const CGPathElement *element) {
        CGPoint *p = lastPointOfPathElement(element);
        if (!p)
            return;
        if (hypotf(p->x - priorPoint.x, p->y - priorPoint.y) < kMinimumDistance)
            return;
        [pathPointsData appendBytes:p length:sizeof *p];
        priorPoint = *p;
        [array addObject:[NSValue valueWithCGPoint:priorPoint]];
    }];
    self.pointArray = array.copy;
}

static CGPoint *lastPointOfPathElement(CGPathElement const *element) {
    NSInteger index;
    switch (element->type) {
        case kCGPathElementMoveToPoint: index = 0; break;
        case kCGPathElementAddCurveToPoint: index = 2; break;
        case kCGPathElementAddLineToPoint: index = 0; break;
        case kCGPathElementAddQuadCurveToPoint: index = 1; break;
        case kCGPathElementCloseSubpath: index = NSNotFound; break;
    }
    return index == NSNotFound ? 0 : &element->points[index];
}

@end
