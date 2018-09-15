import Foundation
import UIKit
import LGCoreKit
import LGComponents

final class ListingDeckActionView: UIView {

    private struct Layout {
        struct Height {
            static let actionButton: CGFloat = 48.0
            static let blank: CGFloat = Metrics.shortMargin
        }
    }

    let actionButton: LetgoButton = {
        let button = LetgoButton(withStyle: .terciary)
        button.setTitle(R.Strings.productMarkAsSoldButton, for: .normal)
        return button
    }()

    private var fullViewContraints: [NSLayoutConstraint] = []
    private var actionButtonCenterY: NSLayoutConstraint?
    private var actionButtonBottomAnchorConstraint: NSLayoutConstraint?

    private var actionButtonBottomMargin: CGFloat {
        return -(bumpUpBanner.intrinsicContentSize.height + Layout.Height.blank)
    }

    private let separator: UIView = {
        let separator = UIView()
        separator.applyDefaultShadow()
        separator.layer.shadowOffset = CGSize(width: 0, height: -1)
        return separator
    }()

    let bumpUpBanner = BumpUpBanner()
    var isBumpUpVisible: Bool { return !bumpUpBanner.isHidden }

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    private func setup() {
        addSubviewsForAutoLayout([actionButton, separator, bumpUpBanner])
        let actionButtonCenterY = actionButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        let actionButtonBottomAnchorConstraint = actionButton.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                                                      constant: actionButtonBottomMargin)
        [
            actionButton.heightAnchor.constraint(equalToConstant: Layout.Height.actionButton),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.margin),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.margin),
            actionButtonCenterY,

            separator.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: Metrics.shortMargin),
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),

            bumpUpBanner.topAnchor.constraint(equalTo: separator.bottomAnchor),
            bumpUpBanner.leftAnchor.constraint(equalTo: leftAnchor),
            bumpUpBanner.rightAnchor.constraint(equalTo: rightAnchor),
            bumpUpBanner.centerXAnchor.constraint(equalTo: centerXAnchor)
        ].activate()

        fullViewContraints.append(contentsOf: [
            actionButton.topAnchor.constraint(equalTo: topAnchor, constant: Layout.Height.blank),
            actionButtonBottomAnchorConstraint
        ])

        self.actionButtonCenterY = actionButtonCenterY
        self.actionButtonBottomAnchorConstraint = actionButtonBottomAnchorConstraint
        setupUI()
    }

    func updatePrivateActionsWith(actionsAlpha: CGFloat) {
        actionButton.alpha = actionsAlpha
        separator.alpha = actionsAlpha
        bumpUpBanner.alpha = actionsAlpha
    }

    func resetCountdown() {
        bumpUpBanner.resetCountdown()
    }

    func hideBumpUp() {
        bumpUpBanner.isHidden = true
        separator.isHidden = true

        invalidateIntrinsicContentSize()
        fullModeAlignment(false)
    }

    func updateBumpUp(withInfo info: BumpUpInfo) {
        bumpUpBanner.updateInfo(info: info)
        switch info.type {
        case .boost(let boostBannerVisible):
            actionButtonBottomAnchorConstraint?.constant = boostBannerVisible ? -CarouselUI.bannerHeight*2 : -CarouselUI.bannerHeight
        case .free, .hidden, .priced, .restore, .loading:
            actionButtonBottomAnchorConstraint?.constant = -CarouselUI.bannerHeight
        }
    }

    func showBumpUp() {
        bumpUpBanner.isHidden = false
        separator.isHidden = false

        invalidateIntrinsicContentSize()
        fullModeAlignment(true)
    }

    private func setupUI() {
        backgroundColor = .clear
        separator.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        bumpUpBanner.isHidden = true
        separator.isHidden = true

        bringSubview(toFront: actionButton)

        fullModeAlignment(true)
    }

    private func fullModeAlignment(_ isEnabled: Bool) {
        fullViewContraints.forEach {
            $0.isActive = isEnabled
        }
        actionButtonCenterY?.isActive = !isEnabled
    }
    
}
