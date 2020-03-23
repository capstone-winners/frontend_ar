//
//  LifiDetection.cpp
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

#include "ColorDetector.hpp"
#include <opencv2/opencv.hpp>
#include "opencv2/highgui/highgui.hpp"

using namespace cv;

const string ShapeTypeToString(int enumValue)
{
  return ShapeTypeStrings[enumValue];
}

ColorDetector::ColorDetector(const string name, const vector<ColorRange> color_range) {
  this->name = name;
  this->colorRanges = color_range;
}

string ColorDetector::GetName() {
  return this->name;
}

std::tuple<ShapeType, Rect> ColorDetector::Detect(const Mat frame) {
  // Create a mask based on the colors of this tracker
  this->GenerateMask(frame);

  // find contours in the mask and initialize the current
  // (x, y) center of the ball
  vector<Contour> cnts;
  findContours(this->frame_mask, cnts, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
  
  // only proceed if at least one contour was found
  if (cnts.size() > 0) {
    
    auto isTarget = [this](const Contour a) {
      return get<0>(this->DetectShape(a)) == TARGET;
    };
    
    auto cmpContour = [](const Contour cntA, const Contour cntB) {return contourArea(cntA) > contourArea(cntB);};
    
    // find the largest contour in the mask, then use
    // it to compute the shape and bounding box if its a target
    sort(cnts.rbegin(), cnts.rend(), cmpContour);
    
    auto itr = find_if(cnts.begin(), cnts.end(), isTarget);
    if(itr == cnts.end()) {
      printf("[ColorDetector]: Contour not found!");
      return make_tuple(UNKOWN, Rect());
    }
    
    return DetectShape(*itr);
  }
  
  return make_tuple(UNKOWN, Rect());
}

void ColorDetector::GenerateMask(const Mat frame) {
  
  // Simple HSV color space tracking
  // resize the frame, blur it, and convert it to the HSV color space
  Mat blurred;
  GaussianBlur(frame, blurred, Size(11, 11), 0);

  Mat hsv;
  cvtColor(blurred, hsv, COLOR_BGR2HSV);

  // construct a mask for the color then perform
  // a series of dilations and erosions to remove any small
  // blobs left in the mask
  Mat mask = cv::Mat::zeros(frame.size(), CV_8UC1);
  
  // imshow("frame", frame);
  for (const ColorRange& range : colorRanges) {
    const array<int, 3> lower = get<0>(range);
    const array<int, 3> upper = get<1>(range);
    
    Mat temp;
    inRange(hsv, lower, upper, temp);
    mask = mask | temp;

    // imshow("c", mask);
    // waitKey(3000);
  }
  
  erode(mask, mask, 2);
  dilate(mask, mask, 2);

  this->frame_mask = mask;
}


std::tuple<ShapeType, Rect> ColorDetector::DetectShape(Contour c) {
  // initialize the shape name and approximate the contour
  ShapeType shape = UNKOWN;
  const double peri = arcLength(c, true);
  Contour approx;
  approxPolyDP(c, approx, 0.03 * peri, true);
  const Rect box = boundingRect(approx);
  
  switch (approx.size()) {
    case 3: {
      shape = TRIANGLE;
      break;
    }
    case 4: {
      const double a_ratio = box.width / float(box.height);
      const double b_area = box.area();
      const double c_area = contourArea(c);
      //Make sure the countour area is pretty similar to the estimated
      //bounding box area. This will eliminate any weird, poor shapes
      //that get computed.
      if(abs(c_area - b_area) > .7 * b_area) {
        shape = RECTANGLE;
        break;
      }
      
      //a square will have an aspect ratio that is approximately
      //equal to one, otherwise, the shape is a rectangle
      if(a_ratio >= 0.70 and a_ratio <= 1.30) {
        shape = TARGET;
      } else {
        shape = RECTANGLE;
      }
      break;
    }
    // if the shape is a pentagon, it will have 5 vertices
    case 5: {
      shape = PENTAGON;
      break;
    }
    default: {
      shape = CIRCLE;
      break;
    }
  }
  
  return make_tuple(shape, box);
}
