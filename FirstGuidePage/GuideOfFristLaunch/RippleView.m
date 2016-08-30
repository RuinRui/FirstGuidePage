//
//  RippleView.m
//  12- 03 按钮点击
//
//  Created by FBI、君陌 on 14-12-3.
//  Copyright (c) 2014年 FBI、君陌. All rights reserved.
//

#import "RippleView.h"

@implementation RippleView

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
//        加载单击事件
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShowWaterRipple:)];
        [self addGestureRecognizer:tapGesture];
    }
    
    return self;
}

- (void) tapShowWaterRipple:(UITapGestureRecognizer *) tapGesture{
    
    UIColor * stroke = _rippleColor ? _rippleColor : [UIColor greenColor];
    
    CGRect pathframe = CGRectMake(- 15, - 15, 30, 30);
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:pathframe cornerRadius:20];
    
    CGPoint point = [tapGesture locationInView:tapGesture.view];
//    画圆
    CAShapeLayer * circleShape = [CAShapeLayer layer];
    circleShape.path = path.CGPath;
    circleShape.position = point;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.opacity = 0;
    circleShape.strokeColor = stroke.CGColor;
    circleShape.lineWidth = 1.5;
    
    [tapGesture.view.layer addSublayer:circleShape];
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

@end
