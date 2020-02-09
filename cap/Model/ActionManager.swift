//
//  ActionManager.swift
//  cap
//
//  Created by Andrew Tu on 2/8/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import Foundation

class ActionManager {
  
  func publish(_ action: Action) {
    switch action.action {
    case .lightAction(let value):
      publish(action.deviceType, action.deviceId, value)
    case .lockAction(let value):
      publish(action.deviceType, action.deviceId, value)
    @unknown default:
      print("Error! don't know the type!")
    }
  }
  
  func publish(_ deviceType: DeviceType, _ deviceId: String, _ action: LightAction) {
    let urlString = "\(Constants.baseUrl)/action/\(deviceType.rawValue)/\(deviceId)"
    let jsonData = try? JSONEncoder().encode(action)
    print(urlString)
    print(String(data: jsonData!, encoding: .utf8))

    post(urlString: urlString, jsonData: jsonData)
  }
  
  func publish(_ deviceType: DeviceType, _ deviceId: String, _ action: LockAction) {
    let urlString = "\(Constants.baseUrl)/\(deviceType.rawValue)/\(deviceId)"
    let jsonData = try? JSONEncoder().encode(action)
    
    post(urlString: urlString, jsonData: jsonData)
  }
  
  func post(urlString: String, jsonData: Data?) {
    var request = URLRequest(url: URL(string: urlString)!)
    request.httpMethod = "POST"
    request.httpBody = jsonData
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      // Check for Error
      if let error = error {
        print("Error took place \(error)")
        return
      }
      
      // Convert HTTP Response Data to a String
      if let data = data, let dataString = String(data: data, encoding: .utf8) {
        print("Response data string:\n \(dataString)")
      } else {
        print("idk man....")
      }
    }
    task.resume()
  }
}
