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
使用 `add:` 新增一筆資料, 新增的資料將自動新建或複寫 Id 跟 update,  
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


### 刪除 ###
使用 `remove:`, `removeByFilter:`, `removeAll` 來刪除資料.

```objc
NSMutableDictionary *user = ...... from db
[_db remove:user];

NSPredicate *filter = [NSPredicate predicateWithFormat:@"Id == 213D74EE-9799-471A-8EDB-02E7B1813BDA"];
[_db removeByFilter:filter];

[_db removeAll];

```
> 基本上 remove: 等同於 remove:where:, 過濾條件就是使用 Id.  
> 當過濾條件查不到資料時, 將返回 NO.


### 查詢 ###
使用 `queryByFileter:sortBy`, `queryAllSortBy:` 來查詢.


### 儲存 ###
當使用 cache 時, 未執行 `saveCache` 前, 所有的執行將不會寫入 plist,  
當不使用 cache 時, 所有執行將寫入 plist.

> 使用 cache 時, 請記得執行 saveCache.


### Cache / NonCache
SRPPlist 分為使用 cache 或是不使用, Default YES.

當使用 Cache 時, 假設多個 SRPPlist 指向同一個 plist, 資料是各自分開的,  
必須注意的是, 執行 `saveCache` 時, 會以最後執行的為主.  
例如:

```objc
SRPPlist *db1 = [[SRPPlist alloc]initWithName:@"db"];
SRPPlist *db2 = [[SRPPlist alloc]initWithName:@"db"];

[db1 add:user1];
[db2 add:user2];

[db1 queryAllSortBy:nil];
[db2 queryAllSortBy:nil];

// Now db1 只有 user1.
// Now db2 只有 user2.

[db2 saveCache];
[db1 reloadCache];
[db1 queryAllSortBy:nil];

// Now db1 db2 都只有 user2, user1 不見了.
```

不使用 Cache 時, 指向同一個 plist, 將直接從 disk 存取.  
例如:

```objc
SRPPlist *db1 = [[SRPPlist alloc]initWithName:@"db"];
SRPPlist *db2 = [[SRPPlist alloc]initWithName:@"db"];

[db1 add:user1];
[db2 add:user2];

[db1 queryAllSortBy:nil];
[db2 queryAllSortBy:nil];

// Now db1, db2 都有 user1, user2
```

何時使用 cache, 何時不使用?  
當這個 plist 只有 `一個` object 存取時, 使用 cache,  
當這個 plist 有 `多個` object 存取時, 就不要使用 cache.