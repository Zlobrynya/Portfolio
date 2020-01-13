//
//  SceneObject.swift
//  mimiapp
//
//  Created by Nikitin Nikita on 18/06/2019.
//  Copyright © 2019 Zappa. All rights reserved.
//

import UIKit
import ARKit

class SceneObject {
    private var locScale = 0.01
    private var animating: Bool = false
    private var sceneView: ARSCNView?
    
    private var dX = 0.01
    private var dZ = 0.01
    private var yBeforAnimation: Float = 0
    
    var lastPosition = SCNVector3(0,0,0)
    var isSet = false
    var node = SCNNode()

    init(){}
    
    init(pos: SCNVector3, name: String, scene: ARSCNView, scale: Double, nameNode: String) {
        locScale = scale
        addNode(pos: pos, name: name)
        node.name = nameNode
        sceneView = scene
    }
    
    private func addNode(pos: SCNVector3, name: String){
        guard let scene = SCNScene(named: "art.scnassets/\(name).scn") else { fatalError() }
        node = scene.rootNode
        node.position = pos
        node.categoryBitMask = 0b0010
        node.scale = SCNVector3(locScale, locScale, locScale)
        print("addNode \(node.categoryBitMask)")
        //addChildNode(node)
        isSet = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeSize(by: Double){
        for node in node.childNodes{
            node.scale = SCNVector3(locScale * by, locScale * by, locScale * by)
        }
    }
    
    func rotateObject(rotation: CGFloat){
        node.eulerAngles.y += -Float(rotation)
    }
    
    func setPosition(_ newPosition: SIMD3<Float>, relativeTo cameraTransform: matrix_float4x4, smoothMovement: Bool = false) {
        let cameraWorldPosition = cameraTransform.translation
        var positionOffsetFromCamera = newPosition - cameraWorldPosition
        
        if simd_length(positionOffsetFromCamera) > 10 {
            positionOffsetFromCamera = simd_normalize(positionOffsetFromCamera)
            positionOffsetFromCamera *= 10
        }
        
        node.simdPosition = cameraWorldPosition + positionOffsetFromCamera
        yBeforAnimation = node.position.y
    }
    
    private func animate(targetPos: SCNVector3){
        let move = SCNAction.move(to: targetPos, duration: 0.5)
        let moveSequence = SCNAction.sequence([move])
        node.runAction(moveSequence)
    }
    
    func animateSelectStart(){
        yBeforAnimation = node.position.y

        let moveUp = SCNAction.moveBy(x: 0, y: 0.05, z: 0, duration: 1)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = SCNAction.moveBy(x: 0, y: -0.05, z: 0, duration: 1)
        moveDown.timingMode = .easeInEaseOut
        let moveSequence = SCNAction.sequence([moveUp, moveDown])
        let moveLoop = SCNAction.repeatForever(moveSequence)
        node.runAction(moveLoop, forKey: "select")
    }
    
    func animateSelectStop(){
        node.removeAction(forKey: "select")
        node.position.y = yBeforAnimation
    }
}
