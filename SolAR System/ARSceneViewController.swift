//
//  ARSceneViewController.swift
//  SolAR System
//
//  Created by Andika on 29/06/19.
//  Copyright © 2019 Andika. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import AVFoundation

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

class ARSceneViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // -: REQUIRED :-
    var planetName: String?
    
    var player: AVAudioPlayer?
    var planet: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setupScene()
        self.setupAudio()
    }
    
    func setupScene() {
        let scene = SCNScene()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinched(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        
        panGesture.delegate = self as? UIGestureRecognizerDelegate
        
        sceneView.delegate = self
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.addGestureRecognizer(pinchGesture)
        sceneView.addGestureRecognizer(panGesture)
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        let sphere = SCNSphere(radius: 0.1)
        let material = SCNMaterial()
        
        if planetName! == "earth" {
            material.diffuse.contents = UIImage(named: planetName!+"-diffuse-ar")
            material.emission.contents = UIImage(named: planetName!+"-emission-ar")
            material.specular.contents = UIImage(named: planetName!+"-specular-ar")
        } else {
            material.diffuse.contents = UIImage(named: planetName!+"-diffuse-ar")
        }
        
        sphere.segmentCount = 50
        sphere.materials = [material]
        planet = SCNNode(geometry: sphere)
        planet.position = SCNVector3(0, 0, -0.5)
        
        let spotLight = SCNLight()
        spotLight.type = .spot
        spotLight.spotInnerAngle = 20
        spotLight.spotOuterAngle = 75
        spotLight.intensity = 750
        
        scene.rootNode.addChildNode(planet)
        scene.rootNode.light = spotLight
        
        var action: SCNAction
        
        if planetName == "venus" {
            action = SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 5))
        } else {
            action = SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, -1, 0), duration: 5))
        }
        
        planet.runAction(action)
        
        sceneView.scene = scene
    }
    func setupAudio() {
        guard let url = Bundle.main.url(forResource: planetName!, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc
    func tapped(_ gesture: UIPanGestureRecognizer) {
        guard let _ = planet else { return }
        
        let tapLocation = gesture.location(in: sceneView)
        let results = sceneView.hitTest(tapLocation, types: .featurePoint)
        
        if let result = results.first {
            let translation = result.worldTransform.translation
            planet.position = SCNVector3Make(translation.x, translation.y, translation.z)
            sceneView.scene.rootNode.addChildNode(planet)
        }
    }
    
    @objc
    func pinched(_ gesture: UIPinchGestureRecognizer) {
        guard let _ = planet else { return }
        var originalScale = planet?.scale
        
        switch gesture.state {
        case .began:
            originalScale = planet?.scale
            gesture.scale = CGFloat((planet?.scale.x)!)
        case .changed:
            guard var newScale = originalScale else { return }
            if gesture.scale < 0.5 {
                newScale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
            } else if gesture.scale > 2{
                newScale = SCNVector3(2, 2, 2)
            } else {
                newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
            }
            planet?.scale = newScale
        case .ended:
            guard var newScale = originalScale else { return }
            if gesture.scale < 0.5 {
                newScale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
            } else if gesture.scale > 2 {
                newScale = SCNVector3(2, 2, 2)
            } else {
                newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
            }
            planet?.scale = newScale
            gesture.scale = CGFloat((planet?.scale.x)!)
        default:
            gesture.scale = 1.0
            originalScale = nil
        }
    }
    
    @objc
    func panned(_ gesture: UIPanGestureRecognizer) {
        var currentAngleY: Float = 0.0
        
        guard let _ = planet else { return }
        let translation = gesture.translation(in: gesture.view)
        var newAngleY = (Float)(translation.x)*(Float)(Double.pi)/180.0
        
        newAngleY += currentAngleY
        planet?.eulerAngles.y = newAngleY
        
        if gesture.state == .ended{
            currentAngleY = newAngleY
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
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
