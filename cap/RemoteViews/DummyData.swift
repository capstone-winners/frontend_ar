//
//  DummyData.swift
//  cap
//
//  Created by Andrew Tu on 2/3/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import Foundation
import UIKit

func dummyLightData() -> LightData {
  let dummy = LightData(deviceId: "dummy light", deviceType: DeviceType.light, icon: UIImage(systemName: "lightbulb"), status: DeviceStatus.ok, color: .cyan, brightness: 1)
  return dummy!
}

func dummyClimateData() -> ClimateData {
  let dummy = ClimateData(deviceId: "dummy climate", deviceType: DeviceType.climate, icon: UIImage(systemName: "cloud"), status: DeviceStatus.ok, temperature: 70.0, humidity: 1.0, pressure: 2.0)
  
  return dummy!
}

func dummyLockData() -> LockData {
  let dummy = LockData(deviceId: "dummy light", deviceType: DeviceType.light, icon: UIImage(systemName: "lightbulb"), status: DeviceStatus.ok, isLocked: false)
  
  return dummy!
}
