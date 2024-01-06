//
//  MapViewController.swift
//  Map-TodoList-1
//
//  Created by t2023-m0031 on 1/6/24.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    var mapView: MKMapView!
    var initialLocation: CLLocationCoordinate2D?
    var countriesTableView: UITableView!
    var countriesData: [(name: String, capital: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MKMapView(frame: view.frame)
        mapView.delegate = self
        view.addSubview(mapView)
        
        if let initialLocation = initialLocation {
            // initialLocation이 설정되었다면 해당 좌표로 지도의 중심을 설정합니다.
            mapView.setCenter(initialLocation, animated: true)
        }
    }

}
