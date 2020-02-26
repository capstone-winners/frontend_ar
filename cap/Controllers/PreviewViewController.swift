//
//  PreviewViewController.swift
//  cap
//
//  Created by Andrew Tu on 2/26/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
  
  var delegate: ViewController?
  var state : DeviceData?
  var singleTap : UITapGestureRecognizer!
  var fadeOutTask : DispatchWorkItem?
  
  // MARK: - View controller code
  override func loadView() {
    view = PreviewView()                                          // Initialize view.
    view.translatesAutoresizingMaskIntoConstraints = false        // Necessary for auto-layout.
    view.isUserInteractionEnabled = true                          // We want this to be interactive
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    singleTap = UITapGestureRecognizer(target: self, action: #selector(tapped))
    singleTap.numberOfTapsRequired = 1
    view.addGestureRecognizer(singleTap)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    view.removeGestureRecognizer(singleTap!)
  }
  
  func updateView(state: DeviceData?) {
    guard let preview = view as? PreviewView else {
      print("updateView: not a preview state")
      return
    }
    guard state != nil else {
      print("updateView: state nil abort")
      return
    }

    print(state?.icon)
    preview.previewIcon.image = UIImage(systemName: state?.icon ?? Constants.defaultIcon)?.withRenderingMode(.alwaysTemplate)
    preview.previewLabel.text = state?.deviceId
    
    self.state = state // Save this state to use later.
    
    fadeIn() // Show the state
  }
  
  private func fadeIn() {
    self.view.layer.removeAllAnimations()
    fadeOutTask?.cancel()
    
    UIView.animate(withDuration: 1.5, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      self.view.alpha = 1.0
    }, completion: {finished in
      if finished {
        self.viewDidAppear(false)
        self.delayFadeOut(delay: 5.0)
      }
    })
  }
  
  private func delayFadeOut(delay: Double) {
    fadeOutTask = DispatchWorkItem { self.fadeOut() }
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: fadeOutTask!)
  }
  
  private func fadeOut() {
    UIView.animate(withDuration: 1.5, delay : 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      self.view.alpha = 0.0
    }, completion: {finished in
      if finished {
        print("removed state \(finished)")
        self.viewDidDisappear(false)
        self.state = nil
      }
    })
  }
}


extension PreviewViewController : UIGestureRecognizerDelegate {
  @objc func tapped() {
    delegate?.launchRemoteView(jsonString: state?.toJSONString())
  }
}
