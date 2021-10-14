//
//  CLLocationCoordinate2D+Heading.swift
//  ZSkate
//
//  Created by Alexandre Karst on 15/10/2021.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {
    func heading(to: CLLocationCoordinate2D) -> Double {
        let startLatitude = self.latitude.degreesToRadians
        let startLongitude = self.longitude.degreesToRadians

        let destinationLatitude = to.latitude.degreesToRadians
        let destinationLongitude = to.longitude.degreesToRadians

        let xDistance = destinationLongitude - startLongitude
        let y = sin(xDistance) * cos(destinationLatitude)
        let x = cos(startLatitude) * sin(destinationLatitude) - sin(startLatitude) * cos(destinationLatitude) * cos(xDistance)

        let headingDegrees = atan2(y, x).radiansToDegrees
        if headingDegrees >= 0 {
            return headingDegrees
        } else {
            return headingDegrees + 360
        }
    }
}
