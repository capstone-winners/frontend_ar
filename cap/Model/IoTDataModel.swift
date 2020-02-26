//
//  IoTDataModel.swift
//  cap
//
//  Created by Andrew Tu on 2/3/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

// Might need to revisit this for issues with codable.
// https://www.raywenderlich.com/3418439-encoding-and-decoding-in-swift


import UIKit

// MARK: General Device Types
enum DeviceStatus : String, Codable {
  case ok
  case noConnection
  case error
}

enum DeviceType : String, Codable {
  case light
  case climate
  case lock
  case music
  case abstract
}

class DeviceData : Codable {
  // MARK: Properties
  var deviceId: String            // Interchangeable as a name.
  var deviceType: DeviceType
  var icon: String
  var status: DeviceStatus
  var group: [String]
  var location: String
  
  enum DeviceCodingKeys: String, CodingKey {
    case deviceId
    case deviceType
    case status
    case group
    case location
  }
  
  
  // MARK: Initialization
  init(deviceId: String, deviceType: DeviceType, icon: String, status: DeviceStatus, group: [String], location: String) {
    self.deviceId = deviceId
    self.deviceType = deviceType
    self.icon = icon
    self.status = status
    self.group = group
    self.location = location
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: DeviceCodingKeys.self)
    deviceId = try values.decode(String.self, forKey: .deviceId)
    deviceType = try values.decode(DeviceType.self, forKey: .deviceType)
    status = try values.decode(DeviceStatus.self, forKey: .status)
    group = try values.decode([String].self, forKey: .group)
    location = try values.decode(String.self, forKey: .location)
    
    icon = "desktopcomputer"
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: DeviceCodingKeys.self)
    try container.encode(deviceId, forKey: .deviceId)
    try container.encode(deviceType, forKey: .deviceType)
    try container.encode(status, forKey: .status)
    try container.encode(group, forKey: .group)
    try container.encode(location, forKey: .location)
  }
  
  func toJSONData() -> Data? {
    return try? JSONEncoder().encode(self)
  }
  
  func toJSONString() -> String {
    String(data: self.toJSONData()!, encoding: .utf8)!
  }
}

// MARK: Climate Data
class ClimateData: DeviceData {
  var temperature: Float
  var humidity: Float
  var pressure: Float
  
  enum ClimateCodingKeys: String, CodingKey {
    case temperature
    case humidity
    case pressure
  }
  
  init?(deviceId: String, deviceType: DeviceType, icon: String, status: DeviceStatus, group: [String], location: String, temperature: Float, humidity: Float, pressure: Float) {
    self.temperature = temperature
    self.humidity = humidity
    self.pressure = pressure
    
    super.init(deviceId: deviceId, deviceType: deviceType, icon: icon, status: status, group: group, location: location)
    self.icon = "cloud"
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: ClimateCodingKeys.self)
    temperature = try values.decode(Float.self, forKey: .temperature)
    humidity = try values.decode(Float.self, forKey: .humidity)
    pressure = try values.decode(Float.self, forKey: .pressure)
    
    let superDecoder = try values.superDecoder()
    try super.init(from: superDecoder)
    self.icon = "cloud"
  }
  
  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: ClimateCodingKeys.self)
    
    try container.encode(temperature, forKey: .temperature)
    try container.encode(humidity, forKey: .humidity)
    try container.encode(pressure, forKey: .pressure)
    
    let superencoder = container.superEncoder()
    try super.encode(to: superencoder)
  }
}

struct CodableColor : Codable {
  var hue : CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0, kelvin: CGFloat = 3500
  
  enum CodingKeys : String, CodingKey {
    case hue = "h"
    case saturation = "s"
    case brightness = "b"
    case alpha = "a"
    case kelvin = "k"
  }
  
  var uiColor : UIColor {
    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
  }
  
  init(uiColor : UIColor) {
    kelvin = 3500
    uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
  }
}

// MARK: Light Data
class LightData: DeviceData {
  var isOn : Bool
  var _color: CodableColor
  var brightness: Float
  
  var color: UIColor {
    get {
      return _color.uiColor
    }
    set {
      _color = CodableColor(uiColor: newValue)
    }
  }
  
  enum LightCodingKeys : String, CodingKey {
    case isOn
    case color
    case brightness
  }
  
  init?(deviceId: String, deviceType: DeviceType, icon: String, status: DeviceStatus, group: [String], location: String, isOn: Bool, color: UIColor, brightness: Float) {
    
    guard(brightness <= 1.0 && brightness >= 0) else {
      return nil
    }
    self.isOn = isOn
    self._color = CodableColor(uiColor: color)
    self.brightness = brightness
    
    super.init(deviceId: deviceId, deviceType: deviceType, icon: icon, status: status, group: group, location: location)
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: LightCodingKeys.self)
    
    isOn = try values.decode(Bool.self, forKey: .isOn)
    _color = try values.decode(CodableColor.self, forKey: .color)
    brightness = try values.decode(Float.self, forKey: .brightness)
    
    let superDecoder = try values.superDecoder()
    try super.init(from: superDecoder)
    self.icon = "lightbulb"
  }
  
  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: LightCodingKeys.self)
    
    try container.encode(isOn, forKey: .isOn)
    try container.encode(_color, forKey: .color)
    try container.encode(brightness, forKey: .brightness)
    
    let superencoder = container.superEncoder()
    try super.encode(to: superencoder)
  }
  
}

// MARK: Lock Data
class LockData: DeviceData {
  var isLocked: Bool
  
  enum LockCodingKeys: String, CodingKey {
    case isLocked
  }
  
  init?(deviceId: String, deviceType: DeviceType, icon: String, status: DeviceStatus, group: [String], location: String, isLocked: Bool) {
    self.isLocked = isLocked
    
    super.init(deviceId: deviceId, deviceType: deviceType, icon: icon, status: status, group: group, location: location)
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: LockCodingKeys.self)
    
    isLocked = try values.decode(Bool.self, forKey: .isLocked)
    
    let superDecoder = try values.superDecoder()
    try super.init(from: superDecoder)
    self.icon = "lock"
  }
  
  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: LockCodingKeys.self)
    
    try container.encode(isLocked, forKey: .isLocked)
    
    let superencoder = container.superEncoder()
    try super.encode(to: superencoder)
  }
}

// MARK: Music Data
enum MusicPlayerState : String, Codable {
  case playing
  case paused
  case stopped
}

class MusicData: DeviceData {
  var playerState : MusicPlayerState
  var volume: Float
  var song: String
  
  enum MusicCodingKeys: String, CodingKey {
    case playerState
    case volume
    case song
  }
  
  init?(deviceId: String, deviceType: DeviceType, icon: String, status: DeviceStatus, group: [String], location: String, playerState: MusicPlayerState, volume: Float, song: String) {
    self.playerState = playerState
    self.volume = volume
    self.song = song
    
    super.init(deviceId: deviceId, deviceType: deviceType, icon: icon, status: status, group: group, location: location)
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: MusicCodingKeys.self)
    
    playerState = try values.decode(MusicPlayerState.self, forKey: .playerState)
    volume = try values.decode(Float.self, forKey: .volume)
    song = try values.decode(String.self, forKey: .song)
    
    let superDecoder = try values.superDecoder()
    try super.init(from: superDecoder)
    self.icon = "music.note"
  }
  
  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: MusicCodingKeys.self)
    
    try container.encode(playerState, forKey: .playerState)
    try container.encode(volume, forKey: .volume)
    try container.encode(song, forKey: .song)
    
    let superencoder = container.superEncoder()
    try super.encode(to: superencoder)
  }
}
