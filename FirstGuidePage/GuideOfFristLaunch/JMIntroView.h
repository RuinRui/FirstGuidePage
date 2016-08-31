//
//  JMIntroView.h
//  12- 03 按钮点击
//
//  Created by FBI、君陌 on 14-12-3.
//  Copyright (c) 2014年 FBI、君陌. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JMIntroView;
/**判断引导图是否结束的代理*/
@protocol JMIntroViewDelegate <NSObject>
@optional

- (void) introViewDidFinish:(JMIntroView *) introView;
- (void) intro:(JMIntroView *)introView imageAppeared:(UIImage *)image withIndex:(NSUInteger)pageIndex;
- (void) intro:(JMIntroView *)introView imageStartScrolling:(UIImage *)image withIndex:(NSUInteger)pageIndex;
- (void) intro:(JMIntroView *)introView imageEndScrolling:(UIImage *)image withIndex:(NSUInteger)pageIndex;

@end
/**引导视图*/
@interface JMIntroView : UIView <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView * scrollView;
/**获取图片的数量*/
@property (nonatomic, strong) NSMutableArray * picArr;
/**设置点击引导图后的水波纹颜色*/
@property (nonatomic, strong) UIColor * rippleColor;
@property (nonatomic, strong) UIPageControl * pageCtrl;
/**获取点击的位置*/
@property (nonatomic) CGPoint point;
@property (nonatomic, weak) id <JMIntroViewDelegate> delegate;

/**
 *  创建 欢迎页
 *
 *  @param pictures 图片名称数组
 *
 *  @return 欢迎页视图
 */
+ (instancetype) shareInstanceWithPictures:(NSArray *) pictures delegate:(id) delegate;
/**
 *  展示欢迎页
 *
 *  @param view 展示在哪个页面上
 */
- (void) showInView:(UIView *) view;

@end
