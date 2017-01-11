//
//  Copyright (c) 2017 shinren.pan@gmail.com All rights reserved.
//

#import "SRPPlist.h"


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
    if(_cache)
    {
        return [self __cacheUpdate:dic];
    }
    
    return [self __diskUpdate:dic];
}

#pragma mark 刪除
- (BOOL)remove:(NSDictionary *)dic
{
    if(_cache)
    {
        return [self __cacheRemove:dic];
    }
    
    return [self __diskRemove:dic];
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
        return [self __cacheQueryByFileter:filter sortBy:sort];
    }
    
    return [self __diskQueryByFileter:filter sortBy:sort];
}

#pragma mark 查詢全部
- (NSArray<NSMutableDictionary *> *)queryAllSortBy:(NSArray<NSSortDescriptor *> *)sort
{
    if(_cache)
    {
        return [self __cacheQueryAllSortBy:sort];
    }
    
    return [self __diskQueryAllSortBy:sort];
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

#pragma mark Cache 新增
- (BOOL)__cacheAdd:(NSDictionary *)dic
{
    NSPredicate *filter  = [NSPredicate predicateWithFormat:@"Id == %@", dic[@"Id"]];
    NSArray *filterArray = [_cacheDatas filteredArrayUsingPredicate:filter];
    
    if(filterArray.count > 0)
    {
        return NO;
    }
    
    NSMutableDictionary *mDic = [dic mutableCopy];
    mDic[@"Id"] = [NSUUID UUID].UUIDString;
    mDic[@"update"] = @([NSDate date].timeIntervalSince1970);
    
    [_cacheDatas addObject:mDic];
    
    _statusChanged ? _statusChanged(SRPPlistStatusCacheAdd) : nil;
    
    return YES;
}

#pragma mark Disk 新增
- (BOOL)__diskAdd:(NSDictionary *)dic
{
    NSMutableArray *diskArray = [self __diskArray];
    NSPredicate *filter  = [NSPredicate predicateWithFormat:@"Id == %@", dic[@"Id"]];
    NSArray *filterArray = [diskArray filteredArrayUsingPredicate:filter];
    
    if(filterArray.count > 0)
    {
        return NO;
    }
    
    NSMutableDictionary *mDic = [dic mutableCopy];
    mDic[@"Id"] = [NSUUID UUID].UUIDString;
    mDic[@"update"] = @([NSDate date].timeIntervalSince1970);
    
    [diskArray addObject:mDic];
    
    BOOL result = [self __saveToDisk:diskArray];
    
    if(result)
    {
        _statusChanged ? _statusChanged(SRPPlistStatusDiskAdd) : nil;
    }
    
    return result;
}

#pragma mark Cache 修改
- (BOOL)__cacheUpdate:(NSDictionary *)dic
{
    NSPredicate *filter  = [NSPredicate predicateWithFormat:@"Id == %@", dic[@"Id"]];
    NSArray *filterArray = [_cacheDatas filteredArrayUsingPredicate:filter];
    
    if(filterArray.count != 1)
    {
        return NO;
    }
    
    NSMutableDictionary *mDic = filterArray.firstObject;
    [mDic setDictionary:dic];
    
    _statusChanged ? _statusChanged(SRPPlistStatusCacheUpdate) : nil;
    
    return YES;
}

#pragma mark Disk 修改
- (BOOL)__diskUpdate:(NSDictionary *)dic
{
    NSMutableArray *diskArray = [self __diskArray];
    NSPredicate *filter  = [NSPredicate predicateWithFormat:@"Id == %@", dic[@"Id"]];
    NSArray *filterArray = [diskArray filteredArrayUsingPredicate:filter];
    
    if(filterArray.count != 1)
    {
        return NO;
    }
    
    NSMutableDictionary *mDic = filterArray.firstObject;
    [mDic setDictionary:dic];
    
    BOOL result = [self __saveToDisk:diskArray];
    
    if(result)
    {
        _statusChanged ? _statusChanged(SRPPlistStatusDiskUpdate) : nil;
    }
    
    return result;
}

#pragma mark Cache 刪除
- (BOOL)__cacheRemove:(NSDictionary *)dic
{
    NSPredicate *filter  = [NSPredicate predicateWithFormat:@"Id == %@", dic[@"Id"]];
    NSArray *filterArray = [_cacheDatas filteredArrayUsingPredicate:filter];
    
    if(filterArray.count != 1)
    {
        return NO;
    }
    
    [_cacheDatas removeObjectsInArray:filterArray];
    
    _statusChanged ? _statusChanged(SRPPlistStatusCacheRemove) : nil;
    
    return YES;
}

#pragma mark Disk 刪除
- (BOOL)__diskRemove:(NSDictionary *)dic
{
    NSMutableArray *diskArray = [self __diskArray];
    NSPredicate *filter  = [NSPredicate predicateWithFormat:@"Id == %@", dic[@"Id"]];
    NSArray *filterArray = [diskArray filteredArrayUsingPredicate:filter];
    
    if(filterArray.count != 1)
    {
        return NO;
    }
    
    [diskArray removeObjectsInArray:filterArray];
    
    BOOL result = [self __saveToDisk:diskArray];
    
    if(result)
    {
        _statusChanged ? _statusChanged(SRPPlistStatusDiskRemove) : nil;
    }
    
    return result;
}

#pragma mark Cache 刪除全部
- (BOOL)__cacheRemoveAll
{
    [_cacheDatas removeAllObjects];
    _statusChanged ? _statusChanged(SRPPlistStatusCacheRemoveAll) : nil;
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
        _statusChanged ? _statusChanged(SRPPlistStatusDiskRemoveAll) : nil;
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
