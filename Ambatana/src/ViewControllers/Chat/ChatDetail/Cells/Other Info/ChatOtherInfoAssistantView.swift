import UIKit
import LGComponents

private enum ViewLayout {
    static let stackViewSpacing: CGFloat = 8
    static let labelLeading: CGFloat = 5
    static let maxWidth: CGFloat = 180
    
    enum Icon {
        static let size = CGSize(width: 15, height: 15)
        static let leadingSpacing: CGFloat = 2
        static let topSpacing: CGFloat = 4
    }
}

final class ChatOtherInfoAssistantView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = ViewLayout.stackViewSpacing
        return stackView
    }()
    
    private let icon: UIImageView = {
        let icon = UIImageView(image: R.Asset.IconsButtons.icChatInfoDark.image)
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .grayDark
        label.font = .systemRegularFont(size: 11)
        label.text = R.Strings.chatUserInfoLetgoAssistant
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setupUI() {
        addSubviewsForAutoLayout([icon, label])
        setupConstraints()
    }
    
    private func setupConstraints() {
        let iconConstraints = [
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewLayout.Icon.leadingSpacing),
            icon.topAnchor.constraint(equalTo: topAnchor, constant: ViewLayout.Icon.topSpacing),
            icon.widthAnchor.constraint(equalToConstant: ViewLayout.Icon.size.width),
            icon.heightAnchor.constraint(equalToConstant: ViewLayout.Icon.size.height)
        ]
        iconConstraints.activate()
        
        let labelConstraints = [
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: ViewLayout.labelLeading),
            label.topAnchor.constraint(equalTo: icon.topAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        labelConstraints.activate()
        widthAnchor.constraint(equalToConstant: ViewLayout.maxWidth).isActive = true
    }
}
