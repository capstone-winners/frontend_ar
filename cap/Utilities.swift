//
//  Utilities.swift
//  cap
//
//  Created by Andrew Tu on 1/16/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import ARKit

@available(iOS 12.0, *)
extension ARPlaneAnchor.Classification {
  var description: String {
    switch self {
    case .wall:
      return "Wall"
    case .floor:
      return "Floor"
    case .ceiling:
      return "Ceiling"
    case .table:
      return "Table"
    case .seat:
      return "Seat"
    case .none(.unknown):
      return "Unknown"
    default:
      return ""
    }
  }
}

extension SCNNode {
  func centerAlign() {
    let (min, max) = boundingBox
    let extents = SIMD3<Float>(max) - SIMD3<Float>(min)
    simdPivot = float4x4(translation: ((extents / 2) + SIMD3<Float>(min)))
  }
}

extension float4x4 {
  init(translation vector: SIMD3<Float>) {
    self.init(SIMD4<Float>(1, 0, 0, 0),
              SIMD4<Float>(0, 1, 0, 0),
              SIMD4<Float>(0, 0, 1, 0),
              SIMD4<Float>(vector.x, vector.y, vector.z, 1))
  }
}

extension UIButton {
  convenience init(type: UIButton.ButtonType = .system, backgroundColor: UIColor?, image: UIImage?, imageTintColor: UIColor?) {
    
    self.init(type: type)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.backgroundColor = backgroundColor
    setImage(image, for: .normal)
    imageView?.tintColor = imageTintColor
  }
}

extension UIImage {
  
  func maskWithColor(color: UIColor) -> UIImage? {
    let maskImage = cgImage!
    
    let width = size.width
    let height = size.height
    let bounds = CGRect(x: 0, y: 0, width: width, height: height)
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
    
    context.clip(to: bounds, mask: maskImage)
    context.setFillColor(color.cgColor)
    context.fill(bounds)
    
    if let cgImage = context.makeImage() {
      let coloredImage = UIImage(cgImage: cgImage)
      return coloredImage
    } else {
      return nil
    }
  }
  
}

@nonobjc extension UIViewController {
  // Call this from the parent
  //
  // add(childController)
  //
  func addChildController(_ child: UIViewController, frame: CGRect? = nil) {
    addChild(child)
    
    if frame != nil {
      child.view.frame = frame!
    }
    
    view.addSubview(child.view)
    child.didMove(toParent: self)
  }
  
  // Call this on the child.
  //
  // child.remove()
  func remove() {
    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()
  }
}

func getStringField(labeled label: String, withData data: String) -> UIStackView{
  let fieldLabel = UILabel()
  fieldLabel.translatesAutoresizingMaskIntoConstraints = false
  fieldLabel.text = label
  fieldLabel.textColor = .white
  fieldLabel.backgroundColor = .clear
  fieldLabel.sizeToFit()
  fieldLabel.textAlignment = .justified
  fieldLabel.numberOfLines = 1
  fieldLabel.font = .systemFont(ofSize: 13)
  
  let fieldData = UILabel()
  fieldData.translatesAutoresizingMaskIntoConstraints = false
  fieldData.text = data
  fieldData.textColor = .white
  fieldData.backgroundColor = .clear
  fieldData.sizeToFit()
  fieldData.textAlignment = .justified
  fieldData.numberOfLines = 1
  fieldData.font = .systemFont(ofSize: 13)
  
  let field = UIStackView(arrangedSubviews: [fieldLabel, fieldData])
  field.distribution = .equalSpacing
  field.axis = .horizontal
  field.translatesAutoresizingMaskIntoConstraints = false
  
  return field
}

func makeButton(systemName icon: String, title: String) -> UIButton {
  let image = UIImage(systemName: icon)?.withRenderingMode(.alwaysTemplate)
  let button = UIButton(type: .custom, backgroundColor: nil, image: image, imageTintColor: .white)
  button.setTitle(title, for: .normal)
  return button
}

extension UIView {
  func findViewController() -> UIViewController? {
    if let nextResponder = self.next as? UIViewController {
      return nextResponder
    } else if let nextResponder = self.next as? UIView {
      return nextResponder.findViewController()
    } else {
      return nil
    }
  }
}
