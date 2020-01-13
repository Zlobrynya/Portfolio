//
//  CGPoint.swift
//  ARfurniture
//
//  Created by Nikitin Nikita on 26/11/2019.
//  Copyright © 2019 Zappa. All rights reserved.
//

import ARKit

extension CGPoint {
    /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
    init(_ vector: SCNVector3) {
        self.init()
        x = CGFloat(vector.x)
        y = CGFloat(vector.y)
    }
}
