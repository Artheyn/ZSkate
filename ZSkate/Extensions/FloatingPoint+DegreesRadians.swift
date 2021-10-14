//
//  FloatingPoint+DegreesRadians.swift
//  ZSkate
//
//  Created by Alexandre Karst on 15/10/2021.
//

import Foundation

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
