//
//  RemoteViewController.swift
//  cap
//
//  Created by Andrew Tu on 1/28/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import Foundation
import UIKit

class RemoteViewController: UIViewController {
  var state : Date = Date()
  
  override func loadView() {
    view = RemoteView()
    setupRemoteView()
  }
  
  var remoteView: RemoteView {
      return view as! RemoteView
  }
  
  // MARK: - RemoteView
  
  func setupRemoteView() {
    remoteView.isUserInteractionEnabled = true
    remoteView.magicButton.addTarget(self, action: #selector(magicButtonAction), for: .touchUpInside)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureMakeFullScreen(gesture:)))
    remoteView.addGestureRecognizer(tapGesture)
  }
  
  @objc func magicButtonAction() {
      print("button pushed!")
  }
  
  @objc func tapGestureMakeFullScreen(gesture: UITapGestureRecognizer) {
    print("make full screen!")
    remoteView.deviceInfoLabel.text = state.description
//    if gesture.state == .ended {
//      remoteView.isSmall = false
//      remoteViewFullScreenAnimation()
//    }
  }
  
  func remoteViewFullScreenAnimation() {
    UIView.animate(withDuration: 0.2) {
      // value is small when trying to get full screen (0 is top)
      //self.topConstraintForAlbumsTableView?.constant = self.distanceToFullScreen
      self.view.layoutIfNeeded()
    }
    
  }
  
  func remoteViewSmallScreenAnimation() {
    UIView.animate(withDuration: 0.2) {
      //self.topConstraintForAlbumsTableView?.constant = -self.remoteViewHeightWithoutSafeBottom
      self.view.layoutIfNeeded()
    }
    
  }
}
