//
//  KHPlanetTagView.m
//  planetView
//
//  Created by YAM on 2022/4/12.
//

#import "KHPlanetTagView.h"

@interface KHPlanetTagView()

/**  */
@property (nonatomic, strong) UILabel * label;
/** 用户昵称 */
@property (nonatomic, strong) UILabel * nameLabel;
/** 气泡 */
@property (nonatomic, strong) UIView * bubbleView;
@end

@implementation KHPlanetTagView

- (void)setIsShowBubble:(BOOL)isShowBubble {
    _isShowBubble = isShowBubble;
    if (isShowBubble && self.bubbleView.hidden) {
        [self showBubbleAnimation];
    } else if (!isShowBubble && !self.bubbleView.hidden) {
        [self hideBubbleAnimation];
    }
}

- (void)showBubbleAnimation {
    CGAffineTransform transform = _bubbleView.transform;
    _bubbleView.transform = CGAffineTransformScale(transform, 0.1, 0.1);
    _bubbleView.hidden = false;
    [UIView animateWithDuration:0.3 animations:^{
        self.bubbleView.transform = CGAffineTransformScale(transform, 1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.bubbleView.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)hideBubbleAnimation {
    CGAffineTransform transform = _bubbleView.transform;
    [UIView animateWithDuration:0.3 animations:^{
        self.bubbleView.transform = CGAffineTransformScale(transform, 1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.bubbleView.transform = CGAffineTransformScale(transform, 0.1, 0.1);
        } completion:^(BOOL finished) {
            self.bubbleView.hidden = true;
        }];
    }];
}


- (void)setIndex:(NSInteger)index {
    _label.text = [NSString stringWithFormat:@"%ld", index];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _label.frame = self.bounds;
    _nameLabel.frame = CGRectMake(0, self.bounds.size.height + 5, 40, 13);
    _nameLabel.center = CGPointMake(self.bounds.size.width/2.0, _nameLabel.center.y);
    self.layer.cornerRadius = self.bounds.size.width/2.0;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:175/255.0 green:220/255.0 blue:250/255.0 alpha:1];
        
        _label = [UILabel new];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        
        _nameLabel = [UILabel new];
        _nameLabel.text = @"用户昵称";
        _nameLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        _nameLabel.font = [UIFont boldSystemFontOfSize:9];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.frame = CGRectMake(0, 0, 36, 13);
        [self addSubview:_nameLabel];
        
        _bubbleView = [UIView new];
//        _bubbleView.backgroundColor = [UIColor whiteColor];
//        _bubbleView.layer.cornerRadius = 10;
        _bubbleView.frame = CGRectMake(3, -37, 54, 27);
        _bubbleView.layer.contents = (id)[UIImage imageNamed:@"bubble"].CGImage;
        _bubbleView.hidden = true;
        [self addSubview:_bubbleView];
    }
    return self;
}

@end
