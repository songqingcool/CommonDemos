//
//  SFAlbumsCell.m
//  SFImagePicker
//
//  Created by 宋庆功 on 2016/9/29.
//  Copyright © 2016年 思源. All rights reserved.
//

#import "SFAlbumsCell.h"
#import <Photos/Photos.h>

@interface SFAlbumsCell ()

@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView2;
@property (nonatomic, strong) UIImageView *imageView3;

@property (nonatomic, strong) UILabel *albumsNameLabel;
@property (nonatomic, strong) UILabel *countLabel;


@property (nonatomic) PHImageRequestID requestID1;
@property (nonatomic) PHImageRequestID requestID2;
@property (nonatomic) PHImageRequestID requestID3;

@end

@implementation SFAlbumsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.requestID1 = 0;
        self.requestID2 = 0;
        self.requestID3 = 0;
        [self setupSubview];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupSubview
{
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    // 图片
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    self.imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(19.0, 6.5, 60.0, 60.0)];
    self.imageView3.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView3.layer.borderWidth = 1.0 / scale;
    [self.contentView addSubview:self.imageView3];
    
    self.imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(17.0, 8.5, 64.0, 64.0)];
    self.imageView2.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView2.layer.borderWidth = 1.0 / scale;
    [self.contentView addSubview:self.imageView2];
    
    self.imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 10.5, 68.0, 68.0)];
    self.imageView1.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView1.layer.borderWidth = 1.0 / scale;
    [self.contentView addSubview:self.imageView1];
    
    // 相册名字
    self.albumsNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(98.0, 20.5, CGRectGetWidth([UIScreen mainScreen].bounds)-98.0-35.0, 20.0)];
    self.albumsNameLabel.font = [UIFont systemFontOfSize:16.0];
    [self.contentView addSubview:self.albumsNameLabel];
    // 相册照片个数
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(98.0, 45.5, CGRectGetWidth([UIScreen mainScreen].bounds)-98.0-35.0, 20.0)];
    self.countLabel.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:self.countLabel];
}

- (void)reloadDataWithCollection:(PHAssetCollection *)collection
{
    // Thumbnail
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    if (self.requestID1 != 0) {
        [imageManager cancelImageRequest:self.requestID1];
    }
    
    if (self.requestID2 != 0) {
        [imageManager cancelImageRequest:self.requestID2];
    }
    
    if (self.requestID3 != 0) {
        [imageManager cancelImageRequest:self.requestID3];
    }
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    __weak SFAlbumsCell *weakSelf = self;
    if (fetchResult.count >= 3) {
        self.imageView3.hidden = NO;
        
        self.requestID3 = [imageManager requestImageForAsset:fetchResult[fetchResult.count - 3]
                                                  targetSize:CGSizeMake(CGRectGetWidth(self.imageView3.frame)*scale, CGRectGetHeight(self.imageView3.frame)*scale)
                                                 contentMode:PHImageContentModeAspectFill
                                                     options:nil
                                               resultHandler:^(UIImage *result, NSDictionary *info) {
                                                   __strong SFAlbumsCell *strongSelf = weakSelf;
                                                   strongSelf.imageView3.image = result;
                                               }];
    } else {
        self.imageView3.hidden = YES;
    }
    
    if (fetchResult.count >= 2) {
        self.imageView2.hidden = NO;
        
        self.requestID2 = [imageManager requestImageForAsset:fetchResult[fetchResult.count - 2]
                                                  targetSize:CGSizeMake(CGRectGetWidth(self.imageView2.frame)*scale, CGRectGetHeight(self.imageView2.frame)*scale)
                                                 contentMode:PHImageContentModeAspectFill
                                                     options:nil
                                               resultHandler:^(UIImage *result, NSDictionary *info) {
                                                   __strong SFAlbumsCell *strongSelf = weakSelf;
                                                   strongSelf.imageView2.image = result;
                                               }];
    } else {
        self.imageView2.hidden = YES;
    }
    
    if (fetchResult.count >= 1) {
        self.requestID1 = [imageManager requestImageForAsset:fetchResult[fetchResult.count - 1]
                                                  targetSize:CGSizeMake(CGRectGetWidth(self.imageView1.frame)*scale, CGRectGetHeight(self.imageView1.frame)*scale)
                                                 contentMode:PHImageContentModeAspectFill
                                                     options:nil
                                               resultHandler:^(UIImage *result, NSDictionary *info) {
                                                   __strong SFAlbumsCell *strongSelf = weakSelf;
                                                   strongSelf.imageView1.image = result;
                                               }];
    }
    
    if (fetchResult.count == 0) {
        self.imageView3.hidden = NO;
        self.imageView2.hidden = NO;
        
        // Set placeholder image
        UIImage *placeholderImage = [self placeholderImageWithSize:self.imageView1.frame.size];
        self.imageView1.image = placeholderImage;
        self.imageView2.image = placeholderImage;
        self.imageView3.image = placeholderImage;
    }
    
    // Album title
    self.albumsNameLabel.text = collection.localizedTitle;
    
    // Number of photos
    self.countLabel.text = [NSString stringWithFormat:@"%lu", (long)fetchResult.count];
}

- (UIImage *)placeholderImageWithSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *backgroundColor = [UIColor colorWithRed:(239.0 / 255.0) green:(239.0 / 255.0) blue:(244.0 / 255.0) alpha:1.0];
    UIColor *iconColor = [UIColor colorWithRed:(179.0 / 255.0) green:(179.0 / 255.0) blue:(182.0 / 255.0) alpha:1.0];
    
    // Background
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    // Icon (back)
    CGRect backIconRect = CGRectMake(size.width * (16.0 / 68.0),
                                     size.height * (20.0 / 68.0),
                                     size.width * (32.0 / 68.0),
                                     size.height * (24.0 / 68.0));
    
    CGContextSetFillColorWithColor(context, [iconColor CGColor]);
    CGContextFillRect(context, backIconRect);
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(backIconRect, 1.0, 1.0));
    
    // Icon (front)
    CGRect frontIconRect = CGRectMake(size.width * (20.0 / 68.0),
                                      size.height * (24.0 / 68.0),
                                      size.width * (32.0 / 68.0),
                                      size.height * (24.0 / 68.0));
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(frontIconRect, -1.0, -1.0));
    
    CGContextSetFillColorWithColor(context, [iconColor CGColor]);
    CGContextFillRect(context, frontIconRect);
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(frontIconRect, 1.0, 1.0));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
