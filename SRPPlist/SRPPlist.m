//
//  Copyright (c) 2017 shinren.pan@gmail.com All rights reserved.
//

#import "SRPPlist.h"
#import "SRPPlist+Disk.h"
#import "SRPPlist+Cache.h"


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
        [self cache_reload];
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
        return [self cache_add:dic];
    }
    
    return [self disk_add:dic];
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
        return [self cache_update:dic where:filter];
    }
    
    return [self disk_update:dic where:filter];
}

#pragma mark 新增 or 修改
- (BOOL)createOrUpdate:(NSDictionary *)dic where:(NSPredicate *)filter
{
    if(_cache)
    {
        return [self cache_createOrUpdate:dic where:filter];
    }
    
    return [self disk_createOrUpdate:dic where:filter];
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
    if(_cache)
    {
        return [self cache_removeWhere:filter];
    }
    
    return [self disk_removeWhere:filter];
}

#pragma mark 刪除全部
- (BOOL)removeAll
{
    if(_cache)
    {
        return [self cache_removeAll];
    }
    
    return [self disk_removeAll];
}

#pragma mark 查詢
- (NSArray<NSMutableDictionary *> *)queryWhere:(NSPredicate *)filter sort:(NSArray<NSSortDescriptor *> *)sort
{
    if(_cache)
    {
        return [[self cache_queryWhere:filter sort:sort]copy];
    }
    
    return [[self disk_queryWhere:filter sort:sort]copy];
}

#pragma mark 查詢全部
- (NSArray<NSMutableDictionary *> *)queryAllSort:(NSArray<NSSortDescriptor *> *)sort
{
    if(_cache)
    {
        return [[self cache_queryAllSort:sort]copy];
    }
    
    return [[self disk_queryAllSort:sort]copy];
}

#pragma mark 儲存 Cache
- (BOOL)save
{
    return [self cache_save];
}

#pragma mark Reload Cahce
- (void)reload
{
    [self cache_reload];
}

#pragma mark - Private
#pragma mark 初始設置
- (void)__setup
{
    NSString *rootPath = [self disk_rootPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:rootPath])
    {
        [[NSFileManager defaultManager]createDirectoryAtPath:rootPath
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:nil];
    }
    
    NSString *plistPath = [self disk_plistPath];
    
    if(![NSArray arrayWithContentsOfFile:plistPath])
    {
        NSMutableArray *array = [NSMutableArray array];
        
        [self disk_save:array];
    }
}

@end
