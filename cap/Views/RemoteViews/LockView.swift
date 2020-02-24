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
      lockButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      lockButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      lockButton.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.3),
      lockButton.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor)
    ])
  }
  
  lazy var lockButton : UIButton = {
    let button = makeButton(systemName: "lock", title: "lock")
    button.imageView?.backgroundColor = UIColor.red
    return button
  }()
  
}
