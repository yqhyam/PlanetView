//
//  KHPlanetTagBaseView.h
//  planetView
//
//  Created by YAM on 2022/4/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KHPlanetTagBaseView : UIView
/** points */
@property (nonatomic, copy) NSArray<NSValue *> * pointArray;
/** 属于哪条轨迹 */
@property (nonatomic, assign) NSInteger trackNumber;
/** 最大数 */
@property (nonatomic, assign) NSInteger pointsCount;
/** 当前索引 */
@property (nonatomic, assign) NSInteger currentIndex;
/** 序号 */
@property (nonatomic, assign) NSInteger index;
@end

NS_ASSUME_NONNULL_END
