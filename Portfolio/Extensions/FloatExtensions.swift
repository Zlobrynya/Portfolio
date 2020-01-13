//
//  FloatExtensions.swift
//  HandApp
//
//  Created by Nikitin Nikita on 05/09/2019.
//  Copyright © 2019 Zappa. All rights reserved.
//

import ARKit

extension float4x4 {
    var translation: SIMD3<Float> {
        let translation = self.columns.3
        return SIMD3<Float>(translation.x, translation.y, translation.z)
    }
}
