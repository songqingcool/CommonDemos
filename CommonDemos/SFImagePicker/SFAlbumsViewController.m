//
//  SFAlbumsViewController.m
//  SFImagePicker
//
//  Created by 宋庆功 on 2016/9/29.
//  Copyright © 2016年 思源. All rights reserved.
//

#import "SFAlbumsViewController.h"
#import "SFAlbumsCell.h"
#import <Photos/Photos.h>
#import "SFAssetsViewController.h"
#import "SFImagePickerController.h"

@interface SFAlbumsViewController ()<UITableViewDelegate,UITableViewDataSource,PHPhotoLibraryChangeObserver>

// 相册列表
@property (nonatomic, strong) UITableView *tableView;
// 相册数据源
@property (nonatomic, strong) NSArray *assetCollections;

@property (nonatomic, strong) NSArray *fetchResults;

@end

@implementation SFAlbumsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"相册";
    [self setBarButtonItems];
    [self setupTableView];
    
    // Fetch user albums and smart albums
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    self.fetchResults = @[smartAlbums,userAlbums];
    
    [self updateAssetCollections];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 设置导航栏两侧按钮

- (void)setBarButtonItems
{
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonItemClicked:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)rightButtonItemClicked:(UIBarButtonItem *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if ([self.imagePickerController.delegate respondsToSelector:@selector(sfimagePickerControllerDidCancel:)]) {
        [self.imagePickerController.delegate sfimagePickerControllerDidCancel:self.imagePickerController];
    }
}

#pragma mark - 初始化列表

- (void)setupTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[SFAlbumsCell class] forCellReuseIdentifier:@"SFAlbumsCell"];
    [self.view addSubview:self.tableView];
}

#pragma mark - 获取数据源
- (void)updateAssetCollections
{
    NSMutableArray *assetCollections = [[NSMutableArray alloc] init];
    for (PHFetchResult *fetchResult in self.fetchResults) {
        __weak SFAlbumsViewController *weakSelf = self;
        [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger index, BOOL *stop) {
            __strong SFAlbumsViewController *strongSelf = weakSelf;
            if ([strongSelf.imagePickerController.assetCollectionSubtypes containsObject:@(assetCollection.assetCollectionSubtype)]) {
                [assetCollections addObject:assetCollection];
            }
        }];
    }
    
    self.assetCollections = assetCollections;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate/UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetCollections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFAlbumsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFAlbumsCell" forIndexPath:indexPath];
    PHAssetCollection *collection = [self.assetCollections objectAtIndex:indexPath.row];
    [cell reloadDataWithCollection:collection];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PHAssetCollection *collection = [self.assetCollections objectAtIndex:indexPath.row];
    SFAssetsViewController *assets = [[SFAssetsViewController alloc] init];
    assets.imagePickerController = self.imagePickerController;
    assets.title = collection.localizedTitle;
    assets.collection = collection;
    [self.navigationController pushViewController:assets animated:YES];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update fetch results
        NSMutableArray *fetchResults = [self.fetchResults mutableCopy];
        
        [self.fetchResults enumerateObjectsUsingBlock:^(PHFetchResult *fetchResult, NSUInteger index, BOOL *stop) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:fetchResult];
            
            if (changeDetails) {
                [fetchResults replaceObjectAtIndex:index withObject:changeDetails.fetchResultAfterChanges];
            }
        }];
        
        if (![self.fetchResults isEqualToArray:fetchResults]) {
            self.fetchResults = fetchResults;
            
            // Reload albums
            [self updateAssetCollections];
            
        }
    });
}

@end
