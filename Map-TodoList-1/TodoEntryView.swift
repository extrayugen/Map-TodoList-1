import UIKit
import MapKit
import SwiftEntryKit

class TodoEntryView: UIView {
    
    let titleLabel = UITextField()
    let descriptionLabel = UITextField()
    var coordinate: CLLocationCoordinate2D?
    
    let addButton = UIButton()
    let cancelButton = UIButton()
    
    // 클로저 형태의 콜백 추가
    var onAddTodo: ((String, String, CLLocationCoordinate2D) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = .white
        
        // titleLabel, descriptionLabel, addButton UI 구성 코드
        // ...
        
        // Add Button 타겟 설정
        addButton.addTarget(self, action: #selector(addTodo), for: .touchUpInside)
        
        // Cancel Button 타겟 설정
        cancelButton.addTarget(self, action: #selector(dismissEntryView), for: .touchUpInside)
    }
    
    @objc func addTodo() {
        guard let title = titleLabel.text, !title.isEmpty,
              let description = descriptionLabel.text, !description.isEmpty,
              let coordinate = coordinate else {
            // 적절한 사용자 피드백 제공
            return
        }
        onAddTodo?(title, description, coordinate)
    }
    
    @objc func dismissEntryView() {
        SwiftEntryKit.dismiss()
    }
}
