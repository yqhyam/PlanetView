//
//  KHPlanetRenderView.m
//  planetView
//
//  Created by YAM on 2022/4/12.
//

#import "KHPlanetRenderView.h"
#import "KHPlanetTrackLayer.h"
#import "KHPlanetTagView.h"
#import "KHPlanetTagPlaceholderView.h"
#import "KHPlanetAvatarView.h"
#import "KHPlanetTagModel.h"
#define RADIAN_TO_DEGREE(__ANGLE__) ((__ANGLE__) * 180/M_PI)

/** 轨道宽 */
static NSArray<NSNumber *> * const kTraceWidthArray = @[@(250), @(400), @(500), @(600)];
/** 每条轨道最多数量 */
static NSArray<NSNumber *> * const kTraceMaxCountArray = @[@(4), @(6), @(10)];

/** 轨道数量 */
static NSInteger const kTraceNumber = 4;
/** 轨道x轴 */
static CGFloat const kTraceX = 1;
/** 轨道y轴 */
static CGFloat const kTraceY = -0.4;
/** 轨道xy轴偏移量 */
static CGFloat const kTraceXYSpeed = 0.01;

@interface KHPlanetRenderView()
/** 滑动方向 */
@property (nonatomic, assign) BOOL isClockwise;

/** timer */
//@property (nonatomic, strong) CADisplayLink * timer;
@property (nonatomic, strong) NSTimer * timer;
/** timer 是否暂停 */
@property (nonatomic, assign) BOOL isPause;
/** 惯性 timer */
@property (nonatomic, strong) CADisplayLink * inertiaTimer;
/** 中间头像 */
@property (nonatomic, strong) KHPlanetAvatarView * avatarView;
/** 中间头像轨道 */
@property (nonatomic, strong) CAShapeLayer * midTraceLayer;
/** 轨道背景 */
@property (nonatomic, strong) UIView * traceBGView;

/** 多条轨道，从大到小 */
@property (nonatomic, strong) NSMutableArray<KHPlanetTrackLayer *> * trackLayers;
/** 所有tag */
@property (nonatomic, strong) NSMutableArray<KHPlanetTagBaseView *> * tagViews;

/// numbers
/** 上一个点相对于x轴角度 */
@property (nonatomic, assign) CGFloat lastPointAngle;
/** 角度 */
@property (nonatomic, assign) CGFloat angle;
/** 惯性 */
@property (nonatomic, assign) CGFloat velocity;
/** 需要刷新次数 */
@property (nonatomic, assign) NSInteger updateCount;
/** 当前刷新次数 */
@property (nonatomic, assign) NSInteger currentCount;
@end

@implementation KHPlanetRenderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
    
    [_inertiaTimer invalidate];
    _inertiaTimer = nil;
}

- (void)setup {
    /// ...
    self.angle = 1.2;

    self.tagViews = [NSMutableArray array];
    self.trackLayers = [NSMutableArray array];

    // 初始化timer
//    _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoRotate)];
//    [_timer addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.f/26.f target:self selector:@selector(autoRotate) userInfo:nil repeats:true];
    [self stopTimer];
    
    _inertiaTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(inertiaStep)];
    [_inertiaTimer addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
    
    /// 添加3d手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    [self addGestureRecognizer:pan];
    
    _traceBGView = [UIView new];
    _traceBGView.frame = self.bounds;
    [self addSubview:_traceBGView];
    
    _avatarView = [KHPlanetAvatarView new];
    _avatarView.bounds = CGRectMake(0, 0, 72, 72);
    _avatarView.center = CGPointMake(self.traceBGView.bounds.size.width/2.0, self.traceBGView.bounds.size.height/2.0);
    _avatarView.layer.zPosition = 150;
    [self addSubview:_avatarView];
    
    for (NSInteger i = 0; i < kTraceNumber; i++) {
        CGFloat w = kTraceWidthArray[i].floatValue;
        CGFloat left = (self.bounds.size.width - w)/2.0;
        CGFloat top = (_traceBGView.bounds.size.height - w)/2.0;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(left, top, w, w) cornerRadius:w/2.0];
        [path stroke];
        KHPlanetTrackLayer *trackLayer = [KHPlanetTrackLayer layer];
        trackLayer.path = path.CGPath;
        trackLayer.frame = self.bounds;
        trackLayer.zPosition = kTraceNumber - i;
        [trackLayer parsePathToPoints];
        
        CAGradientLayer *gradient;
        switch (i) {
            case 0:
            {
                trackLayer.lineWidth = 2;
                
                gradient = [CAGradientLayer layer];
                gradient.frame = trackLayer.bounds;
                gradient.colors = @[(__bridge id)[UIColor colorWithRed:66/255.0 green:232/255.0 blue:255/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:179/255.0 green:246/255.0 blue:255/255.0 alpha:0.25].CGColor];
                gradient.startPoint = CGPointMake(0.22, 0.05);
                gradient.endPoint = CGPointMake(0.65, 0.9);
                CAShapeLayer*layer = [CAShapeLayer layer];
                layer.path = path.CGPath;
                gradient.mask = layer;
                [self.traceBGView.layer addSublayer:gradient];
            }
                break;
            case 1:
            {
                trackLayer.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:0.29].CGColor;
            }
                break;
            case 2:
            {
                trackLayer.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:0.29].CGColor;
            }
                break;
            default:
                break;
        }
        [self.traceBGView.layer addSublayer:trackLayer];
        [self.trackLayers addObject:trackLayer];
    }
    
    CGFloat avatarCircleW = 102;
    CGRect rect = CGRectMake(-10, 0, avatarCircleW, avatarCircleW);
    UIBezierPath *avatarPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    KHPlanetTrackLayer *trackLayer = [KHPlanetTrackLayer layer];
    trackLayer.path = avatarPath.CGPath;
    trackLayer.frame = _avatarView.bounds;
    trackLayer.strokeColor = [UIColor whiteColor].CGColor;
    trackLayer.zPosition = 0;
    trackLayer.lineWidth = 3;
    [self.avatarView.layer addSublayer:trackLayer];
    _midTraceLayer = trackLayer;
    
    CATransform3D perspectiveTransform = CATransform3DIdentity;
    perspectiveTransform.m34 = -1.f/700;
    trackLayer.transform = CATransform3DRotate(perspectiveTransform, self.angle, kTraceX, kTraceY, 0);
}

- (void)setTagArray:(NSArray<KHPlanetTagModel *> *)tagArray {
    _tagArray = tagArray;
    
    for (KHPlanetTagBaseView *view in self.tagViews) {
        [view removeFromSuperview];
    }
    [self.tagViews removeAllObjects];
    
    // 去掉最外轨道
    NSInteger round1 = 4;
    NSInteger round2 = 10;
    NSInteger idx = 0;

    for (NSInteger trackIndex = 0; trackIndex < kTraceNumber - 1; trackIndex++) {
        
        NSInteger maxCount = kTraceMaxCountArray[trackIndex].integerValue;
        NSArray<NSValue *> *points = _trackLayers[trackIndex].pointArray;
        // 均分
        NSInteger dived = points.count/maxCount;
        for (NSInteger i = 0; i < maxCount; i++) {
            switch (trackIndex) {
                case 0:
                {
                    NSInteger pIndex = dived/2;
                    KHPlanetTagPlaceholderView *pView = [self getPlaceholderViewByPIndex:pIndex trackIndex:trackIndex points:points index:i];
                    [self addSubview:pView];
                    [self.tagViews addObject:pView];
                }
                    break;
                case 1:
                {
                    // 1-2
                    if (i == 1) {
                        NSInteger pIndex = dived * i + dived/3;
                        KHPlanetTagPlaceholderView *pView = [self getPlaceholderViewByPIndex:pIndex trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView];
                        [self.tagViews addObject:pView];
                        
                        NSInteger pIndex1 = dived * i + dived/3 * 2;
                        KHPlanetTagPlaceholderView *pView1 = [self getPlaceholderViewByPIndex:pIndex1 trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView1];
                        [self.tagViews addObject:pView1];
                    }
                    else if (i == 3) {
                        NSInteger pIndex = dived * i + points.count/(maxCount*2);
                        KHPlanetTagPlaceholderView *pView = [self getPlaceholderViewByPIndex:pIndex trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView];
                        [self.tagViews addObject:pView];
                    }
                    
                }
                    break;
                case 2:
                {
                    if (i == 0) {
                        NSInteger pIndex = dived/2;
                        KHPlanetTagPlaceholderView *pView = [self getPlaceholderViewByPIndex:pIndex trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView];
                        [self.tagViews addObject:pView];
                    }
                    else if (i == 4) {
                        NSInteger pIndex = dived * i + dived/3;
                        KHPlanetTagPlaceholderView *pView = [self getPlaceholderViewByPIndex:pIndex trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView];
                        [self.tagViews addObject:pView];
                        
                        NSInteger pIndex1 = dived * i + dived/3 * 2;
                        KHPlanetTagPlaceholderView *pView1 = [self getPlaceholderViewByPIndex:pIndex1 trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView1];
                        [self.tagViews addObject:pView1];
                    }
                    else if (i == 6) {
                        NSInteger pIndex = dived * i + dived/2;
                        KHPlanetTagPlaceholderView *pView = [self getPlaceholderViewByPIndex:pIndex trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView];
                        [self.tagViews addObject:pView];
                    }
                    else if (i == 8) {
                        NSInteger pIndex = dived * i + dived/2;
                        KHPlanetTagPlaceholderView *pView = [self getPlaceholderViewByPIndex:pIndex trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView];
                        [self.tagViews addObject:pView];
                    }
                }
                    break;
                default:
                    break;
            }
            
            KHPlanetTagBaseView *v;
//            if ((trackIndex == 0 && i < tagArray.count) || (trackIndex == 1 && i + round1 < tagArray.count) || (trackIndex == 2 && i + round2 < tagArray.count)) {
            if (idx < tagArray.count) {
                KHPlanetTagModel *model = [tagArray objectAtIndex:idx];
                v = [KHPlanetTagView new];
                v.bounds = CGRectMake(0, 0, model.tagSize.width, model.tagSize.height);
                v.center = [self convertPoint:CGPointMake(self.traceBGView.bounds.size.width/2.0, self.traceBGView.bounds.size.height/2.0) fromView:_traceBGView];
                v.trackNumber = trackIndex;
                v.pointArray = points;
                v.pointsCount = points.count;
                v.index = model.index;
                v.layer.zPosition = (kTraceNumber - trackIndex) + 230;
                v.currentIndex = dived * i;
                NSLog(@"idx = %ld", idx);
            } else {
                v = [KHPlanetTagPlaceholderView new];
                v.bounds = CGRectMake(0, 0, 20, 20);
                v.center = [self convertPoint:CGPointMake(self.traceBGView.bounds.size.width/2.0, self.traceBGView.bounds.size.height/2.0) fromView:_traceBGView];
                v.trackNumber = trackIndex;
                v.pointArray = points;
                v.pointsCount = points.count;
                v.index = i;
                v.layer.zPosition = (kTraceNumber - trackIndex) + 230;
                v.currentIndex = dived * i;
            }
            [self addSubview:v];
            [self.tagViews addObject:v];
            idx ++;
        }
    }
    
    CATransform3D perspectiveTransform = CATransform3DIdentity;
    perspectiveTransform.m34 = -1.f/700;
    perspectiveTransform = CATransform3DScale(perspectiveTransform, 0.5, 0.5, 1);
    perspectiveTransform = CATransform3DRotate(perspectiveTransform, self.angle, kTraceX, kTraceY, 0);
    self.traceBGView.layer.transform = perspectiveTransform;
    for (KHPlanetTagView *obj in self.tagViews) {
        obj.alpha = 0;
    }
    [UIView animateWithDuration:0.8 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
//        self.traceBGView.layer.transform = CATransform3DScale(perspectiveTransform, 2, 2, 1);

        CATransform3D perspectiveTransform = CATransform3DIdentity;
        perspectiveTransform.m34 = -1.f/700;
        self.traceBGView.layer.transform = CATransform3DRotate(perspectiveTransform, self.angle, kTraceX, kTraceY, 0);
        for (KHPlanetTagView *obj in self.tagViews) {
            obj.alpha = 1;
            obj.center = [self convertPoint:obj.pointArray[obj.currentIndex].CGPointValue fromView:self.traceBGView];
        }
    } completion:nil];
    
    [self startTimer];
}

- (void)setTagModels:(NSDictionary<NSNumber *,NSArray<KHPlanetTagModel *> *> *)tagModels {
    _tagModels = tagModels;

    for (KHPlanetTagBaseView *view in self.tagViews) {
        [view removeFromSuperview];
    }
    [self.tagViews removeAllObjects];
    
    [tagModels enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSArray<KHPlanetTagModel *> * _Nonnull obj, BOOL * _Nonnull stop) {
        NSInteger trackIndex = key.integerValue;
        NSInteger maxCount = kTraceMaxCountArray[trackIndex].integerValue;
        NSArray<NSValue *> *points = _trackLayers[trackIndex].pointArray;
        // 均分
        NSInteger dived = points.count/maxCount;
        
        for (NSInteger i = 0; i < maxCount; i++) {
            switch (trackIndex) {
                case 0:
                {
                    NSInteger pIndex = dived/2;
                    KHPlanetTagPlaceholderView *pView = [self getPlaceholderViewByPIndex:pIndex trackIndex:trackIndex points:points index:i];
                    [self addSubview:pView];
                    [self.tagViews addObject:pView];
                }
                    break;
                case 1:
                {
                    // 1-2
                    if (i == 1) {
                        NSInteger pIndex = dived * i + dived/3;
                        KHPlanetTagPlaceholderView *pView = [self getPlaceholderViewByPIndex:pIndex trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView];
                        [self.tagViews addObject:pView];
                        
                        NSInteger pIndex1 = dived * i + dived/3 * 2;
                        KHPlanetTagPlaceholderView *pView1 = [self getPlaceholderViewByPIndex:pIndex1 trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView1];
                        [self.tagViews addObject:pView1];
                    }
                    else if (i == 3) {
                        NSInteger pIndex = dived * i + points.count/(maxCount*2);
                        KHPlanetTagPlaceholderView *pView = [self getPlaceholderViewByPIndex:pIndex trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView];
                        [self.tagViews addObject:pView];
                    }
                    
                }
                    break;
                case 2:
                {
                    if (i == 0) {
                        NSInteger pIndex = dived/2;
                        KHPlanetTagPlaceholderView *pView = [self getPlaceholderViewByPIndex:pIndex trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView];
                        [self.tagViews addObject:pView];
                    }
                    else if (i == 4) {
                        NSInteger pIndex = dived * i + dived/3;
                        KHPlanetTagPlaceholderView *pView = [self getPlaceholderViewByPIndex:pIndex trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView];
                        [self.tagViews addObject:pView];
                        
                        NSInteger pIndex1 = dived * i + dived/3 * 2;
                        KHPlanetTagPlaceholderView *pView1 = [self getPlaceholderViewByPIndex:pIndex1 trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView1];
                        [self.tagViews addObject:pView1];
                    }
                    else if (i == 6) {
                        NSInteger pIndex = dived * i + dived/2;
                        KHPlanetTagPlaceholderView *pView = [self getPlaceholderViewByPIndex:pIndex trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView];
                        [self.tagViews addObject:pView];
                    }
                    else if (i == 8) {
                        NSInteger pIndex = dived * i + dived/2;
                        KHPlanetTagPlaceholderView *pView = [self getPlaceholderViewByPIndex:pIndex trackIndex:trackIndex points:points index:i];
                        [self addSubview:pView];
                        [self.tagViews addObject:pView];
                    }
                }
                    break;
                default:
                    break;
            }
            
            KHPlanetTagBaseView *v;
            if (i < obj.count) {
                KHPlanetTagModel *model = [obj objectAtIndex:i];
                v = [KHPlanetTagView new];
                v.bounds = CGRectMake(0, 0, model.tagSize.width, model.tagSize.height);
                v.center = [self convertPoint:CGPointMake(self.traceBGView.bounds.size.width/2.0, self.traceBGView.bounds.size.height/2.0) fromView:_traceBGView];
                v.trackNumber = trackIndex;
                v.pointArray = points;
                v.pointsCount = points.count;
                v.index = i;
                v.layer.zPosition = (kTraceNumber - trackIndex) + 230;
                v.currentIndex = dived * i;
                
            } else {
                v = [KHPlanetTagPlaceholderView new];
                v.bounds = CGRectMake(0, 0, 20, 20);
                v.center = [self convertPoint:CGPointMake(self.traceBGView.bounds.size.width/2.0, self.traceBGView.bounds.size.height/2.0) fromView:_traceBGView];
                v.trackNumber = trackIndex;
                v.pointArray = points;
                v.pointsCount = points.count;
                v.index = i;
                v.layer.zPosition = (kTraceNumber - trackIndex) + 230;
                v.currentIndex = dived * i;
            }
            [self addSubview:v];
            [self.tagViews addObject:v];
        }
    }];
    
//    self.traceBGView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    CATransform3D perspectiveTransform = CATransform3DIdentity;
    perspectiveTransform.m34 = -1.f/700;
    perspectiveTransform = CATransform3DScale(perspectiveTransform, 0.5, 0.5, 0);
    perspectiveTransform = CATransform3DRotate(perspectiveTransform, self.angle, kTraceX, kTraceY, 0);
    self.traceBGView.layer.transform = perspectiveTransform;
    
    
    [UIView animateWithDuration:0.8 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
//        CATransform3D perspectiveTransform = CATransform3DIdentity;
//        perspectiveTransform.m34 = -1.f/700;
//        self.traceBGView.layer.transform = CATransform3DRotate(perspectiveTransform, self.angle, kTraceX, kTraceY, 0);
        for (KHPlanetTagView *obj in self.tagViews) {
            obj.center = [self convertPoint:obj.pointArray[obj.currentIndex].CGPointValue fromView:self.traceBGView];
        }
    } completion:nil];
    
    [self startTimer];
}

- (KHPlanetTagPlaceholderView *)getPlaceholderViewByPIndex:(NSInteger)pIndex trackIndex:(NSInteger)trackIndex points:(NSArray *)points index:(NSInteger)i {
    KHPlanetTagPlaceholderView *pView = [KHPlanetTagPlaceholderView new];
    pView.bounds = CGRectMake(0, 0, 10, 10);
    pView.center = [self convertPoint:CGPointMake(self.traceBGView.bounds.size.width/2.0, self.traceBGView.bounds.size.height/2.0) fromView:_traceBGView];
    pView.trackNumber = trackIndex;
    pView.pointArray = points;
    pView.pointsCount = points.count;
    pView.index = i;
    pView.currentIndex = pIndex;
    return pView;
}

- (void)startTimer {
//    _timer.paused = false;
    _isPause = false;
    [_timer setFireDate:[NSDate date]];
}

- (void)stopTimer {
//    _timer.paused = true;
    _isPause = true;
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)inertiaStart {
    [self stopTimer];
    _inertiaTimer.paused = NO;
}

- (void)inertiaStop {
    [self startTimer];
    _inertiaTimer.paused = YES;
}

- (void)inertiaStep {
    _currentCount++;
    NSInteger speed = _velocity/30.0/_currentCount;
    if (_currentCount > _updateCount || _currentCount > 60 || speed == 0) {
        [self inertiaStop];
    }else{
        [self rotateWithSpeed:speed andIsClockwise:self.isClockwise];
    }
}

- (void)autoRotate {
    [self rotateWithSpeed:1 andIsClockwise:true];
}

- (void)rotateWithSpeed:(NSInteger)speed andIsClockwise:(BOOL)isClockwise {
    BOOL subIsClockwise = isClockwise;
    for (KHPlanetTagBaseView *obj in self.tagViews) {
        if (obj.trackNumber == 1 && !self.isPause) {
            subIsClockwise = false;
        } else {
            subIsClockwise = isClockwise;
        }
        obj.currentIndex += subIsClockwise ? speed : -speed;
        if (subIsClockwise && obj.currentIndex >= obj.pointArray.count) {
            NSInteger resIndex = obj.currentIndex - obj.pointArray.count;
            obj.currentIndex = resIndex;
        } else if (!subIsClockwise && obj.currentIndex < 0) {
            NSInteger resIndex = obj.pointArray.count + obj.currentIndex - 1;
            obj.currentIndex = resIndex;

        }
        
        NSInteger leftIndex = obj.pointArray.count/4 + obj.pointArray.count/2;
        NSInteger rightIndex = obj.pointArray.count/4;
        if (obj.currentIndex < rightIndex || obj.currentIndex > leftIndex) {
            if (obj.alpha == 1 || (obj.alpha < 0.4 || obj.alpha > 0.41)) {
                [UIView animateWithDuration:0.3 animations:^{
                    obj.alpha = 0.4;
                    obj.layer.zPosition = 145 - obj.trackNumber;
                }];
                if ([obj isKindOfClass:[KHPlanetTagView class]]) {
                    ((KHPlanetTagView *)obj).isShowBubble = false;
                }
            }
        } else {
            NSInteger zPoisiton = 500 + obj.trackNumber;
            if ((obj.alpha >= 0.4 && obj.alpha < 0.41) || (obj.layer.zPosition != zPoisiton)) {
                [UIView animateWithDuration:0.3 animations:^{
                    obj.alpha = 1;
                    obj.layer.zPosition = zPoisiton;
                }];
                if ([obj isKindOfClass:[KHPlanetTagView class]]) {
                    ((KHPlanetTagView *)obj).isShowBubble = true;
                }
            }
        }
        obj.center = [self convertPoint:obj.pointArray[obj.currentIndex].CGPointValue fromView:self.traceBGView];
    }
}

- (void)onPanGesture:(UIPanGestureRecognizer *)sender {
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self inertiaStop];
            [self stopTimer];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            // 旋转方向
            CGPoint _centerPoint = CGPointMake(self.traceBGView.bounds.size.width/2.0, self.traceBGView.bounds.size.height/2.0);
            CGPoint p = [sender locationInView:sender.view];
            CGFloat currentPointRadius = sqrt(pow(p.y - _centerPoint.y, 2) + pow(p.x - _centerPoint.x, 2));
            if (currentPointRadius != 0) {//当点在中心点时，被除数不能为0
                CGFloat curentPointAngle = acos((p.x - _centerPoint.x) / currentPointRadius);
                if (p.y > _centerPoint.y) {
                    curentPointAngle = 2 * M_PI - curentPointAngle;
                }
                if (_lastPointAngle < curentPointAngle) {
                    self.isClockwise = false;
                    [self rotateWithSpeed:4 andIsClockwise:false];
                } else {
                    self.isClockwise = true;
                    [self rotateWithSpeed:4 andIsClockwise:true];
                }
                _lastPointAngle = curentPointAngle;
            }

            // 上下形变
            CGPoint velocity = [sender velocityInView:self.traceBGView];
            CATransform3D perspectiveTransform = CATransform3DIdentity;
            perspectiveTransform.m34 = -1.f/700;
            if(velocity.y > 0) {
                // 上
                self.angle -= kTraceXYSpeed;
                if (self.angle <= 1.1) {
                    self.angle = 1.1;
                }
                
            } else {
                // 下
                self.angle += kTraceXYSpeed;
                if (self.angle >= 1.58) {
                    self.angle = 1.58;
                }
                NSLog(@"%f", self.angle);
            }
            self.traceBGView.layer.transform = CATransform3DRotate(perspectiveTransform, self.angle, kTraceX, kTraceY, 0);
            _midTraceLayer.transform = CATransform3DRotate(perspectiveTransform, self.angle, kTraceX, kTraceY, 0);
            
            for (KHPlanetTagView *view in self.tagViews) {
                view.center = [self convertPoint:view.pointArray[view.currentIndex].CGPointValue fromView:_traceBGView];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint velocityP = [sender velocityInView:self.traceBGView];
            _velocity = sqrt(velocityP.x * velocityP.x + velocityP.y * velocityP.y);
            if (_velocity > 10000) {
                _velocity = 10000;
            }
            CGFloat slideMult = _velocity / 200;
            float slideFactor = 0.1 * slideMult;
            
            _updateCount = slideFactor * 120 + 1;
            _currentCount = 0;
            
            [self inertiaStart];
        }
            break;
        default:
            break;
    }
}

@end
