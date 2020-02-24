//
//  RemoteViewController.swift
//  cap
//
//  Created by Andrew Tu on 1/28/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//
import UIKit
import FlexColorPicker

class RemoteViewController: UIViewController {
  // MARK: - Properties
  var state : DeviceData?
  var contentView: UIView = RemoteView()
  var iotDecoder : IotDataManager = IotDataManager()
  var actionManager : ActionManager = ActionManager()
  let throttler : Throttler? = Throttler(ms: Constants.colorIntervalUpdateMs)
  let colorPickerController = ColorController()
  var lockButtonActive = true
  
  // MARK: - Downcast Content Views
  var remoteView: RemoteView {
    return contentView as! RemoteView
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
      setupRemoteView()
    case is LightView:
      print("did appear: light view")
      setupLightView()
    case is ClimateView:
      print("did appear: climate view")
    case is MusicView:
      print("did appear: music view")
      setupMusicView()
    case is LockView:
      print("did appear: lock view")
      setupLockView()
    default:
      print("wut the fuk u tryna do m8?")
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    colorPickerController.remove()
    
    // Check if we need to convert the view back to a normal RemoteView.
    if !(contentView is RemoteView) {
      let abstractRemoteView = contentView as! AbstractRemoteView
      viewFadeIn(currentView: abstractRemoteView, newView: RemoteView())
    }
    
    
  }
  
  // MARK: -
  func updateView(state: DeviceData?) {
    self.state = state
    
    if(self.state == nil) {
      print("Nil state - do nothing....")
      return
    }
    print("state type: \(state!)")
    switch state!.deviceType {
    case DeviceType.light:
      launchLightView()
    case DeviceType.climate:
      launchClimateView()
    case DeviceType.lock:
      launchLockView()
    case DeviceType.music:
      launchMusicView()
    case DeviceType.abstract:
      print("RemoteViewController: update abstract view - do nothing...")
    }
  }
  
  // MARK: - RemoteView
  func setupRemoteView() {
    guard (contentView as? RemoteView) != nil else {
      print("RemoteViewController: error in setting up remote view! ")
      print(type(of: contentView))
      return
    }
    
    if state != nil {
      remoteView.deviceInfoLabel.text = state!.deviceId
    } else {
      remoteView.deviceInfoLabel.text = "No device information..."
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
  
  func setupLightView() {
    guard let lightView = contentView as? LightView else {
      return
    }
    
    lightView.submitOnButton.addTarget(self, action: #selector(submitPower(_:)), for: .touchUpInside)
    //    lightView.submitBrightnessButton.addTarget(self, action: #selector(submitBrightness), for: .touchUpInside)
    //    lightView.submitColorButton.addTarget(self, action: #selector(submitColor), for: .touchUpInside)
    
    colorPickerController.delegate = self
    colorPickerController.view.translatesAutoresizingMaskIntoConstraints = false
    addChildController(colorPickerController)
    NSLayoutConstraint.activate([
      colorPickerController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      colorPickerController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      colorPickerController.view.topAnchor.constraint(equalTo: lightView.titleStackView.bottomAnchor),
      colorPickerController.view.bottomAnchor.constraint(equalTo: lightView.buttonsStackView.topAnchor),
      colorPickerController.view.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor, multiplier: 0.75)
    ])
  }
  
  func setupMusicView() {
    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      //contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
    
    guard let musicView = contentView as? MusicView else {
      return
    }
    
    musicView.playButton.addTarget(self, action: #selector(musicViewButtons(_:)), for: .touchUpInside)
    musicView.skipBackButton.addTarget(self, action: #selector(musicViewButtons(_:)), for: .touchUpInside)
    musicView.skipForwardButton.addTarget(self, action: #selector(musicViewButtons(_:)), for: .touchUpInside)
  }
  
  func setupLockView() {
    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      //contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
    
    guard let lockView = contentView as? LockView else {
      return
    }
    
    lockView.lockButton.addTarget(self, action: #selector(lockButtonToggled), for: .touchUpInside)
  }
  
  // MARK: - Launchers
  @objc func launchClimateView() {
    safeDeviceInfoLabel("Climate")
    
    var view : ClimateView!
    if let climateData = state as? ClimateData {
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
    safeDeviceInfoLabel("Light")
    
    var view : LightView!
    if let lightData = state as? LightData {
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
    safeDeviceInfoLabel("Lock")
    viewFadeIn(currentView: remoteView, newView: LockView())
  }
  
  @objc func launchMusicView() {
    safeDeviceInfoLabel("Music")
    viewFadeIn(currentView: remoteView, newView: MusicView())
  }
  
  // MARK: - Tap Gestures
  @objc func tapGestureMakeFullScreen(gesture: UITapGestureRecognizer) {
    if state != nil {
      safeDeviceInfoLabel(state!.deviceId)
    } else {
      safeDeviceInfoLabel("Tap detected!")
    }
  }
  
  @objc func tapGestureLightView(gesture: UITapGestureRecognizer) {
    guard let lightView = contentView as? LightView else {
      return
    }
    
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
    
    if currentView as? LightView != nil {
      colorPickerController.remove()
    }
    
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

// MARK: Action Submitters
extension RemoteViewController {
  @objc func submitPower(_ sender:UISwitch) {
    let powerAction = createSetLightOn(deviceType: state?.deviceType ?? DeviceType.light, deviceId: state?.deviceId ?? Constants.unknownLightId , on: sender.isOn)
    print(powerAction)
    actionManager.publish(powerAction)
  }
  
  @objc func submitBrightness() {
    let brightnessAction = createSetBrightnessAction(deviceType: state?.deviceType ?? DeviceType.light, deviceId: state?.deviceId ?? Constants.unknownLightId, brightness: 0.75)
    print(brightnessAction)
    actionManager.publish(brightnessAction)
  }
  
  @objc func musicViewButtons(_ sender:UIButton) {
    guard let button = MusicView.buttons(rawValue: sender.title(for: .normal)!) else {
      return
    }
    
    let devicetype = state?.deviceType ?? DeviceType.music
    let deviceid = state?.deviceId ?? Constants.unknownLightId
    
    var musicAction : Action
    switch button {
    case .play:
      musicAction = createPlayAction(deviceType: devicetype, deviceId: deviceid, play: true)
    case .skip:
      musicAction = createSkipAction(deviceType: devicetype, deviceId: deviceid, forward: true)
    case .reverse:
      musicAction = createSkipAction(deviceType: devicetype, deviceId: deviceid, forward: false)
    }
    
    print(musicAction)
    actionManager.publish(musicAction)
  }
  
  func submitColor(_ color: UIColor) {
    let colorAction = createSetColorAction(deviceType: state?.deviceType ?? DeviceType.light, deviceId: state?.deviceId ?? Constants.unknownLightId, color: color)
    print(colorAction)
    actionManager.publish(colorAction)
  }
  
  @objc func lockButtonToggled() {
    guard let lockView = contentView as? LockView else {
      return
    }
    
    let devicetype = state?.deviceType ?? DeviceType.lock
    let deviceid = state?.deviceId ?? Constants.unknownLightId
    var action : Action
    
    if lockButtonActive {
      lockView.lockButton.imageView?.backgroundColor = .red
      action = createSetLocked(deviceType: devicetype, deviceId: deviceid, locked: true)
    } else {
      lockView.lockButton.imageView?.backgroundColor = .green
      action = createSetLocked(deviceType: devicetype, deviceId: deviceid, locked: false)
    }
    
    print(action)
    actionManager.publish(action)
    let data = dummyLockData()
    data.isLocked = lockButtonActive
    lockView.customData = data
    lockView.reload()
    lockButtonActive = !lockButtonActive
  }
}


// MARK: ColorPicker Extension
extension RemoteViewController : ColorPickerDelegate {
  func colorPicker(_ colorPicker: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
    
    // If we didn't set up the throttler, than just submit everything.
    guard let throttler = self.throttler else {
      print("Selected: \(selectedColor)")
      submitColor(selectedColor)
      return
    }
    
    // Throttle commands so we're not spamming.
    throttler.throttle {
      DispatchQueue.main.async {
        print("Selected: \(selectedColor)\n\n")
        self.submitColor(selectedColor)
      }
    }
  }
  
  func colorPicker(_ colorPicker: ColorPickerController, confirmedColor: UIColor, usingControl: ColorControl) {
    print("Confirmed: \(confirmedColor)")
    submitColor(confirmedColor)
  }
}
