//
//  TargetHistory.hpp
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

#ifndef TargetHistory_hpp
#define TargetHistory_hpp

#include <stdio.h>
#include <array>
#include <vector>
#include <functional>

#include "DetectorConstants.h"
#include "HistoryInterpreter.hpp"
#include "CvHelper.hpp"

struct Entry {
  std::array<int, 4> lastPos;
  int lastFrame;
  int lastActiveFrame;
  HistoryInterpreter interpreter;
};

class TargetHistory {
  
  public:
  TargetHistory();
  void AddToHistory(DetectedState state, Box box);
  void AdvanceFrameCount();
  void AddFrameCompleteHandler(std::function<void(HistoryInterpreter*)> frameCompleteCallback);
  void AddIouFailureHandler(std::function<void(const Box oldBox, const Box newBox)> iouFailedCallback);
  std::vector<Entry> GetHistory();
  
  private:
  std::vector<Entry> history{};
  int maxCorrespondingDistance = 25;
  double iouThreshold = 0.7;
  int frameNumber = 0;
  int maxFramesToLive = 30;
  std::function<void(HistoryInterpreter*)> frameCompleteCallback;
  std::function<void(Box oldBox, Box newBox)> iouFailedCallback;
  
  Entry CreateHistoryEntry(DetectedState state, Box box);
  Entry UpdateHistoryEntry(Entry old, DetectedState state, Box box);
  void RecordNoDetections();
};


#endif /* TargetHistory_hpp */
