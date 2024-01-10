//
//  MapViewController.swift
//  Map-TodoList-1
//
//  Created by t2023-m0031 on 1/6/24.
//

import UIKit
import MapKit
import SnapKit

class MapViewController: UIViewController, MKMapViewDelegate, MKLocalSearchCompleterDelegate, UITableViewDelegate, UISearchBarDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate {

    var mapView: MKMapView!
    var initialLocation: CLLocationCoordinate2D?
    
    //검색 관련 변수
    let searchBar = UISearchBar()
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var searchResultsTableView: UITableView!

    var userCreatedAnnotation: MKAnnotation?
    var addingPin: Bool = false
    
    var todoList = [String]()
    var todoTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupSearchBar()
        setupSearchResultsTableView()
        searchCompleter.delegate = self
        addLongPressGestureRecognizer()
        setupTableView()

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
    
    // 검색 바와 검색 결과 테이블 뷰 설정
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
    
    func setupTableView(){
        todoTableView = UITableView()
        todoTableView.delegate = self
        todoTableView.dataSource = self
        todoTableView.isHidden = true
        view.addSubview(todoTableView)
        todoTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Search Bar
    // 검색 바 입력 시 호출되는 메서드
     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
         searchCompleter.queryFragment = searchText
         searchResultsTableView.isHidden = searchText.isEmpty
     }

     // 검색 결과 업데이트 시 호출되는 메서드
     func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
         searchResults = completer.results
         searchResultsTableView.reloadData()
     }

     // 검색 버튼 클릭 시 호출되는 메서드
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         searchBar.resignFirstResponder()
         if let searchText = searchBar.text {
             performSearch(searchText: searchText)
         }
     }
    
    // MARK: - Long Press Gesture
    // 지도에 길게 누르기 제스처 인식기를 추가하는 메서드
    private func addLongPressGestureRecognizer() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    // 길게 누르기 제스처를 처리하는 메서드
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
         if gestureRecognizer.state != .began { return } // 제스처가 반복되지 않도록 합니다.

         let point = gestureRecognizer.location(in: mapView)
         let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

         // 해당 위치에 핀을 추가하는 로직
         addPinAtCoordinate(coordinate)
    }
    
    func addPinAtCoordinate(_ coordinate: CLLocationCoordinate2D) {
        // 기존에 추가한 핀이 있을 경우 제거
        if let existingPin = userCreatedAnnotation {
            mapView.removeAnnotation(existingPin)
        }

        // 새로운 핀 생성 및 설정
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "새로운 핀" // 핀의 제목을 원하는 대로 설정하세요.

        // 맵뷰에 핀 추가
        mapView.addAnnotation(annotation)

        // userCreatedAnnotation 업데이트
        userCreatedAnnotation = annotation

        // 핀 추가 모드 종료 (핀 추가 후 다른 작업을 하거나 새로운 핀을 추가하려면 해당 로직을 수정하세요)
        addingPin = false
    }

    // MARK: - MKAnnotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            let selectedLocation = annotation.coordinate
            showTodoListView(at: selectedLocation)
        }
    }
    
    func showTodoListView(at location: CLLocationCoordinate2D) {
        let todoListViewController = TodoListViewController()
        todoListViewController.location = location
        
        present(todoListViewController, animated: true)
    }

    
    // MARK: - TableView SourceData, Delegate

     // 검색 결과 테이블 뷰의 행 개수
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return searchResults.count
     }

     // 검색 결과 테이블 뷰의 셀 설정
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
         let searchResult = searchResults[indexPath.row]
         cell.textLabel?.text = searchResult.title
         return cell
     }

     // 검색 결과 테이블 뷰에서 행 선택 시 호출되는 메서드
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let completion = searchResults[indexPath.row]
         performSearch(searchText: completion.title)
         searchResultsTableView.isHidden = true
     }

     // 실제 지도 검색 로직
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



}
