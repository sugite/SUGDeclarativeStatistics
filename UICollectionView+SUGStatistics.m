//
//  UICollectionView+SUGStatistics.m
//  SUGDeclarativeStatistics
//
//  Created by sugite on 2017/8/31.
//  Copyright © 2017年 sugite. All rights reserved.
//

#import "UICollectionView+SUGStatistics.h"
#import <objc/runtime.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "SUGCellStatisticsProtocol.h"
#import "SUGStatistics.h"

static const void *sugCollectionViewCellClickEventIdKey = &sugCollectionViewCellClickEventIdKey;
static const void *sugCollectionViewCellViewEventIdKey = &sugCollectionViewCellViewEventIdKey;
static const void *visibledIndexPathsKey = &visibledIndexPathsKey;

@interface UICollectionView ()
@property (nonatomic, strong) NSMutableSet<NSIndexPath *> *visibledIndexPaths;
@end

@implementation UICollectionView (SUGStatistics)

- (void)setSugCollectionViewCellClickEventId:(NSString *)sugCollectionViewCellClickEventId
{
    objc_setAssociatedObject(self, sugCollectionViewCellClickEventIdKey, sugCollectionViewCellClickEventId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)sugCollectionViewCellClickEventId
{
    return objc_getAssociatedObject(self, sugCollectionViewCellClickEventIdKey);
}

- (void)setSugCollectionViewCellViewEventId:(NSString *)sugCollectionViewCellViewEventId
{
    if (self.sugCollectionViewCellViewEventId == nil && sugCollectionViewCellViewEventId.length > 0) {
        self.visibledIndexPaths = [NSMutableSet new];
        @weakify(self)
        [[[RACObserve(self, contentOffset) combineLatestWith:RACObserve(self, contentSize)] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(RACTuple *x) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                if (self.dataSource == nil) {
                    return;
                }
                [self.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
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
                        SUGEventTrack(self.sugCollectionViewCellViewEventId, nil, SUGStatisticsEventTypeView, params)
                    }
                }];
            });
        }];
    }
    objc_setAssociatedObject(self, sugCollectionViewCellViewEventIdKey, sugCollectionViewCellViewEventId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)sugCollectionViewCellViewEventId
{
    return objc_getAssociatedObject(self, sugCollectionViewCellViewEventIdKey);
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
