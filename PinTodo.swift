//
//  PinTodo.swift
//  Map-TodoList-1
//
//  Created by t2023-m0031 on 1/10/24.
//

import UIKit
import MapKit


class TodoItem {
    var title: String

    init(title: String) {
        self.title = title
    }
}

struct PinTodo {
    var coordinate: CLLocationCoordinate2D
    var todos: [TodoItem]

    init(coordinate: CLLocationCoordinate2D, todos: [TodoItem]) {
        self.coordinate = coordinate
        self.todos = todos
    }
}
