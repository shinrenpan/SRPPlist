# SRPPlist #
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Plist as database.



## 安裝 ##
使用 [Carthage](https://github.com/Carthage/Carthage) 安裝.


## 使用 ##



### 初始化 ###
使用 `initWithName:` 而不是使用 `init`.  
初始化成功時, 將在 App 的 Sandbox Documents/SRPPlist 底下建立一個 name.plist 檔案.  
例如:

```objc
SRPPlist *db = [[SRPPlist alloc]initWithName:@"db"];
```

將建立 `Documents/SRPPlist/db.plist`


### 新增 ###
使用 `add:`, `addMultiple:` 新增一筆或多筆資料, 新增的資料將自動新建或複寫 Id 跟 update,  
Id 型態為 NSString (NSUUID String), update 型態為 NSNumber (NSDate timeIntervalSince1970).  
例如:

```objc
NSDictionary *user = @{@"name" : @"Shinren Pan"};

[_db add:user];
```

儲存後 user 將變為:

```json
{
	"Id"    : "213D74EE-9799-471A-8EDB-02E7B1813BDA",
	"name"  : "Shinren Pan",
	"update": "1,484,126,444.78973"
}
```

> 請保留 Id 跟 update key.


### 修改 ###
使用 `update:` 或 `update:where:` 來修改資料.  
假設已經從 SRPPlist 撈出資料:

```objc
NSMutableDictionary *user = ...... from db

user[@"name"] = @"Pan Shinren";

[_db update:user];
```

未從 db 撈出資料, 而是透過條件修改:

```objc
NSPredicate *filter = [NSPredicate predicateWithFormat:@"Id == 213D74EE-9799-471A-8EDB-02E7B1813BDA"];
NSDictionary *newValue = @{@"name" : @"Pan Shinren"};

[_db update:newValue where:filter];
```

> 基本上 update: 等同於 update:where:, 過濾條件就是使用 Id.  
> 當過濾條件查不到資料時, 將返回 NO.


### 新增 OR 修改
使用 `createOrUpdate:where:` 可以新增或是修改資料.  
當過濾條件成功將執行修改, 失敗將執行新增, filter = nil 時, 將強制新增.


### 刪除 ###
使用 `remove:`, `removeWhere:`, `removeAll` 來刪除資料.

```objc
NSMutableDictionary *user = ...... from db
[_db remove:user];

NSPredicate *filter = [NSPredicate predicateWithFormat:@"Id == 213D74EE-9799-471A-8EDB-02E7B1813BDA"];
[_db removeWhere:filter];

[_db removeAll];

```
> 基本上 remove: 等同於 removeWhere:, 過濾條件就是使用 Id.  
> 當過濾條件查不到資料時, 將返回 NO.


### 查詢 ###
使用 `queryWhere:sort:`, `queryAllSort:` 來查詢.


### 儲存 ###
當使用 cache 時, 未執行 `save` 前, 所有的執行將不會寫入 plist,  
當不使用 cache 時, 所有執行將寫入 plist.

> 使用 cache 時, 請記得執行 save. save 後把 cache 改為 NO.


### Cache ###
何時使用 Cache, 由於每次存取時都會操作 plist, 當使用迴圈時便可以暫時使用 cache.  
例如:

```objc
for(NSInteger i=0; i < 1000; i++)
{
	[_db createOrUpdate:@{@"data" : @(i)} where:nil];
}

```

未使用 cache 時, 消耗了 12.123653 秒.

```objc
_db.cache = YES;
    
for(NSInteger i=0; i < 1000; i++)
{
	[_db createOrUpdate:@{@"data" : @(i)} where:nil];
}
    
[_db save];
_db.cache = NO;
```

使用 cache 時, 消耗了 0.048382 秒.


### 通知 ###
SRPPlist 使用 Notification 通知變化, 當 cache = YES, 將不通知.  
cache = NO 時, 支援以下變化通知:

1. 新增一筆資料時:  
	`NotificationName = SRPPLIST_<Plsit name 大寫>_ADD`
2. 修改一筆資料時:  
	`NotificationName = SRPPLIST_<Plsit name 大寫>_UPDATE`
3. 移除一筆資料時:  
	`NotificationName = SRPPLIST_<Plsit name 大寫>_REMOVE`
4. 移除所有資料時:  
	`NotificationName = SRPPLIST_<Plsit name 大寫>_REMOVEALL`
	
以下面為例子:

```objc
SRPPlist *db1  = [[SRPPlist alloc]initWithName:@"db"];
NSString *name = @"SRPPLIST_DB_UPDATE";

[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(__dbUpdate:) name:name object:nil];
```

便可以監聽 db.plist 更新時的資訊, 可以 NSLog NSNotification.userInfo 取得更多資訊.


### 其他 ###
1. 小專案, 不保證一定沒 bug.
2. 盡量不要多個 object 存取同一個 plist.
3. For 迴圈時, 盡量使用 cache.
4. 使用 cache 後記得 save 並取消 cache.
