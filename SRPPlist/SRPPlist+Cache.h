//
//  SRPPlist+Cache.h
//  SRPPlist
//
//  Created by dev1 on 2017/1/12.
//  Copyright © 2017年 ShinrenPan. All rights reserved.
//

#import <SRPPlist/SRPPlist.h>

NS_ASSUME_NONNULL_BEGIN

@interface SRPPlist (Cache)

- (BOOL)cache_add:(NSDictionary *)dic;
- (BOOL)cache_update:(NSDictionary *)dic where:(NSPredicate *)filter;
- (BOOL)cache_createOrUpdate:(NSDictionary *)dic where:(nullable NSPredicate *)filter;
- (BOOL)cache_removeWhere:(NSPredicate *)filter;
- (BOOL)cache_removeAll;
- (nullable NSArray <NSMutableDictionary *> *)cache_queryWhere:(NSPredicate *)filter sort:(nullable NSArray <NSSortDescriptor *> *)sort;
- (nullable NSArray <NSMutableDictionary *> *)cache_queryAllSort:(nullable NSArray <NSSortDescriptor *> *)sort;
- (BOOL)cache_save;
- (void)cache_reload;

@end

NS_ASSUME_NONNULL_END
