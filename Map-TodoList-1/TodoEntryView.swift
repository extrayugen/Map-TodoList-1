import UIKit
import SnapKit

class TodoEntryView: UIView {
    var onAddTodo: ((String) -> Void)?
    
    private let textField = UITextField()
    private let addButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // UI 요소들을 생성하고 뷰에 추가하는 코드를 작성합니다.
        
        textField.placeholder = "할 일을 입력하세요"
        textField.borderStyle = .roundedRect
        addSubview(textField)
        
        addButton.setTitle("추가", for: .normal)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addSubview(addButton)
        
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(addButton.snp.left).offset(-10)
        }
        
        addButton.snp.makeConstraints { make in
            make.top.equalTo(textField)
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    @objc private func addButtonTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        onAddTodo?(text)
        textField.text = ""
    }
}
