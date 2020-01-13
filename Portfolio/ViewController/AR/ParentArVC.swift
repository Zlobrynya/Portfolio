//
//  ParentArVC.swift
//  Portfolio
//
//  Created by Nikitin Nikita on 13/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import UIKit
import ARKit

class ParentArVC: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var deleteButton: UIButton?
    @IBOutlet weak var addNodeButton: UIButton?
    @IBOutlet weak var labelHelp: UILabel?
    
    var planeDetection: ARWorldTrackingConfiguration.PlaneDetection = .vertical
    var nameNode = "art.scnassets/Alfinosa.scn"
    var countMaxModel = 10
    var scaleNode = 0.005
    var selectNode: SceneObject?
    var sceneNode = [SceneObject]()
    
    private var configuration = ARWorldTrackingConfiguration()
    private var index = 0
    private var currentTrackingPosition: CGPoint?
    private var lastARPlaneAnchor: ARPlaneAnchor?
    
    //Mark: flags
    private var isAddModel = true
    private var isMove = false
    private var isRemove = false

    var isSelectNode = false {
        didSet{
            deleteButton?.isHidden = !isSelectNode
            addNodeButton?.isHidden = isSelectNode
            labelHelp?.isHidden = isSelectNode
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //sceneView.session.pause()
    }
    
    func setUpSceneView() {
        //configuration.planeDetection = .horizontal
        configuration.planeDetection = planeDetection
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        for _ in 0..<countMaxModel{
            sceneNode.append(SceneObject())
        }
    }
    
    private func addTapGestureToSceneView() {
        //Set model
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARViewController.tapNode(_:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        //Change position
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panPiece(_:)))
        sceneView.addGestureRecognizer(panGestureRecognizer)
        //Rotate
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateNode(_:)))
        sceneView.addGestureRecognizer(rotationGestureRecognizer)
        //Size
        //let sizeGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(sizeNode(_:)))
        //sceneView.addGestureRecognizer(sizeGestureRecognizer)
    }
    
    
    @IBAction func touchRefresh(_ sender: UIButton) {       
        for node in sceneNode{
            node.node.removeFromParentNode()
        }
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        isAddModel = true
        isSelectNode = false
        isMove = false
        index = 0
    }
    
    @IBAction func touchClose(_ sender: Any) {}
    
    @IBAction func touchDeleteNode(_ sender: Any) {
        isRemove = true
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            if (node.name == selectNode?.node.name){
                node.removeFromParentNode()
            }
        }
        sceneNode.removeAll(where: { $0.node.name == selectNode?.node.name })
        sceneNode.append(SceneObject())
        isAddModel = false
        isSelectNode = false
        isMove = false
        labelHelp?.isHidden = true
        index -= 1
    }
    
    @IBAction func touchAddNode(_ sender: Any) {
        isAddModel = true
        labelHelp?.isHidden = false
    }
}

//@objc
extension ParentArVC{
    @objc func panPiece(_ recognizer : UIPanGestureRecognizer) {
        guard let recognizerView = recognizer.view as? ARSCNView else { return }
        if isSelectNode,
            let selectNode = selectNode{
            // Runs once when long press is detected.
            switch recognizer.state {
            case .possible:
                break
            case .began:
                //Todo: hit test to selectNode
                let touch = recognizer.location(in: recognizerView)
                let hitTestOptions: [SCNHitTestOption: Any] = [.rootNode: selectNode.node]
                let hitTestResult = self.sceneView.hitTest(touch, options: hitTestOptions)
                isMove = hitTestResult.first?.node != nil
            case .changed:
                if isMove {
                    let translation = recognizer.translation(in: sceneView)
                    let currentPosition = currentTrackingPosition ?? CGPoint(sceneView.projectPoint(selectNode.node.position))
                    currentTrackingPosition = CGPoint(x: currentPosition.x + translation.x, y: currentPosition.y + translation.y)
                    if planeDetection == .horizontal{
                        moveHorizontalNode(selectNode: selectNode)
                    }else{
                        moveVerticalNode(selectNode: selectNode)
                    }
                    recognizer.setTranslation(.zero, in: sceneView)
                }
            case .ended, .cancelled, .failed:
                currentTrackingPosition = nil
                isMove = false
            @unknown default:
                break
            }
        }
    }
    
    @objc func rotateNode(_ recognizer : UIRotationGestureRecognizer){
        if isSelectNode{
            guard (recognizer.view as? ARSCNView) != nil else { return }
            if let selectNode = selectNode{
                switch recognizer.state {
                case .changed:
                    selectNode.rotateObject(rotation: recognizer.rotation)
                    recognizer.rotation = 0
                    break
                case .ended, .possible, .cancelled,.failed,.began:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    @objc func sizeNode(_ recognizer: UIPinchGestureRecognizer){
        if isSelectNode{
            guard (recognizer.view as? ARSCNView) != nil else { return }
            let pinchScale: CGFloat = recognizer.scale
            //print("pinchScale \(pinchScale)")
            if let selectNode = selectNode{
                switch recognizer.state {
                case .changed:
                    selectNode.changeSize(by: Double(pinchScale))
                    recognizer.scale = 0
                    break
                case .ended, .possible, .cancelled,.failed,.began:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    @objc func tapNode(_ recognizer: UITapGestureRecognizer){
        if isAddModel{
            if index < countMaxModel{
                let tapLocation = recognizer.location(in: sceneView)
                let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
                guard let hitTestResult = hitTestResults.first else { return }
                let translation = hitTestResult.worldTransform.translation
                let position = SCNVector3(translation.x, translation.y, translation.z)
                sceneNode[index] = SceneObject(pos: position, name: nameNode, scene: sceneView, scale: scaleNode, nameNode: "\(index)")
                if planeDetection == .vertical,
                    let anchor = hitTestResult.anchor as? ARPlaneAnchor,
                    let anchoredNode = sceneView.node(for: anchor){
                    sceneNode[index].node.eulerAngles = anchoredNode.eulerAngles
                }
                sceneView.scene.rootNode.addChildNode(sceneNode[index].node)
                index += 1
                isAddModel = false
                labelHelp?.isHidden = true
            }
        }else if !isSelectNode{
            guard let recognizerView = recognizer.view as? ARSCNView else { return }
            let touch = recognizer.location(in: recognizerView)
            if let findedNode = findNode(touch){
                isSelectNode = true
                selectNode = findedNode
                selectNode?.animateSelectStart()
            }
        }else{
            selectNode?.animateSelectStop()
            selectNode = nil
            isSelectNode = false
        }
    }
    
    private func findNode(_ touch: CGPoint) -> SceneObject?{
        for sceneNode in sceneNode{
            let hitTestOptions: [SCNHitTestOption: Any] = [.rootNode: sceneNode.node]
            let hitTestResult = self.sceneView.hitTest(touch, options: hitTestOptions)
            if (hitTestResult.first?.node) != nil {
                return sceneNode
            }
        }
        return nil
    }
    
    private func moveHorizontalNode(selectNode: SceneObject){
        if let currentTrackingPosition = currentTrackingPosition,
            let cameraTransform = sceneView.session.currentFrame?.camera.transform{
            let planeHitTestResults = self.sceneView.hitTest(currentTrackingPosition, types: .existingPlaneUsingExtent)
            //Moves along a plane that has already been defined
            if let result = planeHitTestResults.first {
                lastARPlaneAnchor = result.anchor as? ARPlaneAnchor
                let planeHitTestPosition = result.worldTransform.translation
                selectNode.setPosition(planeHitTestPosition, relativeTo: cameraTransform)
                //Moves along a last plane that has already been defined
            }else if let planeAnchor = lastARPlaneAnchor,
                let nearScenePoint = sceneView.unprojectPoint(currentTrackingPosition, ontoPlane: planeAnchor.transform){
                selectNode.setPosition(nearScenePoint, relativeTo: cameraTransform)
                //Moves along a very first plane that has already been defined
            }else if let planeAnchor = sceneView.session.currentFrame?.anchors.first as? ARPlaneAnchor,
                let nearScenePoint = sceneView.unprojectPoint(currentTrackingPosition, ontoPlane: planeAnchor.transform){
                selectNode.setPosition(nearScenePoint, relativeTo: cameraTransform)
            }
        }
    }
    
    private func moveVerticalNode(selectNode: SceneObject){
        if let currentTrackingPosition = currentTrackingPosition,
            let cameraTransform = sceneView.session.currentFrame?.camera.transform{
            let planeHitTestResults = self.sceneView.hitTest(currentTrackingPosition, types: .existingPlaneUsingExtent)
            //Moves along a plane that has already been defined
            if let result = planeHitTestResults.first,
                let anchor = result.anchor as? ARPlaneAnchor{
                lastARPlaneAnchor = anchor
                if let anchoredNode = sceneView.node(for: anchor){
                    let planeHitTestPosition = result.worldTransform.translation
                    selectNode.setPosition(planeHitTestPosition, relativeTo: cameraTransform, eulerAngles: anchoredNode.eulerAngles)
                }
                //Moves along a last plane that has already been defined
            }else if let planeAnchor = lastARPlaneAnchor,
                let nearScenePoint = sceneView.unprojectPoint(currentTrackingPosition, ontoPlane: planeAnchor.transform){
                if let anchoredNode = sceneView.node(for: planeAnchor){
                    selectNode.setPosition(nearScenePoint, relativeTo: cameraTransform, eulerAngles: anchoredNode.eulerAngles)
                }
                //Moves along a very first plane that has already been defined
            }else if let planeAnchor = sceneView.session.currentFrame?.anchors.first as? ARPlaneAnchor,
                let nearScenePoint = sceneView.unprojectPoint(currentTrackingPosition, ontoPlane: planeAnchor.transform){
                if let anchoredNode = sceneView.node(for: planeAnchor){
                    selectNode.setPosition(nearScenePoint, relativeTo: cameraTransform, eulerAngles: anchoredNode.eulerAngles)
                }
                //selectNode.setPosition(nearScenePoint, relativeTo: cameraTransform)
            }
        }
    }
    
}

extension ParentArVC: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        // Converts the CMSampleBuffer to a CVPixelBuffer.
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        plane.materials.first?.diffuse.contents = #colorLiteral(red: 0.2619169652, green: 0.6674157977, blue: 1, alpha: 0.5)
        
        let planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        DispatchQueue.main.async {
            self.labelHelp?.isHidden = false
        }
        
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
}

