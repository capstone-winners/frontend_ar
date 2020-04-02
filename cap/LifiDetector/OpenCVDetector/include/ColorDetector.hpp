//
//  LifiDetection.hpp
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

#ifndef ColorDetector_hpp
#define ColorDetector_hpp

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#include <stdio.h>
#include <string>
#include <tuple>
#include <opencv2/opencv.hpp>
#include <opencv2/core/types_c.h>

#include "DetectorConstants.h"

using namespace std;

const string ShapeTypeToString(int enumValue);

class ColorDetector {
public:
  ColorDetector(const string name, const vector<ColorRange> color_range);
  DetectorResponse Detect(const cv::Mat src);
  DetectorResponse DetectFromHsv(const cv::Mat hsv);
  void DrawContours(cv::Mat markup_frame);
  string GetName();
  
private:
  string name;
  vector<ColorRange> colorRanges;
  cv::Mat frame_mask;
  vector<Contour> cnts;
  
  void GenerateMask(const cv::Mat frame);
  std::tuple<ShapeType, cv::Rect> DetectShape(Contour c);
  DetectorResponse MakeDetectorResponse(ShapeType type, cv::Rect box, Contour c);
};

#endif /* LifiDetection_hpp */
