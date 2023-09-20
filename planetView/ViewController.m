//
//  ViewController.m
//  planetView
//
//  Created by YAM on 2022/4/12.
//

#import "ViewController.h"
#import "KHPlanetRenderView.h"
#import "KHPlanetTagView.h"
#import "KHPlanetTagModel.h"

@interface ViewController ()
/**  */
@property (nonatomic, strong) KHPlanetRenderView * renderView;
/**  */
@property (nonatomic, strong) NSMutableArray * tags;
@end

@implementation ViewController

// MARK: - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self setupActions];
    [self makeViewConstraints];
}

// MARK: - View Initialize
- (void)setupViews {
    // ...    
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = self.view.bounds;
    gl.startPoint = CGPointMake(0.5, 0);
    gl.endPoint = CGPointMake(0.5, 0.9);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:186/255.0 green:237/255.0 blue:255/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0), @(1.0f)];
    [self.view.layer addSublayer:gl];
    
    NSMutableArray *array1 = [NSMutableArray array];
    for (NSInteger i = 0; i< 4; i++) {
        KHPlanetTagModel *tagModel = [KHPlanetTagModel new];
        tagModel.sizeStyle = KHPlanetTagModelSizeStyleBig;
        [array1 addObject:tagModel];
    }
    NSMutableArray *array2 = [NSMutableArray array];
    for (NSInteger i = 0; i< 6; i++) {
        KHPlanetTagModel *tagModel = [KHPlanetTagModel new];
        tagModel.sizeStyle = KHPlanetTagModelSizeStyleMid;
        [array2 addObject:tagModel];
    }
    
    NSMutableArray *array3 = [NSMutableArray array];
    for (NSInteger i = 0; i < 4; i++) {
        KHPlanetTagModel *tagModel = [KHPlanetTagModel new];
        tagModel.index = i;
        switch (i) {
            case 0:
            case 4:
            case 7:
                tagModel.sizeStyle = KHPlanetTagModelSizeStyleBig;
                break;
            case 2:
            case 5:
            case 8:
            case 10:
            case 13:
            case 14:
            case 16:
            case 18:
                tagModel.sizeStyle = KHPlanetTagModelSizeStyleMid;
                break;
            default:
                tagModel.sizeStyle = KHPlanetTagModelSizeStyleSmall;
                break;
        }
        [array3 addObject:tagModel];
    }
    NSDictionary *dict = @{@(0): array1, @(1): array2, @(2): array3};
    
    self.renderView = [[KHPlanetRenderView alloc] initWithFrame:CGRectMake(0, 88, self.view.bounds.size.width, 500)];
//    self.renderView.tagModels = dict;
    self.renderView.tagArray = array3.copy;
    [self.view addSubview:self.renderView];
}

// MARK: - Layout
- (void)makeViewConstraints {
    // ...
}

// MARK: - User Interaction
- (void)setupActions {
    // ...
    
}

// MARK: - Delegate

// MARK: - Helpers and Network


@end

