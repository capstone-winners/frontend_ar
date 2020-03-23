#include <iostream>
#include <opencv2/opencv.hpp>
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"
#include <opencv2/highgui/highgui_c.h>

#include "TargetDetector.hpp"

using namespace cv;
using namespace std;

Mat ImgWithTarget(Scalar color) {
  Mat img(500, 500, CV_8UC3, Scalar(0, 0, 0));
  cv::rectangle(img, cv::Point2f( 30, 30 ), cv::Point2f(100, 100), color, -1);

  return img;
}

int main(int argc, char **argv)
{
  //std::cout << cv::getBuildInformation() << std::endl;
  const Mat blue = ImgWithTarget(Scalar(255, 0, 0));
  const Mat green = ImgWithTarget(Scalar(0, 255, 0));
  const Mat red = ImgWithTarget(Scalar(0, 0, 255));

  std::vector<Mat> seq = {
    blue, blue, blue, blue,
    green, green, green, green, 
    red, red, red, red, 
    green, green, green, green, 
    green, green, green, green, 
    green, green, green, green, 
    green, green, green, green, 
    red, red, red, red, 
    green, green, green, green, 
    red, red, red, red, 
    blue, blue, blue, blue,
  };

  TargetDetector detector;
  for(int ii = 0; ii < 10; ++ii) {
    for(Mat img : seq) {
      imshow("img", detector.Detect(img));
      waitKey(500);
    }
  }
  
  return 0;
}
