//
//  QRPlane.swift
//  cap
//
//  Created by Andrew Tu on 1/16/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import ARKit

// Convenience extension for colors defined in asset catalog.
extension UIColor {
  static let planeColor = UIColor(named: "planeColor")!
  static let qrColor = UIColor(named: "QRColor")!
}

class QRPlane: SCNNode {
  
  let sphereNode: SCNNode
  var classificationNode: SCNNode?
  
  /// - Tag: VisualizePlane
  init(anchor: QRAnchor, in sceneView: ARSCNView) {
    
    #if targetEnvironment(simulator)
    #error("ARKit is not supported in iOS Simulator. Connect a physical iOS device and select it as your Xcode run destination, or select Generic iOS Device as a build-only destination.")
    #else
    
    // Create a sphere geometry to show we're tracking the QR code
    let sphereGeometry = SCNSphere(radius: 0.1)
    sphereGeometry.firstMaterial?.diffuse.contents = UIColor.qrColor
    
    // Attach geometry to a node.
    sphereNode = SCNNode(geometry: sphereGeometry)
    //sphereNode.transform = SCNMatrix4(anchor.transform)
    //sphereNode.eulerAngles.x = -.pi / 2

    super.init()
    
    //self.setupSphereVisualStyle()
    
    // Add the sphere node so it shows up in the scene.
    addChildNode(sphereNode)
    
    // Display the qr's label
    let textNode = self.makeTextNode(anchor.label)
    classificationNode = textNode
    // Change the pivot of the text node to its center
    textNode.centerAlign()
    // Add the text node as a child node so that it displays the classification
    sphereNode.addChildNode(textNode)
    #endif
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupSphereVisualStyle() {
    // Make the plane visualization semitransparent to clearly show real-world placement.
    sphereNode.opacity = 0.25
    
    // Use color and blend mode to make planes stand out.
    guard let material = sphereNode.geometry?.firstMaterial
      else { fatalError("ARSCNPlaneGeometry always has one material") }
    material.diffuse.contents = UIColor.planeColor
  }
  
  private func makeTextNode(_ text: String) -> SCNNode {
    let textGeometry = SCNText(string: text, extrusionDepth: 1)
    textGeometry.font = UIFont(name: "Futura", size: 75)
    
    let textNode = SCNNode(geometry: textGeometry)
    // scale down the size of the text
    textNode.simdScale = SIMD3<Float>(0.0005)
    
    return textNode
  }
}
