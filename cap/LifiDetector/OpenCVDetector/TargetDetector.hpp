//
//  TargetDetector.hpp
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

#ifndef TargetDetector_hpp
#define TargetDetector_hpp

#ifdef __cplusplus
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#include <stdio.h>
#include <string>
#include <tuple>

#include <opencv2/opencv.hpp>
#include <opencv2/core/types_c.h>

#include "DetectorConstants.h"
#include "CvHelper.hpp"
#include "ColorDetector.hpp"
#include "TargetHistory.hpp"
#include "HistoryInterpreter.hpp"
#endif

using std::vector;

// Color Ranges
// define the lower and upper boundaries of the "green"
// ball in the HSV color space. NB the hue range in
// opencv is 180, normally it is 360
array<int, 3> green_lower = {50, 50, 50};
array<int, 3> green_upper = {70, 255, 255};
vector<ColorRange> green_range {make_tuple(green_lower, green_upper)};

array<int, 3>red_lower = {0, 50, 20};
array<int, 3> red_upper = {5, 255, 255};
array<int, 3> red_lower2 = {170, 50, 20};
array<int, 3> red_upper2 = {180, 255, 255};
vector<ColorRange> red_range {make_tuple(red_lower, red_upper), make_tuple(red_lower2, red_upper2)};

array<int, 3> blue_lower = {110, 50, 50};
array<int, 3> blue_upper = {130, 255, 255};
vector<ColorRange> blue_range {make_tuple(blue_lower, blue_upper)};


class TargetDetector {
public:
  TargetDetector();
  
  void Detect(cv::Mat frame);
  
private:
  ColorDetector greenTracker; 
  ColorDetector redTracker;
  ColorDetector blueTracker;
  vector<ColorDetector> detectors;
  
  const int framesPerMessage = FRAME_SIZE * BUFFER_SIZE;
  int frameCount = 0;
  int lastDetected = 0;
  int detectedFrame = false;
  vector<int> binMessage = {};
  TargetHistory history = TargetHistory();
  
  void AddToHistory(string detectorName, ShapeType detected, cv::Rect box);
  void FrameCompleteCallback(HistoryInterpreter* interp);
  void FailedIouCallback(const Box oldBox, const Box newBox);
  
};

#endif /* TargetDetector_hpp */
