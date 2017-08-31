//
//  SUGCellStatisticsProtocol.h
//  SUGDeclarativeStatistics
//
//  Created by sugite on 2017/8/31.
//  Copyright © 2017年 sugite. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SUGCellStatisticsProtocol <NSObject>
@required
- (NSDictionary *)paramsForCell;
@end
