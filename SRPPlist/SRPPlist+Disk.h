//
//  SRPPlist+Disk.h
//  SRPPlist
//
//  Created by dev1 on 2017/1/12.
//  Copyright © 2017年 ShinrenPan. All rights reserved.
//

#import <SRPPlist/SRPPlist.h>

NS_ASSUME_NONNULL_BEGIN

@interface SRPPlist (Disk)

- (BOOL)disk_add:(NSDictionary *)dic;
- (BOOL)disk_update:(NSDictionary *)dic where:(NSPredicate *)filter;
- (BOOL)disk_createOrUpdate:(NSDictionary *)dic where:(nullable NSPredicate *)filter;
- (BOOL)disk_removeWhere:(NSPredicate *)filter;
- (BOOL)disk_removeAll;
- (nullable NSArray <NSMutableDictionary *> *)disk_queryWhere:(NSPredicate *)filter sort:(nullable NSArray <NSSortDescriptor *> *)sort;
- (nullable NSArray <NSMutableDictionary *> *)disk_queryAllSort:(nullable NSArray <NSSortDescriptor *> *)sort;
- (NSMutableArray <NSMutableDictionary *> *)disk_array;
- (NSString *)disk_rootPath;
- (NSString *)disk_plistPath;
- (BOOL)disk_save:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
