//
//  SRPPlist+Disk.m
//  SRPPlist
//
//  Created by dev1 on 2017/1/12.
//  Copyright © 2017年 ShinrenPan. All rights reserved.
//

#import "SRPPlist+Disk.h"


@implementation SRPPlist (Disk)

- (BOOL)disk_add:(NSDictionary *)dic
{
    NSMutableArray *new = [NSMutableArray array];
    NSMutableArray *diskArray = [self disk_array];
    NSMutableDictionary *mDic = [dic mutableCopy];
    mDic[@"Id"] = [NSUUID UUID].UUIDString;
    mDic[@"update"] = @([NSDate date].timeIntervalSince1970);
    
    [diskArray addObject:mDic];
    [new addObject:[mDic copy]];
    
    BOOL result = [self disk_save:diskArray];
    
    if(result)
    {
        NSDictionary *userInfo = @{@"new": [new copy]};
        NSString *name = [NSString stringWithFormat:@"SRPPLIST_%@_ADD", self.name];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:name object:nil userInfo:userInfo];
    }
    
    return result;
}

- (BOOL)disk_update:(NSDictionary *)dic where:(NSPredicate *)filter
{
    NSMutableArray *diskArray = [self disk_array];
    NSArray *filterArray = [diskArray filteredArrayUsingPredicate:filter];
    
    if(filterArray.count == 0)
    {
        return NO;
    }
    
    NSMutableArray *old = [NSMutableArray array];
    NSMutableArray *new = [NSMutableArray array];
    
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
            
            [old addObject:[mDic copy]];
            
            mDic[key] = dic[key];
            
            [new addObject:[mDic copy]];
        }
    }
    
    if(!result)
    {
        return NO;
    }
    
    // Update = YES, but save to disk 還沒確定
    result = [self disk_save:diskArray];
    
    if(result)
    {
        NSDictionary *userInfo = @{@"old": [old copy], @"new": [new copy]};
        NSString *name = [NSString stringWithFormat:@"SRPPLIST_%@_UPDATE", self.name];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:name object:nil userInfo:userInfo];
    }
    
    return result;
}

- (BOOL)disk_createOrUpdate:(NSDictionary *)dic where:(NSPredicate *)filter
{
    if(!filter)
    {
        return [self disk_add:dic];
    }
    
    NSMutableArray *diskArray = [self disk_array];
    NSArray *filterArray = [diskArray filteredArrayUsingPredicate:filter];
    
    if(!filterArray.count)
    {
        return [self disk_add:dic];
    }
    
    return [self disk_update:dic where:filter];
}

- (BOOL)disk_removeWhere:(NSPredicate *)filter
{
    NSMutableArray *diskArray = [self disk_array];
    NSArray *filterArray      = [diskArray filteredArrayUsingPredicate:filter];
    
    if(!filterArray.count)
    {
        return NO;
    }
    
    NSArray *old = [filterArray copy];
    
    [diskArray removeObjectsInArray:filterArray];
    
    BOOL result = [self disk_save:diskArray];
    
    if(result)
    {
        NSDictionary *userInfo = @{@"old": [old copy]};
        NSString *name = [NSString stringWithFormat:@"SRPPLIST_%@_REMOVE", self.name];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:name object:nil userInfo:userInfo];
    }
    
    return result;
}

- (BOOL)disk_removeAll
{
    NSMutableArray *diskArray = [self disk_array];
    [diskArray removeAllObjects];
    
    BOOL result = [self disk_save:diskArray];
    
    if(result)
    {
        NSString *name = [NSString stringWithFormat:@"SRPPLIST_%@_REMOVEALL", self.name];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:name object:nil userInfo:nil];
    }
    
    return result;
}

- (NSArray<NSMutableDictionary *> *)disk_queryWhere:(NSPredicate *)filter sort:(NSArray<NSSortDescriptor *> *)sort
{
    NSMutableArray *diskArray = [self disk_array];
    
    if(sort)
    {
        [diskArray sortUsingDescriptors:sort];
    }
    
    return [diskArray filteredArrayUsingPredicate:filter];
}

- (NSArray<NSMutableDictionary *> *)disk_queryAllSort:(NSArray<NSSortDescriptor *> *)sort
{
    NSMutableArray *diskArray = [self disk_array];
    
    if(sort)
    {
        [diskArray sortUsingDescriptors:sort];
    }
    
    return diskArray;
}

#pragma mark Array from Disk
- (NSMutableArray<NSMutableDictionary *> *)disk_array
{
    NSMutableArray *result = [NSMutableArray array];
    
    NSString *plistPath = [self disk_plistPath];
    NSArray <NSDictionary *> *temp = [NSArray arrayWithContentsOfFile:plistPath];
    
    for(NSDictionary *dic in temp)
    {
        [result addObject:[dic mutableCopy]];
    }
    
    return result;
}

- (NSString *)disk_rootPath
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *result = [documentsDirectory stringByAppendingPathComponent:@"SRPPlist"];
    
    return result;
}

- (NSString *)disk_plistPath
{
    NSString *rootPath = [self disk_rootPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.plist", self.name];
    NSString *result   = [rootPath stringByAppendingPathComponent:fileName];
    
    return result;
}

- (BOOL)disk_save:(NSArray *)array
{
    NSString *plistPath = [self disk_plistPath];
    
    return [array writeToFile:plistPath atomically:YES];
}

@end
