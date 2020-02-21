//
//  Throttler.swift
//  cap
//
//  Created by Andrew Tu on 2/21/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit

public class Throttler {
  
  private let queue: DispatchQueue = DispatchQueue.global(qos: .background)
  
  private var job: DispatchWorkItem = DispatchWorkItem(block: {})
  private var previousRun: Date = Date.distantPast
  private var maxIntervalMs: Int
  
  init(ms: Int) {
    self.maxIntervalMs = ms
  }
  
  
  func throttle(block: @escaping () -> ()) {
    job.cancel()
    job = DispatchWorkItem(){ [weak self] in
      self?.previousRun = Date()
      block()
    }
    let delay = Date.ms(from: previousRun) > maxIntervalMs ? 0 : maxIntervalMs
    queue.asyncAfter(deadline: .now() + Double(delay/1000), execute: job)
  }
}

private extension Date {
  static func ms(from referenceData: Date) -> Int {
    return Int((Date().timeIntervalSince(referenceData) * 1000).rounded())
  }
}
