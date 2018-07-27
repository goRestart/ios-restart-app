
import UIKit
import LGComponents

final class DropdownShowMoreView: UITableViewHeaderFooterView, ReusableCell {
    
    private var didSelectShowMoreAction: (() -> Void)?
    
    private enum Layout {
        static let titleLabelHorizontalInset: CGFloat = 55
        static let titleLabelFontSize: Int = 17
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(size: Layout.titleLabelFontSize)
        label.textColor = .grayDark
        label.text = R.Strings.filterServicesServicesListShowMore
        
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
        setupGestureRecognizer()
    }
    
    func setupSelectShowMoreAction(didSelectShowMoreAction: (() -> Void)?) {
        self.didSelectShowMoreAction = didSelectShowMoreAction
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubviewForAutoLayout(titleLabel)
        
        titleLabel.layout(with: self)
            .fillVertical()
            .fillHorizontal(by: Layout.titleLabelHorizontalInset)
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        setupLayout()
    }
    
    private func setupGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSelectShowMore))
        contentView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func didSelectShowMore() {
        didSelectShowMoreAction?()
    }
}
