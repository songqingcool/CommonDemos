//
//  SFAssetsCell.m
//  SFImagePicker
//
//  Created by 宋庆功 on 2016/10/8.
//  Copyright © 2016年 思源. All rights reserved.
//

#import "SFAssetsCell.h"
#import <Photos/Photos.h>

@interface SFAssetsCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *checkmarkView;
@property (nonatomic)         PHImageRequestID requestID;

@end

@implementation SFAssetsCell

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
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self addSubview:self.imageView];
    
    self.checkmarkView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-29.0, 2.0, 27.0, 27.0)];
    self.checkmarkView.image = [UIImage imageNamed:@"photo_normal"];
    [self addSubview:self.checkmarkView];
}

- (void)reloadDataWithPHAsset:(PHAsset *)asset
{
    if (self.requestID != 0) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:self.requestID];
    }
    // Image
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.frame)*scale, CGRectGetHeight(self.frame)*scale);
    
    PHImageRequestOptions *option= [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    
    __weak SFAssetsCell *weakSelf = self;
    self.requestID = [[PHCachingImageManager defaultManager] requestImageForAsset:asset
                                                      targetSize:targetSize
                                                     contentMode:PHImageContentModeAspectFill
                                                         options:option
                                                   resultHandler:^(UIImage *result, NSDictionary *info) {
                                                       __strong SFAssetsCell *strongSelf = weakSelf;
                                                       strongSelf.imageView.image = result;
                                                   }];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        self.checkmarkView.image = [UIImage imageNamed:@"photo_selected"];
    }else{
        self.checkmarkView.image = [UIImage imageNamed:@"photo_normal"];
    }
}

@end
