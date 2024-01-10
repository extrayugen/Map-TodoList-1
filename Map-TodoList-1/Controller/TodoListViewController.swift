//
//  TodoListViewController.swift
//  Map-TodoList-1
//
//  Created by t2023-m0031 on 1/10/24.
//

import UIKit
import MapKit
import SnapKit
import FaveButton


class TodoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FaveButtonDelegate{
    
    
    var stackView: UIStackView!
    var todos: [TodoItem] = []
    var tableView: UITableView!
    var location: CLLocationCoordinate2D?
    var heartButton: FaveButton!
    var loveButton: FaveButton!
    var likeButton: FaveButton!
    var starButton: FaveButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        stackView = UIStackView()
        
        // 테이블뷰가 화면 중앙에서 시작하여 아래쪽 끝까지 차지하도록 설정
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.centerY)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TodoCell")
        view.addSubview(tableView)
        
        // 테이블 뷰 제약 조건 설정
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.centerY)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func createFaveButton(named iconName: String) -> FaveButton {
        let button = FaveButton(
            frame: CGRect(x: 200, y: 200, width: 44, height: 44),
            faveIconNormal: UIImage(named: iconName)
        )
        button.delegate = self
        button.addTarget(self, action: #selector(faveButtonTapped(_:)), for: .touchUpInside) // 액션 추가
        return button
    }

    @objc private func faveButtonTapped(_ sender: FaveButton) {
        sender.isSelected = !sender.isSelected // 버튼의 선택 상태를 토글
    }

    @objc private func addTodoButtonTapped() {
        // UIAlertController를 사용하여 사용자로부터 할 일을 입력받습니다.
        let alertController = UIAlertController(title: "할 일 추가", message: "할 일을 추가하세용!", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = ""
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let textField = alertController.textFields?.first, let todoText = textField.text, !todoText.isEmpty {
                // 입력된 할 일을 todos 배열에 추가합니다.
                let newTodo = TodoItem(title: todoText)
                self?.todos.append(newTodo)
                self?.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        // UIAlertController를 표시합니다.
        present(alertController, animated: true, completion: nil)
    }

    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        let todo = todos[indexPath.row]
        cell.textLabel?.text = todo.title
        return cell
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // FaveButtonDelegate 메서드 구현
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
        // FaveButton 선택 상태 변경에 따른 동작 구현
        if selected {
            // 선택된 상태에서의 동작
            print("FaveButton selected")
        } else {
            // 선택 해제된 상태에서의 동작
            print("FaveButton deselected")
        }
    }

    
    // Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        // FaveButton 추가 (4개)
        let faveButton1 = createFaveButton(named: "heart")
        let faveButton2 = createFaveButton(named: "like")
        let faveButton3 = createFaveButton(named: "smile")
        let faveButton4 = createFaveButton(named: "star")
        
        // StackView를 사용하여 FaveButton들을 가로로 정렬
        let stackView = UIStackView(arrangedSubviews: [faveButton1, faveButton2, faveButton3, faveButton4])
        stackView.axis = .horizontal
        stackView.spacing = 50 // 버튼 간의 간격을 조절 (원하는 값으로 설정)
        
        headerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
        ])
        
        stackView.isUserInteractionEnabled = true
        faveButton1.isUserInteractionEnabled = true
        faveButton2.isUserInteractionEnabled = true
        faveButton3.isUserInteractionEnabled = true
        faveButton4.isUserInteractionEnabled = true
    
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100.0 // 헤더의 높이를 조절 (원하는 값으로 설정)
    }
    


    // Footer
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        
        // "Add Todo" 버튼 추가
        let addButton = UIButton(type: .system)
        addButton.setTitle("Add Todo", for: .normal)
        addButton.addTarget(self, action: #selector(addTodoButtonTapped), for: .touchUpInside)
        
        footerView.addSubview(addButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
        ])
        
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44.0 // 푸터의 높이를 조절 (원하는 값으로 설정)
    }
}
