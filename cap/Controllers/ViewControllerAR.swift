//
//  ViewControllerAR.swift
//  cap
//
//  Created by Andrew Tu on 2/26/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewControllerAR: ViewController {
  
  let qrDetector: QRDetector = QRDetector()
  
  var shouldProcessFramesForQr : Bool = true
  
  override func loadView() {
    super.loadView()
    
    // Start QR Detection
    self.qrDetector.startQrCodeDetection(parent: self)
    
    let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(rec:)))
    singleTapGesture.shouldRequireFailure(of: tripleTapGesture)
    sceneView.addGestureRecognizer(singleTapGesture)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    guard let arSceneView = sceneView as? ARSCNView else {
      return
    }
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    //configuration.planeDetection = [.horizontal, .vertical]
    
    // Run the view's session
    arSceneView.session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    guard let arSceneView = sceneView as? ARSCNView else {
      return
    }
    
    // Pause the view's session
    arSceneView.session.pause()
  }
  
  override func SetupSceneView() {
    sceneView = ARSCNView()
    
    guard let arSceneView = sceneView as? ARSCNView else {
      return
    }

    // Set the view's delegate
    arSceneView.delegate = self
    
    // Set the session delegate
    arSceneView.session.delegate = self
    
    // Show statistics such as fps and timing information
    arSceneView.showsStatistics = true
    view.addSubview(sceneView)
    
    sceneView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      sceneView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      sceneView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      sceneView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
    ])
  }
  
  //Method called when tap
  @objc func handleSingleTap(rec: UITapGestureRecognizer){
    guard let arSceneView = sceneView as? ARSCNView else {
      return
    }
    
    if rec.state == .ended {
      let location: CGPoint = rec.location(in: arSceneView)
      let hits = arSceneView.hitTest(location, options: nil)
      if !hits.isEmpty{
        let tappedNode = hits.first?.node
        let bounceAction = SCNAction.sequence([
          SCNAction.move(by: SCNVector3(0,Constants.bounceDistance,0), duration: Constants.bounceTiming),
          SCNAction.move(by: SCNVector3(0,-2*Constants.bounceDistance,0), duration: Constants.bounceTiming),
          SCNAction.move(by: SCNVector3(0,Constants.bounceDistance,0), duration: Constants.bounceTiming),
        ])
        tappedNode!.runAction(bounceAction)
        guard let parent = tappedNode?.parent as? QRPlane else {
          print("Parent is not a QRPlane!")
          return
        }
        
        self.launchRemoteView(jsonString: parent.qrAnchor.observation.payloadStringValue)
      }
    }
  }
  
  @objc override func clearCodes() {
    qrDetector.clear()
    super.clearCodes()
  }
  
  override func launchRemoteView(jsonString: String?){
    shouldProcessFramesForQr = false
    super.launchRemoteView(jsonString: jsonString)
  }
  
  override public func presentationControllerDidDismiss(_ presentationController: UIPresentationController)
  {
    super.presentationControllerDidDismiss(presentationController)
    shouldProcessFramesForQr = true
  }
  
  
}

// MARK: - ARSCNViewDelegate
extension ViewControllerAR : ARSCNViewDelegate {
  /*
   // Override to create and configure nodes for anchors added to the view's session.
   func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
   let node = SCNNode()
   
   return node
   }
   */
  
  /// - Tag: PlaceARContent
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let arSceneView = sceneView as? ARSCNView else {
      return
    }
    
    if let planeAnchor = anchor as? ARPlaneAnchor {
      // Place content only for anchors found by plane detection.
      let plane = Plane(anchor: planeAnchor, in: arSceneView)
      node.addChildNode(plane)
    } else if let qrAnchor = anchor as? QRAnchor {
      // Place content only for anchors found by QR Detection.
      let plane = QRPlane(anchor: qrAnchor, in: arSceneView)
      //sceneView.scene.rootNode.addChildNode(plane)
      node.addChildNode(plane)
      DispatchQueue.main.async {
        let deviceData = self.iotDecoder.decode(anchor: qrAnchor)
        self.debugView.debugLabel.text = "Last detected: " + (deviceData?.deviceId ?? qrAnchor.label)
        
        self.debugView.debugLabel.sizeToFit()
        self.debugView.debugLabel.alpha = 1.0
        //self.launchRemoteView(jsonString: qrAnchor.observation.payloadStringValue)
        self.launchPreviewView(jsonString: qrAnchor.observation.payloadStringValue)
      }
    }
  }
  
  /// - Tag: UpdateARContent
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    // Update only anchors and nodes set up by `renderer(_:didAdd:for:)`.
    guard let planeAnchor = anchor as? ARPlaneAnchor,
      let plane = node.childNodes.first as? Plane
      else {
        //print("anchor as? ARAnchor: " + String(anchor is QRAnchor))
        return }
    
    updatePlaneAnchor(planeAnchor, plane)
  }
  
  func updatePlaneAnchor(_ planeAnchor : ARPlaneAnchor, _ plane : Plane) {
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
extension ViewControllerAR : ARSessionDelegate {
  func session(_ session: ARSession, didUpdate frame: ARFrame) {
    if(shouldProcessFramesForQr) {
      // Pass frame to the QRDetector to figure out if we need to do anything with the frame.
      qrDetector.processFrame(frame)
    }
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



