//
//  Copyright (c) 2017 shinren.pan@gmail.com All rights reserved.
//

#import "ViewController.h"
#import <SRPPlist/SRPPlist.h>


static NSString * const PLIST_NAME = @"Numbers";

@interface ViewController ()

@property (nonatomic, copy) NSArray <NSDictionary *> *dataSource;

@end


@implementation ViewController

#pragma mark - LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [SRPPlist dropPlist:PLIST_NAME];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary *dic = _dataSource[indexPath.row];
    NSNumber *number  = dic[@"number"];
    NSString *Id      = dic[@"id"];
    
    cell.textLabel.text = number.stringValue;
    cell.detailTextLabel.text = Id;
    
    return cell;
}

#pragma mark - UITableDelegate
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 選中的 cell number update to 1000
    UITableViewRowAction *modify = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"To 1000" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSDictionary *dic  = _dataSource[indexPath.row];
        NSString *Id       = dic[@"id"];
        NSPredicate *where = [NSPredicate predicateWithFormat:@"id=%@", Id];
        
        if([SRPPlist plist:PLIST_NAME update:@{@"number": @1000} where:where])
        {
            [self __queryAll];
        }
    }];
    
    // 選中的 cell remove
    UITableViewRowAction *remove = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Remove" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSDictionary *dic  = _dataSource[indexPath.row];
        NSString *Id       = dic[@"id"];
        NSPredicate *where = [NSPredicate predicateWithFormat:@"id=%@", Id];
        
        if([SRPPlist plist:PLIST_NAME removeWhere:where])
        {
            [self __queryAll];
        }
    }];
    
    return @[modify, remove];
}

#pragma mark - IBAction
#pragma mark 按下 add
- (IBAction)addItemClicked:(id)sender
{
   NSNumber *number  =  @(arc4random() % 100);
   NSDictionary *dic = @{@"number": number};
   
   [SRPPlist plist:PLIST_NAME insert:@[dic]];
   [self __queryAll];
}

#pragma mark - Private
#pragma mark 查詢全部並 reload
- (void)__queryAll
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    
    _dataSource = [[SRPPlist plist:PLIST_NAME queryWhere:nil orderBy:@[sort]]copy];
    
    [self.tableView reloadData];
}

@end
