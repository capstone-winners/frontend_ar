//
//  ClimateView.swift
//  cap
//
//  Created by Andrew Tu on 1/29/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit

class ClimateView : AbstractRemoteView {
  var customData : ClimateData {
    get{
      return data as! ClimateData
    } set {
      data = newValue
    }
  }
  
  
  // MARK: - Setup
  convenience init() {
    self.init(data: dummyClimateData())
  }
  
  init(data: ClimateData) {
    super.init(frame: CGRect.zero, data: data)
    self.titleImage.image = UIImage(systemName: customData.icon)
    
    specializeView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func specializeView() {
    addSubview(temperatureStackView)
    NSLayoutConstraint.activate([
      temperatureStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      temperatureStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      temperatureStackView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 20)
    ])
    
    addSubview(humidityStackView)
    NSLayoutConstraint.activate([
      humidityStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      humidityStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      humidityStackView.topAnchor.constraint(equalTo: temperatureStackView.bottomAnchor, constant: 20)
    ])
    
    addSubview(pressureStackView)
    NSLayoutConstraint.activate([
      pressureStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      pressureStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      pressureStackView.topAnchor.constraint(equalTo: self.humidityStackView.bottomAnchor, constant: 20)
    ])
    
    addSubview(tempControl)
    NSLayoutConstraint.activate([
      tempControl.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      tempControl.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      tempControl.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 20)
    ])
  }
  
  func reloadView() {
    if let view = temperatureStackView.arrangedSubviews[1] as? UILabel {
      view.text  = "\(customData.pressure) degrees"
    }
    
    if let view = humidityStackView.arrangedSubviews[1] as? UILabel {
      view.text  = "\(customData.humidity) units"
    }
    
    if let view = pressureStackView.arrangedSubviews[1] as? UILabel {
      view.text  = "\(customData.pressure) units"
    }
  }
  
  lazy var temperatureStackView : UIStackView = {
    let field =  getStringField(labeled: "Temperature", withData: "\(customData.temperature) degrees")
    return field;
  }()
  
  lazy var humidityStackView : UIStackView = {
    return getStringField(labeled: "Humidity", withData: "\(customData.humidity) units")
  }()
  
  lazy var pressureStackView : UIStackView = {
    return getStringField(labeled: "Pressure", withData: "\(customData.pressure) units")
  }()
  
  lazy var tempControl : UIStackView = {
    
    let tempDown = makeButton(systemName: "minus.circle.fill", title: "Cool")
    let tempUp = makeButton(systemName: "plus.circle.fill", title: "Heat")
    
    let stack = UIStackView(arrangedSubviews:[tempUp, tempDown]) ///TODO
    stack.distribution = .equalSpacing
    stack.axis = .vertical
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.alignment = .center
    addSubview(stack)
    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: centerXAnchor),
      stack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -100),
      stack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
      stack.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.5)
    ])
    
    return stack
  }()
}
