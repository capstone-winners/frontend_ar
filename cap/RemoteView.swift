//
//  RemoteView.swift
//  cap
//
//  Created by Andrew Tu on 1/24/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit

class RemoteView: UIView {
  
  // MARK: - Setup
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .cyan
    translatesAutoresizingMaskIntoConstraints = false
    
    setViews()
    setupStackViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func tintColorDidChange() {
    print("color changed amina kodumun yerinde")
  }
  
  //MARK: - Layout
  func setViews() {
    //addSubview(timeUpdaterDisplay)
    //addSubview(avaibleDevicesButton)
  }
  
  private func setupStackViews() {
    let topStackView = UIStackView(arrangedSubviews:[deviceButton, deviceInfoLabel]) ///TODO
    topStackView.distribution = .equalSpacing
    topStackView.axis = .horizontal
    topStackView.translatesAutoresizingMaskIntoConstraints = false
    topStackView.alignment = .center
    addSubview(topStackView)
    
    topStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    topStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100).isActive = true
    topStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95).isActive = true
    topStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    
    
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
  }
  
  func layoutViews() {
    upDownArrowButton.widthAnchor.constraint(lessThanOrEqualToConstant: 32).isActive = true
    upDownArrowButton.heightAnchor.constraint(lessThanOrEqualToConstant: 32).isActive = true
    
    deviceButton.widthAnchor.constraint(lessThanOrEqualToConstant: 32).isActive = true
    deviceButton.heightAnchor.constraint(lessThanOrEqualToConstant: 32).isActive = true
    
    bottomConstraintForAvaibleDevicesButton?.isActive = true
  }
  
  
  //MARK: Constraint Variables
  var bottomConstraintForAvaibleDevicesButton: NSLayoutConstraint?
  
  //MARK: Variables
  var isSmall: Bool = true {
    didSet {
      if isSmall {
        updateDisplayForSmallView()
      } else { //FullScreen
        updateDisplayForFullScreenView()
      }
    }
  }
  
  //todo carry theme under mark:-layout
  private func updateDisplayForSmallView() {
    let image = UIImage(systemName: "chevron.up")?.withRenderingMode(.alwaysTemplate)
    upDownArrowButton.setImage(image, for: .normal)
    let playImage = UIImage(systemName: "desktopcomputer")?.withRenderingMode(.alwaysTemplate)
    deviceButton.setImage(playImage, for: .normal)
    upDownArrowButton.tintColor = .white
    bottomConstraintForAvaibleDevicesButton?.constant = -1
    layoutIfNeeded()
  }
  
  private func updateDisplayForFullScreenView() {
    
    let image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
    upDownArrowButton.setImage(image, for: .normal)
    
    let playListImage = UIImage(systemName: "desktopcomputer")?.withRenderingMode(.alwaysTemplate)
    deviceButton.setImage(playListImage, for: .normal)
    upDownArrowButton.tintColor = .white
    bottomConstraintForAvaibleDevicesButton?.constant = -idealGapBetweenItems
  }
  
  var idealGapBetweenItems : CGFloat  {
    get {
      return UIScreen.main.bounds.height / 45
    }
  }
  
  //MARK: - Top
  var upDownArrowButton : UIButton = {
    let image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
    let button = UIButton(type: .custom, backgroundColor: nil, image: image, imageTintColor: .white)
    
    return button
  }()
  
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
}
