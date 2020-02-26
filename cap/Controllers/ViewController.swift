//
//  ViewController.swift
//  cap
//
//  Created by Andrew Tu on 1/16/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
  
  var sceneView: UIView!
  let debugView: DebugView = DebugView()
  
  let previewViewController = PreviewViewController()
  let remoteViewController = RemoteViewController()
  
  let iotDecoder = IotDataManager()
  
  var isRemoteViewActive : Bool = false
  
  var tripleTapGesture : UITapGestureRecognizer!
  
  override func loadView() {
    super.loadView()
    
    SetupSceneView()
    SetupDebugView()
    
    // Prevent the screen from being dimmed after a while as users will likely
    // have long periods of interaction without touching the screen or buttons.
    UIApplication.shared.isIdleTimerDisabled = true
    
    //Create TapGesture Recognizer
    tripleTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureMakeFullScreen(gesture:)))
    tripleTapGesture.numberOfTapsRequired = 3
    sceneView.addGestureRecognizer(tripleTapGesture)
    
    previewViewController.view.translatesAutoresizingMaskIntoConstraints = false
    addChildController(previewViewController) // Add the preview controller
    configurePreviewView()
  }
  
  func SetupSceneView() {
    fatalError("SetupSceneView has not been implemented")
  }
  
  func SetupDebugView() {
    view.addSubview(debugView)
    debugView.isUserInteractionEnabled = true
    
    NSLayoutConstraint.activate([
      debugView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      debugView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      debugView.heightAnchor.constraint(equalToConstant: 100),
      debugView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
    ])
    
    debugView.clearButton.addTarget(self, action: #selector(clearCodes), for: .touchUpInside)
    debugView.climateButton.addTarget(self, action: #selector(launchPreviewView(_:)), for: .touchUpInside)
    debugView.lightButton.addTarget(self, action: #selector(launchPreviewView(_:)), for: .touchUpInside)
    debugView.musicButton.addTarget(self, action: #selector(launchPreviewView(_:)), for: .touchUpInside)
    debugView.lockButton.addTarget(self, action: #selector(launchPreviewView(_:)), for: .touchUpInside)
  }
  
  func configurePreviewView() {
    NSLayoutConstraint.activate([
      previewViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      previewViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      previewViewController.view.heightAnchor.constraint(equalToConstant: 60),
      previewViewController.view.topAnchor.constraint(equalTo: debugView.bottomAnchor)
    ])
    
    // Start this off as invisible. 
    previewViewController.view.alpha = 0.0
    previewViewController.delegate = self
  }
  
  func configureRemoteView() {
    NSLayoutConstraint.activate([
      remoteViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      remoteViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      remoteViewController.view.heightAnchor.constraint(equalToConstant: 60),
      remoteViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
    ])
  }
  
  @objc func clearCodes() {
    debugView.debugLabel.text = "Saved codes cleared!"
    
    UIView.animate(withDuration: 0, delay: 5.0, options: [], animations: {
      self.debugView.debugLabel.alpha = 0
    }, completion: nil)
  }
  
  @objc func tapGestureMakeFullScreen(gesture: UITapGestureRecognizer) {
     self.launchRemoteView(jsonString: nil)
   }
  
  @objc func launchPreviewView(_ sender: UIButton) {
    switch sender {
    case debugView.climateButton:
      launchPreviewView(jsonString: dummyClimateData().toJSONString())
    case debugView.lightButton:
      launchPreviewView(jsonString: dummyLightData().toJSONString())
    case debugView.musicButton:
      launchPreviewView(jsonString: dummyMusicData().toJSONString())
    case debugView.lockButton:
      launchPreviewView(jsonString: dummyLockData().toJSONString())
    default:
      return
    }
  }
  
  func launchPreviewView(jsonString: String?) {
    previewViewController.updateView(state: iotDecoder.decode(jsonString: jsonString))
  }
  
  func launchRemoteView(jsonString: String?){
    remoteViewController.updateView(state: iotDecoder.decode(jsonString: jsonString))
    remoteViewController.presentationController?.delegate = self
    
    if !isRemoteViewActive {
      isRemoteViewActive = true
      self.present(remoteViewController, animated: true, completion: nil)
    } else {
      print("Remote view is being presented already!")
    }
    
  }
  
  public func presentationControllerDidDismiss(_ presentationController: UIPresentationController)
  {
    // Only called when the sheet is dismissed by DRAGGING.
    // You'll need something extra if you call .dismiss() on the child.
    // (I found that overriding dismiss in the child and calling
    // presentationController.delegate?.presentationControllerDidDismiss
    // works well).
    isRemoteViewActive = false
  }

  func updateDebugLabel(message: String) {
     DispatchQueue.main.async {
       self.debugView.debugLabel.text = message
       
       self.debugView.debugLabel.sizeToFit()
       self.debugView.debugLabel.alpha = 1.0
     }
   }
}
