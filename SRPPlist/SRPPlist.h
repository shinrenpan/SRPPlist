//
//  Copyright (c) 2017 shinren.pan@gmail.com All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 Plist as database.
 */
@interface SRPPlist : NSObject


///-----------------------------------------------------------------------------
/// @name Class methods
///-----------------------------------------------------------------------------

/**
 返回查詢資料.

 @param name Plist 名稱.
 @param where 過濾條件式, 當 where == nil 時, 返回全部查詢資料.
 @param orders 排序條件式.
 @return 返回查詢資料.
 */
+ (nullable NSArray <NSDictionary *> *)plist:(NSString *)name
                                  queryWhere:(nullable NSPredicate *)where
                                     orderBy:(nullable NSArray <NSSortDescriptor *> *)orders;

/**
 新增資料.

 @param name Plist 名稱.
 @param dics 新增的資料.
 @return 返回新增資料成功與否.
 */
+ (BOOL)plist:(NSString *)name insert:(NSArray <NSDictionary *> *)dics;

/**
 修改資料.

 @param name Plist 名稱.
 @param dic 修改的資料.
 @param where 過濾條件式.
 @return 返回修改資料成功與否.
 */
+ (BOOL)plist:(NSString *)name update:(NSDictionary *)dic where:(NSPredicate *)where;

/**
 刪除資料.

 當刪除後, 沒有資料時, 將觸發 dropPlist
 
 @param name Plist 名稱.
 @param where 過濾條件式.
 @return 返回刪除資料成功與否.
 */
+ (BOOL)plist:(NSString *)name removeWhere:(NSPredicate *)where;

/**
 移除 plist.

 注意, 將會把 plist 檔案砍掉.
 
 @param name Plist 名稱.
 @return 返回移除 plist 成功與否.
 */
+ (BOOL)dropPlist:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
