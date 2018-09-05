import UIKit
import LGComponents

private enum ViewLayout {
    static let stackViewSpacing: CGFloat = 8
    static let verificationStackViewSpacing: CGFloat = 2
    static let imageSize = CGSize(width: 12, height: 12)
}

final class ChatOtherInfoVerificationView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = ViewLayout.stackViewSpacing
        return stackView
    }()
    
    private let verificationMethodStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = ViewLayout.verificationStackViewSpacing
        return stackView
    }()

    private let icon: UIImageView = {
        let icon = UIImageView(image: R.Asset.IconsButtons.icVerified.image)
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .grayDark
        label.font = .systemRegularFont(size: 12)
        label.text = R.Strings.chatUserInfoVerifiedWith
        return label
    }()
    
    private let facebookIcon = verificationTypeIcon(R.Asset.IconsButtons.icUserPublicFb.image)
    private let googleIcon = verificationTypeIcon(R.Asset.IconsButtons.icUserPublicGoogle.image)
    private let emailIcon = verificationTypeIcon(R.Asset.IconsButtons.icUserPublicEmail.image)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setupUI() {
        verificationMethodStackView.addArrangedSubview(facebookIcon)
        verificationMethodStackView.addArrangedSubview(googleIcon)
        verificationMethodStackView.addArrangedSubview(emailIcon)

        stackView.addArrangedSubviews([icon, label, verificationMethodStackView, UIView()])
        addSubviewForAutoLayout(stackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        stackView.constraintToEdges(in: self)
    }
    
    func configure(with facebook: Bool, google: Bool, email: Bool) {
        facebookIcon.isHidden = !facebook
        googleIcon.isHidden = !google
        emailIcon.isHidden = !email
    }
    
    private static func verificationTypeIcon(_ image: UIImage) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        
        let imageConstraints = [
            imageView.widthAnchor.constraint(equalToConstant: ViewLayout.imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: ViewLayout.imageSize.height)
        ]
        imageConstraints.activate()
        return imageView
    }
}
