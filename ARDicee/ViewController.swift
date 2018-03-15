//
//  ViewController.swift
//  ARDicee
//
//  Created by mahmoud khudairi on 3/15/18.
//  Copyright © 2018 mahmoud khudairi. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        // self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ARWorldTrackingConfiguration.isSupported{
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            // Run the view's session
            sceneView.session.run(configuration)
        }else{
            let alertController = UIAlertController(title: "Device is not supported", message: "Only devices with A9 chip and above can run this app", preferredStyle: .alert)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let touchlocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchlocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first{
                addDice(atLocation: hitResult)
                
            }
        }
    }
    
    func addDice(atLocation location: ARHitTestResult){
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        guard let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) else{return}
        diceNode.position = SCNVector3(x: location.worldTransform.columns.3.x , y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius , z: location.worldTransform.columns.3.z)
        diceArray.append(diceNode)
        sceneView.scene.rootNode.addChildNode(diceNode)
        roll(dice: diceNode)
    }
    
    func roll(dice: SCNNode){
        let randomx = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        let randomz = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomx * 5), y: 0, z: CGFloat(randomz * 5), duration: 0.5))
    }
    
    func rollAll(){
        if !diceArray.isEmpty{
            for dice in diceArray{
                roll(dice: dice)
            }
        }
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty{
            for dice in diceArray{
                dice.removeFromParentNode()
            }
        }
    }
    
    @IBAction func rallAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
    //MARK: - ARSCNVIEWDelegateMethods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else{return}
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode{
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: planeAnchor.center.x,y: 0,z: planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2,1 , 0, 0)
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        return planeNode
    }
}

