//
//  ViewController.swift
//  ARfurniture
//
//  Created by Nikitin Nikita on 08/11/2019.
//  Copyright © 2019 Zappa. All rights reserved.
//
import UIKit
import SceneKit
import ARKit
import VideoToolbox

class ARViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var addNodeButton: UIButton!
    @IBOutlet weak var labelHelp: UILabel!
    
    private var sceneNode = [SceneObject]()
    private var selectNode: SceneObject?
    private var configuration = ARWorldTrackingConfiguration()
    private var index = 0
    private var currentTrackingPosition: CGPoint?
    private var lastARPlaneAnchor: ARPlaneAnchor?
    
    //Mark: flags
    private var isAddModel = true
    private var isSelectNode = false {
        didSet{
            deleteButton.isHidden = !isSelectNode
            addNodeButton.isHidden = isSelectNode
            labelHelp.isHidden = isSelectNode
        }
    }
    private var isMove = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToSceneView()
        setUpSceneView()
        for _ in 0..<10{
            sceneNode.append(SceneObject())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //sceneView.session.pause()
    }
    
    private func setUpSceneView() {
        //configuration.planeDetection = .horizontal
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func addTapGestureToSceneView() {
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
        sceneView.session.pause()
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        sceneNode.removeAll()
        for _ in 0..<10{
            sceneNode.append(SceneObject())
        }
        isAddModel = true
        isSelectNode = false
        isMove = false
    }
    
    @IBAction func touchClose(_ sender: Any) {
        
    }
    
    @IBAction func touchDeleteNode(_ sender: Any) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            if (node.name == selectNode?.node.name){
                node.removeFromParentNode()
            }
        }
        sceneNode.removeAll(where: { $0.node.name == selectNode?.node.name })
        isAddModel = false
        isSelectNode = false
        isMove = false
        labelHelp.isHidden = true
    }
    
    @IBAction func touchAddNode(_ sender: Any) {
        isAddModel = true
        labelHelp.isHidden = false
    }
}

//@objc
extension ARViewController{
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
                        recognizer.setTranslation(.zero, in: sceneView)
                    }
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
            let tapLocation = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.translation
            let position = SCNVector3(translation.x, translation.y, translation.z)
            sceneNode[index] = SceneObject(pos: position, name: "Alfinosa", scene: sceneView, scale: 0.005, nameNode: "\(index)")
            sceneView.scene.rootNode.addChildNode(sceneNode[index].node)
            index += 1
            isAddModel = false
            labelHelp.isHidden = true
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
}

extension ARViewController: ARSCNViewDelegate {
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
            self.labelHelp.isHidden = false
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
