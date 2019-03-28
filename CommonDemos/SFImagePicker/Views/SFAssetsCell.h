//
//  SFAssetsCell.h
//  SFImagePicker
//
//  Created by 宋庆功 on 2016/10/8.
//  Copyright © 2016年 思源. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

@interface SFAssetsCell : UICollectionViewCell

- (void)reloadDataWithPHAsset:(PHAsset *)asset;

@end
