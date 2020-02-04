//
//  AbstractRemoteView.swift
//  cap
//
//  Created by Andrew Tu on 1/31/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import Foundation
import UIKit

class AbstractRemoteView: UIView {
  var titleStackView : UIStackView!
  var data: DeviceData!
  
  // MARK: - Setup
  init(frame: CGRect, data: DeviceData) {
    super.init(frame: frame)
    translatesAutoresizingMaskIntoConstraints = false
    self.data = data
    
    setBackground()
    setViews()
    setupStackViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: - Layout
  func setBackground() {
    backgroundColor = .clear
    
    let blurEffect = UIBlurEffect(style: .dark)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    //always fill the view
    insertSubview(blurEffectView, at: 0)
    
    blurEffectView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      blurEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      blurEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      blurEffectView.topAnchor.constraint(equalTo: self.topAnchor),
      blurEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
  }
  
  func setViews() {
    //addSubview(timeUpdaterDisplay)
    //addSubview(avaibleDevicesButton)
  }
  
  private func setupStackViews() {
    // Set the Title
    titleStackView = UIStackView(arrangedSubviews: [titleImage, titleLabel])
    titleLabel.text = data.deviceId
    titleStackView.distribution = .equalSpacing
    titleStackView.axis = .horizontal
    titleStackView.translatesAutoresizingMaskIntoConstraints = false
    //titleStackView.alignment = .center
    addSubview(titleStackView)
    NSLayoutConstraint.activate([
      titleStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      titleStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      titleStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20)
    ])
    
    specializeView()
  }
  
  //MARK: - Top
  var titleImage : UIImageView = {
    let image = UIImage(systemName: "desktopcomputer")!.withRenderingMode(.alwaysTemplate)
    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFit // fit based on width, might cause bands on top/bottom
    
    return imageView
  }()
  
  var titleLabel : UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Placeholder"
    label.textColor = .white
    label.backgroundColor = .clear
    label.sizeToFit()
    label.textAlignment = .center
    label.numberOfLines = 1
    label.font = .systemFont(ofSize: 30)
    
    return label
  }()
  
  func fillView(_ view: UIView) {
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: view.leadingAnchor),
      trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topAnchor.constraint(equalTo: view.topAnchor),
      bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  func specializeView() {
    preconditionFailure("This method must be overridden")
  }
}
