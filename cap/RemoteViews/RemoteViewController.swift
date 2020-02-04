//
//  RemoteViewController.swift
//  cap
//
//  Created by Andrew Tu on 1/28/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//
import UIKit

class RemoteViewController: UIViewController {
  var state : Date = Date()
  var contentView: UIView!
  
  // MARK: - View controller code
  override func loadView() {
    view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    
    contentView = RemoteView()
    view.addSubview(contentView)
    setupRemoteView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if contentView is RemoteView {
      print("loading remote view")
      setupRemoteView()
    } else if contentView is LightView {
      print("loading light view")
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    print("disappearing current view")
    viewFadeIn(currentView: abstractRemoteView, newView: RemoteView())
  }
  
  // MARK: - Downcast Content Views
  var abstractRemoteView : AbstractRemoteView {
    return contentView as! AbstractRemoteView
  }
  var remoteView: RemoteView {
      return contentView as! RemoteView
  }
  var lightView: LightView {
      return contentView as! LightView
  }
  
  // MARK: - RemoteView
  func setupRemoteView() {
    guard (contentView as? RemoteView) != nil else {
      print("error in setting up! ")
      print(type(of: contentView))
      return
    }
    
    // Update view size.
    remoteView.fillView(view)
    remoteView.isUserInteractionEnabled = true
    
    // Setup buttons.
    remoteView.climateButton.addTarget(self, action: #selector(climateButtonAction), for: .touchUpInside)
    remoteView.lightButton.addTarget(self, action: #selector(lightButtonAction), for: .touchUpInside)
    remoteView.lockButton.addTarget(self, action: #selector(lockButtonAction), for: .touchUpInside)
    remoteView.musicButton.addTarget(self, action: #selector(musicButtonAction), for: .touchUpInside)
    
    // Add gestures.
    addGestures(view: contentView, singleTapSelector: #selector(tapGestureMakeFullScreen(gesture:)),
    doubleTapSelector: nil)
  }
  
  @objc func climateButtonAction() {
    print("Climate button pushed!")
    let view = ClimateView()
    view.isUserInteractionEnabled = true
    
    // Add Gestures
    addGestures(view: view, singleTapSelector: nil,
    doubleTapSelector: #selector(tapGestureReturnHome(gesture:)))
    
    viewFadeIn(currentView: contentView, newView: view)
    remoteView.deviceInfoLabel.text = "Climate"
  }
  @objc func lightButtonAction() {
    print("Light button pushed!")
    remoteView.deviceInfoLabel.text = "Light"
    
    let view = LightView()
    view.isUserInteractionEnabled = true
    addGestures(view: view, singleTapSelector: #selector(tapGestureLightView(gesture:)),
                doubleTapSelector: #selector(tapGestureReturnHome(gesture:)))
    
    // Transform View
    viewFadeIn(currentView: contentView, newView: view)
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
  }
  
  @objc func tapGestureLightView(gesture: UITapGestureRecognizer) {
    print("recognized")
    lightView.customData.brightness = lightView.customData.brightness - 0.05
    lightView.reloadView()
  }
  
  @objc func tapGestureReturnHome(gesture: UITapGestureRecognizer) {
    viewFadeIn(currentView: contentView, newView: RemoteView())
  }
  
  func viewFadeIn(currentView: UIView, newView: AbstractRemoteView) {
    newView.alpha = 0.0
    view.insertSubview(newView, aboveSubview: currentView)
    newView.fillView(self.view)
    
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
      newView.alpha = 1.0
    }, completion: {_ in
      currentView.removeFromSuperview()
      self.contentView = newView
      self.viewDidAppear(false)
    })
  }
  
  func addGestures(view: UIView, singleTapSelector: Selector?, doubleTapSelector: Selector?) {
      let singleTapGesture = UITapGestureRecognizer(target: self, action: singleTapSelector)
      singleTapGesture.numberOfTapsRequired = 1
      view.addGestureRecognizer(singleTapGesture)
    
    let doubleTapGesture = UITapGestureRecognizer(target: self, action: doubleTapSelector)
    doubleTapGesture.numberOfTapsRequired = 2
    view.addGestureRecognizer(doubleTapGesture)

    singleTapGesture.require(toFail: doubleTapGesture)
  }
}
