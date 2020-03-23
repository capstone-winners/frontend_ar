//
//  DetectorConstants.h
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

#ifndef DetectorConstants_h
#define DetectorConstants_h

#include <array>
#include <vector>
#include <tuple>
#include <opencv2/opencv.hpp>

using std::array;
using std::vector;
using std::tuple;

using ColorRange = tuple<std::array<int, 3>, std::array<int, 3>>;

enum DetectedState {SENTINEL, HIGH, LOW, MISSING};

constexpr int FRAME_SIZE = 9; // 1 Sentinel, 8 Payload
constexpr int RX_FREQ = 120;
constexpr int TX_FREQ = 30;
constexpr int BUFFER_SIZE = RX_FREQ/TX_FREQ;

// COLORS
const cv::Scalar BLACK(0, 0, 0);
const cv::Scalar WHITE(255, 255, 255);
const cv::Scalar BLUE(255, 0, 0);
const cv::Scalar GREEN(0, 255, 0);
const cv::Scalar RED(0, 0, 255);

// Color Ranges
// define the lower and upper boundaries of the "green"
// ball in the HSV color space. NB the hue range in
// opencv is 180, normally it is 360
constexpr array<int, 3> greenLower = {50, 50, 50};
constexpr array<int, 3> greenUpper = {70, 255, 255};
const vector<ColorRange> greenRange {make_tuple(greenLower, greenUpper)};

constexpr array<int, 3>redLower = {0, 50, 20};
constexpr array<int, 3> redUpper = {5, 255, 255};
constexpr array<int, 3> redLower2 = {170, 50, 20};
constexpr array<int, 3> redUpper2 = {180, 255, 255};
const vector<ColorRange> redRange {make_tuple(redLower, redUpper), make_tuple(redLower2, redUpper2)};

constexpr array<int, 3> blueLower = {110, 50, 50};
constexpr array<int, 3> blueUpper = {130, 255, 255};
const vector<ColorRange> blueRange {make_tuple(blueLower, blueUpper)};

#endif /* DetectorConstants_h */
