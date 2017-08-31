//
//  SUGStatistics.m
//  SUGDeclarativeStatistics
//
//  Created by sugite on 2017/8/31.
//  Copyright © 2017年 sugite. All rights reserved.
//

#import "SUGStatistics.h"

@implementation SUGStatistics

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end

@implementation SUGStatistics (Invoke)

#pragma mark - Event
+ (void)eventWithId:(NSString *)eventId pageId:(NSString *)pageId type:(SUGStatisticsEventType)type params:(id)params
{
    if ([SUGStatistics sharedInstance].eventBlock) {
        [SUGStatistics sharedInstance].eventBlock(eventId, pageId, type, params);
    }
}

#pragma mark - Page
+ (void)pageWithId:(NSString *)pageId params:(id)params
{
    if ([SUGStatistics sharedInstance].pageBlock) {
        [SUGStatistics sharedInstance].pageBlock(pageId, params);
    }
}

@end
