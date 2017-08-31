//
//  UIView+SUGStatistics.m
//  SUGDeclarativeStatistics
//
//  Created by sugite on 2017/8/31.
//  Copyright © 2017年 sugite. All rights reserved.
//

#import "UIView+SUGStatistics.h"
#import <objc/runtime.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "SUGStatistics.h"

static const void *sugUIViewClickEventIdKey = &sugUIViewClickEventIdKey;
static const void *sugUIViewViewEventIdKey = &sugUIViewViewEventIdKey;
static const void *sugUIViewEventParamsKey = &sugUIViewEventParamsKey;

@implementation UIView (SUGStatistics)

+ (void)load
{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(addGestureRecognizer:)), class_getInstanceMethod(self, @selector(sugst_addGestureRecognizer:)));
}

- (void)setSugUIViewClickEventId:(NSString *)sugUIViewClickEventId
{
    objc_setAssociatedObject(self, sugUIViewClickEventIdKey, sugUIViewClickEventId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)sugUIViewClickEventId
{
    return objc_getAssociatedObject(self, sugUIViewClickEventIdKey);
}

- (void)setSugUIViewViewEventId:(NSString *)sugUIViewViewEventId
{
    objc_setAssociatedObject(self, sugUIViewViewEventIdKey, sugUIViewViewEventId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)sugUIViewViewEventId
{
    return objc_getAssociatedObject(self, sugUIViewViewEventIdKey);
}

- (void)sugst_addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && self.sugUIViewClickEventId.length > 0) {
        NSArray *targets = [gestureRecognizer valueForKey:@"_targets"];
        if (targets.count == 0) {
            return ;
        }
        id target = [targets.firstObject valueForKey:@"_target"];
        SEL action = ((SEL (*)(id, Ivar))object_getIvar)(targets.firstObject, class_getInstanceVariable([targets.firstObject class], "_action"));
        if (![target respondsToSelector:action]) {
            return ;
        }
        @weakify(self)
        [[[target rac_signalForSelector:action] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
            @strongify(self)
            NSDictionary *params = self.sugUIViewEventParams ? self.sugUIViewEventParams() : nil;
            SUGEventTrack(self.sugUIViewClickEventId, nil, SUGStatisticsEventTypeClick, params)
        }];
    }
    [self sugst_addGestureRecognizer:gestureRecognizer];
}

- (void)setSugUIViewEventParams:(NSDictionary *(^)())sugUIViewEventParams
{
    objc_setAssociatedObject(self, sugUIViewEventParamsKey, sugUIViewEventParams, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary *(^)())sugUIViewEventParams
{
    return objc_getAssociatedObject(self, sugUIViewEventParamsKey);
}

@end
