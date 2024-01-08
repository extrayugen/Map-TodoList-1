import UIKit
import SnapKit
import FaveButton

class TodoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var todos: [TodoItem] = [] // 할 일 목록
    var likedTodos: Set<String> = [] // 좋아요를 누른 할 일 제목을 저장
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
    }
    
    func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TodoCell")
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTodoItem))
    }
    
    @objc func addTodoItem() {
        let alertController = UIAlertController(title: "할 일 추가", message: "할 일의 내용을 입력하세요", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "제목"
        }
        alertController.addTextField { textField in
            textField.placeholder = "설명"
        }
        let addAction = UIAlertAction(title: "추가", style: .default) { [unowned self, unowned alertController] _ in
            guard let title = alertController.textFields?.first?.text,
                  let description = alertController.textFields?.last?.text else { return }
            let newItem = TodoItem(title: title, description: description)
            self.todos.append(newItem)
            self.tableView.reloadData()
        }
        alertController.addAction(addAction)
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }
    
    
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoTableViewCell
        let todo = todos[indexPath.row]
        
        // TodoTableViewCell의 configure 메서드를 사용하여 셀을 구성하고 좋아요 버튼의 델리게이트 설정
        cell.configure(with: todo, isFavorite: likedTodos.contains(todo.title))
        
        cell.faveButton.delegate = self
        cell.faveButton.tag = indexPath.row
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // 모든 셀을 편집 가능하게 설정
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedTodo = todos.remove(at: indexPath.row)
            likedTodos.remove(deletedTodo.title)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // 할 일 항목 선택 시 로직을 추가할 수 있습니다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entryView = TodoEntryView()
        entryView.onAddTodo = { [weak self] text in
            // 할 일 항목 추가 로직
            let todoItem = TodoItem(title: text, description: text)
            self?.todos.append(todoItem)
            self?.tableView.reloadData()
        }
        
        // 전체 화면으로 TodoEntryView를 표시합니다.
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.addSubview(entryView)
            entryView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}
