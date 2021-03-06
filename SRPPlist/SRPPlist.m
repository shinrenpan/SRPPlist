//
//  Copyright (c) 2017 shinren.pan@gmail.com All rights reserved.
//

#import "SRPPlist.h"


@implementation SRPPlist

#pragma mark - Class methods
#pragma mark 查詢
+ (nullable NSArray<NSDictionary *> *)plist:(nonnull NSString *)name
                                 queryWhere:(nullable NSPredicate *)where
                                    orderBy:(nullable NSArray<NSSortDescriptor *> *)orders
{
    // Plist 檔案不存在, 查詢沒有意義, return nil
    if(![self __plistExist:name])
    {
        return nil;
    }
    
    NSMutableArray *results = [self __allFrom:name forMutableDictionary:NO];
    
    if(where)
    {
        [results filterUsingPredicate:where];
    }
    
    if(orders)
    {
        [results sortUsingDescriptors:orders];
    }
    
    // 返回的是 NSArray 所以 copy
    return [results copy];
}

#pragma mark 新增
+ (BOOL)plist:(nonnull NSString *)name insert:(nonnull NSArray<NSDictionary *> *)dics
{
    NSMutableArray *all = [self __allFrom:name forMutableDictionary:NO];
    
    [all addObjectsFromArray:dics];
    
    return [self __save:all toPlist:name];
}

#pragma mark 修改
+ (BOOL)plist:(nonnull NSString *)name update:(nonnull NSDictionary *)dic where:(nonnull NSPredicate *)where
{
    // Plist 檔案不存在, update 沒有意義
    if(![self __plistExist:name])
    {
        return NO;
    }
    
    NSMutableArray *all  = [self __allFrom:name forMutableDictionary:YES];
    NSArray *filterArray = [all filteredArrayUsingPredicate:where];
    
    // where 不成立
    if(filterArray.count == 0)
    {
        return NO;
    }
    
    for (NSMutableDictionary *mDic in filterArray)
    {
        [mDic addEntriesFromDictionary:dic];
    }
    
    return [self __save:all toPlist:name];
}

#pragma mark 刪除
+ (BOOL)plist:(NSString *)name removeWhere:(NSPredicate *)where
{
    // Plist 檔案不存在, remove 沒有意義, 就當作刪除成功吧
    if(![self __plistExist:name])
    {
        return YES;
    }
    
    NSMutableArray *all  = [self __allFrom:name forMutableDictionary:NO];
    NSArray *filterArray = [all filteredArrayUsingPredicate:where];
    
    // where 不成立
    if(!filterArray.count)
    {
        return NO;
    }
    
    [all removeObjectsInArray:filterArray];
    
    if(!all.count)
    {
        return [self dropPlist:name];
    }
    
    return [self __save:all toPlist:name];
}

#pragma mark 移除 plist 檔案
+ (BOOL)dropPlist:(nonnull NSString *)name
{
    // Plist 檔案不存在, drop 沒有意義, 就當作 drop 成功吧
    if(![self __plistExist:name])
    {
        return YES;
    }
    
    NSString *plsitPath = [self __plistPathWith:name];
    
    return [[NSFileManager defaultManager]removeItemAtPath:plsitPath error:nil];
}

#pragma mark - Privare
#pragma mark 根目錄
+ (nonnull NSString *)__rootPath
{
    NSString *documentsDirectory =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    
    NSString *result = [documentsDirectory stringByAppendingPathComponent:@"com.shinrenpan.SRPPlist"];
    
    return result;
}

#pragma mark 根目錄是否存在
+ (BOOL)__rootPathExist
{
    return [[NSFileManager defaultManager]fileExistsAtPath:[self __rootPath]];
}

#pragma mark Plist 檔案路徑
+ (nonnull NSString *)__plistPathWith:(NSString *)name
{
    // 怕 user 有時會建副檔名, 有時不會, 就統一清掉再幫他建.
    name = [name stringByReplacingOccurrencesOfString:@".plist" withString:@""];
    
    NSString *rootPath = [self __rootPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.plist", name];
    NSString *result   = [rootPath stringByAppendingPathComponent:fileName];
    
    return result;
}

#pragma mark Plist 檔案是否存在
+ (BOOL)__plistExist:(nonnull NSString *)name
{
    return [[NSFileManager defaultManager]fileExistsAtPath:[self __plistPathWith:name]];
}

#pragma mark 存到 Plist
+ (BOOL)__save:(nonnull NSMutableArray *)array toPlist:(nonnull NSString *)name
{
    // 如果根目錄不存在
    if(![self __rootPathExist])
    {
        [[NSFileManager defaultManager]createDirectoryAtPath:[self __rootPath]
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:nil];
    }
    
    NSString *plistPath = [self __plistPathWith:name];
    
    return [array writeToFile:plistPath atomically:YES];
}

#pragma mark Plist 裡全部資料
+ (nonnull NSMutableArray <NSDictionary *> *)__allFrom:(nonnull NSString *)name forMutableDictionary:(BOOL)mutable
{
    NSString *plistPath = [self __plistPathWith:name];
    NSArray <NSDictionary *> *temp = [NSArray arrayWithContentsOfFile:plistPath];
    
    NSMutableArray *results;
    
    if(!mutable)
    {
        results = [NSMutableArray arrayWithArray:temp];
        
        return results;
    }
    
    // 可能需要 update, 所以將 plist 裡的 NSDictionary 轉成 NSMutableDictionary
    results = [NSMutableArray array];
    
    for(NSDictionary *dic in temp)
    {
        [results addObject:[dic mutableCopy]];
    }
    
    return results;
}

@end
