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
    
    
    var todos: [TodoItem] = []
    var tableView: UITableView!
    var location: CLLocationCoordinate2D?
    var faveButton: FaveButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
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
    

    // MARK: - UITableView
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
    
    private func createFaveButton(named iconName: String) -> FaveButton {
        let button = FaveButton(
            frame: CGRect(x: 0, y: 0, width: 44, height: 44),
            faveIconNormal: UIImage(named: iconName)
            
        )

        return button
    }
    

    // MARK: - Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        // 버튼 너비와 간격 설정
        let buttonWidth: CGFloat = 44
        let buttonSpacing: CGFloat = 50
        let totalButtonsWidth = buttonWidth * 4
        let totalSpacing = buttonSpacing * 3 // 세 개의 간격
        let totalWidth = totalButtonsWidth + totalSpacing
        
        // headerView의 너비 구하기
        let headerWidth = tableView.bounds.width
        let startingX = (headerWidth - totalWidth) / 2 // 첫 번째 버튼의 시작점
        
        // 각 버튼의 X 좌표 계산
        let button1X = startingX
        let button2X = button1X + buttonWidth + buttonSpacing
        let button3X = button2X + buttonWidth + buttonSpacing
        let button4X = button3X + buttonWidth + buttonSpacing
        
        let faveButton1 = FaveButton(
            frame: CGRect(x: button1X, y: 0, width: 44, height: 44),
            faveIconNormal: UIImage(named: "heart")
        )
        
        let faveButton2 = FaveButton(
            frame: CGRect(x: button2X, y: 0, width: 44, height: 44),
            faveIconNormal: UIImage(named: "like")
        )
        let faveButton3 = FaveButton(
            frame: CGRect(x: button3X, y: 0, width: 44, height: 44),
            faveIconNormal: UIImage(named: "star")
        )
        let faveButton4 = FaveButton(
            frame: CGRect(x: button4X, y: 0, width: 44, height: 44),
            faveIconNormal: UIImage(named: "smile")
        )

        faveButton1.selectedColor = .softRed   // 하트
        faveButton2.selectedColor = .softBlue    // 좋아요
        faveButton3.selectedColor = .softGold   // 별
        faveButton4.selectedColor = .softGreen  // 스마일

        headerView.addSubview(faveButton1)
        headerView.addSubview(faveButton2)
        headerView.addSubview(faveButton3)
        headerView.addSubview(faveButton4)
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80.0 // 헤더의 높이를 조절 (원하는 값으로 설정)
    }
    

// MARK: - Footer
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

extension UIColor {
    static let softRed = UIColor(red: 226/255, green: 38/255, blue: 77/255, alpha: 0.7)
    static let softGold = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 0.7)
    static let softBlue = UIColor(red: 0/255, green: 50/255, blue: 180/255, alpha: 0.7)
    static let softGreen = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 0.7)
}
