#import <UIKit/UIKit.h>

@interface UIBezierPath (forEachElement)

- (void)forEachElement:(void (^)(CGPathElement const *element))block;

@end
