import UIKit
import LGComponents

private enum ViewLayout {
    static let stackViewSpacing: CGFloat = 8
}

final class ChatOtherInfoLocationView: UIView {
    var location: String? {
        didSet { label.text = location }
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = ViewLayout.stackViewSpacing
        return stackView
    }()
 
    private let icon: UIImageView = {
        let icon = UIImageView(image: R.Asset.IconsButtons.icLocation.image)
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .grayDark
        label.font = .systemRegularFont(size: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setupUI() {
        stackView.addArrangedSubviews([icon, label, UIView()])
        addSubviewForAutoLayout(stackView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        stackView.constraintToEdges(in: self)
    }
}
