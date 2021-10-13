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

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMapView()
    }

    func initializeMapView() {
        mapView.delegate = self
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let zenlyRegion = MKCoordinateRegion(center: zenlyCoord, span: span)
        mapView.region = zenlyRegion
    }
}

extension MapViewController: MKMapViewDelegate {
}
