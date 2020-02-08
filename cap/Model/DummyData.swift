//
//  DummyData.swift
//  cap
//
//  Created by Andrew Tu on 2/3/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import Foundation
import UIKit

class DummyIotDataManager : IotDataManager {
  override func decode(anchor: QRAnchor? ) -> DeviceData? {
    if anchor == nil {
      return dummyAbstractData()
    }
    
    return self.decode(jsonString: anchor!.label)
  }
  
  override func decode(jsonString: String) -> DeviceData? {
    print(jsonString)
    switch jsonString {
    case "climate":
      return dummyClimateData()
    case "light":
      return dummyLightData()
    case "lock":
      return dummyLockData()
    case "music":
      #warning("Implement this")
      return dummyAbstractData()
    default:
      return dummyAbstractData()
    }
  }
}

func dummyAbstractData() -> DeviceData {
  let dummy = DeviceData(deviceId: "Abstract Device", deviceType: DeviceType.abstract, icon: "device", status: DeviceStatus.ok, group: ["g1", "g2"], location: "Trap house")
  
  return dummy
}

func dummyAbstractDataJson() -> String {
  return String(data: dummyAbstractData().toJSONData()!, encoding: .utf8)!
}

func dummyLightData() -> LightData {
  let dummy = LightData(deviceId: "dummy light", deviceType: DeviceType.light, icon: "lightbulb", status: DeviceStatus.ok, group: ["g1", "g2"], location: "Trap house", isOn: true, color: .cyan, brightness: 0.88)
  return dummy!
}

func dummyLightDataJson() -> String {
  return String(data: dummyLightData().toJSONData()!, encoding: .utf8)!
}

func dummyClimateData() -> ClimateData {
  let dummy = ClimateData(deviceId: "dummy climate", deviceType: DeviceType.climate, icon: "cloud", status: DeviceStatus.ok, group: ["g1", "g2"], location: "Trap house", temperature: 70.0, humidity: 1.0, pressure: 2.0)
  
  return dummy!
}

func dummyLockData() -> LockData {
  let dummy = LockData(deviceId: "dummy lock", deviceType: DeviceType.lock, icon: "lock", status: DeviceStatus.ok, group: ["g1", "g2"], location: "Trap house", isLocked: false)
  
  return dummy!
}
