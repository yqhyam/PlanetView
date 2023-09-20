//
//  KHPlanetTagPlaceholderView.m
//  planetView
//
//  Created by YAM on 2022/4/22.
//

#import "KHPlanetTagPlaceholderView.h"

@interface KHPlanetTagPlaceholderView()


@end

@implementation KHPlanetTagPlaceholderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,10,10);
    gl.startPoint = CGPointMake(1, 0.5);
    gl.endPoint = CGPointMake(0, 0.5);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:219/255.0 green:223/255.0 blue:254/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:181/255.0 green:224/255.0 blue:252/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0), @(1.0f)];
    [self.layer addSublayer:gl];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = true;
}

@end
