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
      topStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
      topStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
      topStackView.topAnchor.constraint(equalTo: topAnchor),
      topStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
      
    ])
  }
  
  var clearButton : UIButton = {
    return makeButton(systemName: "trash.fill", title: "Clear Codes")
  }()
  
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
  
  private static func makeButton(systemName icon: String, title: String) -> UIButton {
    let image = UIImage(systemName: icon)?.withRenderingMode(.alwaysTemplate)
    let button = UIButton(type: .custom, backgroundColor: nil, image: image, imageTintColor: .white)
    button.setTitle(title, for: .normal)
    return button
  }
  
}
