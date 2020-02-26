//
//  DebugView.swift
//  cap
//
//  Created by Andrew Tu on 2/7/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit

class DebugView : UIView {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = .red
    
    specializeView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func specializeView() {
    let topStackView = UIStackView(arrangedSubviews:[debugLabel, clearButton]) ///TODO
    topStackView.distribution = .equalSpacing
    topStackView.axis = .horizontal
    topStackView.translatesAutoresizingMaskIntoConstraints = false
    topStackView.alignment = .center
    topStackView.backgroundColor = .clear
    
    addSubview(topStackView)
    NSLayoutConstraint.activate([
      topStackView.topAnchor.constraint(equalTo: topAnchor),
      topStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
      topStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      topStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
      
    ])
    
    let buttonStackView = UIStackView(arrangedSubviews:[climateButton, lightButton, musicButton, lockButton])
    buttonStackView.distribution = .equalCentering
    buttonStackView.axis = .horizontal
    buttonStackView.translatesAutoresizingMaskIntoConstraints = false
    buttonStackView.alignment = .center
    topStackView.backgroundColor = .clear
    
  
    addSubview(buttonStackView)
    NSLayoutConstraint.activate([
      buttonStackView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 20),
      buttonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
      buttonStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      buttonStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
    ])
  }
  
  var debugLabel : UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Debug Info"
    label.textColor = .white
    label.backgroundColor = .clear
    label.textAlignment = .justified
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.font = .systemFont(ofSize: 13)
    
    return label
  }()
  
  var clearButton : UIButton = {
    return makeButton(systemName: "trash.fill", title: "Clear Codes")
  }()
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
