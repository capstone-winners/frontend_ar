//
//  RemoteViewController.swift
//  cap
//
//  Created by Andrew Tu on 1/28/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//
import UIKit

class RemoteViewController: UIViewController {
  // MARK: - Properties
  var state : QRAnchor?
  var contentView: UIView = RemoteView()
  #warning("replace this with the real version")
  var iotDecoder : IotDataManager = DummyIotDataManager()
  var deviceState : DeviceData? {
    get {
      return iotDecoder.decode(anchor: state)
    }
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
  
  // MARK: - View controller code
  override func loadView() {
    view = UIView()                                           // Initialize view.
    view.translatesAutoresizingMaskIntoConstraints = false    // Necessary for auto-layout.
    
    contentView = RemoteView()
    view.addSubview(contentView)
    
    setupRemoteView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    switch contentView {
    case is RemoteView:
      print("did appear: remote view")
      setupRemoteView()
    case is LightView:
      print("did appear: light view")
    case is ClimateView:
      print("did appear: climate view")
    default:
      print("wut the fuk u tryna do m8?")
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    // Check if we need to convert the view back to a normal RemoteView.
    if !(contentView is RemoteView) {
      viewFadeIn(currentView: abstractRemoteView, newView: RemoteView())
    }
  }
  
  // MARK: -
  func updateView(state: QRAnchor?) {
    self.state = state
    
    switch deviceState!.deviceType {
    case DeviceType.light:
      launchLightView()
    case DeviceType.climate:
      launchClimateView()
    case DeviceType.lock:
      launchLockView()
    case DeviceType.music:
      launchMusicView()
    case DeviceType.abstract:
      print("do nothing")
    }
  }
  
  // MARK: - RemoteView
  func setupRemoteView() {
    guard (contentView as? RemoteView) != nil else {
      print("error in setting up! ")
      print(type(of: contentView))
      return
    }
    
    if deviceState != nil {
      remoteView.deviceInfoLabel.text = deviceState!.deviceId
    }
    
    // Update view size.
    remoteView.fillView(view)
    remoteView.isUserInteractionEnabled = true
    
    // Setup buttons.
    remoteView.climateButton.addTarget(self, action: #selector(launchClimateView), for: .touchUpInside)
    remoteView.lightButton.addTarget(self, action: #selector(launchLightView), for: .touchUpInside)
    remoteView.lockButton.addTarget(self, action: #selector(launchLockView), for: .touchUpInside)
    remoteView.musicButton.addTarget(self, action: #selector(launchMusicView), for: .touchUpInside)
    
    // Add gestures.
    addGestures(view: contentView, singleTapSelector: #selector(tapGestureMakeFullScreen(gesture:)),
    doubleTapSelector: nil)
  }
  
  // MARK: - Launchers
  @objc func launchClimateView() {
    print("Climate button pushed!")
    safeDeviceInfoLabel("Climate")
    
    var view : ClimateView!
    if let climateData = deviceState as? ClimateData {
      view = ClimateView(data: climateData)
    } else {
      view = ClimateView()
    }
    
    view.isUserInteractionEnabled = true
    
    // Add Gestures
    addGestures(view: view, singleTapSelector: nil,
    doubleTapSelector: #selector(tapGestureReturnHome(gesture:)))
    
    viewFadeIn(currentView: contentView, newView: view)
  }
  
  @objc func launchLightView() {
    print("Light button pushed!")
    safeDeviceInfoLabel("Light")
    
    var view : LightView!
    if let lightData = deviceState as? LightData {
      view = LightView(data: lightData)
    } else {
      view = LightView()
    }
    
    view.isUserInteractionEnabled = true
    addGestures(view: view, singleTapSelector: #selector(tapGestureLightView(gesture:)),
                doubleTapSelector: #selector(tapGestureReturnHome(gesture:)))
    
    // Transform View
    viewFadeIn(currentView: contentView, newView: view)
  }
  
  @objc func launchLockView() {
    print("Lock button pushed!")
    safeDeviceInfoLabel("Lock")
    //viewFadeIn(currentView: remoteView, newView: ClimateView())
  }
  
  @objc func launchMusicView() {
    print("Music button pushed!")
    safeDeviceInfoLabel("Music")
    //viewFadeIn(currentView: remoteView, newView: ClimateView())
  }
  
  // MARK: - Tap Gestures
  @objc func tapGestureMakeFullScreen(gesture: UITapGestureRecognizer) {
    print("make full screen!")
    if state != nil {
      safeDeviceInfoLabel(state!.label)
    }
  }
  
  @objc func tapGestureLightView(gesture: UITapGestureRecognizer) {
    lightView.customData.brightness = lightView.customData.brightness - 0.05
    lightView.reloadView()
  }
  
  @objc func tapGestureReturnHome(gesture: UITapGestureRecognizer) {
    viewFadeIn(currentView: contentView, newView: RemoteView())
  }
  
  // MARK: - Helpers
  private func viewFadeIn(currentView: UIView, newView: AbstractRemoteView) {
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
  
  private func addGestures(view: UIView, singleTapSelector: Selector?, doubleTapSelector: Selector?) {
      let singleTapGesture = UITapGestureRecognizer(target: self, action: singleTapSelector)
      singleTapGesture.numberOfTapsRequired = 1
      view.addGestureRecognizer(singleTapGesture)
    
    let doubleTapGesture = UITapGestureRecognizer(target: self, action: doubleTapSelector)
    doubleTapGesture.numberOfTapsRequired = 2
    view.addGestureRecognizer(doubleTapGesture)

    singleTapGesture.require(toFail: doubleTapGesture)
  }
  
  private func safeDeviceInfoLabel(_ message: String) {
    guard (contentView as? RemoteView != nil) else {return}
      
    remoteView.deviceInfoLabel.text = message
  }
  
}
