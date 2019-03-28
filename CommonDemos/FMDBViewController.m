//
//  FMDBViewController.m
//  CommonDemos
//
//  Created by SONGQG on 2017/1/9.
//  Copyright © 2017年 公司. All rights reserved.
//

#import "FMDBViewController.h"
#import <FMDB/FMDB.h>

#define kTableName @"Test"

@interface FMDBViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) NSDateFormatter *formater;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation FMDBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *dbPath = [NSString stringWithFormat:@"%@/Library/Test.db",NSHomeDirectory()];
    NSLog(@"数据库本地地址:%@",dbPath);
    self.dbQueue = [[FMDatabaseQueue alloc] initWithPath:dbPath];
    
    [self createUI];
    
    NSString *pathString = [NSString stringWithFormat:@"数据库本地地址:%@",dbPath];
    [self textViewAppendString:pathString];
}

- (NSDateFormatter *)formater
{
    if (!_formater) {
        _formater = [[NSDateFormatter alloc] init];
        _formater.dateFormat = @"YYYY-MM-dd hh:mm:ss:SSS";
    }
    return _formater;
}

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *createTableButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 100, 80, 30)];
    [createTableButton setTitle:@"创建表" forState:UIControlStateNormal];
    [createTableButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    createTableButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    createTableButton.backgroundColor = [UIColor greenColor];
    [createTableButton addTarget:self action:@selector(createTableButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createTableButton];
    
    UIButton *insertButton = [[UIButton alloc] initWithFrame:CGRectMake(110, 100, 80, 30)];
    [insertButton setTitle:@"插入数据" forState:UIControlStateNormal];
    [insertButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    insertButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    insertButton.backgroundColor = [UIColor greenColor];
    [insertButton addTarget:self action:@selector(insertButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:insertButton];
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(205, 100, 80, 30)];
    [searchButton setTitle:@"模糊查询" forState:UIControlStateNormal];
    [searchButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    searchButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    searchButton.backgroundColor = [UIColor greenColor];
    [searchButton addTarget:self action:@selector(searchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchButton];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 140, CGRectGetWidth([UIScreen mainScreen].bounds)-30, 30)];
    self.textField.font = [UIFont systemFontOfSize:14.0];
    self.textField.backgroundColor = [UIColor greenColor];
    self.textField.placeholder = @"模糊查询的字符串";
    self.textField.delegate = self;
    [self.view addSubview:self.textField];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 180, CGRectGetWidth([UIScreen mainScreen].bounds)-30, 380)];
    self.textView.font = [UIFont systemFontOfSize:14.0];
    self.textView.backgroundColor = [UIColor greenColor];
    self.textView.editable = NO;
    [self.view addSubview:self.textView];
}

// 创建表
- (void)createTableButtonClicked:(UIButton *)sender
{
    [self textViewAppendString:@"数据库开始创建Test表"];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
         NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id1 INTEGER default 0, id2 INTEGER default 0, id3 INTEGER default 0, createtime INTEGER default 0, text TEXT default '')",kTableName];
        [db executeUpdate:sql];
    }];
    [self textViewAppendString:@"数据库创建Test表结束"];
}

// 插入数据
- (void)insertButtonClicked:(UIButton *)sender
{
    NSString *string = [NSString stringWithFormat:@"数据库开始插入1000000条数据:%@",[self.formater stringFromDate:[NSDate date]]];
    [self textViewAppendString:string];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (int i = 0; i< 1000000; i++) {
            NSInteger id1 = (arc4random() % 1000)+1;
            NSInteger id2 = (arc4random() % 100)+1;
            NSInteger id3 = (arc4random() % 10)+1;
            NSInteger time = [[NSDate date] timeIntervalSince1970]*1000;
            NSMutableString *text = [[NSMutableString alloc] init];
            NSString *GUID = [NSUUID UUID].UUIDString;
            for (int i = 0; i< id3; i++) {
                [text appendString:GUID];
            }
            NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (id1,id2,id3,createtime,text) values (%@,%@,%@,%@,'%@')",kTableName,@(id1),@(id2),@(id3),@(time),text];
            [db executeUpdate:sql];
        }
    }];
    NSString *endString = [NSString stringWithFormat:@"数据库插入1000000条数据结束:%@",[self.formater stringFromDate:[NSDate date]]];
    [self textViewAppendString:endString];
}

- (void)searchButtonClicked:(UIButton *)sender
{
    NSString *searchString = self.textField.text;
    NSString *string = [NSString stringWithFormat:@"数据库开始搜索%@:%@",searchString,[self.formater stringFromDate:[NSDate date]]];
    [self textViewAppendString:string];
    __block NSArray *retArray = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE text LIKE '%%%@%%'",kTableName,searchString];
        FMResultSet *set = [db executeQuery:sql];
        NSMutableArray *tempArray = [NSMutableArray array];
        while ([set next]) {
            NSDictionary *dict = [set resultDictionary];
            if (dict) {
                [tempArray addObject:dict];
            }
        }
        retArray = tempArray;
        [set close];
    }];
    NSString *endString = [NSString stringWithFormat:@"数据库搜索结束:%@",[self.formater stringFromDate:[NSDate date]]];
    [self textViewAppendString:endString];
    NSString *endString1 = [NSString stringWithFormat:@"共有%ld条记录",retArray.count];
    [self textViewAppendString:endString1];
    NSString *resultString = [NSString stringWithFormat:@"数据库搜索结果:%@",retArray];
    [self textViewAppendString:resultString];
}

- (void)textViewAppendString:(NSString *)string
{
    self.textView.text = [NSString stringWithFormat:@"%@%@\n\n",self.textView.text,string];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
