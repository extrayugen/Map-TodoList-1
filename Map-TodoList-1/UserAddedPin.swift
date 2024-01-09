//
//  UserAddedPin.swift
//  Map-TodoList-1
//
//  Created by t2023-m0031 on 1/7/24.
//

import UIKit
import MapKit

class UserAddedPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var todoItems: [TodoItem] = [] // 할 일 목록을 저장하는 배열
    
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        self.coordinate = coordinate
        self.title = title
    }
    
    // 할 일을 추가하는 메서드
    func addTodoItem(_ item: TodoItem) {
        todoItems.append(item)
        
        
    }
}
