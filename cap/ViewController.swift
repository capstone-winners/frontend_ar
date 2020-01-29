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

class ViewController: UIViewController{
  
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var label: UILabel!
  var remoteView = RemoteView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
  
  var qrDetector: QRDetector = QRDetector()
  
  //MARK: - Layout Variables
  var remoteViewSmallHeight : CGFloat {
      get {
          return 60
      }
  }
  var topConstraintForAlbumsTableView : NSLayoutConstraint?
  var remoteViewHeightWithoutSafeBottom: CGFloat {
      get {
          return remoteViewSmallHeight - bottomSafeAreaHeight
      }
  }

  var topSafeAreaHeight : CGFloat {
      get {
          if let window = UIApplication.shared.keyWindow , #available(iOS 11.0, *) {
              return window.safeAreaInsets.top
          } else {
              return 0
          }
      }
  }
  var bottomSafeAreaHeight : CGFloat  {
      get {
          if let window = UIApplication.shared.keyWindow , #available(iOS 11.0, *) {
              return window.safeAreaInsets.bottom
          } else {
              return 0
          }
      }
  }
  
   //distance to take it to full screen
  var distanceToFullScreen: CGFloat {
      get {
          return topSafeAreaHeight - view.frame.height
      }
  }
  
  var remoteOriginalCenter: CGPoint!
  var remoteOffset: CGFloat!
  var remoteUp: CGPoint!
  var remoteDown: CGPoint!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the view's delegate
    sceneView.delegate = self
    
    // Set the session delegate
    sceneView.session.delegate = self
    
    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true
    
    // Prevent the screen from being dimmed after a while as users will likely
    // have long periods of interaction without touching the screen or buttons.
    UIApplication.shared.isIdleTimerDisabled = true
    
    // Start QR Detection
    self.qrDetector.startQrCodeDetection(view: sceneView)
    
    label.lineBreakMode = .byWordWrapping
    label.isHidden = true
    
    setupRemoteView()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    //configuration.planeDetection = [.horizontal, .vertical]
    
    // Run the view's session
    sceneView.session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Pause the view's session
    sceneView.session.pause()
  }
  
  @IBAction func clearCodes(_ sender: UIButton) {
    qrDetector.clear()
    label.isHidden = true
  }
  
}

// MARK: - ARSCNViewDelegate
extension ViewController : ARSCNViewDelegate {
  /*
   // Override to create and configure nodes for anchors added to the view's session.
   func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
   let node = SCNNode()
   
   return node
   }
   */
  
  /// - Tag: PlaceARContent
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    if let planeAnchor = anchor as? ARPlaneAnchor {
      // Place content only for anchors found by plane detection.
      let plane = Plane(anchor: planeAnchor, in: sceneView)
      node.addChildNode(plane)
    } else if let qrAnchor = anchor as? QRAnchor {
      // Place content only for anchors found by QR Detection.
      let plane = QRPlane(anchor: qrAnchor, in: sceneView)
      sceneView.scene.rootNode.addChildNode(plane)
      DispatchQueue.main.async {
        self.label.text = "Last detected: " + qrAnchor.label
        self.label.sizeToFit()
        self.label.isHidden = false
      }
    }
  }
  
  /// - Tag: UpdateARContent
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    // Update only anchors and nodes set up by `renderer(_:didAdd:for:)`.
    guard let planeAnchor = anchor as? ARPlaneAnchor,
      let plane = node.childNodes.first as? Plane
      else {
        print("anchor as? ARAnchor: " + String(anchor is QRAnchor))
        return }
    
    // Update ARSCNPlaneGeometry to the anchor's new estimated shape.
    if let planeGeometry = plane.meshNode.geometry as? ARSCNPlaneGeometry {
      planeGeometry.update(from: planeAnchor.geometry)
    }
    
    // Update extent visualization to the anchor's new bounding rectangle.
    if let extentGeometry = plane.extentNode.geometry as? SCNPlane {
      extentGeometry.width = CGFloat(planeAnchor.extent.x)
      extentGeometry.height = CGFloat(planeAnchor.extent.z)
      plane.extentNode.simdPosition = planeAnchor.center
    }
    
    // Update the plane's classification and the text position
    if #available(iOS 12.0, *),
      let classificationNode = plane.classificationNode,
      let classificationGeometry = classificationNode.geometry as? SCNText {
      let currentClassification = planeAnchor.classification.description
      if let oldClassification = classificationGeometry.string as? String, oldClassification != currentClassification {
        classificationGeometry.string = currentClassification
        classificationNode.centerAlign()
      }
    }
    
  }
}

// MARK: - ARSessionDelegate
extension ViewController : ARSessionDelegate {
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    // Pass frame to the QRDetector to figure out if we need to do anything with the frame.
    qrDetector.processFrame(frame)
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    // Present an error message to the user
    
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
  }
}

// MARK: - RemoteView
extension ViewController {
  
  func setupRemoteView() {
    
    
    remoteOffset = 160
    remoteUp = remoteView.center
    remoteDown = CGPoint(x: remoteView.center.x ,y: remoteView.center.y + remoteOffset)

    remoteView.isUserInteractionEnabled = true
    sceneView.isUserInteractionEnabled = true
    remoteView.deviceInfoLabel.isUserInteractionEnabled=true

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureMakeFullScreen(gesture:)))
    //let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gesture:)))
    //remoteView.addGestureRecognizer(panGesture)
    sceneView.addGestureRecognizer(tapGesture)
    
    sceneView.addSubview(remoteView)
    remoteView.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor).isActive = true
    remoteView.leftAnchor.constraint(equalTo: sceneView.leftAnchor).isActive = true
    remoteView.rightAnchor.constraint(equalTo: sceneView.rightAnchor).isActive = true

  }
  
  @objc func tapGestureMakeFullScreen(gesture: UITapGestureRecognizer) {
    print("make full screen!")
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "LoginVC")
    self.present(controller, animated: true, completion: nil)

    // Safe Present
    /*if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? RemoteViewController
    {
        present(vc, animated: true, completion: nil)
    }*/
    
    if gesture.state == .ended {
      remoteView.isSmall = false
      remoteViewFullScreenAnimation()
    }
  }
  
  @objc func panGesture(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: view)
    let velocity = gesture.velocity(in: view)
    
    print("translation \(translation)")
    print("velocity \(velocity)")

    
    if gesture.state == UIGestureRecognizer.State.began {
      remoteOriginalCenter = remoteView.center
    } else if gesture.state == UIGestureRecognizer.State.changed {
      remoteView.center = CGPoint(x: remoteOriginalCenter.x, y: remoteOriginalCenter.y + translation.y)
      
    } else if gesture.state == UIGestureRecognizer.State.ended {
      if velocity.y > 0 {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
          self.remoteView.center = self.remoteDown
         })
      } else {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
          self.remoteView.center = self.remoteUp
         })
      }
    }
    
  }
  
  func remoteViewFullScreenAnimation() {
      UIView.animate(withDuration: 0.2) {
          // value is small when trying to get full screen (0 is top)
          self.topConstraintForAlbumsTableView?.constant = self.distanceToFullScreen
          self.view.layoutIfNeeded()
      }
      
  }
  
  func remoteViewSmallScreenAnimation() {
      UIView.animate(withDuration: 0.2) {
          self.topConstraintForAlbumsTableView?.constant = -self.remoteViewHeightWithoutSafeBottom
          self.view.layoutIfNeeded()
      }
      
  }
}

