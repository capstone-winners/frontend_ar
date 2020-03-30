//
//  ActionManager.swift
//  cap
//
//  Created by Andrew Tu on 2/8/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import Foundation

class ActionManager {
  
  typealias Handler = (String?) -> Void
  
  var session : URLSession
  var customHandler : Handler?
  
  init(session: URLSession? = nil) {
    self.session = session ?? URLSession.shared
  }
  
  /**
   Main entry way to the ActionManager. Action decoded through dynamic dispatch.
   */
  func publish(_ action: Action, completionHandler: Handler? = nil) {
    customHandler = completionHandler
    
    let jsonData = action.toJSONData()
    let urlString = ActionManager.actionToUrlString(action)
    
    post(urlString: urlString, jsonData: jsonData)
  }
  
  static func actionToUrlString(_ action: Action) -> String {
    let urlString = "\(Constants.baseUrl)/action/\(action.deviceType.rawValue)/\(action.deviceId)"
    return urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! // Need to santizie spaces to %20 for urls.
  }
}


// ***********************
// MARK: Private Helpers
// ***********************
extension ActionManager {
  
  private func post(urlString: String, jsonData: Data?) {
    var request = URLRequest(url: URL(string: urlString)!)
    request.httpMethod = "POST"
    request.httpBody = jsonData
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(Constants.token, forHTTPHeaderField: "Authorization")
    
    let task = session.dataTask(with: request, completionHandler: postCompletionHandlerFunc)
    task.resume()
  }
  
  /**
   This is what we do when we receive a response from the POST action.
   */
  private func postCompletionHandlerFunc(data: Data?, response: URLResponse?, error: Error?) -> Void {
    // Check for Error
    if let error = error {
      print("[ActionManager]: Error took place \(error)")
      return
    }
    
    // Convert HTTP Response Data to a String
    if let data = data, let dataString = String(data: data, encoding: .utf8) {
      print("[ActionManager]: Response data string:\n \(dataString)")
      customHandler?(dataString)
    } else {
      print("[ActionManager]: idk man....")
    }
  }
  
}
