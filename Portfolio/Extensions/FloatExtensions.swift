//
//  FloatExtensions.swift
//  HandApp
//
//  Created by Nikitin Nikita on 05/09/2019.
//  Copyright © 2019 Zappa. All rights reserved.
//

import ARKit

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
