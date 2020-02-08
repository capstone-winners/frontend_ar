//
//  IoTDataManager.swift
//  cap
//
//  Created by Andrew Tu on 2/4/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import Foundation

class IotDataManager {
  
  /**
   Decodes a QRAnchor to a DeviceData object.
   */
  func decode(anchor: QRAnchor? ) -> DeviceData? {    
    if (anchor == nil) {
      return nil
    }
    
    return self.decode(jsonString: anchor!.label)
  }
  
  /**
   Decodes the given json string to the appropriate concrete type.
   Returns `nil` if given an invalid json.
   */
  func decode(jsonString: String) -> DeviceData? {
    guard let dtype = getType(jsonDict: jsonString) else {
      print("IotDataManager: Bad type in decode attempt!")
      return nil
    }
    
    if let jsonData = jsonString.data(using: .utf8)
    {
      let decoder = JSONDecoder()
      do {
        switch dtype {
        case .climate:
          return try decoder.decode(ClimateData.self, from: jsonData)
        case .light:
          return try decoder.decode(LightData.self, from: jsonData)
        case .lock:
          return try decoder.decode(LockData.self, from: jsonData)
        case .music:
          return try decoder.decode(DeviceData.self, from: jsonData)
        case .abstract:
          return try decoder.decode(DeviceData.self, from: jsonData)
        }
      } catch {
        print(error.localizedDescription)
      }
    }
    return nil
  }
  
  /**
   Determines what type of device data message the given json is encoding.
   */
  func getType(jsonDict: String) -> DeviceType? {
    do {
      print(jsonDict)
      // make sure this JSON is in the format we expect
      if let json = try JSONSerialization.jsonObject(with: Data(jsonDict.utf8), options: []) as? [String: Any] {
        // try to read out a string array
        if let deviceType = json[DeviceData.DeviceCodingKeys.deviceType.rawValue] as? String{
          return DeviceType(rawValue: deviceType)!
        } else if let superType = json["super"] as? [String: Any] {
          guard let raw = superType[DeviceData.DeviceCodingKeys.deviceType.rawValue] as? String else {
            return nil
          }
          
          return DeviceType(rawValue: raw)
        }
      }
    } catch let error as NSError {
      print("Failed to load: \(error.localizedDescription)")
    }
    
    return nil
  }
  
}
