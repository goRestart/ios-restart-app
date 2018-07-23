
import UIKit
import LGComponents

final class DropdownShowMoreCell: UITableViewCell, ReusableCell {
    
    private enum Layout {
        static let titleLabelHorizontalInset: CGFloat = 110
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        selectionStyle = .none
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
}
