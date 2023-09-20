//
//  KHPlanetTrackLayer.h
//  planetView
//
//  Created by YAM on 2022/4/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KHPlanetTrackLayer : CAShapeLayer
/** points */
@property (nonatomic, copy) NSArray<NSValue *> * pointArray;
/// 解析path成坐标
- (void)parsePathToPoints;
@end

NS_ASSUME_NONNULL_END
