//
//  NSObject+OpenCVWrapper.m
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

#ifdef __cplusplus
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#import "TargetDetector.hpp"
#endif

using namespace std;
using namespace cv;

#pragma mark - Private Declarations

@interface OpenCVWrapper ()

#ifdef __cplusplus

+ (Mat)_grayFrom:(Mat)source;
+ (Mat)_matFrom:(UIImage *)source;
+ (Mat) _matFromImageBuffer:(CVImageBufferRef) buffer;
+ (UIImage *)_imageFrom:(Mat)source;
#endif

@end

@interface OpenCVWrapper () {
  int callCount;
  TargetDetector detector;
}
@end


#pragma mark - OpenCVWrapper

@implementation OpenCVWrapper

#pragma mark Public
-(id)init {
   self = [super init];
   callCount = 0;
   return self;
}

- (UIImage *)toGray:(UIImage *)source {
  cout << "OpenCV: " << endl;
  cout << "\tcall count: " << callCount << endl;
  callCount = callCount + 1;
  return [OpenCVWrapper _imageFrom:[OpenCVWrapper _grayFrom:[OpenCVWrapper _matFrom:source]]];
}

- (UIImage *)detect:(UIImage *)source {
  detector.Detect([OpenCVWrapper _matFrom:source]);
  return [OpenCVWrapper _imageFrom:[OpenCVWrapper _grayFrom:[OpenCVWrapper _matFrom:source]]];
}

#pragma mark Private

+ (Mat)_grayFrom:(Mat)source {
  cout << "-> grayFrom ->";
  
  Mat result;
  cvtColor(source, result, COLOR_BGR2GRAY);
  
  return result;
}

+ (Mat)_matFrom:(UIImage *)source {
  cout << "matFrom ->";
  
  CGImageRef image = CGImageCreateCopy(source.CGImage);
  CGFloat cols = CGImageGetWidth(image);
  CGFloat rows = CGImageGetHeight(image);
  Mat result(rows, cols, CV_8UC4);
  
  CGBitmapInfo bitmapFlags = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
  size_t bitsPerComponent = 8;
  size_t bytesPerRow = result.step[0];
  CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
  
  CGContextRef context = CGBitmapContextCreate(result.data, cols, rows, bitsPerComponent, bytesPerRow, colorSpace, bitmapFlags);
  CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, cols, rows), image);
  CGContextRelease(context);
  
  return result;
}

+ (cv::Mat) _matFromImageBuffer: (CVImageBufferRef) buffer {
  
  cv::Mat mat ;
  
  CVPixelBufferLockBaseAddress(buffer, 0);
  
  void *address = CVPixelBufferGetBaseAddress(buffer);
  int width = (int) CVPixelBufferGetWidth(buffer);
  int height = (int) CVPixelBufferGetHeight(buffer);
  
  mat   = cv::Mat(height, width, CV_8UC4, address, 0);
  //cv::cvtColor(mat, _mat, CV_BGRA2BGR);
  
  CVPixelBufferUnlockBaseAddress(buffer, 0);
  
  return mat;
}


+ (UIImage *)_imageFrom:(Mat)source {
  cout << "-> imageFrom\n";
  
  NSData *data = [NSData dataWithBytes:source.data length:source.elemSize() * source.total()];
  CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
  
  CGBitmapInfo bitmapFlags = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
  size_t bitsPerComponent = 8;
  size_t bytesPerRow = source.step[0];
  CGColorSpaceRef colorSpace = (source.elemSize() == 1 ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB());
  
  CGImageRef image = CGImageCreate(source.cols, source.rows, bitsPerComponent, bitsPerComponent * source.elemSize(), bytesPerRow, colorSpace, bitmapFlags, provider, NULL, false, kCGRenderingIntentDefault);
  UIImage *result = [UIImage imageWithCGImage:image];
  
  CGImageRelease(image);
  CGDataProviderRelease(provider);
  CGColorSpaceRelease(colorSpace);
  
  return result;
}

@end
