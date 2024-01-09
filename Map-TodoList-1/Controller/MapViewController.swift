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
    
    var userCreatedAnnotation: MKAnnotation?
    var todoListViewController: TodoListViewController!
    var bottomSheetView: UIView!
    var addingPin: Bool = false
    
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
        if gesture.state != .began {
            return
        }
        
        let locationInView = gesture.location(in: mapView)
        let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
        
        if addingPin {
            addPinAtCoordinate(coordinate)
        } else {
            // 사용자가 핀을 추가하는 중임을 표시하기 위해 플래그를 설정합니다.
            addingPin = true
            // 핀 추가 창을 표시합니다.
            showPinInputDialog(coordinate: coordinate)
        }
    }

    // 핀을 지정된 좌표에 추가하는 메서드
    private func addPinAtCoordinate(_ coordinate: CLLocationCoordinate2D) {
        if let existingAnnotation = userCreatedAnnotation {
            mapView.removeAnnotation(existingAnnotation)
        }
        
        let annotation = UserAddedPin(coordinate: coordinate)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        userCreatedAnnotation = annotation
        addingPin = false // 핀 추가가 완료되면 플래그를 다시 비활성화합니다.
    }

    // 핀 추가 창을 표시하는 메서드
    private func showPinInputDialog(coordinate: CLLocationCoordinate2D) {
        let alertController = UIAlertController(
            title: "할 일 추가", message: "할 일의 내용을 입력하세요", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "할 일"
        }
        let addAction = UIAlertAction(title: "추가", style: .default) { [weak self, unowned alertController] _ in
            guard let todoContent = alertController.textFields?.first?.text else { return }
            guard let description = alertController.textFields?.last?.text else { return }

            let newTodo = TodoItem(title: todoContent)
            // Todo 목록에 추가하는 로직
            
            self?.addPinAtCoordinate(coordinate) // 핀을 추가하고 플래그를 다시 설정합니다.
        }

        alertController.addAction(addAction)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel) { _ in
            self.addingPin = false // 취소 버튼을 누르면 플래그를 다시 설정하여 핀 추가 모드를 비활성화합니다.
        })

        present(alertController, animated: true)
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

    
    // 할 일 목록을 숨기는 메서드 (예를 들어, 목록의 '완료' 버튼 등에 연결)
     @objc func hideTodoList() {
         todoListViewController?.view.isHidden = true
     }

    
    
    // MARK: - MKAnnotationView
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // 선택된 핀이 UserAddedPin 타입인지 확인
        guard let userAddedPin = view.annotation as? UserAddedPin else {
            return
        }
        
        // 해당 핀의 할 일 목록을 가져옴
        let todoItems = userAddedPin.todoItems
        
        if todoItems.isEmpty {
            // 할 일 목록이 비어있으면 할 일을 추가하는 모달 표시
            showAddTodoModal(for: userAddedPin)
        } else {
            // 할 일 목록을 보여주는 화면 표시
            showTodoList(for: todoItems, with: userAddedPin)
        }
    }
    
    // 할 일 목록을 보여주는 화면을 표시하는 메서드
    private func showTodoList(for todoItems: [TodoItem], with userAddedPin: UserAddedPin) {
        let todoListVC = TodoListViewController()
        todoListVC.todos = todoItems
        todoListVC.userAddedPin = userAddedPin
        let navController = UINavigationController(rootViewController: todoListVC)
        present(navController, animated: true, completion: nil)
    }

    // 할 일을 추가하는 모달을 표시하는 메서드
    private func showAddTodoModal(for userAddedPin: UserAddedPin) {
        let alertController = UIAlertController(title: "할 일 추가", message: "할 일의 내용을 입력하세요", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "할 일"
        }
        alertController.addAction(UIAlertAction(title: "추가", style: .default) { [weak alertController] _ in
            guard let todoContent = alertController?.textFields?.first?.text else { return }
            let newTodo = TodoItem(title: todoContent)
            userAddedPin.addTodoItem(newTodo)
        })
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }

    






    
    // MARK: - UITableView Datasource, Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let searchResult = searchResults[indexPath.row]
        cell.textLabel?.text = searchResult.title
        return cell
    }

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let completion = searchResults[indexPath.row]
        performSearch(searchText: completion.title)
        searchResultsTableView.isHidden = true
    }
    
    
}
