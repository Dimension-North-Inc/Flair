//
//  MeasurementUnits.swift
//  Flair
//
//  Created by Mark Onyschuk on 02/17/24.
//  Copyright © 2024 Dimension North Inc. All rights reserved.
//

import Foundation

extension UnitLength {
    // Define typographic points, where 1 point = 1/72 of an inch.
    // Since 1 inch = 0.0254 meters, 1 point = 0.0254 / 72 meters.
    public static var points: UnitLength {
        return UnitLength(
            symbol: "pt",
            converter: UnitConverterLinear(
                coefficient: 0.0254 / 72.0
            )
        )
    }
}

