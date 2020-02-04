//
//  IoTDataModel.swift
//  cap
//
//  Created by Andrew Tu on 2/3/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit

// MARK: General Device Types
enum DeviceStatus {
  case ok
  case noConnection
  case error
}

enum DeviceType {
    case light
    case climate
    case lock
    case music
    case abstract
}

class DeviceData {
  // MARK: Properties
  var deviceId: String // Interchangeable as a name.
  var deviceType: DeviceType
  var icon: UIImage?
  var status: DeviceStatus
  
  // MARK: Initialization
  init(deviceId: String, deviceType: DeviceType, icon: UIImage?, status: DeviceStatus) {
    self.deviceId = deviceId
    self.deviceType = deviceType
    self.icon = icon
    self.status = status
  }
  
  init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: Climate Data
class ClimateData: DeviceData {
  var temperature: Float
  var humidity: Float
  var pressure: Float
  
  init?(deviceId: String, deviceType: DeviceType, icon: UIImage?, status: DeviceStatus, temperature: Float, humidity: Float, pressure: Float) {
    self.temperature = temperature
    self.humidity = humidity
    self.pressure = pressure
    
    super.init(deviceId: deviceId, deviceType: deviceType, icon: icon, status: status)
  }
}

// MARK: Light Data
class LightData: DeviceData {
  var color: UIColor
  var brightness: Float
  
  init?(deviceId: String, deviceType: DeviceType, icon: UIImage?, status: DeviceStatus, color: UIColor, brightness: Float) {
    
    guard(brightness <= 1.0 && brightness >= 0) else {
      return nil
    }
    
    self.color = color
    self.brightness = brightness
    
    super.init(deviceId: deviceId, deviceType: deviceType, icon: icon, status: status)
  }
}

// MARK: Lock Data
class LockData: DeviceData {
  var isLocked: Bool
  
  init?(deviceId: String, deviceType: DeviceType, icon: UIImage?, status: DeviceStatus, isLocked: Bool) {
    self.isLocked = isLocked
    
    super.init(deviceId: deviceId, deviceType: deviceType, icon: icon, status: status)
  }
}
