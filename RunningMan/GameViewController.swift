//
//  GameViewController.swift
//  RunningMan
//
//  Created by Oliver Dew on 01/06/2016.
//  Copyright (c) 2016 Salt Pig. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
    
    let scene = SCNScene()
    var player: ColladaRig?
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        setupScene()

        // set the scene to the view
        self.gameView!.scene = scene
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.blackColor()
    }
    
    override func mouseDown(theEvent: NSEvent) {
        player!.walk()
    }
    
    override func mouseUp(theEvent: NSEvent) {
        player!.stopWalking()
    }
    
    func setupScene() {
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        //scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 5, y: 5, z: 15)
        let cameraArm = SCNNode()
        cameraArm.addChildNode(cameraNode)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let skyCube = getCubeMap("miramar")
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = NSColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        let floorNode = SCNNode(geometry: SCNFloor())
        
        let mat = SCNMaterial()
        let scale:CGFloat = 4
        let trans = SCNMatrix4Rotate(SCNMatrix4MakeScale(scale, scale, 1),CGFloat(M_PI_2) / 3 ,0, 0, 1)
        
        mat.diffuse.contents = "art.scnassets/floor07.tga"
        mat.diffuse.wrapS = .Repeat
        mat.diffuse.wrapT = .Repeat
        mat.diffuse.contentsTransform = trans
        mat.normal.contents = "art.scnassets/floor07_NRM.jpg"
        mat.normal.wrapS = .Repeat
        mat.normal.wrapT = .Repeat
        mat.normal.contentsTransform = trans
        // try to stop the floor textures trigger nasty moire jaggies at distance
        mat.normal.mipFilter = .Linear
        mat.normal.maxAnisotropy = 0
        mat.normal.intensity = 0.5
        mat.diffuse.mipFilter = .Linear
        mat.diffuse.maxAnisotropy = 0
        // reflectivity
        mat.reflective.contents = skyCube
        mat.fresnelExponent = 8
        floorNode.geometry?.materials = [mat]
        
        scene.rootNode.addChildNode(floorNode)

        let animation = CABasicAnimation(keyPath: "rotation")
        animation.toValue = NSValue(SCNVector4: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(M_PI)*2))
        animation.duration = 28
        animation.repeatCount = MAXFLOAT //repeat forever
        cameraArm.addAnimation(animation, forKey: nil)
        
//        player = ColladaRig(modelNamed: "Cube" , daeNamed: "blobExport")
//        player!.loadAnimation("walk", daeNamed: "blobRun")
        player = ColladaRig(modelNamed: "Dude" , daeNamed: "lopolydudeMirrorRiggedExport")
        player!.loadAnimation("walk", daeNamed: "lopolydudeMirrorRiggedWalk")
        scene.rootNode.addChildNode(player!.node)
        
        let playerMat = SCNMaterial()
        
        playerMat.diffuse.contents = NSColor.darkGrayColor()
        playerMat.reflective.contents = skyCube
        playerMat.fresnelExponent = 2
        playerMat.shininess = 1
        player!.node.geometry?.materials = [playerMat]
        player!.node.addChildNode(cameraArm)
        
        scene.background.contents = skyCube
        scene.fogStartDistance = 20
        scene.fogEndDistance = 60
        scene.fogColor = NSColor(red: 0.64, green: 0.7, blue: 0.78, alpha: 0.8)
    }


}

func getCubeMap(inFolder: String, type: String = "jpg") -> [String] {
    let path = "art.scnassets/\(inFolder)/"
    return [
        "\(path)right.\(type)",
        "\(path)left.\(type)",
        "\(path)up.\(type)",
        "\(path)down.\(type)",
        "\(path)front.\(type)",
        "\(path)back.\(type)",
    ]
    
}

