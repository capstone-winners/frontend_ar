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
  var contentView: UIView!
  
  override func loadView() {
    view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    
    contentView = RemoteView()
    view.addSubview(contentView)
    setupRemoteView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    setupRemoteView()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    print("dismissed!")
    viewFadeIn(currentView: abstractRemoteView, newView: RemoteView())
  }
  
  var abstractRemoteView : AbstractRemoteView {
    return contentView as! AbstractRemoteView
  }
  var remoteView: RemoteView {
      return contentView as! RemoteView
  }
  
  var climateView : ClimateView {
    return contentView as! ClimateView
  }
  
  // MARK: - RemoteView
  func setupRemoteView() {
    remoteView.fillView(view)
    remoteView.isUserInteractionEnabled = true
    
    remoteView.climateButton.addTarget(self, action: #selector(climateButtonAction), for: .touchUpInside)
    remoteView.lightButton.addTarget(self, action: #selector(lightButtonAction), for: .touchUpInside)
    remoteView.lockButton.addTarget(self, action: #selector(lockButtonAction), for: .touchUpInside)
    remoteView.musicButton.addTarget(self, action: #selector(musicButtonAction), for: .touchUpInside)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureMakeFullScreen(gesture:)))
    remoteView.addGestureRecognizer(tapGesture)
  }
  
  @objc func climateButtonAction() {
    print("Climate button pushed!")
    viewFadeIn(currentView: remoteView, newView: ClimateView())
    remoteView.deviceInfoLabel.text = "Climate"
  }
  @objc func lightButtonAction() {
    print("Light button pushed!")
    remoteView.deviceInfoLabel.text = "Light"
    //viewFadeIn(currentView: remoteView, newView: ClimateView())
  }
  @objc func lockButtonAction() {
    print("Lock button pushed!")
    remoteView.deviceInfoLabel.text = "Lock"
    //viewFadeIn(currentView: remoteView, newView: ClimateView())
  }
  @objc func musicButtonAction() {
    print("Music button pushed!")
    remoteView.deviceInfoLabel.text = "Music"
    //viewFadeIn(currentView: remoteView, newView: ClimateView())
  }
  
  @objc func tapGestureMakeFullScreen(gesture: UITapGestureRecognizer) {
    print("make full screen!")
    remoteView.deviceInfoLabel.text = state.description
//    if gesture.state == .ended {
//      remoteView.isSmall = false
//      remoteViewFullScreenAnimation()
//    }
  }
  func viewFadeIn(currentView: AbstractRemoteView, newView: AbstractRemoteView) {
    newView.alpha = 0.0
    view.insertSubview(newView, aboveSubview: currentView)
    newView.fillView(self.view)
    
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
      newView.alpha = 1.0
    }, completion: {_ in
      currentView.removeFromSuperview()
      self.contentView = newView
      
    })
    
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
