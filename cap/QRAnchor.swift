//
//  QRAnchor.swift
//  cap
//
//  Created by Andrew Tu on 1/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import Foundation
import ARKit

class QRAnchor : ARAnchor {
  
  var label: String
  
  required init(anchor: ARAnchor) {
    if let tempAnchor = anchor as? QRAnchor {
      self.label = tempAnchor.label
      super.init(anchor: anchor)
    } else {
      fatalError("cannot copy non qr anchor as qr anchor")
    }
    
  }
  
  init(transform: simd_float4x4, labeled label: String) {
    self.label = label
    super.init(transform: transform)
   }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
