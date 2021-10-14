//
//  MapViewModel.swift
//  ZSkate
//
//  Created by Alexandre Karst on 14/10/2021.
//

import Foundation
import MapKit

// MARK: - Constant(s)
enum NaiveLinearInterpolationAttributes {
    static let timeInterval = 0.07
}

enum LinearInterpolationAttributes {
    static let timeInterval = 0.009
    static let skateSpeed = 5.0 // In m/s, it's an electric one! 🛹⚡️
}

// MARK: - MapViewModel
protocol MapViewModelDelegate: AnyObject {
    func viewModelDidCompute(zenlySkateCoordinate: CLLocationCoordinate2D)
}

class MapViewModel {
    weak var delegate: MapViewModelDelegate?

    // Start from Zenly, pick-up an ice-cream 🍦 and back to Zenly!
    lazy var roundTrip: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 48.854325, longitude: 2.373343),
        CLLocationCoordinate2D(latitude: 48.854795, longitude: 2.372734),
        CLLocationCoordinate2D(latitude: 48.854339, longitude: 2.371449),
        CLLocationCoordinate2D(latitude: 48.853742, longitude: 2.372649),
        MapAttributes.zenlyCoord
    ]

    lazy var roundTripIterator = roundTrip.makeIterator()

    var runningRoundTrip: [CLLocationCoordinate2D] = []

    var timer: Timer?
}

// MARK: - "Naive" linear interpolation algorithm
/*
     roundTrip
    ┌──────────┬─────────┬─────────┬──────────┐
    │          │         │         │          │
    │          │         │         │          │
    │  LOC1    │  LOC2   │  LOC3   │   ...    │
    │          │         │         │          │
    │   │      │    │    │         │          │
    └───┼──────┴────┼────┴─────────┴──────────┘
      │           │
      │start      │ destination
      ▼           ▼

         Compute n locations (interpolate)

    runningRoundTrip
    ┌─────────────┬─────────────┬─────────┬─────────────┐
    │             │             │         │             │
    │  INT_LOC1   │  INT_LOC2   │  ...    │   INT_LOCN  │
    │             │             │         │             │
    │             │             │         │             │
    └─────────────┴─────────────┴─────────┴─────────────┘

    Each tick:  pick a location and move the annotation

*/
extension MapViewModel {
    func computeNaiveLinearInterpolationAndMove(start: CLLocationCoordinate2D) {
        guard let destination = roundTripIterator.next() else {
            // Trip finished! Reset the iterator.
            roundTripIterator = roundTrip.makeIterator()
            return
        }

        naiveLinearInterpolation(start: start, destination: destination, step: (destination.longitude - start.longitude)/100, currentValue: start.longitude)

        timer = Timer.scheduledTimer(withTimeInterval: NaiveLinearInterpolationAttributes.timeInterval, repeats: true) { timer in
            guard self.runningRoundTrip.count > 0 else {
                self.timer?.invalidate()
                self.timer = nil
                // Interpolate and move to next point starting from the current destination to the next one.
                self.computeNaiveLinearInterpolationAndMove(start: destination)
                return
            }

            let nextCoordinate = self.runningRoundTrip.removeFirst()
            self.delegate?.viewModelDidCompute(zenlySkateCoordinate: nextCoordinate)
        }
    }

    private func naiveLinearInterpolation(start: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, step: Double, currentValue: Double) {
        // Use round to avoid "infinite move" effect
        guard abs(start.longitude.round(to: 6) - destination.longitude) > 0 else {
            return
        }

        let newValue = currentValue + step
        let xDistance = destination.longitude - start.longitude
        let yDistance = destination.latitude - start.latitude
        let computedY = start.latitude + (newValue - start.longitude)*(yDistance/xDistance)

        let computedCoord = CLLocationCoordinate2D(latitude: computedY, longitude: newValue)

        runningRoundTrip.append(computedCoord)

        naiveLinearInterpolation(start: computedCoord, destination: destination, step: step, currentValue: newValue)
    }
}

// MARK: - "Standard" linear interpolation algorithm
// Compute the current position according to the time elapsed since the beginning and the computed destination time
extension MapViewModel {
    func computeLinearInterpolationAndMove(start: CLLocationCoordinate2D) {
        guard let destination = roundTripIterator.next() else {
            // Trip finished! Reset the iterator.
            roundTripIterator = roundTrip.makeIterator()
            return
        }

        let startTime = DispatchTime.now()

        let distance = CLLocation(latitude: start.latitude, longitude: start.longitude).distance(from: CLLocation(latitude: destination.latitude, longitude: destination.longitude))

        let endTime = startTime + distance/LinearInterpolationAttributes.skateSpeed

        timer = Timer.scheduledTimer(withTimeInterval: LinearInterpolationAttributes.timeInterval, repeats: true) { timer in
            // Until we reach our destination (checking the time elapsed)
            guard DispatchTime.now().timeElapsedSince(startTime: startTime) < endTime.timeElapsedSince(startTime: startTime) else {
                self.timer?.invalidate()
                self.timer = nil
                self.computeLinearInterpolationAndMove(start: destination)
                return
            }

            self.linearInterpolation(start: start, destination: destination, startTime: startTime, endTime: endTime)
        }
    }

    private func linearInterpolation(start: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, startTime: DispatchTime, endTime: DispatchTime) {
        let xDistance = destination.longitude - start.longitude
        let yDistance = destination.latitude - start.latitude

        let elapsedTime = DispatchTime.now().timeElapsedSince(startTime: startTime)
        let destinationTime = endTime.timeElapsedSince(startTime: startTime)
        let dt = elapsedTime / destinationTime

        let computedX = start.longitude + dt * xDistance
        let computedY = start.latitude + dt * yDistance

        let computedCoord = CLLocationCoordinate2D(latitude: computedY, longitude: computedX)
        self.delegate?.viewModelDidCompute(zenlySkateCoordinate: computedCoord)
    }
}
