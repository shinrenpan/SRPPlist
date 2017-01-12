//
//  Copyright (c) 2017 shinren.pan@gmail.com All rights reserved.
//

#import "SRPPlist.h"

NSString * const SRPPlistDiskStatusNotificaion = @"SRPPlistDiskStatusNotificaion";


@interface SRPPlist ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSMutableArray <NSMutableDictionary *> *cacheDatas;

@end


@implementation SRPPlist

#pragma mark - LifeCycle
- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    
    if(self)
    {
        _name = name;
        
        [self __setup];
        [self setCache:YES];
    }
    
    return self;
}

#pragma mark - Properties Setter
#pragma mark Set cache
- (void)setCache:(BOOL)cache
{
    _cache = cache;
    
    if(_cache)
    {
        [self __setupCacheData];
    }
    else
    {
        _cacheDatas = nil;
    }
}

#pragma mark - Public
#pragma mark 新增 or 修改
- (BOOL)createOrUpdate:(NSDictionary *)dic where:(NSPredicate *)filter
{
    if(_cache)
    {
        return [self __cacheCreateOrUpdate:dic where:filter];
    }
    
    return [self __diskCreateOrUpdate:dic where:filter];
}

#pragma mark 新增
- (BOOL)add:(NSDictionary *)dic
{
    if(_cache)
    {
        return [self __cacheAdd:dic];
    }
    
    return [self __diskAdd:dic];
}

#pragma mark 修改
- (BOOL)update:(NSDictionary *)dic
{
    if(!dic[@"Id"])
    {
        return NO;
    }
    
    NSPredicate *filter  = [NSPredicate predicateWithFormat:@"Id == %@", dic[@"Id"]];
    
    
    return [self update:dic where:filter];
}

#pragma mark 修改 by Filter
- (BOOL)update:(NSDictionary *)dic where:(NSPredicate *)filter
{
    if(_cache)
    {
        return [self __cacheUpdate:dic where:filter];
    }
    
    return [self __diskUpdate:dic where:filter];
}

#pragma mark 刪除
- (BOOL)remove:(NSDictionary *)dic
{
    if(!dic[@"Id"])
    {
        return NO;
    }
    
    NSPredicate *filter  = [NSPredicate predicateWithFormat:@"Id == %@", dic[@"Id"]];
    
    return [self removeByFilter:filter];
}

#pragma mark 刪除 By 條件
- (BOOL)removeByFilter:(NSPredicate *)filter
{
    if(_cache)
    {
        return [self __cacheRemoveByFilter:filter];
    }
    
    return [self __diskRemoveByFilter:filter];
}

#pragma mark 刪除全部
- (BOOL)removeAll
{
    if(_cache)
    {
        return [self __cacheRemoveAll];
    }
    
    return [self __diskRemoveAll];
}

#pragma mark 查詢
- (NSArray<NSMutableDictionary *> *)queryByFileter:(NSPredicate *)filter sortBy:(NSArray<NSSortDescriptor *> *)sort
{
    if(_cache)
    {
        return [[self __cacheQueryByFileter:filter sortBy:sort]copy];
    }
    
    return [[self __diskQueryByFileter:filter sortBy:sort]copy];
}

#pragma mark 查詢全部
- (NSArray<NSMutableDictionary *> *)queryAllSortBy:(NSArray<NSSortDescriptor *> *)sort
{
    if(_cache)
    {
        return [[self __cacheQueryAllSortBy:sort]copy];
    }
    
    return [[self __diskQueryAllSortBy:sort]copy];
}

#pragma mark 儲存 Cache
- (BOOL)saveCache
{
    if(!_cache)
    {
        return NO;
    }
    
    return [self __saveToDisk:_cacheDatas];
}

#pragma mark Reload Cahce
- (void)reloadCache
{
    [self __setupCacheData];
}

#pragma mark - Private
#pragma mark 初始設置
- (void)__setup
{
    NSString *rootPath = [self __rootPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:rootPath])
    {
        [[NSFileManager defaultManager]createDirectoryAtPath:rootPath
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:nil];
    }
    
    NSString *plistPath = [self __plistPath];
    
    if(![NSArray arrayWithContentsOfFile:plistPath])
    {
        NSMutableArray *array = [NSMutableArray array];
        
        [self __saveToDisk:array];
    }
}

#pragma mark 設置 CacheData
- (void)__setupCacheData
{
    if(!_cacheDatas)
    {
        _cacheDatas = [NSMutableArray array];
    }
    else
    {
        [_cacheDatas removeAllObjects];
    }
    
    NSString *plistPath = [self __plistPath];
    NSArray <NSDictionary *> *temp = [NSArray arrayWithContentsOfFile:plistPath];
    
    for(NSDictionary *dic in temp)
    {
        NSMutableDictionary *mDic = [dic mutableCopy];
        [_cacheDatas addObject:mDic];
    }
}

#pragma mark Cache create or update
- (BOOL)__cacheCreateOrUpdate:(NSDictionary *)dic where:(NSPredicate *)filter
{
    if(!filter)
    {
        return [self __cacheAdd:dic];
    }
    
    NSArray *filterArray = [_cacheDatas filteredArrayUsingPredicate:filter];
    
    if(!filterArray.count)
    {
        return [self __cacheAdd:dic];
    }
    
    return [self __cacheUpdate:dic where:filter];
}

#pragma mark disk create or update
- (BOOL)__diskCreateOrUpdate:(NSDictionary *)dic where:(NSPredicate *)filter
{
    if(!filter)
    {
        return [self __diskAdd:dic];
    }
    
    NSMutableArray *diskArray = [self __diskArray];
    NSArray *filterArray = [diskArray filteredArrayUsingPredicate:filter];
    
    if(!filterArray.count)
    {
        return [self __diskAdd:dic];
    }
    
    return [self __diskUpdate:dic where:filter];
}

#pragma mark Cache 新增
- (BOOL)__cacheAdd:(NSDictionary *)dic
{
    NSMutableDictionary *mDic = [dic mutableCopy];
    mDic[@"Id"] = [NSUUID UUID].UUIDString;
    mDic[@"update"] = @([NSDate date].timeIntervalSince1970);
    
    [_cacheDatas addObject:mDic];
    
    return YES;
}

#pragma mark Disk 新增
- (BOOL)__diskAdd:(NSDictionary *)dic
{
    NSMutableArray *diskArray = [self __diskArray];
    NSMutableDictionary *mDic = [dic mutableCopy];
    mDic[@"Id"] = [NSUUID UUID].UUIDString;
    mDic[@"update"] = @([NSDate date].timeIntervalSince1970);
    
    [diskArray addObject:mDic];
    
    BOOL result = [self __saveToDisk:diskArray];
    
    if(result)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:SRPPlistDiskStatusNotificaion
                                                           object:@(SRPPlistDiskStatusAdd)];
    }
    
    return result;
}

#pragma mark Cache 修改
- (BOOL)__cacheUpdate:(NSDictionary *)dic where:(NSPredicate *)filter
{
    if(!filter)
    {
        filter = [NSPredicate predicateWithFormat:@"Id == %@", dic[@"Id"]];
    }

    NSArray *filterArray = [_cacheDatas filteredArrayUsingPredicate:filter];
    
    if(filterArray.count == 0)
    {
        return NO;
    }
    
    BOOL result = NO;
    
    for(NSMutableDictionary *mDic in filterArray)
    {
        for(NSString *key in [dic allKeys])
        {
            if(mDic[key] == dic[key] || [mDic[key]isEqual:dic[key]])
            {
                continue;
            }
        
            result = YES;
            mDic[key] = dic[key];
        }
    }
    
    return result;
}

#pragma mark Disk 修改
- (BOOL)__diskUpdate:(NSDictionary *)dic where:(NSPredicate *)filter
{
    if(!filter)
    {
        filter = [NSPredicate predicateWithFormat:@"Id == %@", dic[@"Id"]];
    }
    
    NSMutableArray *diskArray = [self __diskArray];
    NSArray *filterArray = [diskArray filteredArrayUsingPredicate:filter];
    
    if(filterArray.count == 0)
    {
        return NO;
    }
    
    BOOL result = NO;
    
    for(NSMutableDictionary *mDic in filterArray)
    {
        for(NSString *key in [dic allKeys])
        {
            if(mDic[key] == dic[key] || [mDic[key]isEqual:dic[key]] || [mDic[key]hash] == [dic[key]hash])
            {
                continue;
            }
        
            result = YES;
            mDic[key] = dic[key];
        }
    }
    
    if(!result)
    {
        return NO;
    }
    
    // Update = YES, but save to disk 還沒確定
    result = [self __saveToDisk:diskArray];
    
    if(result)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:SRPPlistDiskStatusNotificaion
                                                           object:@(SRPPlistDiskStatusUpdate)];
    }
    
    return result;
}

#pragma mark Cache 刪除
- (BOOL)__cacheRemoveByFilter:(NSPredicate *)filter
{
    //NSPredicate *filter  = [NSPredicate predicateWithFormat:@"Id == %@", dic[@"Id"]];
    NSArray *filterArray = [_cacheDatas filteredArrayUsingPredicate:filter];
    
    if(!filterArray.count)
    {
        return NO;
    }
    
    [_cacheDatas removeObjectsInArray:filterArray];
    
    return YES;
}

#pragma mark Disk 刪除
- (BOOL)__diskRemoveByFilter:(NSPredicate *)filter
{
    NSMutableArray *diskArray = [self __diskArray];
    NSArray *filterArray      = [diskArray filteredArrayUsingPredicate:filter];
    
    if(!filterArray.count)
    {
        return NO;
    }
    
    [diskArray removeObjectsInArray:filterArray];
    
    BOOL result = [self __saveToDisk:diskArray];
    
    if(result)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:SRPPlistDiskStatusNotificaion
                                                           object:@(SRPPlistDiskStatusRemove)];
    }
    
    return result;
}

#pragma mark Cache 刪除全部
- (BOOL)__cacheRemoveAll
{
    [_cacheDatas removeAllObjects];
    
    return YES;
}

#pragma mark Disk 刪除全部
- (BOOL)__diskRemoveAll
{
    NSMutableArray *diskArray = [self __diskArray];
    [diskArray removeAllObjects];
    
    BOOL result = [self __saveToDisk:diskArray];
    
    if(result)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:SRPPlistDiskStatusNotificaion
                                                           object:@(SRPPlistDiskStausRemoveAll)];
    }
    
    return result;
}

#pragma mark Cache 查詢
- (NSArray<NSMutableDictionary *> *)__cacheQueryByFileter:(NSPredicate *)filter sortBy:(NSArray<NSSortDescriptor *> *)sort
{
    if(sort)
    {
        [_cacheDatas sortUsingDescriptors:sort];
    }
    
    return [_cacheDatas filteredArrayUsingPredicate:filter];
}

#pragma mark Disk 查詢
- (NSArray<NSMutableDictionary *> *)__diskQueryByFileter:(NSPredicate *)filter sortBy:(NSArray<NSSortDescriptor *> *)sort
{
    NSMutableArray *diskArray = [self __diskArray];
    
    if(sort)
    {
        [diskArray sortUsingDescriptors:sort];
    }
    
    return [diskArray filteredArrayUsingPredicate:filter];
}

#pragma mark Cache 查詢全部
- (NSArray<NSMutableDictionary *> *)__cacheQueryAllSortBy:(NSArray<NSSortDescriptor *> *)sort
{
    if(sort)
    {
        [_cacheDatas sortUsingDescriptors:sort];
    }
    
    return _cacheDatas;
}

#pragma mark Disk 查詢全部
- (NSArray<NSMutableDictionary *> *)__diskQueryAllSortBy:(NSArray<NSSortDescriptor *> *)sort
{
    NSMutableArray *diskArray = [self __diskArray];
    
    if(sort)
    {
        [diskArray sortUsingDescriptors:sort];
    }
    
    return diskArray;
}

#pragma mark 儲存
- (BOOL)__saveToDisk:(NSArray *)array
{
    NSString *plistPath = [self __plistPath];
    
    return [array writeToFile:plistPath atomically:YES];
}

#pragma mark Root path
- (NSString *)__rootPath
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *result = [documentsDirectory stringByAppendingPathComponent:@"SRPPlist"];
    
    return result;
}

#pragma mark Plist path
- (NSString *)__plistPath
{
    NSString *rootPath = [self __rootPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.plist", _name];
    NSString *result   = [rootPath stringByAppendingPathComponent:fileName];
    
    return result;
}

#pragma mark Array from Disk
- (NSMutableArray *)__diskArray
{
    NSMutableArray *result = [NSMutableArray array];
    
    NSString *plistPath = [self __plistPath];
    NSArray <NSDictionary *> *temp = [NSArray arrayWithContentsOfFile:plistPath];
    
    for(NSDictionary *dic in temp)
    {
        [result addObject:[dic mutableCopy]];
    }
    
    return result;
}

@end
