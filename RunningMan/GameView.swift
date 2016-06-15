//
//  GameView.swift
//  RunningMan
//
//  Created by Oliver Dew on 01/06/2016.
//  Copyright (c) 2016 Salt Pig. All rights reserved.
//

import SceneKit

class GameView: SCNView {
    var rig: ColladaRig?
    
    func setRig(rig: ColladaRig){
        self.rig = rig
        Swift.print("rig set", self.rig) //rig set Optional(RunningMan.ColladaRig)
      //  self.rig!.playAnimation()
    }
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        self.rig!.playAnimation("walk") 
        // check what nodes are clicked
        let p = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        let hitResults = self.hitTest(p, options: nil)
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject = hitResults[0]
            
            // get its material
            let material = result.node!.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.5)
            
            // on completion - unhighlight
            SCNTransaction.setCompletionBlock() {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                material.emission.contents = NSColor.blackColor()
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = NSColor.redColor()
            
            SCNTransaction.commit()
        }
        
        super.mouseDown(theEvent)
    }
    
    override func mouseUp(theEvent: NSEvent) {
        self.rig!.stopAnimation("walk")
        super.mouseUp(theEvent)
    }

}
