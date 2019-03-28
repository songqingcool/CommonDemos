//
//  SFPreviewController.m
//  SFImagePicker
//
//  Created by 宋庆功 on 2016/10/10.
//  Copyright © 2016年 思源. All rights reserved.
//

#import "SFPreviewController.h"
#import "SFImagePickerController.h"
#import <Photos/Photos.h>
#import "SFPreviewCell.h"

#define kSFTopBarHeight 64.0
#define kSFToolBarHeight 45.0

@interface SFPreviewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UIView *topView;
// 顶部右侧选择按钮
@property (nonatomic, strong) UIButton *selectButton;

@property (nonatomic, strong) UIView *toolBar;
// 底部左侧原图按钮
@property (nonatomic, strong) UIButton *originButton;
// 底部右侧发送按钮
@property (nonatomic, strong) UIButton *sendButton;

// 要预览的图片
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic) NSUInteger  currentIndex;

@end

@implementation SFPreviewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentIndex = 0;
        self.dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.dataArray addObjectsFromArray:self.imagePickerController.selectedAssets.array];
    
    self.view.backgroundColor = [UIColor colorWithRed:1.0/255.0 green:1.0/255.0 blue:1.0/255.0 alpha:1.0];
    
    [self setupCollectionView];
    
    [self setTopBar];
    [self setupToolBar];
    [self updateTopAndToolBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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

- (void)setTopBar
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), kSFTopBarHeight)];
    view.backgroundColor = [UIColor colorWithRed:24.0/255.0 green:24.0/255.0 blue:24.0/255.0 alpha:0.5];
    [self.view addSubview:view];
    self.topView = view;
    
    UIView *sepview = [[UIView alloc] initWithFrame:CGRectMake(0.0, kSFTopBarHeight-0.5, CGRectGetWidth(view.frame), 0.5)];
    sepview.backgroundColor = [UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0];
    [view addSubview:sepview];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0, 7.5, 44.0, CGRectGetHeight(view.frame)-2*7.5)];
    [backButton setImage:[UIImage imageNamed:@"header_icon_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    backButton.backgroundColor = [UIColor greenColor];
    [view addSubview:backButton];
    
    self.selectButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.frame)-49.0, 7.5, 44.0, CGRectGetHeight(view.frame)-2*7.5)];
    [self.selectButton setImage:[UIImage imageNamed:@"photo_normal"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"photo_selected"] forState:UIControlStateSelected];
    [self.selectButton addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    self.selectButton.backgroundColor = [UIColor blueColor];
    [view addSubview:self.selectButton];
}

- (void)backButtonClicked:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)selectButtonClicked:(UIButton *)sender
{
    PHAsset *asset = [self.dataArray objectAtIndex:self.currentIndex];
    if ([self.imagePickerController.selectedAssets containsObject:asset]) {
        [self.imagePickerController.selectedAssets removeObject:asset];
    }else{
        [self.imagePickerController.selectedAssets addObject:asset];
    }
    
    [self updateTopAndToolBar];
}

#pragma mark - 初始化工具栏

- (void)setupToolBar
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(self.view.frame)-kSFToolBarHeight, CGRectGetWidth(self.view.frame), kSFToolBarHeight)];
    view.backgroundColor = [UIColor colorWithRed:24.0/255.0 green:24.0/255.0 blue:24.0/255.0 alpha:0.5];
    [self.view addSubview:view];
    self.toolBar = view;
    
    UIView *sepview = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(view.frame), 0.5)];
    sepview.backgroundColor = [UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0];
    [view addSubview:sepview];
    
    self.originButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0, 7.5, 80.0, CGRectGetHeight(view.frame)-2*7.5)];
    [self.originButton setImage:nil forState:UIControlStateNormal];
    [self.originButton setImage:nil forState:UIControlStateSelected];
    [self.originButton setTitle:@"原图" forState:UIControlStateNormal];
    self.originButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.originButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.originButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [self.originButton addTarget:self action:@selector(originButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    self.originButton.backgroundColor = [UIColor greenColor];
    [view addSubview:self.originButton];
    
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

- (void)originButtonClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    SFPreviewCell *cell = (SFPreviewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    
    NSString *selectMessage = [NSString stringWithFormat:@"原图(%@)",cell.imageDataLength];
    [self.originButton setTitle:selectMessage forState:UIControlStateSelected];
}

- (void)sendButtonClicked:(UIButton *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if ([self.imagePickerController.delegate respondsToSelector:@selector(sfimagePickerController:didFinishPickingAssets:)]) {
        [self.imagePickerController.delegate sfimagePickerController:self.imagePickerController didFinishPickingAssets:self.imagePickerController.selectedAssets.array];
    }
}

- (void)updateTopAndToolBar
{
    if (self.imagePickerController.selectedAssets.count >= self.imagePickerController.minimumNumberOfSelection) {
        self.sendButton.enabled = YES;
    }else{
        self.sendButton.enabled = NO;
    }
    
    PHAsset *asset = [self.dataArray objectAtIndex:self.currentIndex];
    if ([self.imagePickerController.selectedAssets containsObject:asset]) {
        self.selectButton.selected = YES;
    }else{
        self.selectButton.selected = NO;
    }
    
    if (self.originButton.selected) {
        SFPreviewCell *cell = (SFPreviewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
        
        NSString *selectMessage = [NSString stringWithFormat:@"原图(%@)",cell.imageDataLength];
        [self.originButton setTitle:selectMessage forState:UIControlStateSelected];
    }
}



#pragma mark - 初始化列表

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0.0;// 最小行间距
    layout.minimumInteritemSpacing = 0.0;// 最小列间距
    layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width+16.0, [UIScreen mainScreen].bounds.size.height);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds)+16.0, CGRectGetHeight(self.view.bounds)) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.allowsSelection = NO;
    [self.collectionView registerClass:[SFPreviewCell class] forCellWithReuseIdentifier:@"SFPreviewCell"];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat index = scrollView.contentOffset.x/CGRectGetWidth(scrollView.frame);
    self.currentIndex = (NSUInteger) (index>=0?index:0);
    [self updateTopAndToolBar];
    
    
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SFPreviewCell" forIndexPath:indexPath];
    __weak SFPreviewController *weakSelf = self;
    cell.singleTapBlock = ^(){
        __strong SFPreviewController *strongSelf = weakSelf;
        [strongSelf updateBarHidden];
    };
    PHAsset *asset = [self.dataArray objectAtIndex:indexPath.row];
    [cell reloadDataWithPHAsset:asset];
    
    return cell;
}

- (void)updateBarHidden{
    
    BOOL hidden = !self.topView.hidden;
    if (hidden) {
        __weak SFPreviewController *weakSelf = self;
        [UIView animateWithDuration:0.1 animations:^{
            __strong SFPreviewController *strongSelf = weakSelf;
            strongSelf.topView.alpha = 0.0f;
            strongSelf.toolBar.alpha = 0.0f;
        } completion:^(BOOL finished) {
            __strong SFPreviewController *strongSelf = weakSelf;
            strongSelf.topView.hidden = YES;
            strongSelf.toolBar.hidden = YES;
        }];
    }else{
        self.topView.hidden = NO;
        self.toolBar.hidden = NO;
        __weak SFPreviewController *weakSelf = self;
        [UIView animateWithDuration:0.1 animations:^{
            __strong SFPreviewController *strongSelf = weakSelf;
            strongSelf.topView.alpha = 1.0f;
            strongSelf.toolBar.alpha = 1.0f;
        } completion:nil];
    }
}

@end
