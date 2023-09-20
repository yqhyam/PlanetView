# PlanetView
公司产品提了需求，要求参考 QQ 音乐星球功能，实现好友星球效果。
伪3D星球动画 DEMO，支持手势顺时针逆时针旋转拖动，上滑下滑调整角度。
DEMO 并未包含全部功能，可以自行扩展实现对应需求。
效果如下：
https://github.com/yqhyam/PlanetView/assets/29418368/f9856049-e484-4aba-8620-428317b3ddee

核心代码：
```
将贝塞尔曲线转换成 point
typedef void (^UIBezierPath_forEachElement_Block)(CGPathElement const *element);

@implementation UIBezierPath (forEachElement)

static void applyBlockToPathElement(void *info, CGPathElement const *element) {
    __unsafe_unretained UIBezierPath_forEachElement_Block block =(__bridge  UIBezierPath_forEachElement_Block)info;
    block(element);
}

- (void)forEachElement:(void (^)(const CGPathElement *))block {
    CGPathApply(self.CGPath, (__bridge void *)block, applyBlockToPathElement);
}

@end
```
