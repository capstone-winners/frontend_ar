#include "stdio.h"
#include "gtest/gtest.h"
#include "gmock/gmock.h"
#include "ColorDetector.hpp"
#include "DetectorConstants.h"

#include <opencv2/opencv.hpp>

#include <memory>

using namespace cv;
using testing::ElementsAre;

namespace TestColorDetector {

class TestColorDetector : public ::testing::Test {
 protected:  
  // Declares the variables your tests want to use.
  std::shared_ptr<ColorDetector> test_obj_blue; 
  std::shared_ptr<ColorDetector> test_obj_green; 
  std::shared_ptr<ColorDetector> test_obj_red; 
  Mat green;
  Mat red;
  Mat blue;
  Mat empty;

  void SetUp() override {
    test_obj_blue = std::make_shared<ColorDetector>("blue", blueRange);
    test_obj_green = std::make_shared<ColorDetector>("green", greenRange);
    test_obj_red = std::make_shared<ColorDetector>("red", redRange);

    const cv::Scalar BACKGROUND(0, 0, 0);
    
    blue = Mat(500, 500, CV_8UC3, BACKGROUND);
    cv::rectangle(blue, cv::Point2f( 10, 10 ), cv::Point2f(100, 100), cv::Scalar( 255, 0, 0), -1 );

    green = Mat(500, 500, CV_8UC3, BACKGROUND);
    cv::rectangle(green, cv::Point2f( 10, 10 ), cv::Point2f(100, 100), cv::Scalar( 0, 255, 0 ), -1);
    
    red = Mat(500, 500, CV_8UC3, BACKGROUND);
    cv::rectangle(red, cv::Point2f( 10, 10 ), cv::Point2f(100, 100), cv::Scalar( 0, 0, 255), -1 );
    
    empty = Mat(500, 500, CV_8UC3, BACKGROUND);
  }

  void TestHelper(std::shared_ptr<ColorDetector> detector, Mat img, ShapeType expected) {
    std::tuple<ShapeType, cv::Rect> resp;
    resp = detector->Detect(img);
    EXPECT_EQ(std::get<0>(resp), expected);
  }

};


/**
 * Make sure the frame complete callback is triggere.
 */
TEST_F(TestColorDetector, DetectSquare) {
  TestHelper(test_obj_blue, blue, TARGET);
  TestHelper(test_obj_green, green, TARGET);
  TestHelper(test_obj_red, red, TARGET);
}

/**
 * Make sure the frame complete callback is triggere.
 */
TEST_F(TestColorDetector, NoSquare) {
  TestHelper(test_obj_blue, empty, UNKOWN);
  TestHelper(test_obj_green, empty, UNKOWN);
  TestHelper(test_obj_red, empty, UNKOWN);
}

}  // namespace

