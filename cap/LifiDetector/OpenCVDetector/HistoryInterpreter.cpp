//
//  HistoryInterpreter.cpp
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

#include "HistoryInterpreter.hpp"

HistoryInterpreter::HistoryInterpreter(const string name, std::function<void(HistoryInterpreter*)> frameCompleteCallback) :
  name(name),
  frameCompleteCallback(frameCompleteCallback) {
  
}

void HistoryInterpreter::Process(const DetectedState entry) {
  switch (this->state) {
    case WARMUP:
      HandleWarmup(entry);
      break;
    case DETECTED:
      HandleDetected(entry);
      break;
    case PROCESSING:
      HandleProcessing(entry);
      break;
  }
}

vector<int> HistoryInterpreter::PopOutput() {
  const vector<int> temp(this->output);
  this->output.clear();
  return temp;
}

void HistoryInterpreter::HandleWarmup(const DetectedState entry) {
  if(entry == SENTINEL) {
    this->state = DETECTED;
  }
}

void HistoryInterpreter::HandleDetected(const DetectedState entry){
  if(entry != SENTINEL && entry != MISSING) {
    this->state = PROCESSING;
    this->buffer = {entry};
  }
  
}
void HistoryInterpreter::HandleProcessing(const DetectedState entry){
  
  if(entry == MISSING){
    printf("[History interpretor %s]: missing entry", this->name.c_str());
  }
  
  this->buffer.push_back(entry);
  
  if (this->buffer.size() == this->maxBufferSize) {
    HandleBufferComplete(entry);
  }
}

void HistoryInterpreter::HandleBufferComplete(const DetectedState entry) {
  const int numLow = int(count(this->buffer.begin(), this->buffer.end(), LOW));
  const int numHigh = int(count(this->buffer.begin(), this->buffer.end(), HIGH));
  const int numSentinel = int(count(this->buffer.begin(), this->buffer.end(), SENTINEL));
  const int numMissing = int(count(this->buffer.begin(), this->buffer.end(), MISSING));
  
  if (numMissing > numLow + numHigh + numSentinel) {
    // We missed a lot of frames. Lets start over.
    printf("[History interpretor %s]: missing a lot of frames. resetting...", this->name.c_str());
    printf("\t%d/%d missing", numMissing, this->maxBufferSize);
    
    this->state = WARMUP;
    this->output.clear();
    this->buffer.clear();
    
    return;
  }
  
  if (numSentinel > numLow && numSentinel > numHigh) {
    // We detected more sentinal values than anything else. Move to DETECTED.
    // Handle completed frame.
    this->state = DETECTED;
    this->frameCompleteCallback(this);
  } else{
    // This contained a data frame. Store this in the output.
    this->output.push_back(int(numHigh > numLow));
  }
  
  // Buffer is completed. Reset it.
  this->buffer.clear();
}
