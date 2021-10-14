//
//  MapViewController.swift
//  ZSkate
//
//  Created by Alexandre Karst on 12/10/2021.
//

import UIKit
import MapKit

// MARK: - Constant(s)
enum MapAttributes {
    static let spanDelta = 0.002
    static let zenlyCoord = CLLocationCoordinate2D(latitude: 48.854091, longitude: 2.373104)
}

// MARK: - MapViewController
class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!

    let viewModel = MapViewModel()

    var zenlySkateAnnotation = MKPointAnnotation()

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMapView()
        placeZenlySkateAnnotation()

        viewModel.delegate = self
        // The round trip starts at Zenly location
//        viewModel.computeNaiveLinearInterpolationAndMove(start: zenlyCoord)
        viewModel.computeLinearInterpolationAndMove(start: MapAttributes.zenlyCoord)
    }

    // MARK: - Map initialization
    private func initializeMapView() {
        let span = MKCoordinateSpan(latitudeDelta: MapAttributes.spanDelta, longitudeDelta: MapAttributes.spanDelta)
        let zenlyRegion = MKCoordinateRegion(center: MapAttributes.zenlyCoord, span: span)
        mapView.region = zenlyRegion
    }

    private func placeZenlySkateAnnotation() {
        zenlySkateAnnotation.coordinate = MapAttributes.zenlyCoord
        mapView.addAnnotation(zenlySkateAnnotation)
    }
}

extension MapViewController: MapViewModelDelegate {
    func viewModelDidCompute(zenlySkateCoordinate: CLLocationCoordinate2D) {
        zenlySkateAnnotation.coordinate = zenlySkateCoordinate
    }
}
