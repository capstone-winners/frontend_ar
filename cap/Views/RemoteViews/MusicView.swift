//
//  MusicView.swift
//  cap
//
//  Created by Andrew Tu on 2/9/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit

class MusicView : AbstractRemoteView {
  
  enum buttons : String {
    case play
    case skip
    case reverse
  }
  
  var customData : MusicData {
    get{
      return data as! MusicData
    } set {
      data = newValue
    }
  }
  
  // MARK: - Setup
  convenience init() {
    self.init(data: dummyMusicData())
  }
  
  init(data: DeviceData) {
    data.deviceId = "Music Player"
    super.init(frame: CGRect.zero, data: data)
    self.titleImage.image = UIImage(systemName: data.icon)
    
    specializeView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func specializeView() {
    
    albumArt.translatesAutoresizingMaskIntoConstraints = false
    addSubview(albumArt)
    NSLayoutConstraint.activate([
      albumArt.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      albumArt.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      albumArt.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.3),
      albumArt.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor)
    ])
    
    musicLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(musicLabel)
    NSLayoutConstraint.activate([
      musicLabel.bottomAnchor.constraint(equalTo: albumArt.topAnchor, constant: -50),
      musicLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      musicLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      musicLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
    ])
    
    let buttonStackView = UIStackView(arrangedSubviews:[skipBackButton, playButton, skipForwardButton])
    buttonStackView.distribution = .equalCentering
    buttonStackView.axis = .horizontal
    buttonStackView.translatesAutoresizingMaskIntoConstraints = false
    buttonStackView.alignment = .center
    
    addSubview(buttonStackView)
    
    NSLayoutConstraint.activate([
      buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
      buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
    ])
  }
  
  lazy var musicLabel : UILabel = {
    let fieldLabel = UILabel()
    fieldLabel.translatesAutoresizingMaskIntoConstraints = false
    fieldLabel.text = "Some Snazzy Music"
    fieldLabel.textColor = .white
    fieldLabel.backgroundColor = .clear
    fieldLabel.textAlignment = .center
    fieldLabel.numberOfLines = 1
    fieldLabel.font = .systemFont(ofSize: 25)
    fieldLabel.sizeToFit()
    
    return fieldLabel
  }()
  
  lazy var albumArt : UIImageView = {
    let image = UIImage(systemName: "music.note")?.withRenderingMode(.alwaysTemplate)
    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFit // fit based on width, might cause bands on top/bottom
    
    return imageView
  }()
  
  lazy var skipBackButton : UIButton = {
    return makeButton(systemName: "backward", title: buttons.reverse.rawValue)
  }()
  
  lazy var skipForwardButton : UIButton = {
    return makeButton(systemName: "forward", title: buttons.skip.rawValue)
  }()
  
  lazy var playButton : UIButton = {
    return makeButton(systemName: "play", title: buttons.play.rawValue)
  }()
  
}
