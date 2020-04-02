//
//  TargetDetector.cpp
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

#include "TargetDetector.hpp"

using namespace cv;

bool DRAW_MARKUP = true;

TargetDetector::TargetDetector() :
greenTracker("green", greenRange),
redTracker("red", redRange),
blueTracker("blue", blueRange),
detectors({greenTracker, redTracker, blueTracker})
{
  using namespace std::placeholders; // to get _1, and _2
  this->history.AddFrameCompleteHandler(std::bind(&TargetDetector::FrameCompleteCallback, this, _1));
  this->history.AddIouFailureHandler(std::bind(&TargetDetector::FailedIouCallback, this, _1, _2));
}

cv::Mat TargetDetector::Detect(const Mat frame) {
  // Mat blurred;
  // GaussianBlur(frame, blurred, Size(kernel_size, kernel_size), 0);
  
  Mat hsv;
  cvtColor(frame, hsv, COLOR_BGR2HSV);
  //cvtColor(blurred, hsv, COLOR_BGR2HSV);
  
  return DetectFromHsv(hsv, frame);
}

cv::Mat TargetDetector::DetectFromHsv(const Mat hsv, const Mat frame) {
  // Simple HSV color space tracking
  // resize the frame, blur it, and convert it to the HSV color space
  
  Mat markup_frame;
  if (DRAW_MARKUP) {
    markup_frame=frame.clone();
  }
  
  // Run this frame through every detector. Only keep the largest box
  // from the detections. (Assumes that there is only a SINGLE target
  // in a frame).
  vector<DetectorResponse> responses(this->detectors.size());
  std::transform(this->detectors.begin(), this->detectors.end(),
                 responses.begin(),
                 [hsv](ColorDetector detector) {
    return detector.DetectFromHsv(hsv);
  });
  DetectorResponse max_response =
  *std::max_element(responses.begin(),responses.end(),
                    [](DetectorResponse A, DetectorResponse B) {
    return A.box.area() < B.box.area();});
  
  if(max_response.shape == UNKNOWN) {
    printf("Missing frame!!!\n");
  } else {
//    printf("[%d]Response: %s\n", this->frameCount, max_response.name.c_str());
//    printf("\tpos: (%d,%d,%d,%d)\n", max_response.box.x, max_response.box.y,
//           max_response.box.width, max_response.box.height);
  }
  
  // Add the largest response.
  this->AddToHistory(max_response.name, max_response.shape, max_response.box);
  this->history.AdvanceFrameCount();
  
  this->frameCount += 1;
  if ((this->frameCount - this->lastDetected) % (this->framesPerMessage * 3) == 0) {
    printf("[TargetDetector] resetting frame_count\n");
    printf("\tFrameCount: %d\n", this->frameCount);
    printf("\tLastDetected: %d\n", this->lastDetected);
    this->detectedFrame = false;
    
    this->PrintLargestHistoryEntry();
  }
  
  // Draw things on the frame.
  if(DRAW_MARKUP) {
    if(max_response.shape == TARGET) {
      this->AddMaxResponse(markup_frame, max_response);
    }
    this->AddMessageToFrame(markup_frame);
    this->AddFailedIouToFrame(markup_frame);
    this->AddTargetHistoryDetailToFrame(markup_frame);
    
    return markup_frame;
  }
  
  return cv::Mat::zeros({16, 16}, CV_8UC3);
}

void TargetDetector::SetFrameCompleteCallback(std::function<void(std::vector<int>)> func) {
  this->external_func = func;
};

void TargetDetector::AddToHistory(string detectorName, ShapeType detected, Rect box) {
  if (detected == TARGET) {
    //print("{}\t{}".format(tracker.name, box))
    const Box arrBox = {box.x, box.y, box.width, box.height};
    
    if(detectorName == "red") {
      this->history.AddToHistory(HIGH, arrBox);
    } else if (detectorName == "green") {
      this->history.AddToHistory(LOW, arrBox);
    }else if (detectorName == "blue") {
      this->history.AddToHistory(SENTINEL, arrBox);
    }
  } else {
    //printf("%s\n", ShapeTypeToString(detected).c_str());
  }
}

void TargetDetector::FrameCompleteCallback(HistoryInterpreter* interp) {
  this->detectedFrame = true;
  this->lastDetected = this->frameCount;
  this->binMessage = interp->PopOutput();
  
  if(this->external_func) {
    this->external_func(binMessage);
  }
}

void TargetDetector::FailedIouCallback(const Box oldBox, const Box newBox) {
}

template <class T> 
string VectorToString(std::vector<T> v) {
  string s;
  for(const T& t: v) {
    s += (std::to_string(t) + " ");
  }
  
  return s;
}

void TargetDetector::AddMaxResponse(cv::Mat markup_frame, DetectorResponse response) {
  try {
    Scalar color;
    if(response.name == "red") {
      color = RED;
    } else if(response.name == "blue") {
      color = BLUE;
    } else if(response.name == "green") {
      color = GREEN;
    } else {
      color = WHITE;
    }
    
    drawContours(markup_frame, vector<Contour>(1, response.contour), -1, color);
    const Rect box = response.box;
    const string msg = ShapeTypeToString(response.shape) + " [" + response.name + "]";
    putText(markup_frame, msg,
            Point(box.x + box.width, box.y),
            FONT_HERSHEY_SIMPLEX, .5, WHITE, 1);
  } catch (cv::Exception e) {
    printf("[TargetDetector]: Error drawing max response!\n");
  }
}

void TargetDetector::AddMessageToFrame(cv::Mat markup_frame) {
  string msg;
  if(this->detectedFrame) {
    msg = std::to_string(this->lastDetected) + ": [" + VectorToString<int>(this->binMessage) + "]";
  } else {
    msg = "No msg detected";
  }
  
  const Point pos(0, int(markup_frame.size().height * .9));
  putText(markup_frame, msg, pos,FONT_HERSHEY_SIMPLEX, .5, WHITE, 1);
}

void TargetDetector::AddFailedIouToFrame(cv::Mat markup_frame) {
  
}

void TargetDetector::AddTargetHistoryDetailToFrame(cv::Mat markup_frame) {
  const int estimated_font_size = 22;
  const double font_scale = .3;
  
  for (const Entry& entry : this->history.GetHistory()) {
    const HistoryInterpreter& hi = entry.interpreter;
    if (hi.GetBuffer().size() ==  0 && hi.GetOutput().size() == 0) {
      //continue;
    }
    
    const std::vector<string> msgs = {
      "pos: " + BoxToString(entry.lastPos),
      "state: " + HistoryInterpreterStateToString(hi.GetState()),
      "buffer: " + VectorToString(hi.GetBuffer()),
      "output: " + VectorToString(hi.GetOutput())};
    
    int index = 0;
    for (const std::string& msg : msgs) {
      const int tr_x = std::get<0>(entry.lastPos) + std::get<2>(entry.lastPos);
      const int tr_y = std::get<1>(entry.lastPos)
      + int(2 * estimated_font_size * font_scale)
      + int(index * 2 * estimated_font_size * font_scale);
      
      putText(markup_frame, msg, {tr_x, tr_y}, FONT_HERSHEY_SIMPLEX,
              font_scale, WHITE, 1);
      index++;
    }
    
  }
}

void TargetDetector::PrintLargestHistoryEntry() {
  auto hist =this->history.GetHistory();
  if(hist.empty()) {
    printf("Empty history!\n");
    return;
  }
  Entry max_itr = *std::max_element(hist.begin(), hist.end(),
                                    [](Entry A, Entry B) {
    int areaA =(A.lastPos[2] * A.lastPos[3]);
    int areaB =(B.lastPos[2] * B.lastPos[3]);
    return areaA < areaB;});
  
  const HistoryInterpreter& hi = max_itr.interpreter;
  const std::vector<string> msgs = {
    "pos: " + BoxToString(max_itr.lastPos),
    "state: " + HistoryInterpreterStateToString(hi.GetState()),
    "buffer: " + VectorToString(hi.GetBuffer()),
    "output: " + VectorToString(hi.GetOutput())};
  
  printf("**************\n");
  printf("Max Response\n");
  printf("**************\n");
  for (const std::string& msg : msgs) {
    printf("\t%s\n", msg.c_str());
  }
  printf("**************\n\n");
}
