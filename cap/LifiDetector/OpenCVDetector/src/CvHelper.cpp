//
//  CvHelper.cpp
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//
#include <math.h>
#include <stdio.h>
#include <algorithm>

#include "CvHelper.hpp"

using std::max;
using std::min;

double EuclideanDistanceCenter(const Box boxA, const Box boxB) {
  const double cx_A = boxA[0] + (boxA[2]/2);
  const double cy_A = boxA[1] + (boxA[3]/2);
  
  const double cx_B = boxB[0] + (boxB[2]/2);
  const double cy_B = boxB[1] + (boxB[3]/2);
  
  return pow(pow(cx_A-cx_B, 2) + pow(cy_A-cy_B, 2),.5);
}

Box ConvertBoxRep(const Box box) {
  // converts from [x, y, w, h] to [x1, y1, x2, y2]
  return {box[0], box[1], box[0] + box[2], box[1] + box[3]};
}

double CalculateIou(const Box boxA, const Box boxB) {
  // expects format to be [x1, y1, x2, y2]
  // determine the (x, y)-coordinates of the intersection rectangle
  
  const int xA = max(boxA[0], boxB[0]);
  const int yA = max(boxA[1], boxB[1]);
  const int xB = min(boxA[2], boxB[2]);
  const int yB = min(boxA[3], boxB[3]);
  
  // compute the area of intersection rectangle
  const int interArea = max(0, xB - xA + 1) * max(0, yB - yA + 1);
  // compute the area of both the prediction and ground-truth
  // rectangles
  int boxAArea = (boxA[2] - boxA[0] + 1) * (boxA[3] - boxA[1] + 1);
  int boxBArea = (boxB[2] - boxB[0] + 1) * (boxB[3] - boxB[1] + 1);
  
  // compute the intersection over union by taking the intersection
  // area and dividing it by the sum of prediction + ground-truth
  // areas - the interesection area
  double iou = interArea / float(boxAArea + boxBArea - interArea);
  //return the intersection over union value
  return iou;
}


std::string BoxToString(const Box box) {
  std::string str;
  for (int i : box) {
    str += (std::to_string(i) + " ");
  }
  
  return str;
}


std::string printType(cv::Mat frame) {
  std::string r;

  uchar depth = frame.type() & CV_MAT_DEPTH_MASK;
  uchar chans = 1 + (frame.type() >> CV_CN_SHIFT);

  switch ( depth ) {
    case CV_8U:  r = "8U"; break;
    case CV_8S:  r = "8S"; break;
    case CV_16U: r = "16U"; break;
    case CV_16S: r = "16S"; break;
    case CV_32S: r = "32S"; break;
    case CV_32F: r = "32F"; break;
    case CV_64F: r = "64F"; break;
    default:     r = "User"; break;
  }

  r += "C";
  r += (chans+'0');

  printf("Matrix: %s %dx%d \n", r.c_str(), frame.cols, frame.rows );
  return r;
}