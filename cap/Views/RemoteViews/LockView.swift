//
//  LockView.swift
//  cap
//
//  Created by Andrew Tu on 2/24/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit

class LockView : AbstractRemoteView {
  
  var customData : LockData {
    get{
      return data as! LockData
    } set {
      data = newValue
    }
  }
  
  var lockState : String {
    get {
      if customData.isLocked {
        return "locked"
      }
      
      return "unlocked"
    }
  }
  // MARK: - Setup
  convenience init() {
    self.init(data: dummyLockData())
  }
  
  init(data: DeviceData) {
    data.deviceId = "Lock"
    super.init(frame: CGRect.zero, data: data)
    self.titleImage.image = UIImage(systemName: data.icon)
    
    specializeView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func specializeView() {

    lockButton.translatesAutoresizingMaskIntoConstraints = false
    addSubview(lockButton)
    NSLayoutConstraint.activate([
      lockButton.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.3),
      lockButton.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.3),
      lockButton.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
      lockButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
    ])
  }
  
  lazy var lockButton : UIButton = {
  
    let button = makeButton(systemName: "lock", title: self.lockState)
    button.backgroundColor = .brown
    button.imageView?.backgroundColor = .red
    return button
  }()
  
  func reload() -> Void {
    if customData.isLocked {
      lockButton.backgroundColor = .red
      //lockButton.imageView?.backgroundColor = .red
    } else {
      lockButton.backgroundColor = .green
    }
    lockButton.setTitle(lockState, for: .normal)
  }
}
