//
//  LifiDetector.swift
//  cap
//
//  Created by Andrew Tu on 3/16/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import Vision
import ARKit
import CoreImage

class LifiDetector {
  
  var wrapper: OpenCVWrapper = OpenCVWrapper()
  var imageView: UIImageView!
  weak var parentView: ViewControllerAR!
  var serialQueue: DispatchQueue
  var context : CIContext
  var radius : Double = 11
  
  //var scaleFilter : CIFilter!
  //let blurFilter : CIFilter!
  
  init() {
    self.context = CIContext(mtlDevice: MTLCreateSystemDefaultDevice()!)
    self.serialQueue = DispatchQueue(label: "mySerialQueue")
    self.wrapper.frameCompleteCallback = self.handleFrameComplete
  }
  
  func startLifiDetection(parent: ViewControllerAR) {
    print("starting Lifi detection")
    
    // View
    self.parentView = parent
  }
  
  func clear() {
  }
  
  func processFrame(_ frame: ARFrame) {
    let scaleFactor = 8.0
    var image : UIImage!
    self.radius = 1
    
    serialQueue.async {
      guard let cgimg = self.PreProcessFrame(frame, scaleFactor: scaleFactor) else {
        print("Error in pre-processing!")
        return
      }
      image = self.wrapper.detect(UIImage(cgImage: cgimg))
      
      DispatchQueue.main.async {
        self.imageView.image = image
      }
    }
  }
  
  func PreProcessFrame(_ frame: ARFrame, scaleFactor: Double) -> CGImage? {
    // Set some stuff up
    let imageWidth = CVPixelBufferGetWidth(frame.capturedImage)
    let imageHeight = CVPixelBufferGetWidth(frame.capturedImage)
    let aspectRatio = Double(imageWidth) / Double(imageHeight)
    
    // Scale and blur.
    
    var ciimage = CIImage(cvPixelBuffer: frame.capturedImage)
    ciimage = self.scaleFilter(ciimage, aspectRatio:aspectRatio, scale:1.0/scaleFactor)
    if(self.radius != 1) {
      ciimage = self.blurFilter(ciimage, radius: self.radius)
    }
    guard let cgimg = self.context.createCGImage(ciimage, from: ciimage.extent) else {
      print("Couldn't create cgimage");
      return nil;
    }
    
    return cgimg
  }
  
  func scaleFilter(_ input:CIImage, aspectRatio : Double, scale : Double) -> CIImage
  {
    let scaleFilter = CIFilter(name:"CILanczosScaleTransform")!
    scaleFilter.setValue(input, forKey: kCIInputImageKey)
    scaleFilter.setValue(scale, forKey: kCIInputScaleKey)
    scaleFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
    return scaleFilter.outputImage!
  }
  
  func blurFilter(_ input:CIImage, radius : Double) -> CIImage {
    let blurfilter = CIFilter(name: "CIGaussianBlur")!
    blurfilter.setValue(input, forKey: kCIInputImageKey)
    blurfilter.setValue(radius, forKey: kCIInputRadiusKey)
    return blurfilter.outputImage!
  }
  
  func requestHandler(request: VNRequest, error: Error?) {
  }
  
  func handleFrameComplete(output: NSMutableArray) {
    print("[LifiDetector - SWIFT]: Handler called!")
    print(output)
    if(output == [0, 1, 0, 0, 0, 1, 0, 1]) {
      launchLightView()
    } else {
      print("\tIncorrect sequence!");
    }
  }
  
  func launchLightView() {
    DispatchQueue.main.async {
      print("\tLaunching Light view");
      print(dummyLightData().toJSONString())
      self.parentView.launchPreviewView(jsonString: dummyLightData().toJSONString())
    }
  }
}
