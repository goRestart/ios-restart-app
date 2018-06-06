import Foundation
import RxSwift
import RxCocoa
import LGComponents

private struct Layout {
    static let buttonHeight: CGFloat = 30
    static let buildTrustSeparatorSpace: CGFloat = 30
    static let buttonInset: CGFloat = 15
    static let buttonTitleInset: CGFloat = 10
    static let sideMargin: CGFloat = 20.0
    static let logoSeparation: CGFloat = 6
    static let buttonSeparation: CGFloat = 10
    static let buttonContainerHeight: CGFloat = 60
    static let verifiedContainerHeight: CGFloat = 80
    static let verifiedTitleTopMargin: CGFloat = 15
    static let verifiedLogosTopMargin: CGFloat = 10
    static let logoSize: CGFloat = 24
    static let moreBioButtonHeight: CGFloat = 45
    static let iconDefaultTransform: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    static let iconRotatedTransform: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0).rotated(by: CGFloat(Double.pi * 0.999))
}

protocol UserProfileBioAndTrustDelegate: class {
    func didTapAddBio()
    func didTapBuildTrust()
}

final class UserProfileBioAndTrustView: UIView {
    weak var delegate: UserProfileBioAndTrustDelegate?
    let isAnimatingResize = Variable<Bool>(false)

    private let buildTrustButton = LetgoButton()
    private let addBioButton = LetgoButton()
    private let verifiedTitle = UILabel()
    private let moreBioButton = UIButton()
    private let bioLabel = UILabel()
    private let buttonContainer = UIStackView()
    private let verifiedContainer = UIView()
    private let verifiedLogosStackView = UIStackView()
    private let stackView = UIStackView()

    let isPrivate: Bool

    var onlyShowBioText: Bool = false

    var buildTrustButtonTitle: String? {
        didSet {
            buildTrustButton.setTitle(buildTrustButtonTitle, for: .normal)
        }
    }

    var addBioButtonTitle: String? {
        didSet {
            addBioButton.setTitle(addBioButtonTitle, for: .normal)
        }
    }

    var verifiedTitleText: String? {
        didSet {
            verifiedTitle.text = verifiedTitleText
        }
    }

    var moreBioButtonTitle: String? {
        didSet {
            moreBioButton.setTitle(moreBioButtonTitle, for: .normal)
        }
    }

    var accounts: UserViewHeaderAccounts? {
        didSet {
            updateAccountsVisibility()
        }
    }

    var userBio: String? {
        didSet {
            updateBioVisibility()
        }
    }

    private var buildTrustButtonVisible: Bool {
        guard isPrivate && !onlyShowBioText else { return false }
        guard let accounts = accounts else { return true }
        return !(accounts.emailVerified && accounts.facebookVerified && accounts.googleVerified)
    }

    private var verifiedAccountsVisible: Bool {
        guard let accounts = accounts, !onlyShowBioText else { return false }
        return accounts.emailVerified || accounts.facebookVerified || accounts.googleVerified
    }

    private var showMoreBioButtonVisible: Bool {
        if let bio = userBio {
            return !bio.isEmpty
        }
        return false
    }

    private var addBioButtonVisible: Bool {
        guard isPrivate, !onlyShowBioText else { return false }
        if let bio = userBio {
            return bio.isEmpty
        }
        return true
    }


    init(isPrivate: Bool) {
        self.isPrivate = isPrivate
        super.init(frame: .zero)
        setupView()
        setupAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubviewForAutoLayout(stackView)
        buttonContainer.addArrangedSubview(buildTrustButton)
        buttonContainer.addArrangedSubview(addBioButton)

        buttonContainer.alignment = .center
        buttonContainer.axis = .horizontal
        buttonContainer.distribution = .equalSpacing
        buttonContainer.spacing = Layout.buttonSeparation

        verifiedContainer.addSubviewForAutoLayout(verifiedTitle)
        verifiedContainer.addSubviewForAutoLayout(verifiedLogosStackView)
        stackView.addArrangedSubview(buttonContainer)
        stackView.addArrangedSubview(verifiedContainer)
        stackView.addArrangedSubview(moreBioButton)
        stackView.addArrangedSubview(bioLabel)

        addBioButton.setStyle(.secondary(fontSize: .small, withBorder: true))
        addBioButton.layer.cornerRadius = Layout.buttonHeight / 2
        setupBuildTrustButton()

        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0

        verifiedTitle.font = UIFont.sectionTitleFont
        verifiedTitle.textColor = UIColor.grayDark

        verifiedLogosStackView.alignment = .center
        verifiedLogosStackView.axis = .horizontal
        verifiedLogosStackView.distribution = .equalSpacing
        verifiedLogosStackView.spacing = Layout.logoSeparation

        bioLabel.numberOfLines = 0
        bioLabel.font = UIFont.mediumBodyFont
        bioLabel.textColor = UIColor.lgBlack
        bioLabel.isHidden = true

        moreBioButton.addTarget(self, action: #selector(toggleBioLabel), for: .touchUpInside)
        addBioButton.addTarget(self, action: #selector(didTapAddBio), for: .touchUpInside)
        buildTrustButton.addTarget(self, action: #selector(didTapBuildTrust), for: .touchUpInside)

        setupMoreBioButton()
        updateBioVisibility()
        updateAccountsVisibility()
        setupConstraints()
    }

    private func setupConstraints() {
        let constraints = [
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),

            buttonContainer.heightAnchor.constraint(equalToConstant: Layout.buttonContainerHeight),
            addBioButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            buildTrustButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            verifiedContainer.heightAnchor.constraint(equalToConstant: Layout.verifiedContainerHeight),

            verifiedTitle.topAnchor.constraint(equalTo: verifiedContainer.topAnchor, constant: Layout.verifiedTitleTopMargin),
            verifiedTitle.leftAnchor.constraint(equalTo: verifiedContainer.leftAnchor),

            verifiedLogosStackView.topAnchor.constraint(equalTo: verifiedTitle.bottomAnchor, constant: Layout.verifiedLogosTopMargin),
            verifiedLogosStackView.leftAnchor.constraint(equalTo: verifiedContainer.leftAnchor),
            verifiedLogosStackView.heightAnchor.constraint(equalToConstant: Layout.logoSize),

            moreBioButton.heightAnchor.constraint(equalToConstant: Layout.moreBioButtonHeight)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func setupAccessibilityIds() {
        addBioButton.set(accessibilityId: .userProfileAddBioButton)
        buildTrustButton.set(accessibilityId: .userProfileBuildTrustButton)
        verifiedTitle.set(accessibilityId: .userProfileVerifiedTitle)
        moreBioButton.set(accessibilityId: .userProfileMoreBioTitle)
        bioLabel.set(accessibilityId: .userProfileBioLabel)
    }

    private func updateAccountsVisibility() {
        guard let verifiedAccounts = accounts else { return }
        verifiedLogosStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if verifiedAccounts.facebookVerified {
            addVerifiedAccountWith(image: R.Asset.IconsButtons.icVerifiedFb.image, accessibilityId: .userProfileVerifiedWithFacebook)
        }

        if verifiedAccounts.googleVerified {
            addVerifiedAccountWith(image: R.Asset.IconsButtons.icVerifiedGoogle.image, accessibilityId: .userProfileVerifiedWithGoogle)
        }

        if verifiedAccounts.emailVerified {
            addVerifiedAccountWith(image: R.Asset.IconsButtons.icVerifiedEmail.image, accessibilityId: .userProfileVerifiedWithEmail)
        }

        verifiedContainer.isHidden = !verifiedAccountsVisible
        buildTrustButton.isHidden = !buildTrustButtonVisible
        updateButtonContainerVisibility()
    }

    private func addVerifiedAccountWith(image: UIImage, accessibilityId: AccessibilityId) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.heightAnchor.constraint(equalToConstant: Layout.logoSize).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: Layout.logoSize).isActive = true
        imageView.set(accessibilityId: accessibilityId)
        verifiedLogosStackView.addArrangedSubview(imageView)
    }

    private func updateBioVisibility() {
        moreBioButton.isHidden = !showMoreBioButtonVisible
        addBioButton.isHidden = !addBioButtonVisible
        bioLabel.text = userBio
        updateButtonContainerVisibility()
    }

    private func updateButtonContainerVisibility() {
        buttonContainer.isHidden = !buildTrustButtonVisible && !addBioButtonVisible
    }

    private func setupBuildTrustButton() {
        buildTrustButton.setStyle(.secondary(fontSize: .small, withBorder: true))
        buildTrustButton.contentEdgeInsets = UIEdgeInsets(top: 0,
                                                          left: Layout.buttonInset,
                                                          bottom: 0,
                                                          right: Layout.buttonInset + Layout.buttonTitleInset)
        buildTrustButton.titleEdgeInsets = UIEdgeInsets(top: 0,
                                                        left: Layout.buttonTitleInset,
                                                        bottom: 0,
                                                        right: -Layout.buttonTitleInset)
        buildTrustButton.layer.cornerRadius = Layout.buttonHeight / 2
        buildTrustButton.setImage(R.Asset.IconsButtons.icBuildTrustSmall.image, for: .normal)
    }

    private func setupMoreBioButton() {
        moreBioButton.setTitleColor(UIColor.grayDark, for: .normal)
        moreBioButton.titleLabel?.font = UIFont.sectionTitleFont
        moreBioButton.contentEdgeInsets = UIEdgeInsets(top: 0,
                                                       left: Layout.buttonInset,
                                                       bottom: 0,
                                                       right: Layout.buttonTitleInset)
        moreBioButton.titleEdgeInsets = UIEdgeInsets(top: 0,
                                                     left: Layout.buttonTitleInset,
                                                     bottom: 0,
                                                     right: -Layout.buttonTitleInset)
        moreBioButton.layer.cornerRadius = Layout.buttonHeight / 2
        moreBioButton.setImage(R.Asset.IconsButtons.chevronDownGrey.image, for: .normal)
        moreBioButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        moreBioButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        moreBioButton.imageView?.transform = Layout.iconDefaultTransform
    }

    @objc private func didTapAddBio() {
        delegate?.didTapAddBio()
    }

    @objc private func didTapBuildTrust() {
        delegate?.didTapBuildTrust()
    }

    @objc private func toggleBioLabel() {
        isAnimatingResize.value = true
        UIView.animate(withDuration: 0.2, animations: {
            self.moreBioButton.imageView?.transform = !self.bioLabel.isHidden ? Layout.iconDefaultTransform : Layout.iconRotatedTransform
            self.bioLabel.isHidden = !self.bioLabel.isHidden
            self.bioLabel.alpha = self.bioLabel.isHidden ? 0 : 1
            self.layoutIfNeeded()
        }) { [weak self] (isCompleted) in
            guard isCompleted else { return }
            self?.isAnimatingResize.value = false
        }
    }
}
