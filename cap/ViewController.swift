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

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate{
  
  @IBOutlet var sceneView: ARSCNView!
  
  var qrDetector: QRDetector = QRDetector()
  
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
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = [.horizontal, .vertical]
    
    // Run the view's session
    sceneView.session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Pause the view's session
    sceneView.session.pause()
  }
  
  // MARK: - ARSCNViewDelegate
  
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
      node.addChildNode(plane)
    }
  }
  
  /// - Tag: UpdateARContent
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    // Update only anchors and nodes set up by `renderer(_:didAdd:for:)`.
    guard let planeAnchor = anchor as? ARPlaneAnchor,
      let plane = node.childNodes.first as? Plane
      else {
        print("anchor as? ARAnchor: " + String(anchor == qrDetector.detectedDataAnchor))
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
