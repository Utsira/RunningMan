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
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        // create a new scene
        let scene = SCNScene() //SCNScene(named: "art.scnassets/ship.scn")!
        
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
        
        let floor = SCNFloor()
        let floorNode = SCNNode(geometry: floor)
        floor.reflectivity = 0.25
        
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
        mat.normal.mipFilter = .Linear
        mat.normal.maxAnisotropy = 0
        mat.normal.intensity = 0.5
        mat.reflective.contents = skyCube
        mat.fresnelExponent = 8
        mat.diffuse.mipFilter = .Linear
        mat.diffuse.maxAnisotropy = 0
        floorNode.geometry?.materials = [mat]
        
        scene.rootNode.addChildNode(floorNode)
        // retrieve the ship node
//        let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
//        
//        // animate the 3d object
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.toValue = NSValue(SCNVector4: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(M_PI)*2))
        animation.duration = 28
        animation.repeatCount = MAXFLOAT //repeat forever
        cameraArm.addAnimation(animation, forKey: nil)
  //      let dude = ColladaRig(modelNamed: "Cube" , daeNamed: "blobExport" , animImport: .playRepeatedly)
        let dude = ColladaRig(modelNamed: "Dude" , daeNamed: "lopolydudeMirrorRiggedExport" , animImport: .playRepeatedly) // "lopolydudeWithGun",
      //  dude.loadAnimation("rest", daeNamed: "blobExport")
    //    dude.playAnimation("rest")
    //    dude.loadAnimation("walk", daeNamed: "blobRun") 
        dude.loadAnimation("walk", daeNamed: "lopolydudeMirrorRiggedWalk") //

       // let dude = SCNScene(named: "lopolydudeMirrorRiggedExport.dae", inDirectory: "art.scnassets", options: nil)!.rootNode.childNodeWithName("Cube", recursively: false)!
      //  dude.addAccessory("Gun", daeNamed: "lopolydudeGun")
        var min = SCNVector3(0,0,0)
        var max = SCNVector3(0,0,0)
        dude.node.getBoundingBoxMin(&min, max: &max) //SCNVector3(0,0,0) //1.2 4.352
        print(min, max)
        dude.node.position = SCNVector3(0, (max.y - min.y), 0) //
        
        scene.rootNode.addChildNode(dude.node)
        let gun = dude.node.childNodeWithName("Gun", recursively: true)
        print(gun?.eulerAngles)
        gun?.eulerAngles.x = 0
        let dudeMat = SCNMaterial()
        
        dudeMat.diffuse.contents = NSColor.darkGrayColor()
        dudeMat.reflective.contents = skyCube
        dudeMat.fresnelExponent = 2
        dudeMat.shininess = 1
        dude.node.geometry?.materials = [dudeMat]
        dude.node.addChildNode(cameraArm)
        
        scene.background.contents = skyCube
        scene.fogStartDistance = 20
        scene.fogEndDistance = 60
        scene.fogColor = NSColor(red: 0.64, green: 0.7, blue: 0.78, alpha: 0.3)
        self.gameView!.setRig(dude)
      //  print(self.gameView.dude)
        //dude.playAnimation()
        // set the scene to the view
        self.gameView!.scene = scene
        
        // allows the user to manipulate the camera
        //self.gameView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.blackColor()
    }
//    
//    override func mouseDown(theEvent: NSEvent) {
//        /* Called when a mouse click occurs */
//        print("click")
//        // check what nodes are clicked
//        let p = gameView.convertPoint(theEvent.locationInWindow, fromView: nil)
//        let hitResults = gameView.hitTest(p, options: nil)
//        // check that we clicked on at least one object
//        if hitResults.count > 0 {
//            // retrieved the first clicked object
//            let result: AnyObject = hitResults[0]
//            
//            // get its material
//            let material = result.node!.geometry!.firstMaterial!
//            
//            // highlight it
//            SCNTransaction.begin()
//            SCNTransaction.setAnimationDuration(0.5)
//            
//            // on completion - unhighlight
//            SCNTransaction.setCompletionBlock() {
//                SCNTransaction.begin()
//                SCNTransaction.setAnimationDuration(0.5)
//                
//                material.emission.contents = NSColor.blackColor()
//                
//                SCNTransaction.commit()
//            }
//            
//            material.emission.contents = NSColor.redColor()
//            
//            SCNTransaction.commit()
//        }
//        
//        super.mouseDown(theEvent)
//    }

}

func getCubeMap(inFolder: String, type: String? = "jpg", XForward: Bool? = false) -> [String] {
    let path = "art.scnassets/\(inFolder)/"
    switch XForward! {
    case true:
        return [
            "\(path)front.\(type!)",
            "\(path)back.\(type!)",
            "\(path)up.\(type!)",
            "\(path)down.\(type!)",
            "\(path)right.\(type!)",
            "\(path)left.\(type!)"
        ]
    case false:
        return [
            "\(path)right.\(type!)",
            "\(path)left.\(type!)",
            "\(path)up.\(type!)",
            "\(path)down.\(type!)",
            "\(path)front.\(type!)",
            "\(path)back.\(type!)",
        ]
        
    }
}



class ColladaRig {
    let node: SCNNode
    //let armature: SCNNode
    var animations = [String: CAAnimation]() // [String: CAAnimation]
    var accessories = [String: SCNNode]()
    
    enum AnimImport {
        case playOnce, playRepeatedly, doNotPlay, useSceneTime
    }
    
    static func getSceneSource(daeNamed: String, animImport: AnimImport? = nil) -> SCNSceneSource {
        var options:[String: String]?
        
        if let anim = animImport {
            switch anim {
            case .playOnce:
                options = [SCNSceneSourceAnimationImportPolicyKey : SCNSceneSourceAnimationImportPolicyPlay]
            case .playRepeatedly:
                options = [SCNSceneSourceAnimationImportPolicyKey : SCNSceneSourceAnimationImportPolicyPlayRepeatedly]
            case .doNotPlay:
                options = [SCNSceneSourceAnimationImportPolicyKey : SCNSceneSourceAnimationImportPolicyDoNotPlay]
            case .useSceneTime:
                options = [SCNSceneSourceAnimationImportPolicyKey : SCNSceneSourceAnimationImportPolicyPlayUsingSceneTimeBase]
            }
        }
        let collada = NSBundle.mainBundle().URLForResource("art.scnassets/\(daeNamed)", withExtension: "dae")!
        return SCNSceneSource(URL: collada, options: options)!
    }
    
    init(modelNamed: String, daeNamed: String, animImport: AnimImport? = nil){
        
        let sceneSource = ColladaRig.getSceneSource(daeNamed, animImport: animImport)
        node = sceneSource.entryWithIdentifier(modelNamed, withClass: SCNNode.self)!
        let armature = sceneSource.entryWithIdentifier("Armature", withClass: SCNNode.self)!
        
        //In some Blender output DAE, animation is child of armature, in others it has no child. Not sure what causes this. Hence:
        armature.removeAllAnimations()
        
        let animation = sceneSource.entryWithIdentifier("\(daeNamed)-1", withClass: CAAnimation.self)!
        animations["rest"] = animation
        node.addAnimation(animation, forKey: "rest") //or armature?
        node.addChildNode(armature)
    }
    
    func loadAnimation(named: String, daeNamed: String, fade: CGFloat? = 0.3){
       
        let sceneSource = ColladaRig.getSceneSource(daeNamed, animImport: nil)
        let animation = sceneSource.entryWithIdentifier("\(daeNamed)-1", withClass: CAAnimation.self)!
        
        // animation.speed = 1
        animation.fadeInDuration = fade!
        animation.fadeOutDuration = fade!
       // animation.beginTime = CFTimeInterval( fade!)
        animations[named] = animation
    }
   
    func addAccessory(modelNamed: String, daeNamed: String) {
        let sceneSource = ColladaRig.getSceneSource(daeNamed, animImport: nil)
        let accessory = sceneSource.entryWithIdentifier(modelNamed, withClass: SCNNode.self)!
        accessory.skinner?.skeleton = node.skinner?.skeleton
        accessories[modelNamed] = accessory
        node.addChildNode(accessory)
    }
    
    func playAnimation(named: String){ //also works for armature
        node.pauseAnimationForKey("rest")
      //  node.removeAnimationForKey("rest", fadeOutDuration: 0.3)
        if let animation = animations[named] {
            node.addAnimation(animation, forKey: named)
//            for (_, accessory) in accessories {
//                accessory.addAnimation(animation, forKey: named)
//            }
            let run = SCNAction.repeatActionForever( SCNAction.moveByX(0, y: 0, z: 12, duration: 1))
            run.timingMode = .EaseInEaseOut
            node.runAction(run, forKey: named) //12
        }
    }
    
    func stopAnimation(named: String){
        node.resumeAnimationForKey("rest")
        
     //   node.addAnimation(animations["rest"]!, forKey: "rest")
        node.removeAnimationForKey(named, fadeOutDuration: 0.3)
        
        node.removeActionForKey(named)
    }
}
