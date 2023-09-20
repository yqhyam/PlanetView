//
//  KHPlanetAvatarView.m
//  planetView
//
//  Created by YAM on 2022/4/22.
//

#import "KHPlanetAvatarView.h"

@interface KHPlanetAvatarView()


@end

@implementation KHPlanetAvatarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
//    self.layer.cornerRadius = 36;
//    self.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.layer.borderWidth = 2;
//    self.layer.masksToBounds = true;

    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,72,72);
    gl.startPoint = CGPointMake(0.5, 0);
    gl.endPoint = CGPointMake(0.5, 1);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:175/255.0 green:224/255.0 blue:255/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:255/255.0 green:225/255.0 blue:225/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0), @(1.0f)];
    [self.layer addSublayer:gl];
    
    gl.cornerRadius = 36;
    gl.borderColor = [UIColor whiteColor].CGColor;
    gl.borderWidth = 2;
    
}

@end
