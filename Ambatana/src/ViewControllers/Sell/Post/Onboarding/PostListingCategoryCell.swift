//
//  PostListingCategoryCell.swift
//  LetGo


import LGCoreKit
import RxSwift
import LGComponents

class PostListingCategoryCell: UITableViewCell {

    private let label = UILabel()

    
    // MARK: - Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }

    override var isSelected: Bool {
        didSet {
            accessoryType = isSelected ? .checkmark : .none
        }
    }
    
    private func resetUI() {
        accessoryType = .none
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        selectionStyle = .none
        label.font = UIFont.systemBoldFont(size: 21)
        label.textColor = UIColor.blackText
        label.numberOfLines = 1
        label.textAlignment = .left
        tintColor = UIColor.primaryColor
    }
    
    private func setupLayout() {
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layout(with: contentView).left(by: Metrics.bigMargin).top().bottom().right()
    }
    
    func updateWith(text: String?) {
        label.text = text
    }
}
