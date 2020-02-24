//
//  ActionDataModel.swift
//  cap
//
//  Created by Andrew Tu on 2/8/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import Foundation

// MARK: Light Actions
struct SetColorAction : Codable {
  var color : CodableColor
}

struct SetBrightnessAction : Codable {
  var brightness : Float
}

struct SetOnAction : Codable {
  var isOn : Bool
}

enum LightAction : Codable {
  case setColor(SetColorAction)
  case setBrightness(SetBrightnessAction)
  case setIsOn(SetOnAction)
}

extension LightAction {
  private enum CodingKeys: String, CodingKey {
    case setColor
    case setBrightness
    case setIsOn
  }
  
  enum LightActionCodingError: Error {
    case decoding(String)
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    if let value = try? values.decode(SetColorAction.self, forKey: .setColor) {
      self = .setColor(value)
      return
    }
    if let value = try? values.decode(SetBrightnessAction.self, forKey: .setBrightness) {
      self = .setBrightness(value)
      return
    }
    if let value = try? values.decode(SetOnAction.self, forKey: .setIsOn) {
      self = .setIsOn(value)
      return
    }
    throw LightActionCodingError.decoding("Whoops! \(dump(values))")
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .setColor(let value):
      try container.encode(value, forKey: .setColor)
    case .setBrightness(let value):
      try container.encode(value, forKey: .setBrightness)
    case .setIsOn(let value):
      try container.encode(value, forKey: .setIsOn)
    }
  }
}

// MARK: Lock Actions
enum LockAction : Codable {
  case setLock(SetLockAction)
}
extension LockAction {
  private enum CodingKeys: String, CodingKey {
    case setLock
  }
  
  enum LockActionCodingError: Error {
    case decoding(String)
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    if let value = try? values.decode(SetLockAction.self, forKey: .setLock) {
      self = .setLock(value)
      return
    }
    throw LockActionCodingError.decoding("Whoops! \(dump(values))")
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .setLock(let value):
      try container.encode(value, forKey: .setLock)
    }
  }
}

struct SetLockAction : Codable {
  var isLocked : Bool
}

// *****************************************
// MARK: Music Action
// *****************************************
enum MusicAction : Codable {
  case play(PlayAction)
  case skip(SkipAction)
}
extension MusicAction {
  private enum CodingKeys: String, CodingKey {
    case play
    case skip
  }
  
  enum MusicActionCodingError: Error {
    case decoding(String)
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    if let value = try? values.decode(PlayAction.self, forKey: .play) {
      self = .play(value)
      return
    }
    if let value = try? values.decode(SkipAction.self, forKey: .skip) {
      self = .skip(value)
      return
    }
    
    throw MusicActionCodingError.decoding("Whoops! \(dump(values))")
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .play(let value):
      try container.encode(value, forKey: .play)
    case .skip(let value):
      try container.encode(value, forKey: .skip)
    }
  }
}

struct PlayAction : Codable {
  var shouldPlay : Bool
}
struct SkipAction : Codable {
  var skipForward : Bool
}

// *****************************************
// MARK: Overall Action
// *****************************************
enum IotAction : Codable {
  case lightAction(LightAction)
  case lockAction(LockAction)
  case musicAction(MusicAction)
}

extension IotAction {
  private enum CodingKeys: String, CodingKey {
    case lightAction
    case lockAction
    case musicAction
  }
  
  enum LockActionCodingError: Error {
    case decoding(String)
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    if let value = try? values.decode(LightAction.self, forKey: .lightAction) {
      self = .lightAction(value)
      return
    }
    if let value = try? values.decode(LockAction.self, forKey: .lockAction) {
      self = .lockAction(value)
      return
    }
    throw LockActionCodingError.decoding("Whoops! \(dump(values))")
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .lockAction(let value):
      try container.encode(value, forKey: .lockAction)
    case .lightAction(let value):
      try container.encode(value, forKey: .lightAction)
    case .musicAction(let value):
      try container.encode(value, forKey: .musicAction)
    }
  }
}

struct Action : Codable {
  var deviceType : DeviceType
  var deviceId : String
  var action : IotAction
}

// Give some json functionalities.
extension Action {
  func toJSONData() -> Data? {
    return try? JSONEncoder().encode(self)
  }
  
  func toJSONString() -> String {
    String(data: self.toJSONData()!, encoding: .utf8)!
  }
}
