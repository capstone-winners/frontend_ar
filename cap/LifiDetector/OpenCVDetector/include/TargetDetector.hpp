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

class TargetDetector {
public:
  TargetDetector();
  
  cv::Mat Detect(const cv::Mat frame);
  cv::Mat DetectFromHsv(const cv::Mat hsv, const cv::Mat frame);
  void SetFrameCompleteCallback(std::function<void(std::vector<int>)>);
  
private:
  ColorDetector greenTracker; 
  ColorDetector redTracker;
  ColorDetector blueTracker;
  vector<ColorDetector> detectors;
  
  const int framesPerMessage = FRAME_SIZE * BUFFER_SIZE;
  int frameCount = 0;
  int lastDetected = 0;
  bool detectedFrame = false;
  vector<int> binMessage = {};
  TargetHistory history = TargetHistory();
  std::function<void(std::vector<int>)> external_func;
  
  void AddToHistory(string detectorName, ShapeType detected, cv::Rect box);
  void FrameCompleteCallback(HistoryInterpreter* interp);
  void FailedIouCallback(const Box oldBox, const Box newBox);
  
  // Drawing Functions to update a markup frame.
  void AddMaxResponse(cv::Mat markup_frame, DetectorResponse response);
  void AddMessageToFrame(cv::Mat markup_frame);
  void AddFailedIouToFrame(cv::Mat markup_frame);
  void AddTargetHistoryDetailToFrame(cv::Mat markup_frame);
  
  void PrintLargestHistoryEntry();
};

#endif /* TargetDetector_hpp */
