//
//  KHPlanetRenderView.h
//  planetView
//
//  Created by YAM on 2022/4/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class KHPlanetTagView, KHPlanetTagModel;
@interface KHPlanetRenderView : UIView

/** tagArray 按顺序填充 */
@property (nonatomic, copy) NSArray<KHPlanetTagModel *> * tagArray;
/** tagModels 按轨道填充 */
@property (nonatomic, copy) NSDictionary<NSNumber *, NSArray<KHPlanetTagModel *> *> * tagModels;
@end

NS_ASSUME_NONNULL_END
