//
//  KHPlanetTagModel.m
//  planetView
//
//  Created by YAM on 2022/4/22.
//

#import "KHPlanetTagModel.h"

@implementation KHPlanetTagModel

- (CGSize)tagSize {
    switch (_sizeStyle) {
        case KHPlanetTagModelSizeStyleSmall:
            return CGSizeMake(18, 18);
            break;
        case KHPlanetTagModelSizeStyleBig:
            return CGSizeMake(36, 36);
            break;
        default:
            return CGSizeMake(24, 24);
            break;
    }
}

@end
