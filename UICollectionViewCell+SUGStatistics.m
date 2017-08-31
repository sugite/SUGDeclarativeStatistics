//
//  UICollectionViewCell+SUGStatistics.m
//  SUGDeclarativeStatistics
//
//  Created by sugite on 2017/8/31.
//  Copyright © 2017年 sugite. All rights reserved.
//

#import "UICollectionViewCell+SUGStatistics.h"
#import <objc/runtime.h>
#import "SUGCellStatisticsProtocol.h"
#import "SUGStatistics.h"
#import "UICollectionView+SUGStatistics.h"

static const void *lastCalledTimeKey = &lastCalledTimeKey;

@interface UICollectionViewCell ()
@property (nonatomic, assign) NSTimeInterval lastCalledTime;
@end

@implementation UICollectionViewCell (SUGStatistics)

+(void)load
{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(setSelected:)), class_getInstanceMethod(self, @selector(sugst_setSelected:)));
}

- (void)sugst_setSelected:(BOOL)selected
{
    [self sugst_setSelected:selected];
    if (selected && [self respondsToSelector:@selector(paramsForCell)]) {
        if ([NSDate date].timeIntervalSince1970 - self.lastCalledTime < 0.3) {
            return;
        }
        self.lastCalledTime = [NSDate date].timeIntervalSince1970;
        id view = [self superview];
        while (view && ![view isKindOfClass:[UICollectionView class]]) {
            view = [view superview];
        }
        UICollectionView *collectionView = (UICollectionView *)view;
        if (collectionView.sugCollectionViewCellClickEventId.length > 0) {
            NSIndexPath *indexPath = [collectionView indexPathForCell:self];
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"index":@(indexPath.item + 1)}];
            [params addEntriesFromDictionary:[(id<SUGCellStatisticsProtocol>)self paramsForCell]];
            SUGEventTrack(collectionView.sugCollectionViewCellClickEventId, nil, SUGStatisticsEventTypeClick, params)
        }
    }
}

- (void)setLastCalledTime:(NSTimeInterval)lastCalledTime
{
    objc_setAssociatedObject(self, lastCalledTimeKey, @(lastCalledTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)lastCalledTime
{
    return [objc_getAssociatedObject(self, lastCalledTimeKey) doubleValue];
}

@end
