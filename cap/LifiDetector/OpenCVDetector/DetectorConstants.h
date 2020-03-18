//
//  DetectorConstants.h
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

#ifndef DetectorConstants_h
#define DetectorConstants_h

enum DetectedState {SENTINEL, HIGH, LOW, MISSING};

constexpr int FRAME_SIZE = 9; // 1 Sentinel, 8 Payload
constexpr int RX_FREQ = 60;
constexpr int TX_FREQ = 30;
constexpr int BUFFER_SIZE = RX_FREQ/TX_FREQ;


#endif /* DetectorConstants_h */
