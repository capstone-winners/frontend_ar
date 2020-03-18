//
//  LifiDetector.swift
//  cap
//
//  Created by Andrew Tu on 3/16/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import Vision
import ARKit

class LifiDetector {
  
  var wrapper: OpenCVWrapper = OpenCVWrapper()
  weak var parentView: ViewController!
  
  func startLifiDetection(parent: ViewController) {
    print("starting Lifi detection")
    
    // View
    self.parentView = parent
  }
  
  func clear() {
  }
  
  func processFrame(_ frame: ARFrame) {
//    DispatchQueue.global(qos: .userInitiated).async {
//    }
    wrapper.detect(UIImage(pixelBuffer: frame.capturedImage)!)
  }
  
  func requestHandler(request: VNRequest, error: Error?) {
  }
}
