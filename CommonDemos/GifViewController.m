//
//  GifViewController.m
//  CommonDemos
//
//  Created by SONGQG on 2017/3/2.
//  Copyright © 2017年 公司. All rights reserved.
//

#import "GifViewController.h"
#import "LiveGifTool.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "SFImagePickerController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface GifViewController ()<SFImagePickerControllerDelegate>

@property (nonatomic, strong) LiveGifTool *tool;
@property (nonatomic, strong) PHAssetResource *resource;
@property (nonatomic, strong) PHLivePhotoView *livePhotoView;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation GifViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tool = [[LiveGifTool alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
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

- (void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *createTableButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 100, 80, 30)];
    [createTableButton setTitle:@"live to mov" forState:UIControlStateNormal];
    [createTableButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    createTableButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    createTableButton.backgroundColor = [UIColor greenColor];
    [createTableButton addTarget:self action:@selector(liveToMov) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createTableButton];
    
    UIButton *insertButton = [[UIButton alloc] initWithFrame:CGRectMake(110, 100, 80, 30)];
    [insertButton setTitle:@"mov to gif" forState:UIControlStateNormal];
    [insertButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    insertButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    insertButton.backgroundColor = [UIColor greenColor];
    [insertButton addTarget:self action:@selector(movToGif) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:insertButton];
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(205, 100, 80, 30)];
    [searchButton setTitle:@"live to gif" forState:UIControlStateNormal];
    [searchButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    searchButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    searchButton.backgroundColor = [UIColor greenColor];
    [searchButton addTarget:self action:@selector(liveToGif) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchButton];
    
    UIButton *createTableButton1 = [[UIButton alloc] initWithFrame:CGRectMake(15, 140, 80, 30)];
    [createTableButton1 setTitle:@"gif to mov" forState:UIControlStateNormal];
    [createTableButton1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    createTableButton1.titleLabel.font = [UIFont systemFontOfSize:15.0];
    createTableButton1.backgroundColor = [UIColor greenColor];
    [createTableButton1 addTarget:self action:@selector(gifToMov) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createTableButton1];
    
    UIButton *insertButton1 = [[UIButton alloc] initWithFrame:CGRectMake(110, 140, 80, 30)];
    [insertButton1 setTitle:@"mov to live" forState:UIControlStateNormal];
    [insertButton1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    insertButton1.titleLabel.font = [UIFont systemFontOfSize:15.0];
    insertButton1.backgroundColor = [UIColor greenColor];
    [insertButton1 addTarget:self action:@selector(movToLive) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:insertButton1];
    
    UIButton *searchButton1 = [[UIButton alloc] initWithFrame:CGRectMake(205, 140, 80, 30)];
    [searchButton1 setTitle:@"gif to live" forState:UIControlStateNormal];
    [searchButton1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    searchButton1.titleLabel.font = [UIFont systemFontOfSize:15.0];
    searchButton1.backgroundColor = [UIColor greenColor];
    [searchButton1 addTarget:self action:@selector(gifToLive) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchButton1];
    
    UIButton *pickPhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 180, 100, 30)];
    [pickPhotoButton setTitle:@"pick Photos" forState:UIControlStateNormal];
    [pickPhotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pickPhotoButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    pickPhotoButton.backgroundColor = [UIColor greenColor];
    [pickPhotoButton addTarget:self action:@selector(pickPhotoButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pickPhotoButton];
    
    UIButton *loadGifButton = [[UIButton alloc] initWithFrame:CGRectMake(130, 180, 80, 30)];
    [loadGifButton setTitle:@"load gif" forState:UIControlStateNormal];
    [loadGifButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    loadGifButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    loadGifButton.backgroundColor = [UIColor greenColor];
    [loadGifButton addTarget:self action:@selector(loadGifButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loadGifButton];
    
    [self.view addSubview:self.livePhotoView];
    [self.view addSubview:self.webView];
}

- (PHLivePhotoView *)livePhotoView
{
    if (!_livePhotoView) {
        _livePhotoView = [[PHLivePhotoView alloc] initWithFrame:CGRectMake(0.0, 220.0, CGRectGetWidth([UIScreen mainScreen].bounds), 178.0)];
    }
    return _livePhotoView;
}

- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 408.0, CGRectGetWidth([UIScreen mainScreen].bounds), 178.0)];
        _webView.scalesPageToFit = YES;
    }
    return _webView;
}

#pragma mark - 从相册获取live
- (void)pickPhotoButtonDidClicked:(UIButton *)sender
{
    SFImagePickerController *imagePicker = [[SFImagePickerController alloc] init];
    imagePicker.maximumNumberOfSelection = 1;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - SFImagePickerControllerDelegate
- (void)sfimagePickerController:(SFImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
    NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:assets.firstObject];
    for (PHAssetResource *tempRes in resources) {
        if (tempRes.type == PHAssetResourceTypePairedVideo) {
            self.resource = tempRes;
        }
    }
    
    __weak GifViewController *weakSelf = self;
    PHLivePhotoRequestOptions *option= [[PHLivePhotoRequestOptions alloc] init];
    [[PHCachingImageManager defaultManager] requestLivePhotoForAsset:assets.firstObject targetSize:self.livePhotoView.bounds.size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(PHLivePhoto *livePhoto, NSDictionary *info) {
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            __strong GifViewController *strongSelf = weakSelf;
            strongSelf.livePhotoView.livePhoto = livePhoto;
        }
    }];
}

- (void)sfimagePickerControllerDidCancel:(SFImagePickerController *)imagePickerController
{
    
}

- (void)loadGifButtonDidClicked:(UIButton *)sender
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"temp" ofType:@"gif"];
    NSData *gifData = [NSData dataWithContentsOfFile:path];
    [self.webView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
}

#pragma mark - live->gif
- (void)liveToMov
{
    NSString *movp = [NSHomeDirectory() stringByAppendingString:@"/Documents/temp.MOV"];
    NSURL *movPath = [NSURL fileURLWithPath:movp isDirectory:NO];
    [self.tool liveToMovWithAssetResource:self.resource destinationPath:movPath progressHandler:^(double progress) {
        NSLog(@"live To Mov progress:%f",progress);
    } completionHandler:^(NSError *error) {
        
    }];
}

- (void)movToGif
{
    NSString *movp = [[NSBundle mainBundle] pathForResource:@"TOON_LIVETOGIF_TEMP" ofType:@"MOV"];
    NSURL *movPath = [NSURL fileURLWithPath:movp isDirectory:NO];
    NSString *gifp = [NSHomeDirectory() stringByAppendingString:@"/Documents/temp.gif"];
    NSURL *gifPath = [NSURL fileURLWithPath:gifp isDirectory:NO];
    [self.tool movToGifWithPath:movPath destinationPath:gifPath completionHandler:^(NSError *error) {
        NSLog(@"movToGif complete Error:%@",error);
    }];
}

- (void)liveToGif
{
    // 最终结果gif的地址
    NSString *gifp = [NSHomeDirectory() stringByAppendingString:@"/Documents/temp.gif"];
    NSURL *gifPath = [NSURL fileURLWithPath:gifp isDirectory:NO];
    
    [self.tool liveToGifWithAssetResource:self.resource destinationPath:gifPath completionHandler:^(NSError *error) {
        NSLog(@"liveToGif complete Error:%@",error);
    }];
}

#pragma mark - gif->live
- (void)gifToMov
{
    NSString *gifp = [[NSBundle mainBundle] pathForResource:@"temp" ofType:@"gif"];
    NSURL *gifPath = [NSURL fileURLWithPath:gifp isDirectory:NO];
    NSString *movp = [NSHomeDirectory() stringByAppendingString:@"/Documents/temp.MOV"];
    NSURL *movPath = [NSURL fileURLWithPath:movp isDirectory:NO];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:movp]) {
        [[NSFileManager defaultManager] removeItemAtPath:movp error:nil];
    }
    
    [self.tool gifToMovWithPath:gifPath destinationPath:movPath completionHandler:^(NSError *error) {
        NSLog(@"gifToMov complete Error:%@",error);
    }];
}

- (void)movToLive
{
    NSString *movp = [[NSBundle mainBundle] pathForResource:@"TOON_LIVETOGIF_TEMP" ofType:@"MOV"];
    NSURL *movPath1 = [NSURL fileURLWithPath:movp isDirectory:NO];
    [self.tool movToLiveWithPath:movPath1 completionHandler:^(NSString *jpegPath, NSString *movPath, NSError *error) {
        NSLog(@"movToLive complete Error:%@",error);
    }];
}

- (void)gifToLive
{
    NSString *gifp = [[NSBundle mainBundle] pathForResource:@"temp" ofType:@"gif"];
    NSURL *gifPath = [NSURL fileURLWithPath:gifp isDirectory:NO];
    __weak GifViewController *weakSelf = self;
    [self.tool gifToLiveWithPath:gifPath completionHandler:^(NSString *jpegPath, NSString *movPath, NSError *error) {
        NSLog(@"gifToLive complete Error:%@",error);
        __strong GifViewController *strongSelf = weakSelf;
        [strongSelf liveWithJpegPath:jpegPath movPath:movPath];
        [strongSelf saveLiveWithJpegPath:jpegPath movPath:movPath];
    }];
}

#pragma mark - 显示gif->live的结果
- (void)liveWithJpegPath:(NSString *)jpegPath movPath:(NSString *)movPath
{
    NSURL *jpegUrl = [NSURL fileURLWithPath:jpegPath];
    NSURL *movUrl = [NSURL fileURLWithPath:movPath];
    
    __weak GifViewController *weakSelf = self;
    [PHLivePhoto requestLivePhotoWithResourceFileURLs:@[jpegUrl,movUrl] placeholderImage:[UIImage imageWithContentsOfFile:jpegPath] targetSize:self.livePhotoView.bounds.size contentMode:PHImageContentModeAspectFit resultHandler:^(PHLivePhoto *livePhoto, NSDictionary *info) {
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            __strong GifViewController *strongSelf = weakSelf;
            strongSelf.livePhotoView.livePhoto = livePhoto;
        }
    }];
}

#pragma mark - 保存live到相册
- (void)saveLiveWithJpegPath:(NSString *)jpegPath movPath:(NSString *)movPath
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        PHAssetResourceCreationOptions *option = [[PHAssetResourceCreationOptions alloc] init];
        [request addResourceWithType:PHAssetResourceTypePairedVideo fileURL:[NSURL fileURLWithPath:movPath] options:option];
        [request addResourceWithType:PHAssetResourceTypePhoto fileURL:[NSURL fileURLWithPath:jpegPath] options:option];
        
    } completionHandler:^(BOOL success, NSError *error) {
        NSLog(@"success:%d😭   Error:%@",success,error);
    }];
}

@end
