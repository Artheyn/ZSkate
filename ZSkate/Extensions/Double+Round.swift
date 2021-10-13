//
//  Double+Round.swift
//  ZSkate
//
//  Created by Alexandre Karst on 14/10/2021.
//

import Foundation

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
