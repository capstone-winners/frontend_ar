//
//  ViewController.swift
//  cap
//
//  Created by Andrew Tu on 1/16/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewControllerNoAR: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    let sceneView: UIView = UIView()
    
    let remoteViewController = RemoteViewController()
    let debugView: DebugView = DebugView()
    
    //#warning("replace this with the real version")
    //var iotDecoder : IotDataManager = DummyIotDataManager()
    let iotDecoder = IotDataManager()
    
    var shouldProcessFramesForQr : Bool = true
    var isRemoteViewActive : Bool = false
    
    override func loadView() {
        super.loadView()
                
        SetupNoArView()
        SetupDebugView()
        
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
        
        //addController(remoteViewController)
        //configureRemoteView()
    }
    
    @objc func tapGestureMakeFullScreen(gesture: UITapGestureRecognizer) {
        self.launchRemoteView(anchor: nil)
    }
    
    func configureRemoteView() {
        NSLayoutConstraint.activate([
            remoteViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            remoteViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            remoteViewController.view.heightAnchor.constraint(equalToConstant: 60),
            remoteViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        ])
    }
    
    func SetupNoArView() {
        view.addSubview(sceneView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureMakeFullScreen(gesture:)))
        tapGesture.numberOfTapsRequired = 3
        
        sceneView.addGestureRecognizer(tapGesture)
        
        sceneView.backgroundColor = .purple
        
        sceneView.isUserInteractionEnabled = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        sceneView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        sceneView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    func SetupDebugView() {
        view.addSubview(debugView)
        debugView.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            debugView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            debugView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            debugView.heightAnchor.constraint(equalToConstant: 100),
            debugView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }
    
    func launchRemoteView(anchor: QRAnchor?){
        remoteViewController.updateView(state: iotDecoder.decode(anchor: anchor))
        remoteViewController.presentationController?.delegate = self
        shouldProcessFramesForQr = false
        
        if !isRemoteViewActive {
            isRemoteViewActive = true
            self.present(remoteViewController, animated: true, completion: nil)
        } else {
            print("Remote view is being presented already!")
        }
        
    }
    
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController)
    {
        // Only called when the sheet is dismissed by DRAGGING.
        // You'll need something extra if you call .dismiss() on the child.
        // (I found that overriding dismiss in the child and calling
        // presentationController.delegate?.presentationControllerDidDismiss
        // works well).
        shouldProcessFramesForQr = true
        isRemoteViewActive = false
    }
    
    
}

// MARK: - ARSessionDelegate
extension ViewControllerNoAR : ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}



