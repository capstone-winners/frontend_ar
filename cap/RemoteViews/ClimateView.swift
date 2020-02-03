//
//  ClimateView.swift
//  cap
//
//  Created by Andrew Tu on 1/29/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import Foundation
import UIKit

class ClimateView : AbstractRemoteView {
  // MARK: - Setup
  override init(frame: CGRect) {
    super.init(frame: frame)
    deviceName = "Climate Chip"
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
  
  private static func getField(labeled label: String, withData data: String) -> UIStackView{
    let fieldLabel = UILabel()
    fieldLabel.translatesAutoresizingMaskIntoConstraints = false
    fieldLabel.text = label
    fieldLabel.textColor = .white
    fieldLabel.backgroundColor = .clear
    fieldLabel.sizeToFit()
    fieldLabel.textAlignment = .justified
    fieldLabel.numberOfLines = 1
    fieldLabel.font = .systemFont(ofSize: 13)
    
    let fieldData = UILabel()
    fieldData.translatesAutoresizingMaskIntoConstraints = false
    fieldData.text = data
    fieldData.textColor = .white
    fieldData.backgroundColor = .clear
    fieldData.sizeToFit()
    fieldData.textAlignment = .justified
    fieldData.numberOfLines = 1
    fieldData.font = .systemFont(ofSize: 13)
    
    let field = UIStackView(arrangedSubviews: [fieldLabel, fieldData])
    field.distribution = .equalSpacing
    field.axis = .horizontal
    field.translatesAutoresizingMaskIntoConstraints = false
    
    return field
  }
  
  var temperatureStackView : UIStackView = {
    let field =  getField(labeled: "Temperature", withData:"fucking hot")
    return field;
  }()
  
  var humidityStackView : UIStackView = {
    return getField(labeled: "Humidity", withData:"fucking wet")
  }()
  
  var pressureStackView : UIStackView = {
    return getField(labeled: "Pressure", withData: "fucking high")
  }()
}
