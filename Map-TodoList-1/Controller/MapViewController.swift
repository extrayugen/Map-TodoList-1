//
//  MapViewController.swift
//  Map-TodoList-1
//
//  Created by t2023-m0031 on 1/6/24.
//

import UIKit
import MapKit
import SnapKit
import SwiftEntryKit

class MapViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, MKLocalSearchCompleterDelegate {

    var mapView: MKMapView!
    var initialLocation: CLLocationCoordinate2D?
    let searchBar = UISearchBar()
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var searchResultsTableView: UITableView!
    var userCreatedAnnotation: MKAnnotation?

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupSearchBar()
        setupSearchResultsTableView()
        addLongPressGesture()
        searchCompleter.delegate = self

    }
    
    func setupMapView() {
        mapView = MKMapView()
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        if let initialLocation = initialLocation {
            mapView.setCenter(initialLocation, animated: true)
        }
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "장소를 입력하세요!"
        searchBar.showsSearchResultsButton = true
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func setupSearchResultsTableView() {
        searchResultsTableView = UITableView()
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchResultCell")
        searchResultsTableView.isHidden = true
        
        view.addSubview(searchResultsTableView)
        
        searchResultsTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
        searchResultsTableView.isHidden = searchText.isEmpty
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultsTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text {
            performSearch(searchText: searchText)
        }
    }
    private func addLongPressGesture() {
           let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
           mapView.addGestureRecognizer(longPressGesture)
       }

    // Long press recognizer의 handler 메서드
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        // 이미 추가된 핀이 있는 경우 return
        if gesture.state != .began || userCreatedAnnotation != nil {
            return
        }
        
        let locationInView = gesture.location(in: mapView)
        let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
        
        // 새로운 핀 추가
        let userAddedAnnotation = UserAddedPin(coordinate: coordinate, title: "사용자 위치")
        mapView.addAnnotation(userAddedAnnotation)
        
        // 추적을 위해 userCreatedAnnotation에 할당
        userCreatedAnnotation = userAddedAnnotation
    }

    private func addPinAtCoordinate(_ coordinate: CLLocationCoordinate2D) {
        // 기존 핀이 있으면 제거
        if let existingAnnotation = userCreatedAnnotation {
            mapView.removeAnnotation(existingAnnotation)
        }

        // UserAddedPin 인스턴스를 생성하고 좌표를 전달합니다.
        let annotation = UserAddedPin(coordinate: coordinate)
        mapView.addAnnotation(annotation)

        // 새로운 핀을 추적
        userCreatedAnnotation = annotation
    }

    private func performSearch(searchText: String?) {
        guard let searchText = searchText, !searchText.isEmpty else { return }

        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText

        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] response, _ in
            guard let self = self, let response = response else { return }

            self.mapView.removeAnnotations(self.mapView.annotations)
            for item in response.mapItems {
                let annotation = MKPointAnnotation()
                annotation.title = item.name
                annotation.coordinate = item.placemark.coordinate
                self.mapView.addAnnotation(annotation)
            }

            if let firstItem = response.mapItems.first {
                let region = MKCoordinateRegion(center: firstItem.placemark.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
    
    
    @objc func dismissEntryView() {
        SwiftEntryKit.dismiss()
    }
    
    // MARK: - MapViewDelegate
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? UserAddedPin else { return }
        
        // UIAlertController 생성
        let alertController = UIAlertController(title: "새 할 일 추가", message: "할 일의 제목과 설명을 입력하세요.", preferredStyle: .alert)
        
        // 텍스트 필드 추가
        alertController.addTextField { textField in
            textField.placeholder = "제목"
        }
        alertController.addTextField { textField in
            textField.placeholder = "설명"
        }
        
        // 추가 버튼
        let addAction = UIAlertAction(title: "추가", style: .default) { [weak self] _ in
            guard let title = alertController.textFields?.first?.text,
                  let description = alertController.textFields?.last?.text else { return }
            
            let todoItem = TodoItem(title: title, description: description, coordinate: annotation.coordinate)
            // TodoManager 또는 관련 데이터 구조에 todoItem 추가
            // ...
        }
        
        // 취소 버튼
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        // 알림창에 버튼 추가
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        // 알림창 표시
        self.present(alertController, animated: true)
    }

    // MARK: - MapViewDataSource
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let identifier = "CustomPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
            annotationView?.animatesWhenAdded = true
        } else {
            annotationView?.annotation = annotation
        }

        if annotation is UserAddedPin {
            annotationView?.markerTintColor = .systemMint // 사용자가 추가한 핀의 색상
        } else {
            annotationView?.markerTintColor = .red // 검색 결과 핀의 색상
        }

        return annotationView
    }





    
    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let searchResult = searchResults[indexPath.row]
        cell.textLabel?.text = searchResult.title
        return cell
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let completion = searchResults[indexPath.row]
        performSearch(searchText: completion.title)
        searchResultsTableView.isHidden = true
    }
    
    
}
