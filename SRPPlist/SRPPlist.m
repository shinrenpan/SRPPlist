//
//  Copyright (c) 2017 shinren.pan@gmail.com All rights reserved.
//

#import "SRPPlist.h"


@interface SRPPlist ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSMutableArray <NSMutableDictionary *> *datas;

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

#pragma mark - Public
#pragma mark 新增或更新
- (void)createOrUpdate:(NSDictionary *)dic
{
    if(!dic[@"Id"])
    {
        [self __addDic:dic];
        return;
    }
    
    NSPredicate *filter  = [NSPredicate predicateWithFormat:@"Id == %@", dic[@"Id"]];
    NSArray *filterArray = [_datas filteredArrayUsingPredicate:filter];
    
    if(!filterArray.count)
    {
        [self __addDic:dic];
        return;
    }
    
    NSMutableDictionary *mDic = filterArray.firstObject;
    [mDic setDictionary:dic];
}

#pragma mark 刪除
- (void)deleteWithFilter:(NSPredicate *)filter
{
    NSArray *filterArray = [_datas filteredArrayUsingPredicate:filter];
    
    [_datas removeObjectsInArray:filterArray];
}

#pragma mark 刪除全部
- (void)deletaAll
{
    [_datas removeAllObjects];
}

#pragma mark 查詢 by filter
- (NSArray<NSMutableDictionary *> *)queryWithFileter:(NSPredicate *)filter
{
    NSArray *filterArray = [_datas filteredArrayUsingPredicate:filter];
    
    return (filterArray.count) ? filterArray : nil;
}

#pragma mark 查詢 by range
- (NSArray <NSMutableDictionary *> *)queryWithRange:(NSRange)range
{
    return (range.location + range.length > _datas.count) ? nil : [_datas subarrayWithRange:range];
}

#pragma mark 查詢全部
- (NSArray <NSMutableDictionary *> *)queryAll
{
    return _datas.count ? _datas : nil;
}

#pragma mark 儲存
- (void)save
{
    NSString *collectionPath = [self __plistPath];
    
    [_datas writeToFile:collectionPath atomically:YES];
}

#pragma mark - Private
#pragma mark 新增
- (void)__addDic:(NSDictionary *)dic
{
    NSMutableDictionary *mDic = [dic mutableCopy];
    mDic[@"Id"] = [NSUUID UUID].UUIDString;
    mDic[@"update"] = @([NSDate date].timeIntervalSince1970);
    
    [_datas addObject:mDic];
}

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
    
    if(![fileManager fileExistsAtPath:plistPath])
    {
        _datas = [NSMutableArray array];
    }
    else
    {
        _datas = [NSMutableArray array];
        
        NSArray *array = [NSArray arrayWithContentsOfFile:plistPath];
        
        for(NSDictionary *dic in array)
        {
            NSMutableDictionary *mDic = [dic mutableCopy];
            
            [_datas addObject:mDic];
        }
    }
}

#pragma mark Root path
- (NSString *)__rootPath
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"SRPPlist"];
    
    return databasePath;
}

#pragma mark Plist path
- (NSString *)__plistPath
{
    NSString *databasePath = [self __rootPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.plist", _name];
    NSString *collectionPath = [databasePath stringByAppendingPathComponent:fileName];
    
    return collectionPath;
}

@end
