//
//  UITableView+SUGStatistics.m
//  SUGDeclarativeStatistics
//
//  Created by sugite on 2017/8/31.
//  Copyright © 2017年 sugite. All rights reserved.
//

#import "UITableView+SUGStatistics.h"
#import <objc/runtime.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "SUGCellStatisticsProtocol.h"
#import "SUGStatistics.h"

static const void *sugTableViewCellClickEventIdKey = &sugTableViewCellClickEventIdKey;
static const void *sugTableViewCellViewEventIdKey = &sugTableViewCellViewEventIdKey;
static const void *visibledIndexPathsKey = &visibledIndexPathsKey;

@interface UITableView ()
@property (nonatomic, strong) NSMutableSet<NSIndexPath *> *visibledIndexPaths;
@end

@implementation UITableView (SUGStatistics)

- (void)setSugTableViewCellClickEventId:(NSString *)sugTableViewCellClickEventId
{
    objc_setAssociatedObject(self, sugTableViewCellClickEventIdKey, sugTableViewCellClickEventId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)sugTableViewCellClickEventId
{
    return objc_getAssociatedObject(self, sugTableViewCellClickEventIdKey);
}

- (void)setSugTableViewCellViewEventId:(NSString *)sugTableViewCellViewEventId
{
    if (self.sugTableViewCellViewEventId == nil && sugTableViewCellViewEventId.length > 0) {
        self.visibledIndexPaths = [NSMutableSet new];
        @weakify(self)
        [[[RACObserve(self, contentOffset) combineLatestWith:RACObserve(self, contentSize)] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(RACTuple *x) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                if (self.dataSource == nil) {
                    return;
                }
                [self.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSIndexPath *indexPath = [self indexPathForCell:cell];
                    if (![self.visibledIndexPaths containsObject:indexPath]) {
                        if (![cell respondsToSelector:@selector(paramsForCell)]) {
                            return ;
                        }
                        NSMutableDictionary *params = [[(id<SUGCellStatisticsProtocol>)cell paramsForCell] mutableCopy];
                        if (params.allKeys.count == 0) {
                            return ;
                        }
                        [params addEntriesFromDictionary:@{@"index":@(indexPath.item + 1)}];
                        [self.visibledIndexPaths addObject:indexPath];
                        SUGEventTrack(self.sugTableViewCellViewEventId, nil, SUGStatisticsEventTypeView, params)
                    }
                }];
            });
        }];
    }
    objc_setAssociatedObject(self, sugTableViewCellViewEventIdKey, sugTableViewCellViewEventId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)sugTableViewCellViewEventId
{
    return objc_getAssociatedObject(self, sugTableViewCellViewEventIdKey);
}

- (void)setVisibledIndexPaths:(NSMutableSet<NSIndexPath *> *)visibledIndexPaths
{
    objc_setAssociatedObject(self, visibledIndexPathsKey, visibledIndexPaths, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableSet<NSIndexPath *> *)visibledIndexPaths
{
    return objc_getAssociatedObject(self, visibledIndexPathsKey);
}

@end
