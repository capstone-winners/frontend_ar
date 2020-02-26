//
//  ViewController.swift
//  cap
//
//  Created by Andrew Tu on 1/16/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit

class ViewControllerNoAR: ViewController {
  override func setupSceneView() {
    sceneView = UIView()
    view.addSubview(sceneView)
    
    sceneView.backgroundColor = .purple
    
    sceneView.isUserInteractionEnabled = true
    sceneView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      sceneView.topAnchor.constraint(equalTo: view.topAnchor),
      sceneView.leftAnchor.constraint(equalTo: view.leftAnchor),
      sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      sceneView.rightAnchor.constraint(equalTo: view.rightAnchor)])
  }
  
}
