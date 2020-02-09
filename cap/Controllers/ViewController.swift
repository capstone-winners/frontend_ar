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
  
  let sceneView: ARSCNView = ARSCNView()
  let debugView: DebugView = DebugView()
  
  let remoteViewController = RemoteViewController()
  let qrDetector: QRDetector = QRDetector()
  
  //#warning("replace this with the real version")
  //var iotDecoder : IotDataManager = DummyIotDataManager()
  let iotDecoder = IotDataManager()
  
  var shouldProcessFramesForQr : Bool = true
  var isRemoteViewActive : Bool = false
  
  override func loadView() {
    super.loadView()
    
    SetupArView()
    SetupDebugView()
    
    // Prevent the screen from being dimmed after a while as users will likely
    // have long periods of interaction without touching the screen or buttons.
    UIApplication.shared.isIdleTimerDisabled = true
    
    // Start QR Detection
    self.qrDetector.startQrCodeDetection(view: sceneView)
    
    //Create TapGesture Recognizer
    let tripleTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureMakeFullScreen(gesture:)))
    tripleTapGesture.numberOfTapsRequired = 3
    sceneView.addGestureRecognizer(tripleTapGesture)
    
    let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(rec:)))
    singleTapGesture.shouldRequireFailure(of: tripleTapGesture)
    sceneView.addGestureRecognizer(singleTapGesture)
    
    //addController(remoteViewController)
    //configureRemoteView()
  }
  
  //Method called when tap
  @objc func handleSingleTap(rec: UITapGestureRecognizer){
    if rec.state == .ended {
      let location: CGPoint = rec.location(in: sceneView)
      let hits = self.sceneView.hitTest(location, options: nil)
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
        
        self.launchRemoteView(anchor: parent.qrAnchor)
      }
    }
  }
  
  @objc func tapGestureMakeFullScreen(gesture: UITapGestureRecognizer) {
    self.launchRemoteView(anchor: nil)
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
  
  @objc func clearCodes() {
    qrDetector.clear()
    debugView.debugLabel.text = "Saved codes cleared!"
    
    UIView.animate(withDuration: 0, delay: 5.0, options: [], animations: {
      self.debugView.debugLabel.alpha = 0
    }, completion: nil)
  }
  
  func launchRemoteView(anchor: QRAnchor?){
    remoteViewController.updateView(state: iotDecoder.decode(anchor: anchor))
    remoteViewController.presentationController?.delegate = self
    shouldProcessFramesForQr = false
    
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
    shouldProcessFramesForQr = true
    isRemoteViewActive = false
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
  
  func SetupDebugView() {
    view.addSubview(debugView)
    debugView.isUserInteractionEnabled = true
    
    NSLayoutConstraint.activate([
      debugView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      debugView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      debugView.heightAnchor.constraint(equalToConstant: 100),
      debugView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
    ])
    
    debugView.clearButton.addTarget(self, action: #selector(clearCodes), for: .touchUpInside)
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
      //sceneView.scene.rootNode.addChildNode(plane)
      node.addChildNode(plane)
      DispatchQueue.main.async {
        let deviceData = self.iotDecoder.decode(anchor: qrAnchor)
        self.debugView.debugLabel.text = "Last detected: " + (deviceData?.deviceId ?? qrAnchor.label)
        
        self.debugView.debugLabel.sizeToFit()
        self.debugView.debugLabel.alpha = 1.0
        self.launchRemoteView(anchor: qrAnchor)
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
extension ViewController : ARSessionDelegate {
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



