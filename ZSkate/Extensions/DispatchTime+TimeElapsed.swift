//
//  DispatchTime+TimeElapsed.swift
//  ZSkate
//
//  Created by Alexandre Karst on 14/10/2021.
//

import Foundation

extension DispatchTime {
    func timeElapsedSince(startTime: DispatchTime) -> Double {
        let nanoTime = uptimeNanoseconds - startTime.uptimeNanoseconds
        return Double(nanoTime) / 1_000_000_000
    }
}
