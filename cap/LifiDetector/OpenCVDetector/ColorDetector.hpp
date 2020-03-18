//
//  LifiDetection.hpp
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

#ifndef ColorDetector_hpp
#define ColorDetector_hpp

#ifdef __cplusplus
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#include <stdio.h>
#include <string>
#include <tuple>
#include <opencv2/opencv.hpp>
#include <opencv2/core/types_c.h>
#endif

using namespace std;

enum ShapeType {UNKOWN, TARGET, TRIANGLE, RECTANGLE, SQUARE, PENTAGON, CIRCLE};
using Contour = vector<cv::Point>;
using ColorRange = tuple<std::array<int, 3>, std::array<int, 3>>;

class ColorDetector {
public:
  ColorDetector(const string name, const vector<ColorRange> color_range);
  std::tuple<ShapeType, cv::Rect> detect(cv::Mat src);
  string getName();
  
private:
  string name;
  vector<ColorRange> colorRanges;
  cv::Mat frame_mask;
  
  void generateMask(cv::Mat frame);
  std::tuple<ShapeType, cv::Rect> detectShape(Contour c);
};




#endif /* LifiDetection_hpp */
