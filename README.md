# SRPPlist #
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Plist as database.

**注意事項**

1. Not thread safe.
2. 只接受 plist 可儲存的格式:
   - NSString
   - NSNumber
   - NSArray
   - NSDictionary
   - NSDate
   - NSData

## 安裝 ##
使用 [Carthage](https://github.com/Carthage/Carthage) 安裝.


## 使用 ##



### 查詢 ###

```objc
+ (nullable NSArray <NSDictionary *> *)queryFromPlist:(NSString *)name
                                                where:(nullable NSPredicate *)where
                                              orderBy:(nullable NSArray <NSSortDescriptor *> *)orders;
```

其中

- name: plist 名稱.
- where: 過濾條件.
- orders: 排序條件.

當 **`where == nil`** 時, 將返回全部查詢.


### 新增 ###

```objc
+ (BOOL)plist:(NSString *)name insert:(NSArray <NSDictionary *> *)dics;
```

其中

- name: plist 名稱.
- dics: 要新增的資料, 單筆或多筆.

新增的資料將自動產生 **`id`** (NSUUID string), **`update`** (NSDate NSTimeInterval) 欄位.

> 請保留 id, 與 update 欄位


### 修改 ###

```objc
+ (BOOL)plist:(NSString *)name update:(NSDictionary *)dic where:(NSPredicate *)where;
```

其中

- name: plist 名稱.
- dic: 要修改的資料.
- where: 過濾條件.

當 **`where 不成立`** 將返回修改失敗.


### 刪除 ###

```objc
+ (BOOL)removeFromPlist:(NSString *)name where:(NSPredicate *)where;
```

其中

- name: plist 名稱.
- where: 過濾條件.

當 **`where 不成立`** 將返回刪除失敗.


### 移除 Plist ###
```objc
+ (BOOL)dropPlist:(NSString *)name;
```
其中

- name: plsit 名稱.

可用來刪除全部資料.
