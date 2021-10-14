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
    static let zenlyCoord = CLLocationCoordinate2D(latitude: 48.85406197173514, longitude: 2.3730338486432867)
}

// MARK: - MapViewController
class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!

    let viewModel = MapViewModel()

    var zenlySkateAnnotation = MKPointAnnotation()
    var zenlySkateAnnotationView: MKAnnotationView?

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
        mapView.delegate = self
    }

    private func placeZenlySkateAnnotation() {
        zenlySkateAnnotation.coordinate = MapAttributes.zenlyCoord
        mapView.addAnnotation(zenlySkateAnnotation)
    }

    private func makeZenlySkateAnnotation(viewFor annotation: MKAnnotation) -> MKAnnotationView {
        guard let zenlySkateAnnotationView = zenlySkateAnnotationView else {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "zenlySkate")
            annotationView.image = UIImage(named: "ZSkate")
            annotationView.canShowCallout = false
            zenlySkateAnnotationView = annotationView

            return annotationView
        }

        return zenlySkateAnnotationView
    }
}

extension MapViewController: MapViewModelDelegate {
    func viewModelDidCompute(zenlySkateCoordinate: CLLocationCoordinate2D) {
        zenlySkateAnnotation.coordinate = zenlySkateCoordinate
    }

    func viewModelDidCompute(zenlySkateAngle: Double) {
        UIView.animate(withDuration: 1.0) {
            self.zenlySkateAnnotationView?.layer.setAffineTransform(CGAffineTransform(rotationAngle: zenlySkateAngle))
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case _ as MKUserLocation:
            return nil
        default:
            return makeZenlySkateAnnotation(viewFor: annotation)
        }
    }
}
