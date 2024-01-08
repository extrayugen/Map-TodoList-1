//
//  TodoTableViewCell.swift
//  Map-TodoList-1
//
//  Created by t2023-m0031 on 1/8/24.
//

import UIKit
import SnapKit
import FaveButton

class TodoTableViewCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let faveButton = FaveButton(
        frame: CGRect(x: 0, y: 0, width: 44, height: 44),
        faveIconNormal: UIImage(named: "heart")
    )
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(faveButton)
        setupLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 셀 구성 메서드
    func configure(with todo: TodoItem, isFavorite: Bool) {
        titleLabel.text = todo.title
        faveButton.setSelected(selected: isFavorite, animated: false)
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.lessThanOrEqualTo(faveButton.snp.left).offset(-10)
        }
        
        faveButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(20)
            make.width.height.equalTo(44) // 좋아요 버튼의 크기
        }
        
        faveButton.addTarget(self, action: #selector(faveButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func faveButtonTapped(_ sender: FaveButton) {
        // Handle the fave button tap event here.
        // You can update the liked status and perform any necessary actions.
        // For example, you can send a network request to update the like status.
        // Then, update the UI accordingly.
    }
    
    
}
