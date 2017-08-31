//
//  UIControl+SUGStatistics.m
//  SUGDeclarativeStatistics
//
//  Created by sugite on 2017/8/31.
//  Copyright © 2017年 sugite. All rights reserved.
//

#import "UIControl+SUGStatistics.h"
#import <objc/runtime.h>
#import "SUGStatistics.h"

static const void *sugUIControlEventIdKey = &sugUIControlEventIdKey;
static const void *sugUIControlEventParamsKey = &sugUIControlEventParamsKey;
static const void *sugGetEventIdKey = &sugGetEventIdKey;

@implementation UIControl (SUGStatistics)

- (void)setSugUIControlEventId:(NSString *)sugUIControlEventId
{
    if (sugUIControlEventId.length == 0) {
        return;
    }
    if (self.sugUIControlEventId == nil) {
        [self addTarget:self action:@selector(controlDidClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    objc_setAssociatedObject(self, sugUIControlEventIdKey, sugUIControlEventId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)sugUIControlEventId
{
    return objc_getAssociatedObject(self, sugUIControlEventIdKey);
}

- (void)setSugUIControlEventParams:(NSDictionary *(^)())sugUIControlEventParams
{
    objc_setAssociatedObject(self, sugUIControlEventParamsKey, sugUIControlEventParams, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary *(^)())sugUIControlEventParams
{
    return objc_getAssociatedObject(self, sugUIControlEventParamsKey);
}

- (void)setSugGetEventId:(NSString * (^)())sugGetEventId
{
    if (sugGetEventId == nil) {
        return;
    }
    if (self.sugGetEventId == nil) {
        [self addTarget:self action:@selector(controlDidClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    objc_setAssociatedObject(self, sugGetEventIdKey, sugGetEventId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString * (^)())sugGetEventId
{
    return objc_getAssociatedObject(self, sugGetEventIdKey);
}

- (void)controlDidClicked
{
    NSString *eventId = self.sugGetEventId ? self.sugGetEventId() : self.sugUIControlEventId;
    NSDictionary *params = self.sugUIControlEventParams ? self.sugUIControlEventParams() : nil;
    SUGEventTrack(eventId, nil, SUGStatisticsEventTypeClick, params)
}
@end
