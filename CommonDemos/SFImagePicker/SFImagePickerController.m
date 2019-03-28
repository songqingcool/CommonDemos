//
//  SFImagePickerController.m
//  SFImagePicker
//
//  Created by 宋庆功 on 2016/10/8.
//  Copyright © 2016年 思源. All rights reserved.
//

#import "SFImagePickerController.h"
#import "SFAlbumsViewController.h"
#import "SFAssetsViewController.h"
#import <Photos/Photos.h>

@interface SFImagePickerController ()

@property (nonatomic, strong) UINavigationController *albumsNavigationController;

@end

@implementation SFImagePickerController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSArray *subTypes = nil;
        CGFloat systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
        if (systemVersion >= 9.0) {
            subTypes = @[@(PHAssetCollectionSubtypeAlbumRegular),@(PHAssetCollectionSubtypeSmartAlbumBursts),@(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),@(PHAssetCollectionSubtypeSmartAlbumSelfPortraits),@(PHAssetCollectionSubtypeSmartAlbumScreenshots),@(PHAssetCollectionSubtypeSmartAlbumUserLibrary)];
        }else{
            subTypes = @[@(PHAssetCollectionSubtypeAlbumRegular),@(PHAssetCollectionSubtypeSmartAlbumBursts),@(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),@(PHAssetCollectionSubtypeSmartAlbumUserLibrary)];
        }
        self.assetCollectionSubtypes = subTypes;
        self.minimumNumberOfSelection = 1;
        self.maximumNumberOfSelection = 9;
        self.numberOfColumnsInPortrait = 4;
        _selectedAssets = [NSMutableOrderedSet orderedSet];
        
        
        [self setUpAlbumsViewController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (void)setUpAlbumsViewController
{
    SFAlbumsViewController *albums = [[SFAlbumsViewController alloc] init];
    albums.imagePickerController = self;
    SFAssetsViewController *assets = [[SFAssetsViewController alloc] init];
    assets.imagePickerController = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:albums];
    [navigationController pushViewController:assets animated:NO];
    
    [self addChildViewController:navigationController];
    
    navigationController.view.frame = self.view.bounds;
    [self.view addSubview:navigationController.view];
    
    [navigationController didMoveToParentViewController:self];
    
    self.albumsNavigationController = navigationController;
}


#pragma mark - 预览隐藏状态栏
- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.childViewControllers.firstObject;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.childViewControllers.firstObject;
}

@end
