//
//  LiveGifTool.m
//  CommonDemos
//
//  Created by 宋庆功 on 2017/3/3.
//  Copyright © 2017年 公司. All rights reserved.
//

#import "LiveGifTool.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation LiveGifTool

#pragma mark - live photo转gif

// live photo -> MOV
// resource:live photo资源  destinationPath:mov结果绝对路径
- (void)liveToMovWithAssetResource:(PHAssetResource *)resource
                   destinationPath:(NSURL *)destinationPath
                   progressHandler:(void(^)(double progress))progress
                 completionHandler:(void(^)(NSError *error))handler
{
    PHAssetResourceRequestOptions *option = [[PHAssetResourceRequestOptions alloc] init];
    option.networkAccessAllowed = NO;
    option.progressHandler = progress;
    [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource toFile:destinationPath options:option completionHandler:handler];
}

// MOV -> gif
// path:mov文件绝对路径  destinationPath:gif结果绝对路径
- (void)movToGifWithPath:(NSURL *)path
         destinationPath:(NSURL *)destinationPath
       completionHandler:(void(^)(NSError *error))handler
{
    AVAsset *asset = [AVAsset assetWithURL:path];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    CMTime tempDuration = CMTimeConvertScale(asset.duration, 15, kCMTimeRoundingMethod_QuickTime);
    NSMutableArray *timePoints = [NSMutableArray array];
    for (int currentFrame = 0; currentFrame < tempDuration.value; currentFrame+=2) {
        CMTime time = CMTimeMake(currentFrame, 15);
        [timePoints addObject:[NSValue valueWithCMTime:time]];
    }
    if (timePoints.count == 0) {
        if (handler) {
            NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:@{@"des":@"0个关键帧"}];
            handler(error);
        }
        return;
    }
    __block NSMutableArray *imageArray = [NSMutableArray array];
    [generator generateCGImagesAsynchronouslyForTimes:timePoints completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        if (result == AVAssetImageGeneratorSucceeded) {
            [imageArray addObject:[UIImage imageWithCGImage:image]];
        }else{
            NSLog(@"获取某一个关键帧图片取消或失败了:requestedTime:%lld😭actualTime:%lld😭error:%@",requestedTime.value,actualTime.value,error);
        }
        
        if (requestedTime.value == ((NSValue *)(timePoints.lastObject)).CMTimeValue.value) {
            if (imageArray.count) {
                CFURLRef url = (__bridge CFURLRef)destinationPath;
                CGImageDestinationRef destinationRef = CGImageDestinationCreateWithURL(url, kUTTypeGIF, imageArray.count, NULL);
                CGImageDestinationSetProperties(destinationRef, (CFDictionaryRef)@{(NSString *)kCGImagePropertyGIFDictionary:@{(NSString *)kCGImagePropertyGIFLoopCount: @(0)}});
                for (UIImage *image in imageArray) {
//                    NSData *data = UIImageJPEGRepresentation(image, 0.4);
//                    UIImage *tempImage = [UIImage imageWithData:data];
                    CGImageDestinationAddImage(destinationRef, image.CGImage, (CFDictionaryRef)@{(NSString *)kCGImagePropertyGIFDictionary:@{(NSString *)kCGImagePropertyGIFDelayTime: @(3.0/imageArray.count)},(NSString *)kCGImagePropertyColorModel:(NSString *)kCGImagePropertyColorModelRGB});
                }
                CGImageDestinationFinalize(destinationRef);
                CFRelease(destinationRef);
                if (handler) {
                    handler(nil);
                }
            }else{
                if (handler) {
                    NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:@{@"des":@"0个图片"}];
                    handler(error);
                }
            }
        }
    }];
}

// live photo -> gif
// resource:live photo资源  destinationPath:gif结果绝对路径
- (void)liveToGifWithAssetResource:(PHAssetResource *)resource
                   destinationPath:(NSURL *)destinationPath
                 completionHandler:(void (^)(NSError *error))handler
{
    NSString *mPath = [NSHomeDirectory() stringByAppendingString:@"/tmp/TOON_LIVETOGIF_TEMP.MOV"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:mPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:mPath error:nil];
    }
    NSURL *movPath = [NSURL fileURLWithPath:mPath];
    __weak LiveGifTool *weakSelf = self;
    [self liveToMovWithAssetResource:resource destinationPath:movPath progressHandler:nil completionHandler:^(NSError *error) {
        __strong LiveGifTool *strongSelf = weakSelf;
        if (error) {
            if (handler) {
                handler(error);
            }
        }else{
            [strongSelf movToGifWithPath:movPath destinationPath:destinationPath completionHandler:handler];
        }
    }];
}

#pragma mark - gif转live photo

// gif -> MOV
// path:gif文件绝对路径  destinationPath:mov结果绝对路径
- (void)gifToMovWithPath:(NSURL *)path
         destinationPath:(NSURL *)destinationPath
       completionHandler:(void(^)(NSError *error))handler
{
    NSMutableArray *durationArray = [[NSMutableArray alloc]init];
    NSMutableArray *frameImageArray = [[NSMutableArray alloc]init];
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)path, NULL);
    size_t gifCount = CGImageSourceGetCount(gifSource);
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    for (size_t i = 0; i< gifCount; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        [frameImageArray addObject:image];
        CGImageRelease(imageRef);
        // 获取图片信息
        CFDictionaryRef info = CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL);
        CGFloat w = [(NSNumber *)CFDictionaryGetValue(info, kCGImagePropertyPixelWidth) floatValue];
        if (w>width) {
            width = w;
        }
        CGFloat h = [(NSNumber *)CFDictionaryGetValue(info, kCGImagePropertyPixelHeight) floatValue];
        if (h>height) {
            height = h;
        }
        CFDictionaryRef timeDic = CFDictionaryGetValue(info, kCGImagePropertyGIFDictionary);
        CGFloat time = [(NSString *)CFDictionaryGetValue(timeDic, kCGImagePropertyGIFDelayTime) floatValue];
        [durationArray addObject:[NSNumber numberWithFloat:time]];
        CFRelease(info);
    }
    CFRelease(gifSource);
    
    // writer for mov
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:destinationPath fileType:AVFileTypeQuickTimeMovie error:nil];
    NSString *assetIdentifier = [NSUUID UUID].UUIDString;
    writer.metadata = [self metadataForAssetIdentifier:assetIdentifier];
    // video track
    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:[LiveGifTool videoSettingsWithContentSize:CGSizeMake(width, height)]];
    input.expectsMediaDataInRealTime = YES;
    NSDictionary *sourcePixelBufferAttributesDictionary =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:input sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    if ([writer canAddInput:input]) {
        [writer addInput:input];
    }
    [writer startWriting];
    [writer startSessionAtSourceTime:kCMTimeZero];
    
    dispatch_queue_t queue = dispatch_queue_create("gifToMovAssetVideoWriterQueue", NULL);
    [input requestMediaDataWhenReadyOnQueue:queue usingBlock:^{
        
        CMTime presentationTime = kCMTimeZero;
        NSUInteger index = 0;
        while ([input isReadyForMoreMediaData]) {
            if (index >= frameImageArray.count) {
                break;
            }
            @autoreleasepool {
                UIImage *image = [frameImageArray objectAtIndex:index];
                CVPixelBufferRef buffer = [self pixelBufferFasterWithImage:image.CGImage];
                if (buffer) {
                    double scale = 600.0;
                    if (index < durationArray.count) {
                        scale = 1.0 / [[durationArray objectAtIndex:index] floatValue];
                    }
                    [adaptor appendPixelBuffer:buffer withPresentationTime:presentationTime];
                    presentationTime = CMTimeAdd(presentationTime, CMTimeMake(1, scale));
                    CVBufferRelease(buffer);
                }
            }
            index++;
        }
        
        [input markAsFinished];
        [writer finishWritingWithCompletionHandler:^{
            if (handler) {
                handler(nil);
            }
        }];
        CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
    }];
}

- (CVPixelBufferRef)pixelBufferFasterWithImage:(CGImageRef)image{
    
    CVPixelBufferRef pxbuffer = NULL;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];

    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    CVPixelBufferCreate(kCFAllocatorDefault,width,height,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef) options,&pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer,0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(image);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata,width,height,bitsPerComponent,bytesPerRow,rgbColorSpace,(CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context,CGRectMake(0,0,width,height), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer,0);
    
    return pxbuffer;
}

+ (NSDictionary *)videoSettingsWithContentSize:(CGSize)size {
    int w = (int)((int)(size.width / 16.0) * 16);
    int h = (int)(size.height * w / size.width);
    NSDictionary *videoSettings = @{
                                    AVVideoCodecKey: AVVideoCodecH264,
                                    AVVideoWidthKey: @(w),
                                    AVVideoHeightKey: @(h),
                                    AVVideoScalingModeKey:AVVideoScalingModeResizeAspect
                                    };
    return videoSettings;
}

// MOV -> live photo
// path:mov文件绝对路径
- (void)movToLiveWithPath:(NSURL *)path
        completionHandler:(void(^)(NSString *jpegPath, NSString *movPath, NSError *error))handler
{
    __weak LiveGifTool *weakSelf = self;
    AVAsset *asset = [AVAsset assetWithURL:path];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    
    NSMutableArray *timePoints = [NSMutableArray array];
    CMTime time = kCMTimeZero;
    [timePoints addObject:[NSValue valueWithCMTime:time]];
    [generator generateCGImagesAsynchronouslyForTimes:timePoints completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        __strong LiveGifTool *strongSelf = weakSelf;
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"获取某一个关键帧图片取消或失败了:requestedTime:%lld😭actualTime:%lld😭error:%@",requestedTime.value,actualTime.value,error);
            if (handler) {
                handler(nil,nil,error);
            }
            return ;
        }
        
        NSString *jpegPath = [NSHomeDirectory() stringByAppendingString:@"/tmp/TOON_MOVTOLIVE_TEMP.JPG"];
        NSString *movPath = [NSHomeDirectory() stringByAppendingString:@"/tmp/TOON_MOVTOLIVE_TEMP.MOV"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:jpegPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:jpegPath error:nil];
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:movPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:movPath error:nil];
        }
        
        NSString *assetIdentifier = [NSUUID UUID].UUIDString;
        CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:jpegPath];
        CGImageDestinationRef destinationRef = CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, NULL);
        CGImageDestinationAddImage(destinationRef, image, (CFDictionaryRef)@{(NSString *)kCGImagePropertyMakerAppleDictionary:@{@"17":assetIdentifier}});
        CGImageDestinationFinalize(destinationRef);
        CFRelease(destinationRef);
        [strongSelf writeVideoWithAsset:asset destinationPath:[NSURL fileURLWithPath:movPath] assetIdentifier:assetIdentifier];
        if (handler) {
            handler(jpegPath,movPath,nil);
        }
    }];
}

- (void)writeVideoWithAsset:(AVAsset *)asset
            destinationPath:(NSURL *)destinationPath
            assetIdentifier:(NSString *)assetIdentifier
{
    // reader for source video
    AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (!track) {
        NSLog(@"not found video track");
        return;
    }
    AVAssetReaderTrackOutput *output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:@{(NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)}];
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:nil];
    [reader addOutput:output];
    // writer for mov
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:destinationPath fileType:AVFileTypeQuickTimeMovie error:nil];
    writer.metadata = [self metadataForAssetIdentifier:assetIdentifier];
    // video track
    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:[self viedoSettingWithSize:track.naturalSize]];
    input.expectsMediaDataInRealTime = YES;
    input.transform = track.preferredTransform;
    [writer addInput:input];
    
    AVAssetWriterInput *audioWriterInput = nil;
    AVAssetReaderOutput *audioReaderOutput = nil;
    AVAssetReader *audioReader = nil;
    if (asset.tracks.count>1) {
        NSLog(@"Has Audio");
        audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:nil];
        audioWriterInput.expectsMediaDataInRealTime = NO;
        if ([writer canAddInput:audioWriterInput]) {
            [writer addInput:audioWriterInput];
        }
        AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
        audioReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
        audioReader = [AVAssetReader assetReaderWithAsset:asset error:nil];
        if ([audioReader canAddOutput:audioReaderOutput]) {
            [audioReader addOutput:audioReaderOutput];
        }
    }
    // metadata track
    AVAssetWriterInputMetadataAdaptor *adapter = [self metadataAdapter];
    [writer addInput:adapter.assetWriterInput];
    
    // --------------------------------------------------
    // creating video
    // --------------------------------------------------
    [writer startWriting];
    [reader startReading];
    [writer startSessionAtSourceTime:kCMTimeZero];
    
    // write metadata track
    AVMutableTimedMetadataGroup *group = [[AVMutableTimedMetadataGroup alloc] initWithItems:[self metadataForStillImageTime] timeRange:CMTimeRangeMake(CMTimeMake(0, 1000), CMTimeMake(200, 3000))];
    [adapter appendTimedMetadataGroup:group];
    
    // write video track
    dispatch_queue_t queue = dispatch_queue_create("assetVideoWriterQueue", NULL);
    [input requestMediaDataWhenReadyOnQueue:queue usingBlock:^{
        while (input.isReadyForMoreMediaData) {
            if (reader.status == AVAssetReaderStatusReading) {
                CMSampleBufferRef buffer = [output copyNextSampleBuffer];
                if (buffer) {
                    if (![input appendSampleBuffer:buffer]) {
                        NSLog(@"can't write:%@",writer.error);
                        [reader cancelReading];
                    }
                    CFRelease(buffer);
                }
            }else{
                [input markAsFinished];
                [writer finishWritingWithCompletionHandler:^{
                    
                }];
            }
        }
    }];
    while (writer.status == AVAssetWriterStatusWriting) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
    if (writer.error) {
        NSLog(@"can't write:%@",writer.error);
    }
}

- (NSArray<AVMetadataItem *> *)metadataForAssetIdentifier:(NSString *)assetIdentifier
{
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.key = @"com.apple.quicktime.content.identifier";
    item.keySpace = @"mdta";
    item.value = assetIdentifier;
    item.dataType = @"com.apple.metadata.datatype.UTF-8";
    return @[item];
}

- (NSArray<AVMetadataItem *> *)metadataForStillImageTime
{
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.key = @"com.apple.quicktime.still-image-time";
    item.keySpace = @"mdta";
    item.value = @(0);
    item.dataType = @"com.apple.metadata.datatype.int8";
    return @[item];
}

- (NSDictionary *)viedoSettingWithSize:(CGSize)size
{
    return @{AVVideoCodecKey: AVVideoCodecH264,
             AVVideoWidthKey: @(size.width),
             AVVideoHeightKey: @(size.height)};
}

- (AVAssetWriterInputMetadataAdaptor *)metadataAdapter
{
    NSDictionary *spec = @{(NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier:
                               @"mdta/com.apple.quicktime.still-image-time",
                           (NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType:
                               @"com.apple.metadata.datatype.int8"};
    CMFormatDescriptionRef desc = nil;
    CMMetadataFormatDescriptionCreateWithMetadataSpecifications(kCFAllocatorDefault, kCMMetadataFormatType_Boxed, (__bridge CFArrayRef)(@[spec]), &desc);
    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeMetadata outputSettings:nil sourceFormatHint:desc];
    AVAssetWriterInputMetadataAdaptor *adaptor = [AVAssetWriterInputMetadataAdaptor assetWriterInputMetadataAdaptorWithAssetWriterInput:input];
    return adaptor;
}

- (void)gifToLiveWithPath:(NSURL *)path
        completionHandler:(void (^)(NSString *jpegPath, NSString *movPath, NSError *error))handler
{
    NSString *mPath = [NSHomeDirectory() stringByAppendingString:@"/tmp/TOON_GIFTOLIVE_TEMP.MOV"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:mPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:mPath error:nil];
    }
    NSURL *movPath = [NSURL fileURLWithPath:mPath];
    __weak LiveGifTool *weakSelf = self;
    [self gifToMovWithPath:path destinationPath:movPath completionHandler:^(NSError *error) {
        __strong LiveGifTool *strongSelf = weakSelf;
        if (error) {
            if (handler) {
                handler(nil,nil,error);
            }
        }else{
            [strongSelf movToLiveWithPath:movPath completionHandler:handler];
        }
    }];
}

@end
