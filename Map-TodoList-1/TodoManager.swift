//
//  TodoManager.swift
//  Map-TodoList-1
//
//  Created by t2023-m0031 on 1/7/24.
//

import Foundation

class TodoManager {
    static let shared = TodoManager()

    var todos: [TodoItem] = []

    func addTodo(_ todo: TodoItem) {
        todos.append(todo)
    }

    // 필요한 경우 추가적인 메서드 구현
}
