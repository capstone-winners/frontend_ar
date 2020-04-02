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
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVWrapper.h"
#import "TargetDetector.hpp"
#endif

using namespace std;
using namespace cv;

#pragma mark - Private Declarations

@interface OpenCVWrapper ()
{
  TargetDetector detector;
}

- (void)_callback:(std::vector<int>)output;
@end

#pragma mark - OpenCVWrapper

@implementation OpenCVWrapper

#pragma mark Public
-(id)init {
   self = [super init];
   detector.SetFrameCompleteCallback(^(std::vector<int> input) {
     [self _callback:input];
   });
   return self;
}

- (UIImage *)detect:(UIImage *)source {
  Mat mat;
  UIImageToMat(source, mat);
  Mat bgr;
  cvtColor(mat, bgr, COLOR_RGB2BGR);
  Mat rgb;
  cvtColor(detector.Detect(bgr), rgb, COLOR_BGR2RGB);
  return MatToUIImage(rgb);
}

#pragma mark Private

- (void)_callback:(std::vector<int>)output {
  NSMutableArray *stringArray = [[NSMutableArray alloc] init];
  for(int i=0; i< output.size(); i++){
    [stringArray addObject:[NSNumber numberWithInt:output.at(i)]];
  }

  self.frameCompleteCallback(stringArray);
}

@end
