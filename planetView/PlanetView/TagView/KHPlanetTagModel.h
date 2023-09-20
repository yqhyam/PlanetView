//
//  KHPlanetTagModel.h
//  planetView
//
//  Created by YAM on 2022/4/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, KHPlanetTagModelSizeStyle) {
    KHPlanetTagModelSizeStyleSmall,
    KHPlanetTagModelSizeStyleMid,
    KHPlanetTagModelSizeStyleBig,
};

@interface KHPlanetTagModel : NSObject
/** size类型 */
@property (nonatomic, assign) KHPlanetTagModelSizeStyle sizeStyle;
/** size */
@property (nonatomic, assign) CGSize tagSize;
/** index */
@property (nonatomic, assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END
