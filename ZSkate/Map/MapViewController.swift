//
//  MapViewController.swift
//  ZSkate
//
//  Created by Alexandre Karst on 12/10/2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!

    let zenlyCoord = CLLocationCoordinate2D(latitude: 48.854091, longitude: 2.373104)
    lazy var roundTrip: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 48.854325, longitude: 2.373343),
        CLLocationCoordinate2D(latitude: 48.854795, longitude: 2.372734),
        CLLocationCoordinate2D(latitude: 48.854339, longitude: 2.371449),
        CLLocationCoordinate2D(latitude: 48.853742, longitude: 2.372649),
        zenlyCoord
    ]
    lazy var roundTripIterator = roundTrip.makeIterator()

    var runningRoundTrip: [CLLocationCoordinate2D] = []

    var zenlySkateAnnotation = MKPointAnnotation()

    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMapView()
        placeZenlySkateAnnotation()
        // The round trip starts at Zenly location
        computeInterpolationAndMove(start: zenlyCoord)
    }

    private func computeInterpolationAndMove(start: CLLocationCoordinate2D) {
        guard let destination = roundTripIterator.next() else {
            return
        }


        naiveLinearInterpolation(start: start, destination: destination, step: (destination.longitude - start.longitude)/100, currentValue: start.longitude)


        startMoving(to: destination)
        print("computed linear coords:")
        print(runningRoundTrip)
    }

    private func startMoving(to destination: CLLocationCoordinate2D) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.09, repeats: true) { timer in
            print("Update loc!")
            guard self.runningRoundTrip.count > 0 else {
                self.timer?.invalidate()
                self.timer = nil
                print("Finished!")
                self.computeInterpolationAndMove(start: destination)
                return
            }

            let coordinate = self.runningRoundTrip.removeFirst()
            self.zenlySkateAnnotation.coordinate = coordinate
        }
    }

    private func naiveLinearInterpolation(start: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, step: Double, currentValue: Double) {
        print("New longitude: \(start.longitude)")
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

    private func initializeMapView() {
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let zenlyRegion = MKCoordinateRegion(center: zenlyCoord, span: span)
        mapView.region = zenlyRegion
    }

    private func placeZenlySkateAnnotation() {
        zenlySkateAnnotation.coordinate = zenlyCoord
        mapView.addAnnotation(zenlySkateAnnotation)
    }
}
