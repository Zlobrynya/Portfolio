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

class ARViewController: ParentArVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        planeDetection = .horizontal
        setUpSceneView()
    }
}
