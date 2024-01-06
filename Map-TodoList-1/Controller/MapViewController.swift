//
//  MapViewController.swift
//  Map-TodoList-1
//
//  Created by t2023-m0031 on 1/6/24.
//

import UIKit
import MapKit
import SnapKit

class MapViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {
    
    var mapView: MKMapView!
    var initialLocation: CLLocationCoordinate2D?
    var countriesTableView: UITableView!
    var countriesData: [(name: String, capital: String)] = []
    let searchBar = UISearchBar()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MKMapView(frame: view.frame)
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
        // 안전 영역 내에서 지도의 레이아웃 제약 조건을 설정합니다.
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        setupSearchBar()
        
        if let initialLocation = initialLocation {
            // initialLocation이 설정되었다면 해당 좌표로 지도의 중심을 설정합니다.
            mapView.setCenter(initialLocation, animated: true)
        }
        
        
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
          searchBar.placeholder = "장소를 입력하세요!"
          searchBar.showsSearchResultsButton = true
          searchBar.sizeToFit()
          
          view.addSubview(searchBar)
          searchBar.snp.makeConstraints { make in
              make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
              make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
              make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
          }
      }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        // 검색 요청을 생성하고 실행합니다.
        if let searchText = searchBar.text, !searchText.isEmpty {
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = searchText
            
            let search = MKLocalSearch(request: searchRequest)
            search.start { response, _ in
                guard let response = response else {
                    return
                }
                
                // 검색 결과를 처리합니다.
                self.handleSearchResults(response.mapItems)
            }
        }
    }
    
    func handleSearchResults(_ mapItems: [MKMapItem]) {
        // 이전의 핀을 지도에서 제거합니다.
        mapView.removeAnnotations(mapView.annotations)
        
        // 검색 결과에 대한 핀을 추가합니다.
        for item in mapItems {
            let annotation = MKPointAnnotation()
            annotation.title = item.name
            annotation.coordinate = item.placemark.coordinate
            mapView.addAnnotation(annotation)
        }
        
        // 첫 번째 검색 결과를 중심으로 지도를 조정합니다.
        if let firstItem = mapItems.first {
            let region = MKCoordinateRegion(center: firstItem.placemark.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
            mapView.setRegion(region, animated: true)
        }
    }
    
}
