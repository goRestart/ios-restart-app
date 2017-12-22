import Foundation
import UIKit

class TagCollectionViewCell: UICollectionViewCell, ReusableCell {
    
    let tagLabel: UIRoundedLabelWithPadding = {
        let label = UIRoundedLabelWithPadding(frame: .zero, padding: UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(tagLabel)
        tagLabel.backgroundColor = UIColor.black.withAlphaComponent(0.54)
        tagLabel.font = tagLabel.font.withSize(13.0)
        tagLabel.textColor = .white
    }
    
    private func setupConstraints() {
        let constraints = [
            tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tagLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            tagLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(with tag: String) {
        tagLabel.text = tag
    }
}
