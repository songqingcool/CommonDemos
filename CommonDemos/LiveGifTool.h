//
//  LiveGifTool.h
//  CommonDemos
//
//  Created by 宋庆功 on 2017/3/3.
//  Copyright © 2017年 公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class PHAssetResource;

@interface LiveGifTool : NSObject

#pragma mark - live photo转gif

// live photo -> MOV
// resource:live photo资源  destinationPath:mov结果绝对路径
- (void)liveToMovWithAssetResource:(PHAssetResource *)resource
                   destinationPath:(NSURL *)destinationPath
                   progressHandler:(void(^)(double progress))progress
                 completionHandler:(void(^)(NSError *error))handler;

// MOV -> gif
// path:mov文件绝对路径  destinationPath:gif结果绝对路径
- (void)movToGifWithPath:(NSURL *)path
         destinationPath:(NSURL *)destinationPath
       completionHandler:(void(^)(NSError *error))handler;

// live photo -> gif
// resource:live photo资源  destinationPath:gif结果绝对路径
- (void)liveToGifWithAssetResource:(PHAssetResource *)resource
                   destinationPath:(NSURL *)destinationPath
                 completionHandler:(void (^)(NSError *error))handler;

#pragma mark - gif转live photo

// gif -> MOV
// path:gif文件绝对路径  destinationPath:mov结果绝对路径
- (void)gifToMovWithPath:(NSURL *)path
         destinationPath:(NSURL *)destinationPath
       completionHandler:(void(^)(NSError *error))handler;

// MOV -> live photo
// path:mov文件绝对路径
- (void)movToLiveWithPath:(NSURL *)path
        completionHandler:(void(^)(NSString *jpegPath, NSString *movPath, NSError *error))handler;

// gif -> live photo
// path:gif文件绝对路径
- (void)gifToLiveWithPath:(NSURL *)path
        completionHandler:(void (^)(NSString *jpegPath, NSString *movPath, NSError *error))handler;
@end
