//
//  Copyright (c) 2017 shinren.pan@gmail.com All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 使用 Plist 當作簡易 DataBase
 */
@interface SRPPlist : NSObject


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
 *  新增或更新.
 *
 *  @param dic 新增或更新的 NSDictionary.
 */
- (void)createOrUpdate:(NSDictionary *)dic;

/**
 *  新增或更新多筆.
 *
 *  @param dics 多筆資料.
 */
- (void)createOrUpdateMultiple:(NSArray <NSDictionary *> *)dics;

/**
 *  刪除 by filter.
 *
 *  @param filter 刪除的 filter.
 */
- (void)deleteWithFilter:(NSPredicate *)filter;

/**
 *  刪除全部.
 */
- (void)deletaAll;

/**
 *  查詢 by filter.
 *
 *  @param filter 查詢的 filter.
 *
 *  @return 返回查詢資料.
 */
- (nullable NSArray <NSMutableDictionary *> *)queryWithFileter:(NSPredicate *)filter;

/**
 *  查詢 by range.
 *
 *  @param range 查詢的 range.
 *
 *  @return 返回查詢的資料
 */
- (nullable NSArray <NSMutableDictionary *> *)queryWithRange:(NSRange)range;

/**
 *  查詢全部.
 *
 *  @return 返回查詢的資料.
 */
- (nullable NSArray <NSMutableDictionary *> *)queryAll;

/**
 *  儲存, 寫入 Sanbox folder.
 */
- (void)save;

@end

NS_ASSUME_NONNULL_END
