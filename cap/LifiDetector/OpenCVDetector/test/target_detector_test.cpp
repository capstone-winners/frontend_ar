#include "stdio.h"
#include "gtest/gtest.h"
#include "gmock/gmock.h"
#include "TargetDetector.hpp"

#include <opencv2/opencv.hpp>

#include <memory>

using namespace cv;

namespace TestTargetDetector {

class TestTargetDetector : public ::testing::Test {
 protected:  
  // Declares the variables your tests want to use.
  std::shared_ptr<TargetDetector> test_obj; 

  const cv::Scalar BACKGROUND = cv::Scalar(0, 0, 0);
  const cv::Scalar BLUE = cv::Scalar(255, 0, 0);
  const cv::Scalar GREEN = cv::Scalar(0, 255, 0);
  const cv::Scalar RED = cv::Scalar(0, 0, 255);
  const int SOLID = -1;

  Mat green;
  Mat red;
  Mat blue;
  Mat empty;

  void SetUp() override {
    test_obj = std::make_shared<TargetDetector>();
    
    green = Mat(500, 500, CV_8UC3, BACKGROUND);
    cv::rectangle(green, cv::Point2f( 10, 10 ), cv::Point2f(100, 100), GREEN, SOLID);
    
    red = Mat(500, 500, CV_8UC3, BACKGROUND);
    cv::rectangle(red, cv::Point2f( 10, 10 ), cv::Point2f(100, 100), RED, SOLID);
    
    blue = Mat(500, 500, CV_8UC3, BACKGROUND);
    cv::rectangle(blue, cv::Point2f( 10, 10 ), cv::Point2f(100, 100), BLUE, SOLID);
    
    empty = Mat(500, 500, CV_8UC3, BACKGROUND);
  }
};


/**
 * Make sure the frame complete callback is triggere.
 */
TEST_F(TestTargetDetector, HappyPathBehavior) {
  test_obj->Detect(blue.clone());
  test_obj->Detect(blue.clone());
  test_obj->Detect(blue.clone());
}

}  // namespace

