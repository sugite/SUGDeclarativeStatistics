//
//  UIView+SUGStatistics.h
//  SUGDeclarativeStatistics
//
//  Created by sugite on 2017/8/31.
//  Copyright © 2017年 sugite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SUGStatistics)
@property (nonatomic, strong) NSString *sugUIViewClickEventId;
@property (nonatomic, strong) NSString *sugUIViewViewEventId;
@property (nonatomic, copy) NSDictionary * (^sugUIViewEventParams)();
@end
