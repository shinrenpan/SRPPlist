//
//  Copyright (c) 2017 shinren.pan@gmail.com All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SRPPlistStatus)
{
    SRPPlistStatusCacheAdd,
    SRPPlistStatusCacheUpdate,
    SRPPlistStatusCacheRemove,
    SRPPlistStatusCacheRemoveAll,
    SRPPlistStatusDiskAdd,
    SRPPlistStatusDiskUpdate,
    SRPPlistStatusDiskRemove,
    SRPPlistStatusDiskRemoveAll,
    SRPPlistStatusDiskSave
};

typedef void(^SRPPlistStatusChanged)(SRPPlistStatus status);

/**
 * Plist as DataBase.
 */
@interface SRPPlist : NSObject


///-----------------------------------------------------------------------------
/// @name Properties
///-----------------------------------------------------------------------------

/**
 *  SRPPlist 狀態改變 block.
 */
@property (nonatomic, copy) SRPPlistStatusChanged statusChanged;

/**
 *  是否使用 Cache, Default = YES.
 *
 *  Cache = YES 時, 所有資料在 saveCache 前, 將不會儲存到 Disk 裡.
 *
 *  Cache = NO 時, 所有資料處理將自動儲存到 disk 裡.
 */
@property (nonatomic, assign) BOOL cache;


///-----------------------------------------------------------------------------
/// @name Public methods
///-----------------------------------------------------------------------------

/**
 *  返回 SRPPlist object, 儲存在 Sanbox Documents/SRPPlist/name.plist 底下.
 *
 *  @param name Plist name.
 *
 *  @return 返回 SRPPlist object.
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  新增.
 *
 *  @param dic 新增的資料.
 *
 *  @return 是否新增成功.
 */
- (BOOL)add:(NSDictionary *)dic;

/**
 *  修改.
 *
 *  @param dic 更新的資料.
 *
 *  @return 是否更新成功.
 */
- (BOOL)update:(NSDictionary *)dic;

/**
 *  刪除.
 *
 *  @param dic 刪除的資料.
 *
 *  @return 刪除是否成功.
 */
- (BOOL)remove:(NSDictionary *)dic;

/**
 *  刪除全部.
 *
 *  @return 刪除是否成功.
 */
- (BOOL)removeAll;

/**
 *  查詢.
 *
 *  @param filter 過濾條件.
 *  @param sort   排序.
 *
 *  @return 查詢到到資料.
 */
- (nullable NSArray <NSMutableDictionary *> *)queryByFileter:(NSPredicate *)filter sortBy:(nullable NSArray <NSSortDescriptor *> *)sort;

/**
 *  查詢全部.
 *
 *  @param sort 排序.
 *
 *  @return 查詢到的資料.
 */
- (nullable NSArray <NSMutableDictionary *> *)queryAllSortBy:(nullable NSArray <NSSortDescriptor *> *)sort;

/**
 *  儲存 Cache 資料.
 *
 *  @return 儲存是否成功.
 */
- (BOOL)saveCache;

/**
 *  Reload Cache 資料.
 */
- (void)reloadCache;

@end

NS_ASSUME_NONNULL_END
