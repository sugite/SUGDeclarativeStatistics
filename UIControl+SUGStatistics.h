//
//  UIControl+SUGStatistics.h
//  SUGDeclarativeStatistics
//
//  Created by sugite on 2017/8/31.
//  Copyright © 2017年 sugite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (SUGStatistics)

@property (nonatomic, strong) NSString *sugUIControlEventId;
@property (nonatomic, copy) NSDictionary * (^sugUIControlEventParams)();
@property (nonatomic, copy) NSString * (^sugGetEventId)();

@end
