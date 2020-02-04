//
//  QRAnchor.swift
//  cap
//
//  Created by Andrew Tu on 1/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//
import ARKit
import Vision

class QRAnchor : ARAnchor {
  
  var observation: VNBarcodeObservation
  var label: String
  
  required init(anchor: ARAnchor) {
    if let tempAnchor = anchor as? QRAnchor {
      self.observation = tempAnchor.observation
      self.label = tempAnchor.label
      super.init(anchor: anchor)
    } else {
      fatalError("cannot copy non qr anchor as qr anchor")
    }
    
  }
  
  init(transform: simd_float4x4, _ observation: VNBarcodeObservation) {
    self.observation = observation
    self.label = observation.payloadStringValue!
    
    super.init(transform: transform)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
