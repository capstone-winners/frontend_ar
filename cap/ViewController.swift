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
  
  let sceneView: ARSCNView = ARSCNView()
  let label: UILabel = UILabel()
  let remoteViewController = RemoteViewController()
  
  
  var qrDetector: QRDetector = QRDetector()
  
  override func loadView() {
    super.loadView()
    
    SetupArView()
    
    // Prevent the screen from being dimmed after a while as users will likely
    // have long periods of interaction without touching the screen or buttons.
    UIApplication.shared.isIdleTimerDisabled = true
    
    // Start QR Detection
    self.qrDetector.startQrCodeDetection(view: sceneView)
    
    label.lineBreakMode = .byWordWrapping
    label.isHidden = true
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureMakeFullScreen(gesture:)))
    sceneView.addGestureRecognizer(tapGesture)
    //addController(remoteViewController)
    //configureRemoteView()
  }
  
  @objc func tapGestureMakeFullScreen(gesture: UITapGestureRecognizer) {
    remoteViewController.state = Date()
    print(remoteViewController.state.description)
    self.present(remoteViewController, animated: true, completion: nil)
  }
  
  func configureRemoteView() {
    NSLayoutConstraint.activate([
      remoteViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      remoteViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      remoteViewController.view.heightAnchor.constraint(equalToConstant: 60),
      remoteViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
    ])
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
  
  func SetupArView() {
    // Set the view's delegate
    sceneView.delegate = self
    
    // Set the session delegate
    sceneView.session.delegate = self
    
    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true
    view.addSubview(sceneView)
    
    sceneView.translatesAutoresizingMaskIntoConstraints = false
    sceneView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    sceneView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    sceneView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
  }
  
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



