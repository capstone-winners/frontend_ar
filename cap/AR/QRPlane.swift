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
  var qrAnchor: QRAnchor!
  var deviceType : DeviceType? {
    get {
      return qrAnchor.deviceType
    }
  }
  
  /// - Tag: VisualizePlane
  init(anchor: QRAnchor, in sceneView: ARSCNView) {
    
    super.init()
    qrAnchor = anchor // Store this cuz we'll need it later. 
    
    self.configureQrNode(anchor: anchor)
    // Add the sphere node so it shows up in the scene.
    addChildNode(qrNode)
    
    // self.setupSphereVisualStyle()
    // self.configureTextNode(anchor: anchor)
    // qrNode.addChildNode(classificationNode)
    
    let rotateXAction = SCNAction.rotateBy(x: 0, y: -30, z: 0, duration: 30)
    qrNode.runAction(SCNAction.repeatForever(rotateXAction))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureQrNode(anchor: QRAnchor) {
    // Get the width and height of the bounding box.
    let qrWidth = anchor.observation.boundingBox.width
    let qrHeight = anchor.observation.boundingBox.height
    
    // Create a plane geometry to show we're tracking the QR code
    //let qrPlane = SCNPlane(width: qrWidth, height: qrHeight)
    let qrPlane = SCNSphere(radius: qrWidth)
    //qrPlane.firstMaterial?.colorBufferWriteMask = .alpha
    qrPlane.firstMaterial?.diffuse.contents = UIColor.qrColor
    
    // Attach geometry to a node.
    qrNode = SCNNode(geometry: qrPlane)
    //qrNode.eulerAngles.x = -.pi / 2
    qrNode.renderingOrder = -1
    qrNode.opacity = 1
    
    if let image = imageWithText(text: anchor.label, imageSize: CGSize(width:1024,height:1024), backgroundColor: .qrColor) {
        qrPlane.firstMaterial?.diffuse.contents = image
    }
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
    //textGeometry.containerFrame = qrNode.frame // TODO: SOMETHING????
    
    let textNode = SCNNode(geometry: textGeometry)
    // scale down the size of the text
    textNode.simdScale = SIMD3<Float>(repeating: 0.0005)
    
    return textNode
  }
}

extension QRPlane {
  func imageWithText(text:String, fontSize:CGFloat = 100, fontColor:UIColor = .black, imageSize:CGSize, backgroundColor:UIColor) -> UIImage? {
    
    let imageRect = CGRect(origin: CGPoint.zero, size: imageSize)
    UIGraphicsBeginImageContext(imageSize)
    
    defer {
      UIGraphicsEndImageContext()
    }
    
    guard let context = UIGraphicsGetCurrentContext() else {
      return nil
    }
    
    // Fill the background with a color
    context.setFillColor(backgroundColor.cgColor)
    context.fill(imageRect)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    
    // Define the attributes of the text
    let attributes = [
      NSAttributedString.Key.font: UIFont(name: "TimesNewRomanPS-BoldMT", size:fontSize),
      NSAttributedString.Key.paragraphStyle: paragraphStyle,
      NSAttributedString.Key.foregroundColor: fontColor
    ]
    
    // Determine the width/height of the text for the attributes
    let textSize = text.size(withAttributes: attributes as [NSAttributedString.Key : Any])
    
    // Draw text in the current context
    text.draw(at: CGPoint(x: imageSize.width/2 - textSize.width/2, y: imageSize.height/2 - textSize.height/2), withAttributes: attributes as [NSAttributedString.Key : Any])
    
    if let image = UIGraphicsGetImageFromCurrentImageContext() {
      return image
    }
    return nil
  }
}
