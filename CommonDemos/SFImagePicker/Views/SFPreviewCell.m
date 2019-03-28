//
//  SFPreviewCell.m
//  SFImagePicker
//
//  Created by 宋庆功 on 2016/10/11.
//  Copyright © 2016年 思源. All rights reserved.
//

#import "SFPreviewCell.h"
#import <Photos/Photos.h>

@interface SFPreviewCell ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic)         PHImageRequestID requestID;

@end

@implementation SFPreviewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _requestID = 0;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    self.backgroundColor = [UIColor blackColor];
    self.contentView.backgroundColor = [UIColor blackColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds)-16.0, CGRectGetHeight(self.bounds))];
    self.scrollView.delegate = self;
    self.scrollView.bouncesZoom = YES;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.multipleTouchEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.contentView addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds)-16.0, CGRectGetHeight(self.bounds))];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.imageView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.contentView addGestureRecognizer:singleTap];
    [self.contentView addGestureRecognizer:doubleTap];
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)singleTap {
    if (self.singleTapBlock) {
        self.singleTapBlock();
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)doubleTap {
    if (self.scrollView.zoomScale > 1.0f) {
        [self.scrollView setZoomScale:1.0 animated:YES];
    }else {
        CGPoint touchPoint = [doubleTap locationInView:self.imageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)reloadDataWithPHAsset:(PHAsset *)asset
{
    self.scrollView.zoomScale = 1.0;
    
    if (self.requestID != 0) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:self.requestID];
    }
    // Image
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.version = PHImageRequestOptionsVersionOriginal;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    __weak SFPreviewCell *weakSelf = self;
    self.requestID = [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
        __strong SFPreviewCell *strongSelf = weakSelf;
        strongSelf.imageView.image = [UIImage imageWithData:imageData];
        
        CGFloat result = imageData.length/1024.0;
        if (result>=1024.0) {
            strongSelf.imageDataLength = [NSString stringWithFormat:@"%.1fM",result/1024.0];
        }else{
            strongSelf.imageDataLength = [NSString stringWithFormat:@"%dK",(int)result];
        }
        
        [strongSelf resizeSubviews];
    }];
    
//    CGFloat scale = [[UIScreen mainScreen] scale];
//    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.frame)*scale, CGRectGetHeight(self.frame)*scale);
//    
//    PHImageRequestOptions *option= [[PHImageRequestOptions alloc] init];
//    option.resizeMode = PHImageRequestOptionsResizeModeFast;
//    
//    
//    __weak SFPreviewCell *weakSelf = self;
//    self.requestID = [[PHCachingImageManager defaultManager] requestImageForAsset:asset
//                                                                       targetSize:targetSize
//                                                                      contentMode:PHImageContentModeAspectFill
//                                                                          options:option
//                                                                    resultHandler:^(UIImage *result, NSDictionary *info) {
//                                                                        __strong SFPreviewCell *strongSelf = weakSelf;
//                                                                        strongSelf.imageView.image = result;
//                                                                        [strongSelf resizeSubviews];                         }];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)resizeSubviews {
    
    UIImage *image = self.imageView.image;
    if (!image) {
        return;
    }
    
    CGSize size = [self adjustOriginSize:image.size
                                     toTargetSize:CGSizeMake(self.bounds.size.width - 16, self.bounds.size.height)];
    self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
    
    self.scrollView.contentSize = CGSizeMake(MAX(self.frame.size.width - 16, self.imageView.bounds.size.width), MAX(self.frame.size.height, self.imageView.bounds.size.height));
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    [self scrollViewDidZoom:self.scrollView];
    self.scrollView.maximumZoomScale = MAX(MAX(image.size.width/(self.bounds.size.width - 16), image.size.height / self.bounds.size.height), 3.f);
}

- (CGSize)adjustOriginSize:(CGSize)originSize
              toTargetSize:(CGSize)targetSize {
    
    CGSize resultSize = CGSizeMake(originSize.width, originSize.height);
    
    /** 计算图片的比例 */
    CGFloat widthPercent = (originSize.width ) / (targetSize.width);
    CGFloat heightPercent = (originSize.height ) / targetSize.height;
    if (widthPercent <= 1.0f && heightPercent <= 1.0f) {
        resultSize = CGSizeMake(originSize.width, originSize.height);
    } else if (widthPercent > 1.0f && heightPercent < 1.0f) {
        
        resultSize = CGSizeMake(targetSize.width, (originSize.height * targetSize.width) / originSize.width);
    }else if (widthPercent <= 1.0f && heightPercent > 1.0f) {
        
        resultSize = CGSizeMake((targetSize.height * originSize.width) / originSize.height, targetSize.height);
    }else {
        if (widthPercent > heightPercent) {
            resultSize = CGSizeMake(targetSize.width, (originSize.height * targetSize.width) / originSize.width);
        }else {
            resultSize = CGSizeMake((targetSize.height * originSize.width) / originSize.height, targetSize.height);
        }
    }
    return resultSize;
}

@end
