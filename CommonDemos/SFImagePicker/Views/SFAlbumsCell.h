//
//  SFAlbumsCell.h
//  SFImagePicker
//
//  Created by 宋庆功 on 2016/9/29.
//  Copyright © 2016年 思源. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAssetCollection;

@interface SFAlbumsCell : UITableViewCell


- (void)reloadDataWithCollection:(PHAssetCollection *)collection;

@end
