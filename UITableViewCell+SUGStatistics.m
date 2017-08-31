//
//  UITableViewCell+SUGStatistics.m
//  SUGDeclarativeStatistics
//
//  Created by sugite on 2017/8/31.
//  Copyright © 2017年 sugite. All rights reserved.
//

#import "UITableViewCell+SUGStatistics.h"
#import <objc/runtime.h>
#import "SUGCellStatisticsProtocol.h"
#import "SUGStatistics.h"
#import "UITableView+SUGStatistics.h"

@implementation UITableViewCell (SUGStatistics)

+(void)load
{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(setSelected:animated:)), class_getInstanceMethod(self, @selector(sugst_setSelected:animated:)));
}

- (void)sugst_setSelected:(BOOL)selected animated:(BOOL)animated {
    [self sugst_setSelected:selected animated:animated];
    if (selected) {
        NSMutableDictionary *params = [NSMutableDictionary new];
        if ([self respondsToSelector:@selector(paramsForCell)]) {
            [params addEntriesFromDictionary:[(id<SUGCellStatisticsProtocol>)self paramsForCell]];
        } else {
            return;
        }
        id view = [self superview];
        while (view && ![view isKindOfClass:[UITableView class]]) {
            view = [view superview];
        }
        UITableView *tableView = (UITableView *)view;
        if (tableView.sugTableViewCellClickEventId.length > 0) {
            NSIndexPath *indexPath = [tableView indexPathForCell:self];
            [params addEntriesFromDictionary:@{@"index":@(indexPath.row + 1)}];
            SUGEventTrack(tableView.sugTableViewCellClickEventId, nil, SUGStatisticsEventTypeClick, params)
        }
    }
}

@end
