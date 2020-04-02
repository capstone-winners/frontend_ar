//
//  TargetHistory.cpp
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//
#include "TargetHistory.hpp"
#include <iostream>

TargetHistory::TargetHistory()
{
  
}

void TargetHistory::AddToHistory(const DetectedState state, const Box box) {
  if(history.size() == 0) {
    history.push_back(this->CreateHistoryEntry(state, box));
  }
  
  auto compareDistanceCenter = [box](const Entry entryA, const Entry entryB) {
    return EuclideanDistanceCenter(entryA.lastPos, box) > EuclideanDistanceCenter(entryB.lastPos, box);
  };
  
  // Determine what entry has the minimum distance to the new box.
  const auto itr = min_element(this->history.begin(), this->history.end(), compareDistanceCenter);
  const auto minIndex = std::distance(this->history.begin(), itr);
  const Entry minEntry = *itr;
  const double minDistance = EuclideanDistanceCenter(box, minEntry.lastPos);
  
  if (minDistance > this->maxCorrespondingDistance) {
    // Consider this a new element:
    this->history.push_back(this->CreateHistoryEntry(state, box));
  } else {
    // Consider this an existing element
    const Box minBox = minEntry.lastPos;
    
    // Determine if there is enough overlap to be the same
    const double iou = CalculateIou(ConvertBoxRep(box), ConvertBoxRep(minBox));
    
    if(iou > this->iouThreshold) {
      this->history[minIndex] = this->UpdateHistoryEntry(minEntry, state, box);
    } else {
      printf("failed iou threshold!!! %f\n", iou);
      iouFailedCallback(minBox, box);
    }
  }
}

void TargetHistory::AdvanceFrameCount() {
  // Note which entries were missing on this frame iteration.
  this->RecordNoDetections();
  
  // Bump the frame number.
  this->frameNumber = (this->frameNumber + 1) % this->maxFramesToLive;
  
  // Remove any entries that are missing. Entry is missing if the bumped frame number
  // is equal to the last time this entry was actually seen.
  auto isMissing = [this](Entry const x) {return x.lastActiveFrame == this->frameNumber; };
  auto res = std::remove_if(this->history.begin(), this->history.end(), isMissing);
  this->history.erase(res, this->history.end());
}

void TargetHistory::AddFrameCompleteHandler(std::function<void(HistoryInterpreter*)> frameCompleteCallback) {
  this->frameCompleteCallback = frameCompleteCallback;
};

void TargetHistory::AddIouFailureHandler(std::function<void(const Box oldBox, const Box newBox)> iouFailedCallback) {
  this->iouFailedCallback = iouFailedCallback;
}

std::vector<Entry> TargetHistory::GetHistory() {
  return this->history;
}

Entry TargetHistory::CreateHistoryEntry(DetectedState state, Box box) {
  using namespace std::placeholders; // for `_1`
  HistoryInterpreter interp(BoxToString(box), frameCompleteCallback);
  
  const Entry newEntry {
    box,
    this->frameNumber,
    this->frameNumber,
    interp
  };
  
  return newEntry;
}

Entry TargetHistory::UpdateHistoryEntry(Entry old, DetectedState state, Box box) {
  old.interpreter.Process(state);
  
  const int lastFrame = state != MISSING ? this->frameNumber : old.lastActiveFrame;
  const Entry newEntry {
    box,
    this->frameNumber,
    lastFrame,
    old.interpreter
  };
  
  /*std::cout << "Buffer: ";
  for(const auto i : old.interpreter.GetBuffer()) {
    std:: cout << i;
  }
  std::cout << std::endl;*/
  
  return newEntry;
}

void TargetHistory::RecordNoDetections() {
  for (Entry& entry : this->history) {
    // If this entry wasn't updated with this frame number, the entry was missing.
    // Record the frame as missing.
    if (entry.lastFrame != this->frameNumber) {
      //std::cout << BoxToString(entry.lastPos) << " missing frame!" << std::endl;
      entry.lastFrame = this->frameNumber;
      entry.interpreter.Process(MISSING);
    }
  }
}

