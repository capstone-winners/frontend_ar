//
//  HistoryInterpreter.hpp
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

#ifndef HistoryInterpreter_hpp
#define HistoryInterpreter_hpp

#include <stdio.h>
#include <string>
#include <vector>
#include <functional>

#include "DetectorConstants.h"

using std::string;
using std::vector;

class HistoryInterpreter {
public:
  enum State {WARMUP, DETECTED, PROCESSING};
  
  HistoryInterpreter(const string name, std::function<void(HistoryInterpreter*)> frameCompleteCallback);
  
  void Process(const DetectedState entry);
  vector<int> PopOutput();
  
  State GetState() const;
  
  string GetName() const;
  
  int GetMaxBufferSize() const;
  
  vector<int> GetOutput() const;
  
  vector<DetectedState> GetBuffer() const;
  
private:
  string name;
  HistoryInterpreter::State state = HistoryInterpreter::WARMUP;
  int maxBufferSize = BUFFER_SIZE;
  vector<DetectedState> buffer = {};
  vector<int> output = {};
  std::function<void(HistoryInterpreter*)> frameCompleteCallback;
  
  void HandleWarmup(const DetectedState entry);
  void HandleDetected(const DetectedState entry);
  void HandleProcessing(const DetectedState entry);
  
  void HandleBufferComplete(const DetectedState entry);
};

#endif /* HistoryInterpreter_hpp */
