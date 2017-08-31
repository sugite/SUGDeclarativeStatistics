//
//  SUGStatistics.h
//  SUGDeclarativeStatistics
//
//  Created by sugite on 2017/8/31.
//  Copyright © 2017年 sugite. All rights reserved.
//

// 统计事件主要分两类：Event 和 Page
// Event 主要是用户行为统计，比如 控件点击、控件曝光
// Page  主要是页面PV UV统计

#import <Foundation/Foundation.h>

#define SUGEventTrack(EVENTID, PAGEID, TYPE, PARAMS)    ([SUGStatistics trackEvent:EVENTID pageId:PAGEID type:TYPE params:PARAMS]);
#define SUGPageTrack(PAGEID, PARAMS)                    ([SUGStatistics trackPage:PAGEID params:PARAMS]);

typedef NS_ENUM (NSUInteger, SUGStatisticsEventType) {
    SUGStatisticsEventTypeView = 1,    // 曝光
    SUGStatisticsEventTypeClick = 2,   // 点击
    SUGStatisticsEventTypeNone = 0,    // 无类别
};

typedef void(^SUGStatisticsEventBlock)(NSString *eventId, NSString *pageId, SUGStatisticsEventType type, id params);
typedef void(^SUGStatisticsPageBlock)(NSString *pageId, id params);

@interface SUGStatistics : NSObject

// 通过block注入自己所依赖的统计库
@property (nonatomic, copy) SUGStatisticsEventBlock  eventBlock;
@property (nonatomic, copy) SUGStatisticsPageBlock   pageBlock;

+ (instancetype)sharedInstance;

@end

@interface SUGStatistics (Invoke)

#pragma mark - Event
+ (void)trackEvent:(NSString *)eventId pageId:(NSString *)pageId type:(SUGStatisticsEventType)type params:(id)params;

#pragma mark - Page
+ (void)trackPage:(NSString *)pageId params:(id)params;

@end
