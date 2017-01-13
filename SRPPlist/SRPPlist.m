//
//  Copyright (c) 2017 shinren.pan@gmail.com All rights reserved.
//

#import "SRPPlist.h"


@interface SRPPlist ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSMutableArray <NSMutableDictionary *> *cacheData;

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
    }
    
    return self;
}

- (void)setCache:(BOOL)cache
{
    _cache = cache;
    
    if(_cache)
    {
        _cacheData = [[self __diskArray]mutableCopy];
    }
    else
    {
        _cacheData = nil;
    }
}

#pragma mark - Public
#pragma mark 新增
- (BOOL)add:(NSDictionary *)dic
{
    NSMutableArray *new = [NSMutableArray array];
    NSMutableArray *diskArray = [self __diskArray];
    NSMutableDictionary *mDic = [dic mutableCopy];
    mDic[@"Id"] = [NSUUID UUID].UUIDString;
    mDic[@"update"] = @([NSDate date].timeIntervalSince1970);
    
    [diskArray addObject:mDic];
    [new addObject:[mDic copy]];
    
    if(_cache)
    {
        return NO;
    }
    
    BOOL result = [self __save:diskArray];
    
    if(result)
    {
        NSDictionary *userInfo = @{@"new": [new copy]};
        NSString *name = [NSString stringWithFormat:@"SRPPLIST_%@_ADD", _name];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:name object:nil userInfo:userInfo];
    }
    
    return result;
}

- (BOOL)addMultiple:(NSArray<NSDictionary *> *)dics
{
    NSMutableArray *diskArray = [self __diskArray];
    
    NSInteger count = 0;
    
    for(id dic in dics)
    {
        if(![dic isKindOfClass:[NSDictionary class]])
        {
            continue;
        }
        
        NSMutableDictionary *mDic = [dic mutableCopy];
        
        mDic[@"Id"] = [NSUUID UUID].UUIDString;
        mDic[@"update"] = @([NSDate date].timeIntervalSince1970);
        
        [diskArray addObject:mDic];
        
        count++;
    }
    
    if(_cache)
    {
        return NO;
    }
    
    if(count == 0)
    {
        return NO;
    }
    
    return [self __save:diskArray];
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
    NSMutableArray *diskArray = [self __diskArray];
    NSArray *filterArray = [diskArray filteredArrayUsingPredicate:filter];
    
    if(filterArray.count == 0)
    {
        return NO;
    }
    
    NSMutableArray *old = [NSMutableArray array];
    NSMutableArray *new = [NSMutableArray array];
    
    BOOL updated = NO;
    
    for(NSMutableDictionary *mDic in filterArray)
    {
        [old addObject:[mDic copy]];
        
        for(NSString *key in [dic allKeys])
        {
            if([key isEqualToString:@"Id"])
            {
                continue;
            }
            
            if(mDic[key] == dic[key])
            {
                continue;
            }
            
            if([mDic[key]isEqual:dic[key]])
            {
                continue;
            }
            
            if([mDic[key]hash] == [dic[key]hash])
            {
                continue;
            }
            
            updated = YES;
            
            mDic[key] = dic[key];
        }
        
        if(updated)
        {
            mDic[@"update"] = @([NSDate date].timeIntervalSince1970);
            [new addObject:[mDic copy]];
        }
        else
        {
            [old removeLastObject];
        }
    }
    
    if(_cache)
    {
        return NO;
    }
    
    if(!updated)
    {
        new = nil;
        old = nil;
        return NO;
    }
    
    // Update = YES, but save to disk 還沒確定
    updated = [self __save:diskArray];
    
    if(updated)
    {
        NSDictionary *userInfo = @{@"old": [old copy], @"new": [new copy]};
        NSString *name = [NSString stringWithFormat:@"SRPPLIST_%@_UPDATE", self.name];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:name object:nil userInfo:userInfo];
    }
    
    return updated;
}

#pragma mark 新增 or 修改
- (BOOL)createOrUpdate:(NSDictionary *)dic where:(NSPredicate *)filter
{
    if(!filter)
    {
        return [self add:dic];
    }
    
    NSMutableArray *diskArray = [self __diskArray];
    NSArray *filterArray = [diskArray filteredArrayUsingPredicate:filter];
    
    if(!filterArray.count)
    {
        return [self add:dic];
    }
    
    return [self update:dic where:filter];
}

#pragma mark 刪除
- (BOOL)remove:(NSDictionary *)dic
{
    if(!dic[@"Id"])
    {
        return NO;
    }
    
    NSPredicate *filter  = [NSPredicate predicateWithFormat:@"Id == %@", dic[@"Id"]];
    
    return [self removeWhere:filter];
}

#pragma mark 刪除 By 條件
- (BOOL)removeWhere:(NSPredicate *)filter
{
    NSMutableArray *diskArray = [self __diskArray];
    NSArray *filterArray      = [diskArray filteredArrayUsingPredicate:filter];
    
    if(!filterArray.count)
    {
        return NO;
    }
    
    NSArray *old = [filterArray copy];
    
    [diskArray removeObjectsInArray:filterArray];
    
    if(_cache)
    {
        return NO;
    }
    
    BOOL result = [self __save:diskArray];
    
    if(result)
    {
        NSDictionary *userInfo = @{@"old": [old copy]};
        NSString *name = [NSString stringWithFormat:@"SRPPLIST_%@_REMOVE", self.name];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:name object:nil userInfo:userInfo];
    }
    
    return result;
}

#pragma mark 刪除全部
- (BOOL)removeAll
{
    NSMutableArray *diskArray = [self __diskArray];
    [diskArray removeAllObjects];
    
    if(_cache)
    {
        return NO;
    }
    
    BOOL result = [self __save:diskArray];
    
    if(result)
    {
        NSString *name = [NSString stringWithFormat:@"SRPPLIST_%@_REMOVEALL", self.name];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:name object:nil userInfo:nil];
    }
    
    return result;
}

#pragma mark 查詢
- (NSArray<NSMutableDictionary *> *)queryWhere:(NSPredicate *)filter sort:(NSArray<NSSortDescriptor *> *)sort
{
    NSMutableArray *diskArray = [self __diskArray];
    NSMutableArray *results   = [[diskArray filteredArrayUsingPredicate:filter]mutableCopy];
    
    if(sort)
    {
        [results sortUsingDescriptors:sort];
    }
    
    return [results copy];
}

#pragma mark 查詢全部
- (NSArray<NSMutableDictionary *> *)queryAllSort:(NSArray<NSSortDescriptor *> *)sort
{
    NSMutableArray *diskArray = [self __diskArray];
    
    if(sort)
    {
        [diskArray sortUsingDescriptors:sort];
    }
    
    return [diskArray copy];
}

#pragma mark Save cache
- (BOOL)save
{
    if(!_cache || !_cacheData.count)
    {
        return NO;
    }
    
    return [self __save:_cacheData];
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
        
        [self __save:array];
    }
}

#pragma mark Array from disk
- (NSMutableArray<NSMutableDictionary *> *)__diskArray
{
    if(_cache && _cacheData)
    {
        return _cacheData;
    }
    
    NSMutableArray *results = [NSMutableArray array];
    
    NSString *plistPath = [self __plistPath];
    NSArray <NSDictionary *> *temp = [NSArray arrayWithContentsOfFile:plistPath];
    
    for(NSDictionary *dic in temp)
    {
        [results addObject:[dic mutableCopy]];
    }
    
    return results;
}

#pragma mark 根目錄
- (NSString *)__rootPath
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *result = [documentsDirectory stringByAppendingPathComponent:@"SRPPlist"];
    
    return result;
}

#pragma mark Plist 檔案路徑
- (NSString *)__plistPath
{
    NSString *rootPath = [self __rootPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.plist", self.name];
    NSString *result   = [rootPath stringByAppendingPathComponent:fileName];
    
    return result;
}

#pragma mark Save to disk
- (BOOL)__save:(NSArray *)array
{
    NSString *plistPath = [self __plistPath];
    
    return [array writeToFile:plistPath atomically:YES];
}

@end
