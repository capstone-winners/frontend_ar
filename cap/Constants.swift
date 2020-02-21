//
//  Constants.swift
//  cap
//
//  Created by Andrew Tu on 2/8/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import Foundation

class Constants {
  // MARK: Things we're probably going to keep
  static let baseUrl = "http://192.168.1.4:3000"

  static let bounceDistance = 0.5
  static let bounceTiming = 0.25
  
  static let colorIntervalUpdateMs = 1000
  
  // MARK: BAD things we want to get ride of eventually...
  static let hardcodedLightUrl = "http://192.168.1.4:3000/action/light/vibe-check"
  static let unknownLightId = "vibe-check"
  static let currentQrJson = "{\"isOn\":true,\"brightness\":0.01999,\"color\":{\"r\":0,\"g\":0,\"b\":0,\"a\":1},\"super\":{\"status\":\"ok\",\"deviceId\":\"Vibe Check \",\"deviceType\":\"light\",\"location\":\"Trap House\",\"group\":\"Toms Room\"}}"

}
