//
//  QRPlane.swift
//  cap
//
//  Created by Andrew Tu on 1/16/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import ARKit
import WebKit

// Convenience extension for colors defined in asset catalog.
extension UIColor {
  static let planeColor = UIColor(named: "planeColor")!
  static let qrColor = UIColor(named: "QRColor")!
}

class QRPlane: SCNNode {
  
  var qrNode: SCNNode!
  var classificationNode: SCNNode!
  
  /// - Tag: VisualizePlane
  init(anchor: QRAnchor, in sceneView: ARSCNView) {
    
    #if targetEnvironment(simulator)
    #error("ARKit is not supported in iOS Simulator. Connect a physical iOS device and select it as your Xcode run destination, or select Generic iOS Device as a build-only destination.")
    #else
    
    super.init()
    
    self.configureQrNode(anchor: anchor)
    // Add the sphere node so it shows up in the scene.
    addChildNode(qrNode)
    //runHighlight(on: qrNode, width: anchor.observation.boundingBox.width, height: anchor.observation.boundingBox.height)
    
    //self.setupSphereVisualStyle()
    self.configureTextNode(anchor: anchor)
    qrNode.addChildNode(classificationNode)
    
    #endif
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureQrNode(anchor: QRAnchor) {
    // Get the width and height of the bounding box.
    let qrWidth = anchor.observation.boundingBox.width
    let qrHeight = anchor.observation.boundingBox.height
    
    // Create a plane geometry to show we're tracking the QR code
    let qrPlane = SCNPlane(width: qrWidth, height: qrHeight)
    //qrPlane.firstMaterial?.colorBufferWriteMask = .alpha
    qrPlane.firstMaterial?.diffuse.contents = UIColor.qrColor
    
    // Attach geometry to a node.
    qrNode = SCNNode(geometry: qrPlane)
    //qrNode.eulerAngles.x = -.pi / 2
    qrNode.renderingOrder = -1
    qrNode.opacity = 1
  }
  
  private func configureTextNode(anchor: QRAnchor) {
    // Display the qr's label
    let textNode = self.makeTextNode(anchor.label)
    classificationNode = textNode
    // Change the pivot of the text node to its center
    textNode.centerAlign()
    // Add the text node as a child node so that it displays the classification
  }
  
  private func setupSphereVisualStyle() {
    // Make the plane visualization semitransparent to clearly show real-world placement.
    qrNode.opacity = 0.25
    
    // Use color and blend mode to make planes stand out.
    guard let material = qrNode.geometry?.firstMaterial
      else { fatalError("ARSCNPlaneGeometry always has one material") }
    material.diffuse.contents = UIColor.planeColor
  }
  
  private func makeTextNode(_ text: String) -> SCNNode {
    let textGeometry = SCNText(string: text, extrusionDepth: 1)
    textGeometry.font = UIFont(name: "Futura", size: 50)
    textGeometry.isWrapped = true
    // textGeometry.containerFrame = qrNode.frame // TODO: SOMETHING????
    
    let textNode = SCNNode(geometry: textGeometry)
    // scale down the size of the text
    textNode.simdScale = SIMD3<Float>(repeating: 0.0005)
    
    return textNode
  }
}

extension QRPlane {
  
  func runHighlight(on node: SCNNode, width qrWidth: CGFloat, height qrHeight: CGFloat) {
    self.highlightDetection(on: node, width: qrWidth, height: qrHeight, completionHandler: {
      
      // Introduce virtual content
      self.displayDetailView(on: node, xOffset: qrWidth)
      
      // Animate the WebView to the right
      self.displayWebView(on: node, xOffset: qrWidth)
      
    })
  }
  
  func displayDetailView(on node: SCNNode, xOffset offset: CGFloat) {
    print("Ran highlight!!!")
  }
  
  func displayWebView(on node: SCNNode, xOffset: CGFloat) {
    DispatchQueue.main.async {
      let webConfiguration = WKWebViewConfiguration()
      let request = URLRequest(url: URL(string: "https://en.wikipedia.org/wiki/Richard_Hamming")!)
      let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 400, height: 672), configuration: webConfiguration)
      webView.load(request)
      
      let webViewPlane = SCNPlane(width: xOffset, height: xOffset * 1.4)
      webViewPlane.cornerRadius = 0.25
      
      let webViewNode = SCNNode(geometry: webViewPlane)
      
      // Set the web view as webViewPlane's primary texture
      webViewNode.geometry?.firstMaterial?.diffuse.contents = webView
      webViewNode.position.z -= 0.5
      webViewNode.opacity = 0
      
      node.addChildNode(webViewNode)
      webViewNode.runAction(.sequence([
        .wait(duration: 3.0),
        .fadeOpacity(to: 1.0, duration: 1.5),
        .moveBy(x: xOffset * 1.1, y: 0, z: -0.05, duration: 1.5),
        .moveBy(x: 0, y: 0, z: -0.05, duration: 0.2)
      ])
      )
    }
  }
  
  func highlightDetection(on rootNode: SCNNode, width: CGFloat, height: CGFloat, completionHandler block: @escaping (() -> Void)) {
    let planeNode = SCNNode(geometry: SCNPlane(width: width, height: height))
    planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.qrColor
    planeNode.position.z += 0.1
    planeNode.opacity = 0
    
    rootNode.addChildNode(planeNode)
    planeNode.runAction(self.imageHighlightAction) {
      block()
    }
    planeNode.opacity = 1
  }
  
  var imageHighlightAction: SCNAction {
    return .sequence([
      .wait(duration: 0.25),
      .fadeOpacity(to: 0.85, duration: 0.25),
      .fadeOpacity(to: 0.15, duration: 0.25),
      .fadeOpacity(to: 0.85, duration: 0.25),
      .fadeOpacity(to: 0.15, duration: 0.25),
      .fadeOpacity(to: 0.85, duration: 0.25),
      .fadeOpacity(to: 0.15, duration: 0.25),
      .fadeOpacity(to: 0.85, duration: 0.25),
      .fadeOpacity(to: 0.15, duration: 0.25),
      .fadeOut(duration: 0.5)//,
      //.removeFromParentNode()
    ])
  }
}
