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
    if anchor == nil {
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
      return nil
    }
    
    if let jsonData = jsonString.data(using: .utf8)
    {
      let decoder = JSONDecoder()
      do {
        switch dtype {
        case .climate:
          print("climate")
          return try decoder.decode(ClimateData.self, from: jsonData)
        case .light:
          print("light")
          return try decoder.decode(LightData.self, from: jsonData)
        case .lock:
          print("lock")
          return try decoder.decode(LockData.self, from: jsonData)
        case .music:
          print("music")
          return try decoder.decode(DeviceData.self, from: jsonData)
        case .abstract:
          print("abstract")
          return try decoder.decode(DeviceData.self, from: jsonData)
        }
      } catch {
        print(error.localizedDescription)
      }
    }
    return dummyLockData()
  }
  
  /**
   Determines what type of device data message the given json is encoding.
   */
  func getType(jsonDict: String) -> DeviceType? {
    do {
      // make sure this JSON is in the format we expect
      if let json = try JSONSerialization.jsonObject(with: Data(jsonDict.utf8), options: []) as? [String: Any] {
        // try to read out a string array
        if let type = json["deviceType"] as? String {
          return DeviceType(rawValue: type)!
        }
      }
    } catch let error as NSError {
      print("Failed to load: \(error.localizedDescription)")
    }
    
    return nil
  }
  
}
