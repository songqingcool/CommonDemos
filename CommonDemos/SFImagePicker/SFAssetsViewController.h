//
//  SFAssetsViewController.h
//  SFImagePicker
//
//  Created by 宋庆功 on 2016/9/29.
//  Copyright © 2016年 思源. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFImagePickerController;
@class PHAssetCollection;

@interface SFAssetsViewController : UIViewController

@property (nonatomic, weak) SFImagePickerController *imagePickerController;
@property (nonatomic, strong) PHAssetCollection *collection;

@end
