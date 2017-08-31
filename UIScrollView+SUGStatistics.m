//
//  UIScrollView+SUGStatistics.m
//  SUGDeclarativeStatistics
//
//  Created by sugite on 2017/8/31.
//  Copyright © 2017年 sugite. All rights reserved.
//

#import "UIScrollView+SUGStatistics.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <objc/runtime.h>
#import "UIView+SUGStatistics.h"
#import "SUGStatistics.h"

static const void *sugAllowTrackViewEventKey = &sugAllowTrackViewEventKey;
static const void *sugScrollViewSubviewSetKey = &sugScrollViewSubviewSetKey;
static const void *sugScrollViewEventViewsKey = &sugScrollViewEventViewsKey;
static const void *sugScrollViewVisibledViewsKey = &sugScrollViewVisibledViewsKey;
static const void *sugScrollViewLastSignalTimeKey = &sugScrollViewLastSignalTimeKey;
static const void *sugScrollViewLastHeightKey = &sugScrollViewLastHeightKey;
static const void *sugScrollViewStopEnumerateSubviewKey = &sugScrollViewStopEnumerateSubviewKey;

@interface UIScrollView ()
@property (nonatomic, strong) NSMutableSet *sugSubviewSet;
@property (nonatomic, strong) NSMutableArray *sugEventViews;
@property (nonatomic, strong) NSMutableSet *sugVisibledViews;
@property (nonatomic, assign) NSTimeInterval sugLastSignalTime;
@property (nonatomic, assign) CGFloat sugLastHeight;
@property (nonatomic, assign) BOOL sugStopEnumerateSubview;
@end

@implementation UIScrollView (SUGStatistics)

- (void)setSugAllowTrackViewEvent:(BOOL)sugAllowTrackViewEvent
{
    if (self.sugAllowTrackViewEvent == NO && sugAllowTrackViewEvent) {
        self.sugSubviewSet = [NSMutableSet new];
        self.sugEventViews = [NSMutableArray new];
        self.sugVisibledViews = [NSMutableSet new];
        self.sugLastSignalTime = [NSDate date].timeIntervalSince1970;
        @weakify(self)
        // thottle 1 确保除网络问题以外的大部分view布局已完成
        [[[RACObserve(self, contentOffset) combineLatestWith:[RACObserve(self, contentSize) throttle:1]] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(RACTuple *x) {
            @strongify(self)
            // 统计间隔至少为0.1s
            NSTimeInterval nowTime = [NSDate date].timeIntervalSince1970;
            if (nowTime - self.sugLastSignalTime < 0.1) {
                return ;
            }
            
            // 计算滚动速度
            CGFloat currHeight = [x.first CGSizeValue].height;
            CGFloat scrollSpeed = fabs((currHeight - self.sugLastHeight) / (nowTime - self.sugLastSignalTime));
            self.sugLastSignalTime = nowTime;
            self.sugLastHeight = currHeight;
            
            // 快速滚动时略过
            if (scrollSpeed > 400) {  // 400 pixels per second
                return ;
            }
            
            // subview无变化时将不会继续遍历subview
            if (!self.sugStopEnumerateSubview) {
                [self sugEnumerateSubview];
            }
            
            CGRect visibleRect = (CGRect) {self.contentOffset, self.bounds.size};
            [self.sugEventViews enumerateObjectsUsingBlock:^(UIView *eventView, NSUInteger idx, BOOL * _Nonnull stop) {
                if (self.sugVisibledViews.count == self.sugEventViews.count) {
                    *stop = YES;
                }
                if ([self.sugVisibledViews containsObject:eventView.sugUIViewViewEventId]) {
                    return;
                }
                BOOL isHidden = eventView.hidden || eventView.alpha < 0.01 || eventView.frame.size.width <= 0 || eventView.frame.size.height <= 0;
                if (!isHidden) {
                    CGRect realFrame = [self convertRect:eventView.bounds fromView:eventView];
                    if (CGRectIntersectsRect(visibleRect, realFrame)) {
                        NSDictionary *params = eventView.sugUIViewEventParams ? eventView.sugUIViewEventParams() : nil;
                        SUGEventTrack(eventView.sugUIViewViewEventId, nil, SUGStatisticsEventTypeView, params)
                        [self.sugVisibledViews addObject:eventView.sugUIViewViewEventId];
                    }
                }
            }];
        }];
    }
    objc_setAssociatedObject(self, sugAllowTrackViewEventKey, @(sugAllowTrackViewEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sugAllowTrackViewEvent
{
    return [objc_getAssociatedObject(self, sugAllowTrackViewEventKey) boolValue];
}

- (void)sugEnumerateSubview
{
    NSUInteger subviewCount = self.sugSubviewSet.count;
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray<UIView *> *viewsQueue = [NSMutableArray arrayWithArray:@[subview]];
        UIView *curView = nil;
        while (viewsQueue.count > 0) {
            curView = viewsQueue.firstObject;
            if (![self.sugSubviewSet containsObject:@(curView.hash)]) {
                [self.sugSubviewSet addObject:@(curView.hash)];
            }
            [viewsQueue removeObjectAtIndex:0];
            if (curView.sugUIViewViewEventId.length > 0) {
                __weak typeof(curView) weakCurView = curView;
                [self.sugEventViews addObject:weakCurView];
            }
            [viewsQueue addObjectsFromArray:curView.subviews];
        }
    }];
    self.sugStopEnumerateSubview = subviewCount == self.sugSubviewSet.count;
}

- (void)setsugSubviewSet:(NSMutableSet *)sugSubviewSet
{
    objc_setAssociatedObject(self, sugScrollViewSubviewSetKey, sugSubviewSet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableSet *)sugSubviewSet
{
    return objc_getAssociatedObject(self, sugScrollViewSubviewSetKey);
}

- (void)setSugEventViews:(NSMutableArray *)sugEventViews
{
    objc_setAssociatedObject(self, sugScrollViewEventViewsKey, sugEventViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)sugEventViews
{
    return objc_getAssociatedObject(self, sugScrollViewEventViewsKey);
}

- (void)setsugVisibledViews:(NSMutableSet *)sugVisibledViews
{
    objc_setAssociatedObject(self, sugScrollViewVisibledViewsKey, sugVisibledViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableSet *)sugVisibledViews
{
    return objc_getAssociatedObject(self, sugScrollViewVisibledViewsKey);
}

- (void)setsugLastSignalTime:(NSTimeInterval)sugLastSignalTime
{
    objc_setAssociatedObject(self, sugScrollViewLastSignalTimeKey, @(sugLastSignalTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)sugLastSignalTime
{
    return [objc_getAssociatedObject(self, sugScrollViewLastSignalTimeKey) doubleValue];
}

- (void)setsugLastHeight:(CGFloat)sugLastHeight
{
    objc_setAssociatedObject(self, sugScrollViewLastHeightKey, @(sugLastHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)sugLastHeight
{
    return [objc_getAssociatedObject(self, sugScrollViewLastHeightKey) floatValue];
}

- (void)setsugStopEnumerateSubview:(BOOL)sugStopEnumerateSubview
{
    objc_setAssociatedObject(self, sugScrollViewStopEnumerateSubviewKey, @(sugStopEnumerateSubview), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sugStopEnumerateSubview
{
    return [objc_getAssociatedObject(self, sugScrollViewStopEnumerateSubviewKey) boolValue];
}

@end
