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
      temperatureStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      temperatureStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      temperatureStackView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 20)
    ])
    
    addSubview(humidityStackView)
    NSLayoutConstraint.activate([
      humidityStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      humidityStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      humidityStackView.topAnchor.constraint(equalTo: temperatureStackView.bottomAnchor, constant: 20)
    ])
    
    addSubview(pressureStackView)
    NSLayoutConstraint.activate([
      pressureStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      pressureStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      pressureStackView.topAnchor.constraint(equalTo: self.humidityStackView.bottomAnchor, constant: 20)
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
}
