//
//  RemoteView.swift
//  cap
//
//  Created by Andrew Tu on 1/24/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//
import UIKit

class RemoteView : AbstractRemoteView {
  init() {
    let data = DeviceData(deviceId: "Abstract Device", deviceType: DeviceType.abstract, icon: UIImage(systemName: "device"), status: DeviceStatus.ok)
    
    super.init(frame: CGRect.zero, data: data)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func specializeView() {
    let topStackView = UIStackView(arrangedSubviews:[deviceButton, deviceInfoLabel]) ///TODO
    topStackView.distribution = .equalSpacing
    topStackView.axis = .horizontal
    topStackView.translatesAutoresizingMaskIntoConstraints = false
    topStackView.alignment = .center
    addSubview(topStackView)
    NSLayoutConstraint.activate([
      topStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
      topStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100),
      topStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
      topStackView.heightAnchor.constraint(equalToConstant: 100)
    ])
    
    let child = UILabel()
    child.text = "hello world"
    child.translatesAutoresizingMaskIntoConstraints = false
    child.backgroundColor = .red
    addSubview(child)
    child.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    child.bottomAnchor.constraint(equalTo: topStackView.topAnchor, constant: 0).isActive = true
    //child.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    child.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95).isActive = true
    child.heightAnchor.constraint(equalToConstant: 33).isActive = true
    
    let buttonStackView = UIStackView(arrangedSubviews:[climateButton, lightButton, musicButton, lockButton])
    buttonStackView.distribution = .equalCentering
    buttonStackView.axis = .horizontal
    buttonStackView.translatesAutoresizingMaskIntoConstraints = false
    buttonStackView.alignment = .center

    addSubview(buttonStackView)
    
    NSLayoutConstraint.activate([
      buttonStackView.bottomAnchor.constraint(equalTo: child.topAnchor, constant: -10),
      buttonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
      buttonStackView.leadingAnchor.constraint(equalTo: child.leadingAnchor),
      buttonStackView.trailingAnchor.constraint(equalTo: child.trailingAnchor)
    ])
  }
  
  var deviceButton : UIButton = {
    let image = UIImage(systemName: "desktopcomputer")?.withRenderingMode(.alwaysTemplate)
    let button = UIButton(type: .custom, backgroundColor: nil, image: image, imageTintColor: .white)
    
    return button
  }()
  
  var deviceInfoLabel : UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Device Info"
    label.textColor = .white
    label.backgroundColor = .clear
    label.sizeToFit()
    label.textAlignment = .justified
    label.numberOfLines = 1
    label.font = .systemFont(ofSize: 13)
    
    return label
  }()
  
  private static func makeButton(systemName icon: String, title: String) -> UIButton {
    let image = UIImage(systemName: icon)?.withRenderingMode(.alwaysTemplate)
    let button = UIButton(type: .custom, backgroundColor: nil, image: image, imageTintColor: .white)
    button.setTitle(title, for: .normal)
    return button
  }
  
  var climateButton : UIButton = {
    return makeButton(systemName: "cloud", title: "Climate")
  }()
  var lightButton : UIButton = {
    return makeButton(systemName: "lightbulb", title: "Light")
  }()
  var musicButton : UIButton = {
    return makeButton(systemName: "music.note", title: "Music")
  }()
  var lockButton : UIButton = {
    return makeButton(systemName: "lock", title: "Lock")
  }()
}
