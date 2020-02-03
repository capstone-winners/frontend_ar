//
//  QRAnchorDetector.swift
//  cap
//  class based on the following SO post:
//  https://stackoverflow.com/questions/45090716/arkit-how-to-put-3d-object-on-qrcode
//
//  Created by Andrew Tu on 1/16/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import Vision
import ARKit

class QRDetector {
  
  var processingQr: Bool = false
  var qrRequests: [VNRequest] = []
  var detectedDataAnchors = [String: QRAnchor]()
  var latestFrame: ARFrame?
  
  var sceneView: ARSCNView!
  
  func startQrCodeDetection(view sceneView: ARSCNView) {
    print("starting detection")
    
    // View
    self.sceneView = sceneView
    
    // Create a Barcode Detection Request
    let request = VNDetectBarcodesRequest(completionHandler: self.requestHandler)
    // Set it to recognize QR code only
    request.symbologies = [.QR]
    self.qrRequests = [request]
  }
  
  func clear() {
    for (_, anchor) in detectedDataAnchors {
      let node = self.sceneView.node(for: anchor)
      node?.removeFromParentNode()
    }
    detectedDataAnchors.removeAll()
  }
  
  func processFrame(_ frame: ARFrame) {
    // On each frame, get the frame image and attempt to find qr codes.
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        if self.processingQr {
          // Already processing a QR code.
          return
        }
        self.processingQr = true
        self.latestFrame = frame
        // Create a request handler using the captured image from the ARFrame
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage,
                                                        options: [:])
        // Process the request
        try imageRequestHandler.perform(self.qrRequests)
      } catch {
      }
    }
  }
  
  func requestHandler(request: VNRequest, error: Error?) {
    // Get the first result out of the results, if there are any
    if let results = request.results, let result = results.first as? VNBarcodeObservation {
      guard let payload = result.payloadStringValue else {return}
      
      // Get the bounding box for the bar code and find the center
      var rect = result.boundingBox
      // Flip coordinates
      rect = rect.applying(CGAffineTransform(scaleX: 1, y: -1))
      rect = rect.applying(CGAffineTransform(translationX: 0, y: 1))
      
      // Get center
      let center = CGPoint(x: rect.midX, y: rect.midY)
      
      DispatchQueue.main.async {
        self.hitTestQrCode(center: center, observation: result)
        self.processingQr = false
      }
    } else {
      self.processingQr = false
    }
  }
  
  func hitTestQrCode(center: CGPoint, observation: VNBarcodeObservation) {
    // Attempt to hit the QR code.
    if let hitTestResults = self.latestFrame?.hitTest(center, types: [.featurePoint] ),
      let hitTestResult = hitTestResults.first, let text = observation.payloadStringValue {
      if let detectedDataAnchor = self.detectedDataAnchors[text],
        let node = self.sceneView.node(for: detectedDataAnchor) {
        // let previousQrPosition = node.position
        node.transform = SCNMatrix4(hitTestResult.worldTransform)
      } else {
        // Create an anchor. The node will be created in delegate methods
        self.detectedDataAnchors[text] = QRAnchor(transform: hitTestResult.worldTransform, observation)
        self.sceneView.session.add(anchor: self.detectedDataAnchors[text]!)
      }
    } else {
      print("Hit test failed")
    }
  }
}
