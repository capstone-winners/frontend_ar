#include "stdio.h"
#include "gtest/gtest.h"
#include "gmock/gmock.h"
#include "HistoryInterpreter.hpp"
#include "CvHelper.hpp"

#include <memory>

namespace TestHistoryInterpreter {

using testing::ElementsAre;
using testing::MockFunction;

MATCHER_P(IsHi, hii, "") { 
  return (arg->GetName() == hii.GetName()
          && arg->GetState() == hii.GetState()
          && arg->GetBuffer() ==  hii.GetBuffer()
          && arg->GetOutput() ==  hii.GetOutput());
}

class TestHistoryInterpreter : public ::testing::Test {
 protected:  
  // Declares the variables your tests want to use.
  std::shared_ptr<HistoryInterpreter> test_obj; 
  MockFunction<void(HistoryInterpreter*)> mockCallback;

  void SetUp() override {
    using namespace std::placeholders; // to get _1, and _2

    test_obj = std::make_shared<HistoryInterpreter>("test_obj", 
                                                    mockCallback.AsStdFunction());
  }

  HistoryInterpreter GetHi(std::vector<DetectedState> input, Box box) {

    HistoryInterpreter hi("test_obj",
                          mockCallback.AsStdFunction());

    EXPECT_CALL(mockCallback, Call(testing::_)).Times(testing::AnyNumber());
    for(DetectedState entry : input) {
      hi.Process(entry);
    }

    return hi;
  }
};

/**
 * Test the HistoryInterpreter Happy Path
 */
TEST_F(TestHistoryInterpreter, InitialConfig) {
  EXPECT_EQ(test_obj->GetState(), HistoryInterpreter::State::WARMUP);
  EXPECT_EQ(test_obj->GetMaxBufferSize(), 4);
  EXPECT_EQ(test_obj->GetName(), "test_obj");
}

TEST_F(TestHistoryInterpreter, HappyPathBehavior) {
  const std::vector<DetectedState> states = {
    SENTINEL,
    LOW, LOW, LOW, LOW,
    HIGH, HIGH, HIGH, HIGH,
    SENTINEL, SENTINEL, SENTINEL, SENTINEL };
  const Box box = {0, 0, 10, 10};
  HistoryInterpreter hii = GetHi(states, box);

  EXPECT_CALL(mockCallback, Call(IsHi(hii))).Times(1);

  // Push through the full sequence.
  EXPECT_EQ(test_obj->GetState(), HistoryInterpreter::State::WARMUP);
  test_obj->Process(SENTINEL);
  EXPECT_EQ(test_obj->GetState(), HistoryInterpreter::State::DETECTED);
  test_obj->Process(LOW);
  EXPECT_EQ(test_obj->GetState(), HistoryInterpreter::State::PROCESSING);
  test_obj->Process(LOW);
  test_obj->Process(LOW);
  test_obj->Process(LOW);
  test_obj->Process(HIGH);
  test_obj->Process(HIGH);
  test_obj->Process(HIGH);
  test_obj->Process(HIGH);
  test_obj->Process(SENTINEL);
  test_obj->Process(SENTINEL);
  test_obj->Process(SENTINEL);
  test_obj->Process(SENTINEL);
  EXPECT_EQ(test_obj->GetState(), HistoryInterpreter::State::DETECTED);

  // Expected output. 
  ASSERT_THAT(test_obj->GetOutput(), ElementsAre(0, 1));
}

/**
 * Test that this HistoryInterpreter remains in the WARMUP state until a
 * sentinel value is detected. 
 */
TEST_F(TestHistoryInterpreter, WaitSentinel) {
  const std::vector<DetectedState> states = {
    SENTINEL,
    HIGH, HIGH, HIGH, HIGH,
    SENTINEL, SENTINEL, SENTINEL, SENTINEL };
  const Box box = {0, 0, 10, 10};
  HistoryInterpreter hii = GetHi(states, box);

  EXPECT_CALL(mockCallback, Call(IsHi(hii))).Times(1);

  test_obj->Process(LOW);
  test_obj->Process(LOW);
  test_obj->Process(LOW);
  test_obj->Process(LOW);
  EXPECT_EQ(test_obj->GetState(), HistoryInterpreter::State::WARMUP);
  test_obj->Process(SENTINEL);
  EXPECT_EQ(test_obj->GetState(), HistoryInterpreter::State::DETECTED);
  test_obj->Process(SENTINEL);
  test_obj->Process(SENTINEL);
  test_obj->Process(SENTINEL);
  test_obj->Process(HIGH);
  EXPECT_EQ(test_obj->GetState(), HistoryInterpreter::State::PROCESSING);
  test_obj->Process(HIGH);
  test_obj->Process(HIGH);
  test_obj->Process(HIGH);
  test_obj->Process(SENTINEL);
  test_obj->Process(SENTINEL);
  test_obj->Process(SENTINEL);
  test_obj->Process(SENTINEL);

  ASSERT_THAT(test_obj->GetOutput(), ElementsAre(1));
}

}  // namespace

