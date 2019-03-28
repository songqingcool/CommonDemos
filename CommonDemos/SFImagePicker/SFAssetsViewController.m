//
//  SFAssetsViewController.m
//  SFImagePicker
//
//  Created by 宋庆功 on 2016/9/29.
//  Copyright © 2016年 思源. All rights reserved.
//

#import "SFAssetsViewController.h"
#import <Photos/Photos.h>
#import "SFAssetsCell.h"
#import "SFImagePickerController.h"
#import "SFPreviewController.h"

#define kSFToolBarHeight 45.0

@interface SFAssetsViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) PHFetchResult *fetchResult;

// 底部左侧预览按钮
@property (nonatomic, strong) UIButton *previewButton;
// 底部右侧发送按钮
@property (nonatomic, strong) UIButton *sendButton;

@end

@implementation SFAssetsViewController

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
    
    [self setupCollectionView];
    [self updateFetchRequest];
    [self setBarButtonItems];
    // 初始化工具栏
    [self setupToolBar];
    // 更新工具栏状态
    [self updateToolBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"header_icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonItemClicked:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonItemClicked:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)leftButtonItemClicked:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonItemClicked:(UIBarButtonItem *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if ([self.imagePickerController.delegate respondsToSelector:@selector(sfimagePickerControllerDidCancel:)]) {
        [self.imagePickerController.delegate sfimagePickerControllerDidCancel:self.imagePickerController];
    }
}

#pragma mark - 初始化工具栏

- (void)setupToolBar
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(self.view.frame)-kSFToolBarHeight, CGRectGetWidth(self.view.frame), kSFToolBarHeight)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    UIView *sepview = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(view.frame), 0.5)];
    sepview.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    [view addSubview:sepview];
    
    self.previewButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0, 7.5, 44.0, CGRectGetHeight(view.frame)-2*7.5)];
    [self.previewButton setImage:nil forState:UIControlStateNormal];
    [self.previewButton setTitle:@"预览" forState:UIControlStateNormal];
    self.previewButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIColor *previewDisableColor = [UIColor colorWithRed:175.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0];
    [self.previewButton setTitleColor:previewDisableColor forState:UIControlStateDisabled];
    
    [self.previewButton addTarget:self action:@selector(previewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    self.previewButton.backgroundColor = [UIColor greenColor];
    [view addSubview:self.previewButton];
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.frame)-49.0, 7.5, 44.0, CGRectGetHeight(view.frame)-2*7.5)];
    [self.sendButton setImage:nil forState:UIControlStateNormal];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    UIColor *sendColor = [UIColor colorWithRed:35.0/255.0 green:180.0/255.0 blue:55.0/255.0 alpha:1.0];
    UIColor *sendDisableColor = [UIColor colorWithRed:210.0/255.0 green:230.0/255.0 blue:210.0/255.0 alpha:1.0];
    [self.sendButton setTitleColor:sendColor forState:UIControlStateNormal];
    [self.sendButton setTitleColor:sendDisableColor forState:UIControlStateDisabled];
    [self.sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    self.sendButton.backgroundColor = [UIColor blueColor];
    [view addSubview:self.sendButton];
}

- (void)previewButtonClicked:(UIButton *)sender
{
    self.navigationController.navigationBar.hidden = YES;
    SFPreviewController *preview = [[SFPreviewController alloc] init];
    preview.imagePickerController = self.imagePickerController;
    [self.navigationController pushViewController:preview animated:YES];
}

- (void)sendButtonClicked:(UIButton *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if ([self.imagePickerController.delegate respondsToSelector:@selector(sfimagePickerController:didFinishPickingAssets:)]) {
        [self.imagePickerController.delegate sfimagePickerController:self.imagePickerController didFinishPickingAssets:self.imagePickerController.selectedAssets.array];
    }
}

- (void)updateToolBar
{
    if (self.imagePickerController.selectedAssets.count > 0) {
        self.previewButton.enabled = YES;
    }else{
        self.previewButton.enabled = NO;
    }
    
    if (self.imagePickerController.selectedAssets.count >= self.imagePickerController.minimumNumberOfSelection) {
        self.sendButton.enabled = YES;
    }else{
        self.sendButton.enabled = NO;
    }
    
}

#pragma mark - 初始化列表

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 4.0;// 最小行间距
    layout.minimumInteritemSpacing = 4.0;// 最小列间距
    layout.sectionInset = UIEdgeInsetsMake(4.0, 4.0, 0.0, 4.0);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-kSFToolBarHeight) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[SFAssetsCell class] forCellWithReuseIdentifier:@"SFAssetsCell"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
}

#pragma mark - 获取照片数据

- (void)updateFetchRequest
{
    if (!self.collection) {
        PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        self.collection = fetchResult.firstObject;
    }
    self.title = self.collection.localizedTitle;
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    self.fetchResult = [PHAsset fetchAssetsInAssetCollection:self.collection options:options];
    
    [self.collectionView reloadData];
    
    // 滚动到底部
    if (self.fetchResult.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.fetchResult.count-1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFAssetsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SFAssetsCell" forIndexPath:indexPath];
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.row];
    [cell reloadDataWithPHAsset:asset];
    
    if ([self.imagePickerController.selectedAssets containsObject:asset]) {
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.imagePickerController.selectedAssets.count>=self.imagePickerController.maximumNumberOfSelection) {
        
        NSString *title = [NSString stringWithFormat:@"你最多只能选择%ld张照片",self.imagePickerController.maximumNumberOfSelection];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }else {
        return YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.row];
    [self.imagePickerController.selectedAssets addObject:asset];
    [self updateToolBar];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.row];
    [self.imagePickerController.selectedAssets removeObject:asset];
    [self updateToolBar];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger numberOfColumns = self.imagePickerController.numberOfColumnsInPortrait;
    
    CGFloat width = (CGRectGetWidth(self.view.frame) - 4.0 * (numberOfColumns + 1)) / numberOfColumns;
    
    return CGSizeMake(width, width);
}

@end
