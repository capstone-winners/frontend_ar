//
//  TargetDetector.cpp
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

#include "TargetDetector.hpp"

using namespace cv;

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
  Mat markup_frame=frame.clone();
  
  for (ColorDetector& detector : this->detectors) {
    const auto ret = detector.Detect(frame);
    ShapeType detected = std::get<0>(ret);
    cv::Rect box = std::get<1>(ret);
    this->AddToHistory(detector.GetName(), detected, box);
  }
  this->history.AdvanceFrameCount();
  
  this->frameCount += 1;
  if ((this->frameCount - this->lastDetected) % (this->framesPerMessage * 3) == 0) {
    printf("resetting frame_count\n\t%d\n\t%d\n", this->frameCount, this->lastDetected);
    this->detectedFrame = false;
  }
  
  // Draw things on the frame.
  this->AddMessageToFrame(markup_frame);
  this->AddFailedIouToFrame(markup_frame);
  this->AddTargetHistoryDetailToFrame(markup_frame);

  return markup_frame;
}

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
  }
}

void TargetDetector::FrameCompleteCallback(HistoryInterpreter* interp) {
  this->detectedFrame = true;
  this->lastDetected = this->frameCount;
  this->binMessage = interp->PopOutput();
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
      continue;
    }
                                                                           
    const std::vector<string> msgs = {
      "pos: " + BoxToString(entry.lastPos),
      "state: " + HistoryInterpreterStateToString(hi.GetState()),
      "buffer: " + VectorToString(hi.GetBuffer()),
      "output: " + VectorToString(hi.GetOutput())};
                                                                           
    int index = 0;
    for (const std::string& msg : msgs) {
      const int tr_x = std::get<0>(entry.lastPos) + std::get<2>(entry.lastPos);
      const int tr_y = std::get<1>(entry.lastPos) + int(index * 2 * estimated_font_size * font_scale);
                                                                         
      putText(markup_frame, msg, {tr_x, tr_y}, FONT_HERSHEY_SIMPLEX, 
      font_scale, WHITE, 1);
      index++;
    }
    
  }

}
