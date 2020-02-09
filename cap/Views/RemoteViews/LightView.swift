//
//  LightView.swift
//  cap
//
//  Created by Andrew Tu on 2/3/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//
import UIKit

class LightView : AbstractRemoteView {
  var customData : LightData {
    get{
      return data as! LightData
    } set {
      data = newValue
    }
  }
  
  // MARK: - Setup
  convenience init() {
    self.init(data: dummyLightData())
  }
  
  init(data: LightData) {
    super.init(frame: CGRect.zero, data: data)
    self.titleImage.image = UIImage(systemName: customData.icon)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func specializeView() {
    addSubview(buttonsStackView)
    buttonsStackView.isUserInteractionEnabled = true
    buttonsStackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    NSLayoutConstraint.activate([
      buttonsStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      buttonsStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      buttonsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -60)
    ])
  }
  
  func reloadView() {
    // TODO: Set this equal to the current state
    // customData.color
  }
  
  lazy var brightnessStackView : UIStackView = {
    let data = "\(customData.brightness) percent"
    let field =  getStringField(labeled: "Brightness", withData: data)
    return field;
  }()
  
  lazy var submitColorButton : UIButton = {
    return makeButton(systemName: "eyedropper.full", title: "Color")
  }()
  
  lazy var submitBrightnessButton : UIButton = {
    return makeButton(systemName: "sun.max.fill", title: "Brightness")
  }()
  
  lazy var submitOnButton : UIButton = {
    return makeButton(systemName: "power", title: "Power")
  }()
  
  lazy var buttonsStackView : UIStackView = {
    //let buttonView = UIStackView(arrangedSubviews:[submitOnButton, submitBrightnessButton, submitColorButton]) ///TODO
    let buttonView = UIStackView(arrangedSubviews:[submitOnButton]) ///TODO
    buttonView.distribution = .equalSpacing
    buttonView.axis = .horizontal
    buttonView.translatesAutoresizingMaskIntoConstraints = false
    buttonView.alignment = .center
    buttonView.backgroundColor = .clear
    return buttonView
  }()
}
