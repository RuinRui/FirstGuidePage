//
//  JMIntroView.m
//  12- 03 按钮点击
//
//  Created by FBI、君陌 on 14-12-3.
//  Copyright (c) 2014年 FBI、君陌. All rights reserved.
//

#import "JMIntroView.h"

#ifndef kScreenW
#define kScreenW    [UIScreen mainScreen].bounds.size.width
#endif

#ifndef kScreenH
#define kScreenH    [UIScreen mainScreen].bounds.size.height
#endif

@implementation JMIntroView

#pragma mark - 根据图片名称数组初始化JMIntroView
+ (instancetype) shareInstanceWithPictures:(NSArray *) pictures delegate:(id) delegate{
    
    JMIntroView * view = [[JMIntroView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
    view.delegate = delegate;
    [view initWithPictures:pictures];
    [view initwithScrollView];
    
    return view;
}

#pragma mark - 初始化
- (void) initWithPictures:(NSArray *)pictures{
    
    _picArr = [[ NSMutableArray alloc] init];
    
    for (int i = 0; i < pictures.count; i ++) {
        UIImageView * imgV = [[UIImageView alloc] initWithFrame:self.frame];
        imgV.image = [UIImage imageNamed:pictures[pictures.count - 1 - i]];
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imgV];
    }
    
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    for (id anything in self.subviews) {
        if ([anything isKindOfClass:[UIImageView class]]) {
            [arr addObject:anything];
        }
    }
//    确保_picArr中的对象是self的子View由上到下排列的数组
    for (NSInteger i = arr.count - 1; i >= 0; i --) {
        [_picArr addObject:arr[i]];
    }
}

#pragma mark - 初始化ScrollView
- (void) initwithScrollView{
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width * (_picArr.count + 1), self.frame.size.height);
    self.scrollView.delegate = self;
    
    self.scrollView.alpha = 0.1;
    self.scrollView.pagingEnabled = YES;
    
    [self addSubview:self.scrollView];
//    当引导图在显示的时候，点击时候会出现 水波纹 效果
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShowWaterRipple:)];
    [self.scrollView addGestureRecognizer:tapGesture];
    
//    注销自带的pageController
    self.pageCtrl = [[UIPageControl alloc] initWithFrame:CGRectMake((self.frame.size.width - 100) / 2, self.frame.size.height - 50, 100, 30)];
    
    self.pageCtrl.numberOfPages = self.picArr.count;
    [self addSubview:self.pageCtrl];
}

#pragma mark - 展示欢迎页
- (void) showInView:(UIView *) view{
    
    if (self.superview != view) {
        [view addSubview:self];
    } else {
        [view bringSubviewToFront:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(intro:imageAppeared:withIndex:)]) {
        [self.delegate intro:self imageAppeared:[(UIImageView *)self.picArr[0] image] withIndex:0];
    }
}

#pragma mark - 单机图片
- (void) tapShowWaterRipple:(UITapGestureRecognizer *) tapGesture{
    _point = [tapGesture locationInView:tapGesture.view];
    [self showWaterRipple];
    
    if (self.scrollView.contentOffset.x == kScreenW * (_picArr.count-1)) {
        [UIView animateWithDuration:1.0 animations:^{
            UIImageView * imgV = (id)self.subviews[0];
            imgV.alpha = 0;
        }];
        
        [self performSelector:@selector(introViewFinshed) withObject:nil afterDelay:1.0];
    }
}

#pragma mark - 结束引导图
- (void) introViewFinshed{
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(introViewDidFinish:)]) {
        [self.delegate introViewDidFinish:self];
    }
}

#pragma mark - 单机引导图出现水波纹效果
- (void) showWaterRipple{
    
    UIColor * stroke = _rippleColor ? _rippleColor : [UIColor blueColor];
    
    CGRect pathframe = CGRectMake(- 15, - 15, 30, 30);
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:pathframe cornerRadius:20];
//    画圆
    CAShapeLayer * circleShape = [CAShapeLayer layer];
    circleShape.path = path.CGPath;
    circleShape.position = _point;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.opacity = 0;
    circleShape.strokeColor = stroke.CGColor;
    circleShape.lineWidth = 1.5;
    
    [self.scrollView.layer addSublayer:circleShape];
//    缩放动画
    CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.5, 2.5, 1)];
//    透明度动画
    CABasicAnimation * alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
//    动画组，让缩放动画和透明度动画一起执行
    CAAnimationGroup * animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.duration = 0.5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [circleShape addAnimation:animation forKey:nil];
}

#pragma mark -
#pragma mark - UIScrollView delegate
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    int currentPage = scrollView.contentOffset.x / self.frame.size.width;
//    NSLog(@"scrollViewWillBeginDragging === %d", currentPage);
    if ([self.delegate respondsToSelector:@selector(intro:imageStartScrolling:withIndex:)]) {
        [self.delegate intro:self imageStartScrolling:[(UIImageView *)self.picArr[currentPage] image] withIndex:currentPage];
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
    
    int currentPage = scrollView.contentOffset.x / self.frame.size.width;
//    NSLog(@"scrollViewDidScroll === %d", currentPage);
    if (currentPage < self.picArr.count) {
        UIImageView * imgV = self.picArr[currentPage];
        imgV.alpha = 1 - (scrollView.contentOffset.x - ((int)scrollView.contentOffset.x / (int)self.frame.size.width * self.frame.size.width)) / self.frame.size.width;
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int currentPage = scrollView.contentOffset.x / self.frame.size.width;
//    NSLog(@"scrollViewDidEndDecelerating === %d", currentPage);
    self.pageCtrl.currentPage = currentPage;
    
    for (NSInteger i = 0; i < currentPage && currentPage < self.picArr.count; i ++) {
        UIImageView * imgV = self.picArr[i];
        imgV.alpha = 0;
    }
    
    for (NSInteger i = self.picArr.count - 1; i >= currentPage; i --) {
        UIImageView * imgV = self.picArr[i];
        imgV.alpha = 1;
    }
    
    if ([self.delegate respondsToSelector:@selector(intro:imageEndScrolling:withIndex:)] && currentPage < self.picArr.count)  {
        [self.delegate intro:self imageEndScrolling:[(UIImageView *)self.picArr[currentPage] image] withIndex:currentPage];
    }
    
    if ([self.delegate respondsToSelector:@selector(intro:imageAppeared:withIndex:)] && currentPage < self.picArr.count) {
        [self.delegate intro:self imageAppeared:[(UIImageView *)self.picArr[currentPage] image] withIndex:currentPage];
    }
//    当滚动停止的时候，若到了最后一页的下一页了，引导图结束，给代理发送消息
    if (currentPage == self.picArr.count) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(introViewDidFinish:)]) {
            [self.delegate introViewDidFinish:self];
        }
    }
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    int currentPage = scrollView.contentOffset.x / self.frame.size.width;
//    NSLog(@"scrollViewDidEndScrollingAnimation === %d", currentPage);
    if ([self.delegate respondsToSelector:@selector(intro:imageAppeared:withIndex:)] && currentPage < self.picArr.count) {
        [self.delegate intro:self imageAppeared:[(UIImageView *)self.picArr[currentPage] image] withIndex:currentPage];
    }
}

@end
