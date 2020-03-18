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

void TargetDetector::Detect(Mat frame) {
  Mat markupFrame=frame.clone();
  
  for (ColorDetector& detector : this->detectors) {
    const auto ret = detector.detect(frame);
    ShapeType detected = std::get<0>(ret);
    cv::Rect box = std::get<1>(ret);
    this->AddToHistory(detector.getName(), detected, box);
  }
  this->history.AdvanceFrameCount();
  
  this->frameCount += 1;
  if ((this->frameCount - this->lastDetected) % (this->framesPerMessage * 3) == 0) {
    printf("resetting frame_count\n\t%d\n\t%d", this->frameCount, this->lastDetected);
    this->detectedFrame = false;
  }
  
  //this->add_message_to_frame(markupFrame)
  //this->add_failed_iou_to_frame(markupFrame)
  //this->add_target_history_detail_to_frame(markupFrame)
  //return markup_frame
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
