//
//  SFImagePickerController.h
//  SFImagePicker
//
//  Created by 宋庆功 on 2016/10/8.
//  Copyright © 2016年 思源. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFImagePickerController;

@protocol SFImagePickerControllerDelegate <NSObject>

@optional
- (void)sfimagePickerController:(SFImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets;
- (void)sfimagePickerControllerDidCancel:(SFImagePickerController *)imagePickerController;

@end

@interface SFImagePickerController : UIViewController

@property (nonatomic, strong, readonly) NSMutableOrderedSet *selectedAssets;

@property (nonatomic, weak) id<SFImagePickerControllerDelegate> delegate;
// 要显示的相册类型
@property (nonatomic, strong) NSArray *assetCollectionSubtypes;
// 最少要选择的图片数  默认1
@property (nonatomic) NSUInteger minimumNumberOfSelection;
// 最多要选择的图片数  默认9
@property (nonatomic) NSUInteger maximumNumberOfSelection;
// 竖屏多少列 默认4
@property (nonatomic) NSUInteger numberOfColumnsInPortrait;

@end
