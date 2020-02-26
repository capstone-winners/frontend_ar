//
//  PreviewViewController.swift
//  cap
//
//  Created by Andrew Tu on 2/26/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
  
  // MARK: - View controller code
  override func loadView() {
    view = PreviewView()                                           // Initialize view.
    view.translatesAutoresizingMaskIntoConstraints = false        // Necessary for auto-layout.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
  }
  
  
}
