//
//  SRPPlist+Cache.m
//  SRPPlist
//
//  Created by dev1 on 2017/1/12.
//  Copyright © 2017年 ShinrenPan. All rights reserved.
//

#import "SRPPlist+Disk.h"
#import "SRPPlist+Cache.h"


@interface SRPPlist ()

@property (nonatomic, copy) NSMutableArray <NSMutableDictionary *> *cacheDatas;

@end


@implementation SRPPlist (Cache)

- (BOOL)cache_add:(NSDictionary *)dic
{
    NSMutableDictionary *mDic = [dic mutableCopy];
    mDic[@"Id"] = [NSUUID UUID].UUIDString;
    mDic[@"update"] = @([NSDate date].timeIntervalSince1970);
    
    [self.cacheDatas addObject:mDic];
    
    return YES;
}

- (BOOL)cache_update:(NSDictionary *)dic where:(NSPredicate *)filter
{
    NSArray *filterArray = [self.cacheDatas filteredArrayUsingPredicate:filter];
    
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

- (BOOL)cache_createOrUpdate:(NSDictionary *)dic where:(NSPredicate *)filter
{
    if(!filter)
    {
        return [self cache_add:dic];
    }
    
    NSArray *filterArray = [self.cacheDatas filteredArrayUsingPredicate:filter];
    
    if(!filterArray.count)
    {
        return [self cache_add:dic];
    }
    
    return [self cache_update:dic where:filter];
}

- (BOOL)cache_removeWhere:(NSPredicate *)filter
{
    NSArray *filterArray = [self.cacheDatas filteredArrayUsingPredicate:filter];
    
    if(!filterArray.count)
    {
        return NO;
    }
    
    [self.cacheDatas removeObjectsInArray:filterArray];
    
    return YES;
}

- (BOOL)cache_removeAll
{
    [self.cacheDatas removeAllObjects];
    
    return YES;
}

- (nullable NSArray <NSMutableDictionary *> *)cache_queryWhere:(NSPredicate *)filter sort:(nullable NSArray <NSSortDescriptor *> *)sort
{
    if(sort)
    {
        [self.cacheDatas sortUsingDescriptors:sort];
    }
    
    return [self.cacheDatas filteredArrayUsingPredicate:filter];
}

- (nullable NSArray <NSMutableDictionary *> *)cache_queryAllSort:(nullable NSArray <NSSortDescriptor *> *)sort
{
    if(sort)
    {
        [self.cacheDatas sortUsingDescriptors:sort];
    }
    
    return self.cacheDatas;
}

- (BOOL)cache_save
{
    if(!self.cache)
    {
        return NO;
    }
    
    return [self disk_save:self.cacheDatas];
}

- (void)cache_reload
{
    if(!self.cacheDatas)
    {
        self.cacheDatas = [NSMutableArray array];
    }
    else
    {
        [self.cacheDatas removeAllObjects];
    }
    
    NSString *plistPath = [self disk_plistPath];
    NSArray <NSDictionary *> *temp = [NSArray arrayWithContentsOfFile:plistPath];
    
    for(NSDictionary *dic in temp)
    {
        NSMutableDictionary *mDic = [dic mutableCopy];
        [self.cacheDatas addObject:mDic];
    }
}

@end
