//
//  SFPreviewCell.h
//  SFImagePicker
//
//  Created by 宋庆功 on 2016/10/11.
//  Copyright © 2016年 思源. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

@interface SFPreviewCell : UICollectionViewCell

// 图片大小
@property (nonatomic) NSString *imageDataLength;

@property (nonatomic, copy) void(^singleTapBlock)(void);

- (void)reloadDataWithPHAsset:(PHAsset *)asset;

@end
