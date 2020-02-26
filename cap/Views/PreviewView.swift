//
//  PreviewView.swift
//  cap
//
//  Created by Andrew Tu on 2/26/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit

class PreviewView : UIView {
  init() {
    super.init(frame: CGRect.zero)
    
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = .blue
    
    specializeView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func specializeView() {
    let topStackView = UIStackView(arrangedSubviews:[previewIcon, previewLabel]) ///TODO
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
  
  var previewIcon : UIImageView = {
    let image = UIImage(systemName: "desktopcomputer")?.withRenderingMode(.alwaysTemplate)
    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFit // fit based on width, might cause bands on top/bottom
    
    return imageView
  }()
  
  var previewLabel : UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Preview Label"
    label.textColor = .white
    label.backgroundColor = .clear
    label.textAlignment = .justified
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.font = .systemFont(ofSize: 13)
    
    return label
  }()
}
