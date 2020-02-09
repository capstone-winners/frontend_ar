//
//  MusicView.swift
//  cap
//
//  Created by Andrew Tu on 2/9/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit

class MusicView : AbstractRemoteView {
  
  // MARK: - Setup
  convenience init() {
    self.init(data: dummyAbstractData())
  }
  
  init(data: DeviceData) {
    super.init(frame: CGRect.zero, data: data)
    self.titleImage.image = UIImage(systemName: data.icon)
    
    specializeView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func specializeView() {
    let buttonStackView = UIStackView(arrangedSubviews:[skipBackButton, playButton, skipForwardButton])
    buttonStackView.distribution = .equalCentering
    buttonStackView.axis = .horizontal
    buttonStackView.translatesAutoresizingMaskIntoConstraints = false
    buttonStackView.alignment = .center
    
    addSubview(buttonStackView)
    
    NSLayoutConstraint.activate([
      buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
      buttonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
      buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
    ])
  }
  
  lazy var skipBackButton : UIButton = {
    return makeButton(systemName: "backward", title: nil)
  }()
  
  lazy var skipForwardButton : UIButton = {
    return makeButton(systemName: "forward", title: nil)
  }()
  
  lazy var playButton : UIButton = {
    return makeButton(systemName: "play", title: nil)
  }()
  
}
