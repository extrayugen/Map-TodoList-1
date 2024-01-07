//
//  MapViewController.swift
//  Map-TodoList-1
//
//  Created by t2023-m0031 on 1/6/24.
//

import UIKit
import MapKit
import SnapKit

class MapViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, MKLocalSearchCompleterDelegate {

    var mapView: MKMapView!
    var initialLocation: CLLocationCoordinate2D?
    let searchBar = UISearchBar()
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var searchResultsTableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupSearchBar()
        
        setupSearchResultsTableView()
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let coordinate = view.annotation?.coordinate else { return }
        
        // Todo 입력을 위한 얼럿 컨트롤러 생성
        let alertController = UIAlertController(title: "할 일 추가", message: "할 일의 내용을 입력하세요", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "제목"
        }
        alertController.addTextField { textField in
            textField.placeholder = "설명"
        }

        let addAction = UIAlertAction(title: "추가", style: .default) { [weak alertController] _ in
            guard let title = alertController?.textFields?[0].text,
                  let description = alertController?.textFields?[1].text else { return }

            let todoItem = TodoItem(title: title, description: description, coordinate: coordinate)
            TodoManager.shared.addTodo(todoItem)
            // Todo 목록 업데이트 또는 사용자 인터페이스 반영
        }

        alertController.addAction(addAction)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
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
