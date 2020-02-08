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
    addSubview(brightnessStackView)
    NSLayoutConstraint.activate([
      brightnessStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      brightnessStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      brightnessStackView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 20)
    ])
    
    addSubview(colorStackView)
    NSLayoutConstraint.activate([
      colorStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      colorStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      colorStackView.topAnchor.constraint(equalTo: brightnessStackView.bottomAnchor, constant: 20)
    ])
    
    addSubview(buttonsStackView)
    NSLayoutConstraint.activate([
      buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      buttonsStackView.topAnchor.constraint(equalTo: colorStackView.bottomAnchor, constant: 20)
    ])
  }
  
  func reloadView() {
    if let view = brightnessStackView.arrangedSubviews[1] as? UILabel {
      view.text  = "\(customData.brightness) percent"
    }
    
    colorStackView.arrangedSubviews[1].backgroundColor = customData.color
  }
  
  lazy var brightnessStackView : UIStackView = {
    let data = "\(customData.brightness) percent"
    let field =  getStringField(labeled: "Brightness", withData: data)
    return field;
  }()
  
  lazy var colorStackView : UIStackView = {
    let fieldLabel = UILabel()
    fieldLabel.translatesAutoresizingMaskIntoConstraints = false
    fieldLabel.text = "Color"
    fieldLabel.textColor = .white
    fieldLabel.backgroundColor = .clear
    fieldLabel.sizeToFit()
    fieldLabel.textAlignment = .justified
    fieldLabel.numberOfLines = 1
    fieldLabel.font = .systemFont(ofSize: 13)
    
    let fieldData = UIView()
    fieldData.translatesAutoresizingMaskIntoConstraints = false
    fieldData.backgroundColor = customData.color
    
    let field = UIStackView(arrangedSubviews: [fieldLabel, fieldData])
    field.distribution = .equalSpacing
    field.axis = .horizontal
    field.translatesAutoresizingMaskIntoConstraints = false
    fieldData.heightAnchor.constraint(equalTo: field.heightAnchor).isActive = true
    fieldData.widthAnchor.constraint(equalTo: field.heightAnchor).isActive = true
    
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
    let buttonView = UIStackView(arrangedSubviews:[submitOnButton, submitBrightnessButton, submitColorButton]) ///TODO
    buttonView.distribution = .equalSpacing
    buttonView.axis = .horizontal
    buttonView.translatesAutoresizingMaskIntoConstraints = false
    buttonView.alignment = .center
    buttonView.backgroundColor = .clear
    return buttonView
  }()
}
