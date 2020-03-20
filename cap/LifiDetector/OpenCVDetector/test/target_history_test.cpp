#include "stdio.h"
#include "gtest/gtest.h"
#include "gmock/gmock.h"
#include "TargetHistory.hpp"
#include "HistoryInterpreter.hpp"
//#include "DetectorConstants.h"

#include <memory>

namespace TestTargetHistory {

using testing::ElementsAre;
using testing::MockFunction;

void printBuffer(const HistoryInterpreter interp, const std::string name) {
  std::cout << "Buffer [" << name << "]: ";
  for(auto i : interp.GetBuffer()) {
    std::cout << i << " ";
  }
  std::cout << std::endl;
}

void printOutput(const HistoryInterpreter interp, const std::string name) {
  std::cout << "Output [" << name << "]: ";
  for(auto i : interp.GetOutput()) {
    std::cout << i << " ";
  }
  std::cout << std::endl;
}


MATCHER_P(IsHi, hii, "") { 
  return (arg->GetName() == hii.GetName()
         && arg->GetState() == hii.GetState()
         && arg->GetBuffer() ==  hii.GetBuffer()
         && arg->GetOutput() ==  hii.GetOutput());
}


class TestTargetHistory : public ::testing::Test {
 protected:  
  // Declares the variables your tests want to use.
  std::shared_ptr<TargetHistory> test_obj; 
  MockFunction<void(HistoryInterpreter*)> frame_complete_callback;
  MockFunction<void(const Box, const Box)> iou_failed_callback;

  void SetUp() override {
    using namespace std::placeholders; // to get _1, and _2

    test_obj = std::make_shared<TargetHistory>();
    test_obj->AddFrameCompleteHandler(
        frame_complete_callback.AsStdFunction());
    test_obj->AddIouFailureHandler(
        iou_failed_callback.AsStdFunction());
  }

  void AddFrameHelper(std::vector<DetectedState> input, Box box) {
    for(DetectedState entry : input) {
      test_obj->AddToHistory(entry, box);
      test_obj->AdvanceFrameCount();
    }
  }

  HistoryInterpreter GetHi(std::vector<DetectedState> input, Box box) {

    HistoryInterpreter hi(BoxToString(box), 
                       frame_complete_callback.AsStdFunction());
    
    EXPECT_CALL(frame_complete_callback, Call(testing::_)).Times(
        testing::AnyNumber());
    for(DetectedState entry : input) {
      hi.Process(entry);
    }

    return hi;
  }

};


/**
 * Make sure the frame complete callback is triggere.
 */
TEST_F(TestTargetHistory, HappyPathBehavior) {

  const std::vector<DetectedState> states = {
    SENTINEL,
    LOW, LOW, LOW, LOW,
    HIGH, HIGH, HIGH, HIGH,
    SENTINEL, SENTINEL, SENTINEL, SENTINEL };
  const Box box = {0, 0, 10, 10};

  HistoryInterpreter hi = GetHi(states, box);
  
  // We expect this call to be made eventually.
  EXPECT_CALL(frame_complete_callback, Call(IsHi(hi))).Times(1);
  AddFrameHelper(states, box);
}


/**
 * Expect the IoU Failure to get triggered.
 */
TEST_F(TestTargetHistory, IouFailure) {

  const std::vector<DetectedState> states = {
    SENTINEL,
    LOW, LOW, LOW, LOW,
    HIGH, HIGH, HIGH, HIGH,
    SENTINEL, SENTINEL, SENTINEL, SENTINEL };
  const Box box = {0, 0, 10, 10};
  const Box box2 = {0, 0, 30, 30};

  HistoryInterpreter hi = GetHi(states, box);
  
  // We expect this call to be made eventually.
  EXPECT_CALL(iou_failed_callback, Call(box, box2)).Times(1);
  AddFrameHelper(states, box);
  test_obj->AddToHistory(HIGH, box2);
}

}  // namespace

