import Foundation

class ToDoManager {
    static let shared = ToDoManager()
    
    private let itemsKey = "ToDoItems"
    private(set) var items: [ToDoItem] = [] // 외부에서 읽기만 가능하도록 설정
    
    private init() {
        loadItems()
    }
    
    // 항목을 로드하는 메소드
    func loadItems() {
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.data(forKey: itemsKey),
           let savedItems = try? JSONDecoder().decode([ToDoItem].self, from: data) {
            items = savedItems
        }
    }
    
    // 항목을 저장하는 메소드
    func saveItems() {
        let userDefaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(items) {
            userDefaults.set(data, forKey: itemsKey)
            userDefaults.synchronize() // 데이터 동기화를 위해 호출 (iOS 12 이전 버전)
        }
    }
    
    // 항목을 추가하는 메소드
    func addItem(_ item: ToDoItem) {
        items.append(item)
        saveItems()
    }
    
    // 항목을 업데이트하는 메소드
    func updateItem(_ item: ToDoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            saveItems()
        }
    }
    
    // 항목을 삭제하는 메소드
    func deleteItem(_ item: ToDoItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }
    
    // 특정 위치의 항목을 가져오는 메소드
    func item(at index: Int) -> ToDoItem? {
        if items.indices.contains(index) {
            return items[index]
        }
        return nil
    }
    
    // 모든 항목을 가져오는 메소드
    func getAllItems() -> [ToDoItem] {
        return items
    }
}
