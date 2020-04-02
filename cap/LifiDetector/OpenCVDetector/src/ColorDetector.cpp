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
int kernel_size = 11;

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

DetectorResponse ColorDetector::Detect(const Mat frame) {
  // Simple HSV color space tracking
  // resize the frame, blur it, and convert it to the HSV color space
  // Mat blurred;
  // GaussianBlur(frame, blurred, Size(kernel_size, kernel_size), 0);
  // Mat blurred(frame);

  Mat hsv;
  cvtColor(frame, hsv, COLOR_BGR2HSV);
  //cvtColor(blurred, hsv, COLOR_BGR2HSV);
  
  return this->DetectFromHsv(hsv);
}

DetectorResponse ColorDetector::DetectFromHsv(const Mat hsv) {
  
  // Create a mask based on the colors of this tracker
  this->GenerateMask(hsv);

  // find contours in the mask and initialize the current
  // (x, y) center of the ball
  this->cnts.clear();
  findContours(this->frame_mask, this->cnts, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
  
  // only proceed if at least one contour was found
  if (!this->cnts.empty()) {
    auto cmpContour = [](const Contour cntA, const Contour cntB) {return contourArea(cntA) < contourArea(cntB);};
    
    // find the largest contour in the mask, then use
    // it to compute the shape and bounding box if its a target
    sort(this->cnts.rbegin(), this->cnts.rend(), cmpContour);
    
    auto isTarget = [this](const Contour a) {
      return get<0>(this->DetectShape(a)) == TARGET;
    };
    auto itr = find_if(this->cnts.begin(), this->cnts.end(), isTarget);
    if(itr == this->cnts.end()) {
      //printf("[ColorDetector]: Contour not found!");
      return MakeDetectorResponse(UNKNOWN, Rect(), {});
    }
    
    std::tuple<ShapeType, Rect> resp = DetectShape(*itr);
    return MakeDetectorResponse(std::get<0>(resp), std::get<1>(resp), *itr);
  }
  
  return MakeDetectorResponse(UNKNOWN, Rect(), {});
}

void ColorDetector::DrawContours(Mat markup_frame) {
  
  for (Contour cnt : cnts) {
    auto response = this->DetectShape(cnt);
    const ShapeType shape = get<0>(response);
    if(shape == UNKNOWN) {
      // SKIP UNKOWNS
      continue;
    }
    drawContours(markup_frame, vector<Contour>(1, cnt), -1, Scalar(0, 255, 255));
    const Rect box = get<1>(response);
    putText(markup_frame, ShapeTypeToString(shape),
            Point(box.x + box.width, box.y),
            FONT_HERSHEY_SIMPLEX, .5, WHITE, 1);
  }
}

void ColorDetector::GenerateMask(const Mat frame) {
  // construct a mask for the color then perform
  // a series of dilations and erosions to remove any small
  // blobs left in the mask
  Mat mask = cv::Mat::zeros(frame.size(), CV_8UC1);
  
  // imshow("frame", frame);
  for (const ColorRange& range : colorRanges) {
    const array<int, 3> lower = get<0>(range);
    const array<int, 3> upper = get<1>(range);
    
    Mat temp;
    inRange(frame, lower, upper, temp);
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
  ShapeType shape = UNKNOWN;
  const double peri = arcLength(c, true);
  Contour approx;
  approxPolyDP(c, approx, 0.03 * peri, true);
  const Rect boundingBox = boundingRect(approx);
  
  const double a_ratio = boundingBox.width / float(boundingBox.height);
  const double b_area = boundingBox.area();
  const double c_area = contourArea(c);
  
  //Make sure the countour area is pretty similar to the estimated
  //bounding box area. This will eliminate any weird, poor shapes
  //that get computed.
  if(abs(c_area - b_area) > .90 * b_area) {
    // Weirdly Shaped - Poor IOU.
  } else {
    // IOU mostly matches the bounding rect.
    if(a_ratio >= 0.80 and a_ratio <= 1.2) {
      // shape is mostly REGULAR
      if(approx.size() == 4) {
        shape = TARGET;
      }
    }
  }
  
  /*
  switch (approx.size()) {
    case 3: {
      shape = TRIANGLE;
      break;
    }
    case 4: {
      
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
  */
  return make_tuple(shape, boundingBox);
}

DetectorResponse ColorDetector::MakeDetectorResponse(ShapeType type, cv::Rect box, Contour c) {
  DetectorResponse resp;
  resp.name = this->name;
  resp.box = box;
  resp.shape = type;
  resp.contour = c;
  return resp;
}
