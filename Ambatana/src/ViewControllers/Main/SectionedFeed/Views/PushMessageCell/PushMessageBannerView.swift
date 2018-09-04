import UIKit
import LGComponents

final class PushMessageBannerView: UIView {
    
    private let icon: UIImageView = {
        let icon = UIImageView(image: R.Asset.IconsButtons.icMessages.image)
        icon.contentMode = .center
        return icon
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemMediumFont(size: 17)
        label.textColor = UIColor.grayLighter
        label.text = R.Strings.profilePermissionsHeaderMessage
        return label
    }()
    
    private let disclosure: UIImageView = {
        let disclosure = UIImageView(image: R.Asset.IconsButtons.icDisclosure.image)
        disclosure.contentMode = .center
        return disclosure
    }()
    
    enum Layout {
        static let viewHeight: CGFloat = 50
        static let iconWidth: CGFloat = 55
        static let disclosureWidth: CGFloat = 27
        static let messageMargin: CGFloat = 8
    }
    
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private methods
    
    private func setupUI() {
        backgroundColor = UIColor.lgBlack
        addSubviewsForAutoLayout([icon, label, disclosure])
        
        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: topAnchor),
            icon.bottomAnchor.constraint(equalTo: bottomAnchor),
            icon.leftAnchor.constraint(equalTo: leftAnchor),
            icon.widthAnchor.constraint(equalToConstant: Layout.iconWidth),
            
            disclosure.topAnchor.constraint(equalTo: topAnchor),
            disclosure.bottomAnchor.constraint(equalTo: bottomAnchor),
            disclosure.rightAnchor.constraint(equalTo: rightAnchor),
            disclosure.widthAnchor.constraint(equalToConstant: Layout.disclosureWidth),
            
            label.leftAnchor.constraint(equalTo: icon.rightAnchor),
            label.rightAnchor.constraint(equalTo: disclosure.leftAnchor, constant: -Layout.messageMargin),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
